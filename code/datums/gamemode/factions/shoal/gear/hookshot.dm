#define NET_RESIST_TIME 60 SECONDS
#define NET_RESIST_TIME_STRONG 30 SECONDS
#define NET_RESIST_TIME_HULK 5 SECONDS
#define NET_HELP_TIME 10 SECONDS
#define NET_CUT_TIME  3 SECONDS

// Called when the atom is anchored and hit by a netgun. Returns 0 by default, resulting in the net bouncing off the atom.
/atom/movable/proc/can_be_netted_while_anchored()
	return 0

/atom/movable/proc/can_be_netted()
	return 0

/mob/living/can_be_netted()
	return 1

/obj/machinery/can_be_netted()
	return 1

// Called when the atom is netted by a netgun
/atom/movable/proc/on_netted()
	return 0

// Called when the atom is pulled by a netgun
/atom/movable/proc/net_pull()
	return 0

/obj/item/loose_net
	name = "loose net"
	desc = "A loose net for trapping things. The heavy weights make it difficult to throw without some sort of launcher."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "net"
	throw_range = 6
	w_class = W_CLASS_SMALL

/obj/item/loose_net/throw_at(var/atom/A, throw_range, throw_speed)
	if(ismob(usr))
		var/mob/living/M = usr
		if((M_HULK in M.mutations) || (M_STRONG in M.mutations))
			..()
		else
			to_chat(usr,"<span class='warning'>You fumble with the heavy [src]!</span>")
	else
		..()

/obj/item/loose_net/throw_impact(atom/impacted_atom, speed, mob/user)
	if(!..() && isliving(impacted_atom))
		var/mob/living/L = impacted_atom
		new /obj/structure/net(L.loc, list(L))
		qdel(src)


//////////////////////////////////////

/obj/structure/net
	name = "sticky net"
	desc = "It's a net. Not a closet."
//	icon = 'icons/obj/structures.dmi'
//	icon_state = "net"
	icon = null
	icon_state = ""
	anchored = FALSE

	var/item_type = /obj/item/loose_net

	var/atom/movable/visholder  // Because humans really don't behave when put directly into vis_contents
	var/list/visholder_cache = list()

	plane = ABOVE_OBJ_PLANE

/obj/structure/net/New(loc,var/atom/movable/atom_to_net)
	..()
	if(!atom_to_net)
		undo_net()
	create_visholder()
	insert_content(atom_to_net)

/obj/structure/net/Destroy(var/loose_net = TRUE)
	dump_contents()
	QDEL_NULL(visholder)
	..()

/obj/structure/net/proc/insert_content(var/atom/movable/AM)
	if(!AM)
		return
	if(istype(AM, /mob/living))
		var/mob/living/L = AM
		if(L.locked_to)
			return 0
		if(L.client)
			L.client.perspective = EYE_PERSPECTIVE
			L.client.eye = src
		L.Knockdown(1)
		L.resting = TRUE
		L.visible_message("<span class='warning'>\The [src] is caught by \the [L]!</span>", \
			"<span class='danger'>You're tangled up by \the [src]!</span>")
	AM.forceMove(src)
	handle_vis_enter(AM)
	playsound(src, 'sound/weapons/netgun_reload.ogg', 60, 1)

