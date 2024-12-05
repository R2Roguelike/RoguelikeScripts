untyped
global function InventorySlot_Display

void function InventorySlot_Display( var slot, var content )
{
    var bg = Hud_GetChild( slot, "BG" )
    var icon = Hud_GetChild( slot, "Icon" )
    var energyBarPilot = Hud_GetChild( slot, "EnergyBar2" )
    var energyBarTitan = Hud_GetChild( slot, "EnergyBar1" )
    var slotLabel = Hud_GetChild(slot, "SlotLabel")

    if (content == null)
    {
        bg.SetColor( [0,0,0,135] )
        Hud_SetImage( icon, $"vgui/hud/empty" )
        Hud_SetBarProgress( energyBarPilot, 0.0 )
        Hud_SetBarProgress( energyBarTitan, 0.0 )
        Hud_SetColor( icon, 255, 255, 255, 255 )
        Hud_SetText( slotLabel, "" )
        Hud_SetVisible( Hud_GetChild(slot, "Button"), false )

        return
    }

    Hud_SetVisible( Hud_GetChild(slot, "Button"), true )
    expect table( content )

    switch (content.type)
    {
        case "armor_chip":
            bg.SetColor( [0,0,0,135] )
            Hud_SetImage( icon, $"ui/armor_chip" )
            Hud_SetColor( slotLabel, 25, 25, 25, 255 )
            float pilotEnergy = float( content.pilotEnergy ) / 15.0
            float titanEnergy = float( content.titanEnergy ) / 15.0
            Hud_SetBarSegmentInfo( energyBarPilot, ContentScaledXAsInt( 2 ), ContentScaledXAsInt( 4 ) )
            Hud_SetBarSegmentInfo( energyBarTitan, ContentScaledXAsInt( 2 ), ContentScaledXAsInt( 4 ) )
            Hud_SetBarProgress( energyBarPilot, pilotEnergy )
            Hud_SetBarProgress( energyBarTitan, titanEnergy )
            switch (expect int( content.slot ))
            {
                case 1:
                    Hud_SetColor( icon, 0, 214, 255, 255 )
                    Hud_SetText( slotLabel, "A" )
                    break
                case 2:
                    Hud_SetColor( icon, 165, 255, 0, 255 )
                    Hud_SetText( slotLabel, "B" )
                    break
                case 3:
                    // note, this  slightly breaks the square pallette in favor of accessibility
                    Hud_SetColor( icon, 197, 0, 255, 255 )
                    Hud_SetColor( slotLabel, 255, 255, 255, 255 )
                    Hud_SetText( slotLabel, "C" )
                    break
                case 4:
                    Hud_SetColor( icon, 255, 117, 0, 255 )
                    Hud_SetText( slotLabel, "D" )
                    break
            }
            break
    }
}