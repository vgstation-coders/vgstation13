

// ***********************************************************
// Foods that are produced from hydroponics ~~~~~~~~~~
// Data from the seeds carry over to these grown foods
// ***********************************************************

var/list/special_fruits = list()
//Grown foods
//Subclass so we can pass on values
/obj/item/weapon/reagent_containers/food/snacks/grown/
	var/plantname
	var/potency = -1
	var/hydroflags = 0
	var/datum/seed/seed
	var/fragrance
	autoignition_temperature = AUTOIGNITION_FABRIC

	icon = 'icons/obj/hydroponics/apple.dmi'
	icon_state = "produce"

/proc/get_special_fruits(var/filter=HYDRO_PREHISTORIC|HYDRO_VOX)
	. = list()
	. += /obj/item/weapon/reagent_containers/food/snacks/grown
	for(var/T in existing_typesof(/obj/item/weapon/reagent_containers/food/snacks/grown))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/G = T
		if(initial(G.hydroflags) & filter)
			. += T

/obj/item/weapon/reagent_containers/food/snacks/grown/New(atom/loc, custom_plantname, mob/harvester)
	..()
	if(custom_plantname)
		plantname = custom_plantname
	if(ticker)
		initialize(harvester)

/obj/item/weapon/reagent_containers/food/snacks/grown/initialize(mob/harvester)

	//Handle some post-spawn var stuff.
	//Fill the object up with the appropriate reagents.
	if(!isnull(plantname))
		seed = SSplant.seeds[plantname]
		if(!seed)
			return
		icon = seed.plant_dmi
		icon_state = seed.plant_icon_state
		potency = round(seed.potency)
		force = seed.thorny ? 5+seed.voracious*3 : 0
		throwforce = seed.thorny ? 5+seed.voracious*3 : 0
		if(seed.noreact)
			flags |= NOREACT

		if(seed.teleporting)
			name = "blue-space [name]"
		if(seed.stinging)
			name = "stinging [name]"
		if(seed.juicy == 2)
			name = "slippery [name]"

		if(seed.gas_absorb)
			processing_objects.Add(src)

		if(!seed.chems)
			return

		var/totalreagents = 0
		for(var/rid in seed.chems)
			var/list/reagent_data = seed.chems[rid]
			var/rtotal = reagent_data[1]
			if(reagent_data.len > 1 && potency > 0)
				rtotal += round(potency/reagent_data[2])
			totalreagents += rtotal

		if(totalreagents)
			var/coeff = min(reagents.maximum_volume / totalreagents, 1)

			for(var/rid in seed.chems)
				var/list/reagent_data = seed.chems[rid]
				var/rtotal = reagent_data[1]
				if(reagent_data.len > 1 && potency > 0)
					rtotal += round(potency/reagent_data[2])
				reagents.add_reagent(rid, max(0.1, round(rtotal*coeff, 0.1)))

	if(reagents.total_volume > 0)
		bitesize = 1 + round(reagents.total_volume/2, 1)
	src.pixel_x = rand(-5, 5) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-5, 5) * PIXEL_MULTIPLIER


/obj/item/weapon/reagent_containers/food/snacks/grown/throw_impact(atom/hit_atom, var/speed, mob/user)
	if(..() || !seed || !src)
		return
	//if(seed.stinging)   			//we do NOT want to transfer reagents on throw, as it would mean plantbags full of throwable chloral injectors
	//	stinging_apply_reagents(M)  //plus all sorts of nasty stuff like throw_impact not targeting a specific bodypart to check for protection.

	// We ONLY want to apply special effects if we're hitting a turf! That's because throw_impact will always be
	// called on a turf AFTER it's called on the things ON the turf, and will runtime if the item doesn't exist anymore.
	if(isturf(hit_atom))
		do_splat_effects(hit_atom,user)
	return

/obj/item/weapon/reagent_containers/food/snacks/grown/proc/do_splat_effects(atom/hit_atom, mob/user)
	if(seed.teleporting)
		splat_reagent_reaction(get_turf(hit_atom),user)
		if(do_fruit_teleport(hit_atom, usr, potency))
			visible_message("<span class='danger'>The [src] splatters, causing a distortion in space-time!</span>")
		else if(splat_decal(get_turf(hit_atom)))
			visible_message("<span class='notice'>The [src.name] has been squashed.</span>","<span class='moderate'>You hear a smack.</span>")
		qdel(src)
		return

	if(seed.juicy)
		splat_decal(get_turf(hit_atom))
		splat_reagent_reaction(get_turf(hit_atom),user)
		visible_message("<span class='notice'>The [src.name] has been squashed.</span>","<span class='moderate'>You hear a smack.</span>")
		qdel(src)
		return

/obj/item/weapon/reagent_containers/food/snacks/grown/attack(mob/living/M, mob/user, def_zone)
	if(user.a_intent == I_HURT)
		. = handle_attack(src,M,user,def_zone)
		if(seed.stinging)
			if(M.getarmor(def_zone, "melee") < 5)
				var/reagentlist = stinging_apply_reagents(M)
				if(reagentlist)
					to_chat(M, "<span class='danger'>You are stung by \the [src]!</span>")
					add_attacklogs(user, M, "stung", object = src, addition = "Reagents: [english_list(seed.get_reagent_names())]", admin_warn = 1)
			to_chat(user, "<span class='alert'>Some of \the [src]'s stingers break off in the hit!</span>")
			potency -= rand(1,(potency/3)+1)
		do_splat_effects(M,user)
		return
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/Crossed(var/mob/living/carbon/M)
	if(!seed || ..() || !istype(M) || !M.on_foot())
		return
	if(seed.thorny || seed.stinging || arcanetampered)
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(!H.check_body_part_coverage(FEET))
				var/datum/organ/external/affecting = H.get_organ(pick(LIMB_LEFT_FOOT, LIMB_RIGHT_FOOT))
				if(affecting && affecting.is_organic())
					if(thorns_apply_damage(M, affecting))
						to_chat(H, "<span class='danger'>You step on \the [src]'s sharp thorns!</span>")
						if(H.feels_pain())
							H.Knockdown(3)
							H.Stun(3)
					if(stinging_apply_reagents(M))
						to_chat(H, "<span class='danger'>You step on \the [src]'s stingers!</span>")
						potency -= rand(1,(potency/3)+1)
	if(seed.juicy == 2)
		if(M.Slip(3, 2, slipped_on = src))
			do_splat_effects(M)

