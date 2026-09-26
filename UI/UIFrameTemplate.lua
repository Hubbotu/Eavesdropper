---Frame Background
Eavesdropper_NineSliceFrameMixin = {};

local ThemeLayout = {
	Standard = {
		TopLeftCorner = {width = 140, height = 96, left = 0, right = 140, top = 0, bottom = 96},
		TopRightCorner = {width = 158, height = 96, left = 204, right = 362, top = 0, bottom = 96},
		BottomLeftCorner = {width = 140, height = 96, left = 0, right = 140, top = 224, bottom = 320},
		BottomRightCorner = {width = 158, height = 96, left = 204, right = 362, top = 224, bottom = 320},
		TopEdge = {width = 64, height = 96, left = 140, right = 204, top = 0, bottom = 96, tileHorizontal = true},
		BottomEdge = {width = 64, height = 96, left = 140, right = 204, top = 224, bottom = 320},
		LeftEdge = {width = 140, height = 128, left = 0, right = 140, top = 96, bottom = 224},
		RightEdge = {width = 158, height = 128, left = 204, right = 362, top = 96, bottom = 224},
		Center = {width = 64, height = 128, left = 140, right = 204, top = 96, bottom = 224},
	},

	Forever = {
		TopLeftCorner = {width = 98, height = 96, left = 0, right = 98, top = 0, bottom = 96},
		TopRightCorner = {width = 108, height = 96, left = 254, right = 362, top = 0, bottom = 96},
		BottomLeftCorner = {width = 98, height = 96, left = 0, right = 98, top = 224, bottom = 320},
		BottomRightCorner = {width = 108, height = 96, left = 254, right = 362, top = 224, bottom = 320},
		TopEdge = {width = 156, height = 96, left = 98, right = 254, top = 0, bottom = 96, tileHorizontal = true},
		BottomEdge = {width = 156, height = 96, left = 98, right = 254, top = 224, bottom = 320, tileHorizontal = true},
		LeftEdge = {width = 98, height = 128, left = 0, right = 98, top = 96, bottom = 224, tileVertical = true},
		RightEdge = {width = 108, height = 128, left = 254, right = 362, top = 96, bottom = 224, tileVertical = true},
		Center = {width = 156, height = 128, left = 98, right = 254, top = 96, bottom = 224, tileBoth = true},
	},
};

ThemeLayout.ForeverBrighter = ThemeLayout.Forever;

---@alias FrameTheme
---| "Standard"
---| "Forever"
---| "ForeverBrighter"

---@param theme FrameTheme?
function Eavesdropper_NineSliceFrameMixin:SetTheme(theme)
	if not ThemeLayout[theme] then return; end

	local path = string.format("Interface/AddOns/Eavesdropper/Resources/%s/Frame", theme);
	local sizeScale = 0.5;
	local canvasWidth, canvasHeight = 512, 512;

	for pieceName, info in pairs(ThemeLayout[theme]) do
		local piece = self[pieceName];
		if piece then
			piece:SetSize(info.width * sizeScale, info.height * sizeScale);

			local texture;
			local wrapModeHorizontal;
			local wrapModeVertical;

			if info.tileHorizontal then
				texture = path.."-Horizontal.png";
				wrapModeHorizontal = "REPEAT";
				piece:SetTexCoord(0, 1, info.top / canvasHeight, info.bottom / canvasHeight);
			elseif info.tileVertical then
				texture = path.."-Vertical.png";
				wrapModeVertical = "REPEAT";
				piece:SetTexCoord(info.left / canvasWidth, info.right / canvasWidth, 0, 1);
			elseif info.tileBoth then
				texture = path.."-Center.png";
				wrapModeHorizontal = "REPEAT";
				wrapModeVertical = "REPEAT";
				piece:SetSize(64, 64)
				piece:SetTexCoord(0, 1, 0, 1);
			else
				texture = path..".png";
				piece:SetTexCoord(info.left / canvasWidth, info.right / canvasWidth, info.top / canvasHeight, info.bottom / canvasHeight);
			end

			piece:SetTexture(texture, wrapModeHorizontal, wrapModeVertical);

			piece:SetHorizTile(info.tileHorizontal or info.tileBoth);
			piece:SetVertTile(info.tileVertical or info.tileBoth);

			-- DisableSharpening
			piece:SetTexelSnappingBias(0);
			piece:SetSnapToPixelGrid(false);
		end
	end

	self:GetParent().CloseButton:ClearAllPoints();

	local CloseButton = self:GetParent().CloseButton;
	if CloseButton then
		CloseButton:ClearAllPoints();
		CloseButton:SetPoint("TOPRIGHT", self:GetParent(), "TOPRIGHT", 1, 1);
	end

	self.theme = theme;
