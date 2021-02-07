local skill = Skill( "fire_dragon")
skill:SetDescription("Blow a constant fire stream on your enemies.")
skill:SetMaxLive( 2 )
skill:SetCooldown( 8 )

local damage = 10
local rate = 0.1
local range = 400

local col = Capsule(Vector(100,0,0), Vector(100,0,0), 50)
col:SetPos1Dest(Vector(100,0,0))
col:SetPos2Dest(Vector(range,0,0))

function skill:Stage1( ent )
    local caster = ent:GetCaster()

    if CLIENT and caster != LocalPlayer() then return end

    local forward = caster:GetAimVector() --caster:GetRight():Cross(_VECTOR.UP)
    ent:SetPos( _VECTOR.UP * 50 + caster:GetPos() )
    ent:SetAngles( forward:Angle() )

    if CLIENT then return end
    ent:GetCustomCollider():SetFraction(ent.alive * 2)
end

function skill:ActivationConditions( caster )
    return caster:WaterLevel() < 2
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("dragon")
        ent:EmitSound("fire_burst")
        ent:CreateParticleEffect("element_fire_flame_dragon2", 1)
        --ent:SetCustomCollider( Capsule( col ) )
    end
end

if SERVER then
    function skill:Spawn( ent, caster )
        ent:SetInvisible( true )
        ent:SetTriggerFlag( true )
        ent:SetTouchRate( rate )
        caster:Slow(1.4, 0.001)
        ent:SetCustomCollider( Capsule( col ) )
        ent:SetPos( _VECTOR.UP * 50 + caster:GetPos() )
        ent:SetAngles( caster:GetAimVector():Angle() )
    end

    function skill:OnRemove( ent )
        ent:StopSound("fire_burst")
    end

    function skill:Touch( ent, touched )
        self:Hit(ent, touched, damage, DMG_FALL, ent:GetForward())
    end
end

skill_manager.Register( skill )