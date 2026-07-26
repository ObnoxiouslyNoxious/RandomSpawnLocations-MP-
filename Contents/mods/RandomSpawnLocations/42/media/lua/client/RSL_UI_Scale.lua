if isServer() and not isClient() then return end

RSL_UI_Scale = {}

local tmgr = getTextManager()
local FONT_SM = UIFont.Small
local fontHgt = tmgr:getFontHeight(FONT_SM)

local BASE_SM = 19
local SCALE = fontHgt / BASE_SM

RSL_UI_Scale.FONT_SM = FONT_SM
RSL_UI_Scale.fontHgt = fontHgt
RSL_UI_Scale.SCALE = SCALE

function RSL_UI_Scale.s(px)
    return math.floor(px * SCALE + 0.5)
end
