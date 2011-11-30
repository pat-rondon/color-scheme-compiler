%{

 module CS = ColorScheme
 module SM = CS.StringMap

 type def_kind =
   | Face
   | Definition

 let defs = ref SM.empty

 let add_def name face = defs := SM.add name face !defs

 let find_def face attr =
   try
     SM.find attr (SM.find face !defs)
   with Not_found ->
     let _ = Format.printf "Cannot find attribute %s.%s@." face attr in
       assert false

 (* ztatlock: make all these hex_color *)
 (* ztatlock: add all X86 colors *)
 let colors =
   [ "black",       CS.hex_color "#000000"
   ; "white",       CS.hex_color "#FFFFFF"
   ; "red",         CS.Color (178, 34, 34)
   ; "green",       CS.Color (46, 139, 87)
   ; "blue",        CS.hex_color "#325F9F"
   ; "yellow",      CS.Color (255, 236, 139)
   ; "purple",      CS.hex_color "#72275A"
   ; "orange",      CS.Color (255, 127, 0)
   ; "teal",        CS.hex_color "#308876"
   ; "dark-gray",   CS.hex_color "#4A4A4A"
   ; "medium-gray", CS.hex_color "#858585"
   ; "light-gray",  CS.Color (235, 235, 235)
   ; "light-blue",  CS.hex_color "#4189A4"
   ; "faint-blue",  CS.hex_color "#DFE8F1"
   ; "steel-blue",  CS.hex_color "#606B85"
   ]

%}

%token LEFT_CURLY RIGHT_CURLY
%token LEFT_PAREN RIGHT_PAREN
%token COMMA
%token COLON SEMICOLON
%token PROJECT
%token RGB
%token DEFINITION
%token <string> HexColor
%token <string> Id
%token <int> Number
%token <string> String
%token EOF

%start color_scheme

%type <ColorScheme.t> color_scheme

%%

color_scheme:
    defs { { CS.name = ""; CS.faces = $1} }
;

defs:
             { SM.empty }
  | defs def {
    let kind, name, attrs = $2 in
      match kind with
        | Definition -> add_def name attrs; $1
        | Face       -> SM.add name attrs $1
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
                                   { SM.empty }
  | face_attributes face_attribute { SM.add (fst $2) (snd $2) $1 }
;

face_attribute:
    Id COLON attribute_value SEMICOLON { ($1, $3) }
;

attribute_value:
  | RGB LEFT_PAREN Number COMMA Number COMMA Number RIGHT_PAREN {
      CS.Color ($3, $5, $7)
    }
  | Id {
      try CS.Color (List.assoc $1 NamedColors.colors)
      with Not_found -> CS.String $1
    }
  | HexColor      { CS.hex_color $1 }
  | String        { CS.String $1 }
  | Id PROJECT Id { find_def $1 $3 }
;
