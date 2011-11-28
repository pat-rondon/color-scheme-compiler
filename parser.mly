%{

 module CS = ColorScheme

 type def_kind =
   | Face
   | Definition

 let defs = ref CS.StringMap.empty

 let add_def name face = defs := CS.StringMap.add name face !defs

 let find_def face attr =
   try
     CS.StringMap.find attr (CS.StringMap.find face !defs)
   with Not_found ->
     let _ = Format.printf "Cannot find attribute %s.%s@." face attr in
       assert false

%}

%token LEFT_CURLY RIGHT_CURLY
%token LEFT_PAREN RIGHT_PAREN
%token COMMA
%token COLON SEMICOLON
%token PROJECT
%token RGB
%token DEFINITION
%token <(int * int * int)> HexColor
%token <string> Id
%token <int> Number
%token <string> String
%token EOF

%start color_scheme

%type <ColorScheme.t> color_scheme

%%
color_scheme:
    defs { { ColorScheme.name = ""; ColorScheme.faces = $1} }
;

defs:
             { ColorScheme.StringMap.empty }
  | defs def {
    let kind, name, attrs = $2 in
      match kind with
        | Definition -> add_def name attrs; $1
        | Face       -> ColorScheme.StringMap.add name attrs $1
  }
;

def:
    def_aux            { (Face, fst $1, snd $1) }
  | DEFINITION def_aux { (Definition, fst $2, snd $2) }
;

def_aux:
  Id LEFT_CURLY face_attributes RIGHT_CURLY { ($1, $3) }
;

face_attributes:
                                   { ColorScheme.StringMap.empty }
  | face_attributes face_attribute { ColorScheme.StringMap.add (fst $2) (snd $2) $1 }
;

face_attribute:
    Id COLON attribute_value SEMICOLON { ($1, $3) }
;

attribute_value:
    RGB LEFT_PAREN Number COMMA Number COMMA Number RIGHT_PAREN {
      ColorScheme.Color ($3, $5, $7)
    }
  | HexColor      { let r, g, b = $1 in ColorScheme.Color (r, g, b) }
  | String        { ColorScheme.String $1 }
  | Id PROJECT Id { find_def $1 $3 }
;
