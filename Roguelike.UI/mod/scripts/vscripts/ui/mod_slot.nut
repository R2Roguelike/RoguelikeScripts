global function ModSlot_DisplayMod

void function ModSlot_DisplayMod( var slot, RoguelikeMod ornull mod )
{
    Hud_SetVisible( Hud_GetChild(slot, "Overlay"), false )
    var icon = Hud_GetChild(slot, "ModIcon")

    if (mod == null)
    {
        Hud_SetVisible( Hud_GetChild(slot, "ModIcon"), false )
        Hud_SetVisible( Hud_GetChild(slot, "Cost"), false )
        Hud_SetVisible( Hud_GetChild(slot, "FloppyDisk"), false )
        Hud_SetVisible( Hud_GetChild(slot, "Button"), false )
        
        return
    }

    Hud_SetVisible( Hud_GetChild(slot, "Button"), true )
    expect RoguelikeMod( mod )

    if (mod.uniqueName == "empty")
    {
        Hud_SetImage( icon, mod.icon )
        Hud_SetColor( icon, 255, 255, 255, 128 )
        Hud_SetVisible( icon, true )
        Hud_SetVisible( Hud_GetChild(slot, "Cost"), false )
        Hud_SetVisible( Hud_GetChild(slot, "FloppyDisk"), false )

        return
    }

    var costLabel = Hud_GetChild(slot, "Cost")

    Hud_SetVisible( Hud_GetChild(slot, "FloppyDisk"), true )
    Hud_SetVisible( costLabel, true )
    Hud_SetVisible( icon, true )

    Hud_SetText( costLabel, string( mod.cost ) )
    Hud_SetImage( icon, mod.icon )
    Hud_SetColor( icon, 255, 255, 255, 255 )
}