/obj/item/weapon/reagent_containers/food/snacks/grown/pickup(mob/user)
	..()
	if(!seed)
		return
	if(seed.thorny || seed.stinging || arcanetampered)
		var/mob/living/carbon/human/H = user
		if(!istype(H))
			return
		if(H.check_body_part_coverage(HANDS) && !arcanetampered)
			return
		var/datum/organ/external/affecting = H.get_organ(pick(LIMB_RIGHT_HAND,LIMB_LEFT_HAND))
		if((!affecting || !affecting.is_organic()) && !arcanetampered)
			return
		if(stinging_apply_reagents(H))
			to_chat(H, "<span class='danger'>You are stung by \the [src]!</span>")
			potency -= rand(1,(potency/3)+1)
		if(thorns_apply_damage(H, affecting))
			to_chat(H, "<span class='danger'>You are prickled by the sharp thorns on \the [src]!</span>")
			spawn(3)
				if(H.feels_pain())
					H.drop_item(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/after_consume(var/mob/living/carbon/human/H)
	if((seed.thorny || arcanetampered) && istype(H))
		var/datum/organ/external/affecting = H.get_organ(LIMB_HEAD)
		if(affecting)
			if(thorns_apply_damage(H, affecting))
				to_chat(H, "<span class='danger'>Your mouth is cut by \the [src]'s sharp thorns!</span>")
				//H.stunned++ //just a 1 second pause to prevent people from spamming pagedown on this, since it's important
	..()

/obj/item/weapon/reagent_containers/food/snacks/grown/examine(mob/user)
	..()
	if(!seed)
		return
	var/traits = ""
	if(seed.stinging)
		traits += "<span class='alert'>It's covered in tiny stingers.</span> "
	if(seed.thorny)
		traits += "<span class='alert'>It's covered in sharp thorns.</span> "
	if(seed.juicy == 2)
		traits += "It looks ripe and excessively juicy. "
	if(seed.teleporting)
		traits += "It seems to be spatially unstable. "
	if(traits)
		to_chat(user, traits)
	hydro_hud_scan(user, src)

/obj/item/weapon/reagent_containers/food/snacks/grown/proc/splat_decal(turf/T)
	var/obj/effect/decal/cleanable/S = new seed.splat_type(T)
	if(seed.splat_type == /obj/effect/decal/cleanable/fruit_smudge/)
		if(filling_color != "#FFFFFF")
			S.color = filling_color
		else
			S.color = AverageColor(getFlatIcon(src, src.dir, 0), 1, 1)
		S.name = "[seed.seed_name] smudge"
	if(seed.biolum && seed.biolum_colour)
		S.set_light(1, l_color = seed.biolum_colour)
	return 1

/obj/item/weapon/reagent_containers/food/snacks/grown/proc/thorns_apply_damage(mob/living/carbon/human/H, datum/organ/external/affecting)
	if((!seed.thorny || !affecting) && (!arcanetampered|| !affecting))
		return 0
	affecting.take_damage(5+seed.voracious*3, 0, 0, "plant thorns")
	H.UpdateDamageIcon()
	return 1

/obj/item/weapon/reagent_containers/food/snacks/grown/proc/stinging_apply_reagents(mob/living/carbon/human/H)
	if(!seed.stinging && !arcanetampered)
		return 0
	if(!reagents || reagents.total_volume <= 0)
		return 0
	if(!seed.chems || !seed.chems.len)
		return 0

	var/list/thingsweinjected = list()
	var/injecting = clamp(1, 3, potency/10)

	for(var/rid in seed.chems) //Only transfer reagents that the plant naturally produces, no injecting chloral into your nettles.
		reagents.trans_id_to(H,rid,injecting)
		thingsweinjected += "[injecting]u of [rid]"
		. = 1

	if(. && fingerprintshidden && fingerprintshidden.len)
		H.investigation_log(I_CHEMS, "was stung by \a [src], transfering [english_list(thingsweinjected)] - all touchers: [english_list(src.fingerprintshidden)]")


/obj/item/weapon/reagent_containers/food/snacks/grown/proc/do_fruit_teleport(atom/hit_atom, mob/M, var/potency)	//Does this need logging?
	var/datum/zLevel/L = get_z_level(src)
	if(!L || L.teleJammed)
		return 0
	var/picked = pick_rand_tele_turf(hit_atom, potency/15, potency/10) // Does nothing at base potency since inner_radius == 0
	if(!isturf(picked))
		return 0
	var/turf/hit_turf = get_turf(hit_atom)
	var/turf_has_mobs = locate(/mob) in hit_turf
	if((!istype(M) || prob(50)) && turf_has_mobs) //50% chance to teleport the person who was hit by the fruit
		spark(hit_atom)
		new/obj/effect/decal/cleanable/molten_item(hit_turf) //Leave a pile of goo behind for dramatic effect...
		for(var/mob/A in hit_turf) //For the mobs in the tile that was hit...
			A.unlock_from()
			A.forceMove(picked) //And teleport them to the chosen location.
			spawn()
				spark(A)
	else //Teleports the thrower instead.
		spark(M)
		new/obj/effect/decal/cleanable/molten_item(M.loc) //Leaves a pile of goo behind for dramatic effect.
		M.unlock_from()
		M.forceMove(picked) //Send then to that location we picked previously
		spawn()
			spark(M) //Two set of sparks, one before the teleport and one after. //Sure then ?
	return 1

/obj/item/weapon/reagent_containers/food/snacks/grown/process()
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/environment
	if(istype(T))
		environment = T.return_air()
	else
		environment = space_gas

	for (var/gas in seed.consume_gasses)
		if(environment[gas] > 0 && reagents.total_volume < reagents.maximum_volume)
			var/amount_consumed = min(min(environment[gas],seed.consume_gasses[gas]/10),min(seed.consume_gasses[gas]/10,reagents.maximum_volume-reagents.total_volume))
			switch(gas)
				if(GAS_PLASMA)
					reagents.add_reagent(PLASMA, seed.consume_gasses[gas]/100)
				if(GAS_NITROGEN)
					reagents.add_reagent(NITROGEN, seed.consume_gasses[gas]/100)
				if(GAS_OXYGEN)
					reagents.add_reagent(OXYGEN, seed.consume_gasses[gas]/100)
				if(GAS_CARBON)
					reagents.add_reagent(CARBON, seed.consume_gasses[gas]/300)
					reagents.add_reagent(OXYGEN, seed.consume_gasses[gas]/150)
			environment.adjust_gas(gas, -(amount_consumed), FALSE)
	environment.update_values()

	if(reagents.total_volume >= reagents.maximum_volume)
		processing_objects.Remove(src)

//Types blacklisted from appearing as products of strange seeds and no-fruit.
var/list/strange_seed_product_blacklist = subtypesof(/obj/item/weapon/reagent_containers/food/snacks/grown/clover/) //Otherwise the selection would be biased by the relatively large number of multiple leaf-number-specific subtypes - the base type with randomized leaves is still valid.

/obj/item/weapon/reagent_containers/food/snacks/grown/corn
	name = "ear of corn"
	desc = "Needs some butter!"
	plantname = "corn"
	potency = 40
	filling_color = "#FFEE00"
	trash = /obj/item/weapon/corncob
	fragrance = INCENSE_CORNOIL

/obj/item/weapon/reagent_containers/food/snacks/grown/corn/attackby(var/obj/item/weapon/W, var/mob/user)
	if(W.is_sharp() && W.sharpness_flags & SHARP_BLADE)
		to_chat(user, "<span class='warning'>You'll have to eat the corn first before you can cut a pipe out of its cob.</span>")
		return
	..()

/obj/item/weapon/reagent_containers/food/snacks/grown/cherries
	name = "cherries"
	desc = "Great for toppings!"
	filling_color = "#FF0000"
	gender = PLURAL
	plantname = "cherry"
	slot_flags = SLOT_EARS

/obj/item/weapon/reagent_containers/food/snacks/grown/cinnamon
	name = "cinnamon sticks"
	desc = "Straight from the bark!"
	filling_color = "#D2691E"
	gender = PLURAL
	plantname = "cinnamomum"

/obj/item/weapon/reagent_containers/food/snacks/grown/poppy
	name = "poppy"
	desc = "Long-used as a symbol of rest, peace, and death."
	potency = 30
	filling_color = "#CC6464"
	plantname = "poppies"
	fragrance = INCENSE_POPPIES

/obj/item/weapon/reagent_containers/food/snacks/grown/harebell
	name = "harebell"
	desc = "\"I'll sweeten thy sad grave: thou shalt not lack the flower that's like thy face, pale primrose, nor the azured hare-bell, like thy veins; no, nor the leaf of eglantine, whom not to slander, out-sweeten’d not thy breath.\""
	potency = 1
	filling_color = "#D4B2C9"
	plantname = "harebells"
	fragrance = INCENSE_HAREBELLS

/obj/item/weapon/reagent_containers/food/snacks/grown/moonflower
	name = "moonflower"
	desc = "Store in a location at least 50 yards away from werewolves."
	potency = 25
	filling_color = "#E6E6FA"
	plantname = "moonflowers"
	fragrance = INCENSE_MOONFLOWERS

/obj/item/weapon/reagent_containers/food/snacks/grown/potato
	name = "potato"
	desc = "The space Irish starved to death after their potato crops died. Sadly they were unable to fish for space carp due to it being the queen's space. Bringing this up to any space IRA member will drive them insane with anger."
	potency = 25
	filling_color = "#E6E8DA"
	plantname = "potato"

/obj/item/weapon/reagent_containers/food/snacks/grown/potato/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/stack/cable_coil))
		if(W:amount >= 5)
			W:amount -= 5
			if(!W:amount)
				qdel(W)
			to_chat(user, "<span class='notice'>You add some cable to \the [src] and slide it inside the battery encasing.</span>")
			var/obj/item/weapon/cell/potato/pocell = new /obj/item/weapon/cell/potato(user.loc)
			pocell.maxcharge = src.potency * 10
			pocell.charge = pocell.maxcharge
			qdel(src)
			return

