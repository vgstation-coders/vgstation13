// **********************
// Other harvested materials from plants (that are not food)
// **********************

/obj/item/weapon/grown // Grown weapons
	name = "grown_weapon"
	icon = 'icons/obj/hydroponics/nettle.dmi'
	var/plantname
	var/potency = 1
	var/fragrance = null

/obj/item/weapon/grown/New(atom/loc, custom_plantname)
	..()

	pixel_x = rand(-5, 5) * PIXEL_MULTIPLIER	//Randomizes position slightly.
	pixel_y = rand(-5, 5) * PIXEL_MULTIPLIER

	var/datum/reagents/R = new/datum/reagents(50)
	reagents = R
	R.my_atom = src

	if(custom_plantname)
		plantname = custom_plantname

	// Fill the object up with the appropriate reagents.
	if(!isnull(plantname))
		var/datum/seed/S = SSplant.seeds[plantname]
		if(!S || !S.chems)
			return

		changePotency(S.potency)

		var/totalreagents = 0
		for(var/rid in S.chems)
			var/list/reagent_data = S.chems[rid]
			var/rtotal = reagent_data[1]
			if(reagent_data.len > 1 && potency > 0)
				rtotal += round(potency/reagent_data[2])
			totalreagents += rtotal

		if(totalreagents)
			var/coeff = min(reagents.maximum_volume / totalreagents, 1)

			for(var/rid in S.chems)
				var/list/reagent_data = S.chems[rid]
				var/rtotal = reagent_data[1]
				if(reagent_data.len > 1 && potency > 0)
					rtotal += round(potency/reagent_data[2])
				reagents.add_reagent(rid,max(1,round(rtotal*coeff, 0.1)))

/obj/item/weapon/grown/proc/changePotency(newValue) //-QualityVan
	potency = newValue

/obj/item/weapon/grown/log
	plantname = "towercap"
	name = "tower-cap log"
	desc = "It's better than bad, it's good!"
	icon = 'icons/obj/hydroponics/towercap.dmi'
	icon_state = "produce"
	force = 5
	flags = 0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=1"
	attack_verb = list("bashes", "batters", "bludgeons", "whacks")

	var/planks = 2

/obj/item/weapon/grown/log/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(W.sharpness_flags & CHOPWOOD) // I considered adding serrated to this but c'mon, making planks out of a serrated blade sounds like an awful idea
		user.show_message("<span class='notice'>You make two planks out of \the [src].</span>", MESSAGE_SEE)
		playsound(loc, 'sound/effects/woodcutting.ogg', 50, 1)
		drop_stack(/obj/item/stack/sheet/wood, get_turf(user), planks, user)

		qdel(src)
		return
	if(istype(W,/obj/item/weapon/grown/log) && isturf(loc))
		to_chat(user,"<span class='notice'>You begin building a storm door out of the tower-cap logs.</span>")
		if(do_after(user,src,4 SECONDS))
			to_chat(user,"<span class='notice'>You finish the door.</span>")
			new /obj/machinery/door/mineral/wood/log/towercap(loc)
			qdel(src)
	else
		..()

/obj/item/weapon/grown/log/tree
	name = "log"
	plantname = "tree"
	desc = "A very heavy log, a main product of woodcutting. Much heavier than tower-cap logs."
	force = 10
	w_class = W_CLASS_LARGE

	planks = 4

/obj/item/weapon/grown/log/tree/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/grown/log/tree) && isturf(loc))
		to_chat(user,"<span class='notice'>You begin building a storm door out of the heavy tree logs.</span>")
		if(do_after(user,src,4 SECONDS))
			to_chat(user,"<span class='notice'>You finish the door.</span>")
			new /obj/machinery/door/mineral/wood/log(loc)
			qdel(src)
	else
		..()

/obj/item/weapon/grown/sunflower // FLOWER POWER!
	plantname = "sunflowers"
	name = "sunflower"
	desc = "It's beautiful! A certain person might beat you to death if you trample these."
	icon = 'icons/obj/hydroponics/sunflower.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/flowers.dmi', "right_hand" = 'icons/mob/in-hand/right/flowers.dmi')
	icon_state = "sunflower"
	damtype = "fire"
	force = 0
	flags = 0
	throwforce = 1
	w_class = W_CLASS_TINY
	throw_speed = 1
	throw_range = 3
	fragrance = INCENSE_SUNFLOWERS
	slot_flags = SLOT_HEAD

