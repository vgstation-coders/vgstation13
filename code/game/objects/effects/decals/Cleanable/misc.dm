/obj/effect/decal/cleanable/generic
	name = "clutter"
	desc = "Someone should clean that up."
	gender = PLURAL
	density = 0
	anchored = 1
	icon = 'icons/obj/objects.dmi'
	icon_state = "shards"

/obj/effect/decal/cleanable/ash
	name = "ashes"
	desc = "Ashes to ashes, dust to dust, and into space."
	gender = PLURAL
	reagent = TOXIN //ash is bad for you!
	icon = 'icons/obj/objects.dmi'
	icon_state = "ash"
	anchored = 1

/obj/effect/decal/cleanable/ash/attack_hand(mob/user as mob)
	user.visible_message("<span class='notice'>[user] wipes away \the [src].</span>")
	qdel(src)

/obj/effect/decal/cleanable/dirt
	name = "dirt"
	desc = "Someone should clean that up."
	gender = PLURAL
	density = 0
	anchored = 1
	icon = 'icons/effects/effects.dmi'
	icon_state = "dirt"

/obj/effect/decal/cleanable/flour
	name = "flour"
	desc = "It's still good. Four second rule!"
	gender = PLURAL
	density = 0
	anchored = 1
	reagent = FLOUR
	icon = 'icons/effects/effects.dmi'
	icon_state = "flour"

/obj/effect/decal/cleanable/pepper
	name = "black pepper"
	desc = "*AAAACHOOO*"
	gender = PLURAL
	density = 0
	anchored = 1
	reagent = BLACKPEPPER
	icon = 'icons/effects/effects.dmi'
	icon_state = "pepper"

/obj/effect/decal/cleanable/crumbs
	name = "crumbs"
	desc = "some food remains"
	gender = PLURAL
	density = 0
	anchored = 1
	reagent = NUTRIMENT
	icon = 'icons/effects/effects.dmi'
	icon_state = "crumbs"
	plane = OBJ_PLANE
	layer = TABLE_LAYER+0.1
	age = 3

/obj/effect/decal/cleanable/crumbs/New()
	..()
	pixel_x = rand (-4,4) * PIXEL_MULTIPLIER
	pixel_y = rand (-4,4) * PIXEL_MULTIPLIER

/obj/effect/decal/cleanable/greenglow
	name = "glowing goo"
	desc = "Jeez. I hope that's not for lunch."
	gender = PLURAL
	density = 0
	anchored = TRUE
	reagent = RADIUM
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenglow"

/obj/effect/decal/cleanable/greenglow/New()
	..()
	set_light(1,2,COLOR_RADIUM)

/obj/effect/decal/cleanable/blueglow
	name = "glowing luminol"
	desc = "A smear of activated luminol."
	gender = PLURAL
	density = 0
	anchored = TRUE
	reagent = LUMINOL
	icon = 'icons/effects/blood.dmi'
	icon_state = "mfloor1"
	//icon = 'icons/effects/tomatodecal.dmi'
	//icon_state = "fruit_smudge1"
	color = LIGHT_COLOR_CYAN

/obj/effect/decal/cleanable/blueglow/New()
	..()
	icon_state = "mfloor[rand(1,7)]"
	////icon_state = "[pick("m","")]floor[rand(1,3)]"
	//icon_state = "fruit_smudge[rand(1,3)]"
	set_light(1,2,LIGHT_COLOR_BLUE)

/obj/effect/decal/cleanable/cobweb
	name = "cobweb"
	desc = "Somebody should remove that."
	density = 0
	anchored = 1
	reagent = SPIDERS //no way this can go wrong, right?
	plane = ABOVE_HUMAN_PLANE
	icon = 'icons/effects/effects.dmi'
	icon_state = "cobweb1"

/obj/effect/decal/cleanable/molten_item
	name = "gooey grey mass"
	desc = "It looks like a melted... something."
	density = 0
	anchored = 1
	reagent = CHEMICAL_WASTE
	layer = OBJ_LAYER
	plane = OBJ_PLANE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "molten"
	persistence_type = null //Can get out of hand, description doesn't persist, makes you go hmmm if there's one piece of goo perfectly under each of your roundstart items

/obj/effect/decal/cleanable/cobweb2
	name = "cobweb"
	desc = "Somebody should remove that."
	density = 0
	anchored = 1
	reagent = SPIDERS
	plane = ABOVE_HUMAN_PLANE
	icon = 'icons/effects/effects.dmi'
	icon_state = "cobweb2"

