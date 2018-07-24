_G.DamageType = DamageType or Class()

AccessorFunc( DamageType, "name", "Name", FORCE_STRING )
AccessorFunc( DamageType, "particleEffect", "ParticleEffect", FORCE_STRING )

function DamageType:_init( name )
    self.name = name
end

function DamageType:HitEffect( ent )
end

if SERVER then
    function DamageType:Hit( ent )
        netstream.Start(player.GetAll(), "DamageType:Hit", self.name, ent)
        self:HitEffect( ent )
    end
end

if CLIENT then
    function DamageType:Hit( ent )
        if (self.particleEffect) then
            CreateParticleSystem( ent, self.particleEffect, PATTACH_ABSORIGIN, 0, Vector( 0, 0, 50 ) )
        end
        self:HitEffect( ent )
    end

    netstream.Hook("DamageType:Hit", function( type, ent )
        local dmgType = skill_manager.GetDamageType( type )
        dmgType:Hit( ent )
    end)
end