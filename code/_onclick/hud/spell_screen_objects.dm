/obj/abstract/screen/movable/spell_master
	name = "Spells"
	icon = 'icons/mob/screen_spells.dmi'
	var/icon/override_icon
	icon_state = "wiz_spell_ready"
	var/list/obj/abstract/screen/spell/spell_objects = list()
	var/showing = 0
	globalscreen = 1
	var/open_state = "master_open"
	var/closed_state = "master_closed"

	screen_loc = ui_spell_master

	var/mob/spell_holder
	var/length = 9

/obj/abstract/screen/movable/spell_master/Destroy()
	..()
	for(var/obj/abstract/screen/spell/spells in spell_objects)
		spells.spellmaster = null
	spell_objects = null
	if(spell_holder)
		spell_holder.spell_masters -= src
		if(spell_holder.client && spell_holder.client.screen)
			spell_holder.client.screen -= src
		spell_holder = null

/obj/abstract/screen/movable/spell_master/resetVariables()
	..("spell_objects", args)
	spell_objects = list()

/obj/abstract/screen/movable/spell_master/MouseDrop()
	if(showing)
		return

	return ..()

/obj/abstract/screen/movable/spell_master/MouseEntered(location,control,params)
	openToolTip(usr,src,params,title = name,content = "Click and drag while closed to move this around the screen")

/obj/abstract/screen/movable/spell_master/MouseExited()
	closeToolTip(usr)

/obj/abstract/screen/movable/spell_master/Click()
	if(!spell_objects.len)
		returnToPool(src)
		return

	toggle_open()

/obj/abstract/screen/movable/spell_master/proc/toggle_open(var/forced_state = 0)
	if(showing && (forced_state != 2))
		for(var/obj/abstract/screen/spell/O in spell_objects)
			if(spell_holder && spell_holder.client)
				spell_holder.client.screen -= O
			O.handle_icon_updates = 0
		showing = 0
		overlays.len = 0
	else if(forced_state != 1)
		open_spellmaster()
		update_spells(1)
		showing = 1
		overlays.len = 0
	var/spellmaster_icon = null
	if(override_icon && (override_icon != icon))
		spellmaster_icon = image(icon = override_icon, icon_state = (showing ? open_state : closed_state))
	else
		spellmaster_icon = showing ? open_state : closed_state
	overlays.Add(spellmaster_icon)

/obj/abstract/screen/movable/spell_master/proc/open_spellmaster()
	var/list/screen_loc_xy = splittext(screen_loc,",")

	//Create list of X offsets
	var/list/screen_loc_X = splittext(screen_loc_xy[1],":")
	var/x_position = decode_screen_X(screen_loc_X[1])
	var/x_pix = screen_loc_X[2]

	//Create list of Y offsets
	var/list/screen_loc_Y = splittext(screen_loc_xy[2],":")
	var/y_position = decode_screen_Y(screen_loc_Y[1])
	var/y_pix = screen_loc_Y[2]

	for(var/i = 1; i <= spell_objects.len; i++)
		var/obj/abstract/screen/spell/S = spell_objects[i]
		var/xpos = x_position + (x_position < (world.view+1) ? 1 : -1)*(i%length)
		var/ypos = y_position + (y_position < (world.view+1) ? round(i/length) : -round(i/length))
		S.screen_loc = "[encode_screen_X(xpos)]:[x_pix],[encode_screen_Y(ypos)]:[y_pix]"
		if(spell_holder && spell_holder.client)
			spell_holder.client.screen += S
			S.handle_icon_updates = 1

