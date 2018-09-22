local settings = {}

--how many wins are needed until map change (5 wins mean 10 rounds at max)
settings.wins = 5
--time to load up the game
settings.warmupTime = 2 * 60
--time to choose your class
settings.prepTime = 1 * 10
--time to fight
settings.roundTime = 3 * 60
--time to laugh at the loosers
settings.overTime = 1 * 15
--time after a team won (mapvote)
settings.gameoverTime = 60

--Default map rotation
--I would recommend ulx and some mapvote addon
--Voting should be called at the end of the match
--if no command given the map rotation will be used
settings.mapvoteCommand = ""
--maps will rotate through all exisintg txt files (maps with spawn points)
settings.rotateTxtFiles = true
--if rotateTxtFiles is set false, this list will be used
settings.rotateMapsOverride = {
    "gm_uldum2",
    "gm_floatingworlds_3",
    "gm_isles",
    "gm_dunes",
    --"001_nanshansi_shishi" --CSS CONTENT but spawns
}

_G.CataSettings = settings