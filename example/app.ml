open Tv_js

module Delegate = Make(struct
    let on_launch obj =
      print_endline "Launched"
  end)
