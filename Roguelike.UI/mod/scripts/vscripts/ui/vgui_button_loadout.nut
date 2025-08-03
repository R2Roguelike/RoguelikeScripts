untyped
global function VGUIButtonLoadout_Init
global function VGUIButtonLoadout_OnClick
global function VGUIButtonLoadout_SetText
global function VGUIButtonLoadout_SetState
global function VGUIButtonLoadout_GetState
global function VGUIButtonLoadout_SetDescriptionText

global enum eVGUIButtonLoadoutState
{
    None,
    Selected,
    Locked,
    Disabled
}

table<var, void functionref( var )> callbacks

void function VGUIButtonLoadout_Init( var panel )
{
    var button = Hud_GetChild( panel, "Button" )
    var bg = Hud_GetChild( panel, "BG" )
    var label = Hud_GetChild( panel, "Label" )
    var goldBorder = Hud_GetChild( panel, "GoldBorder" )
    var overlay = Hud_GetChild( panel, "Overlay" )
    var lock = Hud_GetChild( panel, "Lock" )
    panel.s.state <- eVGUIButtonLoadoutState.None
    Hud_SetVisible( goldBorder, false )
    Hud_SetVisible( overlay, false )
    Hud_SetVisible( lock, false )
    overlay.SetColor( 0, 0, 0, 192 )
    Hud_AddEventHandler( button, UIE_GET_FOCUS, OnGetFocus )
    Hud_AddEventHandler( button, UIE_LOSE_FOCUS, OnLoseFocus )
    Hud_AddEventHandler( button, UIE_CLICK, OnClick )

    array<var> elements = [bg, goldBorder, overlay, button]
    foreach (var elem in elements)
    {
        Hud_SetWidth( elem, Hud_GetWidth( panel ) )
        Hud_SetHeight( elem, Hud_GetHeight( panel ) )
    }
}

void function VGUIButtonLoadout_SetText( var panel, string text )
{
    var label = Hud_GetChild( panel, "Label" )

    Hud_SetText( label, text )
}

void function VGUIButtonLoadout_OnClick( var panel, void functionref( var ) callback )
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

    Hud_GetChild( panel, "Overlay" ).SetVisible( false )
    Hud_GetChild( panel, "Lock" ).SetVisible( false )
    Hud_GetChild( panel, "GoldBorder" ).SetVisible( false )
    Hud_SetLocked( button, false )
    Hud_SetNew( button, false )
    switch (panel.s.state)
    {
        case eVGUIButtonLoadoutState.None:
            Hud_GetChild( panel, "BG" ).SetColor( 220, 220, 220, 255 )
            Hud_GetChild( panel, "Label" ).SetColor( 25, 25, 25, 255 )
            Hud_GetChild( panel, "Value" ).SetColor( 25, 25, 25, 255 )
            Hud_SetNew( button, true )
            break
        case eVGUIButtonLoadoutState.Selected:
            Hud_GetChild( panel, "BG" ).SetColor( 219, 157, 0, 255 )
            Hud_GetChild( panel, "Label" ).SetColor( 0, 0, 0, 255 )
            Hud_GetChild( panel, "Value" ).SetColor( 0, 0, 0, 255 )
            Hud_SetNew( button, true )
            break
        case eVGUIButtonLoadoutState.Locked:
            Hud_GetChild( panel, "Lock" ).SetVisible( true )
        case eVGUIButtonLoadoutState.Disabled:
            Hud_SetLocked( button, true )
            Hud_GetChild( panel, "BG" ).SetColor( 220, 220, 220, 255 )
            Hud_GetChild( panel, "Label" ).SetColor( 25, 25, 25, 255 )
            Hud_GetChild( panel, "Overlay" ).SetVisible( true )
            break
    }
}

void function OnLoseFocus( var button )
{
    var panel = Hud_GetParent( button )

    Hud_GetChild( panel, "Overlay" ).SetVisible( false )
    Hud_GetChild( panel, "Lock" ).SetVisible( false )
    Hud_GetChild( panel, "GoldBorder" ).SetVisible( false )
    Hud_SetLocked( button, false )
    switch (panel.s.state)
    {
        case eVGUIButtonLoadoutState.None:
            Hud_GetChild( panel, "BG" ).SetColor( 0, 0, 0, 128 )
            Hud_GetChild( panel, "Label" ).SetColor( 255, 255, 255, 255 )
            Hud_GetChild( panel, "Value" ).SetColor( 255, 255, 255, 255 )
            break
        case eVGUIButtonLoadoutState.Selected:
            Hud_GetChild( panel, "BG" ).SetColor( 0, 0, 0, 128 )
            Hud_GetChild( panel, "Label" ).SetColor( 219, 157, 0, 255 )
            Hud_GetChild( panel, "Value" ).SetColor( 219, 157, 0, 255 )
            Hud_GetChild( panel, "GoldBorder" ).SetVisible( true )
            break
        case eVGUIButtonLoadoutState.Locked:
            Hud_GetChild( panel, "Lock" ).SetVisible( true )
        case eVGUIButtonLoadoutState.Disabled:
            Hud_GetChild( panel, "BG" ).SetColor( 0, 0, 0, 128 )
            Hud_GetChild( panel, "Label" ).SetColor( 255, 255, 255, 255 )
            Hud_GetChild( panel, "Overlay" ).SetVisible( true )
            Hud_SetLocked( button, true )
            break
    }
}

void function VGUIButtonLoadout_SetState( var panel, int state )
{
    var button = Hud_GetChild( panel, "Button" )

    panel.s.state = state

    if (Hud_IsFocused( button ))
        OnGetFocus( button )
    else
        OnLoseFocus( button )
}

void function VGUIButtonLoadout_SetDescriptionText( var panel, string value )
{
    var valueText = Hud_GetChild( panel, "Value" )

    Hud_SetText( valueText, value )
}

int function VGUIButtonLoadout_GetState( var panel )
{
    return expect int(panel.s.state)
}
