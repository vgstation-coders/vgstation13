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
	var/icon_suffix = "rocket" //used for rpg overlays in update_icon()

/obj/item/ammo_casing/rocket_rpg/update_icon()
	return

/obj/item/ammo_casing/rocket_rpg/lowyield
	name = "low yield rocket"
	desc = "Explosive supplement to Nanotrasen's rocket launchers."
	icon_state = "rpground_lowyield"
	projectile_type = "/obj/item/projectile/rocket/lowyield"
	icon_suffix = "lowyield"
	starting_materials = list(MAT_IRON = 10000)

/obj/item/ammo_casing/rocket_rpg/blank
	name = "blank rocket"
	desc = "This rocket left intentionally blank."
	projectile_type = "/obj/item/projectile/rocket/blank"
	icon_state = "rpground_blank"
	starting_materials = list(MAT_IRON = 50)
	icon_suffix = "blank"

/obj/item/ammo_casing/rocket_rpg/emp
	name = "EMP rocket"
	desc = "EMP rocket for the Nanotrasen rocket launcher."
	icon_state = "rpground_emp"
	projectile_type = "/obj/item/projectile/rocket/blank/emp"
	starting_materials = list(MAT_IRON = 10000, MAT_URANIUM = 250)
	icon_suffix = "emp"

/obj/item/ammo_casing/rocket_rpg/stun
	name = "stun rocket"
	desc = "Stun rocket for the Nanotrasen rocket launcher. Not a flashbang."
	icon_state = "rpground_stun"
	projectile_type = "/obj/item/projectile/rocket/blank/stun"
	starting_materials = list(MAT_IRON = 25000, MAT_SILVER = 500)
	icon_suffix = "stun"

/obj/item/ammo_casing/rocket_rpg/extreme
	name = "extreme rocket" //don't even map or spawn this in or you'll be very sad
	desc = "Extreme-yield rocket. Fire from very very far away."
	icon_state = "rpground_extreme"
	projectile_type = "/obj/item/projectile/rocket/lowyield/extreme"
	icon_suffix = "extreme"

//clown missiles///////////////

/obj/item/ammo_casing/rocket_rpg/mouse
	name = "mouse missile"
	desc = "It's like a mouse utopia experiment, but said utopia happens to be inside of a rocket propelled explosive warhead."
	projectile_type = "/obj/item/projectile/rocket/clown/mouse"
	icon_state = "rpground_mouse"
	icon_suffix = "mouse"

/obj/item/ammo_casing/rocket_rpg/pizza
	name = "pizza-delivering strike missile"
	desc = "Covers the target in pizza slices upon exploding. Your answer for all those unpleasant customers."
	projectile_type = "/obj/item/projectile/rocket/clown/pizza"
	icon_state = "rpground_pizza"
	icon_suffix = "pizza"

/obj/item/ammo_casing/rocket_rpg/pie
	name = "armor pie-rcing missile"
	desc = "No amount of armor can protect the target from having a pie thrown into their face."
	projectile_type = "/obj/item/projectile/rocket/clown/pie"
	icon_state = "rpground_pie"
	icon_suffix = "pie"

/obj/item/ammo_casing/rocket_rpg/cow
	name = "cluster-cow missile"
	desc = "Inspired by the legendary cow launcher, this explosive missile releases a cluster of cows on explosion. The beef industry would do anything to get its hands on one of these."
	projectile_type = "/obj/item/projectile/rocket/clown/cow"
	icon_state = "rpground_cow"
	icon_suffix = "cow"

/obj/item/ammo_casing/rocket_rpg/goblin
	name = "clown goblin rocket"
	desc = "If you put your ear real close to it you can hear thousands of little honks coming from inside. Not much is know about this rocket except that it was literally created by demons to torture mankind."
	projectile_type = "/obj/item/projectile/rocket/clown/goblin"
	icon_state = "rpground_clowngoblin"
	icon_suffix = "goblin"

/obj/item/ammo_casing/rocket_rpg/cluwne
	name = "cluwnzerfaust"
	desc = "NT doesn't want you to know about this..."
	projectile_type = "/obj/item/projectile/rocket/clown/transmog/cluwne"
	icon_state = "rpground_clowngoblin"
	icon_suffix = "goblin"