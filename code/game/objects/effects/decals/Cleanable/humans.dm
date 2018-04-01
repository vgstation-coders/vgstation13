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
	appearance_flags = TILE_BOUND
	var/base_icon = 'icons/effects/blood.dmi'

	basecolor=DEFAULT_BLOOD // Color when wet.
	amount = 5
	counts_as_blood = 1
	transfers_dna = 1
	absorbs_types=list(/obj/effect/decal/cleanable/blood,/obj/effect/decal/cleanable/blood/drip,/obj/effect/decal/cleanable/blood/writing)

/obj/effect/decal/cleanable/blood/Destroy()
	..()
	blood_DNA = null
	virus2 = null

/obj/effect/decal/cleanable/blood/cultify()
	return

/obj/effect/decal/cleanable/blood/update_icon()
	if(basecolor == "rainbow")
		basecolor = "#[pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"
	color = basecolor
	if(basecolor == "#FF0000"||basecolor == DEFAULT_BLOOD) // no dirty dumb vox scum allowed
		plane = NOIR_BLOOD_PLANE
	else
		plane = ABOVE_TURF_PLANE
	var/icon/blood = icon(base_icon,icon_state,dir)
	blood.Blend(basecolor,ICON_MULTIPLY)

	icon = blood

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
	var/fleshcolor = "#FFFFFF"

/obj/effect/decal/cleanable/blood/gibs/update_icon()
	if(basecolor == "#FF0000"||basecolor == DEFAULT_BLOOD) // no dirty dumb vox scum allowed
		plane = NOIR_BLOOD_PLANE
	else
		plane = ABOVE_TURF_PLANE
	var/image/giblets = new(base_icon, "[icon_state]_flesh", dir)
	if(!fleshcolor || fleshcolor == "rainbow")
		fleshcolor = "#[pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"
	giblets.color = fleshcolor

	var/icon/blood = new(base_icon,"[icon_state]",dir)
	if(basecolor == "rainbow")
		basecolor = "#[pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"
	blood.Blend(basecolor,ICON_MULTIPLY)

	icon = blood
	overlays.len = 0
	overlays += giblets

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
	setGender(PLURAL)
	density = 0
	anchored = 1
	icon = 'icons/effects/blood.dmi'
	icon_state = "mucus"
	random_icon_states = list("mucus")

	var/dry=0
