local path, prefix, name
local quality = ".wav"

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
	sound = path .. name .. quality
})

name = "hit2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 130,
	pitch = { 95, 110 },
	sound = path .. name .. quality
})

name = "hit3"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 0.5,
	level = 130,
	pitch = { 95, 110 },
	sound = path .. name .. quality
})

name = "summon"
sound.Add({
	name = prefix .. name,
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 130,
	pitch = { 95, 110 },
	sound = path .. name .. quality
})

name = "summon2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 130,
	pitch = { 95, 110 },
	sound = path .. name .. quality
})

name = "gather"
sound.Add({
	name = prefix .. name,
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 130,
	pitch = { 95, 110 },
	sound = path .. name .. quality
})

name = "grow"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 130,
	pitch = 100,
	sound = path .. name .. quality
})

name = "woosh"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 100,
	pitch = { 150, 200 },
	sound = path .. name .. quality
})

name = "woosh2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 100,
	pitch = { 150, 200 },
	sound = path .. name .. quality
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
	sound = path .. name .. quality
})

name = "hit2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 80,
	pitch = { 95, 110 },
	sound = path .. name .. quality
})

name = "hit3"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 80,
	pitch = { 95, 110 },
	sound = path .. name .. quality
})

name = "shot"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 130,
	pitch = { 95, 110 },
	sound = path .. name .. quality
})

name = "shot2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 130,
	pitch = { 95, 110 },
	sound = path .. name .. quality
})

name = "explode"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 130,
	pitch = { 95, 110 },
	sound = path .. name .. quality
})

name = "explode2"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 130,
	pitch = { 95, 110 },
	sound = path .. name .. quality
})

name = "burst"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 130,
	pitch = { 95, 110 },
	sound = path .. name .. quality
})

name = "burning"
sound.Add({
	name = prefix .. name,
	channel = CHAN_ITEM,
	volume = 1.0,
	level = 130,
	pitch = { 95, 110 },
	sound = path .. name .. quality
})

//AIR
path = "element/fx/air/"
prefix = "air_"

//WATER
path = "element/fx/water/"
prefix = "water_"