resource/ui/menus/panels/mod_slot.res
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

	Button
	{
		ControlName				RuiButton
		xpos					0
		wide                256
		tall				128
		labelText				""
	}
}