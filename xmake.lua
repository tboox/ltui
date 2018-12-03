-- project
set_project("ltui")

-- version
set_version("1.1", {build = "%Y%m%d%H%M"})

-- set xmake min version
set_xmakever("2.2.3")

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
    add_requires("luajit")
else
    add_requires("lua")
end
if not is_plat("windows") then
    add_requires("ncurses", {config = {cflags = "-fPIC"}})
end

-- add target
target("test")

    -- only for test
    set_kind("phony")

    -- default: disable
    set_default(false)

    -- we need build ltui first
    add_deps("ltui")

    -- run tests
    on_run(function (target)

        -- imports
        import("core.base.option")
        import("lib.detect.find_tool")

        -- do run
        local lua = has_config("luajit") and find_tool("luajit") or find_tool("lua")
        if lua then
            os.cd(os.projectdir())
            local testname = table.wrap(option.get("arguments"))[1] or "mconfdialog"
            os.execv(lua.program, {path.join("tests", testname .. ".lua")})
        else
            raise("%s not found!", has_config("luajit") and "luajit" or "lua")
        end
    end)

-- add target
target("ltui")

    -- make as a shared library
    set_kind("shared")

    -- set target directory
    set_targetdir("$(buildir)")

    -- set languages
    set_languages("c89")

    -- add lua and do not link it on linux and macos
    local lualinks = nil
    if not is_plat("windows") then
        lualinks = {} 
    end
    if has_config("luajit") then
        add_defines("LUAJIT")
        add_packages("luajit", {links = lualinks})
    else
        add_packages("lua", {links = lualinks})
    end
  
    -- add curses 
    if is_plat("windows") then
        add_defines("PDCURSES")
        add_includedirs("pdcurses")
    else
        add_packages("ncurses", {links = "ncurses"})
    end

    -- dynamic lookup liblua symbols
    if is_plat("macosx") then
        add_shflags("-undefined dynamic_lookup")
    end

-- add projects
includes("src/core/lcurses")
if is_plat("windows") then
    includes("src/core/pdcurses")
end
