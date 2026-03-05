local ffi = require ("ffi")
local C = ffi.C

local mapMenu = nil

local statetext = {}
local maintainancecost = {}

local maintainancedata = {}

local function Init()
  mapMenu = Helper.getMenu("MapMenu")
  RegisterEvent("MaintainanceCost_Initdata", maintainancecost.Initdata)
  RegisterEvent("MaintainanceCost_Cleardata", maintainancecost.Claerdata)
  mapMenu.registerCallback("createPropertyOwned_on_start", maintainancecost.createPropertyOwned_on_start)
  mapMenu.registerCallback("createPropertyOwned_on_init_infoTableData", maintainancecost.createPropertyOwned_on_init_infoTableData)
  mapMenu.registerCallback("createPropertyOwned_on_add_ship_infoTableData", maintainancecost.createPropertyOwned_on_add_ship_infoTableData)
  mapMenu.registerCallback("createPropertyOwned_on_createPropertySection_unassignedships", maintainancecost.createPropertyOwned_on_createPropertySection_unassignedships)
  mapMenu.registerCallback("createPropertyRow_override_row_location_createText", maintainancecost.createPropertyRow_override_row_location_createText)
  mapMenu.registerCallback("MtCst_map_shipInformation_newrowsafterboardingstrength", maintainancecost.setupInfoSubmenuRows_add_maintainancestate)
end


function maintainancecost.Initdata()
  local playerId = ConvertStringTo64Bit(tostring(C.GetPlayerID()))
  local mdtable = GetNPCBlackboard(playerId, "$maintainancecost_states")
  for ship, data in pairs(mdtable) do
    maintainancedata[ConvertStringTo64Bit(tostring(ship))] = {data[1], data[2]}
  end
  statetext = {ReadText(90105, 7024), Helper.convertColorToText(mapMenu.holomapcolor.lowalertcolor) .. ReadText(90105, 7025) .. "\027X", Helper.convertColorToText(mapMenu.holomapcolor.mediumalertcolor) .. ReadText(90105, 7026) .. "\027X", Helper.convertColorToText(mapMenu.holomapcolor.highalertcolor) .. ReadText(90105, 7027) .. "\027X"}
end


function maintainancecost.Claerdata()
  maintainancedata = {}
  statetext = {}
end


function maintainancecost.createPropertyOwned_on_start(config)
  local hastab = false
	for _, tab in ipairs (config.propertyCategories) do
		if tab.category == "maintainancecost_info" then
			hastab = true
		end
	end
	if not hastab then
		local loctab = {
			category = "maintainancecost_info",
			name = ReadText (90105, 7022),
			icon = "shipbuildst_repair",
			helpOverlayID = "map_sidebar_maintainancecostinfo",
			helpOverlayText = ReadText (90105, 7023)
		}
		table.insert (config.propertyCategories, loctab)
	end
end


function maintainancecost.createPropertyOwned_on_init_infoTableData(infoTableData)
  infoTableData.maintainancecostShips = {}
end


function maintainancecost.createPropertyOwned_on_add_ship_infoTableData(infoTableData, object)
  local object64 = ConvertStringTo64Bit(tostring(object))
  if (maintainancedata[object64] ~= nil) and (maintainancedata[object64][1] > 1 ) then
    table.insert(infoTableData.maintainancecostShips, object)
  end
end


function maintainancecost.createPropertyOwned_on_createPropertySection_unassignedships(numdisplayed, instance, ftable, infoTableData)
  if mapMenu.propertyMode == "maintainancecost_info" then
    numdisplayed = mapMenu.createPropertySection(instance, "maintainancecost_info", ftable, ReadText(90105, 7022), infoTableData.maintainancecostShips, "-- " .. ReadText(1001, 34) .. " --", nil, numdisplayed, true, mapMenu.propertySorterType)
  end
  return {numdisplayed = numdisplayed}
end


function maintainancecost.createPropertyRow_override_row_location_createText(locationtext, properties, component)
  local menu = mapMenu
	local mouseovertext = properties.mouseOverText
  local component64 = ConvertStringTo64Bit(tostring(component))
  if mapMenu.propertyMode == "maintainancecost_info" and maintainancedata[component64] then
    local maxhp = tostring(maintainancedata[component64][2])
    if statetext[maintainancedata[component64][1]] then
      locationtext = statetext[maintainancedata[component64][1]]
    else
      locationtext = ReadText(90105, 7028)
    end
    mouseovertext = ReadText(90105,7029) .. locationtext ..", " .. ReadText(90105, 7030) .. maxhp .. "%"
    if maintainancedata[component64][1] == 4 then
      mouseovertext = mouseovertext .. "\n" .. ReadText(90105, 7031)
    end
  end
  return {locationtext = locationtext, properties = {halign = "center", font = properties.font, mouseOverText = mouseovertext, x = properties.x}}
end


function maintainancecost.setupInfoSubmenuRows_add_maintainancestate(object, object64)
  local defenceinfo_high = C.IsInfoUnlockedForPlayer(object, "defence_status")
  local text
  if (defenceinfo_high and maintainancedata[object64] ~= nil and statetext[maintainancedata[object64][1]]) then
    text = statetext[maintainancedata[object64][1]]
  else
    text = ReadText(90105, 7028)
  end
  return { false, ReadText(90105, 7022) .. ReadText(1001, 120), text }	
end

Init()