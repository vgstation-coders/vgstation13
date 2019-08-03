/obj/item/weapon/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	hitsound = "sound/weapons/whip.ogg"
	force = 3.0
	throwforce = 10.0
	throw_speed = 5
	throw_range = 3
	w_class = W_CLASS_MEDIUM
	flags = FPRINT
	attack_verb = list("mops", "bashes", "bludgeons", "whacks", "slaps", "whips")

/obj/item/weapon/mop/New()
	. = ..()
	create_reagents(50)
	mop_list.Add(src)

/obj/item/weapon/mop/Destroy()
	mop_list.Remove(src)
	..()

/obj/item/weapon/mop/proc/clean(turf/simulated/A as turf)
	for(var/obj/effect/O in A)
		if(iscleanaway(O))
			qdel(O)
	reagents.reaction(A,1,10) //Mops magically make chems ten times more efficient than usual, aka equivalent of 50 units of whatever you're using
	A.clean_blood()
	playsound(src, get_sfx("mop"), 25, 1)

/obj/effect/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/mop))
		return
	..()

/obj/item/weapon/mop/afterattack(atom/A, mob/user as mob)
	if(!user.Adjacent(A))
		return
	if(A.mop_act(src, user))
		return
	if(istype(A, /mob/living))
		if(!(reagents.total_volume < 1)) //Slap slap slap
			A.visible_message("<span class='danger'>[user] covers [A] in the mop's contents</span>")
			reagents.reaction(A,1,10) //I hope you like my polyacid cleaner mix
			reagents.clear_reagents()

	if(istype(A, /turf/simulated) || iscleanaway(A))
		if(reagents.total_volume < 1)
			to_chat(user, "<span class='notice'>Your mop is dry!</span>")
			return
		user.visible_message("<span class='warning'>[user] cleans \the [get_turf(A)].</span>", "<span class='notice'>You clean \the [get_turf(A)].</span>")
		user.delayNextAttack(10)
		clean(get_turf(A))
		reagents.remove_any(1) //Might be a tad wonky with "special mop mixes", but fuck it
