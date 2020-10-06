target("ltui")

    -- add source files
    add_files("lcurses.c", {languages = "c99", cflags = "-Wno-expansion-to-defined"})

