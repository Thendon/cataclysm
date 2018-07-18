local air_dmg = DamageType("air")
air_dmg:SetParticleEffect("element_air_hit")

function air_dmg:HitEffect( ent )
    //TODO distinguish fire
end

skill_manager.RegisterDamageType( air_dmg )