resource/ui/menus/panels/mod_slot.res
{
    BG
    {
		ControlName			ImagePanel

		image			"ui/titan_mod_3"

		drawColor	"0 0 0 135"
		scaleImage			1

		wide				 64
		tall				 64

		"xpos"			"0"
		"ypos"			"0"

		zpos			-1
    }

	FloppyDisk
	{
		ControlName			ImagePanel

		image			"ui/floppy_disk"

		drawColor	"64 64 64 255"
		scaleImage			1
		zpos				0

		wide				64
		tall				64

		"xpos"			"0"
		"ypos"			"0"
		pin_to_sibling "BG"
		pin_corner_to_sibling	CENTER
		pin_to_sibling_corner	CENTER
	}

	ModIcon
	{
		ControlName			ImagePanel

		image			"vgui/hud/white"

		drawColor	"255 255 255 255"
		scaleImage			1
		zpos				1

		wide				32
		tall				32

		"xpos"			"0"
		"ypos"			"0"
		pin_to_sibling "BG"
		pin_corner_to_sibling	CENTER
		pin_to_sibling_corner	CENTER
	}

	Overlay
	{
		ControlName			ImagePanel

		image			"ui/titan_mod_3"
		visible			0

		drawColor	"0 0 0 225"
		scaleImage			1
		zpos				2

		wide				64
		tall				64

		"xpos"			"0"
		"ypos"			"0"
		pin_to_sibling "BG"
		pin_corner_to_sibling	CENTER
		pin_to_sibling_corner	CENTER
	}

	Abbreviation
	{
        ControlName				Label
        xpos					0
        ypos				    0
        wide					74
        tall					32
        visible					1
        enabled					1
        auto_wide_tocontents	1
        //auto_tall_tocontents	1
        labelText				"!"
        fgcolor_override		"255 255 255 255"
        textAlignment			center
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_27
		zpos				1

		"xpos"			"0"
		"ypos"			"0"
		pin_to_sibling "FloppyDisk"
		pin_corner_to_sibling	CENTER
		pin_to_sibling_corner	CENTER
	}

	Button
	{
		ControlName				RuiButton
		xpos					0
		wide					 64
		tall					 64
			labelText				""
		zpos				3
	}
}