#!/bin/sh

set -e

# for prod built For Production: "–opt 3". It minimize the generated
# javascript by applying various optimizations until a fix-point is
# reached

mkdir -p example/build

jsoo_debug='js_of_ocaml --pretty --debug-info --no-inline --source-map '
jsoo_prod='js_of_ocaml -opt 3 '

build_dir='example/build'

${jsoo_debug} tv_code.byte -o ${build_dir}/tv_app.js
${jsoo_debug} client_main.byte -o ${build_dir}/main.js
${jsoo_debug} client_renderer.byte -o ${build_dir}/client_renderer.js

jade --pretty < example/index.jade > example/build/index.html
