local path, prefix, name
local formats = { ".mp3", ".wav" }
local format = formats[2]

//EARTH
path = "element/fx/earth/"
prefix = "earth_"

name = "hit"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 130,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "hit2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 130,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "hit3"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 0.25,
	level = 100,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "summon"
sound.Add({
	name = prefix .. name,
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 130,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "summon2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 130,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "gather"
sound.Add({
	name = prefix .. name,
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 130,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "grow"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 130,
	pitch = 100,
	sound = path .. name .. format
})

name = "woosh"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 100,
	pitch = { 150, 200 },
	sound = path .. name .. format
})

name = "woosh2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 100,
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
	level = 80,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "hit2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 80,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "hit3"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 80,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "shot"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 130,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "shot2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 130,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "explode"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 0.5,
	level = 110,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "explode2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 130,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "burst"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 0.4,
	level = 100,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "burning"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 0.4,
	level = 100,
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
	level = 80,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "push"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1,
	level = 100,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "push2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1,
	level = 100,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "smooth"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = 100,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "storm"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = 100,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "storm2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = 100,
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
	level = 100,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "shot2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = 100,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "shot3"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = 100,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "shot4"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = 100,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "stream"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = 100,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "stream2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = 100,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "stream3"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = 100,
	pitch = { 95, 110 },
	sound = path .. name .. format
})

name = "waves"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1,
	level = 100,
	pitch = { 95, 110 },
	sound = path .. name .. format
})