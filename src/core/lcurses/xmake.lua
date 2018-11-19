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
    add_packages("luajit")
  
    -- add links
    if is_plat("windows") then
        add_defines("PDCURSES")
        add_includedirs("../pdcurses")
    else
        add_links("curses")
    end
