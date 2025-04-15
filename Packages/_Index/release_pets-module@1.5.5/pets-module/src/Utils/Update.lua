local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Settings

local function GetAnimationOffset(TimeElapsed, PetMovement, Model)
	local Speed, MaxHeight, ForwardAngle, BackwardAngle

	if PetMovement == "Fly" then
		Speed = Settings.FlySpeed
		MaxHeight = Settings.FlyMaxHeight
		ForwardAngle = Settings.FlyForwardAngle
		BackwardAngle = Settings.FlyBackwardAngle
	elseif PetMovement == "Walk" then
		Speed = Settings.GroundSpeed
		MaxHeight = Settings.GroundMaxHeight
		ForwardAngle = Settings.GroundForwardAngle
		BackwardAngle = Settings.GroundBackwardAngle
	end

	local SinTime = math.sin(TimeElapsed * Speed)
	local NewHeight = SinTime * MaxHeight

	local NewRotation
	if NewHeight >= 0 then
		NewRotation = SinTime * ForwardAngle
	else
		NewRotation = SinTime * BackwardAngle
	end

	if PetMovement == "Fly" then
		NewHeight = NewHeight + 4.3
	elseif PetMovement == "Walk" then
		NewHeight = math.abs(NewHeight)
	end

	local AnimationLeft = true
	if PetMovement == "Walk" then
		if NewHeight > 0.15 then
			AnimationLeft = true
		else
			AnimationLeft = false
			NewRotation = 0
			NewHeight = 0
		end
	end

	return {
		Rotation = CFrame.fromOrientation(NewRotation, 0, 0),
		Height = NewHeight + (Model:GetAttribute("HeighOffset") or 0),
		AnimationLeft = AnimationLeft,
	}
end

local function GetPositionOffset(Grid, Info)
	local TotalOffset
	local XOffset
	local ZOffset
	if Info.Farming == true then
		XOffset = math.cos(0)
	else
		XOffset = ((Grid.Column - (Grid.TotalColumns + 1) / 2) * Settings.XSpacing)
		ZOffset = (
			Settings.PlayerSpacing
			+ -(-(Grid.Row - (Grid.TotalRows + 1) / 2) * Settings.ZSpacing - (Grid.TotalRows / 2) * Settings.ZSpacing)
		)
	end
	TotalOffset = CFrame.new(XOffset, 0, ZOffset)
	return TotalOffset
end

local function GetRaycastOffset(LastPosition, Target, RaycastExcludeModels)
	local YOffset
	local TempPosition = Vector3.new(LastPosition.Position.X, Target.Position.Y + 5, LastPosition.Position.Z)

	local RayParams = RaycastParams.new()
	RayParams.FilterDescendantsInstances = { RaycastExcludeModels }
	RayParams.FilterType = Enum.RaycastFilterType.Exclude

	local GroundFound = Workspace:Raycast(TempPosition, Vector3.new(0, -200, 0), RayParams)
	if GroundFound and GroundFound.Instance then
		YOffset = GroundFound.Position.Y
	else
		YOffset = LastPosition.Position.Y
	end
	return YOffset
end

