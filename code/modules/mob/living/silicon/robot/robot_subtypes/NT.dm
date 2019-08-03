//Combat module debug subtype.
/mob/living/silicon/robot/debug_droideka
	cell_type = /obj/item/weapon/cell/hyper
	startup_sound = 'sound/mecha/nominalnano.ogg'
	startup_vary = FALSE

/mob/living/silicon/robot/debug_droideka/New()
	..()
	UnlinkSelf()
	laws = new /datum/ai_laws/ntmov()
	pick_module(COMBAT_MODULE)
	set_module_sprites(list("Droid" = "droid-combat"))
	install_upgrade(src, /obj/item/borg/upgrade/vtec)