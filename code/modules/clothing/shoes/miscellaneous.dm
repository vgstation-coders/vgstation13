/obj/item/clothing/shoes/syndigaloshes
	desc = "A pair of brown shoes." // the "extra grip" contraband id text is moved to examine()
	name = "brown shoes"
	icon_state = "brown"
	item_state = "brown"
	_color = "brown"
	clothing_flags = NOSLIP
	origin_tech = Tc_SYNDICATE + "=3"
	var/list/clothing_choices = list()
	actions_types = list(/datum/action/item_action/change_appearance_shoes)
	siemens_coefficient = 0.8
	permeability_coefficient = 0.90
	species_fit = list(VOX_SHAPED, GREY_SHAPED, UNDEAD_SHAPED, MUSHROOM_SHAPED, INSECT_SHAPED)

// desc replacement block
/obj/item/clothing/shoes/syndigaloshes/examine(mob/user)
	..()
	if(is_holder_of(user, src)) // are the noslips on your person or on the floor?
		to_chat(user, "<span class='info'><b>When inspected hands-on,</b> they are apparently modified with complex electronics and extra-grip soles.</span>") // these are no-slips yes hello sir
		to_chat(user, "<span class='info'>They are rated to fit all known species able to wear footgear.</span>") // catbeasts/unathi/golems btfo, how will they ever recover
		return
	if(isturf(loc) && user.Adjacent(src)) // so there's degrees of identification. above is blatant, this is less so
		to_chat(user, "Something's a little off...")

/obj/item/clothing/shoes/syndigaloshes/New()
	..()
	verbs += /obj/item/clothing/shoes/syndigaloshes/verb/change_appearance_shoes
	for(var/Type in existing_typesof(/obj/item/clothing/shoes) - (/obj/item/clothing/shoes/syndigaloshes))
		clothing_choices += new Type
	return

/*	// the above 5 lines invalidate any purpose this block once had
/obj/item/clothing/shoes/syndigaloshes/attackby(obj/item/I, mob/user)
	..()

	if(!istype(I, /obj/item/clothing/shoes) || istype(I, src.type))
		return 0
	else
		var/obj/item/clothing/shoes/S = I
		if(src.clothing_choices.Find(S))
			to_chat(user, "<span class='warning'>[S.name]'s pattern is already stored.</span>")
			return
		src.clothing_choices += S
		to_chat(user, "<span class='notice'>[S.name]'s pattern absorbed by \the [src].</span>")
		return 1
	return 0
*/

/datum/action/item_action/change_appearance_shoes
	name = "Change Shoe Color"
	desc = "Swap the appearance of your shoes."

/datum/action/item_action/change_appearance_shoes/Trigger()
	var/obj/item/clothing/shoes/syndigaloshes/T = target
	if(!istype(T))
		return
	T.change()

/obj/item/clothing/shoes/syndigaloshes/verb/change_appearance_shoes()
	set name = "Change Shoe Color"
	set category = "Object"
	set desc = "Swap the appearance of your shoes."
	src.change()

/obj/item/clothing/shoes/syndigaloshes/proc/change()
	var/obj/item/clothing/shoes/A
	A = input("Pick a color:", "BOOYEA", A) as null|anything in clothing_choices
	if(!A || usr.incapacitated() || !Adjacent(usr) || isturf(src.loc))
		return

	desc = A.desc
	name = A.name
	icon_state = A.icon_state
	item_state = A.item_state
	_color = A._color
	step_sound = A.step_sound
	usr.update_inv_shoes()

/obj/item/clothing/shoes/mime
	name = "mime shoes"
	icon_state = "mime"
	_color = "mime"

/obj/item/clothing/shoes/mime/biker
	name = "Biker's shoes"

/obj/item/clothing/shoes/swat
	name = "\improper SWAT shoes"
	desc = "When you want to turn up the heat."
	icon_state = "swat"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	clothing_flags = NOSLIP
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	siemens_coefficient = 0.6
	heat_conductivity = INS_SHOE_HEAT_CONDUCTIVITY
	bonus_kick_damage = 3

