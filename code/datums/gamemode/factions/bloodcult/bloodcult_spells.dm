
/spell/cult
	panel = "Cult"
	override_base = "cult"
	user_type = USER_TYPE_CULT


// Not sure what to do with this spell really, it always kinda sucked and tomes as a whole need an overhaul. Runic Skin is a better power.
var/list/arcane_pockets = list()

/spell/cult/arcane_dimension
	name = "Arcane Dimension (empty)"
	desc = "Cast while holding an Arcane Tome to discretly store it through the veil."
	hud_state = "cult_pocket_empty"

	invocation_type = SpI_NONE
	charge_type = Sp_RECHARGE
	charge_max = 0
	range = 0
	spell_flags = null
	insufficient_holder_msg = ""
	still_recharging_msg = ""

	cast_delay = 0

	var/obj/item/weapon/tome/stored_tome = null

/spell/cult/arcane_dimension/New()
	..()
	arcane_pockets.Add(src)

/spell/cult/arcane_dimension/Destroy()
	arcane_pockets.Remove(src)
	..()

/spell/cult/arcane_dimension/choose_targets(var/mob/user = usr)
	return list(user)

/spell/cult/arcane_dimension/cast(var/list/targets, var/mob/living/carbon/user)
	..()
	if (user.occult_muted())
		to_chat(user, "<span class='warning'>You can't seem to remember how to access your arcane dimension right now.</span>")
		return 0
	if (stored_tome)
		stored_tome.forceMove(get_turf(user))
		if (user.get_inactive_hand() && user.get_active_hand())//full hands
			to_chat(user,"<span class='warning'>Your hands being full, your [stored_tome] had nowhere to fall but on the ground.</span>")
		else
			to_chat(user,"<span class='notice'>You hold your hand palm up, and your [stored_tome] drops in it from thin air.</span>")
			user.put_in_hands(stored_tome)
		stored_tome = null
		name = "Arcane Dimension (empty)"
		connected_button.name = name
		desc = "Cast while holding an Arcane Tome to discretly store it through the veil."
		hud_state = "cult_pocket_empty"
		connected_button.overlays.len = 0
		connected_button.MouseExited()
		return

	var/obj/item/weapon/tome/held_tome = locate() in user.held_items
	if (held_tome)
		if (held_tome.state == TOME_OPEN)
			held_tome.icon_state = "tome"
			held_tome.item_state = "tome"
			held_tome.state = TOME_CLOSED
		stored_tome = held_tome
		user.u_equip(held_tome)
		held_tome.loc = null
		to_chat(user,"<span class='notice'>With a swift movement of your arm, you drop \the [held_tome] that disappears into thin air before touching the ground.</span>")
		name = "Arcane Dimension (full)"
		connected_button.name = name
		desc = "Cast to pick up your Arcane Tome back from the veil. You should preferably have a free hand."
		hud_state = "cult_pocket_full"
		connected_button.overlays.len = 0
		connected_button.MouseExited()


///////////////////////////////ASTRAL PROJECTION SPELLS/////////////////////////////////////


/spell/astral_return
	name = "Re-enter Body"
	desc = "End your astral projection and re-awaken inside your body. If used while tangible you might spook on-lookers, so be mindful."
	user_type = USER_TYPE_CULT
	hud_state = "astral_return"
	override_base = "cult"
	charge_max = 0
	spell_flags = 0
	range = 0

/spell/astral_return/choose_targets(var/mob/user = usr)
	return list(user)

/spell/astral_return/cast(var/list/targets, var/mob/user)
	var/mob/living/simple_animal/astral_projection/astral = user
	if (istype(astral))
		astral.death()//pretty straightforward isn't it?

/spell/astral_toggle
	name = "Toggle Tangibility"
	desc = "Turn into a visible copy of your body, able to speak and bump into doors. But note that the slightest source of damage will dispel your astral projection altogether."
	user_type = USER_TYPE_CULT
	charge_max = 50//relatively short, but still there to prevent too much spamming in/out of tangibility
	hud_state = "astral_toggle"
	override_base = "cult"
	spell_flags = 0
	range = 0

/spell/astral_toggle/choose_targets(var/mob/user = usr)
	return list(user)

/spell/astral_toggle/cast(var/list/targets, var/mob/user)
	var/mob/living/simple_animal/astral_projection/astral = user
	astral.toggle_tangibility()
	if (astral.tangibility)
		desc = "Turn back into an invisible projection of your soul."
	else
		desc = "Turn into a visible copy of your body, able to speak and bump into doors. But note that the slightest source of damage will dispel your astral projection altogether."
