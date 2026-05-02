/obj/item/weapon/gun/procgun
    desc = "Oh no..."
    name = "proc gun"
    icon = 'icons/obj/device.dmi'
    icon_state = "eftpos" // We gmod now (looks like toolgun)
    w_class = W_CLASS_SMALL
    recoil = 0
    fire_delay = 0
    fire_sound = "procgun_sound"
    var/procname
    var/list/procargs = list()

var/static/list/bad_procs = list(
	"gib",
	"ex_act",
	"singularity_act",
	"shuttle_act",
	"death",
)

/obj/item/weapon/gun/procgun/attack_self(mob/user)
    if(!user.check_rights(R_DEBUG))
        to_chat(user,"<span class='warning'>You do not have the divine authority to modify what this gun does.</span>")
        return

    procname = input("Proc path to call on target hit, eg: /proc/fake_blood","Path:", null) as text|null
    if(!procname)
        return

    var/argnum = input("Number of arguments","Number:",0) as num|null
    if(!argnum && (argnum!=0))
        return

    procargs.len = argnum // Expand to right length

    for(var/i in 1 to argnum) // Lists indexed from 1 forwards in byond
        procargs[i] = variable_set(user.client)

    if(procname in bad_procs)
        desc = "RUN!!!"
    else
        desc = "Oh no..."

    process_chambered()

/obj/item/weapon/gun/procgun/process_chambered()
    if(!in_chamber)
        in_chamber = new/obj/item/projectile/beam/procjectile(src)
    var/obj/item/projectile/beam/procjectile/P = in_chamber
    P.procname = procname
    P.procargs = procargs.Copy()
    return 1

/obj/item/projectile/beam/procjectile
    name = "proc beam"
    icon = 'icons/obj/projectiles_experimental.dmi'
    icon_state = "procg"
    damage = 0
    nodamage = TRUE
    fire_sound = "procgun_sound"
    var/procname
    var/list/procargs = list()

/obj/item/projectile/beam/procjectile/to_bump(atom/A)
    if(procname && hascall(A, procname))
        spawn(1)
            call(A,procname)(arglist(procargs))
    return ..()

/obj/item/procnade
	name = "Procnade"
	desc = "Oh no..."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/items_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/items_righthand.dmi')
	icon = 'icons/obj/grenade.dmi'
	icon_state = "banana"
	item_state = "banana" //banana inhand sprites when
	w_class = W_CLASS_SMALL
	var/affected_area = 2
	var/procname
	var/typefilter = /atom
	var/list/procargs = list()

/obj/item/procnade/attack_self(mob/user)
	if(!user.check_rights(R_DEBUG))
		to_chat(user,"<span class='warning'>You do not have the divine authority to modify what this grenade does.</span>")
		return

	procname = input("Proc path to call on affected, eg: /proc/fake_blood","Path:",procname) as text|null
	if(!procname)
		return

	var/argnum = input("Number of arguments","Number:",procargs.len) as num|null
	if(!argnum && (argnum!=0))
		return

	procargs.len = argnum // Expand to right length

	for(var/i in 1 to argnum) // Lists indexed from 1 forwards in byond
		procargs[i] = variable_set(user.client)

	if(procname in bad_procs)
		desc = "RUN!!!"
	else
		desc = "Oh no..."

	var/texttype = input("Type to filter to, eg: /obj/item","Type:", null) as text|null
	var/ourtype = texttype ? filter_list_input("Select an atom type", "Type filter", get_matching_types(texttype, /atom)) : /atom
	typefilter = ourtype || /atom

	affected_area = input("Range to affect","Range", affected_area) as num|null
	if(!affected_area)
		affected_area = world.view

/obj/item/procnade/throw_impact(atom/impacted_atom, speed, mob/user)
	if(!..() && procname)
		playsound(src, 'sound/effects/bamfgas.ogg', 50, 1)
		visible_message("<span class='warning'>[bicon(src)] \The [src] bursts open.</span>")
		var/turf/T = get_turf(src)
		for(var/atom/A in view(affected_area, src))
			if(T && cheap_pythag(T.x - A.x, T.y - A.y) > affected_area) // do it in a circle
				continue
			if(istype(A,typefilter) && procname && hascall(A, procname))
				spawn(1)
					call(A,procname)(arglist(procargs))

