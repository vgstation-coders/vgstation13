#define DRYING_TIME 5 * 60*10			//for 1 unit of depth in puddle (amount var)

var/global/list/image/splatter_cache=list()
var/global/list/blood_list = list()

/obj/effect/decal/cleanable/blood
	name = "blood"
	desc = "It's thick and gooey. Perhaps it's the chef's cooking?"
	gender = PLURAL
	density = 0
	anchored = 1
	icon = 'icons/effects/blood.dmi'
	icon_state = "mfloor1"
	random_icon_states = list("mfloor1", "mfloor2", "mfloor3", "mfloor4", "mfloor5", "mfloor6", "mfloor7")
	plane = ABOVE_TURF_PLANE
	layer = BLOOD_LAYER
	appearance_flags = TILE_BOUND|LONG_GLIDE
	var/base_icon = 'icons/effects/blood.dmi'

	basecolor=DEFAULT_BLOOD // Color when wet.
	amount = 5
	counts_as_blood = 1
	transfers_dna = 1
	absorbs_types=list(/obj/effect/decal/cleanable/blood,/obj/effect/decal/cleanable/blood/drip,/obj/effect/decal/cleanable/blood/writing)

	persistence_type = SS_BLOOD

/obj/effect/decal/cleanable/blood/New(var/loc, var/age, var/icon_state, var/color, var/dir, var/pixel_x, var/pixel_y, var/basecolor)
	if(basecolor)
		src.basecolor = basecolor
	..()

/obj/effect/decal/cleanable/blood/Destroy()
	..()
	blood_DNA = null
	virus2 = null

/obj/effect/decal/cleanable/blood/cultify()
	return

/obj/effect/decal/cleanable/blood/update_icon()
	color = basecolor
	update_plane()

/obj/effect/decal/cleanable/blood/proc/update_plane()
	if(basecolor == "#FF0000" || basecolor == DEFAULT_BLOOD) // no dirty dumb vox scum allowed
		plane = NOIR_BLOOD_PLANE
	else
		plane = ABOVE_TURF_PLANE

/obj/effect/decal/cleanable/blood/atom2mapsave()
	. = ..()
	.["basecolor"] = adjust_brightness(basecolor, -100/(age*2))

/obj/effect/decal/cleanable/blood/setPersistenceAge(var/nu)
	. = ..()
	dry(nu)

/obj/effect/decal/cleanable/blood/dry(var/drying_age = 1)
	amount = 0
	name = "dried [replacetext(initial(src.name), "wet ", "")]"
	desc = "It's dry and crusty. Someone is not doing their job."
	switch(drying_age)
		if(3)
			desc = "This looks like it's been sitting there a good while."
		if(4)
			alpha = 220
			name = "old [replacetext(initial(src.name), "wet ", "")]"
			desc = "It's dry, dark, flakey, and crackled throughout. Perhaps it's the chef's cooking?"
		if(5)
			alpha = 200
			name = "crusty old [replacetext(initial(src.name), "wet ", "")]"
			desc = "Probably too late to put it back in."
	update_icon()

/obj/effect/decal/cleanable/blood/splatter
	random_icon_states = list("mgibbl1", "mgibbl2", "mgibbl3", "mgibbl4", "mgibbl5")
	amount = 2

/obj/effect/decal/cleanable/blood/drip
	name = "drips of blood"
	desc = "Dried, crusty, and slightly upsetting."
	gender = PLURAL
	icon = 'icons/effects/drip.dmi'
	icon_state = "1"
	random_icon_states = list("1","2","3","4","5")
	amount = 0

	base_icon = 'icons/effects/drip.dmi'

/obj/effect/decal/cleanable/blood/writing
	icon_state = "tracks"
	desc = "It looks like a writing in blood."
	gender = NEUTER
	random_icon_states = list("writing1","writing2","writing3","writing4","writing5")
	amount = 0
	var/message

/obj/effect/decal/cleanable/blood/writing/New()
	..()
	if(random_icon_states.len)
		for(var/obj/effect/decal/cleanable/blood/writing/W in loc)
			random_icon_states.Remove(W.icon_state)
		icon_state = pick(random_icon_states)
	else
		icon_state = "writing1"