/obj/item/clothing/shoes/combat //Basically SWAT shoes combined with galoshes.
	name = "combat boots"
	desc = "When you REALLY want to turn up the heat."
	icon_state = "swat"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	clothing_flags = NOSLIP
	species_fit = list(VOX_SHAPED)
	siemens_coefficient = 0.6
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	heat_conductivity = INS_SHOE_HEAT_CONDUCTIVITY
	bonus_kick_damage = 3

/obj/item/clothing/shoes/sandal
	desc = "A pair of rather plain, wooden sandals."
	name = "sandals"
	icon_state = "wizard"
	species_fit = list(VOX_SHAPED)

	wizard_garb = 1

/obj/item/clothing/shoes/sandal/slippers
	name = "magic slippers"
	icon_state = "slippers"
	desc = "For the wizard that puts comfort first. Who's going to laugh?"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/shoes/sandal/marisa
	desc = "A pair of magic, black shoes."
	name = "magic shoes"
	icon_state = "black"

/obj/item/clothing/shoes/sandal/marisa/leather
	icon_state = "laceups"
	item_state = "laceups"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)

/obj/item/clothing/shoes/galoshes
	name = "galoshes"
	desc = "Rubber boots!"
	icon_state = "galoshes"
	permeability_coefficient = 0.05
	clothing_flags = NOSLIP
	slowdown = MISC_SHOE_SLOWDOWN
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	heat_conductivity = INS_SHOE_HEAT_CONDUCTIVITY
	sterility = 100

/obj/item/clothing/shoes/galoshes/broken
	name = "ruined galoshes"
	desc = "The grip treading is broken off."
	icon_state = "galoshes_ruined"
	flags = null
	sterility = 80

/obj/item/clothing/shoes/clown_shoes
	desc = "The prankster's standard-issue clowning shoes. Damn they're huge!"
	name = "clown shoes"
	icon_state = "clown"
	item_state = "clown_shoes"
	_color = "clown"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)
	footprint_type = /obj/effect/decal/cleanable/blood/tracks/footprints/clown

	step_sound = "clownstep"

/obj/item/clothing/shoes/clown_shoes/New()
	..()
	if(Holiday == APRIL_FOOLS_DAY)
		modulo_steps = 1 //Honk on every step

/obj/item/clothing/shoes/clown_shoes/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/clothing/mask/gas/clown_hat))
		new /mob/living/simple_animal/hostile/retaliate/cluwne/goblin(get_turf(src))
		qdel(W)
		qdel(src)

/obj/item/clothing/shoes/clown_shoes/lola
	name = "fighting clown shoes"
	desc = "Squeaky when scuffling."
	icon_state = "lola"
	item_state = "lola"
	_color = "lola"

/obj/item/clothing/shoes/clown_shoes/elf
	desc = "Jolly shoes for a jolly little elf!"
	name = "elf shoes"
	icon_state = "elf_shoes"
	item_state = "elf_shoes"
	_color = "elf_shoes"

/obj/item/clothing/shoes/clown_shoes/elf/stickymagic
	canremove = 0

#define CLOWNSHOES_RANDOM_SOUND "random sound"

/obj/item/clothing/shoes/clown_shoes/advanced
	name = "advanced clown shoes"
	desc = "Only granted to the most devout followers of Honkmother."
	icon_state = "superclown"
	item_state = "superclown"
	clothing_flags = NOSLIP
	var/list/sound_list = list(
		"Clown squeak" = "clownstep",
		"Bike horn" = 'sound/items/bikehorn.ogg',
		"Air horn" = 'sound/items/AirHorn.ogg',
		"Chewing" = 'sound/items/eatfood.ogg',
		"Polaroid" = "polaroid",
		"Gunshot" = 'sound/weapons/Gunshot.ogg',
		"Ion gun" = 'sound/weapons/ion.ogg',
		"Laser gun" = 'sound/weapons/Laser.ogg',
		"Punch" = "punch",
		"Shotgun" = 'sound/weapons/shotgun.ogg',
		"Taser" = 'sound/weapons/Taser.ogg',
		"Male scream" = "malescream",
		"Female scream" = "femalescream",
		"Vox shriek" = 'sound/misc/shriek1.ogg',
		"Male cough" = "malecough",
		"Female cough" = "femalecough",
		"Sad trombone" = 'sound/misc/sadtrombone.ogg',
		"Awooga" = 'sound/effects/awooga.ogg',
		"Bubbles" = 'sound/effects/bubbles.ogg',
		"EMP pulse" = 'sound/effects/EMPulse.ogg',
		"Explosion" = "explosion",
		"Glass" = 'sound/effects/glass_step.ogg',
		"Mouse squeak" = 'sound/effects/mousesqueek.ogg',
		"Meteor impact" = 'sound/effects/meteorimpact.ogg',
		"Supermatter" = 'sound/effects/supermatter.ogg',
		"Emitter" = 'sound/weapons/emitter.ogg',
		"Laughter" = 'sound/effects/laughtrack.ogg',
		"Mecha step" = 'sound/mecha/mechstep.ogg',
		"Fart" = 'sound/misc/fart.ogg',
		"Dramatic" = 'sound/effects/dramatic_short.ogg',
		"Random" = CLOWNSHOES_RANDOM_SOUND)
	var/random_sound = 0

