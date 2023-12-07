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


/obj/item/palette
	// Graphics stuff
	desc = "A palette on which to store colours. Let out your inner Picasso."
	name = "palette"
	icon = 'icons/obj/painting_items.dmi'
	icon_state = "palette"
	item_state = "palette"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/arts_n_crafts.dmi', "right_hand" = 'icons/mob/in-hand/right/arts_n_crafts.dmi')

	// Materials stuff
	w_class = W_CLASS_SMALL
	starting_materials = list(MAT_WOOD = 245) //25cm wide disc, 0.5cm thick. Roughly the size of a DIN A4 piece of paper
	autoignition_temperature = AUTOIGNITION_WOOD
	w_type = RECYK_WOOD
	siemens_coefficient = 0

	// Paint stuff
	var/tagindex = 0
	var/list/stored_colours = list()
	var/list/nanopaint_indexes = list()
	var/list/components = list()

/obj/item/palette/attack_self(mob/user)
	. = ..()
	ui_interact(user)

/obj/item/palette/attackby(obj/item/weapon/W, mob/user)
	. = ..()
	var/datum/painting_utensil/p = new(user, W)
	if (p.base_color)
		stored_colours["[++tagindex]"] = p.base_color
		nanopaint_indexes["[tagindex]"] = p.nano_paint
		components["[tagindex]"] = p.components.Copy()
		to_chat(user, "<span class='notice'>You add a new color to \the [src].</span>")
		update_icon()

/obj/item/palette/ui_interact(mob/user, ui_key, datum/nanoui/ui, force_open)
	. = ..()
	var/list/data = list()
	var/list/paint_colours
	if (stored_colours.len)
		paint_colours = list()
	for (var/C_tag in stored_colours)
		var/C_data[0]
		C_data["tag"] = C_tag
		var/colour = rgb2num(stored_colours[C_tag]) // Shaving off the alpha channel
		C_data["base_color"] = rgb(colour[1], colour[2], colour[3])
		switch(nanopaint_indexes[C_tag])
			if (PAINTLIGHT_NONE)
				C_data["nano_paint"] = "#161616"
			if (PAINTLIGHT_LIMITED)
				C_data["nano_paint"] = "#999999"
			if (PAINTLIGHT_FULL)
				C_data["nano_paint"] = "#FFFFFF"
		paint_colours += list(C_data)
	data["paint_colours"] = paint_colours
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		// The ui does not exist, so we'll create a new one.
		ui = new(user, src, ui_key, "palette.tmpl", name, 580, 410)
		// Open the new ui window.
		ui.open()
		ui.set_initial_data(data)
		// Auto update every Master Controller tick.
		ui.set_auto_update(1)

/obj/item/palette/update_icon()
	overlays.len = 0
	var/i = 0
	var/image/paintleft = image(inhand_states["left_hand"], src, "palette-color")
	var/image/paintright = image(inhand_states["right_hand"], src, "palette-color")
	for (var/C_tag in stored_colours)
		var/image/I = image(icon, src, "palette-color[(i % 12)+1]")
		I.color = stored_colours[C_tag]
		overlays += I

		//dynamic in-hand overlay
		var/image/paintcolorleft = image(inhand_states["left_hand"], src, "palette-color[(i % 4)+1]")
		var/image/paintcolorright = image(inhand_states["right_hand"], src, "palette-color[(i % 4)+1]")
		paintcolorleft.color = stored_colours[C_tag]
		paintcolorright.color = stored_colours[C_tag]
		paintleft.overlays += paintcolorleft
		paintright.overlays += paintcolorright

		i++

	dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"] = paintleft
	dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"] = paintright

	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()

