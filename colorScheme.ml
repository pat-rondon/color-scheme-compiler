module StringMap = Map.Make (String)

type color = int * int * int

type attribute =
  | Color  of color
  | String of string

type t = (string StringMap.t) StringMap.t

let of_list xs = List.fold_left (fun m (x, y) -> StringMap.add x y m) StringMap.empty xs

let extract_face cs face =
  try
    (Some (StringMap.find face cs), StringMap.remove face cs)
  with Not_found ->
    (None, cs)
