(module
  (import "wasi_snapshot_preview1" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))

  (memory (export "memory") 1)
  (data (i32.const 0) "1749\n1897\n881\n1736\n1161\n1720\n1676\n305\n264\n1904\n1880\n1173\n483\n1978\n1428\n1635\n1386\n1858\n1602\n1916\n1906\n1212\n1730\n1777\n1698\n1845\n1812\n1922\n1729\n1803\n1761\n1901\n1748\n1188\n1964\n1935\n1919\n1810\n1567\n1849\n1417\n1452\n54\n1722\n1784\n1261\n1744\n1594\n1526\n1771\n1762\n1894\n1717\n1716\n51\n1955\n1143\n1741\n1999\n1775\n1944\n1983\n1962\n1198\n1553\n1835\n1867\n1662\n1461\n1811\n1764\n1726\n1927\n1179\n1468\n1948\n1813\n1213\n1905\n1371\n1751\n1215\n1392\n1798\n1823\n1815\n1923\n1942\n1987\n1887\n1838\n1395\n2007\n1479\n1752\n1945\n1621\n1538\n1937\n565\n1969\n1493\n1291\n1438\n1578\n1770\n2005\n1703\n1712\n1943\n2003\n1499\n1903\n1760\n1950\n1990\n1185\n1809\n1337\n1358\n1743\n1707\n1671\n1788\n1785\n1972\n1863\n1690\n1512\n1963\n1825\n1460\n1828\n1902\n1874\n1755\n1951\n1830\n1767\n1787\n1373\n1709\n1514\n1807\n1791\n1724\n1859\n1590\n1976\n1572\n1947\n1913\n1995\n1728\n1624\n1731\n1706\n1782\n1994\n1851\n1843\n1773\n1982\n1685\n2001\n1346\n1200\n1746\n1520\n972\n1834\n1909\n2008\n1733\n1960\n1280\n1879\n1203\n1979\n1133\n1647\n1282\n1684\n860\n1444\n1780\n1989\n1795\n1819\n1797\n1842\n1796\n1457\n1839\n1853\n1711\n1883\n1146\n1734\n1389\n;")
  (data (i32.const 3000) " ")
  (global $list_ptr i32 (i32.const 4000))
  (global $print_iov_ptr i32 (i32.const 4500))

  (func $main (export "_start")
    (local $i i32)
    (local $j i32)
    (local $n i32)
    (local $i_int i32)
    (local $j_int i32)
    (local $n_int i32)
    (local $list_i i32)
    (local $string_ptr i32)
    (local $len i32)
    (local $out i32)
    (local.set $string_ptr (i32.const 0))
    (local.set $list_i (i32.const 0))
    (loop $fill_numbers
      (local.set $len (i32.const 0))
      (loop $find_len
        (local.set $len (i32.add (local.get $len) (i32.const 1)))
        (br_if $find_len (i32.ne (i32.load8_u (i32.add (local.get $string_ptr) (local.get $len))) (i32.const 10))))
      (i32.store (i32.add (global.get $list_ptr) (i32.mul (local.get $list_i) (i32.const 4))) (call $parse_number (local.get $string_ptr) (local.get $len)))
      (local.set $string_ptr (i32.add (local.get $string_ptr) (i32.add (local.get $len) (i32.const 1))))
      (call $print_number (i32.load (i32.add (i32.mul (local.get $list_i) (i32.const 4)) (global.get $list_ptr))))
      (call $print (i32.const 4) (i32.const 1))
      (local.set $list_i (i32.add (local.get $list_i) (i32.const 1)))
      (br_if $fill_numbers (i32.ne (i32.load8_u (local.get $string_ptr)) (i32.const 59))))
    (local.set $i (i32.const 0))
    (loop $outer
      (local.set $j (i32.add (local.get $i) (i32.const 1)))
      (loop $inner
        (local.set $n (i32.add (local.get $j) (i32.const 1)))
        (loop $innerinner
          (local.set $i_int (i32.load (i32.add (i32.mul (local.get $i) (i32.const 4)) (global.get $list_ptr))))
          (local.set $j_int (i32.load (i32.add (i32.mul (local.get $j) (i32.const 4)) (global.get $list_ptr))))
          (local.set $n_int (i32.load (i32.add (i32.mul (local.get $n) (i32.const 4)) (global.get $list_ptr))))
          (if (i32.eq (i32.add (local.get $n_int) (i32.add (local.get $i_int) (local.get $j_int))) (i32.const 2020)) (then 
            (call $print_number (local.get $i_int))
            (call $print (i32.const 3000) (i32.const 1))
            (call $print_number (local.get $j_int))
            (call $print (i32.const 3000) (i32.const 1))
            (call $print_number (local.get $n_int))
            (call $print (i32.const 4) (i32.const 1))
            (local.set $out (i32.mul (local.get $n_int) (i32.mul (local.get $i_int) (local.get $j_int))))
            (call $print (i32.const 4) (i32.const 1))
            )
          )
          (local.set $n (i32.add (local.get $n) (i32.const 1)))
          (br_if $innerinner (i32.lt_u (local.get $n) (local.get $list_i))))
        (local.set $j (i32.add (local.get $j) (i32.const 1)))
        (br_if $inner (i32.lt_u (i32.add (local.get $j) (i32.const 1)) (local.get $list_i))))
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br_if $outer (i32.lt_u (i32.add (local.get $i) (i32.const 2)) (local.get $list_i))))
    (call $print_number (local.get $out))
    (call $print (i32.const 4) (i32.const 1))
  )

  (func $parse_number (param $ptr i32) (param $len i32) (result i32)
    (local $i i32)
    (local $num i32)
    (local.set $num (i32.const 0))
    (loop $loop
      (local.set $num (i32.mul (local.get $num) (i32.const 10)))
      (local.set $num (i32.add (local.get $num) (i32.sub (i32.load8_u (i32.add (local.get $ptr) (local.get $i))) (i32.const 48))))
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br_if $loop (i32.lt_u (local.get $i) (local.get $len))))
    (return (local.get $num))
  )

  (func $print_number (param $num i32)
    (local $ptr i32)
    (local $i i32)
    (local.set $i (i32.const 0))
    (local.set $ptr (i32.const 5000))

    (loop $loop
      (i32.store8
        (i32.sub (local.get $ptr) (local.get $i))
        (i32.add (i32.rem_u (local.get $num) (i32.const 10)) (i32.const 48))) ;; add 48 which is the ascii value for '0'
      (local.set $num (i32.div_u (local.get $num) (i32.const 10)))
      (local.set $i (i32.add (local.get $i) (i32.const 1)))

      (br_if $loop (i32.gt_u (local.get $num) (i32.const 0))))
    (call $print
      (i32.add (i32.sub (local.get $ptr) (local.get $i)) (i32.const 1))
      (local.get $i))
  )

  (func $print (param $ptr i32) (param $len i32)
    ;; The start pos and length for the string to print.
    (i32.store (global.get $print_iov_ptr) (local.get $ptr))
    (i32.store (i32.add (global.get $print_iov_ptr) (i32.const 4)) (local.get $len))

    ;; Printing
    (call $fd_write
      (i32.const 1) ;; fd = 1 (stdout)
      (global.get $print_iov_ptr)
      (i32.const 1) ;; iovs_len 
      (i32.add (global.get $print_iov_ptr) (i32.const 8)) ;; return ptr https://github.com/WebAssembly/WASI/blob/main/legacy/tools/witx-docs.md
    )
    drop
  )
)
