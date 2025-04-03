(module
  (import "wasi_snapshot_preview1" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))
  (import "wasi_snapshot_preview1" "path_open" (func $path_open (param i32 i32 i32 i32 i32 i64 i64 i32 i32) (result i32)))
  (import "wasi_snapshot_preview1" "fd_read" (func $fd_read (param i32 i32 i32 i32) (result i32)))
  (import "wasi_snapshot_preview1" "proc_exit" (func $proc_exit (param i32)))

  (memory (export "memory") 1)

  (data (i32.const 16) "1.txt")
  (data (i32.const 8) "crash!\n")

  (func $assert (param $condition i32)
    (if (i32.eq (local.get $condition) (i32.const 0))
      (then
        (call $write (i32.const 1) (i32.const 8) (i32.const 7))
        (call $proc_exit (i32.const 0))
      )
    )
  )

  (func $write (param $file i32) (param $ptr i32) (param $len i32)
    (i32.store (i32.const 0) (local.get $ptr))
    (i32.store (i32.const 4) (local.get $len))
    (call $fd_write
      (local.get $file)
      (i32.const 0)
      (i32.const 1)
      (i32.const 0)
    )
    (call $assert (i32.eq (i32.const 0)))
  )

  (func $get_file (param $path_ptr i32) (param $path_len i32) (result i32)
    (call $path_open
      (i32.const 3)
      (i32.const 0x1)
      (local.get $path_ptr)
      (local.get $path_len)
      (i32.const 0x0)
      (i64.const 3)
      (i64.const 3)
      (i32.const 0x0)
      (i32.const 0)
    )
    (call $assert (i32.eq (i32.const 0)))
    
    (i32.load (i32.const 0))
  )
  
  (func $read (param $file_ptr i32) (param $file_len i32) (param $buf_ptr i32) (param $buf_len i32) (result i32)
    (local $file i32)
    (local.set $file (call $get_file (local.get $file_ptr) (local.get $file_len)))

    (i32.store (i32.const 0) (local.get $buf_ptr))
    (i32.store (i32.const 4) (local.get $buf_len))

    (call $fd_read
      (local.get $file)
      (i32.const 0)
      (i32.const 1)
      (i32.const 0)
    )
    (call $assert (i32.eq (i32.const 0)))

    (i32.load (i32.const 0))
  )

  (func $format_u32 (param $x i32) (param $ptr i32) (result i32)
    (local $len i32)
    (local $x_ i32)
    (local $i i32)
    (local.set $x_ (local.get $x))
    (loop $len
      (local.set $len (i32.add (local.get $len) (i32.const 1)))
      (local.set $x_ (i32.div_u (local.get $x_) (i32.const 10)))
      (br_if $len (i32.gt_u (local.get $x_) (i32.const 0)))
    )
    
    (loop $store
      (local.set $ptr (i32.sub (local.get $ptr) (i32.const 1)))
      (i32.store8 (i32.add (local.get $ptr) (local.get $len)) (i32.add (i32.rem_u (local.get $x) (i32.const 10)) (i32.const 48)))
      (local.set $x (i32.div_u (local.get $x) (i32.const 10)))
      (br_if $store (i32.gt_u (local.get $x) (i32.const 0)))
    )
  
    (local.get $len)
  )

  (func $print_u32 (param $x i32)
    (local $len i32)
    (local $ptr i32)
    (local.set $ptr (i32.const 10_000))
    (local.set $len (call $format_u32 (local.get $x) (local.get $ptr)))
    (i32.store (i32.add (local.get $ptr) (local.get $len)) (i32.const 10))
    (call $write
      (i32.const 1)
      (local.get $ptr)
      (i32.add (local.get $len) (i32.const 1))
    )
  )

  (func $next_newline (param $ptr i32) (param $max i32) (result i32)
    (loop $read
      (local.set $ptr (i32.add (local.get $ptr) (i32.const 1)))
      (br_if $read (i32.and (i32.le_u (local.get $ptr) (local.get $max)) (i32.ne (i32.load8_u (local.get $ptr)) (i32.const 10))))
    )
    (local.get $ptr)
  )

  (func $parse_u32 (param $ptr i32) (param $len i32) (result i32)
    (local $x i32)
    (local $i i32)
    (local.set $i (i32.const 0))
    (local.set $x (i32.const 0))
    (loop $parse
      (local.set $x (i32.mul (local.get $x) (i32.const 10)))
      (local.set $x (i32.add (local.get $x) (i32.sub (i32.load8_u (i32.add (local.get $ptr) (local.get $i))) (i32.const 48))))
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br_if $parse (i32.le_u (local.get $i) (local.get $len)))
    )
    (local.get $x)
  )

  (func (export "_start")
    (local $ptr i32)
    (local $len i32)
    (local $max i32)
    (local $p1 i32)
    (local $p2 i32)
    (local $n1 i32)
    (local $p3 i32)
    (local $p4 i32)
    (local $n2 i32)
    (local $sum i32)

    (local.set $ptr (i32.const 100))
    (local.set $len 
      (call $read
        (i32.const 16)
        (i32.const 5)
        (local.get $ptr)
        (i32.const 900)
      )
    )
    (local.set $max (i32.add (local.get $ptr) (local.get $len)))

    (local.set $p1 (local.get $ptr))
    (loop $outer
      (local.set $p2 (call $next_newline (local.get $p1) (local.get $max)))
      (local.set $n1 (call $parse_u32 (local.get $p1) (i32.sub (i32.sub (local.get $p2) (local.get $p1)) (i32.const 1))))
      (local.set $p2 (i32.add (local.get $p2) (i32.const 1)))
      (local.set $p1 (local.get $p2))
      (local.set $p3 (local.get $p2))
      (if (i32.le_u (local.get $p2) (i32.sub (local.get $max) (i32.const 2)))
        (then
          (loop $inner
            (local.set $p4 (call $next_newline (local.get $p3) (local.get $max)))
            (local.set $n2 (call $parse_u32 (local.get $p3) (i32.sub (i32.sub (local.get $p4) (local.get $p3)) (i32.const 1))))
            (local.set $p4 (i32.add (local.get $p4) (i32.const 1)))
            (local.set $p3 (local.get $p4))
            (if (i32.eq (i32.add (local.get $n1) (local.get $n2)) (i32.const 2020))
              (then
                (call $print_u32 (i32.mul (local.get $n1) (local.get $n2)))
                (call $proc_exit (i32.const 0))
              )
            )
            (br_if $inner (i32.le_u (local.get $p4) (i32.sub (local.get $max) (i32.const 2))))
          )
          (br $outer)
        )
      )
    )
  )
)

