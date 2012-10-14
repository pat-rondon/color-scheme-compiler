%{

 module CS = ColorScheme
 module SM = Util.StringMap

 type def_kind =
   | Face
   | Definition

 let defs = ref SM.empty

 let add_def face name =
   defs := SM.add name face !defs

 let find_def face attr =
   try SM.find attr (SM.find face !defs)
   with Not_found -> begin
     Format.eprintf "Cannot find attribute %s.%s@." face attr;
     assert false
   end

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
    let kind, names, attrs = $2 in
      match kind with
        | Definition -> List.iter (add_def attrs) names; $1
        | Face       -> List.fold_left (fun dm n -> SM.add n attrs dm) $1 names
  }
;

def:
    def_aux            { (Face, fst $1, snd $1) }
  | DEFINITION def_aux { (Definition, fst $2, snd $2) }
;

def_aux:
  ids LEFT_CURLY face_attributes RIGHT_CURLY { ($1, $3) }
;

ids:
    Id           { [$1] }
  | Id COMMA ids { $1 :: $3 }
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
      try CS.hex_color (List.assoc $1 NamedColors.colors)
      with Not_found -> CS.String $1
    }
  | HexColor      { CS.hex_color $1 }
  | String        { CS.String $1 }
  | Id PROJECT Id { find_def $1 $3 }
;
