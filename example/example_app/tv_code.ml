open Tv_js

module P = Printf

let launch_video () =
  (* var mediaItem = new MediaItem('video', 'http://trailers.apple.com/movies/\ *)
  (* focus_features/9/9-clip_480p.mov');\ *)
  Js.Unsafe.eval_string
    "(function (){\
     var player = new Player();\
     var playlist = new Playlist();\
     var mediaItem = new MediaItem('video', \
     'http://localhost:9001/working_server.mov');\
     player.playlist = playlist;\
     player.playlist.push(mediaItem);\
     player.present();})()"

module Delegate = Make(struct

    let on_exit obj =
      match obj#reloading with
      | None -> print_endline "Exited"
      | Some b ->
        print_endline (P.sprintf "%b" b)

    let on_error message ~source_url ~error_line =
      (match source_url, error_line with
      (* | (Some s_url, Some s_l) -> *)
      (*   P.sprintf "Error: %s at %s, %d" message s_url s_l *)
      | _ -> P.sprintf "Error: %s" message)
      |> print_endline

    (* Your entry point to the application, think
       ApplicationDidFinishLaunching *)
    let on_launch obj =
      ((match obj#launch_context, obj#location with
          | (Some l_ctx, Some loc) ->
            P.sprintf "Launch context: %s, Location: %s" l_ctx loc
          | (None, Some loc) -> P.sprintf "Only: Location: %s" loc
          | (Some l_ctx, None) -> P.sprintf "Only: launch context: %s" l_ctx
          | _ -> P.sprintf "Neither launch context or location provided from system")
       |> print_endline);
      launch_video ()

  end)
