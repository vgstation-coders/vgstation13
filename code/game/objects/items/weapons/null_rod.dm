/obj/item/weapon/nullrod
	name = "null rod"
	desc = "A rod of pure obsidian, its very presence disrupts and dampens the powers of paranormal phenomenae."
	icon_state = "nullrod"
	item_state = "nullrod"
	flags = FPRINT
	slot_flags = SLOT_BELT
	force = 15
	throw_speed = 1
	throw_range = 4
	throwforce = 10
	w_class = W_CLASS_TINY
	var/reskinned = FALSE
	var/reskin_selectable = TRUE						//set to FALSE if a subtype is meant to not normally be available as a reskin option (fluff ones will get re-added through their list)
	var/list/fluff_transformations = list() //does it have any special transformations only accessible to it? Should only be subtypes of /obj/item/weapon/nullrod

/obj/item/weapon/nullrod/suicide_act(mob/user)
	user.visible_message("<span class='danger'>[user] is impaling \himself with \the [src]! It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/nullrod/attack(mob/M as mob, mob/living/user as mob) //Paste from old-code to decult with a null rod.

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	msg_admin_attack("[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

	if(!ishuman(user) && !isbadmonkey(user) && !ismartian(user)) //Fucks sakes
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if(clumsy_check(user) && prob(50))
		user.visible_message("<span class='warning'>\The [src] slips out of [user]'s hands and hits \his head.</span>",
		"<span class='warning'>\The [src] slips out of your hands and hits your head.</span>")
		user.apply_damage(10, BRUTE, LIMB_HEAD)
		user.Stun(5)
		return

	if(ishuman(M)) //Typecasting, only humans can be vampires
		var/mob/living/carbon/human/H = M

		if(isvampire(H) && user.mind && (user.mind.assigned_role == "Chaplain")) //Fuck up vampires by smithing the shit out of them. Shock and Awe!
			if(!(VAMP_MATURE in H.mind.vampire.powers))
				to_chat(H, "<span class='warning'>\The [src]'s power violently interferes with your own!</span>")
				if(H.mind.vampire.nullified < 5) //Don't actually reduce their debuff if it's over 5
					H.mind.vampire.nullified = max(5, H.mind.vampire.nullified + 2)
				H.mind.vampire.smitecounter += 30 //Smithe the shit out of him. Four strikes and he's out

	//A 25% chance to de-cult per hit that bypasses all protections? Is this some kind of joke? The last thing cult needs right now is that kind of nerfs. Jesus dylan.
	/*
	if(iscult(M) && user.mind && (user.mind.assigned_role == "Chaplain")) //Much higher chance of deconverting cultists per hit if Chaplain
		if(prob(25))
			to_chat(M, "<span class='notice'>\The [src]'s intense field suddenly clears your mind of heresy. Your allegiance to Nar'Sie wanes!</span>")
			to_chat(user, "<span class='notice'>You see [M]'s eyes become clear. Nar'Sie no longer controls his mind, \the [src] saved him!</span>")
			ticker.mode.remove_cultist(M.mind)
		else //We aren't deconverting him this time, give the Cultist a fair warning
			to_chat(M, "<span class='warning'>\The [src]'s intense field is overwhelming you. Your mind feverishly questions Nar'Sie's teachings!</span>")
	*/

	..() //Whack their shit regardless. It's an obsidian rod, it breaks skulls

/obj/item/weapon/nullrod/afterattack(atom/A, mob/user as mob, prox_flag, params)
	if(!prox_flag)
		return
	user.delayNextAttack(8)
	if(istype(A, /turf/simulated/floor))
		to_chat(user, "<span class='notice'>You hit the floor with the [src].</span>")
		call(/obj/effect/rune/proc/revealrunes)(src)

/obj/item/weapon/nullrod/pickup(mob/living/user as mob)
	if(user.mind)
		if(user.mind.assigned_role == "Chaplain")
			to_chat(user, "<span class='notice'>The obsidian rod is teeming with divine power. You feel like you could pulverize a horde of undead with this.</span>")
		if(ishuman(user)) //Typecasting, only humans can be vampires
			var/mob/living/carbon/human/H = user
			if(isvampire(H) && !(VAMP_UNDYING in H.mind.vampire.powers))
				H.mind.vampire.smitecounter += 60
				to_chat(H, "<span class='danger'>You feel an unwanted presence as you pick up the rod. Your body feels like it is burning from the inside!</span>")

/obj/item/weapon/nullrod/attack_self(mob/user)
	if(reskinned)
		return
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		reskin_holy_weapon(user)

/obj/item/weapon/nullrod/proc/reskin_holy_weapon(mob/living/M)
	var/list/holy_weapons_list = typesof(/obj/item/weapon/nullrod)
	for(var/entry in holy_weapons_list)
		var/obj/item/weapon/nullrod/variant = entry
		if(!initial(variant.reskin_selectable))
			holy_weapons_list -= variant
	if(fluff_transformations.len)
		for(var/thing in fluff_transformations)
			holy_weapons_list += thing
	var/list/display_names = list()
	for(var/V in holy_weapons_list)
		var/atom/A = V
		display_names += initial(A.name)

	var/choice = input(M,"What theme would you like for your holy weapon?","Holy Weapon Theme") as null|anything in display_names
	if(!src || !choice || !in_range(M, src) || M.incapacitated() || reskinned)
		return

	var/index = display_names.Find(choice)
	var/A = holy_weapons_list[index]

	var/obj/item/weapon/nullrod/holy_weapon = new A

	feedback_set_details("chaplain_weapon","[choice]")

	if(holy_weapon)
		visible_message("<span class='notice'>[M.name] invokes the power of [ticker.Bible_deity_name] to transform \the [src] into \a [holy_weapon.name]!</span>")
		holy_weapon.reskinned = TRUE
		M.drop_item(src, force_drop = 1)
		M.put_in_active_hand(holy_weapon)
		qdel(src)

/obj/item/weapon/nullrod/sword
	name = "holy avenger"
	icon_state = "avenger"
	item_state = "avenger"
	desc = "DEUS VULT!"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	w_class = W_CLASS_LARGE
	slot_flags = SLOT_BACK|SLOT_BELT
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")

/obj/item/weapon/nullrod/sword/IsShield()
	return prob(10) //Only TRIES to block 10% of the attacks. SO MANY LAYERS OF RNG but hey.

/obj/item/weapon/nullrod/sword/cult //Muh cult religion.
	name = "cult blade"
	desc = "Spread the glory of the blood god!"
	icon_state = "cultblade"
	item_state = "cultblade"

/obj/item/weapon/nullrod/sword/katana //*tips fedora*
	name = "saint katana"
	desc = "This weapon can cut clean through plasteel because its blade was folded over a thousand times, making it vastly superior to any other holy weapon."
	icon_state = "katana"
	item_state = "katana"

/obj/item/weapon/nullrod/toolbox //Syndicate/Robust religion
	name = "nullbox"
	desc = "The holder of nothingness. If you holy book isn't working, try this one instead."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "toolbox_syndi"
	item_state = "toolbox_syndi"
	hitsound = 'sound/weapons/toolbox.ogg'
	attack_verb = list("robusts", "batters", "staves in")
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/toolbox_ihl.dmi', "right_hand" = 'icons/mob/in-hand/right/toolbox_ihr.dmi')
	w_class = W_CLASS_LARGE

/obj/item/weapon/nullrod/spear //Ratvar? How!
	name = "divine brass spear"
	desc = "A holy, bronze weapon of ancient design."
	hitsound = 'sound/weapons/bladeslice.ogg'
	icon_state = "clockwork0"
	item_state = "clockwork0"
	attack_verb = list("stabs", "pokes", "pierces", "cuts")
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	w_class = W_CLASS_LARGE
	flags = TWOHANDABLE | FPRINT

/obj/item/weapon/nullrod/spear/update_wield(var/mob/user)
	icon_state = "clockwork[wielded ? 1 : 0]"
	item_state = icon_state
	if(user)
		user.update_inv_hands()

/obj/item/weapon/nullrod/spear/attack_self(mob/user)
	if(wielded)
		unwield(user)
	else
		wield(user)
