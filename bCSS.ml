module M  = Map
module CS = ColorScheme
module SM = Util.StringMap
module F  = Format

let print_face ppf = function
  | CS.Color (r, g, b) -> F.fprintf ppf "rgb(%d, %d, %d)" r g b
  | CS.String s        -> F.fprintf ppf "%s" s

let print ppf {CS.name = name; CS.faces = faces} =
  SM.iter begin fun face attrs ->
    F.fprintf ppf "%s {@." face;
    SM.iter begin fun attr v ->
      F.fprintf ppf "  %s: %a;@." attr print_face v
    end attrs;
    F.fprintf ppf "}@.@.";
  end faces

let out_name f =
    "TODO-css-out_name"

