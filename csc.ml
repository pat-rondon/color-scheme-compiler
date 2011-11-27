module F  = Format
module CS = ColorScheme

let m = CS.of_list [("foo", CS.of_list [("bar", CS.String "baz"); ("boob", CS.Color (255, 255, 255))])]

let _ = BCSS.print m F.std_formatter

let _ = F.printf "TBD"
