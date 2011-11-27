module M  = Map
module CS = ColorScheme
module SM = CS.StringMap
module F  = Format

let print_attribute ppf = function
  | CS.Color (r, g, b) -> F.fprintf ppf "rgb(%d, %d, %d)" r g b
  | CS.String s        -> F.fprintf ppf "%s" s

let print cs ppf =
  SM.iter begin fun face attrs ->
    F.fprintf ppf "%s {@." face;
    SM.iter begin fun attr v ->
      F.fprintf ppf "  %s: %a;@." attr print_attribute v
    end attrs;
    F.fprintf ppf "}@.@.";
  end cs
