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
let backend  = ref (module BEmacs: Backend.M)
let filename = ref ""
let ostdout  = ref false

let backends =
  [ "emacs", (module BEmacs: Backend.M)
  ; "vim"  , (module BVim: Backend.M)
  ; "css"  , (module BCSS: Backend.M)
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
  ; "-stdout" , Arg.Set ostdout
              , " Send output to stdout"
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
  let module BE = (val !backend : Backend.M) in
  let ppf =
    if !ostdout then
      Format.std_formatter
    else
      !filename
        |> BE.out_name
        |> open_out
        |> Format.formatter_of_out_channel
  in
  try
    !filename
      |> open_in
      |> Lexing.from_channel
      |> Parser.color_scheme Lexer.token
      |> BE.print ppf
  with Sys_error ": No such file or directory" ->
    Arg.usage arg_spec usage

let _ =
  main ()