/obj/item/weapon/grown/sunflower/attack(mob/M as mob, mob/user as mob)
	to_chat(M, "<font color='green'><b> [user] smacks you with a sunflower! </font><font color='yellow'><b>FLOWER POWER<b></font>")
	to_chat(user, "<font color='green'>Your sunflower's </font><font color='yellow'><b>FLOWER POWER</b></font><font color='green'> strikes [M]</font>")
	//Uh... Doesn't this cancel the rest of attack()?

/obj/item/weapon/grown/novaflower
	plantname = "novaflowers"
	name = "novaflower"
	desc = "These beautiful flowers have a crisp smokey scent, like a summer bonfire."
	icon = 'icons/obj/hydroponics/novaflower.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/flowers.dmi', "right_hand" = 'icons/mob/in-hand/right/flowers.dmi')
	icon_state = "novaflower"
	damtype = "fire"
	force = 0
	flags = 0
	slot_flags = SLOT_HEAD
	throwforce = 1
	w_class = W_CLASS_TINY
	throw_speed = 1
	throw_range = 3
	attack_verb = list("sears", "heats", "whacks", "steams")
	fragrance = INCENSE_NOVAFLOWERS

/obj/item/weapon/grown/novaflower/New(atom/loc, custom_plantname)
	..()
	reagents.add_reagent(NUTRIMENT, 1)
	reagents.add_reagent(CAPSAICIN, round(potency, 1))

/obj/item/weapon/grown/novaflower/changePotency(newValue)
	potency = newValue
	force = round((5 + potency / 5), 1)

/obj/item/weapon/grown/novaflower/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(!..())
		return
	if(istype(M, /mob/living))
		to_chat(M, "<span class='warning'>You are heated by the warmth of the of the [name]!</span>")
		M.bodytemperature += potency/2 * TEMPERATURE_DAMAGE_COEFFICIENT
/obj/item/weapon/grown/novaflower/pickup(mob/living/carbon/human/user as mob)
	if(!user.gloves || arcanetampered)
		to_chat(user, "<span class='warning'>The [name] burns your bare hand!</span>")
		user.adjustFireLoss(rand(1,5))

/obj/item/weapon/grown/novaflower/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is eating some of the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return (SUICIDE_ACT_FIRELOSS|SUICIDE_ACT_TOXLOSS)

/obj/item/weapon/grown/nettle // -- Skie
	plantname = "nettle"
	desc = "It's probably <B>not</B> wise to touch it with bare hands..."
	icon = 'icons/obj/hydroponics/nettle.dmi'
	name = "nettle"
	icon_state = "produce"
	damtype = "fire"
	force = 15
	flags = 0
	throwforce = 1
	w_class = W_CLASS_SMALL
	throw_speed = 1
	throw_range = 3
	origin_tech = Tc_COMBAT + "=1"

/obj/item/weapon/grown/nettle/pickup(mob/living/carbon/human/user as mob) //todo this
	if(istype(user))
		if(!user.gloves || arcanetampered)
			to_chat(user, "<span class='warning'>The nettle burns your bare hand!</span>")
			var/datum/organ/external/affecting = user.get_active_hand_organ()
			if(affecting && affecting.take_damage(0,force))
				user.UpdateDamageIcon()
	else
		user.take_organ_damage(0,force)
		to_chat(user, "<span class='warning'>The nettle burns your bare hand!</span>")

/obj/item/weapon/grown/nettle/afterattack(atom/A as mob|obj, mob/user as mob, proximity)
	if(!proximity)
		return
	user.delayNextAttack(8)
	if(force > 0)
		force -= rand(1,(force/3)+1) // When you whack someone with it, leaves fall off
		playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	else
		to_chat(usr, "All the leaves have fallen off the nettle from violent whacking.")
		user.drop_item(src, force_drop = 1)
		qdel(src)

/obj/item/weapon/grown/nettle/changePotency(newValue) //-QualityVan
	potency = newValue
	force = round((5+potency/5), 1)

