/obj/item/weapon/gun/hookshot/flesh //only intended to be used by borers
	name = "fleshshot"
	desc = "It looks like a hookshot made of muscle and skin."
	slot_flags = null
	mech_flags = MECH_SCAN_ILLEGAL
	w_class = 5
	fire_sound = 'sound/effects/flesh_squelch.ogg'
	empty_sound = null
	silenced = 1
	fire_volume = 250
	maxlength = 10
	clumsy_check = 0
	advanced_tool_user_check = 0
	nymph_check = 0
	hulk_check = 0
	golem_check = 0
	fire_delay = 4
	delay_user = 0
	var/mob/living/simple_animal/borer/parent_borer = null
	var/image/item_overlay = null
	var/obj/item/to_be_dropped = null //to allow items to be dropped at range

	var/end_of_chain

/obj/item/weapon/gun/hookshot/flesh/New(atom/A, var/p_borer = null)
	..(A)
	if(istype(p_borer, /mob/living/simple_animal/borer))
		parent_borer = p_borer
	if(!parent_borer)
		qdel(src)

/obj/item/weapon/gun/hookshot/flesh/dropped()
	..()
	qdel(src)

/obj/item/weapon/gun/hookshot/flesh/Destroy()//if a single link of the chain is destroyed, the rest of the chain is instantly destroyed as well.
	if(parent_borer)
		if(parent_borer.extend_o_arm == src)
			parent_borer.extend_o_arm = null
	..()

/obj/item/weapon/gun/hookshot/flesh/process_chambered()
	if(in_chamber)
		return 1

	if(panic)//if a part of the chain got deleted, we recreate it.
		for(var/i = 0;i <= maxlength; i++)
			var/obj/effect/overlay/hookchain/flesh/HC = links["[i]"]
			if(!HC)
				HC = new(src)
				HC.shot_from = src
				links["[i]"] = HC
			else
				HC.forceMove(src)
		panic = 0

	if(!hook && !rewinding && !clockwerk && !check_tether())//if there is no projectile already, and we aren't currently rewinding the chain, or reeling in toward a target,
		hook = new/obj/item/projectile/hookshot/flesh(src, parent_borer)		//and that the hookshot isn't currently sustaining a tether, then we can fire.
		in_chamber = hook
		firer = loc
		update_icon()
		return 1
	return 0

/obj/item/weapon/gun/hookshot/flesh/display_reel_message()
	if(parent_borer)
		if(parent_borer.host)
			var/mob/living/carbon/C = chain_datum.extremity_B
			var/mob/living/carbon/human/borer_owner = parent_borer.host
			var/datum/organ/external/hostlimb = borer_owner.get_organ(parent_borer.hostlimb)
			to_chat(C, "<span class='warning'>\The [parent_borer.host]'s [hostlimb.display_name] reels you in!</span>")

/obj/item/weapon/gun/hookshot/flesh/rewind_chain()//brings the links back toward the player
	..()
	item_overlay = null
	update_icon()

/obj/item/weapon/gun/hookshot/flesh/rewind_loop()
	end_of_chain = 1
	..()

/obj/item/weapon/gun/hookshot/flesh/reset_hookchain_overlays(var/obj/effect/overlay/hookchain/HC)
	if(HC.overlays.len)
		HC.overlays.len = 0

/obj/item/weapon/gun/hookshot/flesh/set_end_of_chain(var/i)
	if(i > end_of_chain)
		end_of_chain = i

/obj/item/weapon/gun/hookshot/flesh/apply_item_overlay()	//The item overlay fails to appear when retracting only when fired at specific angles and I don't know why.
	var/obj/effect/overlay/hookchain/chain_end = links["[end_of_chain]"]
	if(chain_end && chain_end.loc != src)
		chain_end.overlays += item_overlay
		if(to_be_dropped)
			if(parent_borer && parent_borer.host && istype(parent_borer.host, /mob/living/carbon/human))
				var/mob/living/carbon/human/HT = parent_borer.host
				if(to_be_dropped.loc != HT)
					to_be_dropped.forceMove(get_turf(chain_end))
					to_be_dropped = null

//this datum contains all the data about a tether. It's extremities, which hookshot spawned it, and the list of all of its links.
/datum/chain/flesh
	name = "length of flesh"
	var/mob/living/simple_animal/borer/parent_borer = null

/datum/chain/flesh/New()
	spawn()
		while(!parent_borer)
			if(istype(hookshot, /obj/item/weapon/gun/hookshot/flesh))
				var/obj/item/weapon/gun/hookshot/flesh/F = hookshot
				parent_borer = F.parent_borer
			sleep(1)
	..()