/obj/item/palette/Topic(href, href_list)
	if (..())
		return
	if (href_list["colour"])
		var/colour_tag = href_list["colour"]
		var/colour = stored_colours[colour_tag]
		var/nanopaint = nanopaint_indexes[colour_tag]
		var/list/component = components[colour_tag]
		if (!colour)
			return
		var/mob/living/L = usr
		if (!istype(L))
			return
		var/obj/item/painting_brush/PB
		for (var/i = 1 to L.held_items.len)
			var/obj/O = L.held_items[i]
			if (istype(O, /obj/item/painting_brush))
				PB = O
				break
		if (!PB)
			to_chat(usr, "<span class='warning'>You must have a paintbrush in your hand to use \the [src].</span>")
		switch (href_list["act"])
			if ("apply")
				if (!PB.paint_color)
					PB.paint_color = colour
					PB.nano_paint = nanopaint
					PB.component = component.Copy()
					to_chat(usr, "<span class='notice'>You apply the color to \the [PB].</span>")
				else
					to_chat(usr, "<span class='notice'>You start mixing colours...</span>")
					var/strengh = input("How much do you want to mix the colours? 0.5 is for an even mixing. Values toward 0 get a stronger shade of the colour in the palette, value toward 1 get a stronger shade of the colour in the pencil.", "Strenght of mixing", 0.5) as null|num
					if (!strengh || (strengh < 0))
						return
					strengh = clamp(strengh, 0, 1)
					var/colour_pencil = rgb2num(PB.paint_color)
					var/colour_palette = rgb2num(colour)
					PB.component |= component
					components[colour_tag] = PB.component.Copy()
					//Nano Paint turns any paint it touches into more nano paint and blends additively
					if ((nanopaint == PAINTLIGHT_FULL) || (PB.nano_paint == PAINTLIGHT_FULL))
						var/blend_rgb = AddRGB(colour, PB.paint_color, strengh)
						stored_colours[colour_tag] = blend_rgb
						PB.paint_color = blend_rgb
						PB.nano_paint = TRUE
						nanopaint_indexes[colour_tag] = PAINTLIGHT_FULL
					//Otherwise, if both paints have limited luminosity, the results will be luminous. Otherwise the result loses its luminosity.
					else
						var/blend = colorRybBlend(colour_pencil, colour_palette, strengh)
						var/blend_rgb = rgb(blend[1], blend[2], blend[3], blend[4], "COLORSPACE_RGB")
						stored_colours[colour_tag] = blend_rgb
						PB.paint_color = blend_rgb
						if ((nanopaint != PAINTLIGHT_LIMITED) || (PB.nano_paint != PAINTLIGHT_LIMITED))
							PB.nano_paint = PAINTLIGHT_NONE
				PB.update_icon()
			if ("duplicate")
				stored_colours["[++tagindex]"] += colour
				nanopaint_indexes["[tagindex]"] = nanopaint
				components["[tagindex]"] = component.Copy()
			if ("delete")
				stored_colours -= colour_tag
				nanopaint_indexes -= colour_tag
				components -= colour_tag

	else if (href_list["wash_pencil"])
		var/mob/living/carbon/C = usr
		if (!istype(C))
			return
		for (var/i = 1 to C.held_items.len)
			var/obj/O = C.held_items[i]
			if (istype(O, /obj/item/painting_brush))
				to_chat(usr, "<span class='notice'>You start cleaning \the [O]...</span>")
				if (do_after(usr, src, 1 SECONDS))
					to_chat(usr, "<span class='notice'>You finish cleaning \the [O].</span>")
					var/obj/item/painting_brush/PB = O
					PB.paint_color = null
					PB.update_icon()
	update_icon()


// DM-side procs of the palette colour mixing.
// DM doesn't have a RYB color space, so i'm doing this manually. #YOLO
/proc/rgbToRyb(list/rgb)
	// Soon-to-be result

	var/ryb = list("r" = 0, "y" = 0, "b" = 0, "a" = (rgb.len < 4 ? 255 : rgb[4]))

	// Make a copy of the input to work on
	var/tmpRgb = rgb.Copy()

	// Remove white component
	var/i = min(rgb[1], rgb[2], rgb[3])
	tmpRgb[1] -= i
	tmpRgb[2] -= i
	tmpRgb[3] -= i

	// Convert colors
	ryb["r"] = tmpRgb[1] - min(tmpRgb[1], tmpRgb[2])
	ryb["y"] = (tmpRgb[2] + min(tmpRgb[1], tmpRgb[2]))/2
	ryb["b"] = (tmpRgb[3] + tmpRgb[2] - min(tmpRgb[1], tmpRgb[2]))/2

	// Normalize
	var/tmpMax = max(tmpRgb[1], tmpRgb[2], tmpRgb[3])
	if (tmpMax > 0) // Avoid division by zero
		var/n = max(ryb["r"], ryb["y"], ryb["b"])/tmpMax
		if (n > 0.000001) // Should be zero, but floating point error could be an issue
			ryb["r"] /= n;
			ryb["y"] /= n;
			ryb["b"] /= n;
	else
		ryb["r"] = 0;
		ryb["y"] = 0;
		ryb["b"] = 0;

	// Add black component, and round floating point errors
	i = min(255 - rgb[1], 255 - rgb[2], 255 - rgb[3])
	ryb["r"] = round(ryb["r"] + i)
	ryb["y"] = round(ryb["y"] + i)
	ryb["b"] = round(ryb["b"] + i)
	return ryb;