end

---@param offset number Positive value expands the frame
function Eavesdropper_NineSliceFrameMixin:SetOffset(offset)
	self:ClearAllPoints();
	self:SetPoint("TOPLEFT", self:GetParent(), "TOPLEFT", -offset, offset);
	self:SetPoint("BOTTOMRIGHT", self:GetParent(), "BOTTOMRIGHT", offset, -offset);
end

function Eavesdropper_NineSliceFrameMixin:OnLoad()
	self:SetOffset(8);
	self:SetTheme("Forever");
	self:GetParent().BackgroundOverlay.InnerShadow:SetTexture("Interface/AddOns/Eavesdropper/Resources/SettingsPanelInnerShadow.png");
	--BackgroundOverlay.BackgroundColor:SetColorTexture(0.12, 0.12, 0.12, 0.95);
	self:GetParent().CloseButton:SetScript("OnClick", function()
		self:GetParent():Hide();
	end);
	self:ShowDebugButtons();
end

function Eavesdropper_NineSliceFrameMixin:ShowDebugButtons()
	if not self.debugButtons then
		self.debugButtons = {};

		local function Button_OnClick(f)
			self:SetTheme(f.theme);
			self:UpdateDebugButtons();
		end

		local function Button_OnEnter(f)
			f:SetAlpha(1);
		end

		local function Button_OnLeave(f)
			f:SetAlpha(0.8);
		end

		local function CreateTextButton(theme)
			local f = CreateFrame("Button", nil, self);
			f:SetSize(24, 24);
			f.Text = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
			f.Text:SetText(theme);
			f.Text:SetPoint("CENTER", f, "CENTER", 0, 0);
			f:SetWidth(f.Text:GetWrappedWidth() + 16);
			f.theme = theme;
			f:SetScript("OnClick", Button_OnClick);
			f:SetScript("OnEnter", Button_OnEnter);
			f:SetScript("OnLeave", Button_OnLeave);
			Button_OnLeave(f);
			table.insert(self.debugButtons, f);
			return f;
		end

		local lastButton;
		for theme in pairs(ThemeLayout) do
			local f = CreateTextButton(theme);
			if lastButton then
				f:SetPoint("LEFT", lastButton, "RIGHT", 0, 0);
			else
				f:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 8);
			end
			lastButton = f;
		end

		local ShadowToggle = CreateTextButton("Shadow OFF");
		ShadowToggle.isShadowToggle = true;
		ShadowToggle:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 8);
		ShadowToggle:SetScript("OnClick", function()
			local InnerShadow = self:GetParent().BackgroundOverlay.InnerShadow;
			InnerShadow:SetShown(not InnerShadow:IsShown());
			self:UpdateDebugButtons();
		end);
	end

	self:UpdateDebugButtons();
end

function Eavesdropper_NineSliceFrameMixin:UpdateDebugButtons()
	if self.debugButtons then
		for _, button in ipairs(self.debugButtons) do
			if button.theme == self.theme then
				button.Text:SetTextColor(1, 1, 1);
			else
				button.Text:SetTextColor(1, 0.82, 0);
			end

			if button.isShadowToggle then
				if self:GetParent().BackgroundOverlay.InnerShadow:IsShown() then
					button.Text:SetText("Shadow |cffffffffON|r");
				else
					button.Text:SetText("Shadow |cffffffffOFF|r");
				end
			end
		end
	end
end
