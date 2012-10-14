module StringMap = Map.Make (String)

module Operators = struct
  let (|>) x f = f x
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

(* Colors *)

let print_hex_color ppf (r, g, b) =
  Format.fprintf ppf "\"#%02x%02x%02x\"" r g b