/obj/item/clothing/shoes/clown_shoes/advanced/attack_self(mob/living/user)
	if(user.mind && !clumsy_check(user))
		to_chat(user, "<span class='danger'>These shoes are too powerful for you to handle!</span>")
		if(prob(25))
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H << sound('sound/items/AirHorn.ogg')
				to_chat(H, "<font color='red' size='7'>HONK</font>")
				H.sleeping = 0
				H.stuttering += 20
				H.ear_deaf += 30
				H.Knockdown(3) //Copied from honkerblast 5000
				if(prob(30))
					H.Stun(10)
					H.Paralyse(4)
				else
					H.Jitter(500)
		return

	var/new_sound = input(user,"Select the new step sound!","Advanced clown shoes") in sound_list

	if(Adjacent(user))
		if(step_sound == CLOWNSHOES_RANDOM_SOUND)
			step_sound = "clownstep"
			to_chat(user, "<span class='sinister'>You set [src]'s step sound to always be random!</span>")
			random_sound = 1
		else
			step_sound = sound_list[new_sound]
			to_chat(user, "<span class='sinister'>You set [src]'s step sound to \"[new_sound]\"!</span>")
			random_sound = 0

/obj/item/clothing/shoes/clown_shoes/advanced/verb/ChangeSound()
	set category = "Object"
	set name = "Change Sound"

	return src.attack_self(usr)

/obj/item/clothing/shoes/clown_shoes/advanced/step_action()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc

		if(H.mind && !clumsy_check(H))
			if( ( H.mind.assigned_role == "Mime" ) )
				H.Slip(3, 2, 1)

			return

		if(random_sound)
			step_sound = sound_list[pick(sound_list)]
	..()

