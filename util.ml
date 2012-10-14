module StringMap = Map.Make (String)

module Operators = struct
  let (|>) x f = f x
end

module Colors = struct
  let hex_color_re =
    Str.regexp ("^#?" ^
      "\\([a-zA-Z0-9][a-zA-Z0-9]\\)" ^
      "\\([a-zA-Z0-9][a-zA-Z0-9]\\)" ^
      "\\([a-zA-Z0-9][a-zA-Z0-9]\\)" ^
      "$")

  let rgb_of_hex_color_string hc =
    if Str.string_match hex_color_re hc 0 then
      ( int_of_string ("0x" ^ (Str.matched_group 1 hc))
      , int_of_string ("0x" ^ (Str.matched_group 2 hc))
      , int_of_string ("0x" ^ (Str.matched_group 3 hc))
      )
    else begin
      Printf.eprintf "hex_color: bad input '%s'\n" hc;
      assert false
    end

  let rgb_to_hex_color_string (r, g, b) =
    Format.sprintf "#%02x%02x%02x" r g b
end

(* Utilities for face and attribute maps *)

let find_translated_names name_map name =
  try List.assoc name name_map with Not_found -> [name]

let print_map key_translation_map pr ppf m =
  StringMap.iter begin fun k v ->
    List.iter begin fun lk ->
      pr ppf lk v
    end (find_translated_names key_translation_map k)
  end m
