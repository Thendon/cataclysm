GM.Name = "Cataclysm"
GM.Author = "Thendon.exe"
GM.Email = "so 2000"
GM.Website = "sneaky.rocks"

DeriveGamemode( "base" )

include("sh_loader.lua")

function GM:CreateTeams()
	team.SetUp( 1, "Black", _COLOR.BLACK, true)
	team.SetClass( 1, { "player_earth", "player_fire", "player_air", "player_water" } )

	team.SetUp( 2, "White", _COLOR.WHITE, true)
	team.SetClass( 2, { "player_earth", "player_fire", "player_air", "player_water" } )
end

function GM:PlayerInitialSpawn( ply )
	ply:SetModel("models/player/Group01/male_07.mdl")
end