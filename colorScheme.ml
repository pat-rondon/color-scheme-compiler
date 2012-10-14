module SM = Util.StringMap
module P  = Printf

type attribute =
  | Color  of int * int * int
  | String of string

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