/obj/item/weapon/reagent_containers/food/snacks/grown/grapes
	name = "bunch of grapes"
	desc = "Nutritious!"
	filling_color = "#A332AD"
	plantname = "grapes"

/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes
	name = "bunch of green grapes"
	desc = "Nutritious!"
	potency = 25
	filling_color = "#A6FFA3"
	plantname = "greengrapes"

/obj/item/weapon/reagent_containers/food/snacks/grown/peanut
	name = "peanut"
	desc = "Nuts!"
	filling_color = "857e27"
	potency = 25
	plantname = "peanut"

/obj/item/weapon/reagent_containers/food/snacks/grown/rocknut
	name = "rocknut"
	desc = "A mutated nut with a rock hard exterior and soft chewy core."
	filling_color = "#583922"
	potency = 25
	plantname = "rocknut"
	force = 10

/obj/item/weapon/reagent_containers/food/snacks/grown/rocknut/New(atom/loc, custom_plantname, mob/harvester)
	..()
	throwforce = throwforce + round((5+potency/7.5), 1) ///it's a rock, add bonus damage that scales with potency
	eatverb = pick("crunch","gnaw","bite")

/obj/item/weapon/reagent_containers/food/snacks/grown/rocknut/before_consume(mob/living/carbon/eater)
	if(!seed.juicy)//juicy mutated rock nuts will not return your teeth
		var/mob/living/carbon/C = eater
		if(istype(C))//we carbon?
			var/datum/butchering_product/teeth/T = locate(/datum/butchering_product/teeth) in C.butchering_drops //used in tooth check
			if(istype(T)&&T.amount == 0)//we're a creature with teeth but we don't have any right now
				to_chat(eater, "<span class='warning'>I can't eat \the [src] because I have no teeth!</span>")
				return //don't call consume
			else if((istype(T) && T.amount != 0) && prob(round(potency/2.5)))//tooth check and potency probability
				playsound(src, 'sound/effects/tooth_crack.ogg', 50, 1)
				C.adjustBruteLoss(potency/25)
				to_chat(eater, "<span class='warning'>OUCH! I broke a tooth!</span>")
				eater.visible_message("<span class='warning'>[eater] broke a tooth trying to eat \the [src]!</span>")
				T.spawn_result(get_turf(eater), eater, 1)
				return..()//call consume
			else//didn't pass potency probability or some other shit
				C.adjustBruteLoss(potency/50)
				to_chat(eater, "<span class='warning'>OW! I nearly broke a tooth!</span>")
				return..()
		else //not even a carbon, fuck it
			to_chat(eater, "<span class='notice'>\The [src]'s rock hard shell prevents you from biting into it.</span>")
			return
	..()