//Vomit (sorry)
/obj/effect/decal/cleanable/vomit
	name = "vomit"
	desc = "Gosh, how unpleasant."
	gender = PLURAL
	density = 0
	anchored = 1
	reagent = VOMIT
	icon = 'icons/effects/blood.dmi'
	icon_state = "vomit_1"

	basecolor="#FFFF99"
	amount = 2
	random_icon_states = list("vomit_1", "vomit_2", "vomit_3", "vomit_4")
	transfers_dna = 1

	persistent_type_replacement = /obj/effect/decal/cleanable/vomit/pre_dry

	fake_DNA = "vomit splatters"
	stain_name = "vomit"

/obj/effect/decal/cleanable/vomit/pre_dry
	name = "dry vomit"
	mouse_opacity = 0
	amount = 0
	icon_state = "vomit_1_dry"
	random_icon_states = list("vomit_1_dry", "vomit_2_dry", "vomit_3_dry", "vomit_4_dry")

/obj/effect/decal/cleanable/vomit/active
	desc = "A small pool of vomit. Gosh, how unpleasant."
	mouse_opacity = 1
	flags = OPENCONTAINER
	var/dry_state = 40 //Decreases by 1. When it reaches 0, the vomit becomes dry

/obj/effect/decal/cleanable/vomit/active/New()
	..()

	dry_state = rand(50,80)
	create_reagents(10)
	reagents.add_reagent(VOMIT, rand(2,5))

	processing_objects.Add(src)

/obj/effect/decal/cleanable/vomit/active/Destroy()
	..()

	processing_objects.Remove(src)

/obj/effect/decal/cleanable/vomit/active/process()
	if(--dry_state <= 0) //Decrease dry_state by 1. Check if it's equal to zero
		dry()

/obj/effect/decal/cleanable/vomit/dry(var/drying_age)
	processing_objects.Remove(src)

	name = "dry [src.name]"
	icon_state = "vomit_[rand(1,4)]_dry"
	amount = 0
	QDEL_NULL(reagents)

/obj/effect/decal/cleanable/tomato_smudge
	name = "tomato smudge"
	desc = "It's red."
	density = 0
	anchored = 1
	reagent = TOMATOJUICE
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("tomato_floor1", "tomato_floor2", "tomato_floor3")

/obj/effect/decal/cleanable/fruit_smudge
	name = "smudge"
	desc = "Some kind of fruit smear."
	density = 0
	anchored = 1
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("fruit_smudge1", "fruit_smudge2", "fruit_smudge3")
	icon_state = "fruit_smudge1"

/obj/effect/decal/cleanable/egg_smudge
	name = "smashed egg"
	desc = "Seems like this one won't hatch."
	density = 0
	anchored = 1
	reagent = EGG_YOLK
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("smashed_egg1", "smashed_egg2", "smashed_egg3", "smashed_egg4")

/obj/effect/decal/cleanable/pie_smudge //honk
	name = "smashed pie"
	desc = "It's pie cream from a cream pie."
	density = 0
	anchored = 1
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("smashed_pie")

/obj/effect/decal/cleanable/spaghetti_spill
	name = "spilled spaghetti"
	desc = "A result of bursting into treats from awkward situations."
	density = 0
	anchored = 1
	reagent = SPAGHETTI
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("smashed_spaghetti")

/obj/effect/decal/cleanable/scattered_sand
	name = "scattered sand"
	desc = "Now how are you gonna sweep it back up, smartass?"
	density = 0
	anchored = 1
	icon = 'icons/effects/effects.dmi'
	icon_state = "sand"
	gender = PLURAL

/obj/effect/decal/cleanable/campfire
	name = "burnt out campfire"
	icon_state = "campfire"
	desc = "This burnt-out campfire reminds you of someone."
	anchored = 1
	density = 0
	reagent = TOXIN //ash is bad for you!
	icon = 'icons/obj/atmos.dmi'
	icon_state = "campfire_burnt"
	mouse_opacity = 1

/obj/effect/decal/cleanable/campfire/attackby(obj/item/I, mob/living/user)
	if (istype(I, /obj/item/stack/sheet/wood))
		var/obj/machinery/space_heater/campfire/C = new /obj/machinery/space_heater/campfire
		C.cell.charge = 0
		if (C.addWood(I, user))
			C.loc = src.loc
			qdel(src)
		else
			qdel(C)
	else
		. = ..()

/obj/effect/decal/cleanable/clay_fragments
	name = "clay fragments"
	desc = "Pieces from a broken clay pot."
	gender = PLURAL
	icon = 'icons/effects/tomatodecal.dmi'
	icon_state = "clay_fragments"
	anchored = 0
	mouse_opacity = 1

