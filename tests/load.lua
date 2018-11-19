-- init load directories 
package.path  = package.path .. ';./src/?.lua'
package.cpath = package.cpath .. ';./build/ltui.dll;./build/libltui.so;./build/libltui.dylib'

local os     = require("ltui/base/os")
local ltui   = require("ltui.curses")
print(ltui)

print(os.host())
