

local hits = {"hit0", "hit1", "hit2", "hit3", "hit4", "hit5", "hit6"}
local swings = {"swing1", "swing2", "swing4"}

local seqs = {}
local anim = {}

local seq = Sequence( 1635, 0.05, 0, 1 ) --1801
seq:SetSound(hits)
table.insert(seqs, seq)
table.insert(seqs, Sequence( 1635, 0.1, 1, 1 ))
table.insert(seqs, Sequence( 1635, 0.2, 1, 0 ))
local seq = Sequence( 1797, 0.05, 0, 1 )
seq:SetSound(hits)
table.insert(seqs, seq)
table.insert(seqs, Sequence( 1797, 0.1, 1, 1 ))
table.insert(seqs, Sequence( 1797, 0.1, 1, 0 ))
table.insert(seqs, Sequence( 1, 1, 0, 0 ))

anim = Animation( seqs, 1 )

AnimationManager.Add( "shoot_stone", anim )

local seqs = {}
local anim = {}

local id = 1651
local val = 1
local seq = Sequence( id, 0.15, 0, val )
seq:SetSound(hits)
table.insert(seqs, seq)
table.insert(seqs, Sequence( id, 0.1, val, val ))
table.insert(seqs, Sequence( id, 0.25, val, 0 ))
anim = Animation( seqs, 1 )

AnimationManager.Add( "shoot_stone2", anim )

local seqs = {}
local anim = {}

local id = 1625 --1788
local val = 0.8
local seq = Sequence( id, 0.25, 0, val )
seq:SetSound(hits)
table.insert(seqs, seq)
table.insert(seqs, Sequence( id, 0.25, val, 0.2 ))
table.insert(seqs, Sequence( id, 0.25, 0.2, val ))
table.insert(seqs, Sequence( id, 0.25, val, 0.2 ))
table.insert(seqs, Sequence( id, 0.25, 0.2, 0 ))
anim = Animation( seqs, 1 )

AnimationManager.Add( "summon_earth", anim )

seqs = {}
anim = {}

local id = 1670
local val = 0.5
local timetill = 0.15
local timerest = 2 - 2 * timetill
table.insert(seqs, Sequence( id, timetill, 0, val ))
table.insert(seqs, Sequence( id, timerest, val, val ))
table.insert(seqs, Sequence( id, timetill, val, 0 ))

anim = Animation( seqs, 1 )

AnimationManager.Add( "handcuffed", anim )

seqs = {}
anim = {}

local id = 1798
local seq = Sequence( id, 0.05, 0, 1 )
seq:SetSound(hits)
table.insert(seqs, seq)
table.insert(seqs, Sequence( id, 0.15, 1, 1 ))
table.insert(seqs, Sequence( id, 0.15, 1, 0.5 ))
table.insert(seqs, Sequence( id, 10, 0.4, 0.4 ))
table.insert(seqs, Sequence( id, 0.5, 0.4, 0 ))

anim = Animation( seqs, 1 )

AnimationManager.Add( "shoot_fire1", anim )

seqs = {}
anim = {}

local id = 1801
local seq = Sequence( id, 0.05, 0, 1 )
seq:SetSound(hits)
table.insert(seqs, seq)
table.insert(seqs, Sequence( id, 0.15, 1, 1 ))
table.insert(seqs, Sequence( id, 0.15, 1, 0 ))
table.insert(seqs, Sequence( 1798, 0.05, 0, 0.4 ))
table.insert(seqs, Sequence( 1798, 10, 0.4, 0.4 ))
table.insert(seqs, Sequence( 1798, 0.15, 0.4, 0 ))

anim = Animation( seqs, 1 )

AnimationManager.Add( "shoot_fire2", anim )

seqs = {}
anim = {}

local id = 1649
local val = 1
table.insert(seqs, Sequence( id, 0.15, 0, val ))
table.insert(seqs, Sequence( id, 0.5, val, val ))
table.insert(seqs, Sequence( id, 0.15, val, 0 ))

anim = Animation( seqs, 1 )

AnimationManager.Add( "dash_fire", anim )

seqs = {}
anim = {}

local id = 2004
local val = 1
local seq = Sequence( id, 0.15, 0, val )
seq:SetSound(swings)
table.insert(seqs, seq)
table.insert(seqs, Sequence( id, 0.15, val, 0 ))

anim = Animation( seqs, 1 )

AnimationManager.Add( "kick_fire", anim )

seqs = {}
anim = {}

local id = 1683--1683, 1676, 1680
local val = 1
table.insert(seqs, Sequence( id, 0.15, 0, val ))
table.insert(seqs, Sequence( id, 1.25, val, val ))
table.insert(seqs, Sequence( id, 0.25, val, 0 ))

anim = Animation( seqs, 1 )

AnimationManager.Add( "dragon", anim )

seqs = {}
anim = {}

local id = 1660
local seq = Sequence( id, 0.05, 0, 1 )
seq:SetSound(hits)
table.insert(seqs, seq)
table.insert(seqs, Sequence( id, 0.15, 1, 1 ))
table.insert(seqs, Sequence( id, 0.15, 1, 0 ))

anim = Animation( seqs, 1 )

