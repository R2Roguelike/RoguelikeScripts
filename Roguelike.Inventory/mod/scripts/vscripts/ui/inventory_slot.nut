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

    Hud_SetHeight( icon, ContentScaledYAsInt(56) )
    Hud_SetWidth( icon, ContentScaledYAsInt(56) )
    
    int segmentCount = Roguelike_GetItemMaxLevel( content )
    int length = Hud_GetWidth( energyBarPilot )
    printt(length)
    int gap = segmentCount - length % segmentCount
    printt(gap)
    if (gap < 1)
        gap = (segmentCount - length % segmentCount) + segmentCount
    int segmentWidth = (length + gap) / segmentCount - gap
    printt(segmentWidth)

    Hud_SetBarSegmentInfo( energyBarPilot, gap, segmentWidth )
    Hud_SetBarSegmentInfo( energyBarTitan, gap, segmentWidth )

    Hud_SetBarProgress( energyBarPilot, expect int(content.level) / float(segmentCount)  )
    Hud_SetBarProgress( energyBarTitan, 1 )

    switch (content.type)
    {
        case "armor_chip":
            switch (content.rarity)
            {
                case RARITY_COMMON:
                    bg.SetColor( [64,64,64,255] )
                    break
                case RARITY_UNCOMMON:
                    bg.SetColor( [21, 92, 16,255] )
                    break
                case RARITY_RARE:
                    bg.SetColor( [51, 105, 204,255] )
                    break
                case RARITY_EPIC:
                    bg.SetColor( [128, 51, 204,255] )
                    break
                case RARITY_LEGENDARY:
                    bg.SetColor( [255, 226, 64,255] )
                    break
            }
            Hud_SetImage( icon, $"ui/armor_chip" )
            Hud_SetColor( slotLabel, 25, 25, 25, 255 )
            float pilotEnergy = float( content.pilotEnergy ) / 15.0
            float titanEnergy = float( content.titanEnergy ) / 15.0
            
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
        case "weapon":
            if (!IsFullyConnected())
                break
            switch (content.rarity)
            {
                case RARITY_COMMON:
                    bg.SetColor( [64,64,64,255] )
                    break
                case RARITY_UNCOMMON:
                    bg.SetColor( [21, 92, 16,255] )
                    break
                case RARITY_RARE:
                    bg.SetColor( [51, 105, 204,255] )
                    break
                case RARITY_EPIC:
                    bg.SetColor( [128, 51, 204,255] )
                    break
                case RARITY_LEGENDARY:
                    bg.SetColor( [255, 226, 64,255] )
                    break
            }

            Hud_SetHeight( icon, ContentScaledYAsInt(40) )
            Hud_SetWidth( icon, ContentScaledYAsInt(80) )
            Hud_SetColor( icon, 255, 255, 255, 255 )
            Hud_SetText( slotLabel, "" )
            Hud_SetImage( icon, GetWeaponInfoFileKeyFieldAsset_Global( content.weapon, "hud_icon" ) )
            Hud_SetColor( slotLabel, 25, 25, 25, 255 )
            break
    }
}