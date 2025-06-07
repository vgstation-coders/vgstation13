//List of all drawable graffitis. Their icon states are associated with icon states (so for example "Chaos Undivided" = "chaos")
var/global/list/all_graffitis = list(
	"Left arrow"="left",
	"Right arrow"="right",
	"Up arrow"="up",
	"Down arrow"="down",
	"Heart"="heart",
	"Lambda"="lambda",
	"50 blessings"="50bless",
	"Engineer"="engie",
	"Guy"="guy",
	"The end is nigh"="end",
	"Amy + Jon"="amyjon",
	"Matt was here"="matt",
	"Revolution"="revolution",
	"Face"="face",
	"Dwarf"="dwarf",
	"Uboa"="uboa",
	"Rogue cyborgs"="borgsrogue",
	"Shitcurity"="shitcurity",
	"Catbeast here"="catbeast",
	"Vox are pox"="voxpox",
	"Hieroglyphs 1"="hieroglyphs1",
	"Hieroglyphs 2"="hieroglyphs2",
	"Hieroglyphs 3"="hieroglyphs3",
	"Securites eunt domus"="security",
	"Nanotrasen logo"="nanotrasen",
	"Syndicate logo 1"="syndicate1",
	"Syndicate logo 2"="syndicate2",
	"Don't believe these lies"="lie",
	"Chaos Undivided"="chaos"
)

/obj/item/toy/crayon/red
	icon_state = "crayonred"
	mainColour = "#DA0000"
	shadeColour = "#810C0C"
	colourName = "red"

/obj/item/toy/crayon/orange
	icon_state = "crayonorange"
	mainColour = "#FF9300"
	shadeColour = "#A55403"
	colourName = "orange"

/obj/item/toy/crayon/yellow
	icon_state = "crayonyellow"
	mainColour = "#FFF200"
	shadeColour = "#886422"
	colourName = "yellow"

/obj/item/toy/crayon/green
	icon_state = "crayongreen"
	mainColour = "#A8E61D"
	shadeColour = "#61840F"
	colourName = "green"

/obj/item/toy/crayon/blue
	icon_state = "crayonblue"
	mainColour = "#00B7EF"
	shadeColour = "#0082A8"
	colourName = "blue"

/obj/item/toy/crayon/purple
	icon_state = "crayonpurple"
	mainColour = "#DA00FF"
	shadeColour = "#810CFF"
	colourName = "purple"

/obj/item/toy/crayon/black
	icon_state = "crayonblack"
	mainColour = "#222222"
	shadeColour = "#000000"
	colourName = "black"

/obj/item/toy/crayon/mime
	icon_state = "crayonmime"
	desc = "A very sad-looking crayon."
	mainColour = "#FFFFFF"
	shadeColour = "#000000"
	colourName = "mime"
	uses = 0

/obj/item/toy/crayon/mime/attack_self(mob/living/user as mob) //inversion
	if(mainColour != "#FFFFFF" && shadeColour != "#000000")
		mainColour = "#FFFFFF"
		shadeColour = "#000000"
		to_chat(user, "You will now draw in white and black with this crayon.")
	else
		mainColour = "#000000"
		shadeColour = "#FFFFFF"
		to_chat(user, "You will now draw in black and white with this crayon.")
	return

/obj/item/toy/crayon/rainbow
	icon_state = "crayonrainbow"
	mainColour = "#FFF000"
	shadeColour = "#000FFF"
	colourName = "rainbow"
	uses = 0

/obj/item/toy/crayon/rainbow/attack_self(mob/living/user as mob)
	mainColour = input(user, "Please select the main colour.", "Crayon colour") as color
	shadeColour = input(user, "Please select the shade colour.", "Crayon colour") as color
	return