local function UpdatePets(
	Delta,
	Functions,
	PetsInSession,
	PetsModule,
	PetInstances,
	RaycastExcludeModels,
	FollowDisabledPlayers,
	UserSettings
)
	local PetsToMove = { ["Pets"] = {}, ["CFrames"] = {} }
	Settings = UserSettings

	for i, v in pairs(PetsInSession) do
		if Functions.GetTableAmount(v) > 0 and not table.find(FollowDisabledPlayers, i) then
			for i2, v2 in pairs(v) do
				if v2.Information.Target ~= nil then
					--// References
					local Grid = v2
					local PetData = v2.PetData
					local Info = Grid.Information
					local LastInfo = Grid.LastInformation

					local PetInfo = PetsModule[PetData.Name]
					local Humanoid = Players[i.Name].Character:WaitForChild("Humanoid")

					--// Create pet models
					if
						not PetInstances:FindFirstChild(i.Name .. "_" .. tostring(i2))
						or type(Grid.Model) == "string"
					then
						local PetModel = Functions.GetPetModel(PetData, Functions.ModelsPath)
						if PetModel == nil then
							continue
						end
						PetModel = PetModel:Clone() :: Model
						Grid.Model = PetModel

						PetModel:SetAttribute("Owner", i.Name)
						PetModel:SetAttribute("Pet", Grid.Model.Name)

						local TempPositionOffset = GetPositionOffset(Grid, Info)
						TempPositionOffset = CFrame.new((Info.Target.CFrame * TempPositionOffset).Position)
						TempPositionOffset = TempPositionOffset - Vector3.new(0, TempPositionOffset.Position.Y, 0)

						PetModel:ScaleTo(PetModel:GetScale() / 1.4)
						PetModel.Name = i.Name .. "_" .. tostring(i2)
						--PetModel.Anchored = true
						--PetModel.CanCollide = false
						PetModel:PivotTo(TempPositionOffset)

						PetModel.Parent = PetInstances

						table.insert(RaycastExcludeModels, PetModel)
					end

					table.insert(PetsToMove.Pets, Grid.Model)

					if Grid.Model == "" then
						continue
					end

					--// How time elapsed works

					--[[
                        If animation is still running then the current time elapsed increases
                        otherwise we change it to 0 so when the next math.sin runs it will start
                        at 0
                    ]]

					--// Pet animation

					local AnimationTime = (PetInfo.Movement == "Walk" and Grid.TimeElapsed) or os.clock()
					local AnimationInfo = GetAnimationOffset(
						AnimationTime,
						PetInfo.Movement,
						PetInstances:FindFirstChild(i.Name .. "_" .. tostring(i2))
					)
					local AnimationPositionLerp = LastInfo.AnimationPosition
					local AnimationRotationLerp = LastInfo.AnimationRotation

					if AnimationInfo.AnimationLeft == true or Info.Arrived == false then
						Grid.TimeElapsed = Grid.TimeElapsed + Delta
					else
						Grid.TimeElapsed = 0
					end

					if
						Info.Arrived == false
						or AnimationInfo.AnimationLeft == true
						or (AnimationInfo.Height == 0 and LastInfo.AnimationHeight ~= 0)
						or PetInfo.Movement == "Fly"
					then
						local AnimationHeightDistance = (Vector3.new(0, AnimationInfo.Height, 0) - Vector3.new(
							0,
							LastInfo.AnimationHeight,
							0
						)).Magnitude
						local AnimationSpeed = math.clamp((100 / AnimationHeightDistance) * Delta, 0, 1)
						AnimationPositionLerp = LastInfo.AnimationPosition:Lerp(
							CFrame.new(0, AnimationInfo.Height + (Grid.Model:GetExtentsSize().Y / 2), 0),
							AnimationSpeed
						)
						AnimationRotationLerp = LastInfo.AnimationRotation:Lerp(AnimationInfo.Rotation, AnimationSpeed)
					end

					--// Pet Positions

					if LastInfo.Position == nil then
						LastInfo.Position =
							CFrame.new(Grid.Model:GetPivot().Position.X, 0, Grid.Model:GetPivot().Position.Z)
					end

					local PositionOffset = GetPositionOffset(Grid, Info)
					PositionOffset = CFrame.new((Info.Target.CFrame * PositionOffset).Position)
					PositionOffset = PositionOffset - Vector3.new(0, PositionOffset.Position.Y, 0)

					local PositionDistance = (PositionOffset.Position - LastInfo.Position.Position).Magnitude
					local PositionSpeed = math.clamp((PetData.Speed / PositionDistance) * Delta, 0, 1)
					local PositionLerp = LastInfo.Position:Lerp(PositionOffset, PositionSpeed)
					local DistanceCheck = (
						(PositionLerp.Position - Vector3.new(0, PositionLerp.Position.Y, 0))
						- PositionOffset.Position
					).Magnitude

					local CharacterMoved = (Humanoid.MoveDirection.Magnitude > 0 and true) or false

					if CharacterMoved == true or DistanceCheck > 0.001 then
						Info.Arrived = false
					elseif DistanceCheck <= 0.001 then
						Info.Arrived = true
					end

					--// Raycast
					local RaycastHeight
					local RaycastLerp

					if LastInfo.Raycast == nil then
						LastInfo.Raycast = CFrame.new(0, PositionLerp.Position.Y, 0)
					end

					local AbsoluteTime = os.clock()
					if LastInfo.NextRaycastTime == nil or AbsoluteTime >= LastInfo.NextRaycastTime then
						LastInfo.NextRaycastTime = AbsoluteTime + 0.3
						LastInfo.RaycastHeight = GetRaycastOffset(PositionLerp, Info.Target, RaycastExcludeModels)
					end

					RaycastHeight = LastInfo.RaycastHeight

					local RaycastDistance = (Vector3.new(0, RaycastHeight, 0) - Vector3.new(
						0,
						LastInfo.Raycast.Position.Y,
						0
					)).Magnitude
					local RaycastDistanceSpeed = (RaycastDistance > 50 and 1000) or Settings.RaycastSpeed
					local RaycastLerpSpeed = math.clamp((RaycastDistanceSpeed / RaycastDistance) * Delta, 0, 1)
					RaycastLerp = LastInfo.Raycast:Lerp(CFrame.new(0, RaycastHeight, 0), RaycastLerpSpeed)

					--// Pet Orientation

					local PetOrientation

					if DistanceCheck <= 5 then
						local ConnectedAxis =
							math.atan2(Info.Target.CFrame.LookVector.X, Info.Target.CFrame.LookVector.Z)
						ConnectedAxis = ConnectedAxis + math.rad(180)
						PetOrientation = CFrame.fromOrientation(0, ConnectedAxis, 0)
					else
						local TempPosition1 = PositionLerp.Position - Vector3.new(0, PositionLerp.Position.Y, 0)
						local TempPosition2 = PositionOffset.Position - Vector3.new(0, PositionOffset.Position.Y, 0)
						PetOrientation = CFrame.lookAt(TempPosition1, TempPosition2)
						PetOrientation = PetOrientation - PetOrientation.Position
					end

					local OrientationSpeed = math.clamp(
						(250 / Functions.GetAngleDistance(PetOrientation, LastInfo.Orientation)) * Delta,
						0,
						1
					)
					local OrientationLerp = LastInfo.Orientation:Lerp(PetOrientation, OrientationSpeed)

					--// Calculate Final Rotations

					local _, YOrientationLerp, _ = OrientationLerp:ToOrientation()
					local XAnimationLerp, _, _ = AnimationRotationLerp:ToOrientation()

					local FinalOrientation = CFrame.fromOrientation(XAnimationLerp, YOrientationLerp, 0)

					local Offset = -(
						PetInstances:FindFirstChild(i.Name .. "_" .. tostring(i2)):GetAttribute("Rotation") or 90
					)

					local XRotation = PetInstances:FindFirstChild(i.Name .. "_" .. tostring(i2))
						:GetAttribute("XRotation")

					local Final = (PositionLerp * RaycastLerp * AnimationPositionLerp * FinalOrientation)
						* CFrame.Angles(0, math.rad(Offset or 90), 0)
						* CFrame.Angles(XRotation and math.rad(XRotation) or 0, 0, 0)

					table.insert(PetsToMove.CFrames, Final)

					--// Update all the last variables

					LastInfo.Position = PositionLerp
					LastInfo.Raycast = RaycastLerp
					LastInfo.Distance = DistanceCheck
					LastInfo.AnimationPosition = AnimationPositionLerp
					LastInfo.AnimationRotation = AnimationRotationLerp
					LastInfo.AnimationHeight = AnimationInfo.Height
					LastInfo.Orientation = OrientationLerp
				end
			end
		end
	end
	for i, v in PetsToMove.Pets do
		v:PivotTo(PetsToMove.CFrames[i])
	end
end

return UpdatePets
