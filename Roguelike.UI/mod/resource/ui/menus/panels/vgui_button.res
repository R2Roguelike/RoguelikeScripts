resource/ui/menus/panels/vgui_button.res
{
    BG
    {
		ControlName			ImagePanel

		image			"vgui/hud/white"

		drawColor	"0 0 0 135"
		scaleImage			1

		wide                256
		tall				128

		"xpos"			"0"
		"ypos"			"0"
    }
	
	GoldBorder
	{
		ControlName			ImagePanel

		image			"vgui/hud/white"

		drawColor	"0 0 0 0"
		scaleImage			1

		wide                256
		tall				128
		visible 1

		"xpos"			"0"
		"ypos"			"0"

		border			GoldBorder
	}

	Image
	{
		ControlName			ImagePanel

		image			"vgui/hud/empty"
		xpos				-1
		ypos				0

		visible				1
		wide                64
		tall				64
		textAlignment		center

		pin_to_sibling				BG
		pin_corner_to_sibling		CENTER
		pin_to_sibling_corner		CENTER
	}

	Label
	{
		ControlName			Label
		xpos				-1
		ypos				0

		visible				1
		wide                256
		tall				64
		labelText			">> CONTINUE >>"
		allCaps				1
		font				JetBrainsMono_36
		auto_wide_to_contents	0
		auto_tall_tocontents    1
		textAlignment		center
		fgcolor_override 	"255 255 255 255"

		pin_to_sibling				BG
		pin_corner_to_sibling		CENTER
		pin_to_sibling_corner		CENTER
	}
	
	Overlay
	{
		ControlName			ImagePanel

		image			"vgui/hud/white"
		xpos				0
		ypos				0
		scaleImage			1

		visible				1
		wide                64
		tall				64
		textAlignment		center

		pin_to_sibling				BG
		pin_corner_to_sibling		CENTER
		pin_to_sibling_corner		CENTER
	}
	Lock
	{
		ControlName			ImagePanel

		image			"ui/lock"
		xpos				0
		ypos				0
		scaleImage			1

		visible				1
		wide                64
		tall				64
		textAlignment		center

		pin_to_sibling				BG
		pin_corner_to_sibling		CENTER
		pin_to_sibling_corner		CENTER
	}

	Button
	{
		ControlName				RuiButton
		xpos					0
		wide                256
		tall				128
		labelText				""
	}
}