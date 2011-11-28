module M  = Map
module F  = Format
module CS = ColorScheme
module SM = CS.StringMap

let attr_str = function
  | CS.Color (r, g, b) -> F.sprintf "#%X%X%X" r g b
  | CS.String s        -> F.sprintf "%s" s

let fg attrs =
  try
    "guifg=" ^ attr_str (SM.find "color" attrs)
  with Not_found -> ""

let bg attrs =
  try
    "guibg=" ^ attr_str (SM.find "background" attrs)
  with Not_found -> ""

let attrs_bind k v attrs =
  try
    SM.find k attrs = CS.String v
  with Not_found -> false

let gui attrs =
  let props = ref [] in
  if attrs_bind "text-decoration" "undercurl" attrs then begin
    props := "undercurl" :: !props
  end;
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

let print_color_scheme cs ppf =
  SM.iter begin fun face attrs ->
    F.fprintf ppf "hi %-12s %-12s %-12s %-12s@."
      face (fg attrs) (bg attrs) (gui attrs);
  end cs

let print_prelude body_opt name ppf =
  F.fprintf ppf "%s" (String.concat "\n"
    [ "set background=TODO"
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
        F.fprintf ppf "hi %-12s %-12s %-12s %-12s@."
          "Normal" (fg attrs) (bg attrs) (gui attrs);
    | None -> ()

let print cs ppf =
  let body_opt, cs = CS.extract_face cs "body" in
  print_prelude body_opt "test" ppf;
  print_color_scheme cs ppf

