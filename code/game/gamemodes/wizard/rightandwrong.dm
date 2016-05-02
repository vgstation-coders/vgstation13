

/mob/proc/rightandwrong(var/summon_type) //0 = Summon Guns, 1 = Summon Magic
	to_chat(usr, "<B>You summoned [summon_type ? "magic" : "guns"]!</B>")
	message_admins("[key_name_admin(usr, 1)] summoned [summon_type ? "magic" : "guns"]!")
	log_game("[key_name(usr)] summoned [summon_type ? "magic" : "guns"]!")
	for(var/mob/living/carbon/human/H in player_list)
		if(H.stat == DEAD || !(H.client)) continue
		if(is_special_character(H)) continue
		if(prob(35) && !(H.mind in ticker.mode.traitors))
			ticker.mode.traitors += H.mind
			H.mind.special_role = "traitor"
			var/datum/objective/survive/survive = new
			survive.owner = H.mind
			H.mind.objectives += survive
			H.attack_log += "\[[time_stamp()]\] <font color='red'>Was made into a survivor, and trusts no one!</font>"
			to_chat(H, "<B>You are the survivor! Your own safety matters above all else, trust no one and kill anyone who gets in your way. However, armed as you are, now would be the perfect time to settle that score or grab that pair of yellow gloves you've been eyeing...</B>")
			var/obj_count = 1
			for(var/datum/objective/OBJ in H.mind.objectives)
				to_chat(H, "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]")
				obj_count++
		var/randomizeguns = pick("taser","egun","laser","revolver","detective","smg","nuclear","deagle","gyrojet","pulse","silenced","cannon","doublebarrel","shotgun","combatshotgun","mateba","smg","uzi","crossbow","saw","hecate","osipr","gatling","bison","ricochet","spur","nagant","beegun")
		var/randomizemagic = pick("fireball","smoke","blind","mindswap","forcewall","knock","horsemask","charge","wandnothing", "wanddeath", "wandresurrection", "wandpolymorph", "wandteleport", "wanddoor", "wandfireball", "staffchange", "staffhealing", "armor", "scrying")
		if(!summon_type)
			switch (randomizeguns)
				if("taser")
					new /obj/item/weapon/gun/energy/taser(get_turf(H))
				if("egun")
					new /obj/item/weapon/gun/energy/gun(get_turf(H))
				if("laser")
					new /obj/item/weapon/gun/energy/laser(get_turf(H))
				if("revolver")
					new /obj/item/weapon/gun/projectile(get_turf(H))
				if("detective")
					new /obj/item/weapon/gun/projectile/detective(get_turf(H))
				if("smg")
					new /obj/item/weapon/gun/projectile/automatic/c20r(get_turf(H))
				if("nuclear")
					new /obj/item/weapon/gun/energy/gun/nuclear(get_turf(H))
				if("deagle")
					new /obj/item/weapon/gun/projectile/deagle/camo(get_turf(H))
				if("gyrojet")
					new /obj/item/weapon/gun/projectile/gyropistol(get_turf(H))
				if("pulse")
					new /obj/item/weapon/gun/energy/pulse_rifle(get_turf(H))
				if("silenced")
					new /obj/item/weapon/gun/projectile/pistol(get_turf(H))
					new /obj/item/gun_part/silencer(get_turf(H))
				if("cannon")
					new /obj/item/weapon/gun/energy/lasercannon(get_turf(H))
				if("doublebarrel")
					new /obj/item/weapon/gun/projectile/shotgun/pump/(get_turf(H))
				if("shotgun")
					new /obj/item/weapon/gun/projectile/shotgun/pump/(get_turf(H))
				if("combatshotgun")
					new /obj/item/weapon/gun/projectile/shotgun/pump/combat(get_turf(H))
				if("mateba")
					new /obj/item/weapon/gun/projectile/mateba(get_turf(H))
				if("smg")
					new /obj/item/weapon/gun/projectile/automatic(get_turf(H))
				if("uzi")
					new /obj/item/weapon/gun/projectile/automatic/mini_uzi(get_turf(H))
				if("crossbow")
					new /obj/item/weapon/gun/energy/crossbow(get_turf(H))
				if("saw")
					new /obj/item/weapon/gun/projectile/automatic/l6_saw(get_turf(H))
				if("hecate")
					new /obj/item/weapon/gun/projectile/hecate(get_turf(H))
					new /obj/item/ammo_casing/BMG50(get_turf(H))//can't give a full box of such deadly bullets. 3 shots is plenty.
					new /obj/item/ammo_casing/BMG50(get_turf(H))
				if("osipr")
					new /obj/item/weapon/gun/osipr(get_turf(H))
				if("gatling")
					new /obj/item/weapon/gun/gatling(get_turf(H))
				if("bison")
					new /obj/item/weapon/gun/energy/bison(get_turf(H))
				if("ricochet")
					new /obj/item/weapon/gun/energy/ricochet(get_turf(H))
				if("spur")
					new /obj/item/weapon/gun/energy/polarstar(get_turf(H))
					new /obj/item/device/modkit/spur_parts(get_turf(H))
				if("nagant")
					new /obj/item/weapon/gun/projectile/nagant(get_turf(H))
				if("beegun")
					new /obj/item/weapon/gun/gatling/beegun(get_turf(H))
			playsound(get_turf(H),'sound/effects/summon_guns.ogg', 50, 1)
		else
			switch (randomizemagic)
				if("fireball")
					new /obj/item/weapon/spellbook/oneuse/fireball(get_turf(H))
				if("smoke")
					new /obj/item/weapon/spellbook/oneuse/smoke(get_turf(H))
				if("blind")
					new /obj/item/weapon/spellbook/oneuse/blind(get_turf(H))
				if("mindswap")
					new /obj/item/weapon/spellbook/oneuse/mindswap(get_turf(H))
				if("forcewall")
					new /obj/item/weapon/spellbook/oneuse/forcewall(get_turf(H))
				if("knock")
					new /obj/item/weapon/spellbook/oneuse/knock(get_turf(H))
				if("horsemask")
					new /obj/item/weapon/spellbook/oneuse/horsemask(get_turf(H))
				if("charge")
					new /obj/item/weapon/spellbook/oneuse/charge(get_turf(H))
				/* TODO: Port /tg/ guncode.
				if("wandnothing")
					new /obj/item/weapon/gun/magic/wand(get_turf(H))
				if("wanddeath")
					new /obj/item/weapon/gun/magic/wand/death(get_turf(H))
				if("wandresurrection")
					new /obj/item/weapon/gun/magic/wand/resurrection(get_turf(H))
				if("wandpolymorph")
					new /obj/item/weapon/gun/magic/wand/polymorph(get_turf(H))
				if("wandteleport")
					new /obj/item/weapon/gun/magic/wand/teleport(get_turf(H))
				if("wanddoor")
					new /obj/item/weapon/gun/magic/wand/door(get_turf(H))
				if("staffchange")
					new /obj/item/weapon/gun/magic/staff/change(get_turf(H))
				if("staffhealing")
					new /obj/item/weapon/gun/magic/staff/healing(get_turf(H))
				*/
				if("armor")
					new /obj/item/clothing/suit/space/rig/wizard(get_turf(H))
					new /obj/item/clothing/head/helmet/space/rig/wizard(get_turf(H))
				if("scrying")
					new /obj/item/weapon/scrying(get_turf(H))
					if (!(M_XRAY in H.mutations))
						H.mutations.Add(M_XRAY)
						H.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
						H.see_in_dark = 8
						H.see_invisible = SEE_INVISIBLE_LEVEL_TWO
						to_chat(H, "<span class='notice'>The walls suddenly disappear.</span>")
