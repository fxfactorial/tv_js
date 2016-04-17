open StdLabels

(* Later create an MLI and private type on this record, then people
   can see the fields but can't actually make one *)
type device =
  {app_id : string;
   app_version: string;
   model : string;
   product_type : string;
   system_version : string;
   vendor_id : string}

type highlight = {
  name : string;
  description : string;
  start_time : int;
  duration : int;
  image_url : string;
}

module Helper_funcs = struct
  (* For when you know its going to be there. *)
  let ( <!!!> ) obj field = Js.Unsafe.get obj field

  let ( !@ ) f = Js.wrap_callback f

  let ( !! ) o = Js.Unsafe.inject o

  let m = Js.Unsafe.meth_call

  (* For when you might get back undefined *)
  let ( <!!> ) obj key =
    Js.Optdef.map (obj <!!!> key |> Js.def) Js.to_string
    |> Js.Optdef.to_option

  (* For when you might get it or null *)
  let ( <!> ) obj key =
    Js.Opt.case (obj <!!!> key)
      (fun () -> None)
      (function item -> Some item)

end

module Raw_handles = struct

  (* objects *)
  let (app_class_raw, device_class_raw, event_listen_raw,
       player_raw, xmlhttprequest_raw, device_raw,
       settings_raw, mediaitem_raw, playlist_raw) = Js.Unsafe.(
      global##.App, global##.Device, global##.EventListenObject,
      global##.Player, global##.XMLHttpRequest, global##.Device,
      global##.Settings, global##.MediaItem, global##.Playlist)

  (* functions *)
  let (eval_script_raw, clear_interval_raw, set_interval_raw,
       set_timeout_raw, format_date_raw, format_duration_raw,
       formate_number_raw, uuid_raw, get_active_document_raw,
       open_url_raw) = Js.Unsafe.(
      js_expr "evaluateScripts", js_expr "clearInterval",
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

class media_item ?existing ?url (media_t: [`Audio | `Video]) = object
  val raw_js = match existing with
    | None ->
      new%js Raw_handles.mediaitem_raw
        ((match media_t with `Audio -> "audio" | `Video -> "video") |> Js.string)
        (match url with None -> Js.null | Some u -> Js.string u |> Js.Opt.return)
    | Some given -> given

  method content_rating_domain : [`Movie | `Music | `Tv_show] =
    match (Helper_funcs.m raw_js "contentRatingDomain" [||])
          |> Js.to_string with
    | "movie" -> `Movie
    | "music" -> `Music
    | "tvshow" -> `Tv_show
    | _ -> raise (Failure "Not possible")

  (* goes from 0 to 1000 *)
  method content_rating_ranking : int =
    Helper_funcs.m raw_js "contentRatingRanking" [||]

  method is_explicit = Helper_funcs.m raw_js "isExplicit" [||] |> Js.to_bool
  method artwork_image_url = ()
  method description = ()
  method subtitle = ()
  method title = ()
  method type_ : [`Audio | `Video ] =
    match Helper_funcs.m raw_js "type" [||] |> Js.to_string with
    | "audio" -> `Audio
    | "video" -> `Video
    | _ -> raise (Failure "Not possible")
  method url = ()

  method set_highlight_groups ~highlights:(highlights: highlight list) =
    let js_objs =
      highlights
      |> List.map ~f:(fun r -> object%js
                       val name = r.name
                       val description = r.description
                       val starttime = r.start_time
                       val duration = r.duration
                       val imageURL = r.image_url
                     end)
      |> Array.of_list |> Js.array
    in
    raw_js##.highLightGroups := js_objs

  method set_interstitials = ()

  method set_resume ~resume_at:(resume_at : [`Int of int | `From_beginning ])
    : unit = ()

  method set_load_asset_id = ()

  method set_load_certificate = ()

  method set_loadkey = ()

  (* Not sure how to avoid this for methods like push on Playlist but
     not a huge deal *)
  method raw = Helper_funcs.(!!raw_js)

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


(* type settings = *)
(*   {restrictions : string; *)
(*    langauge : string; *)
(*   on} *)

let device = Raw_handles.(Helper_funcs.(
    {app_id = device_raw <!!!> "appIdentifier" |> Js.to_string;
     app_version = device_raw <!!!> "appVersion" |> Js.to_string;
     model = device_raw <!!!> "model" |> Js.to_string;
     product_type = device_raw <!!!> "model" |> Js.to_string;
     system_version = device_raw <!!!> "systemVersion" |> Js.to_string;
     vendor_id = device_raw <!!!> "vendorIdentifier" |> Js.to_string}
  ))

class keyboard = object

  end

module type App = sig

  val on_error :
    string ->
    source_url:string option ->
    error_line:int option ->
    unit

  val on_exit : <reloading : bool option> -> unit

  val on_launch  :
    <launch_context : string option;
     location : string option;
     reload_data : (string * Js.Unsafe.any) list;
     custom_keys : (string * Js.Unsafe.any) list> -> unit
  (* val on_resume  : unit -> unit *)
  (* val on_suspend : unit -> unit *)
  (* val do_reload  : *)
  (*   options_when_reload : <reloaded_when : [`On_resume | `Now]> option -> *)
  (*   reload_data : (string * Js.Unsafe.any) list -> *)
  (*   unit *)
end

module Make(App : App) = struct

  open Helper_funcs

  let raw_js = Raw_handles.app_class_raw

  (* Set the callbacks *)
  let () =
    raw_js##.onLaunch := !@(fun options ->
        App.on_launch (object
          method launch_context = options <!!> "launchContext"
          method location = options <!!> "location"
          method reload_data = []
          method custom_keys = []
        end));

    raw_js##.onError := Js.Opt.(!@(fun error_message source_url line ->
        App.on_error
          (error_message |> Js.to_string)
          (to_option source_url)
          (to_option line)));

    raw_js##.onExit := !@(fun opts ->
        App.on_exit (object
          method reloading = opts <!> "reloading"
        end))

end

module Functions = struct
  open Helper_funcs

  let eval_js_scripts ~scripts ~did_load:(did_load: bool -> unit) = Js.Unsafe.(
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

class playlist = object
  val raw_js = new%js Raw_handles.playlist_raw

  method media_item index : media_item = Helper_funcs.(
      (m raw_js "item" [|index|])
      (* Js.Opt.case (m raw_js "item" [|index|]) *)
        (* (fun () -> ) *)
        (* (fun provided  -> ) *)
    )

  method length : int = Helper_funcs.(raw_js <!!!> "length")

  method pop : media_item = Helper_funcs.(
      m raw_js "pop" [||]
    )

  method push ~media_item:(media_item: media_item) = Helper_funcs.(
      m raw_js "push" [|media_item#raw|] |> ignore
    )

  (* method splice ~from:(from:int) ~length:(length: int) ~replace_with:() *)

end
