_G.Popup = Popup or {}

Popup.queue = Popup.queue or {}

if CLIENT then
    local showTime = 3
    local fadeTime = 1

    function Popup.Add( message, color )
        table.insert( Popup.queue, { message = message, color = color } )
    end

    function Popup.ShowNext()
        if !Popup.queue[1] then return end
        local message = Popup.queue[1].message
        local w, h = 600, 100
        local derma = TDLib("DPanel")
        derma.death = CurTime() + showTime
        derma:SetSize( w, h )
        derma:SetPos( ScrW() * 0.5 - w * 0.5, ScrH() * 0.3 - h * 0.5 )
        derma:ClearPaint()
        --derma:Background(_COLOR.FADE_WHITE)
        derma:Blur()
        derma:Text(message, "fujimaru", Popup.queue[1].color or _COLOR.GREEN)
        derma:FadeIn()

        Popup.derma = derma

        table.remove( Popup.queue, 1 )
    end

    function Popup.Update()
        if IsValid(Popup.derma) then
            if Popup.derma.death + fadeTime < CurTime() then
                Popup.derma:Remove()
            elseif Popup.derma.death < CurTime() then
                local fraction = (CurTime() - Popup.derma.death) / fadeTime
                Popup.derma:SetAlpha(255 - fraction * 255)
            end
            return
        end
        Popup.ShowNext()
    end

    netstream.Hook("Popup:Add", function( message )
        Popup.Add( message )
    end)
end

if SERVER then
    function Popup.Add( ply, message )
        netstream.Start(ply, "Popup:Add", message)
    end
end