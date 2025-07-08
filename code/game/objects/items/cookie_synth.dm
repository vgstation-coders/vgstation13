/obj/item/weapon/cookiesynth
	name = "cookie synthesizer"
	desc = "A self-recharging device used to rapidly deploy cookies."
	icon = 'icons/obj/RCD.dmi'
	icon_state = "synth_cookie"
	var/food_type = /obj/item/weapon/reagent_containers/food/snacks/cookie
	var/toxin = FALSE
	var/toxin_type = CHLORALHYDRATE
	var/toxin_amount = 10
	var/sound_type = 'sound/machines/click.ogg'
	var/cooldown = 0
	var/delay = 15 SECONDS
	w_class = W_CLASS_MEDIUM

/obj/item/weapon/cookiesynth/emag_act(mob/user)
	emagged = !emagged
	spark(src)

/obj/item/weapon/cookiesynth/attack_self(mob/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(R.emagged)
			toggle_toxins(user)
	if(emagged)
		toggle_toxins(user)

/obj/item/weapon/cookiesynth/AltClick()
	if(loc == usr)
		synthesize(src, usr, TRUE, TRUE)

/obj/item/weapon/cookiesynth/proc/toggle_toxins(mob/user)
	toxin = !toxin
	to_chat(user,"<span class='warning'>You [toxin ? "dis" : "en"]able the [src]'s reagent safety checker!</span>")

/obj/item/weapon/cookiesynth/afterattack(atom/A, mob/user, proximity)
	synthesize(A, user, proximity)

/obj/item/weapon/cookiesynth/proc/synthesize(atom/A, mob/user, proximity, put_in_hands = FALSE)
	if(!proximity)
		return
	var/turf/T = get_turf(A)
	if(T.density)
		return
	if(!(istype(A, /obj/structure/table) || isturf(A) || put_in_hands)) //if it's a table, a turf, or it's being activated via AltClick()
		return
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell || R.cell.charge < 400)
			to_chat(user,"<span class='warning'>You do not have enough power to use [src].</span>")
			return
	if(cooldown > world.time)
		to_chat(user,"<span class='info'>[src] is still recharging.</span>")
		return
	playsound(src.loc, sound_type, 10, 1)
	var/obj/item/weapon/reagent_containers/food/S = new food_type(T)
	if(put_in_hands)
		user.put_in_hands(S)
	to_chat(user,"<span class='info'>Fabricating [lowertext(S.name)]..")
	if(toxin)
		S.reagents.add_reagent(toxin_type, toxin_amount)
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		R.cell.charge -= 100
	cooldown = world.time + delay
	return S

//TODO: Give hugborgs their own custom RSF instead of this snoflakey mess.

/obj/item/weapon/cookiesynth/proc/Honkize()
	name = "banana synthesizer"
	desc = "A self-recharging device used to rapidly deploy bananas."
	food_type = /obj/item/weapon/reagent_containers/food/snacks/grown/banana
	toxin_type = SPIRITBREAKER

/obj/item/weapon/cookiesynth/proc/Lawize()
	name = "donut synthesizer"
	desc = "A self-recharging device used to rapidly deploy donuts."
	food_type = /obj/item/weapon/reagent_containers/food/snacks/donut/normal
	toxin_type = CHEESYGLOOP

/obj/item/weapon/cookiesynth/proc/Noirize()
	name = "joe synthesizer"
	desc = "A self-recharging device used to rapidly deploy bitter, black, and tasteless coffee."
	food_type = /obj/item/weapon/reagent_containers/food/drinks/mug/joe
	toxin_type = HEMOSCYANINE

/obj/item/weapon/reagent_containers/food/drinks/mug/joe/New()
	..()
	reagents.add_reagent(DETCOFFEE, 20)

/obj/item/weapon/cookiesynth/lollipop
	name = "medipop synthesizer"
	desc = "A self-recharging device used to rapidly deploy medicinal lollipops. Tell your patient they were very brave today."
	icon_state = "synth_medi"
	food_type = /obj/item/weapon/reagent_containers/food/snacks/lollipop/medipop

/obj/item/weapon/cookiesynth/lollicheap
	name = "cheap medipop synthesizer"
	desc = "A self-recharging device used to rapidly deploy ordinary, non-medicinal lollipops. Tell your patient they were very brave today."
	icon_state = "synth_medi"
	food_type = /obj/item/weapon/reagent_containers/food/snacks/lollipop/lollicheap
