# We can translate substance identifiers

    Code
      translate_substances(input, from = "srppp")
    Output
        x srppp               derappp
      1 1     3 1-Naphthylacetic acid
      2 2  1245        Terbuthylazine
      3 3   323            Pyrethrins

---

    Code
      translate_substances(input_de, from = "substance_de")
    Output
        x          substance_de                                srppp
      1 1 1-Naphthylacetic acid 6F14D297-81BA-4AA0-9636-D65F2F1A0BD6
      2 2        Terbuthylazine 736564C2-CA47-4979-AC4A-917F2B97B61A
      3 3            Pyrethrine 7639690D-56F7-455F-9CFB-33D3C620FE91
                      derappp
      1 1-Naphthylacetic acid
      2        Terbuthylazine
      3            Pyrethrins

