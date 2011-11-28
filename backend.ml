module type M = sig
  val print : Format.formatter -> ColorScheme.t -> unit
  val out_name : string -> string
end