/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage
	name = "cabbage"
	desc = "Ewwwwwwwwww. Cabbage."
	potency = 25
	filling_color = "#A2B5A1"
	plantname = "cabbage"
	fragrance = INCENSE_LEAFY

/obj/item/weapon/reagent_containers/food/snacks/grown/plasmacabbage
	name = "plasma cabbage"
	desc = "Not to be confused with red cabbage."
	icon = 'icons/obj/hydroponics/cabbageplasma.dmi'
	potency = 25
	filling_color = "#99335C"
	plantname = "plasmacabbage"

/obj/item/weapon/reagent_containers/food/snacks/grown/berries
	name = "bunch of berries"
	desc = "Nutritious!"
	filling_color = "#C2C9FF"
	plantname = "berries"

/obj/item/weapon/reagent_containers/food/snacks/grown/plastellium
	name = "clump of plastellium"
	desc = "Hmm, needs some processing."
	filling_color = "#C4C4C4"
	plantname = "plastic"

/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries
	name = "bunch of glow-berries"
	desc = "Nutritious!"
	filling_color = "#D3FF9E"
	plantname = "glowberries"

/obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod
	name = "cocoa pod"
	desc = "Can be ground into cocoa powder."
	potency = 50
	filling_color = "#9C8E54"
	plantname = "cocoa"

/obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane
	name = "sugarcane"
	desc = "Sickly sweet."
	potency = 50
	filling_color = "#C0C9AD"
	plantname = "sugarcane"

/obj/item/weapon/reagent_containers/food/snacks/grown/poisonberries
	name = "bunch of poison-berries"
	desc = "Taste so good, you could die!"
	gender = PLURAL
	potency = 15
	filling_color = "#B422C7"
	plantname = "poisonberries"

/obj/item/weapon/reagent_containers/food/snacks/grown/deathberries
	name = "bunch of death-berries"
	desc = "Taste so good, you could die!"
	gender = PLURAL
	potency = 50
	filling_color = "#4E0957"
	plantname = "deathberries"

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris
	name = "ambrosia vulgaris branch"
	desc = "This is a plant containing various healing chemicals."
	potency = 10
	filling_color = "#125709"
	plantname = "ambrosia"

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/cruciatus
	name = "ambrosia vulgaris branch"
	desc = "This is a plant containing various healing chemicals."
	potency = 10
	plantname = "ambrosiacruciatus"

/obj/item/weapon/reagent_containers/food/snacks/grown/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/paper))
		qdel(O)
		to_chat(user, "<span class='notice'>You roll a blunt out of \the [src].</span>")
		var/obj/item/clothing/mask/cigarette/blunt/rolled/B = new/obj/item/clothing/mask/cigarette/blunt/rolled(src.loc)
		B.name = "[src.name] blunt"
		B.filling = "[src.name]"
		reagents.trans_to(B, (reagents.total_volume))
		user.put_in_hands(B)
		user.drop_from_inventory(src)
		qdel(src)
	else
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/deus
	name = "ambrosia deus branch"
	desc = "Eating this makes you feel immortal!"
	potency = 10
	filling_color = "#229E11"
	plantname = "ambrosiadeus"

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/deus/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/paper))
		qdel(O)
		to_chat(user, "<span class='notice'>You roll a godly blunt.</span>")
		var/obj/item/clothing/mask/cigarette/blunt/deus/rolled/B = new/obj/item/clothing/mask/cigarette/blunt/deus/rolled(src.loc)
		reagents.trans_to(B, (reagents.total_volume))
		B.light_color = filling_color
		user.put_in_hands(B)
		user.drop_from_inventory(src)
		qdel(src)
	else
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/apple
	name = "apple"
	desc = "It's a little piece of Eden."
	potency = 15
	filling_color = "#DFE88B"
	plantname = "apple"

/obj/item/weapon/reagent_containers/food/snacks/grown/apple/poisoned
	filling_color = "#B3BD5E"
	plantname = "poisonapple"

/obj/item/weapon/reagent_containers/food/snacks/grown/goldapple
	name = "golden apple"
	desc = "Emblazoned upon the apple is the word 'Kallisti'."
	potency = 15
	filling_color = "#F5CB42"
	plantname = "goldapple"

/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon
	name = "watermelon"
	desc = "It's full of watery goodness."
	potency = 10
	filling_color = "#FA2863"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/watermelonslice
	slices_num = 5
	storage_slots = 3
	plantname = "watermelon"

/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin
	name = "pumpkin"
	desc = "It's large and scary."
	potency = 10
	filling_color = "#FAB728"
	plantname = "pumpkin"

