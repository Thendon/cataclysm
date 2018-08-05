_G.KillLog = KillLog or {}

KillLog.slots = KillLog.slots or {}

local showTime = 3
local fadeTime = 1
local worldKill = Material("element/skills/world.png")

function KillLog.GetFreeSlot()
    local max = table.Count(KillLog.slots) + 1
    for i = 1, max do
        if !KillLog.slots[i] then return i end
    end
    return max
end

function KillLog.Add( victim, attacker, inflictor )
    local teamColor = GAMEMODE:GetEnemyTeamColor(victim)

    local index = KillLog.GetFreeSlot()

    local w, h = 576, 64 --640, 64
    local o = 16
    local y = o + (index - 1) * ( o + h )

    local derma = TDLib("DPanel")
    derma.death = CurTime() + showTime
    derma:SetSize( w, h )
    derma:SetPos( ScrW() - w - o, y)
    derma:ClearPaint()
    derma:FadeIn()

    local vic = TDLib("DPanel", derma)
    vic:SetSize( w * 0.5 - h, h )
    vic:ClearPaint()
    vic:Text(victim:GetName(), "fujimaru_tiny", teamColor)

    if (inflictor) then
        local skill = skill_manager.GetSkill(inflictor)
        local icon = (skill != nil and skill.icon) or (inflictor == "world" and worldKill)

        if icon or inflictor == "world" then
            local img = TDLib("DImage", derma)
            img:SetSize( h, h )
            img:SetPos( w * 0.5 - h * 0.5, 0 )
            img:SetMaterial(icon)
        else
            local atk = TDLib("DPanel", derma)
            atk:SetSize( h * 2, h)
            atk:SetPos( w * 0.5 - h * 0.5, 0 )
            atk:ClearPaint()
            atk:Text(inflictor, "fujimaru_tiny", _COLOR.GREEN)
        end
    end

    if (IsValid(attacker) and attacker:IsPlayer()) then
        local inf = TDLib("DPanel", derma)
        inf:SetSize( w * 0.5 - h, h)
        inf:SetPos( w * 0.5 + h, 0 )
        inf:ClearPaint()
        inf:Text(attacker:GetName(), "fujimaru_tiny", teamColor)
    end

    KillLog.slots[index] = derma
end

function KillLog.Update()
    for k, derma in next, KillLog.slots do
        if !IsValid(derma) then
            KillLog.slots[k] = nil
            continue
        end

        if derma.death + fadeTime < CurTime() then
            derma:Remove()
            KillLog.slots[k] = nil
        elseif derma.death < CurTime() then
            local fraction = (CurTime() - derma.death) / fadeTime
            derma:SetAlpha(255 - fraction * 255)
        end
    end
end

netstream.Hook("DeathMessage", function( victim, attacker, inflictor )
    if !IsValid(victim) or victim:IsSpectator() then return end
    KillLog.Add( victim, attacker, inflictor )
end)