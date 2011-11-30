{
  open Parser
}

let digit     = ['0'-'9']
let alpha     = ['a'-'z' 'A'-'Z' '_' '-']
let hexdigit  = ['0'-'9' 'a'-'f' 'A'-'F']
let hex_color = "#" hexdigit hexdigit hexdigit hexdigit hexdigit hexdigit

rule token = parse
  (* ignore whitespace and comments *)
  | ['\r' '\t' ' '] { token lexbuf }
  | "//"[^'\n']*    { token lexbuf }

  (* count newlines *)
  | '\n' { Lexing.new_line lexbuf; token lexbuf }

  (* useful tokens *)
  | "{"                    { LEFT_CURLY }
  | "}"                    { RIGHT_CURLY }
  | "("                    { LEFT_PAREN }
  | ")"                    { RIGHT_PAREN }
  | ":"                    { COLON }
  | ";"                    { SEMICOLON }
  | ","                    { COMMA }
  | "."                    { PROJECT }
  | "rgb"                  { RGB }
  | "def"                  { DEFINITION }
  | hex_color              { HexColor (Lexing.lexeme lexbuf) }
  | alpha(alpha|digit)*    { Id (Lexing.lexeme lexbuf) }
  | digit+                 { Number (int_of_string (Lexing.lexeme lexbuf)) }
  | '"' ([^'"']* as s) '"' { String s }
  | eof	                   { EOF }

  (* error *)
  | _ {
    Printf.eprintf "Lexer: bad input '%s' on line %d.\n"
      (Lexing.lexeme lexbuf)
      lexbuf.Lexing.lex_curr_p.Lexing.pos_lnum;
    assert false
  }
