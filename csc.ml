module F  = Format
module CS = ColorScheme

let m =
  { CS.name  = "charybdis"
  ; CS.faces =  CS.of_list [("keyword", CS.of_list [("color", CS.Color (0, 182, 255))]);
                            ("comment", CS.of_list [("color", CS.Color (100, 100, 100))]);
                            ("body", CS.of_list [("background", CS.String "LightGoldenrod1");
                                                 ("color", CS.Color (0, 0, 255))])
                           ]
  }

(* CSS also *)
let _ = BEmacs.print m F.std_formatter
