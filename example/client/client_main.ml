open Nodejs

let start_server () =
  let app = new Express.app ~existing:None in
  let express = new Express.express in
  app#use (express#static (__dirname ()));
  app#listen ~port:9001

let () =
  let app = new Electron_main.App.app in
  let main_window = ref Js.null in
  let proc = new process in

  (fun () -> if proc#platform <> Darwin then app#quit)
  |> app#on_window_all_closed;

  app#on_ready
    (fun () ->
       main_window :=
         (new Electron_main.Browser_window.browser_window None)
         |>Js.Opt.return;

       let main_window_now =
         Js.Opt.get !main_window (fun () -> assert false)
       in

       main_window_now#load_url
         (Printf.sprintf "file://%s/index.html" (__dirname ()));

       (* main_window_now#open_dev_tools; *)

       main_window_now#on_closed (fun () -> main_window := Js.null));
  start_server ()
