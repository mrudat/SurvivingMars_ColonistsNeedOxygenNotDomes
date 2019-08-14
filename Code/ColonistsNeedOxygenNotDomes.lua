local orig_print = print
if Mods.mrudat_TestingMods then
  print = orig_print
else
  print = empty_func
end

local CurrentModId = rawget(_G, 'CurrentModId') or rawget(_G, 'CurrentModId_X')
local CurrentModDef = rawget(_G, 'CurrentModDef') or rawget(_G, 'CurrentModDef_X')
if not CurrentModId then

  -- copied shamelessly from Expanded Cheat Menu
  local Mods, rawset = Mods, rawset
  for id, mod in pairs(Mods) do
    rawset(mod.env, "CurrentModId_X", id)
    rawset(mod.env, "CurrentModDef_X", mod)
  end

  CurrentModId = CurrentModId_X
  CurrentModDef = CurrentModDef_X
end

orig_print("loading", CurrentModId, "-", CurrentModDef.title)

function Dome:VdfZ0nh_RecalculateColonistConsumption()
  print("Recalculating colonist consumption for", self.name)

  local colonist_count = #self.labels.Colonist

  local base_dome = getmetatable(self)

  local base_electricity_consumption = base_dome.electricity_consumption
  local base_air_consumption = base_dome.air_consumption
  local base_water_consumption = base_dome.water_consumption

  if CurrentModOptions.Disable then
    self:SetBase('electricity_consumption', base_electricity_consumption)
    self:SetBase('air_consumption', base_air_consumption)
    self:SetBase('water_consumption', base_water_consumption)
    return
  end

  local power_per_colonist = CurrentModOptions.PowerPerColonist

  local electricity_consumption = base_electricity_consumption
  local air_consumption = base_air_consumption
  local water_consumption = base_water_consumption

  if base_air_consumption == base_water_consumption then
    local air_and_water_per_colonist = CurrentModOptions.AirAndWaterPerColonist

    electricity_consumption = base_electricity_consumption - MulDivRound(base_water_consumption, power_per_colonist, air_and_water_per_colonist) + (colonist_count * power_per_colonist)

    local air_and_water_consumption = colonist_count * air_and_water_per_colonist

    water_consumption = air_and_water_consumption
    air_consumption = air_and_water_consumption
  elseif base_air_consumption == 0 then
    local water_per_geoscape_colonist = CurrentModOptions.WaterPerGeoscapeColonist

    electricity_consumption = base_electricity_consumption - MulDivRound(base_water_consumption, power_per_colonist, water_per_geoscape_colonist) + (colonist_count * power_per_colonist)

    water_consumption = colonist_count * water_per_geoscape_colonist
  else
    print("TODO")
  end

  if self.disable_electricity_consumption > 0 then
    electricity_consumption = 0
  end
  if self.disable_air_consumption > 0 or BreathableAtmosphere then
    air_consumption = 0
  end
  if self.disable_water_consumption > 0 then
    water_consumption = 0
  end

  print({
    colonists = colonist_count,
    base = {
      electricity = base_electricity_consumption,
      air = base_air_consumption,
      water = base_water_consumption
    },
    new = {
      electricity = electricity_consumption,
      air = air_consumption,
      water = water_consumption
    }
  })

  self:SetBase("electricity_consumption", electricity_consumption)
  self:SetBase("air_consumption", air_consumption)
  self:SetBase("water_consumption", water_consumption)
end

local function Reapply()
  if not UICity then return end
  for _, dome in pairs(UICity.labels.Dome) do
    dome:Notify("VdfZ0nh_RecalculateColonistConsumption")
  end
end

OnMsg.LoadGame = Reapply
OnMsg.BreathableAtmosphereChanged = Reapply

local function ColonistMovement(colonist, dome)
  dome:Notify("VdfZ0nh_RecalculateColonistConsumption")
end

OnMsg.ColonistLeavesDome = ColonistMovement
OnMsg.ColonistJoinsDome = ColonistMovement

function OnMsg.ConstructionComplete(building)
  if IsKindOf(building, "Dome") then
    building:Notify("VdfZ0nh_RecalculateColonistConsumption")
  end
end

function OnMsg.ApplyModOptions(id)
  if id ~= 'VdfZ0nh' then return end
  Reapply()
end

function SavegameFixups.VdfZ0nh_RemoveModifiersFromOldMethod()
  local properties = {
    'electricity_consumption',
    'air_consumption',
    'water_consumption'
  }
  for _, dome in pairs(UICity.labels.Dome) do
    for _, property in ipairs(properties) do
      local modifier = dome:FindModifier("VdfZ0nh", property)
      if modifier then
        dome:UpdateModifier("remove", modifier, -modifier.amount, -modifier.percent)
      end
    end
  end
end

orig_print("loaded", CurrentModId, "-", CurrentModDef.title)
