untyped
global function Hover_Init
global function AddHover
global function RemoveHover
global function GetCurrentHoverTarget
global function HoverSimple_SetData

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
    HoverSimpleData& hoverSimpleData
} file

void function Hover_Init()
{ //PAIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIN
    ClientCommand( "bind \"`\" toggleconsole")
    RegisterSignal( "StopHover" )
    var menu = CreateMenu( "menu_Hover", $"resource/ui/menus/hovers.menu" )

	//menu.SetHudName( "TimerOverlay" )
    //menu.SetDisplayName( "TimerOverlay" )

	//menu.SetType( "menu" )

    //Hud_SetSize( menu, GetScreenSize()[0], GetScreenSize()[1])
    file.menu = menu

    HoverSimpleData data
    file.preHoverCallbacks[HOVER_SIMPLE] <- void function( var panel ) : (data){
        Hud_SetColor( Hud_GetChild(panel, "TitleStrip"), 40, 40, 40, 255 )
        Hud_SetColor( Hud_GetChild(panel, "BG"), 25,25,25, 255 )
        
        Hud_EnableKeyBindingIcons( Hud_GetChild(panel, "FooterText"))
        Hud_SetText( Hud_GetChild(panel, "FooterText"), "" )
    }

    file.postHoverCallbacks[HOVER_SIMPLE] <- void function( var panel ) : (){
        HoverSimpleData data = file.hoverSimpleData

		Hud_SetText( Hud_GetChild( panel, "Title" ), FormatDescription( data.title ) )
		Hud_SetText( Hud_GetChild( panel, "Description" ), FormatDescription( data.description ) )
        Hud_SetText( Hud_GetChild(panel, "FooterText"), FormatDescription(data.footerText) )
        bool visibleFooter = (data.footerText != "")
        bool visibleInfo = (data.boxes.len() > 0)

        if (<data.color[0], data.color[1], data.color[2]> == <255, 255, 255> ) // arrays compared by ref, not by value
        {
            data.color = [40, 40, 40, 255]
        }

        Hud_SetColor( Hud_GetChild( panel, "Title" ), ShouldTextBeBlack( <data.color[0], data.color[1], data.color[2]> / 255 ) ? [0,0,0,255] : [255,255,255,255])
        Hud_GetChild( panel, "TitleStrip" ).SetColor(data.color)
        Hud_GetChild( panel, "BG" ).SetColor([data.color[0] * 0.5, data.color[1] * 0.5, data.color[2] * 0.5, 255])

        int offset = 0
        if (visibleFooter)
            offset += 32
        
        array<int> rows = [0,0,0,0]
        array<int> boxCount = [0,0,0,0]
        array<int> boxIndex = [0,0,0,0]

        int rowNum = 0
        int boxId = 0
        for (int i = 0; i < 4; i++)
        {
            if (i >= data.boxes.len())
            {
                continue
            }
            if (data.boxes[i].newRow && i != 0)
            {
                rowNum++
                boxId = 0
            }
            rows[i] = rowNum
            boxCount[rowNum]++
            boxIndex[i] = boxId
            boxId++
        }
        if (visibleInfo)
            offset += 4 + ((rowNum + 1) * 86)
        for (int i = 0; i < 4; i++)
        {
            var box = Hud_GetChild( panel, "Box" + i )
            if (i >= data.boxes.len())
            {
                Hud_Hide( box )
                continue
            }

            // first box is always full width, the rest share space on a 2nd row
            int rowWidth = ContentScaledXAsInt(418)
            int gap = ContentScaledXAsInt(4)
            int boxAmount = boxCount[rows[i]]
            int gapCount = gap * boxAmount
            
            int boxWidth = ((rowWidth + gap) / boxAmount - gap)
            Hud_Show( box )
            Hud_SetY( box, ContentScaledXAsInt(16) + ContentScaledXAsInt(84) * rows[i] )
            Hud_SetX( box, boxIndex[i] * -(boxWidth + gap))
            Hud_SetWidth( box, boxWidth )
            Hud_SetWidth( Hud_GetChild(box, "BG"), boxWidth )
            HoverSimpleBox boxData = data.boxes[i]
            Hud_SetVisible(Hud_GetChild(box, "Icon"), boxData.icon != $"")

            Hud_SetText(Hud_GetChild(box, "Label"), FormatDescription(boxData.label))
            Hud_SetText(Hud_GetChild(box, "Value"), boxData.currentValue)

            if (boxData.icon != $"")
            {
                Hud_SetImage(Hud_GetChild(box, "Icon"), boxData.icon)
                Hud_SetWidth(Hud_GetChild(box, "Icon"), ContentScaledXAsInt(24))
            }
            else
            {
                Hud_SetWidth(Hud_GetChild(box, "Icon"), 0)
            }
            Hud_GetChild( box, "BG" ).SetColor([max(48.0, data.color[0] * 0.6), max(48.0, data.color[1] * 0.6), max(48.0, data.color[2] * 0.6), 255])


            int offsetNoIcon = ContentScaledXAsInt(12)
            int widthOfValueLabel = Hud_GetWidth(Hud_GetChild(box, "Value")) + offsetNoIcon
            if (boxData.icon != $"")
            {
                widthOfValueLabel += ContentScaledXAsInt(20) - offsetNoIcon
            }
            Hud_SetColor(Hud_GetChild(box, "Value"), 255, 255, 255, 255)
            if (boxData.abilityPowerBox && boxData.currentValue != boxData.initialValue)
            {
                Hud_SetColor(Hud_GetChild(box, "Value"), 255, 137, 18, 255)
            }
            if (boxData.currentValue != boxData.initialValue && boxData.initialValue != "")
            {
                Hud_SetColor(Hud_GetChild(box, "PreviousValue"), 200, 200, 200, 255)
                Hud_Show(Hud_GetChild(box, "PreviousValue"))
                Hud_Show(Hud_GetChild(box, "StrikeThrough"))
                Hud_SetText(Hud_GetChild(box, "PreviousValue"), boxData.initialValue)
                Hud_SetWidth(Hud_GetChild(box, "StrikeThrough"), Hud_GetWidth(Hud_GetChild(box, "PreviousValue")) + ContentScaledXAsInt(4) )
                widthOfValueLabel += Hud_GetWidth(Hud_GetChild(box, "PreviousValue")) + ContentScaledXAsInt(20)
            }
            else
            {
                Hud_Hide(Hud_GetChild(box, "PreviousValue"))
                Hud_Hide(Hud_GetChild(box, "StrikeThrough"))
            }
            
            Hud_SetX(Hud_GetChild(box, "Icon"), -(boxWidth / 2 - widthOfValueLabel / 2) )
        }
        rows.clear()
        boxIndex.clear()
        boxCount.clear()

        
        Hud_SetHeight( Hud_GetChild(panel, "BG"), ContentScaledYAsInt( 64 + 32 + offset ) + Hud_GetHeight(Hud_GetChild(panel, "Description")) )


        Hud_SetHeight( panel, ContentScaledYAsInt( 64 + 32 + offset ) + Hud_GetHeight(Hud_GetChild(panel, "Description")) )
        Hud_SetY( Hud_GetChild(panel, "Footer"), visibleFooter ? 0 : 1999 )
    }

    file.preHoverCallbacks[HOVER_ARMOR_CHIP] <- void function (var panel) : (){
        Hud_SetHeight( panel, ContentScaledYAsInt( 384 ) )
    }
    file.preHoverCallbacks[HOVER_WEAPON] <- void function (var panel) : (){
        Hud_SetHeight( panel, ContentScaledYAsInt( 364 ) )
        Hud_SetColor( Hud_GetChild(panel, "TitleStrip"), 40, 40, 40, 255 )
        Hud_SetColor( Hud_GetChild(panel, "BG"), 25,25,25, 255 )
    }

    Hud_SetVisible( file.menu, true )
    Hud_GetChild(file.menu,HOVER_ARMOR_CHIP).SetPanelAlpha(0.0)
    Hud_SetVisible(Hud_GetChild(file.menu,HOVER_ARMOR_CHIP), false)
    Hud_GetChild(file.menu,HOVER_SIMPLE).SetPanelAlpha(0.0)
    Hud_SetVisible(Hud_GetChild(file.menu,HOVER_SIMPLE), false)
    Hud_GetChild(file.menu,HOVER_WEAPON).SetPanelAlpha(0.0)
    Hud_SetVisible(Hud_GetChild(file.menu,HOVER_WEAPON), false)

    delaythread(0.1) Hover_Update()
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
                Hud_SetVisible(lastPanel, lastPanel.GetPanelAlpha() > 0)
            }
            else if (target != null)
            {
                string hoverType = file.hoverType[target]
                var panel = Hud_GetChild(file.menu, hoverType)

                panel.SetPanelAlpha(min(panel.GetPanelAlpha() + 3000.0 * (Time() - lastTime), 255))
                Hud_Show(panel)

                if (lastHoverType != hoverType && lastHoverType != "")
                {
                    var lastPanel = Hud_GetChild(file.menu, lastHoverType)
                    float alpha = float( lastPanel.GetPanelAlpha() )
                    lastPanel.SetPanelAlpha(0.0)
                    Hud_Hide(lastPanel)
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

            if (loc.y < screenSize[1] / 2)
            {
                loc.y = min(loc.y + 20, screenSize[1] - Hud_GetHeight(file.menu) - 20)
            }
            else
            {
                loc.y = max(loc.y - Hud_GetHeight(file.menu) - 20, 20)
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

void function HoverSimple_SetData(HoverSimpleData data)
{
    file.hoverSimpleData = data
}
