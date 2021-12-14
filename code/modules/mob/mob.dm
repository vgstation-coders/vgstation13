#define MOB_SPACEDRUGS_HALLUCINATING 5
#define MOB_MINDBREAKER_HALLUCINATING 100

/mob
	plane = MOB_PLANE
	pass_flags_self = PASSMOB
	var/said_last_words = 0 // All mobs can now whisper as they die
	var/list/alerts = list()

/mob/variable_edited(var_name, old_value, new_value)
	.=..()

	switch(var_name)
		if("stat")
			if((old_value == 2) && (new_value < 2))//Bringing the dead back to life
				resurrect()
			else if((old_value < 2) && (new_value == 2))//Kill he
				living_mob_list.Remove(src)
				dead_mob_list.Add(src)

/mob/recycle(var/datum/materials)
	return RECYK_BIOLOGICAL

/mob/burnFireFuel(var/used_fuel_ratio,var/used_reactants_ratio)

/mob/Destroy() // This makes sure that mobs with clients/keys are not just deleted from the game.
	for(var/datum/mind/mind in heard_by)
		for(var/M in mind.heard_before)
			if(mind.heard_before[M] == src)
				mind.heard_before[M] = null
	unset_machine()
	if(mind && mind.current == src)
		mind.current = null
	spellremove(src)
	if(istype(src,/mob/living/carbon))//iscarbon is defined at the mob/living level
		var/mob/living/carbon/Ca = src
		Ca.dropBorers(1)//sanity checking for borers that haven't been qdel'd yet
	if(client)
		for(var/obj/abstract/screen/movable/spell_master/spell_master in spell_masters)
			qdel(spell_master)
		spell_masters = null
		remove_screen_objs()
		for(var/atom/movable/AM in client.screen)
			var/obj/abstract/screen/screenobj = AM
			if(istype(screenobj))
				if(!screenobj.globalscreen) //Screens taken care of in other places or used by multiple people
					qdel(AM)
			else
				qdel(AM)
		client.screen = list()
	mob_list.Remove(src)
	dead_mob_list.Remove(src)
	living_mob_list.Remove(src)
	ghostize(0)
	//Fuck datums amirite
	click_delayer = null
	attack_delayer = null
	special_delayer = null
	throw_delayer = null
	qdel(hud_used)
	hud_used = null
	for(var/atom/movable/leftovers in src)
		qdel(leftovers)

	if(transmogged_from)
		qdel(transmogged_from)
		transmogged_from = null
	if(transmogged_to)
		qdel(transmogged_to)
		transmogged_to = null
	if(control_object.len)
		for(var/A in control_object)
			qdel(A)
		control_object = null
	if(orient_object.len)
		for(var/A in orient_object)
			qdel(A)
		orient_object = null

	if (ticker && ticker.mode)
		ticker.mode.mob_destroyed(src)
	..()

/mob/projectile_check()
	return PROJREACT_MOBS

/mob/proc/remove_screen_objs()
	if(hands)
		qdel(hands)
		if(client)
			client.screen -= hands
		hands = null
	if(pullin)
		qdel(pullin)
		if(client)
			client.screen -= pullin
		pullin = null
	if(kick_icon)
		qdel(kick_icon)
		if(client)
			client.screen -= kick_icon
		kick_icon = null
	if(bite_icon)
		qdel(bite_icon)
		if(client)
			client.screen -= bite_icon
		bite_icon = null
	if(visible)
		qdel(visible)
		if(client)
			client.screen -= visible
		visible = null
	if(internals)
		qdel(internals)
		if(client)
			client.screen -= internals
		internals = null
	if(i_select)
		qdel(i_select)
		if(client)
			client.screen -= i_select
		i_select = null
	if(m_select)
		qdel(m_select)
		if(client)
			client.screen -= m_select
		m_select = null
	if(healths)
		qdel(healths)
		if(client)
			client.screen -= healths
		healths = null
	if(healths2)
		qdel(healths2)
		if(client)
			client.screen -= healths2
		healths2 = null
	if(throw_icon)
		qdel(throw_icon)
		if(client)
			client.screen -= throw_icon
		throw_icon = null
	if(damageoverlay)
		qdel(damageoverlay)
		if(client)
			client.screen -= damageoverlay
		damageoverlay = null
	if(pain)
		qdel(pain)
		if(client)
			client.screen -= pain
		pain = null
	if(item_use_icon)
		qdel(item_use_icon)
		if(client)
			client.screen -= item_use_icon
		item_use_icon = null
	if(gun_move_icon)
		qdel(gun_move_icon)
		if(client)
			client.screen -= gun_move_icon
		gun_move_icon = null
	if(gun_run_icon)
		qdel(gun_run_icon)
		if(client)
			client.screen -= gun_run_icon
		gun_run_icon = null
	if(gun_setting_icon)
		qdel(gun_setting_icon)
		if(client)
			client.screen -= gun_setting_icon
		gun_setting_icon = null
	if(m_suitclothes)
		qdel(m_suitclothes)
		if(client)
			client.screen -= m_suitclothes
		m_suitclothes = null
	if(m_suitclothesbg)
		qdel(m_suitclothesbg)
		if(client)
			client.screen -= m_suitclothesbg
		m_suitclothesbg = null
	if(m_hat)
		qdel(m_hat)
		if(client)
			client.screen -= m_hat
		m_hat = null
	if(m_hatbg)
		qdel(m_hatbg)
		if(client)
			client.screen -= m_hatbg
		m_hatbg = null
	if(m_glasses)
		qdel(m_glasses)
		if(client)
			client.screen -= m_glasses
		m_glasses = null
	if(m_glassesbg)
		qdel(m_glassesbg)
		if(client)
			client.screen -= m_glassesbg
		m_glasses = null
	if(zone_sel)
		qdel(zone_sel)
		if(client)
			client.screen -= zone_sel
		zone_sel = null

	if(iscultist(src) && hud_used)
		if(hud_used.cult_Act_display)
			qdel(hud_used.cult_Act_display)
			if(client)
				client.screen -= hud_used.cult_Act_display
			hud_used.cult_Act_display = null
		if(hud_used.cult_tattoo_display)
			qdel(hud_used.cult_tattoo_display)
			if(client)
				client.screen -= hud_used.cult_tattoo_display
			hud_used.cult_tattoo_display = null

/mob/proc/cultify()
	return

/mob/proc/clockworkify()
	return

/mob/New()
	. = ..()
	original_density = density

	mob_list += src

	if(DEAD == stat)
		dead_mob_list += src
	else
		living_mob_list += src

	store_position()

	forceMove(loc) //Without this, area.Entered() isn't called when a mob is spawned inside area

	if(flags & HEAR_ALWAYS)
		virtualhearer = new /mob/virtualhearer(src)

	update_colour(0)

/mob/Del()
	if(flags & HEAR_ALWAYS)
		if(virtualhearer)
			qdel(virtualhearer)
			virtualhearer = null
	..()

/mob/proc/is_muzzled()
	return 0

/mob/proc/store_position()
	origin_x = x
	origin_y = y
	origin_z = z

/mob/proc/send_back()
	x = origin_x
	y = origin_y
	z = origin_z

/mob/proc/generate_name()
	return name

/**
 * Player panel controls for this mob.
 */
/mob/proc/player_panel_controls(var/mob/user)
	return ""

/mob/proc/Cell()
	set category = "Admin"
	set hidden = 1

	if(!loc)
		return 0

	var/datum/gas_mixture/environment = loc.return_air()

	var/t = "<span class='notice'> Coordinates: [x],[y] \n</span>"

	t += "<span class='warning'> Temperature: [environment.temperature] \n</span>"
	for(var/g in environment.gas)
		to_chat(usr, "<span class='notice'> [XGM.name[g]]: [environment.gas[g]] \n</span>")

	usr.show_message(t, 1)

/mob/proc/simple_message(var/msg, var/hallucination_msg) // Same as M << "message", but with additinal message for hallucinations.
	if(hallucinating() && hallucination_msg)
		to_chat(src, hallucination_msg)
	else
		to_chat(src, msg)

/mob/proc/show_message(var/msg, var/type, var/alt, var/alt_type, var/mob/speaker)//Message, type of message (1=visible or 2=hearable), alternative message, alt message type (1=if blind or 2=if deaf), and optionally the speaker
	//Because the person who made this is a fucking idiot, let's clarify. 1 is sight-related messages (aka emotes in general), 2 is hearing-related (aka HEY DUMBFUCK I'M TALKING TO YOU)

	if(!client) //We dun goof
		return

	if (!type) //No type, we want the message to appear no matter our awareness as long as we aren't uncounscious or sleeping
		if(stat != UNCONSCIOUS)
			to_chat(src, msg)
		return

	var/awareness = 0
	if(stat != UNCONSCIOUS)
		if (!is_blind())
			awareness |= MESSAGE_SEE
		if (!is_deaf())
			awareness |= MESSAGE_HEAR

	if (awareness & type)
		to_chat(src, msg)
	else if (awareness & alt_type)
		to_chat(src, alt)
	else if (speaker && (speaker.ckey == ckey) && speaker.isincrit() && speaker.said_last_words) //You can hear your own last words.
		to_chat(src, msg)
	else if ((type == MESSAGE_HEAR) || (alt_type == MESSAGE_HEAR)) //we're completely unaware, either deafblind or sleeping.
		if (speaker)
			to_chat(src, "<span class='notice'>You can almost hear someone talking.</span>")
		else
			to_chat(src, "<span class='notice'>You can almost hear something.</span>")