/obj/effect/decal/cleanable/clay_fragments/New()
	..()
	pixel_x = rand (-3,3) * PIXEL_MULTIPLIER
	pixel_y = rand (-3,3) * PIXEL_MULTIPLIER

/obj/effect/decal/cleanable/broken_plate
	name = "broken plate"
	desc = "Pieces from a broken plate."
	gender = PLURAL
	icon = 'icons/obj/trash.dmi'
	icon_state = "brokenplate"
	anchored = 0
	mouse_opacity = 1

/obj/effect/decal/cleanable/broken_plate/New()
	..()
	pixel_x = rand (-3,3) * PIXEL_MULTIPLIER
	pixel_y = rand (-3,3) * PIXEL_MULTIPLIER

/obj/effect/decal/cleanable/soot
	name = "soot"
	desc = "One hell of a party..."
	gender = PLURAL
	icon = 'icons/effects/tile_effects.dmi'
	icon_state = "tile_soot"
	anchored = 1

	persistence_type = null //Okay, this one is probably too much. A shitton of these get made every plasmaflood and it's not very interesting to clean up.


/obj/effect/decal/cleanable/soot/New()
	..()
	dir = pick(cardinal)

/obj/effect/decal/cleanable/lspaceclutter
	name = "clutter"
	gender = PLURAL
	density = 0
	anchored = 1
	reagent = TOXIN //ash is bad for you!
	icon = 'icons/effects/effects.dmi'
	icon_state = "lspaceclutter"

/obj/effect/decal/cleanable/cockroach_remains
	name = "cockroach remains"
	desc = "A disgusting mess."
	icon = 'icons/mob/animal.dmi'
	icon_state = "cockroach_remains1"
	reagent = ROACHSHELL

/obj/effect/decal/cleanable/cockroach_remains/New()
	..()
	icon_state = "cockroach_remains[rand(1,2)]"

/obj/effect/decal/cleanable/cricket_remains
	name = "cricket remains"
	desc = "A disgusting mess."
	icon = 'icons/mob/animal.dmi'
	icon_state = "cockroach_remains1"
	reagent = FLOUR

/obj/effect/decal/cleanable/wizrune
	name = "rune"
	desc = "Looks unfinished."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "wizrune"

/obj/effect/decal/cleanable/smashed_butter
	name = "smashed butter"
	desc = "Looks like some one has butter fingers."
	icon = 'icons/effects/tomatodecal.dmi'
	icon_state = "smashed_butter"
	reagent = LIQUIDBUTTER

/obj/effect/decal/cleanable/virusdish
	name = "broken growth dish"
	desc = "Probably not safe to step on it with your feet naked. Someone should clean it up."
	icon = 'icons/obj/virology.dmi'
	icon_state = "brokendish-outline"
	density = 0
	anchored = 1
	reagent = VIRUSFOOD
	mouse_opacity = 1
	layer = OBJ_LAYER
	plane = OBJ_PLANE
	persistent_type_replacement = /obj/effect/decal/cleanable/virusdish/persistent
	var/last_openner
	var/datum/disease2/disease/contained_virus

/obj/effect/decal/cleanable/virusdish/Crossed(var/mob/living/perp)
	..()
	if (istype(perp))
		FeetStab(perp,damage = 10,knockdown = 0)
		infection_attempt(perp)

/obj/effect/decal/cleanable/virusdish/proc/infection_attempt(var/mob/living/perp)
	if (!contained_virus)
		return
	//Now if your feet aren't well protected, or are bleeding, you might get infected.
	var/block = 0
	var/bleeding = 0
	if(attempt_colony(perp,contained_virus,"from exposure to a broken virus dish."))
		return
	if (perp.lying)
		block = perp.check_contact_sterility(FULL_TORSO)
		bleeding = perp.check_bodypart_bleeding(FULL_TORSO)
	else
		block = perp.check_contact_sterility(FEET)
		bleeding = perp.check_bodypart_bleeding(FEET)

	if (!block)
		if (contained_virus.spread & SPREAD_CONTACT)
			perp.infect_disease2(contained_virus, notes="(Contact, from [perp.lying?"lying":"standing"] over a broken virus dish[last_openner ? " broken by [last_openner]" : ""])")
		else if (bleeding && (contained_virus.spread & SPREAD_BLOOD))
			perp.infect_disease2(contained_virus, notes="(Blood, from [perp.lying?"lying":"standing"] over a broken virus dish[last_openner ? " broken by [last_openner]" : ""])")

/obj/effect/decal/cleanable/virusdish/persistent
	desc = "Whatever kind of pathogenic culture was in there has long since decayed. Someone should still clean it up eventually."
	icon_state = "brokendish-persistent"
	persistent_type_replacement = null