/obj/item/weapon/grown/nettle/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is eating some of the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return (SUICIDE_ACT_BRUTELOSS|SUICIDE_ACT_TOXLOSS)

/obj/item/weapon/grown/deathnettle // -- Skie
	plantname = "deathnettle"
	desc = "A glowing red nettle that incites rage in you just from looking at it."
	icon = 'icons/obj/hydroponics/deathnettle.dmi'
	name = "deathnettle"
	icon_state = "produce"
	damtype = "fire"
	force = 30
	flags = 0
	throwforce = 1
	w_class = W_CLASS_SMALL
	throw_speed = 1
	throw_range = 3
	origin_tech = Tc_COMBAT + "=3"
	attack_verb = list("stings", "pricks")

/obj/item/weapon/grown/deathnettle/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is eating some of the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return (SUICIDE_ACT_BRUTELOSS|SUICIDE_ACT_TOXLOSS)

/obj/item/weapon/grown/deathnettle/pickup(mob/living/carbon/human/user as mob)
	if(!user.gloves)
		if(istype(user, /mob/living/carbon/human))
			var/datum/organ/external/affecting = user.get_active_hand_organ()
			if(affecting.take_damage(0,force))
				user.UpdateDamageIcon()
		else
			user.take_organ_damage(0,force)
		if(prob(50))
			user.Paralyse(5)
			to_chat(user, "<span class='warning'>You are stunned by the Deathnettle when you try picking it up!</span>")

/obj/item/weapon/grown/deathnettle/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(!..())
		return
	to_chat(M, "<span class='warning'>You are stunned by the powerful acid of the Deathnettle!</span>")

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Had the [src.name] used on them by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] on [M.name] ([M.ckey])</font>")
	msg_admin_attack("[user.name] ([user.ckey]) used the [src.name] on [M.name] ([M.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)

	M.eye_blurry += force/7
	if(prob(20))
		M.Paralyse(force/6)
		M.Knockdown(force/15)
	M.drop_item()

	user.delayNextAttack(8)
	if (force > 0)
		force -= rand(1,(force/3)+1) // When you whack someone with it, leaves fall off
	else
		to_chat(user, "All the leaves have fallen off the deathnettle from violent whacking.")
		qdel(src)

/obj/item/weapon/grown/deathnettle/changePotency(newValue) //-QualityVan
	potency = newValue
	force = round((5+potency/2.5), 1)

/obj/item/weapon/corncob
	name = "corn cob"
	desc = "A reminder of meals gone by."
	icon = 'icons/obj/hydroponics/corn.dmi'
	icon_state = "cob"
	item_state = "corncob"
	w_class = W_CLASS_TINY
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/corncob/attackby(var/obj/item/weapon/W, var/mob/user)
	..()
	if(W.is_sharp() && W.sharpness_flags & SHARP_BLADE)
		to_chat(user, "<span class='notice'>You use [W] to fashion a pipe out of the corn cob!</span>")
		new /obj/item/clothing/mask/cigarette/pipe/cobpipe (user.loc)
		user.drop_item(src, force_drop = 1)
		qdel(src)
		return

/obj/item/weapon/carnivorous_pumpkin
	name = "carnivorous pumpkin"
	desc = "It hungers. For heads."
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "hardhat1_pumpkin"
	cant_drop = 1
	laying_pickup = TRUE

/obj/item/weapon/carnivorous_pumpkin/New()
	..()
	spawn(rand(40 SECONDS, 90 SECONDS))
		if(gcDestroyed)
			return
		var/mob/living/carbon/human/H = loc
		if(istype(H))
			var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD)
			if(head_organ)
				head_organ.explode()
		visible_message("<span class = 'warning'>\The [src] laughs, before disappearing from view.</span>")
		qdel(src)

/obj/item/weapon/carnivorous_pumpkin/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(ishuman(M) && M != user)
		user.drop_item(src, force_drop = 1)
		M.drop_item(M.get_active_hand(), force_drop = 1)
		M.put_in_hands(src)
		to_chat(M, "<span class = 'userwarning'>\The [src] has been forced onto you by \the [user]! Find somebody else to give it to before it consumes your head!</span>")

