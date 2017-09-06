/obj/item/weapon/cookiesynth
	name = "cookie synthesizer"
	desc = "A self-recharging device used to rapidly deploy cookies."
	icon = 'icons/obj/RCD.dmi'
	icon_state = "rcd"
	var/matter = 10
	var/toxin = 0
	var/cooldown = 0
	var/cooldowndelay = 15 SECONDS // ONE COOKIE PER SECOND WAS A NO NO, THESE THINGS CAN MAKE FREE SHITTER JUICE WHEN EMAGGED
	var/emagged = 0
	w_class = W_CLASS_MEDIUM

/obj/item/weapon/cookiesynth/New()
	..()
	processing_objects.Add(src)

/obj/item/weapon/cookiesynth/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/weapon/cookiesynth/examine(mob/user)
	..()
	to_chat(user,"<span class='notice'>It currently holds [matter]/10 cookie-units.</span>")

/obj/item/weapon/cookiesynth/attackby(obj/item/weapon/W, mob/user)
	..()
	if(isEmag(W))
		Emag(user)

/obj/item/weapon/cookiesynth/proc/Emag(mob/user)
	emagged = !emagged
	if(emagged)
		to_chat(user,"<span class='warning'>You short out the [src]'s reagent safety checker!</span>")
	else
		to_chat(user,"<span class='warning'>You reset the [src]'s reagent safety checker!</span>")
		toxin = 0

/obj/item/weapon/cookiesynth/attack_self(mob/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(R.emagged)
			toggle_toxins(user)
	if(emagged)
		toggle_toxins(user)

/obj/item/weapon/cookiesynth/proc/toggle_toxins(mob/user)
	toxin = !toxin
	to_chat(user,"Cookie Synthesizer [toxin ? "Hacked" : "Reset"].")

/obj/item/weapon/cookiesynth/process()
	if(matter < 10)
		matter++

/obj/item/weapon/cookiesynth/afterattack(atom/A, mob/user, proximity)
	if(cooldown > world.time)
		return
	if(!proximity)
		return
	if (!(istype(A, /obj/structure/table) || isturf(A)))
		return
	if(matter < 1)
		to_chat(user,"<span class='warning'>The [src] doesn't have enough matter left. Wait for it to recharge!</span>")
		return
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell || R.cell.charge < 400)
			to_chat(user,"<span class='warning'>You do not have enough power to use [src].</span>")
			return
	var/turf/T = get_turf(A)
	playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
	to_chat(user,"Fabricating Cookie..")
	var/obj/item/weapon/reagent_containers/food/snacks/cookie/S = new /obj/item/weapon/reagent_containers/food/snacks/cookie(T)
	if(toxin)
		S.reagents.add_reagent(CHLORALHYDRATE, 10)
	if (isrobot(user))
		var/mob/living/silicon/robot/R = user
		R.cell.charge -= 100
	else
		matter--
	cooldown = world.time + cooldowndelay
