open OUnit

let suite =
  "async_suite" >:::
    [
    ]

let () =
  print_endline "-------- Async tests --------";
  Test_common.run suite
