open Lwt.Infix


let attach_video_handler () =
  Lwt.async (fun () ->
      let btn = Dom_html.getElementById "create" in
      Lwt_js_events.click btn >|= fun event ->
      let video = Dom_html.createVideo Dom_html.document in

      print_endline "Button clicked"
    )



let () =
  attach_video_handler ();
  (* let nav = Js.Unsafe.global##.navigator in *)
  (* nav##getUserMedia (object%js *)
  (*   val audio = false |> Js.bool *)
  (*   val video = (object%js *)
  (*     val mandatory = (object%js *)
  (*       val chromeMediaSource = "screen" |> Js.string *)
  (*       val maxWidth = 1280 *)
  (*       val maxHeight = 720 *)
  (*     end) *)
  (*     val optional = new%js Js.array_empty *)
  (*   end) *)
  (* end) *)
  (*   (Js.wrap_callback (fun stream -> *)
  (*       print_endline "Got handle on stream" *)
  (*     )) *)
  (*   (Js.wrap_callback (fun _ -> *)
  (*     print_endline "Didn't get the stream")) *)

  print_endline "Render side ran"
