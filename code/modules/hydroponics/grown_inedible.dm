// **********************
// Other harvested materials from plants (that are not food)
// **********************

/obj/item/weapon/grown // Grown weapons
	name = "grown_weapon"
	icon = 'icons/obj/weapons.dmi'
	var/plantname
	var/potency = 1
	var/fragrance = null

/obj/item/weapon/grown/New()

	..()

	var/datum/reagents/R = new/datum/reagents(50)
	reagents = R
	R.my_atom = src

	//Handle some post-spawn var stuff.
	spawn(1)
		// Fill the object up with the appropriate reagents.
		if(!isnull(plantname))
			var/datum/seed/S = SSplant.seeds[plantname]
			if(!S || !S.chems)
				return

			potency = round(S.potency)

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
	name = "tower-cap log"
	desc = "It's better than bad, it's good!"
	icon = 'icons/obj/harvest.dmi'
	icon_state = "logs"
	force = 5
	flags = 0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = Tc_MATERIALS + "=1"
	attack_verb = list("bashes", "batters", "bludgeons", "whacks")

/obj/item/weapon/grown/log/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(W.sharpness_flags & CHOPWOOD) // I considered adding serrated to this but c'mon, making planks out of a serrated blade sounds like an awful idea
		user.show_message("<span class='notice'>You make two planks out of \the [src].</span>", MESSAGE_SEE)
		playsound(loc, 'sound/effects/woodcutting.ogg', 50, 1)
		drop_stack(/obj/item/stack/sheet/wood, get_turf(user), 2, user)

		qdel(src)
		return

/obj/item/weapon/grown/log/tree
	name = "log"
	plantname = "tree"
	desc = "A very heavy log, a main product of woodcutting. Much heavier than tower-cap logs."
	force = 10
	w_class = W_CLASS_LARGE

/obj/item/weapon/grown/sunflower // FLOWER POWER!
	plantname = "sunflowers"
	name = "sunflower"
	desc = "It's beautiful! A certain person might beat you to death if you trample these."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "sunflower"
	damtype = "fire"
	force = 0
	flags = 0
	throwforce = 1
	w_class = W_CLASS_TINY
	throw_speed = 1
	throw_range = 3
	fragrance = INCENSE_SUNFLOWERS

/obj/item/weapon/grown/sunflower/attack(mob/M as mob, mob/user as mob)
	to_chat(M, "<font color='green'><b> [user] smacks you with a sunflower! </font><font color='yellow'><b>FLOWER POWER<b></font>")
	to_chat(user, "<font color='green'>Your sunflower's </font><font color='yellow'><b>FLOWER POWER</b></font><font color='green'> strikes [M]</font>")
	//Uh... Doesn't this cancel the rest of attack()?

/obj/item/weapon/grown/novaflower
	plantname = "novaflowers"
	name = "novaflower"
	desc = "These beautiful flowers have a crisp smokey scent, like a summer bonfire."
	icon = 'icons/obj/harvest.dmi'
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

/obj/item/weapon/grown/novaflower/New()
	..()
	spawn(5) // So potency can be set in the proc that creates these crops
		reagents.add_reagent(NUTRIMENT, 1)
		reagents.add_reagent(CAPSAICIN, round(potency, 1))
		force = round((5 + potency / 5), 1)

/obj/item/weapon/grown/novaflower/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(!..())
		return
	if(istype(M, /mob/living))
		to_chat(M, "<span class='warning'>You are heated by the warmth of the of the [name]!</span>")
		M.bodytemperature += potency/2 * TEMPERATURE_DAMAGE_COEFFICIENT
/obj/item/weapon/grown/novaflower/pickup(mob/living/carbon/human/user as mob)
	if(!user.gloves)
		to_chat(user, "<span class='warning'>The [name] burns your bare hand!</span>")
		user.adjustFireLoss(rand(1,5))

/obj/item/weapon/grown/nettle // -- Skie
	plantname = "nettle"
	desc = "It's probably <B>not</B> wise to touch it with bare hands..."
	icon = 'icons/obj/weapons.dmi'
	name = "nettle"
	icon_state = "nettle"
	damtype = "fire"
	force = 15
	flags = 0
	throwforce = 1
	w_class = W_CLASS_SMALL
	throw_speed = 1
	throw_range = 3
	origin_tech = Tc_COMBAT + "=1"

/obj/item/weapon/grown/nettle/New()
	..()
	spawn(5)
		force = round((5+potency/5), 1)

/obj/item/weapon/grown/nettle/pickup(mob/living/carbon/human/user as mob) //todo this
	if(istype(user))
		if(!user.gloves)
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

/obj/item/weapon/grown/deathnettle // -- Skie
	plantname = "deathnettle"
	desc = "A glowing red nettle that incites rage in you just from looking at it."
	icon = 'icons/obj/weapons.dmi'
	name = "deathnettle"
	icon_state = "deathnettle"
	damtype = "fire"
	force = 30
	flags = 0
	throwforce = 1
	w_class = W_CLASS_SMALL
	throw_speed = 1
	throw_range = 3
	origin_tech = Tc_COMBAT + "=3"
	attack_verb = list("stings, pricks")

/obj/item/weapon/grown/deathnettle/New()
	..()
	spawn(5)
		force = round((5+potency/2.5), 1)

/obj/item/weapon/grown/deathnettle/suicide_act(mob/user)
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
	icon = 'icons/obj/harvest.dmi'
	icon_state = "corncob"
	item_state = "corncob"
	w_class = W_CLASS_SMALL
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/corncob/attackby(obj/item/weapon/W as obj, mob/user as mob)
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
