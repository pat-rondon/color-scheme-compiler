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
    F.eprintf "set_backend: bad name '%s'\n" name;
    exit 1

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

let parse f =
  let lexbuf = Lexing.from_channel (open_in f) in
  try
    Parser.color_scheme Lexer.token lexbuf
  with Parsing.Parse_error ->
    F.eprintf "Parser: error on line %d, col %d\n"
      lexbuf.Lexing.lex_curr_p.Lexing.pos_lnum
     (lexbuf.Lexing.lex_curr_p.Lexing.pos_cnum -
      lexbuf.Lexing.lex_curr_p.Lexing.pos_bol);
    exit 1

let (|>) x f = f x

let main () =
  Arg.parse arg_spec (fun f -> filename := f) usage;
  let module BE = (val !backend : Backend.M) in
  let ppf =
    if !ostdout then
      F.std_formatter
    else
      !filename
        |> BE.out_name
        |> open_out
        |> F.formatter_of_out_channel
  in
  try
    !filename
      |> parse
      |> BE.print ppf
  with Sys_error ": No such file or directory" ->
    Arg.usage arg_spec usage

let _ =
  main ()