// Show a message to all mobs in sight of this one
// This would be for visible actions by the src mob
// message is the message output to anyone who can see e.g. "[src] does something!"
// self_message (optional) is what the src mob sees  e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
// drugged_message (optional) is shown to hallucinating mobs instead of message
// self_drugged_message (optional) is shown to src mob if it's hallucinating
// blind_drugged_message (optional) is shown to blind hallucinating people
// ignore_self (optional) won't show the message to the mob sending the message

/mob/visible_message(var/message, var/self_message, var/blind_message, var/drugged_message, var/self_drugged_message, var/blind_drugged_message, var/ignore_self = 0, var/range = 7)
	var/hallucination = hallucinating()
	var/msg = message
	var/msg2 = blind_message

	if(self_message)
		msg = self_message
	if(hallucination)
		if(self_drugged_message)
			msg = self_drugged_message
		if(blind_drugged_message)
			msg2 = blind_drugged_message

	if(!ignore_self)
		show_message( msg, MESSAGE_SEE, msg2, MESSAGE_HEAR)

	..(message, blind_message, drugged_message, blind_drugged_message, range)

/mob/on_see(var/message, var/blind_message, var/drugged_message, var/blind_drugged_message, atom/A)
	if(see_invisible < A.invisibility || src == A)
		return
	var/hallucination = hallucinating()
	var/msg = message
	var/msg2 = blind_message
	if(hallucination || (src in confusion_victims))
		if(drugged_message)
			msg = drugged_message
		if(blind_drugged_message)
			msg2 = blind_drugged_message
	show_message( msg, MESSAGE_SEE, msg2, MESSAGE_HEAR)

// Show a message to all mobs in sight of this atom
// Use for objects performing visible actions
// message is output to anyone who can see, e.g. "The [src] does something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"

/atom/proc/visible_message(var/message, var/blind_message, var/drugged_message, var/blind_drugged_message, var/range = 7)
	if(world.time>resethearers)
		sethearing()
	var/atom/location = get_holder_at_turf_level(src) || get_turf(src) // Holders are nicer than turfs, I guess
	var/turf/T_loc = get_turf(location) // For getting the .z var, atoms don't have this by default
	var/list/found_Zs = GetOpenConnectedZlevels(location) // Saves constantly calling it
	for(var/z0 in found_Zs)
		if(!found_Zs.len || abs(z0 - T_loc.z) <= range) // So we can get in with an empty list
			var/atom/thing_to_see
			if(!found_Zs.len || z0 == T_loc.z) // Now this is why we need the empty list
				thing_to_see = location // Put that holder thingy to work, like the original version of this function did
			else
				thing_to_see = locate(T_loc.x,T_loc.y,z0) // If not on the same zlevel as it, just do it on turfs, location goes there if all else fails anyways.
			for(var/mob/virtualhearer/hearer in viewers(range, thing_to_see)) // Rest is self explanatory from here
				var/mob/M
				if(istype(hearer.attached, /obj/machinery/hologram/holopad))
					var/obj/machinery/hologram/holopad/holo = hearer.attached
					if(holo.master)
						M = holo.master
				if(istype(hearer.attached, /mob))
					M = hearer.attached
				if(M)
					if(M.client)
						var/client/C = M.client
						if(get_turf(src) in C.ObscuredTurfs)
							continue
				hearer.attached.on_see(message, blind_message, drugged_message, blind_drugged_message, src)

/mob/proc/findname(msg)
	for(var/mob/M in mob_list)
		if (M.real_name == text("[]", msg))
			return M
	return 0

/mob/proc/Life()
	set waitfor = FALSE

	update_perception()

	if(timestopped)
		return 0 //under effects of time magick
	if(spell_masters && spell_masters.len)
		for(var/obj/abstract/screen/movable/spell_master/spell_master in spell_masters)
			spell_master.update_spells(0, src)

	for (var/time in crit_rampup)
		if (world.time > num2text(time) + 20 SECONDS) // clear out the items older than 20 seconds
			crit_rampup -= time

/mob/proc/see_narsie(var/obj/machinery/singularity/narsie/large/N, var/dir)
	if(N.chained)
		if(narsimage)
			del(narsimage)
			del(narglow)
		return

	//No need to make an exception for mechas, as they get deleted as soon as they get in view of narnar

	if((N.z == src.z)&&(get_dist(N,src) <= (N.consume_range+10)) && !(N in view(src)))
		if(!narsimage) //Create narsimage
			narsimage = image('icons/obj/narsie.dmi',src.loc,"narsie",9,1)
			narsimage.mouse_opacity = 0
		if(!narglow) //Create narglow
			narglow = image('icons/obj/narsie.dmi',narsimage.loc,"glow-narsie", NARSIE_GLOW, 1)
			narglow.plane = ABOVE_LIGHTING_PLANE
			narglow.mouse_opacity = 0
/* Animating narsie works like shit thanks to fucking byond
		if(!N.old_x || !N.old_y)
			N.old_x = src.x
			N.old_y = src.y
		//Reset narsie's location to the mob
		var/old_pixel_x = 32 * (N.old_x - src.x) + N.pixel_x
		var/old_pixel_y = 32 * (N.old_y - src.y) + N.pixel_y
		narsimage.pixel_x = old_pixel_x
		narsimage.pixel_y = old_pixel_y
		narglow.pixel_x = old_pixel_x
		narglow.pixel_y = old_pixel_y
		narsimage.forceMove(src.loc)
		narglow.forceMove(src.loc)
		//Animate narsie based on dir
		if(dir)
			var/x_diff = 0
			var/y_diff = 0
			switch(dir) //I bet somewhere out there a proc does something like this already
				if(1)
					x_diff = 32
				if(2)
					x_diff = -32
				if(4)
					y_diff = 32
				if(8)
					y_diff = -32
				if(5)
					x_diff = 32
					y_diff = 32
				if(6)
					x_diff = 32
					y_diff = -32
				if(9)
					x_diff = -32
					y_diff = 32
				if(10)
					x_diff = -32
					y_diff = -32
			animate(narsimage, pixel_x = old_pixel_x+x_diff, pixel_y = old_pixel_y+y_diff, time = 8) //Animate the movement of narsie to narsie's new location
			animate(narglow, pixel_x = old_pixel_x+x_diff, pixel_y = old_pixel_y+y_diff, time = 8)
*/
		//Else if no dir is given, simply send them the image of narsie
		var/new_x = WORLD_ICON_SIZE * (N.x - src.x) + N.pixel_x
		var/new_y = WORLD_ICON_SIZE * (N.y - src.y) + N.pixel_y
		narsimage.pixel_x = new_x
		narsimage.pixel_y = new_y
		narglow.pixel_x = new_x
		narglow.pixel_y = new_y
		narsimage.loc = src.loc
		narglow.loc = src.loc
		//Display the new narsimage to the player
		src << narsimage
		src << narglow
	else
		if(narsimage)
			del(narsimage)
			del(narglow)

/mob/proc/see_rift(var/obj/machinery/singularity/narsie/large/exit/R)
	var/turf/T_mob = get_turf(src)
	if((R.z == T_mob.z) && (get_dist(R,T_mob) <= (R.consume_range+10)) && !(R in view(T_mob)))
		if(!riftimage)
			riftimage = image('icons/obj/rift.dmi',T_mob,"rift", SUPER_PORTAL_LAYER, 1)
			riftimage.plane = ABOVE_LIGHTING_PLANE
			riftimage.mouse_opacity = 0

		var/new_x = WORLD_ICON_SIZE * (R.x - T_mob.x) + R.pixel_x
		var/new_y = WORLD_ICON_SIZE * (R.y - T_mob.y) + R.pixel_y
		riftimage.pixel_x = new_x
		riftimage.pixel_y = new_y
		riftimage.loc = T_mob

		to_chat(src, riftimage)
	else
		if(riftimage)
			del(riftimage)

/mob/proc/get_item_by_slot(slot_id)
	return null

/mob/proc/get_item_by_flag(slot_flag)
	return null

/mob/proc/restrained()
	if(timestopped)
		return TRUE //under effects of time magick
	return FALSE

