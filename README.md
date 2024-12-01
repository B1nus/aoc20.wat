# Advent of Code 2020 in WAT
Solving [Advent of Code 2020](https://adventofcode.com/2020) in the [WebAssembly Text Format](https://developer.mozilla.org/en-US/docs/WebAssembly/Understanding_the_text_format), the "human-readable" version of WebAssembly. I'm doing this because I need to have a deep understanding of WebAssembly for an upcoming project.

# WASI
I'm using [WASI](https://wasi.dev/) for printing to the terminal. To run my files you first need to install the compiler [`wabt`](https://github.com/WebAssembly/wabt) and the runtime [`wasmtime`](https://wasmtime.dev/). Then you can run my programs with: `wat2wasm 5.wat --output=- | wasmtime <(cat)`.

> [!NOTE]
> I am not reading the files with WASI because it is a pain. I use `$ wl-paste | sed ':a;N;$!ba;s/\n/\\n/g' | wl-copy < <(cat)` to take the input from my clipboard and format it with `\n` as newlines. So yes I am cheating a little bit.
