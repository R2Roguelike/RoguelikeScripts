resource/ui/menus/hovers/armor_chip.res
{

    TitleStrip
    {
        ControlName			ImagePanel

        image			"vgui/hud/white"

        drawColor	"64 64 64 255"
        scaleImage			1

        wide				450
        tall			    64

        "xpos"			"0"
        "ypos"			"0"
    }

    BG
    {
        ControlName			ImagePanel

        image			"vgui/hud/white"

        drawColor	"48 48 48 255"
        scaleImage			1

        wide				450
        tall			    200

        "xpos"			"0"
        "ypos"			"0"

		pin_to_sibling			TitleStrip
		pin_corner_to_sibling	TOP
		pin_to_sibling_corner	BOTTOM
    }

    Title
    {
        ControlName				Label
        xpos					0
        ypos				    -8
        wide					2000
        tall					32
        visible					1
        enabled					1
        auto_wide_tocontents	0
        //auto_tall_tocontents	1
        labelText				"CHIP"
        fgcolor_override		"255 255 255 255"
        textAlignment			center
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					GothicExpanded_36

        pin_to_sibling			TitleStrip
        pin_corner_to_sibling	TOP
        pin_to_sibling_corner	TOP
    }

    SubTitle
    {
        ControlName				Label
        xpos					0
        ypos				    -8
        wide					2000
        tall					32
        visible					1
        enabled					1
        auto_wide_tocontents	0
        //auto_tall_tocontents	1
        labelText				"Primary Weapon"
        fgcolor_override		"255 255 255 255"
        textAlignment			center
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMono_18

        pin_to_sibling			Title
        pin_corner_to_sibling	TOP
        pin_to_sibling_corner	BOTTOM
    }

    Footer
    {
        ControlName			ImagePanel

        image			"vgui/hud/white"

        drawColor	"25 25 25 255"
        scaleImage			1

        wide				450
        tall			    32

        "xpos"			"0"
        "ypos"			"0"
		pin_to_sibling			BG
		pin_corner_to_sibling	TOP
		pin_to_sibling_corner	BOTTOM
    }
    FooterBar
    {
		ControlName			CHudProgressBar
		image			    "vgui/hud/white"
		fg_image			"vgui/hud/white"

		ProgressDirection			0
		CircularEnabled 		0
		SegmentFill			1
		SegmentSize			1000
		SegmentGap			6
		visible				1

		fgcolor_override	"150 0 0 255"
		scaleImage			1

		wide				450
		tall				32

		"xpos"			"0"
		"ypos"			"0"

		pin_to_sibling "Footer"
		pin_corner_to_sibling	BOTTOM_LEFT
		pin_to_sibling_corner	BOTTOM_LEFT
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

		wide				384
        wrap                1

		"xpos"			"-8"
		"ypos"			"8"

		pin_to_sibling			TitleStrip
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	BOTTOM_LEFT
    }

    LevelLabel
    {
        ControlName				Label
        visible					1
        enabled					1
        auto_wide_tocontents	1
        auto_tall_tocontents	1
        labelText				"Level 1/5"
        fgcolor_override		"230 230 230 255"
        textAlignment			east
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMono_18

		wide				384
        wrap                1

		"xpos"			"-8"
		"ypos"			"-4"

		pin_to_sibling			TitleStrip
		pin_corner_to_sibling	BOTTOM_RIGHT
		pin_to_sibling_corner	BOTTOM_RIGHT
    }

    FooterText
    {
        ControlName				Label
        visible					1
        enabled					1
        auto_wide_tocontents	0
        auto_tall_tocontents	1
        labelText				"%[X_BUTTON|MOUSE2]%Upgrade (35$) %[X_BUTTON|F]%Dismantle"
        fgcolor_override		"255 255 255 255"
        textAlignment			east
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_20

		wide				4000
        tall                28
        wrap                0

		"xpos"			"-8"
		"ypos"			"1"
		pin_to_sibling			Footer
		pin_corner_to_sibling	RIGHT
		pin_to_sibling_corner	RIGHT
    }
}