//This proc is called whenever someone clicks an inventory ui slot.
/mob/proc/attack_ui(slot, hand_index)
	var/obj/item/W = get_active_hand()
	if(istype(W))
		if(slot)
			equip_to_slot_if_possible(W, slot)
		else if(hand_index)
			put_in_hand(hand_index, W)
	else
		W = get_item_by_slot(slot)
		if(W)
			W.attack_hand(src)

	/*if(ishuman(src) && W == src:head) //AAAAAUGH
		src:update_hair()*/

/mob/proc/put_in_any_hand_if_possible(obj/item/W as obj)
	for(var/index = 1 to held_items.len)
		if(put_in_hand(index, W))
			return 1
	return 0

//This is a SAFE proc. Use this instead of equip_to_slot()!
//set del_on_fail to have it delete W if it fails to equip
//set disable_warning to disable the 'you are unable to equip that' warning.
//unset redraw_mob to prevent the mob from being redrawn at the end.
/mob/proc/equip_to_slot_if_possible(obj/item/W as obj, slot, act_on_fail = 0, disable_warning = 0, redraw_mob = 1, automatic = 0)
	if(!istype(W))
		return 0

	if(!W.mob_can_equip(src, slot, disable_warning))
		switch(act_on_fail)
			if(EQUIP_FAILACTION_DELETE)
				qdel(W)
				W = null
			if(EQUIP_FAILACTION_DROP)
				W.forceMove(get_turf(src)) //Should this be using drop_from_inventory instead?
			else
				if(!disable_warning)
					to_chat(src, "<span class='warning'>You are unable to equip that.</span>")//Only print if act_on_fail is NOTHING

		return 0

	equip_to_slot(W, slot, redraw_mob) //This proc should not ever fail.
	return 1

//This is an UNSAFE proc. It merely handles the actual job of equipping. All the checks on whether you can or can't eqip need to be done before! Use mob_can_equip() for that task.
//In most cases you will want to use equip_to_slot_if_possible()
/mob/proc/equip_to_slot(obj/item/W as obj, slot)
	return

//This is just a commonly used configuration for the equip_to_slot_if_possible() proc, used to equip people when the round starts and when events happen and such.
/mob/proc/equip_to_slot_or_del(obj/item/W as obj, slot)
	return equip_to_slot_if_possible(W, slot, EQUIP_FAILACTION_DELETE, 1, 0)

//This is just a commonly used configuration for the equip_to_slot_if_possible() proc, used to equip people when the round starts and when events happen and such.
/mob/proc/equip_to_slot_or_drop(obj/item/W as obj, slot)
	return equip_to_slot_if_possible(W, slot, EQUIP_FAILACTION_DROP, 1, 0)

// Convenience proc.  Collects crap that fails to equip either onto the mob's back, or drops it.
// Used in job equipping so shit doesn't pile up at the start loc.
/mob/living/carbon/human/proc/equip_or_collect(var/obj/item/W, var/slot)
	if(!equip_to_slot_or_drop(W, slot))
		// Do I have a backpack?
		var/obj/item/weapon/storage/B = back

		// Do I have a plastic bag?
		if(!B)
			var/index = find_held_item_by_type(/obj/item/weapon/storage/bag/plasticbag)
			if(index)
				B = held_items[index]

		if(!B)
			// Gimme one.
			B=new /obj/item/weapon/storage/bag/plasticbag(null) // Null in case of failed equip.
			if(!put_in_hands(B,slot_back))
				return // Fuck it
		B.handle_item_insertion(W,1)

//The list of slots by priority. equip_to_appropriate_slot() uses this list. Doesn't matter if a mob type doesn't have a slot.
var/list/slot_equipment_priority = list( \
		slot_back,\
		slot_wear_id,\
		slot_w_uniform,\
		slot_wear_suit,\
		slot_wear_mask,\
		slot_head,\
		slot_shoes,\
		slot_gloves,\
		slot_ears,\
		slot_glasses,\
		slot_belt,\
		slot_s_store,\
		slot_l_store,\
		slot_r_store\
	)

/*Equips accessories.
A is the mob
B is the accessory.
C is what item the accessory will look to be attached to, important.
D will look how many accessories the item already has, and will move on if its attachment would go above the amount of accessories
E will stop the proc if a candidate had the accessory attached to it and it is toggled on
Use this proc preferably at the end of an equipment loadout
*/
/proc/equip_accessory(var/mob/living/carbon/human/mob, var/obj/item/accessory, var/what_it_looks_for, var/accessory_limit = 1, var/stop_upon_finding_candidate = 0)
	for(var/obj/item/clothing/I in get_contents_in_object(mob))
		if(!istype(I, what_it_looks_for) || (I.accessories.len >= accessory_limit))
			continue
		I.attach_accessory(new accessory)
		if(stop_upon_finding_candidate)
			break

//puts the item "W" into an appropriate slot in a human's inventory
//returns 0 if it cannot, 1 if successful
/mob/proc/equip_to_appropriate_slot(obj/item/W, var/override = FALSE)
	if(!istype(W))
		return 0

	for(var/slot in slot_equipment_priority)
		if(!is_holding_item(W) && !override)
			return 0
		var/obj/item/S = get_item_by_slot(slot)
		if(S && S.can_quick_store(W))
			return S.quick_store(W)
		if(equip_to_slot_if_possible(W, slot, 0, 1, 1, 0)) //act_on_fail = 0; disable_warning = 0; redraw_mob = 1
			return 1

	return 0

/mob/proc/check_for_open_slot(obj/item/W)
	if(!istype(W))
		return 0
	var/openslot = 0
	for(var/slot in slot_equipment_priority)
		if(W.mob_check_equip(src, slot, 1) == 1)
			openslot = 1
			break
	return openslot

/mob/proc/unequip_everything()
	var/list/unequipped_items = list()
	for(var/slot in slot_equipment_priority)
		var/obj/item/I = get_item_by_slot(slot)
		if(I)
			unequipped_items.Add(I)
			u_equip(I)
	return unequipped_items

/mob/proc/recursive_list_equip(list/L)	//Used for equipping a list of items to a mob without worrying about the order (like needing to put a jumpsuit before a belt)
	if(!L || !L.len)
		return

	for(var/obj/item/O in L)
		O.forceMove(get_turf(src))	//At the very least, all the stuff should be on our tile

	var/has_succeeded_once = TRUE
	while(has_succeeded_once)
		has_succeeded_once = FALSE
		for(var/obj/item/I in L)
			if(equip_to_appropriate_slot(I, TRUE)) // The proc wants the item to be in our hands, like in the case of a quick-equip
				has_succeeded_once = TRUE
				L.Remove(I)
	if(L.len)
		var/obj/item/weapon/storage/B = back
		for(var/obj/item/I in L)
			if(istype(B))
				B.handle_item_insertion(I,1)
	regenerate_icons()

/obj/item/proc/mob_check_equip(M as mob, slot, disable_warning = 0)
	if(!M)
		return 0
	if(!slot)
		return 0
	if(ishuman(M))
		//START HUMAN
		var/mob/living/carbon/human/H = M

		switch(slot)
			if(slot_wear_mask)
				if( !(slot_flags & SLOT_MASK) )
					return 0
//				if(H.species.anatomy_flags & IS_BULKY)
//					to_chat(H, "<span class='warning'>You can't get \the [src] to fasten around your thick head!</span>")
//					return 0
				if(H.wear_mask)
					return 0
				return 1
			if(slot_back)
				if( !(slot_flags & SLOT_BACK) )
					return 0
				if(H.back)
					if(H.back.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_wear_suit)
				if( !(slot_flags & SLOT_OCLOTHING) )
					return 0
//				if(H.species.anatomy_flags & IS_BULKY)
//					to_chat(H, "<span class='warning'>You can't get \the [src] to fit over your bulky exterior!</span>")
//					return 0
				if(H.wear_suit)
					if(H.wear_suit.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_gloves)
				if( !(slot_flags & SLOT_GLOVES) )
					return 0
//				if(H.species.anatomy_flags & IS_BULKY)
//					to_chat(H, "<span class='warning'>You can't get \the [src] to fit over your bulky fingers!</span>")
//					return 0
				if(H.gloves)
					if(H.gloves.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_shoes)
				if( !(slot_flags & SLOT_FEET) )
					return 0
//				if(H.species.anatomy_flags & IS_BULKY)
//					to_chat(H, "<span class='warning'>You can't get \the [src] to fit over your bulky feet!</span>")
//					return 0
				if(H.shoes)
					if(H.shoes.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_belt)
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return 0
				if( !(slot_flags & SLOT_BELT) )
					return 0
				if(H.belt)
					if(H.belt.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_glasses)
				if( !(slot_flags & SLOT_EYES) )
					return 0
				if(H.glasses)
					if(H.glasses.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_head)
				if( !(slot_flags & SLOT_HEAD) )
					return 0
				if(H.head)
					if(H.head.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_ears)
				if( !(slot_flags & slot_ears) )
					return 0
				if(H.ears)
					if(H.ears.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_w_uniform)
				if( !(slot_flags & SLOT_ICLOTHING) )
					return 0
				if((M_FAT in H.mutations) && (H.species && H.species.anatomy_flags & CAN_BE_FAT) && !(clothing_flags & ONESIZEFITSALL))
					return 0
