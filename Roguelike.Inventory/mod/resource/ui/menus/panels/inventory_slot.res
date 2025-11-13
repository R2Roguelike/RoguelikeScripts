resource/ui/menus/panels/inventory_slot.res
{
    BG
    {
		ControlName			ImagePanel

		image			"vgui/hud/white"

		drawColor	"0 0 0 135"
		scaleImage			1

		wide				 80
		tall				 80

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

		wide				48
		tall				48

		pin_to_sibling "BG"
		pin_corner_to_sibling	CENTER
		pin_to_sibling_corner	CENTER

		ypos			-1

		"xpos"			"0"
		"ypos"			"0"
	}

	SlotLabel
	{
        ControlName				ImagePanel
        xpos					0
        ypos				    0
        wide					30
        tall					30
        visible					1
        enabled					1
        auto_wide_tocontents	0
		scaleImage				1
        //auto_tall_tocontents	1
        drawColor		"25 25 25 255"
        textAlignment			center
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"

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

		fgcolor_override	"0 0 0 128"
		scaleImage			1

		wide				72
		tall				2

		"xpos"			"0"
		"ypos"			"-4"

		pin_to_sibling "BG"
		pin_corner_to_sibling	BOTTOM
		pin_to_sibling_corner	BOTTOM
	}
	EnergyBar2
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

		wide				72
		tall				2

		"xpos"			"0"
		"ypos"			"-4"

		pin_to_sibling "BG"
		pin_corner_to_sibling	BOTTOM
		pin_to_sibling_corner	BOTTOM
	}

	Button
	{
		ControlName				RuiButton
		labelText				""
		xpos					0
		wide					 80
		tall					 80
		zpos					1000
	}

	SwapEffect
	{
		ControlName			ImagePanel

		image			"vgui/hud/white"

		drawColor	"255 255 255 255"
		scaleImage			1
		visible				0

		wide				 80
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
		visible				0

		wide				 80
		tall				0

		"xpos"			"0"
		"ypos"			"0"
	}
}