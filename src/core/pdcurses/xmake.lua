-- add target
target("pdcurses")

    -- make as a static library
    set_kind("static")

    -- add the common source files
    add_files("**.c") 

    -- add defines
    add_defines("PDC_WIDE")

    -- set languages
    set_languages("c89")
