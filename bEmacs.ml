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
  [("keyword", "font-lock-keyword-face");
   ("comment", "font-lock-comment-face")]

let attribute_map =
  [("color", "foreground")]

let body_face_attribute_map =
  [("color",      "foreground-color");
   ("background", "background-color")]

(******************************************************************************)
(**************************** Color scheme printers ***************************)
(******************************************************************************)

let print_attribute ppf = function
  | CS.Color (r, g, b) -> F.fprintf ppf "\"#%02x%02x%02x\"" r g b (* pmr: factor out hex color printing *)
  | CS.String s        -> F.fprintf ppf "\"%s\"" s

let print_face_attributes =
  print_map
    attribute_map
    (fun ppf k v -> F.fprintf ppf ":%s %a@;" k print_attribute v)

let print_faces =
  print_map
    face_map
    begin fun ppf k v ->
      F.fprintf ppf "(%s ((t (@[%a@]))))@\n" k print_face_attributes v
    end

let print_body_face_option ppf = function
  | None      -> ()
  | Some face ->
    SM.iter begin fun attr v ->
      F.fprintf ppf "(%s . %a)@\n"
        (find_local_name body_face_attribute_map attr)
        print_attribute v
    end face

(* pmr: swap order of params *)
let print {CS.name = name; CS.faces = faces} ppf =
  let body_opt, faces = CS.extract_face faces "body" in
    F.fprintf ppf "(defun color-theme-%s ()@." name;
    F.fprintf ppf "  (interactive)@.";
    F.fprintf ppf "  (color-theme-install@.";
    F.fprintf ppf "    `(color-theme-%s@." name;
    F.fprintf ppf "      (@[%a@])@." print_body_face_option body_opt;
    F.fprintf ppf "      @[%a@]@." print_faces faces;
    F.fprintf ppf "  )))@.";
    F.fprintf ppf "(provide 'color-theme-%s)@." name
