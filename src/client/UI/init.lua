--|| Game Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--|| Modules ||--
local UIModule = require(ReplicatedStorage.Packages.uiModule)

--|| Create Store ||--
local function loadReducers(folder: Instance)
	for _, R in folder:GetChildren() do
		UIModule:AddReducer(R.Name, require(R))
	end
end

loadReducers(script.Store.Reducers)
UIModule:CreateStore()

--|| Create Applications ||--
local function loadApplications(folder: Instance)
	for _, A in folder:GetChildren() do
		UIModule:AddFrame(A.Name, A)
	end
end

loadApplications(script.Apps)
UIModule:CreateApplication()

--|| Synchronize Services & Reducers ||--
require(script.Store.Synchronization).init()

return true
