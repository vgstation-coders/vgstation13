#define MIN_TO_FIRE MEGAWATT

/obj/item/weapon/gun/tesla
	name = "\improper Telsa Cannon"
	desc = "It's a tesla cannon."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "teslacannon_ready"
	item_state = "gravitywell"
	w_class = W_CLASS_LARGE
	slot_flags = SLOT_BELT
	origin_tech = Tc_MATERIALS + "=7;" + Tc_POWERSTORAGE + "=7;" + Tc_MAGNETS + "=5" + Tc_SYNDICATE + "=4;"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 0
	flags = FPRINT
	w_class = W_CLASS_MEDIUM
	fire_delay = 0
	fire_sound = 'sound/weapons/wave.ogg'

	var/connected = 0
	var/charging = 0
	
	var/obj/item/weapon/stock_parts/capacitor/loaded_capacitor = null

/obj/item/weapon/gun/tesla/examine(mob/user, size, show_name)
	..()
	if(!loaded_capacitor)
		to_chat(user, "<span class='warning'>\The [src.name] is missing a capacitor.</span>")
	else
		to_chat(user, "<span class='notice'>\The [src.name] is charged to [round(loaded_capacitor.stored_charge / MEGAWATT, 0.01)] MW.</span>")
		if(loaded_capacitor.stored_charge >= MIN_TO_FIRE)
			to_chat(user, "<span class='notice'>\The [src.name] is ready to fire!</span>")

/obj/item/weapon/gun/tesla/process_chambered()
	if(in_chamber)
		return 1
	if(!loaded_capacitor)
		return 0
	if(loaded_capacitor.stored_charge < MIN_TO_FIRE)
		return 0
	var/obj/item/projectile/teslaball/T 
	if(loaded_capacitor.stored_charge >= GIGAWATT)
		T = new /obj/item/projectile/teslaball/yellow()
	else
		T = new /obj/item/projectile/teslaball()
	in_chamber = T
	T.charge = loaded_capacitor.stored_charge
	loaded_capacitor.stored_charge = 0
	return 1

/obj/item/weapon/gun/tesla/afterattack(atom/A, mob/living/user, flag, params, struggle = 0)
	A = get_turf(A)
	..()

/obj/item/weapon/gun/tesla/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/stock_parts/capacitor))
		if(do_after(user, src, 5 SECONDS))
			if(user.drop_item(W, src))
				to_chat(user, "<span class='notice'>You load the [W.name] into the [src].")	
				loaded_capacitor = W
				W.forceMove(src)
				if(loaded_capacitor.stored_charge >= MIN_TO_FIRE)
					playsound(src,'sound/mecha/powerup.ogg', 50)
				update_icon()

/obj/item/weapon/gun/tesla/attack_self(mob/user)
	if(loaded_capacitor)
		to_chat(user, "<span class='notice'>You remove the [loaded_capacitor.name] from the [src].")
		user.put_in_hands(loaded_capacitor)
		loaded_capacitor = null
		update_icon()


/obj/item/weapon/gun/tesla/update_icon()
	if(loaded_capacitor && loaded_capacitor.stored_charge >= MIN_TO_FIRE)
		icon_state = "teslacannon[loaded_capacitor.stored_charge >= GIGAWATT ? "_strong" : ""]_ready"
	else
		icon_state = "teslacannon"

/obj/item/weapon/gun/tesla/preloaded/New()
	..()
	loaded_capacitor = new /obj/item/weapon/stock_parts/capacitor/adv/super/pre_charged

/obj/item/weapon/stock_parts/capacitor/adv/super/pre_charged
	stored_charge = MEGAWATT


#undef MIN_TO_FIRE