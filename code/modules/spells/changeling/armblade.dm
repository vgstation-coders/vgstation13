/spell/changeling/armblade
	name = "Arm Blade (20)"
	desc = "We transform one of our arms into an organic blade that can cut through flesh and bone."
	abbreviation = "AB"
	hud_state = "armblade"

	spell_flags = NEEDSHUMAN

	chemcost = 20
	required_dna = 1

/spell/changeling/armblade/cast(var/list/targets, var/mob/living/carbon/human/user)

	for(var/obj/item/weapon/armblade/W in user)
		user.visible_message("<span class='danger'>With a sickening crunch, [user] reforms their arm blade into an arm!</span>",
		"<span class='notice'>We assimilate the weapon back into our body.</span>",
		"<span class='italics'>You hear organic matter ripping and tearing!</span>")
		playsound(user, 'sound/weapons/bloodyslice.ogg', 30, 1)
		qdel(W)
		return 

	var/good_hand
	if(user.can_use_hand(user.active_hand))
		good_hand = user.active_hand
	else
		for(var/i = 1 to user.held_items.len)
			if(user.can_use_hand(i))
				good_hand = i
				break
	if(good_hand)
		user.drop_item(user.held_items[good_hand], force_drop = 1)
		var/obj/item/weapon/armblade/A = new (user)
		user.put_in_hand(good_hand, A)
		user.visible_message("<span class='danger'>A grotesque blade forms around [user.name]\'s arm!</span>",
			"<span class='warning'>Our arm twists and mutates, transforming it into a deadly blade.</span>",
			"<span class='italics'>You hear organic matter ripping and tearing!</span>")
		playsound(user, 'sound/weapons/bloodyslice.ogg', 30, 1)

		feedback_add_details("changeling_powers","AB")

	..()

