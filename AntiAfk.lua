--Anti AFK by Scoopy

function OnLoad()
print("AntiAFK Loaded")
Menu()
end

function OnTick()
AntiAFKSystem()
end

function Menu()
Config = scriptConfig("Anti AFK By Scoopy", "antiafksc")
Config:addParam("antisc", "Anti AFK On/Off", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("N"))
end

function AntiAFKSystem()
  if Config.antisc then
myHero:MoveTo(myHero.x, myHero.z)
  end
end
