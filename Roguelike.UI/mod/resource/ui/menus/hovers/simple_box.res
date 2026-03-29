resource/ui/menus/hovers/simple_box.res
{
    BG
    {
        ControlName			ImagePanel

        image			"vgui/hud/white"

        drawColor	"48 48 48 255"
        scaleImage			1

        wide				420
        tall			    80

        "xpos"			"0"
        "ypos"			"0"
    }

    Icon
    {
        ControlName			ImagePanel

        image			"ui/status_effects/puncture"

        drawColor	"255 255 255 255"
        scaleImage			1

        wide				24
        tall			    24

        "xpos"			"0"
        "ypos"			"-10"
        pin_to_sibling			BG
        pin_corner_to_sibling	LEFT
        pin_to_sibling_corner	LEFT
    }

    Value
    {
        ControlName				Label
        xpos					8
        ypos				    0
        wide					2000
        tall					64
        visible					1
        enabled					1
        auto_wide_tocontents	1
        //auto_tall_tocontents	1
        labelText				"3m"
        fgcolor_override		"255 255 255 255"
        textAlignment			west
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					GothicExpanded_42
        allcaps                 0

        pin_to_sibling			Icon
        pin_corner_to_sibling	LEFT
        pin_to_sibling_corner	RIGHT
    }




    PreviousValue
    {
        ControlName				Label
        xpos					10
        ypos				    0
        wide					2000
        tall					64
        visible					1
        enabled					1
        auto_wide_tocontents	1
        //auto_tall_tocontents	1
        labelText				"2m"
        fgcolor_override		"200 200 200 255"
        textAlignment			west
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMono_18_Italic
        allcaps                 0

        pin_to_sibling			Value
        pin_corner_to_sibling	LEFT
        pin_to_sibling_corner	RIGHT
    }

    Label
    {
        ControlName				Label
        xpos					1
        ypos				    0
        wide					2000
        tall					32
        visible					1
        enabled					1
        auto_wide_tocontents	1
        //auto_tall_tocontents	1
        labelText				"Radius"
        fgcolor_override		"200 200 200 255"
        textAlignment			west
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMono_18
        allcaps                 0

        pin_to_sibling			BG
        pin_corner_to_sibling	BOTTOM
        pin_to_sibling_corner	BOTTOM
    }

    StrikeThrough
    {
        ControlName			ImagePanel

        image			"vgui/hud/white"

        drawColor	"200 200 200 255"
        scaleImage			1

        wide				24
        tall			    2

        "xpos"			"0"
        "ypos"			"0"
        pin_to_sibling			PreviousValue
        pin_corner_to_sibling	CENTER
        pin_to_sibling_corner	CENTER
    }
}