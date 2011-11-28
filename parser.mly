%token LEFT_CURLY RIGHT_CURLY
%token LEFT_PAREN RIGHT_PAREN
%token COMMA
%token COLON SEMICOLON
%token PROJECT
%token RGB
%token <string> Id
%token <int> Number
%token <string> String
%token EOF

%start color_scheme

%type <ColorScheme.t> color_scheme

%%
color_scheme:
    face_defs          { { ColorScheme.name = ""; ColorScheme.faces = $1} }
;

face_defs:
                       { ColorScheme.StringMap.empty }
  | face_defs face_def { ColorScheme.StringMap.add (fst $2) (snd $2) $1 }
;

face_def:
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
    rgb_color { $1 }
  | String    { ColorScheme.String $1 }
;

rgb_color:
  RGB LEFT_PAREN Number COMMA Number COMMA Number RIGHT_PAREN {
    ColorScheme.Color ($3, $5, $7)
  }
;
