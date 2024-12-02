///////////////////////////////////////////////////////////
// Tracker scheme resource file
//
// sections:
//		Colors			- all the colors used by the scheme
//		BaseSettings	- contains settings for app to use to draw controls
//		Fonts			- list of all the fonts used by app
//		Borders			- description of all the borders
//
///////////////////////////////////////////////////////////
#base "fonts/font_scheme.res"
Scheme
{
	InheritableProperties
	{
	}
	Fonts
	{
	}

	//////////////////// BORDERS //////////////////////////////
	// describes all the border types
	Borders
	{
		WhiteBorder
		{
			inset 	"1 1 1 1"

			Left
			{
				1
				{
					color 	"255 255 255 40"
					offset	"0 1"
				}
			}
			Right
			{
				1
				{
					color 	"255 255 255 40"
					offset	"1 0"
				}
			}
			Top
			{
				1
				{
					color 	"255 255 255 40"
					offset 	"0 0"
				}
			}
			Bottom
			{
				1
				{
					color 	"255 255 255 40"
					offset 	"0 0"
				}
			}
		}
	}
}
