untyped
global function VGUIButton_Init
global function VGUIButton_OnClick

table<var, void functionref( var )> callbacks

void function VGUIButton_Init( var panel )
{
    var button = Hud_GetChild( panel, "Button" )
    var bg = Hud_GetChild( panel, "BG" )
    var label = Hud_GetChild( panel, "Label" )
    Hud_AddEventHandler( button, UIE_CLICK, OnClick )
    Hud_AddEventHandler( button, UIE_GET_FOCUS, OnGetFocus )
    Hud_AddEventHandler( button, UIE_LOSE_FOCUS, OnLoseFocus )

    array<var> elements = [bg, label, button]
    foreach (var elem in elements)
    {
        Hud_SetWidth( elem, Hud_GetWidth( panel ) )
        Hud_SetHeight( elem, Hud_GetHeight( panel ) )
    }
}

void function VGUIButton_OnClick( var panel, void functionref( var ) callback )
{
    callbacks[panel] <- callback
}

void function OnClick( var button )
{
    var panel = Hud_GetParent( button )
    if (panel in callbacks)
        callbacks[panel]( panel )
}

void function OnGetFocus( var button )
{
    var panel = Hud_GetParent( button )
        
    Hud_GetChild( panel, "BG" ).SetColor( 220, 220, 220, 255 )
    Hud_GetChild( panel, "Label" ).SetColor( 25, 25, 25, 255 )
}

void function OnLoseFocus( var button )
{
    var panel = Hud_GetParent( button )

    Hud_GetChild( panel, "BG" ).SetColor( 0, 0, 0, 128 )
    Hud_GetChild( panel, "Label" ).SetColor( 255, 255, 255, 255 )
}
