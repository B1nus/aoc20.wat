(component
  (core module $main
    (import "deps" "realloc" (func $realloc (param i32 i32 i32 i32) (result i32)))
    (import "deps" "memory" (memory 1))
    (import "wasi:io/streams" "[method]output-stream.blocking-write-and-flush" (func $"[method]output-stream.blocking-write-and-flush" (param i32 i32 i32 i32)))
    (import "wasi:io/streams" "[method]input-stream.read" (func $"[method]input-stream.read" (param i32 i64 i32)))
    (import "wasi:cli/stdout" "get-stdout" (func $get-stdout (result i32)))
    (import "wasi:cli/stdin" "get-stdin" (func $get-stdin (result i32)))

    (func $main (export "run") (result i32)
      (local $ptr i32)
      (local $len i32)
      (local $max i32)
      (local $count i32)
      (call $input)
      (local.set $len)
      (local.set $ptr)
      (local.set $max (i32.add (local.get $ptr) (local.get $len)))
      (loop
        (if (call $is-valid-passport (local.get $ptr) (local.get $max))
          (then (local.set $count (i32.add (local.get $count) (i32.const 1)))))
        (local.set $ptr (i32.add (i32.const 1)))
        (br_if 0 (i32.le_u (local.get $ptr) (local.get $max))))
      (call $output-u32 (local.get $count))
      (i32.const 0))

    (func $is-valid-passport (param $ptr i32) (param $max i32) (result i32 i32)
      (call $mask (local.get $ptr) (local.get $max))
      (i32.eq (i32.const 0xFF)))

    (func $mask (param $ptr i32) (param $max i32) (result i32 i32)
      (local $field i32)
      (local $mask i32)
      (local.set $mask (i32.const 0x80))
      (loop $l
        (local.set $field (call $read-field (local.get $ptr)))
        (if (i32.ne (local.get $field) (i32.const -1))
          (then
            (local.set $mask (i32.or (local.get $mask) (i32.shl (i32.const 1) (local.get $field))))
            (local.set $ptr (call $skip-to-next-field (local.get $ptr) (local.get $max)))
            (br $l))))
      (local.get $ptr)
      (local.get $mask))

    (func $read-field (param $ptr i32) (result i32)
      (local $c i32)
      (local $c2 i32)
      (local.set $c (i32.load8_u (local.get $ptr)))
      (local.set $c2 (i32.load8_u (i32.add (local.get $ptr) (i32.const 1))))
      (if (result i32) (i32.eq (local.get $c) (i32.const 0x62))
        (then (i32.const 0))
      (else (if (result i32) (i32.eq (local.get $c) (i32.const 0x69))
        (then (i32.const 1))
      (else (if (result i32) (i32.and (i32.eq (local.get $c) (i32.const 0x65)) (i32.eq (local.get $c2) (i32.const 0x79)))
        (then (i32.const 2))
      (else (if (result i32) (i32.and (i32.eq (local.get $c) (i32.const 0x68)) (i32.eq (local.get $c2) (i32.const 0x67)))
        (then (i32.const 3))
      (else (if (result i32) (i32.eq (local.get $c) (i32.const 0x68))
        (then (i32.const 4))
      (else (if (result i32) (i32.eq (local.get $c) (i32.const 0x65))
        (then (i32.const 5))
      (else (if (result i32) (i32.eq (local.get $c) (i32.const 0x70))
        (then (i32.const 6))
      (else (if (result i32) (i32.eq (local.get $c) (i32.const 0x63))
        (then (i32.const 7))
      (else
        (i32.const -1)))))))))))))))))
    )

    (func $skip-to-next-field (param $ptr i32) (param $max i32) (result i32)
      (local $c i32)
      (loop (result i32)
        (local.set $ptr (i32.add (local.get $ptr) (i32.const 1)))
        (local.set $c (i32.load8_u (local.get $ptr)))
        (local.get $ptr)
        (br_if 0 (i32.and (i32.and (i32.ne (local.get $c) (i32.const 0xa)) (i32.ne (local.get $c) (i32.const 0x20))) (i32.lt_u (local.get $ptr) (local.get $max)))))
      (i32.add (i32.const 1)))

    (func $output-u32 (param $u32 i32)
      (call $output-u64 (i64.extend_i32_u (local.get $u32))))

    (func $output-u64 (param $u64 i64)
      (call $format-u64 (local.get $u64))
      (call $append-u8 (i32.const 10))
      (call $output))

    (global $io-chunk-size (mut i32) (i32.const 0x1000))

    (func $append-u8 (param $ptr i32) (param $len i32) (param $u8 i32) (result i32 i32)
      (local $new-ptr i32)
      (local $new-len i32)

      (local.set $new-len (i32.add (local.get $len) (i32.const 1)))
      (local.set $new-ptr (call $realloc
        (local.get $ptr)
        (local.get $len)
        (i32.const 4)
        (local.get $new-len)))

      (i32.store8 (i32.add (local.get $new-ptr) (local.get $len)) (local.get $u8))
      (local.get $new-ptr)
      (local.get $new-len))

    (func $format-u64 (param $number i64) (result i32 i32)
      (local $len i32)
      (local $ptr i32)
      (local $i i32)
      (local $number-copy i64)
      (local.set $number-copy (local.get $number))

      (loop $len-loop
        (local.set $number-copy (i64.div_u (local.get $number-copy) (i64.const 10)))
        (local.set $len (i32.add (local.get $len) (i32.const 1)))
        (br_if $len-loop (i64.gt_u (local.get $number-copy) (i64.const 0))))

      (local.set $ptr (call $realloc
        (i32.const 0)
        (i32.const 0)
        (i32.const 4)
        (local.get $len)))
      (local.set $i (i32.add (local.get $ptr) (local.get $len)))
      (loop $store-loop
        (local.set $i (i32.sub (local.get $i) (i32.const 1)))
        (i32.store8 (local.get $i) (i32.add (i32.wrap_i64 (i64.rem_u (local.get $number) (i64.const 10))) (i32.const 0x30)))
        (local.set $number (i64.div_u (local.get $number) (i64.const 10)))
        (br_if $store-loop (i32.gt_u (local.get $i) (local.get $ptr))))

      (local.get $ptr)
      (local.get $len))
    
    (func $output (param $ptr i32) (param $len i32)
      (local $result-ptr i32)
      (local.set $result-ptr (call $realloc
        (i32.const 0)
        (i32.const 0)
        (i32.const 4)
        (i32.const 8) ;; is it twelve??
      ))
      (loop
        (call $"[method]output-stream.blocking-write-and-flush"
          (call $get-stdout)
          (local.get $ptr)
          (if (result i32) (i32.gt_u (local.get $len) (global.get $io-chunk-size))
            (then (global.get $io-chunk-size))
            (else (local.get $len))
          )
          (local.get $result-ptr)
        )
        (local.set $len (i32.sub (local.get $len) (global.get $io-chunk-size)))
        (local.set $ptr (i32.add (local.get $ptr) (global.get $io-chunk-size)))
        (br_if 0 (i32.gt_s (local.get $len) (i32.const 0)))))
    
    (func $input (result i32 i32)
      (local $ptr i32)
      (local $len i32)
      (local $current-len i32)
      (local.set $ptr (call $realloc (i32.const 0) (i32.const 0) (i32.const 4) (i32.const 12)))
      (loop $read
        (call $"[method]input-stream.read" 
          (call $get-stdin)
          (i64.extend_i32_u (global.get $io-chunk-size))
          (local.get $ptr)
        )
        (if (i32.eq (i32.load (local.get $ptr)) (i32.const 0))
          (then
            (local.set $current-len (i32.load offset=8 (local.get $ptr)))
            (local.set $len (i32.add (local.get $len) (local.get $current-len)))
            (br $read))))
      (i32.add (local.get $ptr) (i32.const 12))
      (local.get $len)))

  (core module $deps
    (memory (export "memory") 1)
    (global $memory-page-size i32 (i32.const 0x10000))
    (global $ptr (mut i32) (i32.const 0))
    (global $next-ptr (mut i32) (i32.const 0))

    (; Bump Allocator. Thanks Bryan Burgers: https://burgers.io/complete-novice-wasm-allocator ;)
    (func $realloc (export "realloc") (param $old-ptr i32) (param $old-size i32) (param $alignment i32) (param $new-size i32) (result i32)
      (if (i32.or (i32.ne (local.get $old-ptr) (global.get $ptr)) (i32.eq (local.get $old-size) (i32.const 0)))
        (then
          (memory.copy (i32.const 0) (global.get $next-ptr) (local.get $old-ptr) (local.get $old-size))
          (drop)
          (global.set $ptr (global.get $next-ptr))))
      (global.set $next-ptr (call $align-ptr
        (i32.add (global.get $ptr) (local.get $new-size))
        (local.get $alignment)))
      (call $grow-memory (global.get $next-ptr))
      (global.get $ptr))

    (func $align-ptr (param $ptr i32) (param $alignment i32) (result i32)
      (local $rem i32)
      (local.set $rem (i32.rem_u (local.get $ptr) (local.get $alignment)))
      (if (result i32) (i32.eqz (local.get $rem))
        (then (local.get $ptr))
        (else (i32.add (local.get $ptr) (i32.sub (local.get $alignment) (local.get $rem))))))

    (func $grow-memory (param $target-size i32)
      (local $size-to-grow i32)
      (local $pages i32)

      (local.set $size-to-grow (i32.sub (memory.size) (local.get $target-size)))
      (if (i32.gt_u (local.get $size-to-grow) (i32.const 0))
        (then
          (local.set $pages (call $ceil-div (local.get $size-to-grow) (global.get $memory-page-size)))
          (memory.grow (local.get $pages))
          (drop))))

    (func $ceil-div (param $dividend i32) (param $divisor i32) (result i32)
      (i32.div_u (i32.sub (i32.add (local.get $dividend) (local.get $divisor)) (i32.const 1)) (local.get $divisor)))
  )

  (; Wasi imports ;)
  (import "wasi:io/error@0.2.3" (instance $error
    (export "error" (type (sub resource)))
  ))
  (alias export $error "error" (type $error))
  (import "wasi:io/streams@0.2.3" (instance $streams
    (export $input-stream "input-stream" (type (sub resource)))
    (export $output-stream "output-stream" (type (sub resource)))
    (alias outer 1 $error (type $error))
    (type $stream-errors (variant
      (case "last-operation-failed" (own $error))
      (case "closed")
    ))
    (export $stream-error "stream-error" (type (eq $stream-errors)))
    (export "[method]output-stream.blocking-write-and-flush" (func
      (param "self" (borrow $output-stream))
      (param "contents" (list u8))
      (result (result (error $stream-error)))
    ))
    (export "[method]input-stream.read" (func
      (param "self" (borrow $input-stream))
      (param "len" u64)
      (result (result (list u8) (error $stream-error)))
    ))
  ))
  (alias export $streams "output-stream" (type $output-stream))
  (alias export $streams "input-stream" (type $input-stream))
  (import "wasi:cli/stdout@0.2.3" (instance $stdout
    (alias outer 1 $output-stream (type $output-stream-t))
    (export $eq-output-stream "output-stream" (type (eq $output-stream-t)))
    (export "get-stdout" (func (result (own $eq-output-stream))))
  ))
  (import "wasi:cli/stdin@0.2.3" (instance $stdin
      (alias outer 1 $input-stream (type $input-stream))
      (export $eq-input-stream "input-stream" (type (eq $input-stream)))
      (export "get-stdin" (func (result (own $eq-input-stream))))
  ))
  
  (; Wasi aliases ;)
  (core instance $deps (instantiate $deps))
  (core func $"[method]output-stream.blocking-write-and-flush" (canon lower
    (func $streams "[method]output-stream.blocking-write-and-flush")
    (memory $deps "memory")
    (realloc (func $deps "realloc"))
  ))
  (core func $"[method]input-stream.read" (canon lower
    (func $streams "[method]input-stream.read")
    (memory $deps "memory")
    (realloc (func $deps "realloc"))
  ))
  (core func $get-stdout (canon lower (func $stdout "get-stdout")))
  (core func $get-stdin (canon lower (func $stdin "get-stdin")))

  (; Instantiation of main module ;)
  (core instance $main (instantiate $main
    (with "deps" (instance
      (export "memory" (memory $deps "memory"))
      (export "realloc" (func $deps "realloc"))
    ))
    (with "wasi:cli/stdin" (instance
      (export "get-stdin" (func $get-stdin))
    ))
    (with "wasi:cli/stdout" (instance
      (export "get-stdout" (func $get-stdout))
    ))
    (with "wasi:io/streams" (instance
      (export "[method]output-stream.blocking-write-and-flush" (func $"[method]output-stream.blocking-write-and-flush"))
      (export "[method]input-stream.read" (func $"[method]input-stream.read"))
    ))
  ))

  (; Exporting main function ;)
  (func $run (result (result)) (canon lift (core func $main "run")))
  (component $cli
    (import "run" (func $run (result (result))))
    (export "run" (func $run))
  )
  (instance $cli (instantiate $cli (with "run" (func $run))))
  (export "wasi:cli/run@0.2.0" (instance $cli))
)
