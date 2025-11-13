untyped
global function ModSlot_DisplayMod

void function ModSlot_DisplayMod( var slot, bool isTitan, RoguelikeMod ornull mod )
{
    var icon = Hud_GetChild(slot, "ModIcon")
    var bg = Hud_GetChild(slot, "BG")
    var floppyDisk = Hud_GetChild(slot, "FloppyDisk")

    Hud_SetVisible( Hud_GetChild(slot, "Overlay"), false )
    Hud_SetVisible( Hud_GetChild(slot, "Abbreviation"), false )
    Hud_SetColor( Hud_GetChild(slot, "BG"), 0,0,0, 135 )
    Hud_SetImage( bg, isTitan ? $"ui/titan_mod_3" : $"ui/pilot_mod_3")
    Hud_SetImage( Hud_GetChild(slot, "Overlay"), isTitan ? $"ui/titan_mod_3" : $"ui/pilot_mod_3")

    floppyDisk.SetColor(GetTitanColor("generic"))

    if (mod == null)
    {
        Hud_SetVisible( slot, false )
        Hud_SetVisible( Hud_GetChild(slot, "ModIcon"), false )
        Hud_SetVisible( Hud_GetChild(slot, "FloppyDisk"), false )
        Hud_SetVisible( Hud_GetChild(slot, "Button"), false )

        return
    }

    Hud_SetVisible( slot, true )
    Hud_SetVisible( Hud_GetChild(slot, "Button"), true )
    expect RoguelikeMod( mod )


    if (mod.uniqueName == "empty")
    {
        Hud_SetImage( icon, mod.icon )
        Hud_SetColor( icon, 255, 255, 255, 128 )
        Hud_SetVisible( icon, true )
        Hud_SetVisible( Hud_GetChild(slot, "FloppyDisk"), false )

        return
    }

    Hud_SetImage( icon, $"vgui/hud/empty" )


    Hud_SetVisible( Hud_GetChild(slot, "FloppyDisk"), true )
    asset image = StringToAsset( (isTitan ? "ui/titan" : "ui/pilot") + "_mod_" + mod.cost )
    Hud_SetImage( floppyDisk, image )
    floppyDisk.SetColor(GetModColor(mod))

    asset bgImage = $"vgui/hud/empty"
    switch (mod.cost)
    {
        case 0:
            bgImage = StringToAsset( (isTitan ? "ui/titan" : "ui/pilot") + "_mod_3" )
            break;
        case 1:
            bgImage = StringToAsset( (isTitan ? "ui/titan" : "ui/pilot") + "_mod_2" )
            break;
        case 2:
            bgImage = StringToAsset( (isTitan ? "ui/titan" : "ui/pilot") + "_mod_1" )
            break;
    }
    
    Hud_SetImage( bg, bgImage )
    Hud_SetVisible( icon, false )

    Hud_GetChild(slot, "Abbreviation").SetColor( GetModColor(mod) )
    Hud_SetVisible( Hud_GetChild(slot, "Abbreviation"), true )
    Hud_SetText( Hud_GetChild(slot, "Abbreviation"), mod.abbreviation )
    Hud_SetColor( icon, 255, 255, 255, 255 )
}
