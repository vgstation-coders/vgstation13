#define WIRE_RECEIVE	1
#define WIRE_PULSE	2
#define WIRE_PULSE_SPECIAL	4
#define WIRE_RADIO_RECEIVE	8
#define WIRE_RADIO_PULSE	16

/obj/item/device/assembly
	name = "assembly"
	desc = "A small electronic device that should never exist."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = ""
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=100)
	throwforce = 2
	throw_speed = 3
	throw_range = 7

	var/secured = TRUE
	var/list/attached_overlays = null
	var/obj/item/device/assembly_holder/holder = null
	var/wire_type = WIRE_RECEIVE | WIRE_PULSE
	var/attachable = FALSE // can this be attached to wires
	var/datum/wires/connected = null

	var/next_activate = 0 //When we're next allowed to activate - for spam control

/obj/item/device/assembly/get_part_rating()
	return 1

/obj/item/device/assembly/proc/on_attach()

/obj/item/device/assembly/proc/on_detach()

/obj/item/device/assembly/proc/holder_movement()							//Called when the holder is moved
	return

/obj/item/device/assembly/proc/describe()									// Called by grenades to describe the state of the trigger (time left, etc)
	return "The trigger assembly looks broken!"


/obj/item/device/assembly/proc/is_secured(mob/user)
	if(!secured)
		to_chat(user, "<span class='warning'>The [name] is unsecured!</span>")
		return FALSE
	return TRUE


//Called when another assembly acts on this one, var/radio will determine where it came from for wire calcs
/obj/item/device/assembly/proc/pulsed(radio = 0)
	if(wire_type & WIRE_RECEIVE)
		INVOKE_ASYNC(src, .proc/activate)
	if(radio && (wire_type & WIRE_RADIO_RECEIVE))
		INVOKE_ASYNC(src, .proc/activate)
	return TRUE


//Called when this device attempts to act on another device, var/radio determines if it was sent via radio or direct
/obj/item/device/assembly/proc/pulse(radio = 0)
	if(connected && wire_type)
		connected.pulse_assembly(src)
		return TRUE
	if(holder && (wire_type & WIRE_PULSE))
		holder.process_activation(src, 1, 0)
	if(holder && (wire_type & WIRE_PULSE_SPECIAL))
		holder.process_activation(src, 0, 1)
	return TRUE


// What the device does when turned on
/obj/item/device/assembly/proc/activate()
	if(QDELETED(src) || !secured || (next_activate > world.time))
		return FALSE
	next_activate = world.time + 30
	return TRUE


/obj/item/device/assembly/proc/toggle_secure()
	secured = !secured
	update_icon()
	return secured


/obj/item/device/assembly/attackby(obj/item/W, mob/user, params)
	if(isassembly(W))
		var/obj/item/device/assembly/A = W
		if((!A.secured) && (!secured))
			holder = new/obj/item/device/assembly_holder(get_turf(src))
			holder.assemble(src,A,user)
			to_chat(user, "<span class='notice'>You attach and secure \the [A] to \the [src]!</span>")
		else
			to_chat(user, "<span class='warning'>Both devices must be in attachable mode to be attached together.</span>")
		return
	if(istype(W, /obj/item/screwdriver))
		if(toggle_secure())
			to_chat(user, "<span class='notice'>\The [src] is ready!</span>")
		else
			to_chat(user, "<span class='notice'>\The [src] can now be attached!</span>")
		return
	..()


/obj/item/device/assembly/examine(mob/user)
	..()
	if(secured)
		to_chat(user, "\The [src] is secured and ready to be used.")
	else
		to_chat(user, "\The [src] can be attached to other things.")


/obj/item/device/assembly/attack_self(mob/user)
	if(!user)
		return FALSE
	user.set_machine(src)
	interact(user)
	return TRUE

/obj/item/device/assembly/interact(mob/user)
	return ui_interact(user)