/obj/abstract/screen/movable/spell_master/proc/add_spell(var/spell/spell)
	if(!spell)
		return

	if(spell.connected_button) //we have one already, for some reason
		if(spell.connected_button in spell_objects)
			return
		else
			spell_objects.Add(spell.connected_button)
			toggle_open(2)
			return

	if(spell.spell_flags & NO_BUTTON) //no button to add if we don't get one
		return

	var/obj/abstract/screen/spell/newscreen = getFromPool(/obj/abstract/screen/spell)
	newscreen.spellmaster = src
	newscreen.spell = spell
	newscreen.icon = src.icon
	newscreen.icon_state = src.icon_state

	spell.connected_button = newscreen

	if(!spell.override_base) //if it's not set, we do basic checks
		if(spell.spell_flags & CONSTRUCT_CHECK)
			newscreen.spell_base = "const" //construct spells
		else
			newscreen.spell_base = "wiz" //wizard spells
	else
		newscreen.spell_base = spell.override_base
	newscreen.name = spell.name
	newscreen.update_charge(1)
	spell_objects.Add(newscreen)
	toggle_open(2) //forces the icons to refresh on screen

/obj/abstract/screen/movable/spell_master/mech/add_spell(var/spell/mech/MS)
	..()
	var/mechaIcon = MS.linked_mech.initial_icon
	open_state = "[mechaIcon]-open"
	closed_state = "[mechaIcon]"
	//Force it to be open
	toggle_open(2)

/obj/abstract/screen/movable/spell_master/proc/remove_spell(var/spell/spell)
	returnToPool(spell.connected_button)

	spell.connected_button = null

	if(spell_objects.len)
		toggle_open(showing + 1)
	else
		returnToPool(src)

/obj/abstract/screen/movable/spell_master/proc/silence_spells(var/amount)
	for(var/obj/abstract/screen/spell/spell in spell_objects)
		spell.spell.silenced = amount
		spell.update_charge(1)

/obj/abstract/screen/movable/spell_master/proc/update_spells(forced = 0, mob/user)
	if(user && user.client)
		if(!(src in user.client.screen))
			user.client.screen += src
	for(var/obj/abstract/screen/spell/spell in spell_objects)
		spell.update_charge(forced)

/obj/abstract/screen/movable/spell_master/proc/on_holder_death(mob/user)
	for(var/obj/abstract/screen/spell/spell in spell_objects)
		spell.spell.on_holder_death(user)


/obj/abstract/screen/movable/spell_master/genetic
	name = "Mutant Powers"
	icon_state = "genetic_spell_ready"

	open_state = "genetics_open"
	closed_state = "genetics_closed"

	screen_loc = ui_genetic_master

/obj/abstract/screen/movable/spell_master/alien
	name = "Alien Abilities"
	icon_state = "alien_spell_ready"

	open_state = "alien_open"
	closed_state = "alien_closed"

	screen_loc = ui_alien_master
	length = 9

/obj/abstract/screen/movable/spell_master/malf
	name = "Malfunction Modules"
	icon_state = "grey_spell_ready"

	open_state = "malf_open"
	closed_state = "malf_closed"

	screen_loc = ui_alien_master

/obj/abstract/screen/movable/spell_master/racial
	name = "Racial Abilities"
	icon_state = "racial_spell_ready"

	open_state = "genetics_open"
	closed_state = "genetics_closed"

	screen_loc = ui_racial_master

/obj/abstract/screen/movable/spell_master/time
	name = "Time Powers"
	icon_state = "time_spell_ready"

	open_state = "time_open"
	closed_state = "time_closed"

	screen_loc = ui_alien_master

/obj/abstract/screen/movable/spell_master/bloodcult
	name = "Blood Magic"
	icon_state = "cult_spell_ready"

	open_state = "cult_open"
	closed_state = "cult_closed"

/obj/abstract/screen/movable/spell_master/mech
	name = "Mech Modules"
	icon_state = "mech_spell_ready"
	icon = 'icons/mecha/mecha_equipment.dmi'

	//open and close states are defined later
	override_icon = 'icons/mecha/mecha.dmi'
	screen_loc = ui_alien_master

//////////////ACTUAL SPELLS//////////////
//This is what you click to cast things//
/////////////////////////////////////////
/obj/abstract/screen/spell
	icon = 'icons/mob/screen_spells.dmi'
	icon_state = "wiz_spell_base"
	var/spell_base = "wiz"
	var/last_charge = 0 //not a time, but the last remembered charge value
	globalscreen = 1
	var/spell/spell = null
	var/handle_icon_updates = 0
	var/obj/abstract/screen/movable/spell_master/spellmaster

	var/icon/last_charged_icon
	var/channeling_image

