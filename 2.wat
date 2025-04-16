(module
  (import "wasi_snapshot_preview1" "fd_read" (func $fd_read (param i32 i32 i32 i32) (result i32)))
  (import "wasi_snapshot_preview1" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))

  (memory (export "memory") 1)

  (func $write (param $file i32) (param $ptr i32) (param $len i32)
    (i32.store (i32.const 0) (local.get $ptr))
    (i32.store (i32.const 4) (local.get $len))
    (call $fd_write
      (local.get $file)
      (i32.const 0)
      (i32.const 1)
      (i32.const 0)
    )
    (drop)
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
    (local.set $ptr (i32.const 0xF00))
    (local.set $len (call $format_u32 (local.get $x) (local.get $ptr)))
    (i32.store (i32.add (local.get $ptr) (local.get $len)) (i32.const 10))
    (call $write
      (i32.const 1)
      (local.get $ptr)
      (i32.add (local.get $len) (i32.const 1))
    )
  )

  (func $read_policy (param $ptr i32) (result i32 i32 i32 i32)
    (local $min i32)
    (local $max i32)
    (local $char i32)
    (local.set $min (i32.const 0))
    (local.set $max (i32.const 0))
    (local.set $char (i32.const 0))
    (loop $min_loop
      (local.set $char (i32.load8_u (local.get $ptr)))
      (local.set $ptr (i32.add (i32.const 1) (local.get $ptr)))
      (if (i32.and (i32.lt_u (local.get $char) (i32.const 58)) (i32.ge_u (local.get $char) (i32.const 48)))
        (then
          (local.set $min (i32.mul (local.get $min) (i32.const 10)))
          (local.set $min (i32.add (local.get $min) (i32.sub (local.get $char) (i32.const 48))))
          (br $min_loop)
        )
      )
    )

    (loop $max_loop
      (local.set $char (i32.load8_u (local.get $ptr)))
      (local.set $ptr (i32.add (i32.const 1) (local.get $ptr)))
      (if (i32.and (i32.lt_u (local.get $char) (i32.const 58)) (i32.ge_u (local.get $char) (i32.const 48)))
        (then
          (local.set $max (i32.mul (local.get $max) (i32.const 10)))
          (local.set $max (i32.add (local.get $max) (i32.sub (local.get $char) (i32.const 48))))
          (br $max_loop)
        )
      )
    )

    (local.set $char (i32.load8_u (local.get $ptr)))

    (local.set $ptr (i32.add (local.get $ptr) (i32.const 1)))

    (local.get $min)
    (local.get $max)
    (local.get $char)
    (local.get $ptr)
  )

  (func $check_password (param $min i32) (param $max i32) (param $char i32) (param $ptr i32) (result i32 i32)
    (local $count i32)
    (local $byte i32)
    (loop $count_loop
      (local.set $byte (i32.load8_u (local.get $ptr)))
      (if (i32.eq (local.get $byte) (local.get $char))
        (then
          (local.set $count (i32.add (local.get $count) (i32.const 1)))
        )
      )
      (local.set $ptr (i32.add (local.get $ptr) (i32.const 1)))
      (br_if $count_loop (i32.ne (local.get $byte) (i32.const 10)))
    )
    (i32.and (i32.le_u (local.get $count) (local.get $max)) (i32.ge_u (local.get $count) (local.get $min)))
    (local.get $ptr)
  )

  (func $read_all (result i32)
    (local $len i32)

    (loop $read
      (i32.store (i32.const 0) (i32.add (i32.const 8) (local.get $len)))
      (i32.store (i32.const 4) (i32.const 1024))
      (call $fd_read (i32.const 0) (i32.const 0) (i32.const 1) (i32.const 4))
      (drop)
      (local.set $len (i32.add (local.get $len) (i32.load (i32.const 4))))
      (br_if $read (i32.eq (i32.const 1024) (i32.load (i32.const 4))))
    )

    (local.get $len)
  )

  (func (export "_start")
    (local $ptr i32)
    (local $count i32)
    (local $len i32)

    (local.set $len (call $read_all))

    (local.set $ptr (i32.const 8))

    (loop $loop
      (call $read_policy (local.get $ptr))
      (call $check_password)
      (local.set $ptr)

      (if
        (then
          (local.set $count (i32.add (local.get $count) (i32.const 1)))
        )
      )

      (br_if $loop (i32.lt_u (local.get $ptr) (local.get $len)))
    )

    (call $print_u32 (local.get $count))
  )
)