//				if(H.species.anatomy_flags & IS_BULKY && !(clothing_flags & ONESIZEFITSALL))
//					to_chat(H, "<span class='warning'>You can't get \the [src] to fit over your bulky exterior!</span>")
//					return 0
				if(H.w_uniform)
					if(H.w_uniform.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_wear_id)
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return 0
				if( !(slot_flags & SLOT_ID) )
					return 0
				if(H.wear_id)
					if(H.wear_id.canremove)
						return 2
					else
						return 0
				return 1
			if(slot_l_store)
				if(H.l_store)
					return 0
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return 0
				if(slot_flags & SLOT_DENYPOCKET)
					return
				if( w_class <= W_CLASS_SMALL || (slot_flags & SLOT_POCKET) )
					return 1
			if(slot_r_store)
				if(H.r_store)
					return 0
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return 0
				if(slot_flags & SLOT_DENYPOCKET)
					return 0
				if( w_class <= W_CLASS_SMALL || (slot_flags & SLOT_POCKET) )
					return 1
				return 0
			if(slot_s_store)
				if(!H.wear_suit)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a suit before you can attach this [name].</span>")
					return 0
				if(!H.wear_suit.allowed)
					if(!disable_warning)
						to_chat(usr, "You somehow have a suit with no defined allowed items for suit storage, stop that.")
					return 0
				if(src.w_class > W_CLASS_MEDIUM)
					if(!disable_warning)
						to_chat(usr, "The [name] is too big to attach.")
					return 0
				if( istype(src, /obj/item/device/pda) || istype(src, /obj/item/weapon/pen) || is_type_in_list(src, H.wear_suit.allowed) )
					if(H.s_store)
						if(H.s_store.canremove)
							return 2
						else
							return 0
					else
						return 1
				return 0
			if(slot_handcuffed)
				if(H.handcuffed || H.mutual_handcuffs)
					return 0
				if(!istype(src, /obj/item/weapon/handcuffs))
					return 0
				return 1
			if(slot_legcuffed)
				if(H.legcuffed)
					return 0
				if(!istype(src, /obj/item/weapon/legcuffs))
					return 0
				return 1
			if(slot_in_backpack)
				if (H.back && istype(H.back, /obj/item/weapon/storage/backpack))
					var/obj/item/weapon/storage/backpack/B = H.back
					if(!B.storage_slots && w_class <= B.fits_max_w_class)
						return 1
					if(B.contents.len < B.storage_slots && w_class <= B.fits_max_w_class)
						return 1
				return 0
		return 0 //Unsupported slot
		//END HUMAN
/mob/proc/reset_view(atom/A)
	if (client)
		if (istype(A, /atom/movable))
			client.perspective = EYE_PERSPECTIVE
			client.eye = A
		else
			client.eye = client.mob
			client.perspective = MOB_PERSPECTIVE

/mob/proc/show_inv(mob/user as mob)
	user.set_machine(src)
	var/dat = ""
	dat += "<B><HR><FONT size=3>[name]</FONT></B>"
	dat += "<BR><HR>"
	dat += "<BR><B>Mask:</B> <A href='?src=\ref[src];item=[slot_wear_mask]'>[makeStrippingButton(wear_mask)]</A>"

	for(var/i = 1 to held_items.len) //Hands
		var/obj/item/I = held_items[i]
		dat += "<B>[capitalize(get_index_limb_name(i))]</B> <A href='?src=\ref[src];hands=[i]'>[makeStrippingButton(I)]</A><BR>"

	dat += "<BR><B>Back:</B> <A href='?src=\ref[src];item=[slot_back]'>[makeStrippingButton(back)]</A>"

	dat += "<BR>"

	dat += {"
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	<BR>"}
	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 325, 500)
	popup.set_content(dat)
	popup.open()
	return

/mob/proc/ret_grab(obj/effect/list_container/mobl/L as obj, flag)
	if (!find_held_item_by_type(/obj/item/weapon/grab)) //No grab in hands
		if (!( L ))
			return null
		else
			return L.container
	else
		if (!( L ))
			L = new /obj/effect/list_container/mobl(null)
			L.container += src
			L.master = src

		var/grab_in_hands = find_held_item_by_type(/obj/item/weapon/grab)
		if(grab_in_hands)
			var/obj/item/weapon/grab/G = held_items[grab_in_hands]
			if (!( L.container.Find(G.affecting) ))
				L.container += G.affecting
				if (G.affecting)
					G.affecting.ret_grab(L, 1)
		if (!( flag ))
			if (L.master == src)
				var/list/temp = list()
				temp += L.container
				L.forceMove(null)
				return temp
			else
				return L.container
	return

//note: ghosts can point, this is intended
//visible_message will handle invisibility properly
//overriden here and in /mob/dead/observer for different point span classes and sanity checks
/mob/verb/pointed(atom/A as turf | obj | mob in tview(src))
	set name = "Point To"
	set category = "Object"

	if((usr.isUnconscious() && !isobserver(src)) || !(get_turf(src))|| attack_delayer.blocked())
		return 0

	delayNextAttack(SHOW_HELD_ITEM_AND_POINTING_DELAY)

	if(isitem(A) && is_holding_item(A))
		var/obj/item/I = A
		I.showoff(src)
		return 0

	if(!(A in (tview(src) + get_all_slots())))
		message_admins("<span class='warning'><B>WARNING: </B><A href='?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> just pointed at something ([A]) they can't currently see. Are they using a macro to cheat?</span>", 1)
		log_admin("[key_name_admin(src)] just pointed at something ([A]) they can't currently see. Are they using a macro to cheat?")
		return 0

	if(istype(A, /obj/effect/decal/point))
		return 0

	if(istype(A, /mob/living/simple_animal))
		var/mob/living/simple_animal/pointed_at_mob = A
		pointed_at_mob.pointed_at(src)

	var/tile = get_turf(A)

	if(!tile)
		return 0

	var/obj/effect/decal/point/point = new/obj/effect/decal/point(tile)
	point.invisibility = invisibility
	point.pointer = src
	point.target = A
	point.pixel_x = A.pixel_x
	point.pixel_y = A.pixel_y
	spawn(20)
		if(point)
			qdel(point)

	return 1

/mob/proc/has_hand_check()
	return held_items.len

//this and stop_pulling really ought to be /mob/living procs
/mob/proc/start_pulling(var/atom/movable/AM)
	if ( !AM || !src || !isturf(AM.loc) || !AM.can_be_pulled(src))	//if there's no person pulling OR the object being pulled is inside something: abort!
		return

	if(AM == src) //trying to pull yourself is a convenient shortcut for "stop pulling"
		stop_pulling()
		return

	if(!has_hand_check())
		to_chat(src,"<span class='notice'>You don't have any hands to pull with!</span>")
		return

	var/atom/movable/P = AM

	if(ismob(AM))
		var/mob/M = AM
		if(M.locked_to) //If the mob is locked_to on something, let's just try to pull the thing they're locked_to to for convenience's sake.
			P = M.locked_to

	if(!P.anchored)
		P.add_fingerprint(src)

		// If we're pulling something then drop what we're currently pulling and pull this instead.
		if(pulling)
			// Are we trying to pull something we are already pulling?
			// Then we want to either toggle pulling (stop pulling and quit), or keep pulling (just quit) if client preferences want otherwise.
			if(pulling == P)
				if(client && !client.prefs.pulltoggle)
					return
				else
					stop_pulling()
					return
			else
				stop_pulling()

		src.pulling = P
		P.pulledby = src
		AM.on_pull_start(src)
		update_pull_icon()
		if(ismob(P))
			var/mob/M = P
			if(!iscarbon(src))
				M.LAssailant = null
			else
				M.LAssailant = usr
				M.assaulted_by(usr, TRUE)

/mob/verb/stop_pulling()
	set name = "Stop Pulling"
	set category = "IC"

	if(pulling)
		pulling.pulledby = null
		pulling = null
		update_pull_icon()

//I don't want to update the whole HUD each time!
/mob/proc/update_pull_icon()
	if(pullin) //Yes, the pulling icon in HUDs is referenced by a mob-level variable called "pullin". It's awful I know
		if(pulling)
			pullin.icon_state = "pull1"
		else
			pullin.icon_state = "pull0"


/mob/verb/mode()
	set name = "Activate Held Object"
	set category = "IC"
	set src = usr

	if(attack_delayer.blocked())
		return

	if(istype(loc,/obj/mecha))
		return

	if(isVentCrawling())
		to_chat(src, "<span class='danger'>Not while we're vent crawling!</span>")
		return

	var/obj/item/W = get_held_item_by_index(active_hand)
	if(W)
		W.attack_self(src)
		update_inv_hand(active_hand)

