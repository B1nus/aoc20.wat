;; This sample shows how to read a file using WASM/WASI.
;;
;; Reading a file requires sandbox permissions in WASM. By default, WASM
;; module cannot access the file system, and they require special permissions
;; to be granted from the host. The majority of this code deals with obtaining
;; the "pre-set" directory the host mapped for us, so we can open the file
;; and read it.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
  (import "wasi_snapshot_preview1" "fd_read" (func $fd_read (param i32 i32 i32 i32) (result i32)))
  (import "wasi_snapshot_preview1" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))
  (import "wasi_snapshot_preview1" "path_open" (func $path_open (param i32 i32 i32 i32 i32 i64 i64 i32 i32) (result i32)))

  (memory (export "memory") 1)

  (func $main (export "_start")
    (local $bytes_read i32)
    (local.set $bytes_read
      (call $read
        (global.get $filename_pos)
        (global.get $filename_len)
        (global.get $input_buffer_pos)))
    (call $println
      (global.get $input_buffer_pos)
      (local.get $bytes_read))
  )

  ;; Print and add a newline if it is missing
  (func $println (param $pos i32) (param $len i32)
    (local $last_8 i32)

    (call $print
      (local.get $pos)
      (local.get $len))
    
    (local.set $last_8 (i32.load8_u (i32.sub (i32.add (local.get $pos) (local.get $len)) (i32.const 1))))
    (if (i32.ne 
        (local.get $last_8)
        (i32.const 10)
      )
      (then
        (local.set $pos (i32.add (global.get $print_iov_pos) (i32.const 12)))
        (i32.store8 (local.get $pos) (i32.const 10))
        (call $print
          (local.get $pos)
          (i32.const 1))
      )
    )
  )

  (func $print_num_ln (param $num i32)
    ;; TODO
  )

  ;; A helper function to avoid the work of declaring iovs
  (func $print (param $pos i32) (param $len i32)
    ;; The start pos and length for the string to print.
    (i32.store (global.get $print_iov_pos) (local.get $pos))
    (i32.store (i32.add (global.get $print_iov_pos) (i32.const 4)) (local.get $len))

    ;; Printing
    (call $fd_write
      (i32.const 1) ;; fd = 1 (stdout)
      (global.get $print_iov_pos)
      (i32.const 1)
      (i32.add (global.get $print_iov_pos) (i32.const 8))
    )
    drop
  )

  (func $print_num (param $num i32)
    ;; TODO
  )

  ;; Put the number into memory as a string. The return value is the length of the string.
  (func $num_string (param $num i32) (param $pos i32) (result i32)
    ;; TODO
    i32.const 0
  )

    ;; println_number prints a number as a string to stdout, adding a newline.
    ;; It takes the number as parameter.
    (; (func $println_number (param $num i32) ;)
    (;     (local $numtmp i32) ;)
    (;     (local $numlen i32) ;)
    (;     (local $writeidx i32) ;)
    (;     (local $digit i32) ;)
    (;     (local $dchar i32) ;)
    (;;)
    (;     ;; Count the number of characters in the output, save it in $numlen. ;)
    (;     (i32.lt_s (local.get $num) (i32.const 10)) ;)
    (;     if ;)
    (;         (local.set $numlen (i32.const 1)) ;)
    (;     else ;)
    (;         (local.set $numlen (i32.const 0)) ;)
    (;         (local.set $numtmp (local.get $num)) ;)
    (;         (loop $countloop (block $breakcountloop ;)
    (;             (i32.eqz (local.get $numtmp)) ;)
    (;             br_if $breakcountloop ;)
    (;;)
    (;             (local.set $numtmp (i32.div_u (local.get $numtmp) (i32.const 10))) ;)
    (;             (local.set $numlen (i32.add (local.get $numlen) (i32.const 1))) ;)
    (;             br $countloop ;)
    (;         )) ;)
    (;     end ;)
    (;;)
    (;     ;; Now that we know the length of the output, we will start populating ;)
    (;     ;; digits into the buffer. E.g. suppose $numlen is 4: ;)
    (;     ;; ;)
    (;     ;;                     _  _  _  _ ;)
    (;     ;; ;)
    (;     ;;                     ^        ^ ;)
    (;     ;;  $itoa_out_buf -----|        |---- $writeidx ;)
    (;     ;; ;)
    (;     ;; ;)
    (;     ;; $writeidx starts by pointing to $itoa_out_buf+3 and decrements until ;)
    (;     ;; all the digits are populated. ;)
    (;     (local.set $writeidx ;)
    (;         (i32.sub ;)
    (;             (i32.add (global.get $itoa_out_buf) (local.get $numlen)) ;)
    (;             (i32.const 1))) ;)
    (;;)
    (;     (loop $writeloop ;)
    (;         ;; digit <- $num % 10 ;)
    (;         (local.set $digit (i32.rem_u (local.get $num) (i32.const 10))) ;)
    (;         ;; set the char value from the lookup table of digit chars ;)
    (;         (local.set $dchar (i32.load8_u offset=8000 (local.get $digit))) ;)
    (;;)
    (;         ;; mem[writeidx] <- dchar ;)
    (;         (i32.store8 (local.get $writeidx) (local.get $dchar)) ;)
    (;;)
    (;         ;; num <- num / 10 ;)
    (;         (local.set $num (i32.div_u (local.get $num) (i32.const 10))) ;)
    (;;)
    (;         ;; If after writing a number we see we wrote to the first index in ;)
    (;         ;; the output buffer, we're done. ;)
    (;         (i32.ne (local.get $writeidx) (global.get $itoa_out_buf)) ;)
    (;         br_if $writeloop ;)
    (;       ) ;)
    (;;)
    (;     (call $println ;)
    (;         (global.get $itoa_out_buf) ;)
    (;         (local.get $numlen)) ;)
    (; ) ;)

  ;; Read the file with the name starting at $name_pos with length $name_len. Dump the files text into memory at $dump_pos. The return value is the length of the text. This function does not handle any errors.
  (func $read (param $name_pos i32) (param $name_len i32) (param $dump_pos i32) (result i32)
    ;; The I/O vector for the fd_read output
    (local $iov i32)
    (local $bytes_read i32)
    (local.set $iov (i32.add (global.get $input_buffer_len) (local.get $dump_pos)))

    ;; Store the I/O vector
    (i32.store (local.get $iov) (local.get $dump_pos))
    (i32.store (i32.add (local.get $iov) (i32.const 4)) (global.get $input_buffer_len))

    ;; The position to store the amount of bytes read in memory. This puts it right after the I/O vector.
    (local.set $bytes_read (i32.add (local.get $iov) (i32.const 8)))

      (call $path_open
        (i32.const 3) ;; fd=3 base dir
        (i32.const 1) ;; symlink_follow = 1
        (local.get $name_pos)
        (local.get $name_len)
        (i32.const 0) ;; oflags = 0
        (i64.const 3) ;; fd_rights_base
        (i64.const 3) ;; fd_rights_inheriting
        (i32.const 0) ;; fdflags = 0
        (local.get $dump_pos)) ;; The fd for the fd_read we'll use later

      (call $fd_read
        (i32.load (local.get $dump_pos)) ;; fd ("File Descriptor")
        (local.get $iov)
        (i32.const 1)
        (local.get $bytes_read))

    (return (i32.load (local.get $bytes_read)))
  )

  ;; These slots are used as parameters for fd_write, and its return value.
  (global $datavec_addr i32 (i32.const 7900))
  (global $datavec_len i32 (i32.const 7904))
  (global $fdwrite_ret i32 (i32.const 7908))

  ;; Using some memory for a number-->digit ASCII lookup-table, and then the
  ;; space for writing the result of $itoa.
  (data (i32.const 8000) "0123456789")
  (data (i32.const 8010) "\n")
  (global $itoa_out_buf i32 (i32.const 8020))

  ;; Reading input file
  (global $filename_pos i32 (i32.const 0))
  (global $filename_len i32 (i32.const 5))
  (data (i32.const 0) "1.txt")
  (global $input_buffer_pos i32 (i32.const 16384))
  (global $input_buffer_len i32 (i32.const 16384))
  (global $print_iov_pos i32 (i32.const 32768))
)
