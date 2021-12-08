/*
Painting palette

Stores paint colors.
having one in hand while painting with a brush addas all of the palette's colors to the painting UI's palette
limit on number of colors? y/n?
should it hold actual reagents? how much? 1u, 5u?
would mean brush should actually hold reagents too, meaning brush is no longer simplistic color picker and must be managed like syringe: do you want it to draw color, exude color?

UI:
	option A: Normal Nano UI
		much like canvas, clicking with brush in hand opens UI
		click button to add color to list
		click color on list to mix
		opacity slider for mixing
		"delete" and "pick" button per color entry, pick sets brush color

		color display for brush?
		should "delete" require a rag? reagent container with water/paint cleaner? soap? sounds a bit weird but at least it's handheld

		people spending time on UIs instead of paying attention to game detracts from game
		being "focused" on painting is a necessary evil, and somewhat understandable
		being "focused" on mixing colors maybe not so much

	option B: RCD style UI
		palette opens like bag
		using brush on slots adds colors
		using brush on color mixes color

		two slots reserved for:
			- one brush
			- one paint cleaner:
				- small reagent container: water/paint cleaner to clean brush, no powergaymin issues
				- rag: use brush on rag, cleans brush, use rag on slots, cleans color, might be powergaymin issue?
						legitimizes rags outside bartender, but no idea how bad that might be if at all
						sounds most immersive
				- soap?: sounds a bit weird, also soap "hidden" in palette sounds terrible

		should probably have icons for palette+brush, palette+rag and combinations

		clicking palete with item puts it in palette
		yay, painting "toolbox"

		cons:
		- while idea sounds neat and immersive I can also see it being clunky and annoying
		- also no opacity/mixing slider. paint brush transfer amount, like beaekers? def on clumsy side of things
		- would require duplicating RYB color mixing algo in BYOND (duplicated code = bad)
		- puts a UI based limit to how many colors it can hold

interactions:
	- again, if held while painting using brush, palette's palette added alongside brush's to canvas palette
	- some way to clean the whole thing all at once. soap? running under sink? rag (conflicts with UI option B)?
*/


/obj/item/weapon/palette
	// Graphics stuff
	desc = "A piece of wood"
	name = "painting brush"
	icon = 'icons/obj/painting_items.dmi'
	icon_state = "painting_brush"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')

	// Materials stuff
	w_class = W_CLASS_SMALL
	starting_materials = list(MAT_WOOD = 245) //25cm wide circle, 0.5cm thick. Roughly the size of a DIN A4 piece of paper
	autoignition_temperature = AUTOIGNITION_WOOD
	w_type = RECYK_WOOD
	siemens_coefficient = 0

	// Paint stuff
