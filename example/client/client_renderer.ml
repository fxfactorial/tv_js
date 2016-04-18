open Lwt.Infix

let ( !@ ) f = Js.wrap_callback f

let attach_video_handler () =
  Lwt.async (fun () ->
      let btn = Dom_html.getElementById "create" in
      Lwt_js_events.click btn >|= fun event ->
      (* let video = Dom_html.createVideo Dom_html.document in *)

      print_endline "Button clicked"
    )



let () =
  attach_video_handler ();
  let nav = Js.Unsafe.global##.navigator in
  nav##webkitGetUserMedia (object%js
    val audio = false |> Js.bool
    val video = (object%js
      val mandatory = (object%js
        val chromeMediaSource = "screen" |> Js.string
        val maxWidth = 560
        val maxHeight = 600
      end)
      val optional = new%js Js.array_empty
    end)
  end)
    !@(Js.Unsafe.(fun stream ->
        let handle = Dom_html.getElementById "video" in
        [|stream|]
        |> meth_call (get Dom_html.window "URL") "createObjectURL"
        |> set handle "src"
      ))
    !@(fun _ -> print_endline "Didn't get the stream")
