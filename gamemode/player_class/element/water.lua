DEFINE_BASECLASS( "player_element" )

local player = {}

player.WalkSpeed = 200
player.RunSpeed = 400
player.Icon = Material("element/classes/water.png", "unlitgeneric")
player.Color = _COLOR.BLUE
player.skills = {}
player.skills[KEY_Q] = skill_manager.GetSkill("water_drown")
player.skills[KEY_E] = skill_manager.GetSkill("water_surf")
player.skills[KEY_R] = skill_manager.GetSkill("water_shield")
player.skills[MOUSE_LEFT] = skill_manager.GetSkill("water_shot")
player.skills[MOUSE_RIGHT] = skill_manager.GetSkill("water_heal")

player_manager.RegisterClass("player_water", player, "player_element")