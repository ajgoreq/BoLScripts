--Anti AFK by Scoopy

function OnLoad()
print("AntiAFK Loaded")
Menu()
end

function OnTick()
AntiAFKSystem()
end

function Menu()
  Clock = os.clock()
Config = scriptConfig("Anti AFK By Scoopy", "antiafksc")
Config:addParam("antisc", "Anti AFK On/Off", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("N"))
end

function AntiAFKSystem()
   if os.clock() < Clock or not Config.antisc then return end
    Clock = os.clock() + math.random(60,120)
myHero:MoveTo(myHero.x, myHero.z)
  end
end
