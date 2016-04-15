#!/bin/sh

# for prod built For Production: "–opt 3". It minimize the generated
# javascript by applying various optimizations until a fix-point is
# reached

js_of_ocaml --pretty --debug-info app.byte -o app.js
