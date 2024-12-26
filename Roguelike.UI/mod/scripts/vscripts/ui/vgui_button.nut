untyped
global function VGUIButton_Init
global function VGUIButton_OnClick
global function VGUIButton_SetText
global function VGUIButton_SetState
global function VGUIButton_GetState

global enum eVGUIButtonState
{
    None,
    Selected,
    Locked
}

table<var, void functionref( var )> callbacks

void function VGUIButton_Init( var panel )
{
    var button = Hud_GetChild( panel, "Button" )
    var bg = Hud_GetChild( panel, "BG" )
    var img = Hud_GetChild( panel, "Image" )
    var label = Hud_GetChild( panel, "Label" )
    var goldBorder = Hud_GetChild( panel, "GoldBorder" )
    var overlay = Hud_GetChild( panel, "Overlay" )
    var lock = Hud_GetChild( panel, "Lock" )
    panel.s.state <- eVGUIButtonState.None
    Hud_SetVisible( goldBorder, false )
    Hud_SetVisible( overlay, false )
    Hud_SetVisible( lock, false )
    overlay.SetColor( 0, 0, 0, 128 )
    Hud_AddEventHandler( button, UIE_CLICK, OnClick )
    Hud_AddEventHandler( button, UIE_GET_FOCUS, OnGetFocus )
    Hud_AddEventHandler( button, UIE_LOSE_FOCUS, OnLoseFocus )

    array<var> elements = [bg, goldBorder, overlay, label, button]
    foreach (var elem in elements)
    {
        Hud_SetWidth( elem, Hud_GetWidth( panel ) )
        Hud_SetHeight( elem, Hud_GetHeight( panel ) )
    }
}

void function VGUIButton_SetText( var panel, string text )
{
    var label = Hud_GetChild( panel, "Label" )

    Hud_SetText( label, text )
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
    
    Hud_GetChild( panel, "Overlay" ).SetVisible( false )
    Hud_GetChild( panel, "Lock" ).SetVisible( false )
    Hud_GetChild( panel, "GoldBorder" ).SetVisible( false )
    Hud_SetLocked( button, false )
    switch (panel.s.state)
    {
        case eVGUIButtonState.None:
            Hud_GetChild( panel, "BG" ).SetColor( 220, 220, 220, 255 )
            Hud_GetChild( panel, "Label" ).SetColor( 25, 25, 25, 255 )
            break
        case eVGUIButtonState.Selected:
            Hud_GetChild( panel, "BG" ).SetColor( 219, 157, 0, 255 )
            Hud_GetChild( panel, "Label" ).SetColor( 0, 0, 0, 255 )
            break
        case eVGUIButtonState.Locked:
            Hud_GetChild( panel, "BG" ).SetColor( 220, 220, 220, 255 )
            Hud_GetChild( panel, "Label" ).SetColor( 25, 25, 25, 255 )
            Hud_GetChild( panel, "Overlay" ).SetVisible( true )
            Hud_GetChild( panel, "Lock" ).SetVisible( true )
            Hud_SetLocked( button, true )
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
        case eVGUIButtonState.None:
            Hud_GetChild( panel, "BG" ).SetColor( 0, 0, 0, 128 )
            Hud_GetChild( panel, "Label" ).SetColor( 255, 255, 255, 255 )
            break
        case eVGUIButtonState.Selected:
            Hud_GetChild( panel, "BG" ).SetColor( 0, 0, 0, 128 )
            Hud_GetChild( panel, "Label" ).SetColor( 219, 157, 0, 255 )
            Hud_GetChild( panel, "GoldBorder" ).SetVisible( true )
            break
        case eVGUIButtonState.Locked:
            Hud_GetChild( panel, "BG" ).SetColor( 0, 0, 0, 128 )
            Hud_GetChild( panel, "Label" ).SetColor( 255, 255, 255, 255 )
            Hud_GetChild( panel, "Overlay" ).SetVisible( true )
            Hud_GetChild( panel, "Lock" ).SetVisible( true )
            Hud_SetLocked( button, true )
            break
    }
}

void function VGUIButton_SetState( var panel, int state )
{
    var button = Hud_GetChild( panel, "Button" )

    panel.s.state = state

    if (Hud_IsFocused( button ))
        OnGetFocus( button )
    else
        OnLoseFocus( button )
}

int function VGUIButton_GetState( var panel )
{
    return expect int(panel.s.state)
}