/datum/chain/flesh/process()
	if(!parent_borer)
		if(istype(hookshot, /obj/item/weapon/gun/hookshot/flesh))
			var/obj/item/weapon/gun/hookshot/flesh/F = hookshot
			parent_borer = F.parent_borer
	..()

/datum/chain/flesh/pick_up_item(var/mob/living/M, var/obj/item/I)
	. = 1
	if(parent_borer && ishuman(parent_borer.host))
		if(M == parent_borer.host)
			var/mob/living/carbon/human/H = M
			var/datum/organ/external/OE = H.get_organ(parent_borer.hostlimb)

			//Check if the arm that the borer is occupying is holding anything
			//If it's empty, put the item into the hand
			//Otherwise make the owner pull the item
			if(OE.grasp_id)
				if(!H.get_held_item_by_index(OE.grasp_id))
					H.put_in_hand(OE.grasp_id, I)
				else
					I.CtrlClick(H)

//THE CHAIN THAT APPEARS WHEN YOU FIRE THE HOOKSHOT
/obj/effect/overlay/hookchain/flesh
	name = "length of flesh"
	icon_state = "fleshshot_chain"

//THE CHAIN THAT TETHERS STUFF TOGETHER
/obj/effect/overlay/chain/flesh
	name = "length of flesh"
	overlay_name = "fleshshot_chain"

///////////////PROJECTILE///////////////////

/obj/item/projectile/hookshot/flesh
	name = "claw"
	icon_state = ""//"flesh_hookshot"
	kill_count = 11
	var/mob/living/simple_animal/borer/parent_borer = null
	var/image/item_overlay = null
	failure_message = "With a tearing noise, the length of flesh mysteriously snaps and retracts back into its arm."
	icon_name = "fleshshot"
	chain_datum_path = /datum/chain/flesh
	chain_overlay_path = /obj/effect/overlay/chain/flesh

/obj/item/projectile/hookshot/flesh/New(atom/A = null, var/p_borer = null)
	..(A)
	if(istype(p_borer, /mob/living/simple_animal/borer))
		parent_borer = p_borer
	update_icon()

/obj/item/projectile/hookshot/flesh/OnFired()
	..()
	update_icon()

/obj/item/projectile/hookshot/flesh/update_icon()
	overlays.len = 0
	var/obj/item/I = null

	if(!parent_borer)
		return
	if(ishuman(parent_borer.host))
		var/mob/living/carbon/human/L = parent_borer.host
		var/datum/organ/external/OE = L.get_organ(parent_borer.hostlimb)

		if(OE.grasp_id)
			I = L.get_held_item_by_index(OE.grasp_id)

	if(I)
		item_overlay = image('icons/obj/projectiles_experimental.dmi', src, "nothing")
		item_overlay.appearance = I.appearance
		item_overlay.layer = src.layer

		overlays += item_overlay
		if(shot_from)
			var/obj/item/weapon/gun/hookshot/flesh/hookshot = shot_from
			hookshot.item_overlay = item_overlay

/obj/item/projectile/hookshot/flesh/drop_item()
	var/obj/item/weapon/gun/hookshot/flesh/hookshot = shot_from
	if(!hookshot.item_overlay)
		item_overlay = null
		update_icon()
	else if(item_overlay != hookshot.item_overlay)
		item_overlay = hookshot.item_overlay

	if(hookshot.to_be_dropped)
		var/obj/item/dropping = hookshot.to_be_dropped
		if(parent_borer && parent_borer.host && istype(parent_borer.host, /mob/living/carbon/human))
			var/mob/living/carbon/human/HT = parent_borer.host
			if(dropping.loc != HT)
				dropping.forceMove(get_turf(src))
				hookshot.to_be_dropped = null

/obj/item/projectile/hookshot/flesh/held_item_check(var/atom/A)
	if(parent_borer && ishuman(parent_borer.host))
		var/mob/living/carbon/human/L = parent_borer.host
		var/datum/organ/external/OE = L.get_organ(parent_borer.hostlimb)

		if(OE.grasp_id) //If borer is in an arm
			var/obj/item/held = L.get_held_item_by_index(OE.grasp_id)
			if(held)
				if(!parent_borer.check_attack_cooldown())
					A.attackby(held, L, 1, parent_borer)
					if(!parent_borer)	//There's already a check for this above, but for some reason when it hits an airlock it gets qdel()'d before it gets to this point.
						bullet_die()
						return 1

					parent_borer.set_attack_cooldown()
				bullet_die()
				return 1