/obj/item/toy/crayon/afterattack(atom/target, mob/user as mob, proximity, click_parameters)
	if(!proximity)
		return

	if(istype(target, /turf/simulated))
		var/drawtype = input("Choose what you'd like to draw.", "Crayon scribbles") as null|anything in list("graffiti","rune","letter","text", "advanced graffiti")
		var/preference
		var/drawtime = 50
		var/fontsize = 6 //For text
		var/pix_x = text2num(params2list(click_parameters)["icon-x"]) - (drawtype == "text" ? length(preference)*(fontsize/2) : 16)
		var/pix_y = text2num(params2list(click_parameters)["icon-y"]) - (drawtype == "text" ? fontsize : 16)

		if(!drawtype)
			return

		switch(drawtype)
			if("letter")
				drawtype = input("Choose the letter.", "Crayon scribbles") in list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
				to_chat(user, "You start drawing a letter on the [target.name].")
			if("graffiti")
				var/list/graffitis = list("Random" = "graffiti") + all_graffitis
				if(istype(user,/mob/living/carbon/human))
					var/mob/living/carbon/human/M=user
					if(M.getBrainLoss() >= 60)
						graffitis = list(
							"Cancel"="cancel",
							"Dick"="dick[rand(1,3)]",
							"Valids"="valid"
							)
				preference = input("Choose the graffiti.", "Crayon scribbles") as null|anything in graffitis

				if(!preference)
					return

				drawtype=graffitis[preference]
				to_chat(user, "You start drawing graffiti on \the [target].")
			if("rune")
				to_chat(user, "You start drawing a rune on \the [target].")
				pix_x = 0
				pix_y = 0
			if("text")
				fontsize = input("How big should the text be, in pts?", "Crayon scribbles", "[CRAYON_MIN_FONTSIZE]") as num
				if(!fontsize)
					return
				fontsize = clamp(fontsize,CRAYON_MIN_FONTSIZE,CRAYON_MAX_FONTSIZE)

				preference = sanitize(input("Write some text here (maximum ([CRAYON_MAX_LETTERS/(fontsize/CRAYON_MIN_FONTSIZE)]) letters).", "Crayon scribbles") as null|text)

				var/letter_amount = length(replacetext(preference, " ", ""))
				if(!letter_amount) //If there is no text
					return
				drawtime = 4 * letter_amount * (fontsize/8) //10 letters at 8pt = 4 seconds, 5 at 16pt = 4 seconds
				preference = copytext(preference, 1, (CRAYON_MAX_LETTERS/(fontsize/CRAYON_MIN_FONTSIZE))+1)

				if(user.client)
					var/obj/effect/decal/cleanable/crayon/text/example = new(null, size = fontsize, fontname = clumsy_check(user) ? "Comic Sans MS" : "DK Cool Crayon", color = mainColour, type = preference, pixel_x = pix_x, pixel_y = pix_y)
					var/image/I = image(icon = null) //Create an empty image. You can't just do "image()" for some reason, at least one argument is needed
					I.maptext = example.maptext
					I.loc = get_turf(target)
					I.maptext_height = example.maptext_height
					I.maptext_width = example.maptext_width
					I.maptext_y = example.maptext_y
					I.pixel_x = example.pixel_x
					I.pixel_y = example.pixel_y
					qdel(example)
					animate(I, alpha = 100, 10, -1)

					user.client.images.Add(I)
					var/continue_drawing = alert(user, "This is how your drawing will look. Continue?", "Crayon scribbles", "Yes", "Cancel")

					user.client.images.Remove(I)
					animate(I) //Cancel the animation so that the image gets garbage collected
					I.loc = null
					I = null

					if(continue_drawing != "Yes")
						return

				to_chat(user, "You start writing \"[preference]\" on \the [target].")

			if ("advanced graffiti")
				var/turf/simulated/the_turf = target
				var/datum/painting_utensil/p = new(user, src)
				if (!the_turf.advanced_graffiti)
					var/datum/custom_painting/advanced_graffiti = new(the_turf, 32, 32, base_color = "#00000000")
					the_turf.advanced_graffiti = advanced_graffiti
				the_turf.advanced_graffiti.interact(user, p)
				return

		if(!user.Adjacent(target))
			return
		if(target.density && !cardinal.Find(get_dir(user, target))) //Drawing on a wall and not standing in a cardinal direction - don't draw
			to_chat(user, "<span class='warning'>You can't reach \the [target] from here!</span>")
			return

		if(instant || do_after(user,target, drawtime))
			if(drawtype == "text")
				new /obj/effect/decal/cleanable/crayon/text(target, size = fontsize, fontname = clumsy_check(user) ? "Comic Sans MS" : "DK Cool Crayon", color = mainColour, type = preference, pixel_x = pix_x, pixel_y = pix_y)
			else
				new /obj/effect/decal/cleanable/crayon(target, color = mainColour, shade = shadeColour, type = drawtype, pixel_x = pix_x, pixel_y = pix_y)

			to_chat(user, "You finish drawing.")
			target.add_fingerprint(user)		// Adds their fingerprints to the floor the crayon is drawn on.
			if(uses)
				uses--
				if(!uses)
					to_chat(user, "<span class='warning'>You used up your crayon!</span>")
					qdel(src)

/obj/item/toy/crayon/attack(mob/M as mob, mob/user as mob)
	if(M == user)
		user.visible_message("<span class='notice'>[user] bites a chunk out of \the [src].</span>", \
			"<span class='notice'>You bite a chunk out of \the [src].</span>")
		user.nutrition += 5
		score.foodeaten++
		if(ispath(text2path("/datum/reagent/paint/[colourName]")) && M.reagents)
			M.reagents.add_reagent("paint_[colourName]", 10)
		if(uses)
			uses -= 5
			if(uses <= 0)
				user.visible_message("<span class='notice'>[user] swallows what was left of \the [src].</span>", \
					"<span class='notice'>You finish eating \the [src].</span>")
				qdel(src)
	else
		..()
