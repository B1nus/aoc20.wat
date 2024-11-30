# aoc24.wat
Solving [Advent of Code 2024](https://adventofcode.com/2023) in the [WebAssembly Text Format](https://developer.mozilla.org/en-US/docs/WebAssembly/Understanding_the_text_format), the "human-readable" version of WebAssembly. I'm doing this because I need to have a deep understanding of WebAssembly for an upcoming project.

# WASI
I'm using [WASI](https://wasi.dev/) for reading files and printing to the terminal. To run my files you first need to install the compiler [`wabt`](https://github.com/WebAssembly/wabt) and the runtime [`wasmtime`](https://wasmtime.dev/). Then you can run my programs with: `wat2wasm 5.wat --output=- | wasmtime --dir=. <(cat)`. You're going to need your own input files, store them in the root directory with the day number and then `.txt` as the files name. For example `5.txt` for the input for day 5.
