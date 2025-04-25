untyped
global function ModSlot_DisplayMod

void function ModSlot_DisplayMod( var slot, RoguelikeMod ornull mod )
{
    Hud_SetVisible( Hud_GetChild(slot, "Overlay"), false )
    Hud_SetVisible( Hud_GetChild(slot, "Abbreviation"), false )
    Hud_SetColor( Hud_GetChild(slot, "BG"), 0,0,0, 135 )

    var icon = Hud_GetChild(slot, "ModIcon")
    var floppyDisk = Hud_GetChild(slot, "FloppyDisk")
    string loadout = "generic"

    floppyDisk.SetColor(GetTitanColor("generic"))

    if (mod == null)
    {
        Hud_SetVisible( slot, false )
        Hud_SetVisible( Hud_GetChild(slot, "ModIcon"), false )
        Hud_SetVisible( Hud_GetChild(slot, "Cost"), false )
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
        Hud_SetVisible( Hud_GetChild(slot, "Cost"), false )
        Hud_SetVisible( Hud_GetChild(slot, "FloppyDisk"), false )

        return
    }

    Hud_SetImage( icon, $"vgui/hud/empty" )

    if (mod.loadouts.len() == 1)
        loadout = mod.loadouts[0]
    
    var costLabel = Hud_GetChild(slot, "Cost")

    Hud_SetVisible( Hud_GetChild(slot, "FloppyDisk"), true )
    floppyDisk.SetColor(GetTitanColor(loadout))
    Hud_SetVisible( costLabel, true )
    Hud_SetVisible( icon, false )

    Hud_SetText( costLabel, string( mod.cost ) )
    Hud_SetVisible( Hud_GetChild(slot, "Abbreviation"), true )
    Hud_SetText( Hud_GetChild(slot, "Abbreviation"), mod.abbreviation )
    Hud_SetColor( icon, 255, 255, 255, 255 )
}