/obj/abstract/screen/spell/MouseEntered(location,control,params)
	if(!spell)
		return
	var/dat = ""
	if(spell.charge_type & Sp_RECHARGE)
		dat += "<br>Cooldown: [spell.charge_max/10] second\s"
	if(spell.charge_type & Sp_CHARGES)
		dat += "<br>Has [spell.charge_counter] charge\s left"
	if(spell.charge_type & Sp_HOLDVAR)
		dat += "<br>Requires [spell.holder_var_amount] [spell.holder_var_type]"
	switch(spell.range)
		if(1)
			dat += "<br>Range: Adjacency"
		if(2 to INFINITY)
			dat += "<br>Range: [spell.range]"
		if(GLOBALCAST)
			dat += "<br>Range: Global"
		if(SELFCAST)
			dat += "<br>Range: Self"
	if(spell.desc)
		dat += "<br>Desc: [spell.desc]"
	openToolTip(usr,src,params,title = name,content = dat)

/obj/abstract/screen/spell/MouseExited()
	closeToolTip(usr)

/obj/abstract/screen/spell/Destroy()
	..()
	spell = null
	last_charged_icon = null
	if(spellmaster)
		spellmaster.spell_objects -= src
		if(spellmaster.spell_holder && spellmaster.spell_holder.client)
			spellmaster.spell_holder.client.screen -= src
			remove_channeling()
	if(spellmaster && !spellmaster.spell_objects.len)
		returnToPool(spellmaster)
	spellmaster = null

/obj/abstract/screen/spell/proc/update_charge(var/forced_update = 0)
	if(!spell)
		returnToPool(src)
		return

	if((last_charge == spell.charge_counter || !handle_icon_updates) && !forced_update)
		return //nothing to see here

	var/spell_icon = null
	if(spell.override_icon && (spell.override_icon != icon))
		spell_icon = image(icon = spell.override_icon, icon_state = spell.hud_state, dir = spell.icon_direction)
	else
		spell_icon = spell.hud_state
	overlays -= spell_icon

	if((spell.charge_type & Sp_RECHARGE) || (spell.charge_type & Sp_CHARGES) || (spell.charge_type & Sp_GRADUAL))
		if(spell.charge_counter < spell.charge_max)
			icon_state = "[spell_base]_spell_base"
			if(spell.charge_counter > 0)
				var/icon/partial_charge = icon(src.icon, "[spell_base]_spell_ready")
				partial_charge.Crop(1, 1, partial_charge.Width(), round(partial_charge.Height() * spell.charge_counter / spell.charge_max))
				overlays += partial_charge
				if(last_charged_icon)
					overlays -= last_charged_icon
				last_charged_icon = partial_charge
			else if(last_charged_icon)
				overlays -= last_charged_icon
				last_charged_icon = null
		else
			icon_state = "[spell_base]_spell_ready"
			if(last_charged_icon)
				overlays -= last_charged_icon
	else
		icon_state = "[spell_base]_spell_ready"
	overlays += spell_icon

	last_charge = spell.charge_counter

	overlays -= image(icon = icon, icon_state = "silence")
	if(spell.silenced)
		overlays += image(icon = icon, icon_state = "silence")

/obj/abstract/screen/spell/Click(location, control, params)
	if(!usr || !spell)
		returnToPool(src)
		return

	var/list/param_list = params2list(params)
	if(param_list["middle"])
		if(spell.on_right_click(usr))
			return

	spell.perform(usr)
	update_charge(1)

//Helper proc, does not remove channeling
/obj/abstract/screen/spell/proc/add_channeling()
	var/image/channel = image(icon = icon, loc = src, icon_state = "channeled", layer = src.layer + 1)
	channeling_image = channel
	if(spellmaster && spellmaster.spell_holder && spellmaster.spell_holder.client)
		spellmaster.spell_holder.client.images += channeling_image

/obj/abstract/screen/spell/proc/remove_channeling()
	if(spellmaster && spellmaster.spell_holder && spellmaster.spell_holder.client)
		spellmaster.spell_holder.client.images -= channeling_image
	channeling_image = null
