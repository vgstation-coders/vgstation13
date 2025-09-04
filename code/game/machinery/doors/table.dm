//Its a door. Doors are too machiney, lets make it a structure instead! -Oldcoders
//That was a bad idea, lets make it a machine instead!

/obj/machinery/door/table
	name = "table door"
	opacity = 0
	animation_delay = 0
	pass_flags_self = PASSTABLE
	layer = TABLE_LAYER
	open_layer = TABLE_LAYER
	throwpass = 1	//You can throw objects over this, despite its density.
	use_power = MACHINE_POWER_USE_NONE
	machine_flags = SCREWTOGGLE
	icon = 'icons/obj/doors/tabledoor.dmi'
	icon_state = "metaldoor_closed"
	prefix = "metal" //Corresponds to the mineral type
	health = 100
	soundeffect = 'sound/effects/wood_door_slam.ogg'
	var/obj/item/weapon/circuitboard/airlock/electronics = null
	sheet_type = /obj/item/stack/sheet/metal

/obj/machinery/door/table/New()
	. = ..()
	update_adjacent()
	if(req_access_txt != "0" || req_one_access_txt != "0")
		set_up_access()
		electronics = new /obj/item/weapon/circuitboard/airlock(src)
		electronics.installed = TRUE
		if(req_access?.len)
			electronics.conf_access = req_access
		else if(req_one_access?.len)
			electronics.conf_access = req_one_access
			electronics.one_access = 1
		electronics.dir_access = req_access_dir
		electronics.access_nodir = access_not_dir

/obj/machinery/door/table/Destroy()
	QDEL_NULL(electronics)
	setDensity(FALSE)
	update_adjacent()
	. = ..()

/obj/machinery/door/table/Bumped(atom/user)
	if(!density || operating)
		return

	if(!emagged && !allowed(user))
		denied()
	else
		open()
		spawn(2 SECONDS)
			close()

/obj/machinery/door/table/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(!density)
		return 1
	if(locate(/obj/effect/unwall_field) in loc)
		return 1
	if(air_group || (height==0))
		return 1
	if(istype(mover,/obj/item/projectile))
		return (check_cover(mover,target))
	if(ismob(mover))
		var/mob/M = mover
		if(M.flying)
			return 1
	if(istype(mover) && mover.checkpass(pass_flags_self))
		return 1
	return 0

//checks if projectile 'P' from turf 'from' can hit whatever is behind the table. Returns 1 if it can, 0 if bullet stops.
/obj/machinery/door/table/proc/check_cover(obj/item/projectile/P, turf/from)
	var/shooting_at_the_table_directly = (P.original == src)
	var/chance = 60
	if(shooting_at_the_table_directly || prob(chance))
		health -= P.damage/2
		if (health > 0)
			visible_message("<span class='warning'>[P] hits \the [src]!</span>")
			return 0
		else
			visible_message("<span class='warning'>[src] breaks down!</span>")
			dismantle()
			return 1
	return 1

/obj/machinery/door/table/proc/update_adjacent()
	for(var/direction in cardinal)
		var/obj/structure/table/T = locate(/obj/structure/table, get_step(src, direction))
		if(T)
			T.update_icon()

/obj/machinery/door/table/door_animate(animation) // no spritework for it
	return

/obj/machinery/door/table/attack_ai(mob/user) //those aren't really machinery, they're just big fucking slabs of a mineral
	if(isAI(user)) //so the AI can't open it
		return
	else if(isrobot(user) && get_dist(user,src) <= 1) //but robots can, not remotely though
		return TryToSwitchState(user) //also >nesting if statements

/obj/machinery/door/table/attack_paw(mob/user)
	if(M_HULK in user.mutations)
		user.do_attack_animation(src, user)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		visible_message("<span class='danger'>[user] smashes the [src] apart!</span>")
		user.delayNextAttack(8)
		dismantle()
		return
	return TryToSwitchState(user)

/obj/machinery/door/table/attack_hand(mob/user)
	if(M_HULK in user.mutations)
		user.do_attack_animation(src, user)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		dismantle()
		return
	return TryToSwitchState(user)

/obj/machinery/door/table/attack_alien(mob/living/user)
	user.do_attack_animation(src, user)
	visible_message("<span class='danger'>[user] slices [src] apart!</span>")
	dismantle()

/obj/machinery/door/table/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash_flags & SMASH_LIGHT_STRUCTURES)
		user.do_attack_animation(src, user)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		dismantle()

/obj/machinery/door/table/proc/TryToSwitchState(mob/user)
	if(operating)
		return

	if(!user.restrained() && (user.size > SIZE_TINY))
		add_fingerprint(user)
		SwitchState()
	return

/obj/machinery/door/table/proc/SwitchState()
	if(!density)
		return close()
	else
		return open()

/obj/machinery/door/table/proc/remove_electronics()
	if (electronics)
		electronics.forceMove(loc)
		electronics = null
	req_access = list()
	req_one_access = list()

/obj/machinery/door/table/proc/dismantle()
	remove_electronics()
	if(sheet_type)
		new sheet_type(loc,2)
	qdel(src)