/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(W.sharpness_flags & SHARP_BLADE)
		user.visible_message("<span class='notice'>[user] carves a face into \the [src] with \the [W]!</span>", "<span class='notice'>You carve a face into \the [src] with \the [W]!</span>")
		new /obj/item/clothing/head/pumpkinhead(get_turf(src)) //Don't move it
		qdel(src)
		return

/obj/item/weapon/reagent_containers/food/snacks/grown/lime
	name = "lime"
	desc = "It's so sour, your face will twist."
	potency = 20
	filling_color = "#28FA59"
	plantname = "lime"

/obj/item/weapon/reagent_containers/food/snacks/grown/lemon
	name = "lemon"
	desc = "When life gives you lemons, be grateful they aren't limes."
	potency = 20
	filling_color = "#FAF328"
	plantname = "lemon"

/obj/item/weapon/reagent_containers/food/snacks/grown/orange
	name = "orange"
	desc = "It's a tangy fruit."
	potency = 20
	filling_color = "#FAAD28"
	plantname = "orange"

/obj/item/weapon/reagent_containers/food/snacks/grown/silicatecitrus
	name = "silicate citrus"
	desc = "Best thing since the toast untoaster."
	potency = 20
	filling_color = "#C7FFFF"
	plantname = "silicatecitrus"

/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet
	name = "white-beet"
	desc = "You can't beat white-beet."
	potency = 15
	filling_color = "#FFFCCC"
	plantname = "whitebeet"

/obj/item/weapon/reagent_containers/food/snacks/grown/banana
	name = "banana"
	desc = "It's an excellent prop for a comedy."
	filling_color = "#FCF695"
	trash = /obj/item/weapon/bananapeel
	plantname = "banana"
	fragrance = INCENSE_BANANA

/obj/item/weapon/reagent_containers/food/snacks/grown/banana/isHandgun()
	return TRUE

/obj/item/weapon/reagent_containers/food/snacks/grown/banana/after_consume(var/mob/user, var/datum/reagents/reagentreference)
	var/obj/item/weapon/bananapeel/peel = new
	peel.potency = potency
	trash = peel
	..()

/obj/item/weapon/reagent_containers/food/snacks/grown/bluespacebanana
	name = "bluespace banana"
	desc = "It's an excellent prop for a comedy."
	filling_color = "#FCF695"
	plantname = "bluespacebanana"

/obj/item/weapon/reagent_containers/food/snacks/grown/bluespacebanana/isHandgun()
	return TRUE

/obj/item/weapon/reagent_containers/food/snacks/grown/bluespacebanana/after_consume(var/mob/user, var/datum/reagents/reagentreference)
	var/obj/item/weapon/bananapeel/bluespace/peel = new
	peel.potency = potency
	trash = peel
	..()

/obj/item/weapon/reagent_containers/food/snacks/grown/chili
	name = "chili"
	desc = "It's spicy! Wait... IT'S BURNING ME!!"
	filling_color = "#FF0000"
	plantname = "chili"

/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant
	name = "eggplant"
	desc = "Maybe there's a chicken inside?"
	filling_color = "#550F5C"
	plantname = "eggplant"

/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans
	name = "soybeans"
	desc = "It's pretty bland, but oh the possibilities..."
	gender = PLURAL
	filling_color = "#E6E8B7"
	plantname = "soybean"

/obj/item/weapon/reagent_containers/food/snacks/grown/koibeans
	name = "koibean"
	desc = "Something about these seems fishy."
	gender = PLURAL
	filling_color = "#F0E68C"
	plantname = "koibean"

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato
	name = "tomato"
	desc = "I say to-mah-to, you say tom-mae-to."
	filling_color = "#FF0000"
	potency = 10
	plantname = "tomato"

/obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato
	name = "tomato" //"blue-space" is applied on new(), provided it's teleporting trait hasn't been removed
	desc = "Its juices lubricate so well, you might slip through space-time."
	potency = 20
	origin_tech = Tc_BLUESPACE + "=3"
	filling_color = "#91F8FF"
	plantname = "bluespacetomato"

/obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato/testing
	potency = 100

/obj/item/weapon/reagent_containers/food/snacks/grown/killertomato
	name = "killer-tomato"
	desc = "I say to-mah-to, you say tom-mae-to... OH GOD IT'S EATING MY LEGS!!"
	potency = 10
	filling_color = "#FF0000"
	plantname = "killertomato"

/obj/item/weapon/reagent_containers/food/snacks/grown/killertomato/attack_self(mob/user as mob)
	if(istype(user.loc, /turf/space))
		return
	var/mob/living/simple_animal/hostile/retaliate/tomato/T = new(user.loc)
	T.harm_intent_damage = potency/5 - potency/20
	T.melee_damage_lower = potency/10
	T.melee_damage_upper = potency/5 - potency/20
	T.health = potency/2 - potency/8
	T.maxHealth = potency/2 - potency/8
	T.friends += user
	qdel(src)

	to_chat(user, "<span class='notice'>You plant the killer-tomato.</span>")

/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato
	name = "blood-tomato"
	desc = "So bloody...so...very...bloody....AHHHH!!!!"
	potency = 10
	filling_color = "#FF0000"
	plantname = "bloodtomato"

/obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato
	name = "blue-tomato"
	desc = "I say blue-mah-to, you say blue-mae-to."
	potency = 10
	filling_color = "#586CFC"
	plantname = "bluetomato"

/obj/item/weapon/reagent_containers/food/snacks/grown/wheat
	name = "wheat"
	desc = "Sigh... wheat... a-grain?"
	gender = PLURAL
	filling_color = "#F7E186"
	plantname = "wheat"

/obj/item/weapon/reagent_containers/food/snacks/grown/ricestalk
	name = "rice stalk"
	desc = "Rice to see you."
	gender = PLURAL
	filling_color = "#FFF8DB"
	plantname = "rice"

