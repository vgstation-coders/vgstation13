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
	icon = 'icons/effects/effects.dmi'
	icon_state = "flour"

/obj/effect/decal/cleanable/greenglow
	name = "glowing goo"
	desc = "Jeez. I hope that's not for lunch."
	gender = PLURAL
	density = 0
	anchored = 1
	luminosity = 1
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenglow"

/obj/effect/decal/cleanable/cobweb
	name = "cobweb"
	desc = "Somebody should remove that."
	density = 0
	anchored = 1
	plane = ABOVE_HUMAN_PLANE
	icon = 'icons/effects/effects.dmi'
	icon_state = "cobweb1"

/obj/effect/decal/cleanable/molten_item
	name = "gooey grey mass"
	desc = "It looks like a melted... something."
	density = 0
	anchored = 1
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
	icon = 'icons/effects/blood.dmi'
	icon_state = "vomit_1"

	basecolor="#FFFF99"
	amount = 2
	random_icon_states = list("vomit_1", "vomit_2", "vomit_3", "vomit_4")
	transfers_dna = 1

	persistent_type_replacement = /obj/effect/decal/cleanable/vomit/pre_dry

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
	mouse_opacity = 0
	amount = 0
	qdel(reagents)
	reagents = null

/obj/effect/decal/cleanable/tomato_smudge
	name = "tomato smudge"
	desc = "It's red."
	density = 0
	anchored = 1
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
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("smashed_egg1", "smashed_egg2", "smashed_egg3")

/obj/effect/decal/cleanable/pie_smudge //honk
	name = "smashed pie"
	desc = "It's pie cream from a cream pie."
	density = 0
	anchored = 1
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("smashed_pie")

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
	icon = 'icons/obj/atmos.dmi'
	icon_state = "campfire_burnt"

/obj/effect/decal/cleanable/clay_fragments
	name = "clay fragments"
	desc = "pieces from a broken clay pot"
	gender = PLURAL
	icon = 'icons/effects/tomatodecal.dmi'
	icon_state = "clay_fragments"
	anchored = 0

/obj/effect/decal/cleanable/clay_fragments/New()
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
	mouse_opacity = 0

	persistence_type = null //Okay, this one is probably too much. A shitton of these get made every plasmaflood and it's not very interesting to clean up.


/obj/effect/decal/cleanable/soot/New()
	..()
	dir = pick(cardinal)

/obj/effect/decal/cleanable/lspaceclutter
	name = "clutter"
	gender = PLURAL
	density = 0
	anchored = 1
	icon = 'icons/effects/effects.dmi'
	icon_state = "lspaceclutter"

/obj/effect/decal/cleanable/cockroach_remains
	name = "cockroach remains"
	desc = "A disgusting mess."
	icon = 'icons/mob/animal.dmi'
	icon_state = "cockroach_remains1"

/obj/effect/decal/cleanable/cockroach_remains/New()
	..()
	icon_state = "cockroach_remains[rand(1,2)]"

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

/obj/effect/decal/cleanable/virusdish
	name = "broken virus containment dish"
	icon = 'icons/obj/virology.dmi'
	icon_state = "brokendish-outline"
	density = 0
	anchored = 1
	mouse_opacity = 1
	layer = OBJ_LAYER
	plane = OBJ_PLANE
	var/last_openner
	var/datum/disease2/disease/contained_virus

/obj/effect/decal/cleanable/virusdish/Crossed(var/mob/living/perp)
	..()
	if(istype(perp))
		if(perp.locked_to)//Riding a vehicle? Just make some noise.
			playsound(src, 'sound/effects/glass_step.ogg', 50, 1)
			return
		if(perp.flying)//Flying? Ignore it altogether.
			return
		else		//Otherwise you might hurt your feet if not wearing shoes
			playsound(src, 'sound/effects/glass_step.ogg', 50, 1)
			if(ishuman(perp))
				var/mob/living/carbon/human/H = perp
				var/danger = FALSE
				var/datum/organ/external/foot = H.pick_usable_organ(LIMB_LEFT_FOOT, LIMB_RIGHT_FOOT)
				if(!H.organ_has_mutation(foot, M_STONE_SKIN) && !H.check_body_part_coverage(FEET))
					if(foot.is_organic())
						danger = TRUE

						if(!H.lying && H.feels_pain())
							H.Knockdown(3)
						if(foot.take_damage(5, 0))
							H.UpdateDamageIcon()
						H.updatehealth()

				to_chat(perp, "<span class='[danger ? "danger" : "notice"]'>You step in \the [src]!</span>")
		infection_attempt(perp)

/obj/effect/decal/cleanable/virusdish/proc/infection_attempt(var/mob/living/perp)
	//Now if your feet aren't well protected, or are bleeding, you might get infected.
	var/block = 0
	var/bleeding = 0
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
