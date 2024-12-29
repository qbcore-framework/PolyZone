local function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return tostring(math.floor(num * mult + 0.5) / mult)
end

local header = function(zone)
  local name = zone.name
  local date = os.date("!%Y-%m-%dT%H:%M:%SZ")
  return ("--Name: %s | %s"):format(name, date)
end

local center = function(zone)
  return ("vector3(%s, %s, %s)"):format(round(zone.center.x), round(zone.center.y), round(zone.center.z))
end

local parse = {

  poly = function(zone)
    local name = zone.name
    local date = os.date("!%Y-%m-%dT%H:%M:%SZ")
    local template = "%s\nPolyZone:Create({\n%s},{\n%s\n})\n"

    local pointsString = ""
    for i = 1, #zone.points do
      pointsString = ("%s  vector2(%s, %s)%s\n"):format(pointsString, tostring(zone.points[i].x), tostring(zone.points[i].y), i ~= #zone.points and "," or "")
    end

    local optionsString = ("  name=\"%s\",\n  --minZ = %s,\n  --maxZ = %s, \n  debugPoly = false"):format(name, zone.minZ, zone.maxZ)

    return template:format(header(zone), pointsString, optionsString)
  end,

  circle = function(zone)
    local name = zone.name
    local date = os.date("!%Y-%m-%dT%H:%M:%SZ")
    local template = "%s\nCircleZone:Create(%s, %s, {\n name=\"%s\",\n useZ=%s,\n debugPoly = false\n})\n"
    
    return template:format(header(zone), center(zone), round(zone.radius), name, tostring(zone.useZ))
  end,

  box = function(zone)
    local name = zone.name
    local date = os.date("!%Y-%m-%dT%H:%M:%SZ")
    local template = "%s\nBoxZone:Create(%s, %s, %s, {\n name=\"%s\",\n heading=%s,\n debugPoly = false%s%s\n})\n"

    local minZ = zone.minZ and (",\n minZ=" .. round(zone.minZ)) or ""
    local maxZ = zone.maxZ and (",\n maxZ=" .. round(zone.maxZ)) or ""

    return template:format(header(zone), center(zone), tostring(zone.length), tostring(zone.width), name, tostring(zone.heading), minZ, maxZ)
  end
}

local function addToTxtFile(value)
  local file = LoadResourceFile(GetCurrentResourceName(), "polyzone_created_zones.txt") or ""
  file = ("%s\n%s"):format(file, value)
  local success = SaveResourceFile(GetCurrentResourceName(), "polyzone_created_zones.txt", file, -1)
  print(("PolyZone: %s"):format(success and "Added to file" or "Failed to add to file"))
end

RegisterNetEvent("polyzone:save", function(zone_type, zone)
  addToTxtFile(parse[zone_type](zone))
end)