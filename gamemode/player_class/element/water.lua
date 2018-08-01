DEFINE_BASECLASS( "player_element" )

local player = {}

player.WalkSpeed = 300
player.Icon = Material("element/classes/water.png", "unlitgeneric")
player.Color = _COLOR.BLUE
player.Sound = "taikos1"
player.Track = "fast"
player.Health = 200

player.skills = {}
player.skills[KEY_Q] = "water_drown"
player.skills[KEY_E] = "water_shield"
player.skills[KEY_LSHIFT] = "water_surf"
player.skills[MOUSE_LEFT] = "water_shot"
player.skills[MOUSE_RIGHT] = "water_heal"

if SERVER then
    resource.AddWorkshop( 1211334981 ) --ninja
    resource.AddWorkshop( 780889405 ) --cultist
end

player.models = {}
table.insert(player.models, {model = "models/vinrax/player/ninja_player.mdl"})
table.insert(player.models, {model = "models/player/jka_cultist.mdl", details = {skin = 2}})

player_manager.RegisterClass("player_water", player, "player_element")