/*
/mob/verb/dump_source()


	var/master = "<PRE>"
	for(var/t in typesof(/area))
		master += text("[]\n", t)
		//Foreach goto(26)
	src << browse(master)
	return
*/

/mob/verb/memory()
	set name = "Notes"
	set category = "IC"
	if(mind)
		mind.show_memory(src)
	else
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")

/mob/verb/add_memory(msg as message)
	set name = "Add Note"
	set category = "IC"

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)
	msg = sanitize(msg)
	message_admins("[usr.key]/([usr.name]) added the following message to their memory. [msg]")
	log_admin("[usr.key]/([usr.name]) added the following message to their memory. [msg]")
	if(mind)
		mind.store_memory(msg)
	else
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")

/mob/proc/store_memory(msg as message, popup, sane = 1)
	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	if (sane)
		msg = sanitize(msg)

	if (length(memory) == 0)
		memory += msg
	else
		memory += "<BR>[msg]"

	if (popup)
		memory()

//mob verbs are faster than object verbs. See http://www.byond.com/forum/?post=1326139&page=2#comment8198716 for why this isn't atom/verb/examine()
/mob/verb/examination(atom/A as mob|obj|turf in view(src)) //It used to be oview(12), but I can't really say why
	set name = "Examine"
	set category = "IC"

	if(is_blind(src))
		to_chat(src, "<span class='notice'>Something is there but you can't see it.</span>")
		return

	if (src in confusion_victims)
		to_chat(src, "<span class='sinister'>[pick("Oh god what's this even?","Paranoia and panic prevent you from calmly observing whatever this is.")]</span>")
		return

	if(get_dist(A,client.eye) > client.view)
		to_chat(src, "<span class='notice'>It is too far away to make out.</span>")
		return

	face_atom(A)
	A.examine(src)


/mob/living/verb/verb_pickup(obj/I in acquirable_objects_in_view(usr, 1))
	set name = "Pick up"
	set category = "Object"

	face_atom(I)
	I.verb_pickup(src)

/proc/acquirable_objects_in_view(var/mob/living/L, var/range)
	var/list/obj_list = list()
	for(var/turf/T in view(L, range))
		for(var/obj/I in T)
			if(I.can_pickup(L, FALSE, TRUE))
				obj_list.Add(I)
	return obj_list

// See carbon/human
/mob/proc/can_show_flavor_text()
	return FALSE

/mob/proc/print_flavor_text()
	if(!flavor_text)
		return
	if(!can_show_flavor_text())
		return
	var/msg = strip_html(flavor_text)
	if(findtext(msg, "http:") || findtext(msg, "https:") || findtext(msg, "www."))
		return "<font color='#ffa000'><b><a href='?src=\ref[src];show_flavor_text=1'>Show flavor text</a></b></font>"
	if(length(msg) <= 64)
		return "<font color='#ffa000'><b>[msg]</b></font>"
	else
		return "<font color='#ffa000'><b>[copytext(msg, 1, 64)]...<a href='?src=\ref[src];show_flavor_text=1'>More</a></b></font>"

/mob/verb/abandon_mob()
	set name = "Respawn"
	set category = "OOC"

	if (!( abandon_allowed ))
		to_chat(usr, "<span class='notice'> Respawn is disabled.</span>")
		return
	if ((stat != 2 || !( ticker )))
		to_chat(usr, "<span class='notice'> <B>You must be dead to use this!</B></span>")
		return
	if (ticker.mode.name == "meteor" || ticker.mode.name == "epidemic") //BS12 EDIT
		to_chat(usr, "<span class='notice'> Respawn is disabled.</span>")
		return
	else
		var/deathtime = world.time - src.timeofdeath
		if(istype(src,/mob/dead/observer))
			var/mob/dead/observer/G = src
			if(G.has_enabled_antagHUD == 1 && config.antag_hud_restricted)
				to_chat(usr, "<span class='notice'> <B>Upon using the antagHUD you forfeighted the ability to join the round.</B></span>")
				return
		var/deathtimeminutes = round(deathtime / 600)
		var/pluralcheck = "minute"
		if(deathtimeminutes == 0)
			pluralcheck = ""
		else if(deathtimeminutes == 1)
			pluralcheck = " [deathtimeminutes] minute and"
		else if(deathtimeminutes > 1)
			pluralcheck = " [deathtimeminutes] minutes and"
		var/deathtimeseconds = round((deathtime - deathtimeminutes * 600) / 10,1)
		to_chat(usr, "You have been dead for[pluralcheck] [deathtimeseconds] seconds.")
		if (deathtime < config.respawn_delay*600)
			to_chat(usr, "You must wait [config.respawn_delay] minutes to respawn!")
			return
		else
			to_chat(usr, "You can respawn now, enjoy your new life!")

	log_game("[usr.name]/[usr.key] used abandon mob.")

	to_chat(usr, "<span class='notice'> <B>Make sure to play a different character, and please roleplay correctly!</B></span>")

	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		return
	client.screen.len = 0
	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		return

	var/mob/new_player/M = new /mob/new_player()
	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		qdel(M)
		M = null
		return

	M.key = key
//	M.Login()	//wat
	return

/client/verb/issue_report()
	set name = "Github Report"
	set category = "OOC"
	var/dat = {"	<title>/vg/station Github Ingame Reporting</title>
					Revision: [return_revision()]
					<iframe src='http://ss13.moe/issues/?ckey=[ckey(key)]&address=[world.internet_address]:[world.port]&revision=[return_revision()]' style='border:none' width='480' height='480' scroll=no></iframe>"}
	src << browse(dat, "window=github;size=480x480")

/client/verb/changes()
	set name = "Changelog"
	set category = "OOC"
	getFiles(
		'html/postcardsmall.jpg',
		'html/somerights20.png',
		'html/88x31.png',
		'html/bug-minus.png',
		'html/cross-circle.png',
		'html/hard-hat-exclamation.png',
		'html/image-minus.png',
		'html/image-plus.png',
		'html/music-minus.png',
		'html/music-plus.png',
		'html/tick-circle.png',
		'html/wrench-screwdriver.png',
		'html/spell-check.png',
		'html/burn-exclamation.png',
		'html/chevron.png',
		'html/chevron-expand.png',
		'html/changelog.css',
		'html/changelog.js',
		'html/changelog.html'
		)
	src << browse('html/changelog.html', "window=changes;size=675x650")

	if(prefs.lastchangelog != changelog_hash)
		prefs.SetChangelog(ckey, changelog_hash)
		winset(src, "rpane.changelog", "background-color=none;font-style=;")

/mob/verb/observe()
	set name = "Observe"
	set category = "OOC"
	var/is_admin = 0

	if(client.holder && (client.holder.rights & R_ADMIN))
		is_admin = 1
	else if(stat != DEAD || istype(src, /mob/new_player))
		to_chat(usr, "<span class='notice'>You must be observing to use this!</span>")
		return

	if(is_admin && stat == DEAD)
		is_admin = 0

	var/list/names = list()
	var/list/namecounts = list()
	var/list/creatures = list()


	creatures["Nuclear Disk"] = nukedisk // There can be only one !

	for (var/obj/machinery/singularity/S in power_machines)
		var/name = "Singularity"
		if (names.Find(name))
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = S

	for (var/obj/machinery/bot/B in bots_list)
		var/name = "BOT: [B.name]"
		if (names.Find(name))
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = B


	for(var/mob/M in sortNames(mob_list))
		var/name = M.name
		if (names.Find(name))
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1

		creatures[name] = M


	client.perspective = EYE_PERSPECTIVE

	var/eye_name = null

	var/ok = "[is_admin ? "Admin Observe" : "Observe"]"
	eye_name = input("Please, select a player!", ok, null, null) as null|anything in creatures

	if (!eye_name)
		return

	var/mob/mob_eye = creatures[eye_name]

	if(client && mob_eye)
		client.eye = mob_eye
		if (is_admin)
			client.adminobs = 1
			if(mob_eye == client.mob || client.eye == client.mob)
				client.adminobs = 0

/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "IC"
	unset_machine()
	reset_view(null)
	if(istype(src, /mob/living))
		var/mob/living/M = src
		if(M.cameraFollow)
			M.cameraFollow = null
		if(istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			H.handle_regular_hud_updates()

// http://www.byond.com/forum/?post=2219001#comment22205313
// TODO: Clean up and identify the args, document
/mob/verb/DisableClick(argu = null as anything, sec = "" as text, number1 = 0 as num, number2 = 0 as num)
	set name = ".click"
	set category = null
	return

/mob/verb/DisableDblClick(argu = null as anything, sec = "" as text, number1 = 0 as num, number2 = 0 as num)
	set name = ".dblclick"
	set category = null
	return

/mob/Topic(href,href_list[])
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_machine()
		src << browse(null, t1)
	else if (href_list["lookitem"])
		var/obj/item/I = locate(href_list["lookitem"])
		usr.examination(I)
	else
		return ..()
	//if (href_list["joinresponseteam"])
	//	if(usr.client)
	//		var/client/C = usr.client
	//		C.JoinResponseTeam()

/mob/MouseDropFrom(mob/M as mob)
	if(M != usr)
		return ..()
	if(usr == src)
		return ..()
	if(!Adjacent(usr))
		return ..()
	if(istype(M,/mob/living/silicon/ai))
		return ..()
	show_inv(usr)


/mob/proc/can_use_hands()
	if(restrained())
		return FALSE
	return TRUE

/mob/proc/is_active()
	return (0 >= usr.stat)

/mob/proc/see(message)
	if(!is_active())
		return 0
	to_chat(src, message)
	return 1

/mob/proc/show_viewers(message)
	for(var/mob/M in viewers())
		M.see(message)

/mob/Stat()
	..()

	statpanel("Status") //Default tab
	if(client && client.holder && client.inactivity < 1200)
		if(statpanel("MC"))
			stat("Location:", "([x], [y], [z])")
			stat("CPU:", "[world.cpu]")
			stat("Instances:", "[world.contents.len]")
			stat("Map CPU:", "[world.map_cpu]")

			stat(null)
			if(Master)
				Master.stat_entry()
			else
				stat("Master Controller:", "ERROR")
			if(Failsafe)
				Failsafe.stat_entry()
			else
				stat("Failsafe Controller:", "ERROR")
			if(Master)
				stat(null)
				for(var/datum/subsystem/SS in Master.subsystems)
					SS.stat_entry()

	if(client && client.inactivity < (1200))
		if(listed_turf)
			if(get_dist(listed_turf,src) > 1)
				listed_turf = null
			else if(statpanel(listed_turf.name))
				statpanel(listed_turf.name, null, listed_turf)
				for(var/atom/A in listed_turf)
					if(!A.mouse_opacity && !A.name)
						continue
					if(A.invisibility > see_invisible)
						continue
					statpanel(listed_turf.name, null, A)

		if(spell_list && spell_list.len)
			for(var/spell/S in spell_list)
				if((!S.connected_button) || !statpanel(S.panel))
					continue //Not showing the noclothes spell
				var/charge_type = S.charge_type
				if(charge_type & Sp_HOLDVAR)
					statpanel(S.panel,"Required [S.holder_var_type]: [S.holder_var_amount]",S.connected_button)
				else if(charge_type & Sp_CHARGES)
					statpanel(S.panel,"[S.charge_max? "[S.charge_counter]/[S.charge_max] charges" : "Free"]",S.connected_button)
				else if(charge_type & Sp_RECHARGE || charge_type & Sp_GRADUAL)
					statpanel(S.panel,"[S.charge_max? "[S.charge_counter/10.0]/[S.charge_max/10] seconds" : "Free"]",S.connected_button)
	sleep(world.tick_lag * 2)


// facing verbs
/mob/proc/canface()
	if(!canmove)
		return 0
	if(client.moving)
		return 0
	if(client.move_delayer.blocked())
		return 0
	if(stat==2)
		return 0
	if(anchored)
		return 0
	if(monkeyizing)
		return 0
	if(restrained())
		return 0
	return 1

/mob/proc/isKnockedDown() //Check if the mob is knocked down
	return knockdown || paralysis

/mob/proc/isJustStunned() //Some ancient coder (as of 2021) made it so that it checks directly for whether the variable has a positive number, and I'm too afraid of unintended consequences down the line to just change it to isStunned(), so instead you have this half-baked abomination of a barely-used proc just so that player simple_animal mobs can move. You're welcome!
	return stunned

//Updates canmove, lying and icons. Could perhaps do with a rename but I can't think of anything to describe it.
/mob/proc/update_canmove()
	if (timestopped)
		return 0 // update_canmove() is called on all affected mobs right as the timestop ends

	if (locked_to)
		var/datum/locking_category/category = locked_to.get_lock_cat_for(src)
		if (category && ~category.flags & LOCKED_CAN_LIE_AND_STAND)
			canmove = 0
			lying = (category.flags & LOCKED_SHOULD_LIE) ? TRUE : FALSE //A lying value that !=1 will break this

	else if(resting || !can_stand || isKnockedDown() || isUnconscious())
		stop_pulling()
		lying = 1
		canmove = 0
	else if(isJustStunned())
//		lying = 0
		canmove = 0
	else if(captured)
		anchored = 1
		canmove = 0
		lying = 0
	else
		lying = 0
		canmove = has_limbs

	reset_layer() //Handles layer setting in hiding
	if (!forced_density)
		if(lying)
			setDensity(FALSE)
			drop_hands()
		else
			setDensity(original_density)

	//Temporarily moved here from the various life() procs
	//I'm fixing stuff incrementally so this will likely find a better home.
	//It just makes sense for now. ~Carn
	if( update_icon )	//forces a full overlay update
		update_icon = 0
		regenerate_icons()
	else if( lying != lying_prev )
		update_icons()

	return canmove

/mob/proc/reset_layer()
	return

/mob/proc/directionface(var/direction)
	if(loc && loc.relayface(src, direction))
		return 1
	if(locked_to && locked_to.relayface(src, direction))
		return 1
	if(!canface())
		return 0
	if (dir!=direction)
		INVOKE_EVENT(src, /event/before_move)
	dir = direction
	INVOKE_EVENT(src, /event/face)
	INVOKE_EVENT(src, /event/after_move)
	delayNextMove(movement_delay(),additive=1)
	return 1

/mob/verb/eastface()
	set hidden = 1
	return directionface(EAST)

/mob/verb/westface()
	set hidden = 1
	return directionface(WEST)

/mob/verb/northface()
	set hidden = 1
	return directionface(NORTH)

/mob/verb/southface()
	set hidden = 1
	return directionface(SOUTH)

/mob/proc/check_dark_vision()
	if (dark_plane && dark_plane.alphas.len)
		var/max_alpha = 0
		for (var/key in dark_plane.alphas)
			max_alpha = max(dark_plane.alphas[key], max_alpha)
		animate(dark_plane, alpha = max_alpha, color = dark_plane.colours, time = 10)
	else if (dark_plane)
		animate(dark_plane, alpha = initial(dark_plane.alpha), color = dark_plane.colours, time = 10)

	if (self_vision)
		if (isturf(loc))
			var/turf/T = loc
			if (T.get_lumcount() <= 0 && (dark_plane.alpha <= 15) && (master_plane.blend_mode == BLEND_MULTIPLY))
				animate(self_vision, alpha = self_vision.target_alpha, time = 10)
			else
				animate(self_vision, alpha = 0, time = 10)

//Like forceMove(), but for dirs! used in atoms_movable.dm, mainly with chairs and vehicles
/mob/change_dir(new_dir, var/changer)
	INVOKE_EVENT(src, /event/before_move)
	..()
	INVOKE_EVENT(src, /event/after_move)

/mob/proc/isGoodPickpocket() //If the mob gets bonuses when pickpocketing and such. Currently only used for humans with the Pickpocket's Gloves.
	return 0

/mob/proc/Stun(amount)
	if(status_flags & CANSTUN)
		stunned = max(max(stunned,amount),0) //can't go below 0, getting a low amount of stun doesn't lower your current stun
		update_canmove()
	return

/mob/proc/SetStunned(amount) //if you REALLY need to set stun to a set amount without the whole "can't go below current stunned"
	if(status_flags & CANSTUN)
		stunned = max(amount,0)
		update_canmove()
	return

/mob/proc/AdjustStunned(amount)
	if(status_flags & CANSTUN)
		stunned = max(stunned + amount,0)
		update_canmove()
	return

/mob/proc/Deafen(amount)
	ear_deaf = max(max(ear_deaf,amount),0)

/mob/proc/Mute(amount)
	say_mute = max(max(say_mute,amount),0)

/mob/proc/AdjustMute(amount)
	say_mute = max(say_mute + amount,0)

/mob/proc/Knockdown(amount)
	if(status_flags & CANKNOCKDOWN)
		knockdown = max(max(knockdown,amount),0)
		update_canmove()	//updates lying, canmove and icons
	return

/mob/proc/SetKnockdown(amount)
	if(status_flags & CANKNOCKDOWN)
		knockdown = max(amount,0)
		update_canmove()	//updates lying, canmove and icons
	return

/mob/proc/AdjustKnockdown(amount)
	if(status_flags & CANKNOCKDOWN)
		knockdown = max(knockdown + amount,0)
		update_canmove()	//updates lying, canmove and icons
	return

/mob/proc/Jitter(amount)
	jitteriness = max(jitteriness,amount,0)

/mob/proc/Dizzy(amount)
	dizziness = max(dizziness,amount,0)

/mob/proc/AdjustDizzy(amount)
	dizziness = max(dizziness+amount, 0)

/mob/proc/Paralyse(amount)
	if(status_flags & CANPARALYSE)
		paralysis = max(max(paralysis,amount),0)
		update_canmove()
	return

/mob/proc/SetParalysis(amount)
	if(status_flags & CANPARALYSE)
		paralysis = max(amount,0)
		update_canmove()
	return

/mob/proc/AdjustParalysis(amount)
	if(status_flags & CANPARALYSE)
		paralysis = max(paralysis + amount,0)
		update_canmove()
	return

/mob/proc/Sleeping(amount)
	sleeping = max(max(sleeping,amount),0)
	return

/mob/proc/SetSleeping(amount)
	sleeping = max(amount,0)
	return

/mob/proc/AdjustSleeping(amount)
	sleeping = max(sleeping + amount,0)
	return

/mob/proc/Resting(amount)
	resting = max(max(resting,amount),0)
	return

/mob/proc/SetResting(amount)
	resting = max(amount,0)
	return

/mob/proc/AdjustResting(amount)
	resting = max(resting + amount,0)
	return

/mob/proc/get_species()
	return ""

/mob/proc/flash_weak_pain()
	flick("weak_pain",pain)

/mob/proc/yank_out_object()
	set category = "Object"
	set name = "Yank out object"
	set desc = "Remove an embedded item at the cost of bleeding and pain."
	set src in view(1)

	if(!isliving(usr) || (usr.client && usr.client.move_delayer.blocked()))
		return

	delayNextMove(20)
	delayNextAttack(20)

	if(usr.stat == 1)
		to_chat(usr, "You are unconcious and cannot do that!")
		return

	if(usr.restrained())
		to_chat(usr, "You are restrained and cannot do that!")
		return

	var/mob/S = src
	var/mob/U = usr
	var/list/valid_objects = list()
	var/self = null

	if(S == U)
		self = 1 // Removing object from yourself.

	for(var/obj/item/weapon/W in embedded)
		if(W.w_class <= W_CLASS_SMALL)
			valid_objects += W

	if(!valid_objects.len)
		if(self)
			to_chat(src, "You have nothing stuck in your body that is large enough to remove.")
		else
			to_chat(U, "[src] has nothing stuck in their wounds that is large enough to remove.")
		return

	var/obj/item/weapon/selection = input("What do you want to yank out?", "Embedded objects") in valid_objects

	if(self)
		to_chat(src, "<span class='warning'>You attempt to get a good grip on the [selection] in your body.</span></span>")
	else
		to_chat(U, "<span class='warning'>You attempt to get a good grip on the [selection] in [S]'s body.</span>")

	if(!do_after(U, src, 80))
		return
	if(!selection || !S || !U)
		return

	if(self)
		visible_message("<span class='danger'><b>[src] rips [selection] out of their body.</b></span>","<span class='warning'>You rip [selection] out of your body.</span>")
	else
		visible_message("<span class='danger'><b>[usr] rips [selection] out of [src]'s body.</b></span>","<span class='warning'>[usr] rips [selection] out of your body.</span>")

	selection.forceMove(get_turf(src))

	for(var/obj/item/weapon/O in pinned)
		if(O == selection)
			pinned -= O
		if(!pinned.len)
			anchored = 0
	return 1

// Mobs tell access what access levels it has.
/mob/proc/GetAccess()
	return list()

/mob/proc/get_visible_id()
	return 0

// Skip over all the complex list checks.
/mob/proc/hasFullAccess()
	return 0

/mob/proc/assess_threat()
	return 0

/mob/proc/on_foot()
	return !(lying || flying || locked_to)

/mob/proc/dexterity_check()//can the mob use computers, guns, and other fine technologies
	return FALSE

/mob/proc/isTeleViewing(var/client_eye)
	if(istype(client_eye,/obj/machinery/camera))
		return 1
	if(istype(client_eye,/obj/item/projectile/rocket/nikita))
		return 1
	return 0

/mob/proc/html_mob_check()
	return 0

/mob/shuttle_act()
	return

/mob/shuttle_rotate(angle)
	src.dir = turn(src.dir, -angle) //rotating pixel_x and pixel_y is bad

/mob/can_shuttle_move()
	return 1

/mob/proc/is_blind()
	if((sdisabilities & BLIND) || (sight & BLIND) || blinded || paralysis)
		return 1
	return 0

/mob/proc/is_mute()
	if(sdisabilities & MUTE || say_mute)
		return 1
	return 0

/mob/proc/is_deaf()
	if(sdisabilities & DEAF || ear_deaf)
		return 1
	return 0

/mob/proc/hallucinating() //Return 1 if hallucinating! This doesn't affect the scary stuff from mindbreaker toxin, but it does affect other stuff (like special messages for interacting with objects)
	if(isliving(src))
		var/mob/living/M = src
		if(M.hallucination >= MOB_MINDBREAKER_HALLUCINATING)
			return 1
		if(M.druggy >= MOB_SPACEDRUGS_HALLUCINATING)
			return 1
	return 0

/mob/proc/get_subtle_message(var/msg, var/deity = null)
	if(!deity)
		deity = "a voice" //sanity
	var/pre_msg = "You hear [deity] in your head... "
	if(src.hallucinating()) //If hallucinating, make subtle messages more fun
		var/adjective = pick("an angry","a funny","a squeaky","a disappointed","your mother's","your father's","[ticker.Bible_deity_name]'s","an annoyed","a brittle","a loud","a very loud","a quiet","an evil", "an angelic")
		var/location = pick(" from above"," from below"," in your head"," from behind you"," from everywhere"," from nowhere in particular","")
		pre_msg = pick("You hear [adjective] voice[location]...")

	to_chat(src, "<b>[pre_msg] <em>[msg]</em></b>")

/mob/attack_pai(mob/user as mob)
	ShiftClick(user)

/mob/proc/handle_alpha()
	if(alphas.len < 1)
		alpha = 255
	else
		var/lowest_alpha = 255
		for(var/alpha_modification in alphas)
			lowest_alpha = min(lowest_alpha,alphas[alpha_modification])
		alpha = lowest_alpha

/mob/proc/teleport_to(var/atom/A)
	forceMove(get_turf(A))

/mob/proc/nuke_act() //Called when caught in a nuclear blast
	return

/mob/supermatter_act(atom/source, severity)
	var/contents = get_contents_in_object(src)

	var/obj/item/supermatter_shielding/SS = locate(/obj/item/supermatter_shielding) in contents
	if(SS)
		SS.supermatter_act(source)
	else

		if(severity == SUPERMATTER_DUST)
			dust()
			return 1
		else
			qdel(src)
			return 1

/mob/proc/remove_jitter()
	if(jitteriness)
		jitteriness = 0
		animate(src)

//High order proc to remove a mobs spell channeling, removes channeling fully
/mob/proc/remove_spell_channeling()
	if(spell_channeling)
		spell_channeling.channel_spell(force_remove = 1)
		return 1
	return 0

/mob/proc/heard(var/mob/living/M)
	return

/mob/proc/AdjustPlasma()
	return

/mob/living/carbon/heard(var/mob/living/carbon/human/M)
	if(M == src || !istype(M) || !mind)
		return
	if(!ear_deaf && !stat)
		if(!(mind.heard_before[M.name]) && M.mind)
			mind.heard_before[M.name] = M.mind
			M.heard_by |= mind

/mob/acidable()
	return 1

/mob/proc/get_view_range()
	if(client)
		return client.view
	return world.view

/mob/proc/apply_vision_overrides()
	if(see_in_dark_override)
		see_in_dark = see_in_dark_override
	if(see_invisible_override)
		see_invisible = see_invisible_override

/mob/proc/update_perception()
	return

/mob/actual_send_to_future(var/duration)
	var/init_blinded = blinded
	var/init_eye_blind = eye_blind
	var/init_deaf = ear_deaf
	overlay_fullscreen("blind", /obj/abstract/screen/fullscreen/blind)
	blinded = 1
	eye_blind = 1
	ear_deaf = 1

	..()

	blinded = init_blinded
	eye_blind = init_eye_blind
	ear_deaf = init_deaf
	clear_fullscreen("blind")

/mob/send_to_past(var/duration)
	..()
	var/static/list/resettable_vars = list(
		"lastattacker",
		"lastattacked",
		"attack_log",
		"memory",
		"sdisabilities",
		"disabilities",
		"eye_blind",
		"eye_blurry",
		"ear_deaf",
		"ear_damage",
		"stuttering",
		"slurring",
		"real_name",
		"blinded",
		"bhunger",
		"druggy",
		"confused",
		"sleeping",
		"resting",
		"lying",
		"lying_prev",
		"canmove",
		"candrop",
		"cpr_time",
		"bodytemperature",
		"drowsyness",
		"dizziness",
		"jitteriness",
		"nutrition",
		"overeatduration",
		"paralysis",
		"stunned",
		"knockdown",
		"losebreath",
		"nobreath",
		"held_items",
		"back",
		"internal",
		"s_active",
		"wear_mask",
		"radiation",
		"stat",
		"monkeyizing",
		"key")

	reset_vars_after_duration(resettable_vars, duration)

	spawn(duration - 1)
		for(var/atom/movable/AM in contents)
			drop_item(AM, force_drop = 1)

	spawn(duration + 1)
		regenerate_icons()

/mob/proc/transmogrify(var/target_type, var/offer_revert_spell = FALSE)	//transforms the mob into a new member of the given mob type, while preserving the mob's body
	if(!target_type)
		if(transmogged_from)
			var/obj/transmog_body_container/tC = transmogged_from
			if(tC.contained_mob)
				tC.contained_mob.forceMove(loc)
				if(key)
					tC.contained_mob.key = key
				tC.contained_mob.timestopped = 0
				if(istype(tC.contained_mob, /mob/living/carbon))
					var/mob/living/carbon/C = tC.contained_mob
					if(istype(C.get_item_by_slot(slot_wear_mask), /obj/item/clothing/mask/morphing))
						C.drop_item(C.wear_mask, force_drop = 1)
				var/mob/returned_mob = tC.contained_mob
				returned_mob.transmogged_to = null
				tC.get_rid_of()
				transmogged_from = null
				for(var/atom/movable/AM in contents)
					AM.forceMove(get_turf(src))
				forceMove(null)
				qdel(src)
				return returned_mob
		return
	if(!ispath(target_type, /mob))
		EXCEPTION(target_type)
		return
	var/mob/M = new target_type(loc)
	var/obj/transmog_body_container/C = new (M)
	M.transmogged_from = C
	transmogged_to = M
	if(key)
		M.key = key
	if(offer_revert_spell)
		var/spell/change_back
		if(ispath(offer_revert_spell)) //I don't like this but I'm not rewriting the whole system for a hotfix
			change_back = new offer_revert_spell
		else
			change_back = new /spell/aoe_turf/revert_form
		M.add_spell(change_back)
	C.set_contained_mob(src)
	timestopped = 1
	return M

/mob/proc/completely_untransmogrify()	//Reverts a mob through all layers of transmogrification, back down to the base mob. Returns this mob.
	var/mob/top_level = get_top_transmogrification()
	while(top_level)
		top_level = top_level.transmogrify()
		if(top_level)
			. = top_level

/mob/proc/get_top_transmogrification()	//Returns the mob at the highest level of transmogrification, the one which contains the player.
	var/mob/M = src
	while(M.transmogged_to)
		M = M.transmogged_to
	return M

/mob/proc/get_bottom_transmogrification()	//Returns the mob at the lowest level of transmogrification, the original mob.
	var/mob/M = src
	while(M.transmogged_from)
		M = M.transmogged_from.contained_mob
	return M

/spell/aoe_turf/revert_form
	name = "Revert Form"
	desc = "Morph back into your previous form."
	spell_flags = GHOSTCAST
	abbreviation = "RF"
	charge_max = 1
	invocation = "none"
	invocation_type = SpI_NONE
	range = 0
	hud_state = "wiz_mindswap"

/spell/aoe_turf/revert_form/cast(var/list/targets, mob/user)
	user.transmogrify()
	user.remove_spell(src)

/spell/aoe_turf/revert_form/no_z2 //Used if you don't want it reverting on Z2. So far only important for ghosts.
	spell_flags = GHOSTCAST | Z2NOCAST

/obj/transmog_body_container
	name = "transmog body container"
	desc = "You should not be seeing this."
	flags = TIMELESS
	var/mob/contained_mob

/obj/transmog_body_container/proc/set_contained_mob(var/mob/M)
	ASSERT(M)
	M.unlock_from()
	M.forceMove(src)
	contained_mob = M

/obj/transmog_body_container/proc/get_rid_of()
	for(var/atom/movable/AM in contents)
		AM.forceMove(get_turf(src))
	contained_mob = null
	qdel(src)

/obj/transmog_body_container/Destroy()
	contained_mob = null
	for(var/i in contents)
		qdel(i)
	..()

/mob/attack_icon()
	return image(icon = 'icons/mob/attackanims.dmi', icon_state = "default")

/mob/make_invisible(var/source_define, var/time, var/include_clothing)
	if(..() || !source_define)
		return
	alpha = 1	//to cloak immediately instead of on the next Life() tick
	alphas[source_define] = 1
	if(time > 0)
		spawn(time)
			if(src)
				alpha = initial(alpha)
				alphas.Remove(source_define)

/mob/proc/is_pacified(var/message = VIOLENCE_SILENT,var/target,var/weapon)
	if (runescape_pvp)
		var/area/A = get_area(src)
		if (!istype(A, /area/maintenance) && !is_type_in_list(A,non_standard_maint_areas))
			to_chat(src, "<span class='danger'>You must enter maintenance to attack other players!</span>")
			return TRUE

	if(status_flags & UNPACIFIABLE)
		return FALSE

	var/area/A = get_area(src)
	if(A && A.flags & NO_PACIFICATION)
		return FALSE

	if (reagents && (reagents.has_reagent(CHILLWAX) || (reagents.has_reagent(INCENSE_POPPIES) && prob(50))))
		switch (message)
			if (VIOLENCE_DEFAULT)//unarmed, melee weapon, spell
				to_chat(src, "<span class='notice'>[pick("Like...violence...what is it even good for?","Nah, you don't feel like doing that.","What did \the [target] even do to you? Chill out.")]</span>")
			if (VIOLENCE_GUN)//gun, projectile weapon
				to_chat(src, "<span class='notice'>[pick("Hey that's dangerous...wouldn't want hurting people.","You don't feel like firing \the [weapon] at \the [target].","Peace, my [gender == FEMALE ? "girl" : "man"]...")]</span>")
		return TRUE

	for (var/obj/item/weapon/implant/peace/target_implant in src.contents)
		if (!target_implant.malfunction && target_implant.imp_alive && target_implant.imp_in == src)
			if (message != VIOLENCE_SILENT)
				to_chat(src, "<span class='warning'>\The [target_implant] inside you prevents this!</span>")
			return TRUE

	for(var/mob/living/simple_animal/P in view(src))
		if(P.isDead() || !P.pacify_aura)
			continue
		to_chat(src, "<span class = 'notice'>You feel some strange force in the vicinity preventing you from being violent.</span>")
		return TRUE

	return FALSE

/mob/proc/handle_regular_hud_updates()
	if(client)
		return TRUE

/mob/proc/update_antag_huds()
	if (mind)
		for (var/role in mind.antag_roles)
			var/datum/role/R = mind.antag_roles[role]
			R.update_antag_hud()

/mob/proc/CheckSlip(slip_on_walking = FALSE, overlay_type = TURF_WET_WATER, slip_on_magbooties = FALSE)
	return FALSE

// Returns TRUE on success
/mob/proc/attempt_crawling(var/turf/target)
	return FALSE

/mob/proc/can_mind_interact(var/datum/mind/target_mind)
	var/mob/living/target
	if(isliving(target_mind))
		target = target_mind
	else
		if(!istype(target_mind))
			return null
		target = target_mind.current
	if (!istype(target))
		return null
	var/turf/target_turf = get_turf(target)
	var/turf/our_turf = get_turf(src)
	if(!target_turf)
		return null
	if (target.isDead())
		to_chat(src, "You cannot sense the target mind anymore, that's not good...")
		return null
	if(target_turf.z != our_turf.z) //Not on the same zlevel as us
		to_chat(src, "The target mind is too faint, they must be quite far from you...")
		return null
	if(target.stat != CONSCIOUS)
		to_chat(src, "The target mind is too faint, but still close, they must be unconscious...")
		return null
	if(M_PSY_RESIST in target.mutations)
		to_chat(src, "The target mind is resisting!")
		return null
	if(target.is_wearing_any(list(/obj/item/clothing/head/helmet/space/martian,/obj/item/clothing/head/tinfoil,/obj/item/clothing/head/helmet/stun), slot_head))
		to_chat(src, "Interference is disrupting the connection with the target mind.")
		return null
	return target

/mob/proc/canMouseDrag()//used mostly to check if the mob can drag'and'drop stuff in/out of various other stuff, such as disposals, cryo tubes, etc.
	return TRUE

/mob/proc/turn_into_mannequin(var/material = "marble", var/forever = FALSE)
	return FALSE

/mob/proc/get_personal_ambience()
	return list()

/mob/proc/isBloodedAnimal()
	return FALSE

#undef MOB_SPACEDRUGS_HALLUCINATING
#undef MOB_MINDBREAKER_HALLUCINATING
