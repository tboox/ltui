
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
    add_links("kernel32", "user32", "gdi32")
end

-- add requires
add_requires("luajit")

-- add target
target("ltui")

    -- make as a shared library
    set_kind("shared")

    -- add deps
    add_deps("lcurses")

    -- set target directory
    set_targetdir("$(buildir)")

-- add projects
includes("lcurses")
if is_plat("windows") then
    includes("pdcurses")
end
