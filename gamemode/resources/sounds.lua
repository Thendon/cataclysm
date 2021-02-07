local path, prefix, name
local formats = { ".mp3", ".wav" }
local format = formats[2]
local LEVELS = {}
LEVELS.LOUD = 130
LEVELS.AHHH = 100
LEVELS.NORM = 80
LEVELS.SHHH = 60

//EARTH
path = "element/fx/earth/"
prefix = "earth_"

name = "hit"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1.0,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "hit2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1.0,
	level = LEVELS.LOUD,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "hit3"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 0.25,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "summon"
sound.Add({
	name = prefix .. name,
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = LEVELS.LOUD,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "summon2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = LEVELS.LOUD,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "gather"
sound.Add({
	name = prefix .. name,
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = LEVELS.LOUD,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "grow"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1.0,
	level = LEVELS.LOUD,
	pitch = 100,
	sound = path .. name .. format
})

name = "woosh"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1.0,
	level = LEVELS.AHHH,
	pitch = { 150, 200 },
	sound = path .. name .. format
})

name = "woosh2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1.0,
	level = LEVELS.AHHH,
	pitch = { 150, 200 },
	sound = path .. name .. format
})

//FIRE
path = "element/fx/fire/"
prefix = "fire_"

name = "hit"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1.0,
	level = LEVELS.LOUD,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "hit2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1.0,
	level = LEVELS.LOUD,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "hit3"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1.0,
	level = LEVELS.LOUD,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "shot"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1.0,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "shot2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1.0,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "explode"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 0.5,
	level = LEVELS.LOUD,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "explode2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1.0,
	level = LEVELS.LOUD,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "engine"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1.0,
	level = LEVELS.LOUD,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "ignite"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1.0,
	level = LEVELS.LOUD,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "burst"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 0.4,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "burning"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 0.4,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

//AIR
path = "element/fx/air/"
prefix = "air_"

name = "move"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.LOUD,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "push"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "push2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "smooth"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "storm"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 0.25,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "storm2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 0.25,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

//WATER
path = "element/fx/water/"
prefix = "water_"

name = "shot"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "shot2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "shot3"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "shot4"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "stream"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "stream2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "stream3"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "waves"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

//WATER
path = "element/fx/misc/"
prefix = ""

name = "hit0"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "hit1"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "hit2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "hit3"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "hit4"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "hit5"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "hit6"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "swing1"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "swing2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "swing3"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "swing4"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1,
	level = LEVELS.AHHH,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "taikos0"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.SHHH,
	pitch = 100,
	sound = path .. name .. format
})

name = "taikos1"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.SHHH,
	pitch = 100,
	sound = path .. name .. format
})

name = "taikos2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = LEVELS.SHHH,
	pitch = 100,
	sound = path .. name .. format
})