resource/ui/menus/hovers/simple.res
{
    BG
    {
        ControlName			ImagePanel

        image			"vgui/hud/white"

        drawColor	"36 36 36 255"
        scaleImage			1

        wide				450
        tall			    1000

        "xpos"			"0"
        "ypos"			"0"
    }

    TitleStrip
    {
        ControlName			ImagePanel

        image			"vgui/hud/white"

        drawColor	"48 48 48 255"
        scaleImage			1

        wide				450
        tall			    64

        "xpos"			"0"
        "ypos"			"0"
    }

    Title
    {
        ControlName				Label
        xpos					-8
        ypos				    2
        wide					2000
        tall					64
        visible					1
        enabled					1
        auto_wide_tocontents	0
        //auto_tall_tocontents	1
        labelText				"ARMOR CHIP"
        fgcolor_override		"255 255 255 255"
        textAlignment			west
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					GothicExpanded_36
        allcaps                 1

        pin_to_sibling			TitleStrip
        pin_corner_to_sibling	LEFT
        pin_to_sibling_corner	LEFT
    }

    Description
    {
        ControlName				Label
        visible					1
        enabled					1
        //auto_wide_tocontents	1
        auto_tall_tocontents	1
        labelText				"Continues the game from your last checkpoint."
        fgcolor_override		"230 230 230 255"
        textAlignment			west
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMono_18

		wide				442
        wrap                1

		"xpos"			"-8"
		"ypos"			"8"

		pin_to_sibling			TitleStrip
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	BOTTOM_LEFT
    }
}