/obj/item/weapon/reagent_containers/food/snacks/grown/kudzupod
	name = "kudzu pod"
	desc = "<I>Pueraria Virallis</I>: An invasive species with vines that rapidly creep and wrap around whatever they contact."
	filling_color = "#59691B"
	plantname = "kudzu"

/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper
	name = "chilly pepper"
	desc = "It's a mutant strain of chili pepper, now cold rather than hot."
	potency = 20
	filling_color = "#66CEED"
	plantname = "icechili"

/obj/item/weapon/reagent_containers/food/snacks/grown/ghostpepper
	name = "ghost pepper"
	desc = "This pepper is haunted. And pretty spicy, too."
	potency = 20
	filling_color = "#66CEED"
	plantname = "ghostpepper"

/obj/item/weapon/reagent_containers/food/snacks/grown/ghostpepper/spook()
	visible_message("<span class='warning'>A specter takes a bite of \the [src] from beyond the grave!</span>")
	playsound(src,'sound/items/eatfood.ogg', rand(10,50), 1)
	bitecount++
	reagents.remove_any(bitesize)
	if(!reagents.total_volume)
		qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/carrot
	name = "carrot"
	desc = "It's good for the eyes!"
	potency = 10
	filling_color = "#FFC400"
	plantname = "carrot"

/obj/item/weapon/reagent_containers/food/snacks/grown/carrot/diamond
	name = "diamond carrot"
	desc = "Carrots are forever... Wait no."
	potency = 20
	filling_color = "#C4D4E0"
	plantname = "diamondcarrot"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi
	name = "reishi"
	desc = "<I>Ganoderma lucidum</I>: A special fungus believed to help relieve stress."
	potency = 10
	filling_color = "#FF4800"
	plantname = "reishi"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita
	name = "fly amanita"
	desc = "<I>Amanita Muscaria</I>: Learn poisonous mushrooms by heart. Only pick mushrooms you know."
	potency = 10
	filling_color = "#FF0000"
	plantname = "amanita"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel
	name = "destroying angel"
	desc = "<I>Amanita Virosa</I>: Deadly poisonous basidiomycete fungus filled with alpha amatoxins."
	potency = 35
	filling_color = "#FFDEDE"
	plantname = "destroyingangel"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap
	name = "liberty-cap"
	desc = "<I>Psilocybe Semilanceata</I>: Liberate yourself!"
	potency = 15
	filling_color = "#F714BE"
	plantname = "libertycap"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet
	name = "plump-helmet"
	desc = "<I>Plumus Hellmus</I>: Plump, soft and s-so inviting~"
	filling_color = "#F714BE"
	plantname = "plumphelmet"
	fragrance = INCENSE_BOOZE

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom
	name = "walking mushroom"
	desc = "<I>Plumus Locomotus</I>: The beginning of the great walk."
	filling_color = "#FFBFEF"
	potency = 30
	plantname = "walkingmushroom"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom/attack_self(mob/user as mob)
	if(istype(user.loc, /turf/space))
		return
	new /mob/living/simple_animal/hostile/mushroom(user.loc)
	qdel(src)

	to_chat(user, "<span class='notice'>You plant the walking mushroom.</span>")

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle
	name = "chanterelle cluster"
	desc = "<I>Cantharellus Cibarius</I>: These jolly yellow little shrooms sure look tasty!"
	filling_color = "#FFE991"
	plantname = "mushrooms"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom
	name = "glowshroom cluster"
	desc = "<I>Mycena Bregprox</I>: This species of mushroom glows in the dark. Or does it?"
	filling_color = "#DAFF91"
	potency = 30
	plantname = "glowshroom"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/attack_self(mob/user as mob)
	if(istype(user.loc, /turf/space))
		return
	var/obj/effect/glowshroom/planted = new /obj/effect/glowshroom(user.loc)

	planted.delay = 50
	planted.endurance = 100
	planted.potency = potency
	planted.light_color = light_color
	qdel(src)

	to_chat(user, "<span class='notice'>You plant the glowshroom.</span>")

/obj/item/weapon/reagent_containers/food/snacks/grown/grass
	name = "grass"
	desc = "Green and lush."
	filling_color = "#32CD32"
	plantname = "grass"
	fragrance = INCENSE_DENSE
	var/stacktype = /obj/item/stack/tile/grass
	var/tile_coefficient = 0.02 // 1/50

/obj/item/weapon/reagent_containers/food/snacks/grown/grass/attack_self(mob/user as mob)
	to_chat(user, "<span class='notice'>You prepare the astroturf.</span>")
	var/grassAmount = 1 + round(potency * tile_coefficient) // The grass we're holding
	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/grass/G in user.loc) // The grass on the floor
		if(G.type != type)
			continue
		grassAmount += 1 + round(G.potency * tile_coefficient)
		qdel(G)

	drop_stack(stacktype, get_turf(user), grassAmount, user)
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chickenshroom
	name = "chicken-of-the-stars"
	desc = "A variant of the Earth-native Laetiporus sulphureus, adapted by Vox traders for space. Everything tastes like chicken."
	filling_color = "F2E33A"
	plantname = "chickenshroom"
	hydroflags = HYDRO_VOX

/obj/item/weapon/reagent_containers/food/snacks/grown/garlic
	name = "garlic"
	desc = "Warning: Garlic may send vampires straight to the Dead Zone."
	filling_color = "EDEDE1"
	plantname = "garlic"
	hydroflags = HYDRO_VOX

/obj/item/weapon/reagent_containers/food/snacks/grown/breadfruit
	name = "breadfruit"
	desc = "Starchy. Tastes about the same as biting into a sack of flour."
	filling_color = "EDEDE1"
	plantname = "breadfruit"
	hydroflags = HYDRO_VOX

/obj/item/weapon/reagent_containers/food/snacks/grown/woodapple
	name = "woodapple"
	desc = "A hard-shelled fruit with precious juice inside. Even the shell may find use, if properly sliced."
	slice_path = /obj/item/stack/sheet/wood
	slices_num = 1
	storage_slots = 1 //seems less intended and more like an artifact of old code where if something was sliceable, it should also hold items inside, but keeping consistency
	filling_color = "857663"
	plantname = "woodapple"
	hydroflags = HYDRO_VOX

