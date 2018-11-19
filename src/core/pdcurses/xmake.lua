-- add target
target("pdcurses")

    -- only make objects
    set_kind("object")

    -- add the common source files
    add_files("**.c") 

    -- add defines
    add_defines("PDC_WIDE")

    -- set languages
    set_languages("c89")
