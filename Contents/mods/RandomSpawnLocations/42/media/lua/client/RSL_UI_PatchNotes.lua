if isServer() and not isClient() then return end

require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISTextEntryBox"
require "ISUI/ISTickBox"
require "RSL_UI_Scale"
require "RSL_Env"
require "RSL_Config"

RSL_UI_PatchNotes = {}
RSL_UI_PatchNotes.instance = nil

local S = RSL_UI_Scale.s
local FONT = RSL_UI_Scale.FONT_SM
local FONT_H = RSL_UI_Scale.fontHgt
local WIN_W = S(480)
local WIN_H = S(380)
local WIN_H_AUTO = WIN_H + S(36)
local PAD = S(10)
local TEXT_PAD = S(10)
local SCROLL_W = S(30)
local LINE_H = FONT_H + S(4)
local BTN_PAG_W = S(70)

local COL_ACCENT = { r = 52 / 255, g = 194 / 255, b = 0 / 255 }
local COL_TEXT = { r = 0.90, g = 0.90, b = 0.90 }
local COL_DIM = { r = 0.60, g = 0.60, b = 0.60 }

RSL_PatchNotes_Window = ISCollapsableWindow:derive("RSL_PatchNotes_Window")

function RSL_PatchNotes_Window:new(x, y, history, links, autoMode, version)
	local h = autoMode and WIN_H_AUTO or WIN_H
	local o = ISCollapsableWindow.new(self, x, y, WIN_W, h)
	o.moveWithMouse = true
	o.resizable = false
	o.history = history or {}
	o.links = links or {}
	o.currentPage = 1
	o.autoMode = autoMode == true
	o.version = version
	o.totalPages = math.max(1, #o.history + (#o.links > 0 and 1 or 0))
	return o
end

function RSL_PatchNotes_Window:createChildren()
	ISCollapsableWindow.createChildren(self)

	local titleH = FONT_H + S(1)
	local y = titleH + PAD
	local winW = self:getWidth()
	local winH = self:getHeight()

	local pagH = FONT_H + S(5)
	local checkboxH = self.autoMode and (FONT_H + S(8)) or 0
	local checkboxGap = self.autoMode and S(12) or 0
	local bottomH = pagH + checkboxH + checkboxGap + PAD
	local listH = winH - titleH - PAD - bottomH - PAD

	self.noteList = ISScrollingListBox:new(PAD, y, winW - PAD * 2, listH)
	self.noteList:initialise()
	self.noteList:instantiate()
	self.noteList.itemheight = LINE_H
	self.noteList.selected = 0
	self.noteList.font = FONT
	self.noteList.drawBorder = true
	self.noteList.doDrawItem = RSL_PatchNotes_Window.drawNoteLine
	self.noteList:setOnMouseDownFunction(self, RSL_PatchNotes_Window.onRowClicked)
	self:addChild(self.noteList)
	y = y + listH + PAD

	if self.autoMode then
		self.dontShowTick = ISTickBox:new(PAD, y, winW - PAD * 2, checkboxH, "", nil, nil)
		self.dontShowTick:initialise()
		self.dontShowTick:instantiate()
		self.dontShowTick:addOption(getText("IGUI_RSL_PatchNotes_DontShowAgain"))
		self:addChild(self.dontShowTick)
		y = y + checkboxH + checkboxGap
	end

	local tmgr = getTextManager()
	local BTN_PAD_X = S(16)
	local prevText = getText("IGUI_RSL_PatchNotes_Prev")
	local nextText = getText("IGUI_RSL_PatchNotes_Next")
	local closeText = getText("IGUI_RSL_Common_Close")
	local prevW = math.max(BTN_PAG_W, tmgr:MeasureStringX(FONT, prevText) + BTN_PAD_X)
	local nextW = math.max(BTN_PAG_W, tmgr:MeasureStringX(FONT, nextText) + BTN_PAD_X)
	local closeW = math.max(S(90), tmgr:MeasureStringX(FONT, closeText) + BTN_PAD_X)

	self.btnPrev = ISButton:new(PAD, y, prevW, pagH,
		prevText, self, RSL_PatchNotes_Window.onPrevPage)
	self.btnPrev:initialise()
	self.btnPrev:instantiate()
	self:addChild(self.btnPrev)

	self.pageEntry = ISTextEntryBox:new(tostring(self.currentPage), PAD + prevW + S(6), y, S(40), pagH)
	self.pageEntry:initialise()
	self.pageEntry:instantiate()
	self.pageEntry:setOnlyNumbers(true)
	self.pageEntry.onCommandEntered = function(_)
		self:onPageInput()
	end
	self:addChild(self.pageEntry)

	self.pageLabel = ISLabel:new(PAD + prevW + S(52), y + S(4), S(16),
		getText("IGUI_RSL_PatchNotes_PageLabel", self.totalPages),
		COL_DIM.r, COL_DIM.g, COL_DIM.b, 1, FONT, true)
	self.pageLabel:initialise()
	self:addChild(self.pageLabel)

	self.btnNext = ISButton:new(winW - PAD - nextW - S(6) - closeW, y, nextW, pagH,
		nextText, self, RSL_PatchNotes_Window.onNextPage)
	self.btnNext:initialise()
	self.btnNext:instantiate()
	self:addChild(self.btnNext)

	self.btnClose = ISButton:new(winW - PAD - closeW, y, closeW, pagH,
		closeText, self, RSL_PatchNotes_Window.onClose)
	self.btnClose:initialise()
	self.btnClose:instantiate()
	self:addChild(self.btnClose)

	self:showPage()
end

function RSL_PatchNotes_Window:showPage()
	self.noteList:clear()
	local maxW = self:getWidth() - PAD * 2 - TEXT_PAD * 2 - SCROLL_W
	local historyCount = #self.history

	self.noteList:addItem("", { header = false, text = "" })

	if self.currentPage <= historyCount then
		local entry = self.history[self.currentPage]
		if entry then
			self.noteList:addItem(entry.version, {
				header = true,
				text = string.format("--- %s %s (%s) ---", getText("IGUI_RSL_PatchNotes_VersionLabel"), tostring(entry.version), tostring(entry.date)),
			})
			self.noteList:addItem("", { header = false, text = "" })
			self:addLines(entry.notes or {}, maxW)
		end
	else
		self:addLines(self.links, maxW)
	end

	self.noteList:addItem("", { header = false, text = "" })

	if self.pageEntry then self.pageEntry:setText(tostring(self.currentPage)) end
	if self.pageLabel then
		self.pageLabel:setName(getText("IGUI_RSL_PatchNotes_PageLabel", self.totalPages))
	end
	if self.btnPrev then self.btnPrev.enable = self.currentPage > 1 end
	if self.btnNext then self.btnNext.enable = self.currentPage < self.totalPages end
end

function RSL_PatchNotes_Window:addLines(entries, maxW)
	for _, entry in ipairs(entries or {}) do
		if entry.spacer then
			self.noteList:addItem("", { header = false, text = "" })
		elseif entry.header then
			local text = string.format("--- %s ---", getText(entry.header))
			self.noteList:addItem(text, { header = true, text = text })
		elseif entry.line then
			local text = getText(entry.line)
			local wrapped = self:wrapLine(text, maxW)
			for _, wl in ipairs(wrapped) do
				self.noteList:addItem(wl, { header = false, text = wl })
			end
			if entry.copyUrl then
				self.noteList:addItem("__copybtn__", { copyBtnRow = true, copyUrl = entry.copyUrl })
				self.noteList:addItem("", { header = false, text = "" })
			end
		end
	end
end

function RSL_PatchNotes_Window:wrapLine(line, maxW)
	if line == "" then return { "" } end
	local tmgr = getTextManager()
	if tmgr:MeasureStringX(FONT, line) <= maxW then
		return { line }
	end
	local wrapped = tmgr:WrapText(FONT, line, maxW, 10, "")
	local result = {}
	for segment in string.gmatch(wrapped, "[^\n]+") do
		result[#result + 1] = segment
	end
	return #result > 0 and result or { line }
end

local COPY_LINK_LABEL = getText("IGUI_RSL_PatchNotes_CopyLink")
local COPY_LINK_COPIED_LABEL = getText("IGUI_RSL_PatchNotes_LinkCopied")
local COPY_LINK_FEEDBACK_MS = 5000
local COPY_BTN_PAD_X = S(10)
local COPY_BTN_H = FONT_H + S(2)

function RSL_PatchNotes_Window:drawNoteLine(y, item, alt)
	local data = item.item or {}
	local w = self:getWidth()

	if data.copyBtnRow then
		local copied = data.copiedUntil and getTimestampMs() < data.copiedUntil
		local label = copied and COPY_LINK_COPIED_LABEL or COPY_LINK_LABEL
		local textW = getTextManager():MeasureStringX(FONT, label)
		local btnW = textW + COPY_BTN_PAD_X * 2
		local btnX = TEXT_PAD
		local btnY = y + S(1)
		data.btnW = btnW
		if copied then
			self:drawRect(btnX, btnY, btnW, COPY_BTN_H, 1, COL_ACCENT.r, COL_ACCENT.g, COL_ACCENT.b)
			self:drawText(label, btnX + COPY_BTN_PAD_X, y + S(2), 0, 0, 0, 1, FONT)
		else
			self:drawRectBorder(btnX, btnY, btnW, COPY_BTN_H, 1, COL_ACCENT.r, COL_ACCENT.g, COL_ACCENT.b)
			self:drawText(label, btnX + COPY_BTN_PAD_X, y + S(2), COL_ACCENT.r, COL_ACCENT.g, COL_ACCENT.b, 1, FONT)
		end
		return y + LINE_H
	end

	self:drawRect(0, y, w, LINE_H - S(1), 1, 0.0, 0.0, 0.0)
	if data.header then
		self:drawText(data.text, TEXT_PAD, y + S(2),
			COL_ACCENT.r, COL_ACCENT.g, COL_ACCENT.b, 1, FONT)
	elseif data.text ~= "" then
		self:drawText(data.text, TEXT_PAD, y + S(2),
			COL_TEXT.r, COL_TEXT.g, COL_TEXT.b, 1, FONT)
	end
	return y + LINE_H
end

function RSL_PatchNotes_Window.onRowClicked(target, data)
	if not data or not data.copyBtnRow or not data.copyUrl then return end
	local mouseX = target:getMouseX() - target.noteList:getX()
	local btnW = data.btnW or (getTextManager():MeasureStringX(FONT, COPY_LINK_LABEL) + COPY_BTN_PAD_X * 2)
	if mouseX and mouseX >= TEXT_PAD and mouseX <= TEXT_PAD + btnW then
		Clipboard.setClipboard(data.copyUrl)
		data.copiedUntil = getTimestampMs() + COPY_LINK_FEEDBACK_MS
		RSL_dprint("[RSL] Copied link to clipboard: " .. data.copyUrl)
	end
end

function RSL_PatchNotes_Window:onPrevPage()
	if self.currentPage > 1 then
		self.currentPage = self.currentPage - 1
		self:showPage()
	end
end

function RSL_PatchNotes_Window:onNextPage()
	if self.currentPage < self.totalPages then
		self.currentPage = self.currentPage + 1
		self:showPage()
	end
end

function RSL_PatchNotes_Window:onPageInput()
	local page = tonumber(self.pageEntry:getText()) or 1
	page = math.max(1, math.min(page, self.totalPages))
	self.currentPage = page
	self:showPage()
end

function RSL_PatchNotes_Window:onClose()
	if self.autoMode and self.dontShowTick and self.dontShowTick:isSelected(1) then
		if RSL_PatchNotesSync and RSL_PatchNotesSync.acknowledge then
			RSL_PatchNotesSync.acknowledge(self.version)
		end
	end
	self:close()
end

function RSL_PatchNotes_Window:close()
	self:setVisible(false)
	self:removeFromUIManager()
	RSL_UI_PatchNotes.instance = nil
end

function RSL_PatchNotes_Window:setVisible(bVisible)
	ISCollapsableWindow.setVisible(self, bVisible)
	if self.autoMode and RSL_Env.isSP() and getSpecificPlayer(0) then
		setGameSpeed(bVisible and 0 or 1)
	end
end

function RSL_PatchNotes_Window:prerender()
	ISCollapsableWindow.prerender(self)
	local titleH = FONT_H + S(1)
	self:drawRect(0, titleH, self.width, S(2), 1, COL_ACCENT.r, COL_ACCENT.g, COL_ACCENT.b)
end

local function computeMinWindowWidth(totalPages, autoMode)
	local tmgr = getTextManager()
	local btnPadX = S(16)
	local prevW = math.max(BTN_PAG_W, tmgr:MeasureStringX(FONT, getText("IGUI_RSL_PatchNotes_Prev")) + btnPadX)
	local nextW = math.max(BTN_PAG_W, tmgr:MeasureStringX(FONT, getText("IGUI_RSL_PatchNotes_Next")) + btnPadX)
	local closeW = math.max(S(90), tmgr:MeasureStringX(FONT, getText("IGUI_RSL_Common_Close")) + btnPadX)
	local pageLabelW = tmgr:MeasureStringX(FONT, getText("IGUI_RSL_PatchNotes_PageLabel", totalPages))
	local gap = S(6)
	local neededW = PAD * 2 + prevW + gap + S(40) + gap + pageLabelW + gap + nextW + gap + closeW

	if autoMode then
		local checkboxH = FONT_H + S(8)
		local textGap = 10
		local labelW = tmgr:MeasureStringX(FONT, getText("IGUI_RSL_PatchNotes_DontShowAgain"))
		local checkboxNeededW = PAD + checkboxH + textGap + labelW + PAD
		neededW = math.max(neededW, checkboxNeededW)
	end

	return math.max(WIN_W, neededW)
end

function RSL_UI_PatchNotes.open(currentVersion, history, links)
	if RSL_UI_PatchNotes.instance then
		RSL_UI_PatchNotes.instance:close()
	end
	local screenW = getPlayerScreenWidth(0)
	local screenH = getPlayerScreenHeight(0)
	local win = RSL_PatchNotes_Window:new(0, 0, history, links, false, currentVersion)
	local w = math.min(computeMinWindowWidth(win.totalPages), screenW - 40)
	local h = math.min(WIN_H, screenH - 40)
	local x = math.floor((screenW - w) / 2)
	local y = math.floor((screenH - h) / 2)
	win.x = x
	win.y = y
	win:setWidth(w)
	win:setHeight(h)
	win:initialise()
	win:instantiate()
	win:addToUIManager()
	win:setTitle(getText("IGUI_RSL_PatchNotes_Title", tostring(currentVersion or "")))
	RSL_UI_PatchNotes.instance = win
	win:setVisible(true)
end

function RSL_UI_PatchNotes.openAuto(currentVersion, history, links)
	if RSL_UI_PatchNotes.instance then
		RSL_UI_PatchNotes.instance:close()
	end
	local screenW = getPlayerScreenWidth(0)
	local screenH = getPlayerScreenHeight(0)
	local win = RSL_PatchNotes_Window:new(0, 0, history, links, true, currentVersion)
	local w = math.min(computeMinWindowWidth(win.totalPages, true), screenW - 40)
	local h = math.min(WIN_H_AUTO, screenH - 40)
	local x = math.floor((screenW - w) / 2)
	local y = math.floor((screenH - h) / 2)
	win.x = x
	win.y = y
	win:setWidth(w)
	win:setHeight(h)
	win:initialise()
	win:instantiate()
	win:addToUIManager()
	win:setTitle(getText("IGUI_RSL_PatchNotes_Title", tostring(currentVersion or "")))
	RSL_UI_PatchNotes.instance = win
	win:setVisible(true)
end

local function onClickViewPatchNotes()
	if RSL_PatchNotes and RSL_UI_PatchNotes and RSL_UI_PatchNotes.open then
		RSL_UI_PatchNotes.open(RSL_PatchNotes.CURRENT_VERSION, RSL_PatchNotes.History, RSL_PatchNotes.Links)
	end
end

local function initModOptions()
	local modOptions = PZAPI.ModOptions:create("RandomSpawnLocations", getText("IGUI_RSL_ModOptions_Title"))
	modOptions:addTitle(getText("IGUI_RSL_ModOptions_PatchNotesTitle"))
	modOptions:addButton("viewPatchNotes", getText("IGUI_RSL_ModOptions_ButtonName"),
		getText("IGUI_RSL_ModOptions_ButtonDesc"), onClickViewPatchNotes)
end

Events.OnCreateUI.Add(initModOptions)
