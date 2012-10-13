module F  = Format
module FN = Filename
module CS = ColorScheme

open Util.Operators

(* options *)
let backend     = ref (module BEmacs: Backend.M)
let filename    = ref "-"
let outfilename = ref None

let backends = [
    ("emacs", (module BEmacs: Backend.M))
  ; ("vim",   (module BVim: Backend.M))
  ; ("css",   (module BCSS: Backend.M))
]

let backend_spec =
  List.map begin fun (name, m) ->
    ("-" ^ name, Arg.Unit (fun _ -> backend := m), " Use " ^ name ^ " backend")
  end backends

let arg_spec = Arg.align begin
  backend_spec @
  [ "-o" , Arg.String (fun s -> outfilename := Some s), " Set output file name"
  ]
end

let usage = String.concat "\n"
  [ "USAGE: csc [options] [spec.css]"
  ; ""
  ; "Compile spec.css to color scheme for desired target."
  ; "If no spec is provided, read from standard input."
  ; ""
  ; "Options:"
  ]

let parse f =
  let ic =
    match f with
    | "-" -> stdin
    | _   -> open_in f
  in
  let lexbuf = Lexing.from_channel ic in
  try
    Parser.color_scheme Lexer.token lexbuf
  with Parsing.Parse_error ->
    F.eprintf "Parser: error on line %d, col %d@."
      lexbuf.Lexing.lex_curr_p.Lexing.pos_lnum
     (lexbuf.Lexing.lex_curr_p.Lexing.pos_cnum -
      lexbuf.Lexing.lex_curr_p.Lexing.pos_bol);
    exit 1

let main () =
  Arg.parse arg_spec (fun f -> filename := f) usage;
  let module BE = (val !backend : Backend.M) in
  let themename = FN.chop_suffix !filename ".css" in
  let ppf =
    match !outfilename with
      | Some "-" ->
        F.std_formatter
      | Some f ->
           f
        |> open_out
        |> F.formatter_of_out_channel
      | None ->
           themename
        |> BE.out_name
        |> open_out
        |> F.formatter_of_out_channel
  in
  !filename
    |> parse
    |> (fun cs -> {cs with CS.name = themename})
    |> BE.print ppf

let _ =
  main ()
