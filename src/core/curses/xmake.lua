target("ltui")
    add_files("curses.c", {languages = "c99", cflags = "-Wno-expansion-to-defined"})

