
local backdrop = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=], edgeSize = 1,
	insets = {top = 0, left = 0, bottom = 0, right = 0},
}

local tooltips = {
	GameTooltip, 
	ItemRefTooltip, 
	ShoppingTooltip1, 
	ShoppingTooltip2, 
	ShoppingTooltip3, 
	WorldMapTooltip, 
	DropDownList1MenuBackdrop, 
	DropDownList2MenuBackdrop, 
}

for _, v in pairs(tooltips) do
	v:SetBackdrop(backdrop)
	v:SetBackdropColor(0, 0, 0, 0.5)
	v:SetBackdropBorderColor(0, 0, 0, 1)
	v:SetScript("OnShow", function(self)
		local item = select(2, self:GetItem())
		if item then
			local quality = select(3, GetItemInfo(item))
			if quality then
				local r, g, b = GetItemQualityColor(quality)
				self:SetBackdropBorderColor(r, g, b)
			end
		else
			self:SetBackdropBorderColor(0, 0, 0)
		end
	end)
end

local hex = function(r, g, b)
	return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
end

local truncate = function(value)
	if value >= 1e6 then
		return string.format('%.2fm', value / 1e6)
	elseif value >= 1e4 then
		return string.format('%.1fk', value / 1e3)
	else
		return string.format('%.0f', value)
	end
end

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
	local unit = select(2, self:GetUnit())
	if unit then
		local unitClassification = UnitClassification(unit)
		local difficultyColor = GetDifficultyColor(unitLevel)
		if UnitIsPlayer(unit) then
			local guild, rank = GetGuildInfo(unit)
			if guild then
				GameTooltipTextLeft2:SetFormattedText(hex(0, 1, 1).."%s|r %s", guild, rank)
			end
		else
			for i=2, GameTooltip:NumLines() do
				if _G["GameTooltipTextLeft" .. i]:GetText():find(LEVEL) then
					_G["GameTooltipTextLeft" .. i]:SetText(string.format(hex(difficultyColor.r, difficultyColor.g, difficultyColor.b).."%s|r", unitLevel) .. unitClassification .. UnitCreatureType(unit))
					break
				end
			end
		end
		if UnitIsPVP(unit) then
			for i = 2, GameTooltip:NumLines() do
				if _G["GameTooltipTextLeft"..i]:GetText():find(PVP) then
					_G["GameTooltipTextLeft"..i]:SetText(nil)
					break
				end
			end
		end
		if UnitExists(unit.."target") then
			local r, g, b = GameTooltip_UnitColor(unit.."target")
			if UnitName(unit.."target") == UnitName("player") then
				text = hex(1, 0, 0).."<You>|r"
			else
				text = hex(r, g, b)..UnitName(unit.."target").."|r"
			end
			self:AddLine("Target: "..text)
		end
	end
end)

GameTooltipStatusBar:SetScript("OnValueChanged", function(self, value)
	if not value then
		return
	end
	local min, max = self:GetMinMaxValues()
	if value < min or value > max then
		return
	end
	local unit  = select(2, GameTooltip:GetUnit())
	if unit then
		min, max = UnitHealth(unit), UnitHealthMax(unit)
		if not self.text then
			self.text = self:CreateFontString(nil, "OVERLAY")
			self.text:SetPoint("CENTER", GameTooltipStatusBar)
			self.text:SetFont(GameFontNormal:GetFont(), 11, "THINOUTLINE")
		end
		self.text:Show()
		local hp = truncate(min).." / "..truncate(max)
		self.text:SetText(hp)
	end
end)

local iconFrame = CreateFrame("Frame", nil, ItemRefTooltip)
iconFrame:SetWidth(30)
iconFrame:SetHeight(30)
iconFrame:SetPoint("TOPRIGHT", ItemRefTooltip, "TOPLEFT", 0, 0)
iconFrame:SetBackdrop(backdrop)
iconFrame:SetBackdropColor(0, 0, 0, 0.5)
iconFrame:SetBackdropBorderColor(0, 0, 0, 1)
iconFrame.icon = iconFrame:CreateTexture(nil, "BACKGROUND")
iconFrame.icon:SetPoint("TOPLEFT", 1, -1)
iconFrame.icon:SetPoint("BOTTOMRIGHT", -1, 1)
iconFrame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

hooksecurefunc("SetItemRef", function(link, text, button)
	if iconFrame:IsShown() then
		iconFrame:Hide()
	end
	local type, id = string.match(link, "(%l+):(%d+)") 
	if type == "item" then
		iconFrame.icon:SetTexture(select(10, GetItemInfo(id))
		iconFrame:Show()
	elseif type == "spell" then
		iconFrame.icon:SetTexture(select(3, GetSpellInfo(id)))
		iconFrame:Show()
	elseif type == "achievement" then
		iconFrame.icon:SetTexture(select(10, GetAchievementInfo(id)))
		iconFrame:Show()
	end
end)
