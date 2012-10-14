module StringMap : Map.S with type key = string

module Operators: sig
  val (|>) : 'a -> ('a -> 'b) -> 'b
end

val print_map :
  (string * string list) list ->
  (Format.formatter -> string -> 'a -> unit) ->
  Format.formatter ->
  'a StringMap.t ->
  unit

val print_hex_color : Format.formatter -> (int * int * int) -> unit
