DEFINE_BASECLASS( "player_element" )

local player = {}

player.WalkSpeed = 200
player.Icon = Material("element/classes/earth.png", "unlitgeneric")
player.Color = _COLOR.BROWN
player.Sound = "taikos0"
player.Track = "heavy"
player.Health = 250

player.skills = {}
player.skills[KEY_Q] = "earth_bust"
player.skills[KEY_E] = "earth_wall"
player.skills[KEY_LSHIFT] = "earth_boost"
player.skills[MOUSE_LEFT] = "earth_blast"
player.skills[MOUSE_RIGHT] = "earth_push"

if SERVER then
    resource.AddWorkshop( 176540879 ) --guards
    resource.AddWorkshop( 1359912576 ) --jedi
end

player.models = {}
table.insert(player.models, {model = "models/player/guard_whiterun.mdl"})
table.insert(player.models, {model = "models/gonzo/femalejedi/padawan/padawan.mdl", details = {body = { id = 1, value = 1 }}})

player_manager.RegisterClass("player_earth", player, "player_element")