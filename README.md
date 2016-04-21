tv_js
======

These are `OCaml` bindings to the TVML JavaScript environment.

Create amazing Apple TV applications using `OCaml`!

Installation
==============

`git clone` this repo, `cd` to it and then do:

```shell
opam pin add tv_js . -y
```

Usage
======

To use this code you need to use the `Tv_js.Make` functor which will
be your implementation for the `Tv_js.App` interface.

Here's a starting point:

```ocaml
(* file is called application.ml *)
module Delegate = Make(struct

    let on_exit obj =
      match obj#reloading with
      | None -> print_endline "Exited"
      | Some b ->
        print_endline (P.sprintf "%b" b)

    let on_error message ~source_url ~error_line =
      (match source_url, error_line with
       | (Some s_url, Some s_l) ->
         P.sprintf "Error: %s at %s, %d" message s_url s_l
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

  end)
```

Compile with first to byte code:

```shell
$ ocamlfind ocamlc -linkpkg -package tv_js application.ml -o application
```

Then compile to `JavaScript`:

```shell
$ js_of_ocaml application -o application.js	
```

Now you have type safe `JavaScript` that the Apple TV can run.

More Full Featured example
==============================

Included in this repo is a more full featured example that uses
`OCaml` bindings to both `express` and `electron` as a Desktop
application that starts a stream from the local client and streams it
to the Apple TV, ie:

```ocaml
let video () =
  let (player, playlist, media_item) =
    new player (),
    new playlist (),
    new media_item `Video ~url:"http://localhost:9001/working_server.mov"
  in
  player#set_playlist playlist;
  player#playlist#push ~media_item;
  player#present
```

The full featured example requires you to have npm installed
`electron`, `jade`, `electron`. 
