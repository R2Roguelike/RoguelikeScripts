untyped
global function Hover_Init
global function AddHover
global function RemoveHover 
global function GetCurrentHoverTarget

global const string HOVER_ARMOR_CHIP = "ArmorChip"
global const string HOVER_SIMPLE = "Simple"
global const string HOVER_WEAPON = "Weapon"

struct {
    var menu
    var target
    string nextMap = ""
    int startPointIndex = 0
    int kills = 69
    float time = 370
    table< var, void functionref( var, var ) > hoverCallbacks
    table< string, void functionref( var ) > preHoverCallbacks
    table< string, void functionref( var ) > postHoverCallbacks
    table< var, string > hoverType
} file

void function Hover_Init()
{ //PAIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIN

    RegisterSignal( "StopHover" )
    var menu = CreateMenu( "menu_Hover", $"resource/ui/menus/hovers.menu" )

	//menu.SetHudName( "TimerOverlay" )
    //menu.SetDisplayName( "TimerOverlay" )

	//menu.SetType( "menu" )

    //Hud_SetSize( menu, GetScreenSize()[0], GetScreenSize()[1])
    file.menu = menu

    file.preHoverCallbacks[HOVER_SIMPLE] <- void function( var panel ) : (){
        Hud_SetColor( Hud_GetChild(panel, "TitleStrip"), 64, 64, 64, 255 )
        Hud_SetColor( Hud_GetChild(panel, "BG"), 48, 48, 48, 255 )
    }

    file.postHoverCallbacks[HOVER_SIMPLE] <- void function( var panel ) : (){
        Hud_SetHeight( panel, ContentScaledYAsInt( 64 + 16 ) + Hud_GetHeight(Hud_GetChild(panel, "Description")) )
    }

    file.preHoverCallbacks[HOVER_ARMOR_CHIP] <- void function (var panel) : (){
        Hud_SetHeight( panel, ContentScaledYAsInt( 296 ) )
    }
    file.preHoverCallbacks[HOVER_WEAPON] <- void function (var panel) : (){
        Hud_SetHeight( panel, ContentScaledYAsInt( 296 ) )
    }

    Hud_SetVisible( file.menu, true )
    Hud_GetChild(file.menu,HOVER_ARMOR_CHIP).SetPanelAlpha(0.0)
    Hud_GetChild(file.menu,HOVER_SIMPLE).SetPanelAlpha(0.0)
    Hud_GetChild(file.menu,HOVER_WEAPON).SetPanelAlpha(0.0)

    delaythread(0.001) Hover_Update()
}

void function Hover_Update()
{
    string lastHoverType
    float lastTime = -1.0
    int[2] screenSize = GetScreenSize()
    while (true)
    {
        vector ornull mousePosOrNull = NSGetCursorPosition()
        if (mousePosOrNull != null)
        {
            vector mousePos = expect vector( mousePosOrNull )

            var target = null
            foreach ( var element, string hoverType in file.hoverType )
            {
                if (!IsActuallyVisible(element))
                    continue
                
                if ((IsAnyChildFocused( element ) && IsControllerModeActive()) || IsElementHoveredOver(element, mousePos))
                {
                    target = element
                    break
                }
            }


            if (file.target != target)
                Signal( uiGlobal.signalDummy, "StopHover" )

            file.target = target
            if (target == null && lastHoverType != "")
            {
                var lastPanel = Hud_GetChild(file.menu, lastHoverType)
                lastPanel.SetPanelAlpha(max(lastPanel.GetPanelAlpha() - 3000.0 * (Time() - lastTime), 0))
            }
            else if (target != null)
            {
                string hoverType = file.hoverType[target]
                var panel = Hud_GetChild(file.menu, hoverType)

                panel.SetPanelAlpha(min(panel.GetPanelAlpha() + 3000.0 * (Time() - lastTime), 255))

                if (lastHoverType != hoverType && lastHoverType != "")
                {
                    var lastPanel = Hud_GetChild(file.menu, lastHoverType)
                    float alpha = float( lastPanel.GetPanelAlpha() )
                    lastPanel.SetPanelAlpha(0.0)
                    panel.SetPanelAlpha(alpha)
                }

                if (hoverType in file.preHoverCallbacks)
                    file.preHoverCallbacks[hoverType]( panel )

                file.hoverCallbacks[target]( target, panel )

                if (hoverType in file.postHoverCallbacks)
                    file.postHoverCallbacks[hoverType]( panel )

                Hud_SetWidth(file.menu, Hud_GetWidth( panel ))
                Hud_SetHeight(file.menu, Hud_GetHeight( panel ))
                lastHoverType = hoverType
            }
            
            vector loc = mousePos

            // when using controller, dont hover next to mouse, hover next to element
            if (IsControllerModeActive() && target != null)
                loc = <Hud_GetAbsX( target ) + Hud_GetWidth( target ), Hud_GetAbsY( target ), 0>

            // prevent going outside of screen
            if (loc.x > screenSize[0] / 2)
            {
                loc.x = loc.x - Hud_GetWidth(file.menu) - 20
            }
            else
            {
                loc.x = loc.x + 20
            }

            if (loc.y > screenSize[1] / 2)
            {
                loc.y = max(loc.y - Hud_GetHeight(file.menu) - 20, screenSize[1] / 2 - Hud_GetHeight(file.menu) / 2)
            }
            else
            {
                loc.y = min(loc.y + 20, screenSize[1] / 2 - Hud_GetHeight(file.menu) / 2)
            }

            Hud_SetPos( file.menu, loc.x, loc.y )
            
        }
        lastTime = Time()
        wait 0.001
    }
}

var function GetCurrentHoverTarget()
{
    return file.target
}

bool function IsActuallyVisible( var element )
{
    if (element == null)
        return true
    
    if (StartsWith(Hud_GetHudName(element), "menu_") && uiGlobal.activeMenu != element)
        return false
    
    return Hud_IsVisible( element ) && IsActuallyVisible( Hud_GetParent( element ) )
}

bool function IsAnyChildFocused( var element )
{
    return IsAnyChildFocused_Internal( element, GetFocus() )
}

bool function IsAnyChildFocused_Internal( var element, var curParent )
{
    if (curParent == null)
        return false
    
    if (curParent == element)
        return true
    
    return IsAnyChildFocused_Internal( element, Hud_GetParent(curParent) )
}

void function AddHover( var element, void functionref( var, var ) callback, string hoverType )
{
    file.hoverCallbacks[element] <- callback
    file.hoverType[element] <- hoverType
}

void function RemoveHover( var element )
{
    if (!(element in file.hoverCallbacks))
        return
    delete file.hoverCallbacks[element]
    delete file.hoverType[element]
}

void function SetHoverType( var element, string hoverType )
{
    var panel = Hud_GetChild(file.menu, hoverType)
    
    file.hoverType[element] <- hoverType
}

bool function IsElementHoveredOver( var element, vector mousePos )
{
    var minPos = Hud_GetAbsPos( element )
    var size = Hud_GetSize( element )
    return (mousePos.x > minPos[0] && mousePos.x < minPos[0] + size[0] + 1 && mousePos.y > minPos[1] && mousePos.y < minPos[1] + size[1] + 1)
}
