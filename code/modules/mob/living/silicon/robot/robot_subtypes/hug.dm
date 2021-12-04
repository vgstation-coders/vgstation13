//Moving hugborgs to an easy-to-spawn subtype because they were as retarded as the syndie one.
//Be sure to update the vars if you ever add even more weird AI link stuff.
/mob/living/silicon/robot/hugborg
	cell_type = /obj/item/weapon/cell/super
	lawupdate = FALSE
	AIlink = FALSE
	scrambledcodes = TRUE

/mob/living/silicon/robot/hugborg/New()
	..()
	laws = new /datum/ai_laws/asimov()
	pick_module(HUG_MODULE)
	set_module_sprites(list("Peacekeeper" = "peaceborg"))

/mob/living/silicon/robot/hugborg/clown/New()
	..()
	install_upgrade(src, /obj/item/borg/upgrade/honk)

/mob/living/silicon/robot/hugborg/noir/New()
	..()
	laws = new /datum/ai_laws/noir()
	install_upgrade(src, /obj/item/borg/upgrade/noir)

/mob/living/silicon/robot/hugborg/warden/New()
	..()
	laws = new /datum/ai_laws/robocop() //I. AM. THE. LAW.
	install_upgrade(src, /obj/item/borg/upgrade/warden)

/mob/living/silicon/robot/hugborg/hos/New()
	..()
	laws = new /datum/ai_laws/ntmov()
	install_upgrade(src, /obj/item/borg/upgrade/noir)
	install_upgrade(src, /obj/item/borg/upgrade/warden)
	install_upgrade(src, /obj/item/borg/upgrade/hos)

/mob/living/silicon/robot/hugborg/ball/New()
	..()
	set_module_sprites(list("Omoikane" = "omoikane"))