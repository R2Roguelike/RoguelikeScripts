resource/ui/menus/hovers/armor_chip.res
{

    TitleStrip
    {
        ControlName			ImagePanel

        image			"vgui/hud/white"

        drawColor	"25 25 200 255"
        scaleImage			1

        wide				400
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

        wide				400
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
        xpos					-8
        ypos				    2
        wide					74
        tall					64
        visible					1
        enabled					1
        auto_wide_tocontents	1
        //auto_tall_tocontents	1
        labelText				"ARMOR CHIP"
        fgcolor_override		"25 25 25 255"
        textAlignment			north-west
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_43

        pin_to_sibling			TitleStrip
        pin_corner_to_sibling	LEFT
        pin_to_sibling_corner	LEFT
    }

	EnergyBarBG
	{
		ControlName			CHudProgressBar
		image			    "vgui/hud/white"
		fg_image			"vgui/hud/white"

		ProgressDirection			1
		CircularEnabled 		0
		SegmentFill			1
		SegmentSize			72
		SegmentGap			6
		visible				1

		fgcolor_override	"25 25 25 75"
		scaleImage			1

		wide				384
		tall				12

		"xpos"			"-8"
		"ypos"			"-8"

		pin_to_sibling "TitleStrip"
		pin_corner_to_sibling	BOTTOM_LEFT
		pin_to_sibling_corner	BOTTOM_LEFT
	}
	EnergyBar1
	{
		ControlName			CHudProgressBar
		image			    "vgui/hud/white"
		fg_image			"vgui/hud/white"

		ProgressDirection			0
		CircularEnabled 		0
		SegmentFill			1
		SegmentSize			72
		SegmentGap			6
		visible				1

		fgcolor_override	"25 25 25 255"
		scaleImage			1

		wide				384
		tall				12

		"xpos"			"-8"
		"ypos"			"-8"

		pin_to_sibling "TitleStrip"
		pin_corner_to_sibling	BOTTOM_LEFT
		pin_to_sibling_corner	BOTTOM_LEFT
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

        pin_to_sibling			EnergyBar1
        pin_corner_to_sibling	BOTTOM_RIGHT
        pin_to_sibling_corner	TOP_RIGHT
	}

    Armor
	{
        ControlName			CNestedPanel
        Classname			GridButtonClass
        controlSettingsFile	"resource/ui/menus/hovers/stat_bar.res"
        xpos            0
        ypos			8
        wide			384
        tall			24
        visible			1
        scaleImage		1

        zpos			1

		pin_to_sibling			TitleStrip
		pin_corner_to_sibling	TOP
		pin_to_sibling_corner	BOTTOM
	}
    Energy
	{
        ControlName			CNestedPanel
        Classname			GridButtonClass
        controlSettingsFile	"resource/ui/menus/hovers/stat_bar.res"
        xpos            0
        ypos			8
        wide			384
        tall			24
        visible			1
        scaleImage		1

        zpos			1

		pin_to_sibling			Armor
		pin_corner_to_sibling	TOP
		pin_to_sibling_corner	BOTTOM
	}
    Power
	{
        ControlName			CNestedPanel
        Classname			GridButtonClass
        controlSettingsFile	"resource/ui/menus/hovers/stat_bar.res"
        xpos            0
        ypos			8
        wide			384
        tall			24
        visible			1
        scaleImage		1

        zpos			1

		pin_to_sibling			Energy
		pin_corner_to_sibling	TOP
		pin_to_sibling_corner	BOTTOM
	}
    Temper
	{
        ControlName			CNestedPanel
        Classname			GridButtonClass
        controlSettingsFile	"resource/ui/menus/hovers/stat_bar.res"
        xpos            0
        ypos			8
        wide			384
        tall			24
        visible			1
        scaleImage		1

        zpos			1

		pin_to_sibling			Power
		pin_corner_to_sibling	TOP
		pin_to_sibling_corner	BOTTOM
	}
    Speed
	{
        ControlName			CNestedPanel
        Classname			GridButtonClass
        controlSettingsFile	"resource/ui/menus/hovers/stat_bar.res"
        xpos            0
        ypos			8
        wide			384
        tall			24
        visible			1
        scaleImage		1

        zpos			1

		pin_to_sibling			Temper
		pin_corner_to_sibling	TOP
		pin_to_sibling_corner	BOTTOM
	}
    Endurance
	{
        ControlName			CNestedPanel
        Classname			GridButtonClass
        controlSettingsFile	"resource/ui/menus/hovers/stat_bar.res"
        xpos            0
        ypos			8
        wide			384
        tall			24
        visible			1
        scaleImage		1

        zpos			1

		pin_to_sibling			Speed
		pin_corner_to_sibling	TOP
		pin_to_sibling_corner	BOTTOM
	}

    Footer
    {
        ControlName			ImagePanel

        image			"vgui/hud/white"

        drawColor	"25 25 25 255"
        scaleImage			1

        wide				400
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

		wide				400
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
        //auto_wide_tocontents	1
        auto_tall_tocontents	1
        labelText				"%[X_BUTTON|MOUSE2]%Upgrade (35$) %[X_BUTTON|F]%Dismantle"
        fgcolor_override		"255 255 255 255"
        textAlignment			east
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_20

		wide				384
        tall                28
        wrap                0

		"xpos"			"-8"
		"ypos"			"1"
		pin_to_sibling			Footer
		pin_corner_to_sibling	RIGHT
		pin_to_sibling_corner	RIGHT
    }
}