resource/ui/menus/panels/inventory_switch.res
{
    Screen
    {
        ControlName		ImagePanel
        image           "vgui/hud/white"
        wide			512
        tall			256
        visible			1
        scaleImage		1
        fillColor		"0 0 0 0"
        drawColor		"0 0 0 0"
    }

    BarLeft
    {
		ControlName			ImagePanel

		image			"vgui/hud/white"

		drawColor	"255 255 255 255"
		scaleImage			1
		zpos				1

		wide				4
		tall				100

		"xpos"			"0"
		"ypos"			"0"
		pin_to_sibling "Screen"
		pin_corner_to_sibling	RIGHT
		pin_to_sibling_corner	CENTER
    }
    BarRight
    {
		ControlName			ImagePanel

		image			"vgui/hud/white"

		drawColor	"255 176 0 255"
		scaleImage			1
		zpos				1

		wide				4
		tall				200

		"xpos"			"0"
		"ypos"			"0"
		pin_to_sibling "Screen"
		pin_corner_to_sibling	LEFT
		pin_to_sibling_corner	CENTER
    }

    TextLeft
    {
        ControlName				Label
        xpos					-16
        ypos				    0
        wide					300
        tall					56
        visible					1
        enabled					1
        //auto_wide_tocontents	1
        auto_tall_tocontents	1
        labelText				"TITAN"
        fgcolor_override		"255 255 255 255"
        textAlignment			east
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					GothicExpanded_56

        pin_to_sibling			Screen
		pin_corner_to_sibling	RIGHT
		pin_to_sibling_corner	CENTER
    }
    TextRight
    {
        ControlName				Label
        xpos					16
        ypos				    0
        wide					74
        tall					56
        visible					1
        enabled					1
        auto_wide_tocontents	1
        auto_tall_tocontents	1
        labelText				"PILOT"
        fgcolor_override		"255 176 0 255"
        textAlignment			west
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					GothicExpanded_56

        pin_to_sibling			Screen
        pin_corner_to_sibling	LEFT
        pin_to_sibling_corner	CENTER
    }
    SwitchPromptRight
    {
        ControlName				Label
        xpos					0
        ypos				    -6
        wide					74
        tall					27
        visible					1
        enabled					1
        auto_wide_tocontents	1
        auto_tall_tocontents	1
        labelText				"Click to switch..."
        fgcolor_override		"120 120 120 255"
        textAlignment			east
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMono_18_Italic

        pin_to_sibling			TextRight
        pin_corner_to_sibling   TOP_LEFT
        pin_to_sibling_corner	BOTTOM_LEFT
    }
    SwitchPromptLeft
    {
        ControlName				Label
        xpos					0
        ypos				    -6
        wide					74
        tall					27
        visible					1
        enabled					1
        auto_wide_tocontents	1
        auto_tall_tocontents	1
        labelText				"Click to switch..."
        fgcolor_override		"120 120 120 255"
        textAlignment			center
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMono_18_Italic

        pin_to_sibling			TextLeft
        pin_corner_to_sibling   TOP_RIGHT
        pin_to_sibling_corner	BOTTOM_RIGHT
    }

	Button
	{
		ControlName				RuiButton
		xpos					0
		wide                %100
		tall				%100
		visible					1
		enabled					1
		scaleImage				1
		labelText				""
		rui						""
	}
}