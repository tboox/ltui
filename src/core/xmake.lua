
-- set warning all as error
set_warnings("all", "error")

-- set language: c99, c++11
set_languages("c99", "cxx11")

-- disable some compiler errors
add_cxflags("-Wno-error=deprecated-declarations", "-fno-strict-aliasing", "-Wno-error=nullability-completeness")

-- add defines
add_defines("_GNU_SOURCE=1", "_FILE_OFFSET_BITS=64", "_LARGEFILE_SOURCE")

-- set the symbols visibility: hidden
set_symbols("hidden")

-- strip all symbols
set_strip("all")

-- fomit the frame pointer
add_cxflags("-fomit-frame-pointer")

-- for the windows platform (msvc)
if is_plat("windows") then 
    add_cxflags("-MT") 
    add_defines("_CRT_SECURE_NO_WARNINGS")
    add_shflags("-nodefaultlib:msvcrt.lib")
    add_links("kernel32", "user32", "gdi32", "advapi32")
end

-- option: luajit
option("luajit")
    set_default(false)
    set_showmenu(true)
    set_category("option")
    set_description("Enable the luajit runtime engine.")
option_end()

-- add requires
if has_config("luajit") then
    add_requires("luajit", {nolink = not is_plat("windows")})
else
    add_requires("lua", {nolink = not is_plat("windows")})
end

-- add target
target("ltui")

    -- make as a shared library
    set_kind("shared")

    -- set target directory
    set_targetdir("$(buildir)")

    -- set languages
    set_languages("c89")

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
        add_includedirs("pdcurses")
    else
        add_links("curses")
    end

    -- dynamic lookup liblua symbols
    if is_plat("macosx") then
        add_shflags("-undefined dynamic_lookup")
    end

-- add projects
includes("lcurses")
if is_plat("windows") then
    includes("pdcurses")
end
