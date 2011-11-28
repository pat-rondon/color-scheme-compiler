module F  = Format
module CS = ColorScheme

let m =
  { CS.name  = "charybdis"
  ; CS.faces =  CS.of_list [("keyword", CS.of_list [("color", CS.Color (0, 182, 255))]);
                            ("comment", CS.of_list [("color", CS.Color (100, 100, 100))]);
                            ("body", CS.of_list [("background", CS.String "LightGoldenrod1");
                                                 ("color", CS.Color (0, 0, 255))])
                           ]
  }

(* options *)
let backend  = ref BEmacs.print
let filename = ref ""

let backends =
  [ "emacs", BEmacs.print
  ; "vim"  , BVim.print
  ; "css"  , BCSS.print
  ]

let backend_names =
  List.map fst backends

let set_backend name =
  try
    backend := List.assoc name backends
  with Not_found ->
    failwith ("set_backend: bad name '" ^ name ^ "'")

let arg_spec = Arg.align
  [ "-backend", Arg.Symbol (backend_names, set_backend)
              , " Set backend for generating color scheme"
  ]

let usage = String.concat "\n"
  [ "USAGE: csc [options] spec.css"
  ; ""
  ; "Compile spec.css to color scheme for desired target."
  ; ""
  ; "Options:"
  ]

let (|>) x f = f x

let main () =
  Arg.parse arg_spec (fun f -> filename := f) usage;
  try
    !filename
      |> open_in
      |> Lexing.from_channel
      |> Parser.color_scheme Lexer.token
      |> !backend Format.std_formatter
  with Sys_error ": No such file or directory" ->
    Arg.usage arg_spec usage

let _ =
  main ()

