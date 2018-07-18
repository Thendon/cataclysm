local fire_dmg = DamageType("fire")
fire_dmg:SetParticleEffect("element_fire_hit")

function fire_dmg:HitEffect( ent )
    --if SERVER then ent:Ignite(1, 0) end
end

skill_manager.RegisterDamageType( fire_dmg )