/obj/machinery/door/table/open()
	playsound(src, soundeffect, 100, 1)
	return ..()

/obj/machinery/door/table/close()
	playsound(src, soundeffect, 100, 1)
	. = ..()
	set_opacity(0) //always seethru

/obj/machinery/door/table/attackby(obj/item/W, mob/user, params)

	if (!electronics)
		if(W.is_wrench(user))
			to_chat(user, "<span class='notice'>Now disassembling [src]...</span>")
			W.playtoolsound(src, 50)
			if(do_after(user, src,50))
				dismantle()
			return

		if(panel_open && istype(W,/obj/item/weapon/circuitboard/airlock))
			if(W.icon_state == "door_electronics_smoked")
				to_chat(user, "<span class='warning'>Repair \the [W] before putting it in!</span>")
			if(user.drop_item(W,src))
				electronics = W
				if(electronics.conf_access?.len)
					if(electronics.one_access)
						req_one_access = electronics.conf_access
					else
						req_access = electronics.conf_access
				electronics.installed = TRUE
				playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You add [electronics] to [src].</span>")
			return

	else
		if(W.is_wrench(user))
			to_chat(user, "<span class='warning'>Remove [electronics] first!</span>")
			return

		if(panel_open && iscrowbar(W))
			user.visible_message("<span class='notice'>[user] is removing [electronics] from [src].</span>", "<span class='notice'>You start to remove \the [electronics] from [src].</span>")
			W.playtoolsound(src, 100)
			if(do_after(user, src, 40) && src && panel_open && electronics)
				to_chat(user, "<span class='notice'>You removed [electronics]!</span>")
				remove_electronics()
			return

	if(!allowed(user))
		denied()
		return

	. = ..()

/obj/machinery/door/table/emag_act(var/mob/user)
	if (!electronics || emagged)
		return FALSE
	electronics.icon_state = "door_electronics_smoked"
	emagged = TRUE
	req_access = list()
	req_one_access = list()
	spark(loc,2)
	open()
	return TRUE

/obj/machinery/door/table/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.destroy)
		dismantle()
	return ..()

/obj/machinery/door/table/blob_act()
	if(prob(75))
		dismantle()

/obj/machinery/door/table/ex_act(severity)
	switch(severity)
		if(1)
			dismantle()
		if(2)
			if (prob(50))
				dismantle()
		if(3)
			if (prob(25))
				dismantle()

/obj/machinery/door/table/reinforced
	name = "reinforced table door"
	icon_state = "rmetaldoor_closed"
	prefix = "rmetal"
	health = 200
	sheet_type = /obj/item/stack/sheet/plasteel
	var/reinforced = TRUE

/obj/machinery/door/table/reinforced/attackby(obj/item/W, mob/user, params)
	if(reinforced)
		if(W.is_wrench(user))
			to_chat(user, "<span class='warning'>Weaken \the [src] first!</span>")
			return

		if (iswelder(W))
			var/obj/item/tool/weldingtool/WT = W
			if(WT.isOn())
				to_chat(user, "<span class='notice'>Now [reinforced ? "weak" : "strength"]ening \the [src].</span>")
				if(WT.do_weld(user, src, 50, 0))
					if(gcDestroyed)
						return
					reinforced = !reinforced
					to_chat(user, "<span class='notice'>Table  [reinforced ? "strength" : "weak"]ened.</span>")
				return
	. = ..()

/obj/machinery/door/table/wood
	name = "wooden table door"
	icon_state = "wooddoor_closed"
	prefix = "wood"
	health = 50
	flammable = TRUE
	w_type = RECYK_WOOD
	sheet_type = /obj/item/stack/sheet/wood

/obj/machinery/door/table/glass
	name = "glass table door"
	icon_state = "glassdoor_closed"
	prefix = "glass"
	health = 30
	sheet_type = /obj/item/stack/sheet/glass/rglass
	var/shard_type = /obj/item/weapon/shard

/obj/machinery/door/table/glass/kick_act()
	health -= 5
	checkhealth()
	..()

/obj/machinery/door/table/glass/proc/checkhealth()
	if(health <= 0)
		playsound(src, "shatter", 50, 1)
		new shard_type(src.loc)
		sheet_type = /obj/item/stack/rods
		dismantle()

/obj/machinery/door/table/glass/attackby(obj/item/W, mob/user, params)
	if (user.a_intent == I_HURT)
		user.do_attack_animation(src, W)
		user.delayNextAttack(10)
		health -= W.force
		user.visible_message("<span class='warning'>\The [user] hits \the [src] with \the [W].</span>", \
		"<span class='warning'>You hit \the [src] with \the [W].</span>")
		playsound(src, 'sound/effects/Glasshit.ogg', 50, 1)
		checkhealth()
		return

	. = ..()

/obj/machinery/door/table/glass/plasma
	name = "plasma glass table door"
	icon_state = "pglassdoor_closed"
	prefix = "pglass"
	health = 150
	sheet_type = /obj/item/stack/sheet/glass/plasmarglass
	shard_type = /obj/item/weapon/shard/plasma
