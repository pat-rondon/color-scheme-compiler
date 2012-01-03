(* TODO:
   - Neutral faces get translated (variable -> font-lock-variable-name-face)
   - Emacs-understandable names get whitelisted (org-level-1 ok,
     pat-vim-highlhigt not ok)
*)

module M  = Map
module CS = ColorScheme
module SM = CS.StringMap
module F  = Format

(* pmr: factor this out *)
let (|>) x f = f x

(* pmr: factor this out *)
let find_local_name name_map name =
  try List.assoc name name_map with Not_found -> name

(* pmr: factor this out *)
let print_map key_map pr ppf m =
  SM.iter begin fun k v ->
    pr ppf (find_local_name key_map k) v
  end m

(******************************************************************************)
(********************** Color scheme names to Emacs names *********************)
(******************************************************************************)

let face_map =
  [ ("body",         "default")
  ; ("prompt",       "minibuffer-prompt")
  ; ("selection",    "region")
  ; ("keyword",      "font-lock-keyword-face")
  ; ("comment",      "font-lock-comment-face")
  ; ("builtin",      "font-lock-builtin-face")
  ; ("variable",     "font-lock-variable-name-face")
  ; ("function",     "font-lock-function-name-face")
  ; ("type",         "font-lock-type-face")
  ; ("string",       "font-lock-string-face")
  ; ("preprocessor", "font-lock-preprocessor-face")
  ; ("warning",      "font-lock-warning-face")
  ; ("paren-match",  "show-paren-match")
  ; ("paren-mismatch", "show-paren-mismatch")
  ]

let face_whitelist =
  [ "mode-line"
  ; "mode-line-inactive"
  ; "tuareg-font-lock-governing-face"
  ; "tuareg-font-lock-operator-face"
  ; "cursor"
  ; "match"
  ; "compilation-info"
  ; "compilation-error"
  ]

let attribute_map =
  [ ("color",       "foreground")
  ; ("font-weight", "weight")
  ]

let unquoted_attributes =
  [ "weight"
  ]

(******************************************************************************)
(**************************** Color scheme printers ***************************)
(******************************************************************************)

let print_attribute attr ppf = function
  | CS.Color (r, g, b) -> F.fprintf ppf "\"#%02x%02x%02x\"" r g b (* pmr: factor out hex color printing *)
  | CS.String s        ->
    if List.mem attr unquoted_attributes then
      F.fprintf ppf "%s" s
    else F.fprintf ppf "\"%s\"" s

let print_face_attributes =
  print_map
    attribute_map
    (fun ppf k v -> F.fprintf ppf ":%s %a@;" k (print_attribute k) v)

let print_faces =
  print_map
    face_map
    begin fun ppf k v ->
      F.fprintf ppf "'(%s ((t (@[%a@]))))@\n" k print_face_attributes v
    end

let filter_faces =
  SM.filter (fun f _ -> List.mem_assoc f face_map || List.mem f face_whitelist)

let print ppf {CS.name = name; CS.faces = faces} =
  F.fprintf ppf "(deftheme %s \"\")@." name;
  F.fprintf ppf "(custom-theme-set-faces@.";
  F.fprintf ppf "  '%s@." name;
  F.fprintf ppf "  @[%a@]@." print_faces (filter_faces faces);
  F.fprintf ppf "  )@.";
  F.fprintf ppf "(provide-theme '%s)@." name

let out_name f =
  f ^ "-theme.el"
