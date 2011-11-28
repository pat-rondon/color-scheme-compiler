{
  open Parser
}

let alpha = ['A'-'Z' 'a'-'z' '_' ]
let digit = ['0'-'9']

rule token = parse
  | ['\r''\t'' ']       { token lexbuf}
  | '\n'                { begin
                            Lexing.new_line lexbuf;
                            token lexbuf
			  end }
  | "//"[^'\n']*'\n'    { begin
                            Lexing.new_line lexbuf;
			    token lexbuf
                          end }
  | "{"                 { LEFT_CURLY }
  | "}"                 { RIGHT_CURLY }
  | "("                 { LEFT_PAREN }
  | ")"                 { RIGHT_PAREN }
  | ":"                 { COLON }
  | ";"                 { SEMICOLON }
  | ","                 { COMMA }
  | "->"                { PROJECT }
  | "rgb"               { RGB }
  | alpha(alpha|digit)*  { Id (Lexing.lexeme lexbuf) }
  | digit+               { Number (int_of_string (Lexing.lexeme lexbuf)) }
  | '"' ([^'"']* as s) '"' { String s }
  | eof	                { EOF }
  | _                   { begin
                            (* lexerror ("Illegal Character '" ^  *)
                            (*           (Lexing.lexeme lexbuf) ^ "'") lexbuf; *)
    let _ = assert false in
                            token lexbuf
                          end }
