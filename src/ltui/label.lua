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
-- @file        label.lua
--

-- load modules
local log         = require("ltui/base/log")
local view        = require("ltui/view")
local event       = require("ltui/event")
local action      = require("ltui/action")
local curses      = require("ltui/curses")
local luajit, bit = pcall(require, "bit")
if not luajit then
    bit = require("ltui/base/bit")
end

-- define module
local label = label or view()

-- init label
function label:init(name, bounds, text)

    -- init view
    view.init(self, name, bounds)

    -- init text
    self:text_set(text)

    -- init text attribute
    self:textattr_set("black")
end

-- draw view
function label:on_draw(transparent)

    -- draw background
    view.on_draw(self, transparent)

    -- get the text attribute value
    local textattr = self:textattr_val()

    -- draw text string
    local str = self:text()
    if str and #str > 0 and textattr then
        self:canvas():attr(textattr):move(0, 0):putstrs(self:splitext(str))
    end
end

-- get text
function label:text()
    return self._TEXT
end

-- set text
function label:text_set(text)

    -- set text
    text = text or ""
    local changed = self._TEXT ~= text
    self._TEXT = text

    -- do action
    if changed then
        self:action_on(action.ac_on_text_changed)
    end
    self:invalidate()
    return self
end

-- get text attribute
function label:textattr()
    return self:attr("textattr")
end

-- set text attribute, .e.g textattr_set("yellow onblue bold")
function label:textattr_set(attr)
    return self:attr_set("textattr", attr)
end

-- get the current text attribute value
function label:textattr_val()

    -- get text attribute
    local textattr = self:textattr()
    if not textattr then
        return
    end

    -- no text background? use view's background
    if self:background() and not textattr:find("on") then
        textattr = textattr .. " on" .. self:background()
    end

    -- attempt to get the attribute value from the cache first
    self._TEXTATTR = self._TEXTATTR or {}
    local value = self._TEXTATTR[textattr]
    if value then
        return value
    end

    -- update the cache
    value = curses.calc_attr(textattr:split("%s+"))
    self._TEXTATTR[textattr] = value
    return value
end