/obj/item/clothing/shoes/clown_shoes/advanced/emag_act(var/mob/user) //Causes the shoes to play a sound every step instead of 2
	..()
	if(!emagged)
		if(modulo_steps == 1)
			to_chat(user, "<span class='warning'>Aww shucks! Looks like someone beat you to the punch, for these shoes already play a sound every step! Perhaps it was the result of a very special day, or maybe it was tampered with by a very bored god. Either way, you are a fool!</span>")
			to_chat(user, "<span class='good'>However, here is a consolation banana.</span>")
			var/dat = {"<html><div><span style="color:#ff0000;">H</span><span style="color:#99ff00;">O</span><span style="color:#0000ff;">N</span><span style="color:#00ff80;">K</span><span style="color:#0066ff;">!</span></html></div>"}
			to_chat(user, dat)
			playsound(user, 'sound/items/bikehorn.ogg', 100, 0)
			var/obj/item/weapon/reagent_containers/food/snacks/grown/banana/B = new(loc)
			B.name = "consolation banana"
			B.desc = "This one seems to be enchanted..."
			B.potency = 1337 //Honk
			user.put_in_hands(B)
		else
			to_chat(user, "<span class='warning'>You overload the audio cogitators of \the [src], causing them to play a sound on every step!</span>")
			modulo_steps = 1
		emagged = 1

/obj/item/clothing/shoes/clown_shoes/stickymagic
	canremove = 0
	wizard_garb = 1

/obj/item/clothing/shoes/clown_shoes/stickymagic/dissolvable()
	return 0

/obj/item/clothing/shoes/clown_shoes/slippy
	canremove = 0
	var/lube_chance = 10

/obj/item/clothing/shoes/clown_shoes/slippy/step_action() //The honkpocalypse is here
	..()
	if(ishuman(loc) && prob(lube_chance))
		var/mob/living/carbon/human/mob = loc
		if(istype(mob.loc,/turf/simulated))
			var/turf/simulated/T = mob.loc
			T.wet(800, TURF_WET_LUBE)

/obj/item/clothing/shoes/clown_shoes/slippy/dropped(mob/user as mob)
	canremove = 1
	..()


#undef CLOWNSHOES_RANDOM_SOUND

/obj/item/clothing/shoes/jackboots
	name = "jackboots"
	desc = "Nanotrasen-issue Security combat boots for combat scenarios or combat situations. All combat, all the time."
	icon_state = "jackboots"
	item_state = "jackboots"
	_color = "hosred"
	siemens_coefficient = 0.7
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	heat_conductivity = INS_SHOE_HEAT_CONDUCTIVITY
	bonus_kick_damage = 3
	footprint_type = /obj/effect/decal/cleanable/blood/tracks/footprints/boots

/obj/item/clothing/shoes/jackboots/knifeholster/New() //This one comes with preloaded knife holster
	..()
	attach_accessory(new /obj/item/clothing/accessory/holster/knife/boot/preloaded/tactical)

/obj/item/clothing/shoes/jackboots/batmanboots
	name = "batboots"
	desc = "Criminal stomping boots for fighting crime and looking good."

/obj/item/clothing/shoes/jackboots/neorussian
	name = "neo-Russian boots"
	desc = "Tovarish, no one will realize you stepped on a pile of shit if your pair already looks like shit."
	icon_state = "nr_boots"
	item_state = "nr_boots"
	heat_conductivity = INS_ARMOUR_HEAT_CONDUCTIVITY

/obj/item/clothing/shoes/jackboots/cowboy
	name = "cowboy boots"
	desc = "No snake in these boots."
	icon_state = "cowboy"
	item_state = "cowboy"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/shoes/jackboots/steeltoe
	name = "steel-toed boots"
	desc = "In the ever-evolving arms-race of ass kicking, these boots are ready to kick any number of steel plated hides."
	bonus_kick_damage = 5 //2 more than normal jackboots

/obj/item/clothing/shoes/jackboots/steeltoe/impact_dampen(atom/source, damage)
	return 0

/obj/item/clothing/shoes/cult_legacy
	name = "boots"
	desc = "A pair of boots worn by the followers of Nar-Sie."
	icon_state = "cult"
	item_state = "cult"
	_color = "cult"
	siemens_coefficient = 0.7
	heat_conductivity = INS_SHOE_HEAT_CONDUCTIVITY
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	species_fit = list(INSECT_SHAPED)

/obj/item/clothing/shoes/cult_legacy/cultify()
	return

/obj/item/clothing/shoes/cyborg
	name = "cyborg boots"
	desc = "Shoes for a cyborg costume."
	icon_state = "boots"

/obj/item/clothing/shoes/slippers
	name = "bunny slippers"
	desc = "Fluffy!"
	icon_state = "slippers"
	item_state = "slippers"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/shoes/slippers_worn
	name = "worn bunny slippers"
	desc = "Fluffy..."
	icon_state = "slippers_worn"
	item_state = "slippers_worn"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/shoes/laceup
	name = "laceup shoes"
	desc = "The height of fashion, and they're pre-polished!"
	icon_state = "laceups"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/shoes/purplepumps
	name = "purple pumps"
	desc = "Make you seem slightly taller."
	icon_state = "purplepumps"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/shoes/roman
	name = "roman sandals"
	desc = "Sandals with buckled leather straps on it."
	icon_state = "roman"
	item_state = "roman"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/shoes/simonshoes
	name = "Simon's Shoes"
	desc = "Simon's Shoes."
	icon_state = "simonshoes"
	item_state = "simonshoes"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/shoes/kneesocks
	name = "kneesocks"
	desc = "A pair of girly knee-high socks."
	icon_state = "kneesock"
	item_state = "kneesock"
	species_fit = list(INSECT_SHAPED, VOX_SHAPED)

/obj/item/clothing/shoes/kneesocks/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/soap))
		if(do_after(user, src, 1 SECONDS))
			user.create_in_hands(src, new /obj/item/weapon/brick_sock/soap(loc, src, W), W, msg = "<span class='notice'>You place \the [W] into \the [src].</span>", move_in = TRUE)
	else if(istype(W, /obj/item/stack/sheet/mineral/brick))
		if(do_after(user, src, 1 SECONDS))
			user.create_in_hands(src, new /obj/item/weapon/brick_sock(loc, src), W, msg = "<span class='notice'>You place a brick into \the [src].</span>", move_in = TRUE)

