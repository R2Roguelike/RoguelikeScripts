resource/ui/menus/hovers/armor_chip.res
{

    TitleStrip
    {
        ControlName			ImagePanel

        image			"vgui/hud/white"

        drawColor	"25 25 200 255"
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

        drawColor	"60 60 60 255"
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
        fgcolor_override		"25 25 25 255"
        textAlignment			center
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					GothicExpanded_36

        pin_to_sibling			TitleStrip
        pin_corner_to_sibling	TOP
        pin_to_sibling_corner	TOP
    }

	EnergyBarBG
	{
		ControlName			CHudProgressBar
		image			    "vgui/hud/white"
		fg_image			"vgui/hud/white"

		ProgressDirection			0
		CircularEnabled 		0
		SegmentFill			1
		SegmentSize			59
		SegmentGap			6
		visible				1

		fgcolor_override	"25 25 25 255`"
		scaleImage			1

		wide				430
		tall				12

		"xpos"			"0"
		"ypos"			"-7"

		pin_to_sibling "TitleStrip"
		pin_corner_to_sibling	BOTTOM
		pin_to_sibling_corner	BOTTOM
	}
	EnergyBar1
	{
		ControlName			CHudProgressBar
		image			    "vgui/hud/white"
		fg_image			"vgui/hud/white"

		ProgressDirection			0
		CircularEnabled 		0
		SegmentFill			1
		SegmentSize			59
		SegmentGap			6
		visible				1

		fgcolor_override	"15 15 15 255"
		scaleImage			1

		wide				430
		tall				12

		"xpos"			"0"
		"ypos"			"0"

		pin_to_sibling "EnergyBarBG"
		pin_corner_to_sibling	BOTTOM_RIGHT
		pin_to_sibling_corner	BOTTOM_RIGHT
	}

	EnergyCount
	{
        ControlName				Label
        xpos					0
        ypos				    3
        wide					256
        tall					20
        visible					1
        enabled					1
        auto_wide_tocontents	1
        //auto_tall_tocontents	1
        labelText				"3 Titan / 1 Pilot"
        fgcolor_override		"25 25 25 255"
        textAlignment			east
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_17

        pin_to_sibling			EnergyBarBG
        pin_corner_to_sibling	BOTTOM_RIGHT
        pin_to_sibling_corner	TOP_RIGHT
	}

    Stat0
	{
        ControlName			CNestedPanel
        Classname			GridButtonClass
        controlSettingsFile	"resource/ui/menus/hovers/stat_bar.res"
        xpos            0
        ypos			8
        wide			434
        tall			24
        visible			1
        scaleImage		1

        zpos			1

		pin_to_sibling			TitleStrip
		pin_corner_to_sibling	TOP
		pin_to_sibling_corner	BOTTOM
	}
    SubStats
    {
        ControlName				Label
        visible					1
        enabled					1
        auto_wide_tocontents	0
        auto_tall_tocontents	1
        labelText				"Balls^FF000000 +1"
        fgcolor_override		"255 255 255 255"
        textAlignment			west
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_20

		wide				370
        tall                28
        wrap                0

		"xpos"			"-7"
		"ypos"			"8"
		pin_to_sibling			Stat0
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	BOTTOM_LEFT
    }

    Footer
    {
        ControlName			ImagePanel

        image			"vgui/hud/white"

        drawColor	"15 15 15 255"
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