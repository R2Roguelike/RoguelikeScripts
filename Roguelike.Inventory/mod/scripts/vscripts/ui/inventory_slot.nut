untyped
global function InventorySlot_Display

void function InventorySlot_Display( var slot, var content )
{
    var bg = Hud_GetChild( slot, "BG" )
    var icon = Hud_GetChild( slot, "Icon" )
    var energyBarPilot = Hud_GetChild( slot, "EnergyBar2" )
    var energyBarTitan = Hud_GetChild( slot, "EnergyBar1" )
    var slotLabel = Hud_GetChild(slot, "SlotLabel")
    Hud_SetVisible( slotLabel, false )

    Hud_SetLocked( Hud_GetChild(slot, "Button"), content == null )
    if (content == null)
    {
        bg.SetColor( [0,0,0,135] )
        Hud_SetImage( icon, $"vgui/hud/empty" )
        Hud_SetBarProgress( energyBarPilot, 0.0 )
        Hud_SetBarProgress( energyBarTitan, 0.0 )
        Hud_SetColor( icon, 255, 255, 255, 255 )

        return
    }

    expect table( content )

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
        case RARITY_MYTHIC:
            bg.SetColor( [255, 64, 64,255] )
            break
        case RARITY_STELLAR:
            bg.SetColor( [255, 64, 64,255] )
            break
        case RARITY_RADIANT:
            bg.SetColor( [255, 255, 255, 255] )
            break
    }

    Hud_SetHeight( icon, ContentScaledYAsInt(56) )
    Hud_SetWidth( icon, ContentScaledYAsInt(56) )

    int segmentCount = Roguelike_GetItemMaxLevel( content )
    Hud_SetVisible( energyBarPilot, segmentCount > 0 )
    Hud_SetVisible( energyBarTitan, segmentCount > 0 )
    if (segmentCount > 0)
    {
        int length = Hud_GetWidth( energyBarPilot )
        int gap = segmentCount - length % segmentCount
        if (gap < 1)
            gap = (segmentCount - length % segmentCount) + segmentCount
        int segmentWidth = (length + gap) / segmentCount - gap

        Hud_SetBarSegmentInfo( energyBarPilot, gap, segmentWidth )
        Hud_SetBarSegmentInfo( energyBarTitan, gap, segmentWidth )

        Hud_SetBarProgress( energyBarPilot, expect int(content.level) / float(Roguelike_GetItemMaxLevel( content ))  )
        Hud_SetBarProgress( energyBarTitan, 1 )
    }

    switch (content.type)
    {
        case "datacore":
            Hud_SetColor( icon, 255, 255, 255, 255 )
            Hud_SetHeight( icon, ContentScaledYAsInt(100) )
            Hud_SetWidth( icon, ContentScaledYAsInt(100) )
            Hud_SetImage( icon, $"vgui/spinner_frozen" )
            break
        case "armor_chip":
            bool isTitan = expect bool(content.isTitan)
            Hud_SetImage( icon, isTitan ? $"ui/armor_chip_titan" : $"ui/armor_chip_pilot" )
            Hud_SetColor( icon, 25, 25, 25, 255 )
            Hud_SetVisible( slotLabel, true )

            int slot = expect int(content.slot)
            Hud_SetSize( slotLabel, ContentScaledXAsInt(26), ContentScaledYAsInt(26) )
            Hud_SetPos( slotLabel, 0, 0 )
            switch (slot)
            {
                case 1:
                    Hud_SetImage( slotLabel, $"ui/shield" )
                    break
                case 2:
                    Hud_SetImage( slotLabel, $"ui/wrench" )
                    Hud_SetPos( slotLabel, 1, 0 ) // makes it look actually aligned
                    break
                case 3:
                    // note, this  slightly breaks the square pallette in favor of accessibility
                    Hud_SetImage( slotLabel, $"ui/ammo" )
                    Hud_SetSize( slotLabel, ContentScaledXAsInt(30), ContentScaledYAsInt(30) ) // this one has too much padding in the source image, im unbothered to re-export so hack
                    break
                case 4:
                    Hud_SetImage( slotLabel, $"ui/cooldown" )
                    break
            }
            int color = isTitan ? slot : 5 - slot
            switch (color)
            {
                case 1:
                    Hud_SetColor( slotLabel, 0, 214, 255, 255 )
                    break
                case 2:
                    Hud_SetColor( slotLabel, 165, 255, 0, 255 )
                    break
                case 3:
                    Hud_SetColor( slotLabel, 197, 0, 255, 255 )
                    break
                case 4:
                    Hud_SetColor( slotLabel, 255, 117, 0, 255 )
                    break
            }
            break
        case "weapon":
            Hud_SetHeight( icon, ContentScaledYAsInt(40) )
            Hud_SetWidth( icon, ContentScaledYAsInt(80) )
        case "grenade":
            if (!IsFullyConnected())
                break
            
            Hud_SetColor( icon, 255, 255, 255, 255 )
            Hud_SetImage( icon, GetWeaponInfoFileKeyFieldAsset_Global( content.weapon, "hud_icon" ) )
            Hud_SetColor( slotLabel, 25, 25, 25, 255 )
            break
    }
}