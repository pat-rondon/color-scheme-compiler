module type M = sig
  val print : ColorScheme.t -> Format.formatter -> unit
end
