/* Flare gun. Shoots a flare type of shotgun ammo, creating a glowing projectile that produces a flare when it dies
   Useful in emergencies to signal and to light up corridors. Syndicate version is deadly and sets people on fire, and likely going to atmos techs */

/obj/item/weapon/gun/projectile/flare
	name = "flare gun"
	desc = "Light (people on fire), now at a distance."
	fire_sound = 'sound/weapons/shotgun.ogg'
	icon_state = "flaregun"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns.dmi', "right_hand" = 'icons/mob/in-hand/right/guns.dmi')
	item_state = "flaregun"
	max_shells = 1
	w_class = W_CLASS_MEDIUM
	starting_materials = list(MAT_IRON = 15000, MAT_GLASS = 7500)
	w_type = RECYK_METAL
	force = 4
	recoil = 1
	fire_delay = 10
	flags = FPRINT
	siemens_coefficient = 1
	caliber = list(GAUGEFLARE = 1)
	origin_tech = Tc_COMBAT + "=2;" + Tc_MATERIALS + "=2"
	ammo_type = "/obj/item/ammo_casing/shotgun/flare"
	gun_flags = 0

/obj/item/weapon/gun/projectile/flare/syndicate
	desc = "An illegal flare gun with a modified hammer, allowing it to fire shotgun shells and flares at dangerous velocities."
	recoil = 3
	fire_delay = 5 //faster, because it's also meant to be a weapon
	caliber = list(GAUGEFLARE = 1, GAUGE12 = 1)
	origin_tech = Tc_COMBAT + "=4;" + Tc_MATERIALS + "=2;" + Tc_SYNDICATE + "=2"