/obj/effect/decal/cleanable/blood/writing/examine(mob/user)
	..()
	to_chat(user, "It reads: <font color='[basecolor]'>\"[message]\"<font>")

/obj/effect/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "They look bloody and gruesome."
	gender = PLURAL
	density = 0
	anchored = 1
	icon = 'icons/effects/blood.dmi'
	icon_state = "gibbl5"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")
	persistence_type = SS_GIBS
	var/fleshcolor = DEFAULT_FLESH

/obj/effect/decal/cleanable/blood/gibs/New(var/loc, var/age, var/icon_state, var/color, var/dir, var/pixel_x, var/pixel_y, var/basecolor, var/fleshcolor)
	if(fleshcolor)
		src.fleshcolor = fleshcolor
	..()

/obj/effect/decal/cleanable/blood/gibs/atom2mapsave()
	. = ..()
	.["fleshcolor"] = adjust_RGB(fleshcolor, red = -10, green = 10)

/obj/effect/decal/cleanable/blood/gibs/update_icon()
	color = basecolor

	var/image/giblets = new(base_icon, "[icon_state]_flesh", dir)
	giblets.appearance_flags = RESET_COLOR
	giblets.layer = GIBS_OVERLAY_LAYER
	giblets.color = fleshcolor

	overlays.len = 0
	overlays += giblets

	update_plane()

/obj/effect/decal/cleanable/blood/gibs/dry(var/drying_age = 1)
	if(drying_age > 1)
		amount = 0
	switch(drying_age)
		if(2)
			name = "old [initial(src.name)]"
			desc = "Looks bloated and in decay. Smells as bad as it looks."
		if(3)
			name = "rotting [initial(src.name)]"
			desc = "Looks congealed, gruesome, and positively nasty."
		if(4)
			name = "rotten [initial(src.name)]"
			desc = "Looks putrid, wet, and... deflated."
			alpha = 220
		if(5)
			name = "decomposing [initial(src.name)]"
			desc = "Looks... runny. Eugh."
			alpha = 200
	update_icon()

/obj/effect/decal/cleanable/blood/gibs/up
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibup1","gibup1","gibup1")

/obj/effect/decal/cleanable/blood/gibs/down
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibdown1","gibdown1","gibdown1")

/obj/effect/decal/cleanable/blood/gibs/body
	random_icon_states = list("gibhead", "gibtorso")

/obj/effect/decal/cleanable/blood/gibs/limb
	random_icon_states = list("gibleg", "gibarm")

/obj/effect/decal/cleanable/blood/gibs/core
	random_icon_states = list("gibmid1", "gibmid2", "gibmid3")

/obj/effect/decal/cleanable/blood/gibs/core/New()
	..()
	playsound(src, get_sfx("gib"),50,1)




/obj/effect/decal/cleanable/blood/viralsputum
	name = "viral sputum"
	desc = "It's black and nasty."
	basecolor="#030303"
	icon = 'icons/mob/robots.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")

/obj/effect/decal/cleanable/blood/viralsputum/Destroy()
	for(var/datum/disease/D in viruses)
		D.cure(0)
	..()




//We should really get directional blood streak sprites again --snx
/obj/effect/decal/cleanable/blood/proc/streak(var/list/directions, spread_radius = 0)
	spawn (0)
		var/direction = pick(directions)
		for (var/i = 0 to spread_radius)
			sleep(3)
			if (i > 0)
				var/obj/effect/decal/cleanable/blood/b = getFromPool(/obj/effect/decal/cleanable/blood/splatter, src.loc)
				b.New(src.loc)
				b.basecolor = src.basecolor
				b.update_icon()
				for(var/datum/disease/D in src.viruses)
					var/datum/disease/ND = D.Copy(1)
					b.viruses += ND
					ND.holder = b

			step_to(src, get_step(src, direction), 0)


/obj/effect/decal/cleanable/mucus
	name = "mucus"
	desc = "Disgusting mucus."
	gender = PLURAL
	density = 0
	anchored = 1
	icon = 'icons/effects/blood.dmi'
	icon_state = "mucus"
	random_icon_states = list("mucus")

	var/dry=0
