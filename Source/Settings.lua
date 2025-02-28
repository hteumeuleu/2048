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
		self.sounds = false
		if data.crank == true then
			self.crank = true
		end
		if data.sounds == true then
			self.sounds = true
		end
	else
		self.crank = true
		self.sounds = true
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
-- Returns a boolean to enable/disable sounds.
function Settings:usesSounds()

	return self.sounds

end

-- addSystemMenuItems()
--
function Settings:addSystemMenuItems()

	local menu = playdate.getSystemMenu()

	local crankMenuItem, error = menu:addCheckmarkMenuItem("Crank", self.crank, function(value)
		self.crank = value
		self:save()
	end)

	local soundsMenuItem, error = menu:addCheckmarkMenuItem("Sounds", self.sounds, function(value)
		self.sounds = value
		self:save()
	end)

end

-- save()
--
function Settings:save()

	local data = {}
	data.crank = self.crank
	data.sounds = self.sounds
	playdate.datastore.write(data, "settings")

end
