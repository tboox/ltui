-- project
set_project("ltui")

-- version
set_version("1.1", {build = "%Y%m%d%H%M"})

-- set xmake min version
set_xmakever("2.2.3")

-- add projects
includes("src/core") 