/obj/item/weapon/reagent_containers/food/snacks/grown/pitcher
	name = "pitcher plant" //results in "slippery pitcher plant"
	desc = "A fragile, but slippery exotic plant from tropical climates. Powerful digestive acid contained within dissolves prey."
	filling_color = "7E8507"
	plantname = "pitcher"
	hydroflags = HYDRO_VOX

/obj/item/weapon/reagent_containers/food/snacks/grown/aloe
	name = "aloe vera"
	desc = "A thorny, broad-leaf plant believed to be useful for first aid."
	filling_color = "77BA9F"
	plantname = "aloe"
	hydroflags = HYDRO_VOX

// *************************************
// Complex Grown Object Defines -
// Putting these at the bottom so they don't clutter the list up. -Cheridan
// *************************************

/obj/item/weapon/reagent_containers/food/snacks/grown/vaporsac
	plantname = "vaporsac"
	name = "vapor sac fruit"
	desc = "A thin organic film bearing seeds, held slightly aloft by internal gasses and a reservoir of chemicals."
	filling_color = "#FFFFFF"
	fragrance = INCENSE_VAPOR

/obj/item/weapon/reagent_containers/food/snacks/grown/vaporsac/attack(mob/living/M, mob/user, def_zone, eat_override = 0)
	pop(user)

/obj/item/weapon/reagent_containers/food/snacks/grown/vaporsac/attack_animal(mob/M)
	pop(M)

/obj/item/weapon/reagent_containers/food/snacks/grown/vaporsac/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/device/analyzer/plant_analyzer))
		return
	pop(user)

/obj/item/weapon/reagent_containers/food/snacks/grown/vaporsac/proc/pop(mob/popper)
	if(popper)
		popper.visible_message("<span class='warning'>[popper] pops the \the [src]!</span>","<span class='warning'>You pop \the [src]!</span>")
	for(var/mob/living/carbon/C in view(1))
		if(C.CheckSlip() != TRUE)
			continue
		C.Knockdown(5)
		C.Stun(5)
	playsound(src, 'sound/effects/bang.ogg', 10, 1)
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/nofruit
	name = "no-fruit"
	desc = "Any plant you want, at your fingertips."
	potency = 15
	filling_color = "#FFFCCC"
	plantname = "nofruit"
	var/list/available_fruits = list()
	var/switching = 0
	var/current_path = null
	var/counter = 1

/obj/item/weapon/reagent_containers/food/snacks/grown/nofruit/New(atom/loc, custom_plantname, mob/harvester)
	..()
	available_fruits = existing_typesof(/obj/item/weapon/reagent_containers/food/snacks/grown) - get_special_fruits() - strange_seed_product_blacklist
	available_fruits = shuffle(available_fruits)

/obj/item/weapon/reagent_containers/food/snacks/grown/nofruit/verb/pick_leaf()
	set name = "Pick no-fruit leaf"
	set category = "Object"
	set src in range(1)

	var/mob/user = usr
	if(!user.Adjacent(src))
		return
	if(user.isUnconscious())
		to_chat(user, "You can't do that while unconscious.")
		return

	if(!switching)
		randomize()
	else
		getnofruit(user, user.get_active_hand())

/obj/item/weapon/reagent_containers/food/snacks/grown/nofruit/AltClick(mob/user)
	pick_leaf()

/obj/item/weapon/reagent_containers/food/snacks/grown/nofruit/attackby(obj/item/weapon/W, mob/user)
	pick_leaf()

/obj/item/weapon/reagent_containers/food/snacks/grown/nofruit/proc/randomize()
	switching = 1
	mouse_opacity = 2
	spawn()
		while(switching)
			current_path = available_fruits[counter]
			var/obj/item/weapon/reagent_containers/food/snacks/grown/G = current_path
			if(SSplant.seeds[initial(G.plantname)])
				icon = SSplant.seeds[initial(G.plantname)].plant_dmi
			sleep(4)
			if(counter == available_fruits.len)
				counter = 0
				available_fruits = shuffle(available_fruits)
			counter++

/obj/item/weapon/reagent_containers/food/snacks/grown/nofruit/proc/getnofruit(mob/user, obj/item/weapon/W)
	if(!switching || !current_path)
		return
	verbs -= /obj/item/weapon/reagent_containers/food/snacks/grown/nofruit/verb/pick_leaf
	switching = 0
	var/N = rand(1,3)
	if(get_turf(user))
		switch(N)
			if(1)
				playsound(user, 'sound/weapons/genhit1.ogg', 50, 1)
			if(2)
				playsound(user, 'sound/weapons/genhit2.ogg', 50, 1)
			if(3)
				playsound(user, 'sound/weapons/genhit3.ogg', 50, 1)
	if(W)
		user.visible_message("[user] smacks \the [src] with \the [W].","You smack \the [src] with \the [W].")
	else
		user.visible_message("[user] smacks \the [src].","You smack \the [src].")
	if(src.loc == user)
		user.drop_item(src, force_drop = 1)
		var/I = new current_path(get_turf(user))
		user.put_in_hands(I)
	else
		new current_path(get_turf(src))
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/avocado
	name = "avocado"
	desc = "An unusually fatty fruit containing a single large seed."
	icon = 'icons/obj/hydroponics/avocado.dmi'
	filling_color = "#EAE791"
	plantname = "avocado"
	var/cant_eat_msg = "'s skin is much too tough to chew."
	var/cut = FALSE

