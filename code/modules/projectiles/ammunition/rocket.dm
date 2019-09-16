/obj/item/ammo_casing/rocket_rpg
	name = "rocket"
	desc = "Explosive supplement to the syndicate's rocket launcher."
	icon_state = "rpground"
	caliber = ROCKETGRENADE
	projectile_type = "/obj/item/projectile/rocket"
	starting_materials = list(MAT_IRON = 15000)
	w_type = RECYK_METAL
	w_class = W_CLASS_MEDIUM // Rockets don't exactly fit in pockets and cardboard boxes last I heard, try your backpack
	shrapnel_amount = 0
	
/obj/item/ammo_casing/rocket_rpg/update_icon()
	return

/obj/item/ammo_casing/rocket_rpg/lowyield
	name = "low yield rocket"
	desc = "Explosive supplement to Nanotrasen's rocket launchers."
	projectile_type = "/obj/item/projectile/rocket/lowyield"
	starting_materials = list(MAT_IRON = 20000)

/obj/item/ammo_casing/rocket_rpg/blank
	name = "blank rocket"
	desc = "This rocket left intentionally blank."
	projectile_type = "/obj/item/projectile/rocket/blank"
	starting_materials = list(MAT_IRON = 100)

/obj/item/ammo_casing/rocket_rpg/emp
	name = "EMP rocket"
	desc = "EMP rocket for the Nanotrasen rocket launcher."
	projectile_type = "/obj/item/projectile/rocket/blank/emp"
	starting_materials = list(MAT_IRON = 20000, MAT_URANIUM = 500)

/obj/item/ammo_casing/rocket_rpg/stun
	name = "stun rocket"
	desc = "Stun rocket for the Nanotrasen rocket launcher. Not a flashbang."
	projectile_type = "/obj/item/projectile/rocket/blank/stun"
	starting_materials = list(MAT_IRON = 50000, MAT_SILVER = 1000)
	
/obj/item/ammo_casing/rocket_rpg/extreme
	name = "extreme rocket" //don't even map or spawn this in or you'll be very sad
	desc = "Extreme-yield rocket. Fire from very very far away."
	projectile_type = "/obj/item/projectile/rocket/lowyield/extreme"