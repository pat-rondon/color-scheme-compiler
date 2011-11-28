module M  = Map
module F  = Format
module FN = Filename
module CS = ColorScheme
module SM = CS.StringMap

(* translation to vim faces  *)
(* see help syntax for names *)
let face_map =
  [ "comment",      "Comment"
  ; "constant",     "Constant"
  ; "bool",         "Boolean"
  ; "char",         "Character"
  ; "string",       "String"
  ; "int",          "Number"
  ; "float",        "Float"
  ; "variable",     "Identifier"
  ; "function",     "Function"
  ; "statement",    "Statement"
  ; "branch",       "Conditional"
  ; "loop",         "Repeat"
  ; "case",         "Label"
  ; "builtin",      "Operator"
  ; "keyword",      "Keyword"
  ; "exception",    "Exception"
  ; "preprocessor", "PreProc"
  ; "type",         "Type"
  ; "struct",       "Structure"
  ; "error",        "Error"
  ; "todo",         "Todo"
  ; "warning",      "WarningMsg"
  ; "selection",    "Visual"
  ; "paren-match",  "MatchParen"
  ]

let attr_str = function
  | CS.Color (r, g, b) -> F.sprintf "#%02X%02X%02X" r g b
  | CS.String s        -> F.sprintf "%s" s

let fg attrs =
  try "guifg=" ^ attr_str (SM.find "color" attrs)
  with Not_found -> ""

let bg attrs =
  try "guibg=" ^ attr_str (SM.find "background" attrs)
  with Not_found -> ""

let attrs_bind k v attrs =
  try SM.find k attrs = CS.String v
  with Not_found -> false

let gui attrs =
  let props = ref [] in
  if attrs_bind "text-decoration" "underline" attrs then begin
    props := "underline" :: !props
  end;
  if attrs_bind "font-style" "italic" attrs then begin
    props := "italic" :: !props
  end;
  if attrs_bind "font-weight" "bold" attrs then begin
    props := "bold" :: !props
  end;
  if !props = [] then
    ""
  else
    "gui=" ^ (String.concat "," !props)

let print_faces faces ppf =
  SM.iter begin fun face attrs ->
    try
      F.fprintf ppf "hi %-15s %-15s %-15s %s@."
        (List.assoc face face_map) (fg attrs) (bg attrs) (gui attrs);
    with Not_found -> ()
  end faces

let bg_summary body_opt =
  match body_opt with
    | Some attrs ->
      begin try match SM.find "background" attrs with
        | CS.Color (r, g, b) ->
          (* ztatlock: determine better test *)
          if (r + g + b) / 3 > 256 / 2 then
            "set background=light"
          else
            "set background=dark"
        | _ -> ""
      with Not_found -> "" end
    | None -> ""

let print_prelude body_opt name ppf =
  F.fprintf ppf "%s" (String.concat "\n"
    [ bg_summary body_opt
    ; "hi clear"
    ; "if exists(\"syntax_on\")"
    ; "  syntax reset"
    ; "endif"
    ; "let g:colors_name = \"" ^ name ^ "\""
    ; ""
    ; ""
    ]);
  match body_opt with
    | Some attrs ->
      F.fprintf ppf "hi %-15s %-15s %-15s %s@."
        "Normal" (fg attrs) (bg attrs) (gui attrs);
    | None -> ()

let print ppf {CS.name = name; CS.faces = faces} =
  let body_opt, faces = CS.extract_face faces "body" in
  print_prelude body_opt name ppf;
  print_faces faces ppf

let out_name f =
  (FN.chop_suffix f ".css") ^ ".vim"

