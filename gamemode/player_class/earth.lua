DEFINE_BASECLASS( "player_element" )

local player = {}

player.WalkSpeed = 200
player.RunSpeed = 400
player.Icon = Material("element/classes/earth.png", "unlitgeneric")
player.Color = _COLOR.BROWN
player.skills = {}
player.skills[KEY_Q] = skill_manager.GetSkill("earth_bust")
player.skills[KEY_E] = skill_manager.GetSkill("earth_push")
player.skills[KEY_R] = skill_manager.GetSkill("earth_wall")
player.skills[MOUSE_LEFT] = skill_manager.GetSkill("earth_blast")
player.skills[MOUSE_RIGHT] = skill_manager.GetSkill("earth_boost")

player_manager.RegisterClass("player_earth", player, "player_element")