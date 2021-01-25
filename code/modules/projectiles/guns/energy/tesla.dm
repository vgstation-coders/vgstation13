/obj/item/weapon/gun/tesla
	name = "\improper Telsa Cannon"
	desc = "It's a tesla cannon."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "gravitywell"
	item_state = "gravitywell"
	slot_flags = SLOT_BELT
	origin_tech = Tc_MATERIALS + "=7;" + Tc_POWERSTORAGE + "=7;" + Tc_MAGNETS + "=5" + Tc_SYNDICATE + "=4;"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 0
	flags = FPRINT
	w_class = W_CLASS_MEDIUM
	fire_delay = 0
	fire_sound = 'sound/weapons/wave.ogg'


/obj/item/weapon/gun/tesla/process_chambered()
	if(in_chamber)
		return 1
			
	var/obj/item/projectile/teslaball/T = new /obj/item/projectile/teslaball()
	in_chamber = T
	T.charge = 100 * MEGAWATT
	processing_objects.Add(src)
	return 1

/obj/item/weapon/gun/tesla/afterattack(atom/A, mob/living/user, flag, params, struggle = 0)
	A = get_turf(A)
	..()