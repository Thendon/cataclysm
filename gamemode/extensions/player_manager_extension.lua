

if SERVER then
    netstream.Hook("player_manager:RequestClassSwitch", function( ply, class )
        ply:SetClassPick( class )
    end)
end

if CLIENT then
    function player_manager.RequestClassSwitch( class )
        local currentClass = player_manager.GetPlayerClass(LocalPlayer())
        if (currentClass == class) then return end
        if (currentClass == LocalPlayer():GetClassPick()) then return end

        netstream.Start("player_manager:RequestClassSwitch", class)
        LocalPlayer():SetClassPick( class )
    end
end