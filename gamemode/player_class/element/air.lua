DEFINE_BASECLASS( "player_element" )

local player = {}

player.WalkSpeed = 500
player.Icon = Material("element/classes/air.png", "unlitgeneric")
player.Color = _COLOR.WHITE
player.Sound = "taikos2"
player.Track = "calm"
player.Health = 100

player.skills = {}
player.skills[KEY_Q] = "air_storm"
player.skills[KEY_E] = "air_shield"
player.skills[KEY_LSHIFT] = "air_fly"
player.skills[MOUSE_LEFT] = "air_push"
player.skills[MOUSE_RIGHT] = "air_move"


if SERVER then
    resource.AddWorkshop( 1197003940 ) --guard
    resource.AddWorkshop( 919610543 ) --jedi
end

player.models = {}
table.insert(player.models, {model = "models/joshbotts/temple_guard/temple_guard.mdl"})
table.insert(player.models, {model = "models/players/femalejedi.mdl"})

player_manager.RegisterClass("player_air", player, "player_element")