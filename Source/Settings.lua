class('Settings').extends()

-- Settings
--
-- Get and set settings available in the System Menu.
function Settings:init()

	Settings.super.init(self)
	self:initFromSave()
	self:addSystemMenuItems()
	return self

end

-- initFromSave()
--
function Settings:initFromSave()

	local data = playdate.datastore.read("settings")
	if data ~= nil then
		self.crank = false
		if data.crank == true then
			self.crank = true
		end
	else
		self.crank = true
	end

end

-- usesCrank()
--
-- Returns a boolean to enable/disable the crank.
function Settings:usesCrank()

	return self.crank

end

-- addSystemMenuItems()
--
function Settings:addSystemMenuItems()

	local menu = playdate.getSystemMenu()

	local crankMenuItem, error = menu:addCheckmarkMenuItem("Crank", self.crank, function(value)
		self.crank = value
		self:save()
	end)

end

-- save()
--
function Settings:save()

	local data = {}
	data.crank = self.crank
	playdate.datastore.write(data, "settings")

end