/obj/item/clothing/shoes/jestershoes
	name = "Jester Shoes"
	desc = "As worn by the clowns of old."
	icon_state = "jestershoes"
	item_state = "jestershoes"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/shoes/aviatorboots
	name = "Aviator Boots"
	desc = "Boots suitable for just about any occasion."
	icon_state = "aviator_boots"
	item_state = "aviator_boots"
	species_restricted = list("exclude",VOX_SHAPED)

/obj/item/clothing/shoes/libertyshoes
	name = "Liberty Shoes"
	desc = "Freedom isn't free, neither were these shoes."
	icon_state = "libertyshoes"
	item_state = "libertyshoes"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/shoes/megaboots
	name = "DRN-001 Boots"
	desc = "Large armored boots, very weak to large spikes."
	icon_state = "megaboots"
	item_state = "megaboots"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/shoes/protoboots
	name = "Prototype Boots"
	desc = "Functionally identical to the DRN-001 model's boots, but in red."
	icon_state = "protoboots"
	item_state = "protoboots"

/obj/item/clothing/shoes/megaxboots
	name = "Maverick Hunter boots"
	desc = "Regardless of how much stronger these boots are than the DRN-001 model's, they're still extremely easy to pierce with a large spike."
	icon_state = "megaxboots"
	item_state = "megaxboots"

/obj/item/clothing/shoes/joeboots
	name = "Sniper Boots"
	desc = "Nearly identical to the Prototype's boots, except in black."
	icon_state = "joeboots"
	item_state = "joeboots"

/obj/item/clothing/shoes/doomguy
	name = "Doomguy's boots"
	desc = ""
	icon_state = "doom"
	item_state = "doom"

/obj/item/clothing/shoes/workboots
	name = "Workboots"
	desc = "Thick-soled boots for industrial work environments."
	icon_state = "workboots"
	item_state = "workboots"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	footprint_type = /obj/effect/decal/cleanable/blood/tracks/footprints/boots

/obj/item/clothing/shoes/rottenshoes
	name = "rotten shoes"
	desc = "These shoes seem perfect for sneaking around."
	icon_state = "rottenshoes"
	item_state = "rottenshoes"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/clothing.dmi', "right_hand" = 'icons/mob/in-hand/right/clothing.dmi')

/obj/item/clothing/shoes/winterboots
	name = "winter boots"
	desc = "Boots lined with 'synthetic' animal fur."
	icon_state = "winterboots"
	item_state = "winterboots"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	heat_conductivity = INS_SHOE_HEAT_CONDUCTIVITY
	footprint_type = /obj/effect/decal/cleanable/blood/tracks/footprints/boots

/obj/item/clothing/shoes/frankshoes
	name = "Dr. Frank's leggings"
	desc = "Perfect for wearing out to a late night double feature."
	icon_state = "frankshoes"
	item_state = "frankshoes"

/obj/item/clothing/shoes/clockwork_boots
	name = "clockwork boots"
	desc = "A pair of boots worn by the followers of Ratvar."
	icon_state = "clockwork"
	item_state = "clockwork"

/obj/item/clothing/shoes/knifeboot
	name = "laceup shoes"
	desc = "The height of fashion, and they're pre-polished!"
	icon_state = "laceups"
	item_state = "laceups"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	actions_types = list(/datum/action/item_action/generic_toggle)
	var/toggle = FALSE

