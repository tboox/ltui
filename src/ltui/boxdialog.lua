---A cross-platform terminal ui library based on Lua
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Copyright (C) 2015-2020, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        boxdialog.lua
--

-- load modules
local log        = require("ltui/base/log")
local rect       = require("ltui/rect")
local action     = require("ltui/action")
local curses     = require("ltui/curses")
local window     = require("ltui/window")
local textdialog = require("ltui/textdialog")

-- define module
local boxdialog = boxdialog or textdialog()

-- init dialog
function boxdialog:init(name, bounds, title)

    -- init window
    textdialog.init(self, name, bounds, title)

    -- resize text
    self._TEXT_EY = 3
    self:text():bounds().ey = self._TEXT_EY
    self:text():invalidate(true)
    self:text():option_set("selectable", false)

    -- insert box
    self:panel():insert(self:box())

    -- text changed
    self:text():action_set(action.ac_on_text_changed, function (v)
        if v:text() then
            local lines = #self:text():splitext(v:text())
            if lines > 0 and lines < self:height() then
                self._TEXT_EY = lines
                self:panel():invalidate(true)
            end
        end
    end)

    -- select buttons by default
    self:panel():select(self:buttons())

    -- on resize for panel
    self:panel():action_add(action.ac_on_resized, function (v)
        self:text():bounds().ey = self._TEXT_EY
        self:box():bounds_set(rect{0, self._TEXT_EY, v:width(), v:height() - 1})
    end)

    -- on click for frame
    self:frame():action_set(action.ac_on_clicked, function (v, x, y)

        -- get relative coordinates
        x, y  = x - v:bounds().sx, y - v:bounds().sy
        local panel, box = v:parent():panel(), v:parent():box()
        local px, py  = x - panel:bounds().sx, y - panel:bounds().sy

        -- if coordinates don't match any view try box
        if panel:option("mouseable") then
            if panel:action_on(action.ac_on_clicked, x, y) then
                return true
            elseif box:option("mouseable") and not box:option("selectable") and box:bounds():contains(px, py) then
                return box:action_on(action.ac_on_clicked, px, py)
            end
        end
    end)
end

-- get box
function boxdialog:box()
    if not self._BOX then
        self._BOX = window:new("boxdialog.box", rect{0, self._TEXT_EY, self:panel():width(), self:panel():height() - 1})
        self._BOX:border():cornerattr_set("black", "white")
    end
    return self._BOX
end

-- on resize
function boxdialog:on_resize()
    self:text():text_set(self:text():text())
    textdialog.on_resize(self)
end

-- return module
return boxdialog
