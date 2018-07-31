DEFINE_BASECLASS( "player_element" )

local player = {}

player.WalkSpeed = 300
player.Icon = Material("element/classes/fire.png")
player.Color = _COLOR.WHITE
player.Sound = "taikos1"
player.Track = "fast"

player.skills = {}
player.skills[KEY_Q] = "fire_ball"
player.skills[KEY_E] = "fire_dragon"
player.skills[KEY_LSHIFT] = "fire_dash"
player.skills[MOUSE_LEFT] = "fire_shot"
player.skills[MOUSE_RIGHT] = "fire_kick"

if SERVER then
    resource.AddWorkshop( 473426738 ) --mkx
    resource.AddWorkshop( 431813760 ) --shao
end

player.models = {}
table.insert(player.models, {model = "models/player/shao_jun.mdl"})
table.insert(player.models, {model = "models/player/bobert/mkxkenshi.mdl"})

player_manager.RegisterClass("player_fire", player, "player_element")