/obj/item/clothing/shoes/knifeboot/attack_self()
	toggle = !toggle
	to_chat(usr, "<span class = 'notice'>You toggle \the [src]'s hidden knife [toggle?"out":"in"].</span>")
	update_icon()
	..()

/obj/item/clothing/shoes/knifeboot/update_icon()
	if(toggle)
		icon_state = "[initial(icon_state)]_1"
	else
		icon_state = initial(icon_state)
	item_state = icon_state

/obj/item/clothing/shoes/knifeboot/on_kick(mob/living/carbon/human/user, mob/living/victim)
	if(istype(victim) && toggle)
		var/datum/organ/external/affecting = victim.get_organ(ran_zone(user.zone_sel.selecting))
		//Sharpness 1.5, force 10, edge = SHARP_TIP | SHARP_BLADE
		victim.apply_damage(victim.run_armor_absorb(affecting, "melee", 10), BRUTE, affecting, victim.run_armor_check(affecting, "melee"), sharp = 1.5, edge = SHARP_TIP | SHARP_BLADE, used_weapon = src)

/obj/item/clothing/shoes/lich_king
	name = "old knight greaves"
	desc = "Battered by time, and questionably comfortable."
	icon_state = "lichking_boots"
	item_state = "lichking_boots"
	wizard_garb = 1

/obj/item/clothing/shoes/jackboots/inquisitor
	name = "noble boots"
	desc = "A pair of high quality black leather boots."
	icon_state = "noble-boots"
	item_state = "noble-boots"
	wizard_garb = TRUE

/obj/item/clothing/shoes/jackboots/highlander
	name = "highlander's boots"
	desc = "A quality pair of boots, essential for any highlander."
	icon_state = "highlanderboots"
	item_state = "highlanderboots"
	wizard_garb = 1

/obj/item/clothing/shoes/clownshoespsyche
	desc = "The prankster's illegal-issue clowning shoes. Damn they're huge!"
	name = "clown psychedelic shoes"
	icon_state = "clownshoespsyche"
	item_state = "clownshoespsyche"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/clothing.dmi', "right_hand" = 'icons/mob/in-hand/right/clothing.dmi')
	luminosity = 2
	_color = "clownshoespsyche"
	footprint_type = /obj/effect/decal/cleanable/blood/tracks/footprints/clown
	species_fit = list(VOX_SHAPED)

	step_sound = "clownstep"

/obj/item/clothing/shoes/clownshoespsyche/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/clothing/mask/gas/clownmaskpsyche))
		new /mob/living/simple_animal/hostile/retaliate/cluwne/psychedelicgoblin(get_turf(src))
		qdel(W)
		qdel(src)

/obj/item/clothing/shoes/secshoes
	name = "security shoes"
	desc = "Black shoes for formal occasions."
	icon_state = "secshoes"
	item_state = "secshoes"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/shoes/scubafloppers
	name = "scuba floppers"
	desc = "SCUBA floppers for swimming quickly... in space?"
	icon_state = "scubafloppers"
	item_state = "scubafloppers"
	footprint_type = /obj/effect/decal/cleanable/blood/tracks/footprints/clown
	species_fit = list(VOX_SHAPED, GREY_SHAPED, UNDEAD_SHAPED, MUSHROOM_SHAPED, INSECT_SHAPED)


/obj/item/clothing/shoes/hunter
	name = "heavy leather boots"
	desc = "Tall leather boots, perfect for performing slide kicks."
	icon_state = "hunter"
	item_state = "hunter_boots"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/clothing_castlevania.dmi', "right_hand" = 'icons/mob/in-hand/right/clothing_castlevania.dmi')
	heat_conductivity = INS_SHOE_HEAT_CONDUCTIVITY
	bonus_kick_damage = 3
	footprint_type = /obj/effect/decal/cleanable/blood/tracks/footprints/boots

/obj/item/clothing/shoes/hunter/offenseTackleBonus()
	return 3

/obj/item/clothing/shoes/hunter/rangeTackleBonus()
	return 1
