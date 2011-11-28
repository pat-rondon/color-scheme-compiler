{
  open Parser

  let int_of_hex_string s =
    int_of_string ("0x" ^ s)
}

let alpha = ['A'-'Z' 'a'-'z' '_' '-']
let digit = ['0'-'9']

let hexdigit = ['0'-'9' 'a'-'f' 'A'-'F']

let hexdouble = hexdigit hexdigit

rule token = parse
  | ['\r''\t'' ']          { token lexbuf}
  | '\n'                   { Lexing.new_line lexbuf;
                             token lexbuf
			   }
  | "//"[^'\n']*'\n'       { Lexing.new_line lexbuf;
                             token lexbuf
                           }
  | "{"                    { LEFT_CURLY }
  | "}"                    { RIGHT_CURLY }
  | "("                    { LEFT_PAREN }
  | ")"                    { RIGHT_PAREN }
  | ":"                    { COLON }
  | ";"                    { SEMICOLON }
  | ","                    { COMMA }
  | "->"                   { PROJECT }
  | "rgb"                  { RGB }
  | "#" (hexdouble as r) (hexdouble as g) (hexdouble as b) {
    HexColor (int_of_hex_string r, int_of_hex_string g, int_of_hex_string b)
  }
  | alpha(alpha|digit)*    { Id (Lexing.lexeme lexbuf) }
  | digit+                 { Number (int_of_string (Lexing.lexeme lexbuf)) }
  | '"' ([^'"']* as s) '"' { String s }
  | eof	                   { EOF }
  | _                      { let _ = Format.printf "Illegal keyword: %s@.@." (Lexing.lexeme lexbuf) in
                             let _ = assert false in
                               token lexbuf
                           }