/obj/effect/decal/cleanable/virusdish/persistent/post_mapsave2atom(var/list/L)
	icon_state = "brokendish-persistent"


var/list/salts_particle_emitters = list(
	/obj/effect/rune,
	/obj/item/weapon/tome,
	/obj/item/weapon/talisman,
	/obj/item/weapon/melee/cultblade,
	/obj/item/weapon/melee/soulblade,
	/obj/item/clothing/head/culthood,
	/obj/item/clothing/shoes/cult,
	/obj/item/clothing/suit/cultrobes,
	/obj/item/weapon/storage/backpack/cultpack,
	/obj/item/clothing/head/helmet/space/cult,
	/obj/item/clothing/suit/space/cult,
	/obj/item/weapon/bloodcult_pamphlet,
	/obj/item/weapon/storage/cult,
	/obj/item/weapon/reagent_containers/food/drinks/cult,
	/obj/item/weapon/handcuffs/cult,
	/obj/item/weapon/blood_tesseract
	)//those atoms will emit particles periodically when salt is placed upon them

/obj/effect/decal/cleanable/salt
	name = "salt"
	desc = "Guaranteed to ward off ghouls, ghosts, geists, and low blood pressure."
	gender = PLURAL
	reagent = SODIUMCHLORIDE
	icon = 'icons/effects/effects.dmi'
	icon_state = "salt"
	anchored = 1
	var/act_delay = 300 SECONDS

/obj/effect/decal/cleanable/salt/New()
	..()
	spawn()
		particleCheck()

	spawn(act_delay)
		act_delay = 0//stops the recursion of particleCheck()
		for (var/atom/movable/AM in loc)
			AM.salt_act()


/obj/effect/decal/cleanable/salt/proc/particleCheck()
	if (loc && !gcDestroyed && act_delay)
		for (var/atom/movable/AM in loc)
			if (is_type_in_list(AM, salts_particle_emitters))
				anim(target = loc, a_icon = 'icons/effects/effects.dmi', flick_anim = "const_heal", lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)
				break
		sleep(rand(1 SECONDS, 3 SECONDS))
		particleCheck()

/obj/effect/decal/cleanable/salt/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	..()
	if(isliving(mover))
		var/mob/living/L = mover
		if(checkUndead(L))
			to_chat(L, "<span class=danger>The salty ward repels you!</span>")
			return 0
		if(checkVamp(L))
			to_chat(L, "<span class=danger>The salty ward repels you!</span>")
			return 0
		if(isborer(L))
			saltTheWorm(L)
			return 0
	return 1

/obj/effect/decal/cleanable/salt/proc/checkUndead(var/mob/living/theGhoul)
	if(theGhoul.mob_property_flags & (MOB_UNDEAD|MOB_SUPERNATURAL))
		return TRUE
	if(isskellington(theGhoul) || isskelevox(theGhoul) || islich(theGhoul) || istype(theGhoul, /mob/living/carbon/monkey/skellington))
		return TRUE
	return FALSE

/obj/effect/decal/cleanable/salt/proc/checkVamp(var/mob/living/theVamp)
	if(isvampire(theVamp))
		var/datum/role/vampire/V = isvampire(theVamp)
		if(locate(/datum/power/vampire/charisma) in V.current_powers)	//He's already a powerful vamp, the check is no longer meta
			return TRUE
	return FALSE

/obj/effect/decal/cleanable/salt/proc/saltTheWorm(var/mob/living/theBorer)
	to_chat(theBorer, "<span class=danger>The salt, it burns!</span>")
	theBorer.health -= rand(5,25)	//Borers have 20 health
	theBorer.Stun(50)

/obj/effect/decal/cleanable/salt/holy
	name = "holy salts"
	desc = "Blessed salts have been used for centuries as a sacramental."
	gender = PLURAL
	reagent = HOLYSALTS
	icon = 'icons/effects/effects.dmi'
	icon_state = "holysalt"
	anchored = 1
	act_delay = 20 SECONDS

/obj/effect/decal/cleanable/purpledrank
	name = "weeds?"
	desc = "Someone spilled some grape juice? here."
	gender = PLURAL
	density = 0
	anchored = 1
	icon = 'icons/mob/alien.dmi'
	icon_state = "weeds"

/obj/effect/decal/cleanable/glue
	name = "glue"
	desc = "The floor is sticky!"
	density = 0
	anchored = 1
	icon = 'icons/effects/effects.dmi'
	icon_state = "glue"
	color = COLOR_GLUE
	persistence_type = null//better not
	slowdown_modifier = 4

/obj/effect/decal/cleanable/glue/clean_act()
	qdel(src)
