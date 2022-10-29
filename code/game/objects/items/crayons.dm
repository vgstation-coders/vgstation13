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

#define MAX_LETTERS 10
#define MIN_FONTSIZE 8
#define MAX_FONTSIZE 16
/obj/item/toy/crayon/afterattack(atom/target, mob/user as mob, proximity, click_parameters)
	if(!proximity)
		return

	if(istype(target, /turf/simulated))
		var/drawtype = input("Choose what you'd like to draw.", "Crayon scribbles") as null|anything in list("graffiti","rune","letter","text")
		var/preference
		var/drawtime = 50
		var/fontsize = 6 //For text

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
			if("text")
				fontsize = input("How big should the text be, in pts?", "Crayon scribbles", "6") as num
				if(!fontsize)
					return
				fontsize = clamp(fontsize,MIN_FONTSIZE,MAX_FONTSIZE)

				preference = input("Write some text here (maximum ([MAX_LETTERS/(fontsize/MIN_FONTSIZE)]) letters).", "Crayon scribbles") as null|text

				var/letter_amount = length(replacetext(preference, " ", ""))
				if(!letter_amount) //If there is no text
					return
				drawtime = 4 * letter_amount * (fontsize/8) //10 letters at 8pt = 4 seconds, 5 at 16pt = 4 seconds
				preference = copytext(preference, 1, (MAX_LETTERS/(fontsize/MIN_FONTSIZE))+1)

				if(user.client)
					var/image/I = image(icon = null) //Create an empty image. You can't just do "image()" for some reason, at least one argument is needed
					I.maptext = {"<span style="color:[mainColour];font-size:[fontsize]pt;font-family:'Comic Sans MS';">[preference]</span>"}
					I.loc = get_turf(target)
					I.maptext_height = 32
					I.maptext_width = 64
					I.maptext_y = -2
					I.pixel_x = text2num(params2list(click_parameters)["icon-x"]) - length(preference)*(fontsize/2)
					I.pixel_y = text2num(params2list(click_parameters)["icon-y"]) - fontsize
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

		if(!user.Adjacent(target))
			return
		if(target.density && !cardinal.Find(get_dir(user, target))) //Drawing on a wall and not standing in a cardinal direction - don't draw
			to_chat(user, "<span class='warning'>You can't reach \the [target] from here!</span>")
			return

		if(instant || do_after(user,target, drawtime))
			var/obj/effect/decal/cleanable/C
			if(drawtype == "text")
				C = new /obj/effect/decal/cleanable/crayon/text(target, size = fontsize, main = mainColour, type = preference)
			else
				C = new /obj/effect/decal/cleanable/crayon(target, main = mainColour, shade = shadeColour, type = drawtype)
			C.pixel_x = drawtype != "rune" ? text2num(params2list(click_parameters)["icon-x"]) - (drawtype == "text" ? length(preference)*(fontsize/2) : 16) : -16
			C.pixel_y = drawtype != "rune" ? text2num(params2list(click_parameters)["icon-y"]) - (drawtype == "text" ? fontsize : 16) : -16

			var/desired_density = 0
			var/x_offset = 0
			var/y_offset = 0
			if(target.density && (C.loc != get_turf(user))) //Drawn on a wall (while standing on a floor)
				desired_density = !desired_density
				C.forceMove(get_turf(user))
				var/angle = dir2angle_t(get_dir(C, target))
				x_offset = WORLD_ICON_SIZE * cos(angle)
				y_offset = WORLD_ICON_SIZE * sin(angle) //Offset the graffiti to make it appear on the wall
				C.on_wall = target

			for(var/direction in alldirs)
				var/turf/current_turf = get_step(target,direction)
				if(current_turf.density != desired_density)
					switch(direction)
						if(WEST)
							C.pixel_x = max(C.pixel_x, 0)
						if(SOUTH || SOUTHEAST || SOUTHWEST)
							C.pixel_y = max(C.pixel_y, 0)
						if(EAST)
							if(istype(C,/obj/effect/decal/cleanable/crayon/text))
								var/obj/effect/decal/cleanable/crayon/text/CT = C
								CT.name = copytext(CT.name, 1, (MAX_LETTERS/(CT.fontsize/(MIN_FONTSIZE/2))))
								CT.maptext_width = 32
								CT.update_icon()
							C.pixel_x = min(C.pixel_x, 0)
						if(NORTH || NORTHEAST || NORTHWEST)
							C.pixel_y = min(C.pixel_y, drawtype == "text" ? max(0,C.maptext_height - (fontsize*1.5)) : 0)
			C.pixel_x += x_offset
			C.pixel_y += y_offset

			to_chat(user, "You finish drawing.")
			target.add_fingerprint(user)		// Adds their fingerprints to the floor the crayon is drawn on.
			if(uses)
				uses--
				if(!uses)
					to_chat(user, "<span class='warning'>You used up your crayon!</span>")
					qdel(src)

#undef MIN_FONTSIZE
#undef MAX_FONTSIZE
#undef MAX_LETTERS

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
