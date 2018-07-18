local water_dmg = DamageType("water")
water_dmg:SetParticleEffect("element_water_hit")

function water_dmg:HitEffect( ent )
    //TODO distinguish fire
end

skill_manager.RegisterDamageType( water_dmg )