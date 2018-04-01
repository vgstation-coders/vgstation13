/datum/martial_art/mushpunch
	name = "Mushroom Punch"

/datum/martial_art/mushpunch/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/atk_verb
	to_chat(A, "<span class='spider'>You begin to wind up an attack...</span>")
	if(!do_after(A, 25, target = D))
		to_chat(A, "<span class='spider'><b>Your attack was interrupted!</b></span>")
		return TRUE //martial art code was a mistake
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	atk_verb = pick("punches", "smashes", "ruptures", "cracks")
	D.visible_message("<span class='danger'>[A] [atk_verb] [D] with inhuman strength, sending [D.p_them()] flying backwards!</span>", \
					  "<span class='userdanger'>[A] [atk_verb] you with inhuman strength, sending you flying backwards!</span>")
	D.apply_damage(rand(15,30), BRUTE)
	playsound(D, 'sound/effects/meteorimpact.ogg', 25, 1, -1)
	var/throwtarget = get_edge_target_turf(A, get_dir(A, get_step_away(D, A)))
	D.throw_at(throwtarget, 4, 2, A)//So stuff gets tossed around at the same time.
	D.Knockdown(20)
	if(atk_verb)
		add_logs(A, D, "[atk_verb] (Mushroom Punch)")
	return TRUE

/obj/item/mushpunch
	name = "odd mushroom"
	desc = "<I>Sapienza Ophioglossoides</I>:An odd mushroom from the flesh of a mushroom person. it has apparently retained some innate power of it's owner, as it quivers with barely-contained POWER!"
	icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	icon_state = "mycelium-angel"

/obj/item/mushpunch/attack_self(mob/living/carbon/human/user)
	if(!istype(user) || !user)
		return
	var/message = "<span class='spider'>You devour [src], and a confluence of skill and power from the mushroom enhances your punches! You do need a short moment to charge these powerful punches.</span>"
	to_chat(user, message)
	var/datum/martial_art/mushpunch/mush = new(null)
	mush.teach(user)
	qdel(src)
	visible_message("<span class='warning'>[user] devours [src].</span>")
