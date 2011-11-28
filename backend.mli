module type M = sig
  val print : Format.formatter -> ColorScheme.t -> unit
end