/proc/rybToRgb(list/ryb)
	// Soon-to-be result
	var/rgb = list(0, 0, 0, ryb["a"])

	// Make a copy of the input to work on
	var/tmpRyb = ryb.Copy()

	// Remove black component
	var/i = min(ryb["r"], ryb["y"], ryb["b"]);
	tmpRyb["r"] -= i;
	tmpRyb["y"] -= i;
	tmpRyb["b"] -= i;

	// Convert colors
	rgb[1] = tmpRyb["r"] + tmpRyb["y"] - min(tmpRyb["y"], tmpRyb["b"]);
	rgb[2] = tmpRyb["y"] + min(tmpRyb["y"], tmpRyb["b"]);
	rgb[3] = 2*(tmpRyb["b"] - min(tmpRyb["y"], tmpRyb["b"]));
	/* According to the RYB papers linked in code\modules\html_interface\paintTool\paintTool.js,
	 * the formula for green should be:
	 *	"g = y + 2*min(y, b)"
	 * But for whatever godforsaken reason that returns wrong values for colors where y < b
	 * (eg: cyan). Got rid of the '2*' on a hunch and sure it WORKS without breaking anything
	 * else, but WHY?????
	 */

	// Normalize
	var/tmpMax = max(tmpRyb["r"], tmpRyb["y"], tmpRyb["b"])
	if (tmpMax > 0) // Avoid division by zero
		var/n = max(rgb[1], rgb[2], rgb[3])/max(tmpRyb["r"], tmpRyb["y"], tmpRyb["b"])
		if (n > 0.000001) // Should be zero, but floating point error could be an issue
			rgb[1] /= n;
			rgb[2] /= n;
			rgb[3] /= n;
	else
		rgb[1] = 0;
		rgb[2] = 0;
		rgb[3] = 0;

	// Add white component, and round floating point errors
	i = min(255 - ryb["r"], 255 - ryb["y"], 255 - ryb["b"])
	rgb[1] = round(rgb[1] + i)
	rgb[2] = round(rgb[2] + i)
	rgb[3] = round(rgb[3] + i)
	return rgb

/proc/colorRybBlend(var/list/c1, var/list/c2, alpha)
	var/c1Ryb = rgbToRyb(c1)
	var/c2Ryb = rgbToRyb(c2)
	var/resultRyb = list("r" = 0, "y" = 0, "b" = 0, "a" = (c2.len < 4 ? 255 : c2[4]));

	alpha *= (c1Ryb["a"] / 255)

	resultRyb["r"] = round(alpha * c1Ryb["r"] + (1-alpha) * c2Ryb["r"])
	resultRyb["y"] = round(alpha * c1Ryb["y"] + (1-alpha) * c2Ryb["y"])
	resultRyb["b"] = round(alpha * c1Ryb["b"] + (1-alpha) * c2Ryb["b"])
	return rybToRgb(resultRyb)

/proc/BlendRYB(rgb1, rgb2, amount)
	if (length(rgb1) < 8)
		rgb1 += "FF"
	if (length(rgb2) < 8)
		rgb2 += "FF"
	var/blend = colorRybBlend(rgb2num(rgb1), rgb2num(rgb2), amount)
	return rgb(blend[1], blend[2], blend[3], blend[4], "COLORSPACE_RGB")