AnimationManager.Add( "shoot_air", anim )

seqs = {}
anim = {}

local id = 1652
local seq = Sequence( id, 0.05, 0, 1 )
seq:SetSound(hits)
table.insert(seqs, seq)
table.insert(seqs, Sequence( id, 0.15, 1, 1 ))
table.insert(seqs, Sequence( id, 0.15, 1, 0 ))
local id = 1657
local seq = Sequence( id, 0.15, 0, 1 )
seq:SetSound(hits)
table.insert(seqs, seq)
table.insert(seqs, Sequence( id, 0.15, 1, 1 ))
table.insert(seqs, Sequence( id, 0.15, 1, 0 ))

anim = Animation( seqs, 1 )

AnimationManager.Add( "summon_air", anim )

seqs = {}
anim = {}

local id = 1652
local seq = Sequence( id, 0.15, 0, 1 )
seq:SetSound(hits)
table.insert(seqs, seq)
table.insert(seqs, Sequence( id, 0.15, 1, 0 ))
local id = 1657
local seq = Sequence( id, 0.15, 0, 1 )
seq:SetSound(hits)
table.insert(seqs, seq)
table.insert(seqs, Sequence( id, 0.15, 1, 0 ))

anim = Animation( seqs, 1 )

AnimationManager.Add( "summon_air2", anim )

seqs = {}
anim = {}

local id = 1651
local val = 0.8
table.insert(seqs, Sequence( id, 0.5, 0, val ))
table.insert(seqs, Sequence( id, 10, val, val ))
table.insert(seqs, Sequence( id, 0.5, val, 0 ))

anim = Animation( seqs, 1 )

AnimationManager.Add( "fly", anim )

seqs = {}
anim = {}

local id = 1705
local val = 0.8
table.insert(seqs, Sequence( id, 0.5, 0, val ))
table.insert(seqs, Sequence( id, 10, val, val ))
table.insert(seqs, Sequence( id, 0.5, val, 0 ))

anim = Animation( seqs, 1 )

AnimationManager.Add( "fly2", anim )

seqs = {}
anim = {}

local id = 2002
local seq = Sequence( id, 0.05, 0, 1 )
seq:SetSound(hits)
table.insert(seqs, seq)
table.insert(seqs, Sequence( id, 0.15, 1, 1 ))
table.insert(seqs, Sequence( id, 0.15, 1, 0 ))
local id = 1791
local seq = Sequence( id, 0.05, 0, 1 )
seq:SetSound(hits)
table.insert(seqs, seq)
table.insert(seqs, Sequence( id, 0.15, 1, 1 ))
table.insert(seqs, Sequence( id, 0.15, 1, 0 ))

anim = Animation( seqs, 1 )

AnimationManager.Add( "shoot_water", anim )

seqs = {}
anim = {}

local id = 1789
local seq = Sequence( id, 0.05, 0, 1 )
seq:SetSound(hits)
table.insert(seqs, seq)
table.insert(seqs, Sequence( id, 0.15, 1, 1 ))
table.insert(seqs, Sequence( id, 0.15, 1, 0 ))
local id = 1789
local seq = Sequence( id, 0.05, 0, 1 )
seq:SetSound(hits)
table.insert(seqs, seq)
table.insert(seqs, Sequence( id, 0.15, 1, 1 ))
table.insert(seqs, Sequence( id, 0.15, 1, 0 ))
local id = 1789
local seq = Sequence( id, 0.05, 0, 1 )
seq:SetSound(hits)
table.insert(seqs, seq)
table.insert(seqs, Sequence( id, 0.15, 1, 1 ))
table.insert(seqs, Sequence( id, 0.15, 1, 0 ))
local id = 1680
local val = 0.6
local seq = Sequence( id, 0.05, 0, val )
seq:SetSound(hits)
table.insert(seqs, seq)
table.insert(seqs, Sequence( id, 3, val, val ))
table.insert(seqs, Sequence( id, 3, val, 0 ))

anim = Animation( seqs, 1 )

AnimationManager.Add( "summon_water", anim )

seqs = {}
anim = {}

local id = 1693
local val = 0.6
local seq = Sequence( id, 0.05, 0, val )
seq:SetSound(hits)
table.insert(seqs, seq)
table.insert(seqs, Sequence( id, 1, val, val ))
table.insert(seqs, Sequence( id, 0.15, val, 0 ))
local id = 1789
local val = 0.75
local seq = Sequence( id, 0.35, 0, val )
seq:SetSound(swings)
table.insert(seqs, seq)
table.insert(seqs, Sequence( id, 0.25, val, val ))
table.insert(seqs, Sequence( id, 0.25, val, 0 ))

anim = Animation( seqs, 1 )

AnimationManager.Add( "summon_water2", anim )

seqs = {}
anim = {}

local id = 1789
local val = 0.6
local seq = Sequence( id, 0.05, 0, val )
seq:SetSound(hits)
table.insert(seqs, seq)
table.insert(seqs, Sequence( id, 10, val, val ))
table.insert(seqs, Sequence( id, 1, val, 0 ))
anim = Animation( seqs, 1 )

AnimationManager.Add( "stream_water", anim )
