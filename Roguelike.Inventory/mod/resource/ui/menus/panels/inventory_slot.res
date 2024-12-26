resource/ui/menus/panels/inventory_slot.res
{
    BG
    {
		ControlName			ImagePanel

		image			"vgui/hud/white"

		drawColor	"0 0 0 135"
		scaleImage			1

		wide				96
		tall				96

		"xpos"			"0"
		"ypos"			"0"
    }

	Icon
	{
		ControlName			ImagePanel

		image			"ui/armor_chip"

		drawColor	"255 255 255 255"
		scaleImage			1
		visible				1

		wide				64
		tall				64

		pin_to_sibling "BG"
		pin_corner_to_sibling	CENTER
		pin_to_sibling_corner	CENTER

		ypos			-1

		"xpos"			"0"
		"ypos"			"0"
	}

	SlotLabel
	{
        ControlName				Label
        xpos					0
        ypos				    0
        wide					74
        tall					64
        visible					1
        enabled					1
        auto_wide_tocontents	1
        //auto_tall_tocontents	1
        labelText				"3"
        fgcolor_override		"25 25 25 255"
        textAlignment			center
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_36

        pin_to_sibling			Icon
        pin_corner_to_sibling	CENTER
        pin_to_sibling_corner	CENTER
	}

	EnergyBar1
	{
		ControlName			CHudProgressBar
		image			    "vgui/hud/white"
		fg_image			"vgui/hud/white"

		ProgressDirection			0
		CircularEnabled 		0
		SegmentFill			1
		SegmentSize			4
		SegmentGap			2
		visible				1

		fgcolor_override	"220 220 220 255"
		scaleImage			1

		wide				88
		tall				2

		"xpos"			"-4"
		"ypos"			"-4"

		pin_to_sibling "BG"
		pin_corner_to_sibling	BOTTOM_LEFT
		pin_to_sibling_corner	BOTTOM_LEFT
	}
	EnergyBar2
	{
		ControlName			CHudProgressBar
		image			    "vgui/hud/white"
		fg_image			"vgui/hud/white"

		ProgressDirection			1
		CircularEnabled 		0
		SegmentFill			1
		SegmentSize			4
		SegmentGap			2
		visible				1

		fgcolor_override	"255 176 0 255"
		scaleImage			1

		wide				88
		tall				2

		"xpos"			"-4"
		"ypos"			"-4"

		pin_to_sibling "BG"
		pin_corner_to_sibling	BOTTOM_RIGHT
		pin_to_sibling_corner	BOTTOM_RIGHT
	}

	Button
	{
		ControlName				RuiButton
		labelText				""
		xpos					0
		wide					96
		tall					96
		zpos					1000
	}
	
	SwapEffect
	{
		ControlName			ImagePanel

		image			"vgui/hud/white"

		drawColor	"255 255 255 255"
		scaleImage			1

		wide				96
		tall				0

		"xpos"			"0"
		"ypos"			"0"
	}
	SwapEffect2
	{
		ControlName			ImagePanel

		image			"vgui/hud/white"

		drawColor	"255 255 255 255"
		scaleImage			1

		wide				96
		tall				0

		"xpos"			"0"
		"ypos"			"0"
	}
}