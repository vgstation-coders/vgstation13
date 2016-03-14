/obj/item/weapon/gun/projectile/detective
	desc = "A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38-Special rounds."
	name = "revolver"
	icon_state = "detective"
	max_shells = 6
	caliber = list("38" = 1, "357" = 1)
	origin_tech = "combat=2;materials=2"
	ammo_type = "/obj/item/ammo_casing/c38"
	var/perfect = 0

	special_check(var/mob/living/carbon/human/M) //to see if the gun fires 357 rounds safely. A non-modified revolver randomly blows up
		if(getAmmo()) //this is a good check, I like this check
			var/obj/item/ammo_casing/AC = loaded[1]
			if(caliber["38"] == 0) //if it's been modified, this is true
				return 1
			if(istype(AC, /obj/item/ammo_casing/a357) && !perfect && prob(70 - (getAmmo() * 10)))	//minimum probability of 10, maximum of 60
				to_chat(M, "<span class='danger'>[src] blows up in your face.</span>")
				M.take_organ_damage(0,20)
				M.drop_item(src, force_drop = 1)
				qdel(src)
				return 0
		return 1

	verb/rename_gun()
		set name = "Name Gun"
		set category = "Object"
		set desc = "Click to rename your gun. If you're the detective."

		var/mob/M = usr
		if(!M.mind)	return 0
		if(!M.mind.assigned_role == "Detective")
			to_chat(M, "<span class='notice'>You don't feel cool enough to name this gun, chump.</span>")
			return 0

		var/input = stripped_input(usr,"What do you want to name the gun?", ,"", MAX_NAME_LEN)

		if(src && input && !M.stat && in_range(src,M))
			name = input
			to_chat(M, "You name the gun [input]. Say hello to your new friend.")
			return 1

	attackby(var/obj/item/A as obj, mob/user as mob)
		..()
		if(isscrewdriver(A) || istype(A, /obj/item/weapon/conversion_kit))
			var/obj/item/weapon/conversion_kit/CK
			if(istype(A, /obj/item/weapon/conversion_kit))
				CK = A
				if(!CK.open)
					to_chat(user, "<span class='notice'>This [CK.name] is useless unless you open it first. </span>")
					return
			if(caliber["38"])
				to_chat(user, "<span class='notice'>You begin to reinforce the barrel of [src].</span>")
				if(getAmmo())
					afterattack(user, user)	//you know the drill
					playsound(user, fire_sound, 50, 1)
					user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='danger'>[src] goes off in your face!</span>")
					return
				if(do_after(user, src, 30))
					if(getAmmo())
						to_chat(user, "<span class='notice'>You can't modify it!</span>")
						return
					caliber["38"] = 0
					desc = "The barrel and chamber assembly seems to have been modified."
					to_chat(user, "<span class='warning'>You reinforce the barrel of [src]! Now it will fire .357 rounds.</span>")
					if(CK && istype(CK))
						perfect = 1
			else
				to_chat(user, "<span class='notice'>You begin to revert the modifications to [src].</span>")
				if(getAmmo())
					afterattack(user, user)	//and again
					playsound(user, fire_sound, 50, 1)
					user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='danger'>[src] goes off in your face!</span>")
					return
				if(do_after(user, src, 30))
					if(getAmmo())
						to_chat(user, "<span class='notice'>You can't modify it!</span>")
						return
					caliber["38"] = 1
					desc = initial(desc)
					to_chat(user, "<span class='warning'>You remove the modifications on [src]! Now it will fire .38 rounds.</span>")
					perfect = 0





