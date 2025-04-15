local CONFIGURATION_MODULE_NAME = "GroupRewardsModule.config"
local CONFIG_MODULE_PATH = `Shared/Configs/{CONFIGURATION_MODULE_NAME}`

local IS_IN_GROUP_REFRESH_TIME = 60

local ASSETS_PATH = `Shared/Assets/Trails`

return {
	Path = {
		Config = CONFIG_MODULE_PATH,
		Assets = ASSETS_PATH,
	},
	Variables = {
		IsInGroupRefreshTime = IS_IN_GROUP_REFRESH_TIME,
	},
}
