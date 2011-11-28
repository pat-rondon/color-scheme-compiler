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

let arg_spec = [
]

let usage = "USAGE"

let filename = ref "-"

type backend = { print: ColorScheme.t -> F.formatter -> unit }

let be = ref { print = BEmacs.print }

let main () =
  let _   = Arg.parse arg_spec (fun f -> filename := f) usage in
  let f   = open_in !filename in
  let lex = Lexing.from_channel f in
  let cs  = Parser.color_scheme Lexer.token lex in
  let _   = !be.print cs Format.std_formatter in
    ()

let _ = main ()
