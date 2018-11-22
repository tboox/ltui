-- add target
target("lcurses")

    -- only make objects
    set_kind("object")

    -- add deps
    if is_plat("windows") then
        add_deps("pdcurses")
    end

    -- add the common source files
    add_files("lcurses.c") 

    -- add packages
    if has_config("luajit") then
        add_defines("LUAJIT")
        add_packages("luajit")
    else
        add_packages("lua")
    end
  
    -- add links
    if is_plat("windows") then
        add_defines("PDCURSES")
        add_includedirs("../pdcurses")
    else
        add_links("curses")
    end

    -- set languages
    set_languages("c89")
