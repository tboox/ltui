-- init load directories 
package.path  = package.path .. ';./src/?.lua'
package.cpath = package.cpath .. ';./build/ltui.dll;./build/libltui.so;./build/libltui.dylib'

local os     = require("ltui/base/os")
local ltui   = require("ltui.curses")
print(ltui)

--  requires
local log  = require("ltui/base/log")
local rect = require("ltui/rect")
local view = require("ltui/view")
local label = require("ltui/label")
local event = require("ltui/event")
local button = require("ltui/button")
local application = require("ltui/application")

-- the demo application
local demo = application()

-- init demo
function demo:init()

    -- init name 
    application.init(self, "demo")

    -- show desktop, menubar and statusbar
    self:insert(self:desktop())
    self:insert(self:menubar())
    self:insert(self:statusbar())

    -- init title
    self:menubar():title():text_set("Menu Bar (Hello)")

    -- add title label
    self:desktop():insert(label:new("title", rect {0, 0, 12, 1}, "hello xmake!"):textattr_set("white"), {centerx = true})

    -- add yes button
    self:desktop():insert(button:new("yes", rect {0, 1, 7, 2}, "< Yes >"):textattr_set("white"), {centerx = true})

    -- add no button
    self:desktop():insert(button:new("no", rect {0, 2, 6, 3}, "< No >"):textattr_set("white"), {centerx = true})
end

-- on event
function demo:event_on(e)
    if application.event_on(self, e) then
        return true
    end
    if e.type == event.ev_keyboard then
        self:statusbar():info():text_set(e.key_name)
        if e.key_name == "s" then
            self:statusbar():show(not self:statusbar():state("visible"))
        elseif e.key_name == "m" then
            self:menubar():show(not self:menubar():state("visible"))
        elseif e.key_name == "d" then
            self:desktop():show(not self:desktop():state("visible"))
        end
    end
end

-- main entry
demo:run()
