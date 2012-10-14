module StringMap : Map.S with type key = string

module Operators: sig
  val (|>) : 'a -> ('a -> 'b) -> 'b
end

module Colors: sig
  val rgb_of_hex_color_string : string -> int * int * int
  val rgb_to_hex_color_string : int * int * int -> string
end

val print_map :
  (string * string list) list ->
  (Format.formatter -> string -> 'a -> unit) ->
  Format.formatter ->
  'a StringMap.t ->
  unit
