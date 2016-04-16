open StdLabels

module Helper_funcs = struct
  let ( <!> ) obj field = Js.Unsafe.get obj field
  let ( !@ ) f = Js.wrap_callback f
  let ( !! ) o = Js.Unsafe.inject o
  let m = Js.Unsafe.meth_call
end

module Raw_handles = struct

  (* objects *)
  let (app_class_raw,
       device_class_raw,
       event_listen_raw,
       player_raw,
       xmlhttprequest_raw,
       device_raw,
       settings_raw,
      mediaitem_raw) =
    Js.Unsafe.(global##.App, global##.Device, global##.EventListenObject,
               global##.Player, global##.XMLHttpRequest, global##.Device,
               global##.Settings, global##.MediaItem)

  (* functions *)
  let (eval_script_raw,
       clear_interval_raw,
       set_interval_raw,
       set_timeout_raw,
       format_date_raw,
       format_duration_raw,
       formate_number_raw,
       uuid_raw,
       get_active_document_raw,
       open_url_raw ) =
    Js.Unsafe.(js_expr "evaluateScripts", js_expr "clearInterval",
               js_expr "setInterval", js_expr "setTimeout",
               js_expr "formatDate", js_expr "formatDuration",
               js_expr "formatNumber", js_expr "UUID",
               js_expr "getActiveDocument", js_expr "openURL")

end

class virtual event_listener = object
  method virtual add_event_listener :
    ?extra_info:Js.Unsafe.any option ->
    event_name:string -> listen_cb:(unit -> unit) -> unit
  method virtual remove_event_listener :
    event_name:string -> listen_cb:(unit -> unit) -> unit
end

class mediaitem ?url type_ = object
  val raw_js = new%js Raw_handles.mediaitem_raw

  method content_rating_domain : [`Movie | `Music | `Tv_show] =
    match (Helper_funcs.m raw_js "contentRatingDomain" [||])
          |> Js.to_string with
    | "movie" -> `Movie
    | "music" -> `Music
    | "tvshow" -> `Tv_show
    | _ -> raise (Failure "Not possible")
end

class player = object
  inherit event_listener
  val raw_js = new%js Raw_handles.player_raw
  method add_event_listener ?extra_info ~event_name ~listen_cb = ()
  method remove_event_listener ~event_name ~listen_cb = ()
  method overlay_document = ()
  method playlist = ()
  method present : unit = Helper_funcs.m raw_js "present" [||]
  method pause = ()
  method play = ()
  method play_back_state = ()

end

(* Not sure how to make this a private type and make it work *)
type device =
  {app_id : string;
   app_version: string;
   model : string;
   product_type : string;
   system_version : string;
   vendor_id : string}

(* type settings = *)
(*   {restrictions : string; *)
(*    langauge : string; *)
(*   on} *)


let device = Raw_handles.(Helper_funcs.(
    {app_id = device_raw <!> "appIdentifier" |> Js.to_string;
     app_version = device_raw <!> "appVersion" |> Js.to_string;
     model = device_raw <!> "model" |> Js.to_string;
     product_type = device_raw <!> "model" |> Js.to_string;
     system_version = device_raw <!> "systemVersion" |> Js.to_string;
     vendor_id = device_raw <!> "vendorIdentifier" |> Js.to_string}
  ))

class keyboard = object

  end

module type App = sig
  val on_error :
    string ->
    source_url:string option ->
    error_line:int option ->
    unit
  val on_exit    :
    <message : string; source_url : string option; line_number : int option> -> unit
  val on_launch  :
    <launch_context : string;
     location : string;
     reload_data : (string * Js.Unsafe.any) list;
     custom_keys : (string * Js.Unsafe.any) list> -> unit
  val on_resume  : unit -> unit
  val on_suspend : unit -> unit
  val do_reload  :
    options_when_reload : <reloaded_when : [`On_resume | `Now]> option ->
    reload_data : (string * Js.Unsafe.any) list ->
    unit
end

module Make(App : App) = struct
  (* Implement this please *)

end

module Functions = struct
  open Helper_funcs

  let eval_js_scripts ~scripts ~did_load:(did_load: bool -> unit) =
    Js.Unsafe.(
      let eval_us =
        scripts
        |> List.map ~f:Js.string
        |> Array.of_list
        |> Js.array
      in
      [|inject eval_us; !!(fun value -> did_load (value |> Js.to_bool))|]
      |> fun_call Raw_handles.eval_script_raw
    )

  let clear_interval = ()

  let clear_timeout = ()

  let set_interval = ()

  let set_timeout = ()

  let format_date = ()

  let format_duration = ()

  let format_number = ()

  let udid () =
    Js.Unsafe.(fun_call Raw_handles.uuid_raw [||]) |> Js.to_string

  let get_active_document = ()

  let open_url = ()

end