/obj/structure/net/proc/dump_contents()
	for(var/obj/O in contents)
		O.forceMove(src.loc)
		handle_vis_exit(O)

	for(var/mob/M in contents)
		M.forceMove(loc)
		handle_vis_exit(M)
		if(M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE

/obj/structure/net/attack_hand(mob/living/M)
	attempt_remove(M, NET_HELP_TIME)
	..()

/obj/structure/net/attackby(obj/item/weapon/W, mob/user)
	if(W.sharpness_flags & (SHARP_BLADE|SERRATED_BLADE))
		attempt_remove(user, NET_CUT_TIME, TRUE)
	..()

/obj/structure/net/proc/attempt_remove(mob/living/M, time = NET_HELP_TIME, cutted = FALSE)
	M.visible_message("<span class='warning'>[src] starts [cutted ? "cutting away" : "pulling apart"] \the [src].</span>", \
	"<span class='notice'>You start [cutted ? "cutting away" : "pulling apart"] \the [src].</span>")
	if(do_after(M, src, time))
		M.visible_message("<span class='warning'>[src] [cutted ? "cuts away" : "pulls apart"] \the [src].</span>", \
		"<span class='notice'>You [cutted ? "cut away" : "pull apart"] \the [src]!</span>")
		if(src)
			undo_net(cutted)

/obj/structure/net/proc/undo_net(cutted = FALSE)
	if(!cutted)
		new /obj/item/loose_net(loc)
	dump_contents()
	qdel(src)


/obj/structure/net/proc/create_visholder()
	if(visholder)
		return FALSE
	visholder = new(src)
	visholder.name = "net holder"
	visholder.vis_flags = (VIS_INHERIT_DIR | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER | VIS_INHERIT_ID)
	visholder.appearance_flags |= PIXEL_SCALE
	return TRUE

/obj/structure/net/proc/handle_vis_enter(var/atom/movable/AM)
	visholder_cache[AM] = AM.vis_flags

	AM.filters += filter(type="outline", name="netoutline", size=1,color="#DDDDDD")
	visholder.icon = getNettedIcon(new/icon(AM.icon, AM.icon_state))
	AM.vis_flags = (VIS_INHERIT_DIR | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER | VIS_UNDERLAY | VIS_INHERIT_ID)
	AM.appearance_flags |= PIXEL_SCALE
	vis_contents += AM
	AM.overlays += visholder

/obj/structure/net/proc/handle_vis_exit(var/atom/movable/AM)
	if(AM)
		AM.overlays -= visholder
		AM.filters -= "netoutline"
		AM.vis_flags = visholder_cache[AM]
		visholder_cache[AM] = 0
		visholder.vis_contents -= AM



/////////////////////////////////////

/obj/item/weapon/gun/hookshot/netgun
	name = "net gun"
	icon_state = "netgun"
	item_state = "netgun"
	fire_sound = 'sound/weapons/netgun_fire.ogg'
	empty_sound = 'sound/weapons/netgun_empty.ogg'


	hooktype = /obj/item/projectile/hookshot/net
	chaintype = /obj/effect/overlay/hookchain/net
	maxlength = 7

	var/nets = 10

/obj/item/weapon/gun/hookshot/netgun/examine(mob/user, size, show_name)
	..()
	to_chat(user, "<span class='info'>A meter on the side indicates that there are [nets] nets remaining.</span>")

/obj/item/weapon/gun/hookshot/netgun/update_icon()
	icon_state = "netgun"

/obj/item/weapon/gun/hookshot/netgun/process_chambered()
	. = ..()
	if(!. || nets <= 0)
		return 0
	else
		nets -= 1
		return 1


/obj/item/weapon/gun/hookshot/netgun/attackby(obj/item/A, mob/user)
	..()
	if(istype(A, /obj/item/loose_net))
		user.visible_message("<span class='notice'>[user] loads the [A] into the [src].</span>", \
		"</span class='notice'>You load the [A] into the [src].</span>")
		nets += 1
		playsound(user, 'sound/weapons/netgun_reload.ogg', 50, 1)
		qdel(A)

/obj/item/projectile/hookshot/net
	name = "net"
	icon_state = "netshot"
	icon_name = "netshot"

	chain_overlay_path = /obj/effect/overlay/chain/net
	var/net_created = FALSE

/obj/item/projectile/hookshot/net/on_hit_maxlength(var/obj/effect/overlay/hookchain/HC)
	HC.icon_state = "[icon_name]_pixel"
	on_hit_invalid(get_turf(src))

/obj/item/projectile/hookshot/net/on_turf_bump(var/turf/T)
	on_hit_invalid(T)

// No special behavior for hitting something adjacent to us.
/obj/item/projectile/hookshot/net/on_hit_adjacent(var/atom/movable/AM)
	on_hooked(AM)

/obj/item/projectile/hookshot/net/on_hit_anchored(var/atom/movable/AM)
	if(AM.can_be_netted())
		on_hooked(AM)
	else
		on_hit_invalid(AM)

// Create a net on the target.
/obj/item/projectile/hookshot/net/on_hooked(var/atom/movable/AM)
	create_net(get_turf(AM))
	bullet_die()

// Create a net on our position, instead of the target.
/obj/item/projectile/hookshot/net/on_hit_invalid(var/atom/A)
	create_net(get_turf(src))
	bullet_die()


// Creates a net on a turf, and tethers the hookshot to it.
/obj/item/projectile/hookshot/net/proc/create_net(var/atom/A)
	if(net_created)	// Hacky fix for double-netting
		return
	net_created = TRUE

	var/atom/movable/to_net
	// If we hit a turf, we'll net the first thing we hit.
	if(isturf(A))
		var/turf/T = A

		// Prioritize netting living mobs.
		for(var/mob/living/M in T)
			if(M.locked_to)
				if(unlock_atom(M.locked_to))
					to_net = M
					break
			else
				to_net = M
		//  Then we go for other atoms.
		for(var/atom/movable/AM in T)
			if(!AM.can_be_netted())
				continue
			else
				if(AM.locked_to)
					continue
				if(!isturf(AM.loc))
					continue
				if(AM.anchored && !AM.can_be_netted_while_anchored())
					continue
				to_net = AM
	else
		to_net = A

	if(to_net)
		var/obj/structure/net/net = new(get_turf(A), to_net)
		net.set_glide_size(firer.glide_size)
		create_chain(net)
	else
		var/obj/item/loose_net/net = new(get_turf(A))
		net.set_glide_size(firer.glide_size)
		create_chain(net)


//THE CHAIN THAT APPEARS WHEN YOU FIRE THE HOOKSHOT
/obj/effect/overlay/hookchain/net
	name = "length of netting"
	icon_state = "netshot_chain"

//THE CHAIN THAT TETHERS STUFF TOGETHER
/obj/effect/overlay/chain/net
	name = "length of netting"
	overlay_name = "netshot_chain"


///////////////////////////////////////////////////






#undef NET_HELP_TIME
#undef NET_CUT_TIME
