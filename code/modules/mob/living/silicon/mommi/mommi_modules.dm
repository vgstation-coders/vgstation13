/obj/item/weapon/robot_module/mommi
	name = "mobile mmi robot module"


	New()
		src.modules += new /obj/item/borg/sight/meson(src)
		src.emag = new /obj/item/borg/stun(src)
		//src.modules += new /obj/item/weapon/rcd/borg(src)     // Too OP
		//src.modules += new /obj/item/device/flashlight(src)   // Broken
		src.modules += new /obj/item/weapon/weldingtool/largetank(src)
		src.modules += new /obj/item/weapon/screwdriver(src)
		src.modules += new /obj/item/weapon/wrench(src)
		src.modules += new /obj/item/weapon/crowbar(src)
		src.modules += new /obj/item/weapon/wirecutters(src)
		src.modules += new /obj/item/device/multitool(src)
		src.modules += new /obj/item/device/t_scanner(src)
		src.modules += new /obj/item/device/analyzer(src)
		src.modules += new /obj/item/weapon/extinguisher(src) // Aurx sed so
		src.modules += new /obj/item/weapon/pipe_dispenser(src)

		// Added this back in since it made the MoMMI practically useless for engineering stuff.
		var/obj/item/stack/sheet/metal/cyborg/M = new /obj/item/stack/sheet/metal/cyborg(src)
		M.amount = 50
		src.modules += M
/* BIG
		var/obj/item/stack/sheet/rglass/cyborg/G = new /obj/item/stack/sheet/rglass/cyborg(src)
		G.amount = 50
		src.modules += G
*/
		// Aurx also sed so
		var/obj/item/stack/sheet/glass/cyborg/G = new /obj/item/stack/sheet/glass/cyborg(src)
		G.amount = 50
		src.modules += G

		var/obj/item/weapon/cable_coil/W = new /obj/item/weapon/cable_coil(src)
		W.amount = 50
		W.max_amount = 50 // Override MAXCOIL
		src.modules += W
		return
	respawn_consumable(var/mob/living/silicon/robot/R)
		var/list/what = list (
			/obj/item/stack/sheet/metal/cyborg,
			/obj/item/stack/sheet/glass,
			/obj/item/weapon/cable_coil,
		)
		for (var/T in what)
			if (!(locate(T) in src.modules))
				src.modules -= null
				var/O = new T(src)
				if(istype(O,/obj/item/weapon/cable_coil))
					O:max_amount = 50
				src.modules += O
				O:amount = 1
		return