/obj/item/weapon/grown/dandelion
	plantname = "dandelions"
	name = "dandelion"
	desc = "A fuzzy flower, the head consists of a mass of seeds called a pappus, ready to be carried by the wind."
	gender = NEUTER
	icon = 'icons/obj/hydroponics/dandelions.dmi'
	icon_state = "produce-2"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/flowers.dmi', "right_hand" = 'icons/mob/in-hand/right/flowers.dmi')
	item_state = "dandelion-pappus"
	throwforce = 0
	w_class = W_CLASS_TINY
	w_type = RECYK_BIOLOGICAL
	flammable = TRUE
	throw_range = 1
	throw_speed = 1
	pressure_resistance = 2
	attack_verb = list("slaps")
	var/seeds_left = 3

/obj/item/weapon/grown/dandelion/MiddleAltClick(var/mob/living/user)
	attack_self(user)

/obj/item/weapon/grown/dandelion/attack_self(var/mob/living/user)
	var/turf/T = get_turf(user)
	var/turf/U = get_step(T, user.dir)
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		if (H.species && (H.species.flags & SPECIES_NO_MOUTH))
			to_chat(user, "<span class='warning'>You stare at \the [src] intently. Wishing you had a mouth to blown on it.</span>")
			return
	playsound(user, 'sound/effects/blow.ogg', 5, 1, -2)
	if(test_reach(T,U,PASSTABLE|PASSGRILLE|PASSMOB|PASSMACHINE|PASSGIRDER|PASSRAILING))
		blow_seeds(T,U)
	else
		blow_seeds(T,T)
	user.visible_message("<span class='notice'>[user] blows some dandelion seeds.</span>", "<span class='notice'>You blow some dandelion seeds.</span>")

/obj/item/weapon/grown/dandelion/attack(var/mob/living/carbon/human/M, var/mob/living/user)
	return

/obj/item/weapon/grown/dandelion/afterattack(var/atom/A, var/mob/user, proximity_flag)

	if (isshelf(A))
		return

	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		if (H.species && (H.species.flags & SPECIES_NO_MOUTH))
			to_chat(user, "<span class='warning'>You stare at \the [src] intently. Wishing you had a mouth to blown on it.</span>")
			return

	playsound(user, 'sound/effects/blow.ogg', 5, 1, -2)

	var/turf/T = get_turf(user)
	var/turf/U = get_step(T, get_dir(T,A))

	if(T != U && test_reach(T,U,PASSTABLE|PASSGRILLE|PASSMOB|PASSMACHINE|PASSGIRDER|PASSRAILING))
		blow_seeds(T,U)
	else
		blow_seeds(T,T)
	user.visible_message("<span class='notice'>[user] blows some dandelion seeds.</span>", "<span class='notice'>You blow some dandelion seeds.</span>")

/obj/item/weapon/grown/dandelion/proc/blow_seeds(var/turf/source_turf, var/turf/dest_turf)
	source_turf.flying_pollen(dest_turf,3.5)

	sow_trays(dest_turf)

	seeds_left--
	if (seeds_left <= 0)
		qdel(src)

/obj/item/weapon/grown/dandelion/proc/sow_trays(var/turf/T)//TODO: have it work on grass and possibly with other weeds/pollen/seeds
	spawn(10)
		for (var/obj/machinery/portable_atmospherics/hydroponics/tray in T)
			if (!tray.seed)
				tray.seed = SSplant.seeds[plantname]
				tray.add_planthealth(tray.seed.endurance)
				tray.lastcycle = world.time
				tray.weedlevel = 0
				tray.update_icon()

/obj/item/weapon/grown/dandelion/wind_act(var/differential, var/list/connecting_turfs)
	var/turf/T = get_turf(src)
	var/turf/U = get_step(T,get_dir(T,pick(connecting_turfs)))
	var/log_differential = log(abs(differential) * 3)
	if (U)
		if (differential > 0)
			T.flying_pollen(U,log_differential,PS_DANDELIONS)
		else
			T.flying_pollen(U,-log_differential,PS_DANDELIONS)
	sow_trays(U)
	seeds_left--
	if (seeds_left <= 0)
		qdel(src)
