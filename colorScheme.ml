module SM = Util.StringMap
module RE = Str
module P  = Printf

type attribute =
  | Color  of int * int * int
  | String of string

let hex_color_re =
  RE.regexp ("^#?" ^
    "\\([a-zA-Z0-9][a-zA-Z0-9]\\)" ^
    "\\([a-zA-Z0-9][a-zA-Z0-9]\\)" ^
    "\\([a-zA-Z0-9][a-zA-Z0-9]\\)" ^
    "$")

let hex_color hc =
  if RE.string_match hex_color_re hc 0 then
    Color ( int_of_string ("0x" ^ (RE.matched_group 1 hc))
          , int_of_string ("0x" ^ (RE.matched_group 2 hc))
          , int_of_string ("0x" ^ (RE.matched_group 3 hc))
          )
  else begin
    P.eprintf "hex_color: bad input '%s'\n" hc;
    assert false
  end

type t = { name  : string
         ; faces : (attribute SM.t) SM.t
         }

let of_list xs =
  List.fold_left (fun m (x, y) -> SM.add x y m) SM.empty xs

let extract_face cs face =
  try
    (Some (SM.find face cs), SM.remove face cs)
  with Not_found ->
    (None, cs)
