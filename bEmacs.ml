(* TODO:
   - Whitelist face attributes
*)

module M  = Map
module CS = ColorScheme
module F  = Format

open Util.Operators

(******************************************************************************)
(********************** Color scheme names to Emacs names *********************)
(******************************************************************************)

let css_face_to_emacs_face =
  [ ("body",                      ["default"])
  ; ("prompt",                    ["minibuffer-prompt"])
  ; ("selection",                 ["region"])
  ; ("keyword",                   ["font-lock-keyword-face"])
  ; ("comment",                   ["font-lock-comment-face"])
  ; ("doc",                       ["font-lock-doc-face"])
  ; ("constant",                  ["font-lock-constant-face"])
  ; ("line-highlight",            ["hl-line"])
  ; ("builtin",                   ["font-lock-builtin-face"])
  ; ("variable",                  ["font-lock-variable-name-face"])
  ; ("function",                  ["font-lock-function-name-face"])
  ; ("type",                      ["font-lock-type-face"])
  ; ("string",                    ["font-lock-string-face"])
  ; ("preprocessor",              ["font-lock-preprocessor-face"])
  ; ("warning",                   ["font-lock-warning-face"])
  ; ("match",                     ["match"; "isearch"])
  ; ("more-matches",              ["lazy-highlight"])
  ; ("mismatch",                  ["isearch-fail"])
  ; ("paren-match",               ["show-paren-match"])
  ; ("paren-mismatch",            ["show-paren-mismatch"])
  ; ("tooltip",                   ["company-tooltip"])
  ; ("completion-selection",      ["company-tooltip-selection"])
  ; ("completion-common-portion", ["company-tooltip-common"])
  ]

let face_whitelist =
  [ "mode-line"
  ; "mode-line-inactive"
  ; "tuareg-font-lock-governing-face"
  ; "tuareg-font-lock-operator-face"
  ; "racket-keyword-argument-face"
  ; "racket-selfeval-face"
  ; "ido-first-match"
  ; "ido-only-match"
  ; "ido-subdir"
  ; "cursor"
  ; "compilation-info"
  ; "compilation-error"
  ; "highlight"
  ; "secondary-selection"
  ; "info-xref"
  ; "info-xref-visited"
  ; "magit-diff-add"
  ; "magit-diff-del"
  ; "org-level-1"
  ; "org-level-2"
  ; "org-todo"
  ; "org-done"
  ; "eshell-prompt"
  ; "eshell-ls-backup"
  ; "font-latex-math-face"
  ; "font-latex-string-face"
  ; "font-latex-sedate-face"
  ; "font-latex-bold-face"
  ; "font-latex-italic-face"
  ; "font-latex-sectioning-0-face"
  ; "font-latex-sectioning-1-face"
  ; "font-latex-sectioning-2-face"
  ; "font-latex-sectioning-3-face"
  ; "font-latex-sectioning-4-face"
  ; "font-latex-sectioning-5-face"
  ]

let css_attribute_to_emacs_attribute =
  [ ("color",       ["foreground"])
  ; ("font-weight", ["weight"])
  ]

let unquoted_attributes =
  [ "weight"
  ]

(******************************************************************************)
(**************************** Color scheme printers ***************************)
(******************************************************************************)

let print_attribute attr ppf = function
  | CS.Color (r, g, b) ->
    F.fprintf ppf "\"%s\"" (Util.Colors.rgb_to_hex_color_string (r, g, b))
  | CS.String s        ->
    if List.mem attr unquoted_attributes then
      F.fprintf ppf "%s" s
    else F.fprintf ppf "\"%s\"" s

let print_face_attributes =
  Util.print_map
    css_attribute_to_emacs_attribute
    (fun ppf k v -> F.fprintf ppf ":%s %a@;" k (print_attribute k) v)

let print_face_sexpr ppf (face, attributes) =
  F.fprintf ppf "(%s ((t (@[%a@]))))@." face print_face_attributes attributes

let print_faces ppf (prefix, faces) =
  Util.print_map
    css_face_to_emacs_face
    begin fun ppf face attributes ->
      F.fprintf ppf "%s%a" prefix print_face_sexpr (face, attributes)
    end
    ppf
    faces

(* Produces themes for the built-in theming engine present in Emacs 24
   and up *)
module Builtin = struct
  let filter_faces =
    Util.StringMap.filter begin fun f _ ->
      List.mem_assoc f css_face_to_emacs_face || List.mem f face_whitelist
    end

  let print ppf {CS.name = name; CS.faces = faces} =
    F.fprintf ppf "(deftheme %s \"\")@." name;
    F.fprintf ppf "(custom-theme-set-faces@.";
    F.fprintf ppf "  '%s@." name;
    F.fprintf ppf "  @[%a@]@." print_faces ("'", filter_faces faces);
    F.fprintf ppf "  )@.";
    F.fprintf ppf "(provide-theme '%s)@." name

  let out_name f =
    f ^ "-theme.el"
end

(* Produces themes for color-theme.el *)
module ColorThemeEl = struct
  (* The base UI faces are treated specially specially in old-style
     color themes. *)
  let filter_normal_faces =
    Util.StringMap.filter begin fun f _ ->
      f != "body" &&
        (List.mem_assoc f css_face_to_emacs_face || List.mem f face_whitelist)
    end

  let body_face_css_attribute_to_emacs_attribute =
    [ ("foreground", ["foreground-color"])
    ; ("background", ["background-color"])
    ]

  let print_body_face_attributes =
    Util.print_map
      body_face_css_attribute_to_emacs_attribute
      (fun ppf k v -> F.fprintf ppf "(%s . %a)@." k (print_attribute k) v)

  let print ppf {CS.name = name; CS.faces = faces} =
    F.fprintf ppf "(defun color-theme-%s ()@." name;
    F.fprintf ppf "  (interactive)@.";
    F.fprintf ppf "  (color-theme-install@.";
    F.fprintf ppf "    '(%s@." name;
    if CS.SM.mem "body" faces then
      F.fprintf ppf "      (@[%a@])@."
        print_body_face_attributes (CS.SM.find "body" faces);
    F.fprintf ppf "      @[%a@]@." print_faces ("", filter_normal_faces faces);
    F.fprintf ppf ")))@.";
    F.fprintf ppf "(provide 'color-theme-%s)" name

  let out_name f =
    "color-theme-" ^ f ^ ".el"
end
