resource/ui/loadout_unlock_anim.res
{
    Screen
    {
		ControlName			ImagePanel

		image			"vgui/hud/white"

		drawColor	"0 0 0 0"
		scaleImage			1

		wide				 384
		tall				 128

		"xpos"			"0"
		"ypos"			"0"
    }
    LockHandle
    {
		ControlName			ImagePanel

		image			"ui/lock_handle"

		drawColor	"255 255 255 255"
		scaleImage			1
		visible				1

		wide				128
		tall				128

		pin_to_sibling "Screen"
		pin_corner_to_sibling	LEFT
		pin_to_sibling_corner	LEFT

		ypos			0

		"xpos"			"24"
		"ypos"			"0"
    }
    LockBody
    {
		ControlName			ImagePanel

		image			"ui/lock_body"

		drawColor	"255 255 255 255"
		scaleImage			1
		visible				1

		wide				128
		tall				128

		pin_to_sibling "Screen"
		pin_corner_to_sibling	LEFT
		pin_to_sibling_corner	LEFT

		ypos			0

		"xpos"			"24"
		"ypos"			"0"
    }

    LoadoutLabel
    {
		ControlName				Label
		xpos					-15
		ypos					-24
		wide					400
		tall					36
		visible					1
		enabled					1
		//auto_tall_tocontents	1
		auto_wide_tocontents	1
		labelText				"UNLOCKED LOADOUT"
		textAlignment			east
		fgcolor_override 		"255 255 255 255"
		//bgcolor_override 		"0 0 0 200"
		font					JetBrainsMono_43
		//fgcolor_override		""
		allcaps					0
		pin_to_sibling			LockBody
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	TOP_RIGHT
    }
    LoadoutName
    {
		ControlName				Label
		xpos					-17
		ypos					-18
		wide					400
		tall					56
		visible					1
		enabled					1
		//auto_tall_tocontents	1
		auto_wide_tocontents	1
		labelText				"EXPEDITION"
		textAlignment			east
		fgcolor_override 		"255 255 255 255"
		//bgcolor_override 		"0 0 0 200"
		font					JetBrainsMonoBold_72
		//fgcolor_override		""
		allcaps					1
		pin_to_sibling			LockBody
		pin_corner_to_sibling	BOTTOM_LEFT
		pin_to_sibling_corner	BOTTOM_RIGHT
    }

}