/obj/item/weapon/reagent_containers/food/snacks/grown/avocado/can_consume(mob/living/carbon/eater, mob/user)
	if(cant_eat_msg)
		to_chat(user, "<span class='notice'>This [name][cant_eat_msg]</span>")
	else
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/avocado/attackby(obj/item/weapon/W, mob/user)
	..()
	if(W.sharpness_flags & SHARP_BLADE)
		if(cut && cant_eat_msg)
			user.visible_message("\The [user] removes the pit from \the [src] with \the [W].","You remove the pit from \the [src] with \the [W].")
			new /obj/item/seeds/avocadoseed/whole(get_turf(user))
			if(loc == user)
				if(src in user.held_items)
					user.drop_item(src, force_drop = 1)
					var/obj/item/weapon/reagent_containers/food/snacks/grown/avocado/cut/pitted/P = new(get_turf(src))
					user.put_in_hands(P)
					qdel(src)
					return
			new /obj/item/weapon/reagent_containers/food/snacks/grown/avocado/cut/pitted(get_turf(src))
			qdel(src)
		else if(!cut)
			user.visible_message("\The [user] slices \the [src] in half with \the [W].","You slice \the [src] in half with \the [W].")
			var/list/halves = list(new /obj/item/weapon/reagent_containers/food/snacks/grown/avocado/cut(get_turf(src)), new /obj/item/weapon/reagent_containers/food/snacks/grown/avocado/cut/pitted(get_turf(src)))
			if(loc == user)
				if(src in user.held_items)
					user.drop_item(src, force_drop = 1)
					user.put_in_hands(pick(halves))
					qdel(src)
					return
			qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/avocado/cut
	name = "avocado half"
	desc = "This half still has the seed embedded in it."
	icon_state = "cut"
	cant_eat_msg = "'s seed is too large to eat."
	cut = TRUE
	plantname = null	//So people can't use the pit as a seed AND feed each half to the seed extractor

/obj/item/weapon/reagent_containers/food/snacks/grown/avocado/cut/pitted
	desc = "An unusually fatty fruit, it can be used in both savory and sweet dishes."
	icon_state = "pitted"
	cant_eat_msg = null

/obj/item/weapon/reagent_containers/food/snacks/grown/pear
	name = "pear"
	desc = "The inferior alternative to apples."
	potency = 15
	filling_color = "#DFE88B"
	plantname = "pear"

/obj/item/weapon/reagent_containers/food/snacks/grown/silverpear
	name = "silver pear"
	desc = "Silver will always be the inferior alternative to gold."
	potency = 15
	filling_color = "#DFE88B"
	plantname = "silverpear"

/obj/item/weapon/reagent_containers/food/snacks/grown/mustardplant
	name = "mustard flowers"
	desc = "A bunch of bright yellow flowers, unrelated to the gas."
	potency = 10
	filling_color = "#DFE88B"
	plantname = "mustardplant"
	fragrance = INCENSE_MUSTARDPLANT

//Clovers
/obj/item/weapon/reagent_containers/food/snacks/grown/clover
	filling_color = "#247E0A"
	luckiness_validity = LUCKINESS_WHEN_GENERAL_RECURSIVE
	var/leaves
	plantname = "clover"

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/zeroleaf
	leaves = 0

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/oneleaf
	leaves = 1

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/twoleaf
	leaves = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/threeleaf
	leaves = 3

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/fourleaf
	leaves = 4

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/fiveleaf
	leaves = 5

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/sixleaf
	leaves = 6

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/sevenleaf
	leaves = 7

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/proc/update_leaves()
	switch(leaves)
		if(3)
			name = "clover"
			desc = "A cheerful little herb with three leaves."
		if(0)
			name = "zero-leaf clover"
			desc = "Bad luck and extreme misfortune will infest your pathetic soul for all eternity."
			luckiness = -10000
		if(1)
			name = "one-leaf clover"
			desc = "This cursed clover is said to bring nothing but misery to the one who bears it."
			luckiness = -500
		if(2)
			name = "two-leaf clover"
			desc = "This clover only has two leaves. How unfortunate!"
			luckiness = -25
		if(4)
			name = "four-leaf clover"
			desc = "This clover has four leaves. Lucky you!"
			luckiness = 25
		if(5)
			name = "five-leaf clover"
			desc = "A marvel of probabilistics, this exquisitely rare clover is said to bring fantastic luck."
			luckiness = 100
		if(6)
			name = "six-leaf clover"
			desc = "A closely-guarded secret of the leprechauns."
			luckiness = 1000
		if(7)
			name = "seven-leaf clover"
			desc = "The fates themselves are said to shower their adoration on the one who bears this legendary lucky charm."
			luckiness = 10000
	icon = 'icons/obj/hydroponics/clover.dmi'
	icon_state = "clover[leaves]"

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/proc/shift_leaves(var/mut = 0, var/mob/shifter)
	leaves = 3
	var/prob1 = clamp(mut / 3, 0, 66)
	var/luck = 0
	if(ismob(shifter))
		luck = shifter.luck()
	if(luck ? shifter.lucky_prob(prob1, 1/100, 25, ourluck = luck) : prob(prob1))
		var/ls = 1
		var/prob2 = max(clamp(mut, 0, 21) / 21, 0.1)
		prob2 = luck ? shifter.lucky_probability(prob2, 1/333 , 33, ourluck = luck) : prob2
		for(var/i in 1 to 7)
			if(prob(prob2))
				ls += 1
		leaves += ls * pick(-1,1)
		if(luck ? shifter.lucky_prob(3, 1/333, 50, ourluck = luck) : prob(3))
			leaves = clamp(leaves, 0, 7)
		else if(leaves < 0 || leaves > 7)
			leaves = 3
		return leaves != 3

/obj/item/weapon/reagent_containers/food/snacks/grown/clover/initialize(mob/harvester)
	. = ..()
	if(isnull(leaves))
		shift_leaves(seed?.potency, harvester)
	update_leaves()


/obj/item/weapon/reagent_containers/food/snacks/grown/flax
	name = "flax"
	desc = "The grains can be ground to produce an oil whose pigment match the color of surrounding reagents, and the fibers can be weaved into cloth at a spinning wheel or electric loom."
	gender = PLURAL
	potency = 20
	filling_color = "#7E80DE"
	plantname = "flax"
