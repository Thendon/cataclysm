local seqs = {}
local anim = {}

table.insert(seqs, Sequence( 1801, 0.05, 0, 1 ))
table.insert(seqs, Sequence( 1801, 0.1, 1, 1 ))
table.insert(seqs, Sequence( 1801, 0.2, 1, 0 ))
table.insert(seqs, Sequence( 1797, 0.02, 0, 1 ))
table.insert(seqs, Sequence( 1797, 0.1, 1, 1 ))
table.insert(seqs, Sequence( 1797, 0.1, 1, 0 ))
table.insert(seqs, Sequence( 1, 1, 0, 0 ))

anim = Animation( seqs, 1 )

AnimationManager.Add( "shoot_stone", anim )

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

local hits = {"hit0", "hit1", "hit2", "hit3", "hit4", "hit5", "hit6"}
local swings = {"swing1", "swing2", "swing4"}

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