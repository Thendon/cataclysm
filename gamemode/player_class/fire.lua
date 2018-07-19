DEFINE_BASECLASS( "player_element" )

local player = {}

player.WalkSpeed = 300
player.RunSpeed = 400
player.Icon = Material("element/classes/fire.png", "unlitgeneric")
player.Color = _COLOR.RED
player.skills = {}
player.skills[KEY_Q] = skill_manager.GetSkill("fire_ball")
player.skills[KEY_E] = skill_manager.GetSkill("earth_push")
player.skills[KEY_R] = skill_manager.GetSkill("fire_dash")
player.skills[MOUSE_LEFT] = skill_manager.GetSkill("fire_shot")
player.skills[MOUSE_RIGHT] = skill_manager.GetSkill("fire_kick")

player_manager.RegisterClass("player_fire", player, "player_element")