local function _unicode_width(str, idx)
    -- based on Markus Kuhn's implementation of wcswidth()
    -- https://www.cl.cam.ac.uk/~mgk25/ucs/wcwidth.c
    local non_spacing = {
        {0x0300, 0x036F},   {0x0483, 0x0486},   {0x0488, 0x0489},
        {0x0591, 0x05BD},   {0x05BF, 0x05BF},   {0x05C1, 0x05C2},
        {0x05C4, 0x05C5},   {0x05C7, 0x05C7},   {0x0600, 0x0603},
        {0x0610, 0x0615},   {0x064B, 0x065E},   {0x0670, 0x0670},
        {0x06D6, 0x06E4},   {0x06E7, 0x06E8},   {0x06EA, 0x06ED},
        {0x070F, 0x070F},   {0x0711, 0x0711},   {0x0730, 0x074A},
        {0x07A6, 0x07B0},   {0x07EB, 0x07F3},   {0x0901, 0x0902},
        {0x093C, 0x093C},   {0x0941, 0x0948},   {0x094D, 0x094D},
        {0x0951, 0x0954},   {0x0962, 0x0963},   {0x0981, 0x0981},
        {0x09BC, 0x09BC},   {0x09C1, 0x09C4},   {0x09CD, 0x09CD},
        {0x09E2, 0x09E3},   {0x0A01, 0x0A02},   {0x0A3C, 0x0A3C},
        {0x0A41, 0x0A42},   {0x0A47, 0x0A48},   {0x0A4B, 0x0A4D},
        {0x0A70, 0x0A71},   {0x0A81, 0x0A82},   {0x0ABC, 0x0ABC},
        {0x0AC1, 0x0AC5},   {0x0AC7, 0x0AC8},   {0x0ACD, 0x0ACD},
        {0x0AE2, 0x0AE3},   {0x0B01, 0x0B01},   {0x0B3C, 0x0B3C},
        {0x0B3F, 0x0B3F},   {0x0B41, 0x0B43},   {0x0B4D, 0x0B4D},
        {0x0B56, 0x0B56},   {0x0B82, 0x0B82},   {0x0BC0, 0x0BC0},
        {0x0BCD, 0x0BCD},   {0x0C3E, 0x0C40},   {0x0C46, 0x0C48},
        {0x0C4A, 0x0C4D},   {0x0C55, 0x0C56},   {0x0CBC, 0x0CBC},
        {0x0CBF, 0x0CBF},   {0x0CC6, 0x0CC6},   {0x0CCC, 0x0CCD},
        {0x0CE2, 0x0CE3},   {0x0D41, 0x0D43},   {0x0D4D, 0x0D4D},
        {0x0DCA, 0x0DCA},   {0x0DD2, 0x0DD4},   {0x0DD6, 0x0DD6},
        {0x0E31, 0x0E31},   {0x0E34, 0x0E3A},   {0x0E47, 0x0E4E},
        {0x0EB1, 0x0EB1},   {0x0EB4, 0x0EB9},   {0x0EBB, 0x0EBC},
        {0x0EC8, 0x0ECD},   {0x0F18, 0x0F19},   {0x0F35, 0x0F35},
        {0x0F37, 0x0F37},   {0x0F39, 0x0F39},   {0x0F71, 0x0F7E},
        {0x0F80, 0x0F84},   {0x0F86, 0x0F87},   {0x0F90, 0x0F97},
        {0x0F99, 0x0FBC},   {0x0FC6, 0x0FC6},   {0x102D, 0x1030},
        {0x1032, 0x1032},   {0x1036, 0x1037},   {0x1039, 0x1039},
        {0x1058, 0x1059},   {0x1160, 0x11FF},   {0x135F, 0x135F},
        {0x1712, 0x1714},   {0x1732, 0x1734},   {0x1752, 0x1753},
        {0x1772, 0x1773},   {0x17B4, 0x17B5},   {0x17B7, 0x17BD},
        {0x17C6, 0x17C6},   {0x17C9, 0x17D3},   {0x17DD, 0x17DD},
        {0x180B, 0x180D},   {0x18A9, 0x18A9},   {0x1920, 0x1922},
        {0x1927, 0x1928},   {0x1932, 0x1932},   {0x1939, 0x193B},
        {0x1A17, 0x1A18},   {0x1B00, 0x1B03},   {0x1B34, 0x1B34},
        {0x1B36, 0x1B3A},   {0x1B3C, 0x1B3C},   {0x1B42, 0x1B42},
        {0x1B6B, 0x1B73},   {0x1DC0, 0x1DCA},   {0x1DFE, 0x1DFF},
        {0x200B, 0x200F},   {0x202A, 0x202E},   {0x2060, 0x2063},
        {0x206A, 0x206F},   {0x20D0, 0x20EF},   {0x302A, 0x302F},
        {0x3099, 0x309A},   {0xA806, 0xA806},   {0xA80B, 0xA80B},
        {0xA825, 0xA826},   {0xFB1E, 0xFB1E},   {0xFE00, 0xFE0F},
        {0xFE20, 0xFE23},   {0xFEFF, 0xFEFF},   {0xFFF9, 0xFFFB},
        {0x10A01, 0x10A03}, {0x10A05, 0x10A06}, {0x10A0C, 0x10A0F},
        {0x10A38, 0x10A3A}, {0x10A3F, 0x10A3F}, {0x1D167, 0x1D169},
        {0x1D173, 0x1D182}, {0x1D185, 0x1D18B}, {0x1D1AA, 0x1D1AD},
        {0x1D242, 0x1D244}, {0xE0001, 0xE0001}, {0xE0020, 0xE007F},
        {0xE0100, 0xE01EF},
    }

    idx = idx or 1

    -- turn codepoint into unicode
    local c = str:byte(idx)
    local seq = c < 0x80 and 1 or c < 0xE0 and 2 or c < 0xF0 and 3 or
                c < 0xF8 and 4 or error("invalid UTF-8 sequence")
    local val = seq == 1 and c or bit.band(c, (2^(8 - seq) - 1))

    for aux = 2, seq do
        c = str:byte(idx + aux - 1)
        val = val * 2 ^ 6 + bit.band(c, 0x3F)
    end

    -- test for 8-bit control characters
    if val == 0 then return 0 end

    if val < 32 or (val >= 0x7f and val < 0xa0) then
        return -1
    end

    -- binary search in table of non-spacing characters
    local min, max = 1, #non_spacing
    if val >= non_spacing[1][1] and val <= non_spacing[max][2] then
        while max >= min do
            local mid = math.floor((min + max) / 2)
            if val > non_spacing[mid][2] then
                min = mid + 1
            elseif val < non_spacing[mid][1] then
                max = mid - 1
            else
                return 0
            end
        end
    end

    if  val >= 0x1100 and (val <= 0x115f or  -- Hangul Jamo init. consonants
        val == 0x2329 or val == 0x232a or
        (val >= 0x2e80 and val <= 0xa4cf and
        val ~= 0x303f) or                    -- CJK ... Yi
        (val >= 0xac00 and val <= 0xd7a3) or -- Hangul Syllables
        (val >= 0xf900 and val <= 0xfaff) or -- CJK Compatibility Ideographs
        (val >= 0xfe10 and val <= 0xfe19) or -- Vertical forms
        (val >= 0xfe30 and val <= 0xfe6f) or -- CJK Compatibility Forms
        (val >= 0xff00 and val <= 0xff60) or -- Fullwidth Forms
        (val >= 0xffe0 and val <= 0xffe6) or
        (val >= 0x20000 and val <= 0x2fffd) or
        (val >= 0x30000 and val <= 0x3fffd)) then
        return 2
    end

    return 1
end

-- split text by width
function label:splitext(text, width)

    -- get width
    width = width or self:width()

    -- split text first
    local result = {}
    local lines = text:split('\n', true)
    for idx = 1, #lines do
        local line = lines[idx]
        while #line > width do
            local size = 0
            for i = 1, #line do
                if bit.band(line:byte(i), 0xc0) ~= 0x80 then
                    size = size + _unicode_width(line, i)
                    if size > width then
                        table.insert(result, line:sub(1, i - 1))
                        line = line:sub(i)
                        break
                    end
                end
            end
            if size <= width then
                break
            end
        end
        table.insert(result, line)
    end
    return result
end

-- return module
return label
