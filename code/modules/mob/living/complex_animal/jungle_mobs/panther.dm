/mob/living/complex_animal/panther
	name="Panther"
	desc="That's a big kitty!"
	icon_state="panther"
	icon_living = "panther"
	icon_dead = "panther_dead"
	size=SIZE_BIG
	health=40
	maxHealth=40
	armor=list(melee=15,bullet=10,laser=0,energy=0,bomb=0,bio=0,rad=0)
	max_food=100
	food_flags = ANIMAL_CARNIVORE
	base_damage = 30
	damage_variance = 8
	behavior_flags = ANIMAL_BEHAVIOR_PREDATORY | ANIMAL_BEHAVIOR_TERRITORIAL | ANIMAL_BEHAVIOR_RETALIATE | ANIMAL_BEHAVIOR_AVOID_CAPTURE
	movespeed=2
	petable=TRUE
	var/list/mob/affinity_list=list() // stores people we like.


/mob/living/complex_animal/panther/get_idle_sounds()
	if(prob(20))
		var/i=rand(1,3)
		switch(i)
			if(1)
				emote("me", MESSAGE_HEAR, "meows")
			if(2)
				emote("me", MESSAGE_HEAR, "purrs")
			if(3)
				emote("me", MESSAGE_HEAR, "hisses")

/mob/living/complex_animal/panther/get_attack_msg(var/individual)
	var/i=rand(1,3)
	switch(i)
		if(1)
			emote("me", MESSAGE_SEE, "bites \the [individual].")
		if(2)
			emote("me", MESSAGE_SEE, "swipes at \the [individual].")
		if(3)
			emote("me", MESSAGE_SEE, "claws \the [individual].")

/mob/living/complex_animal/panther/is_kin(var/mob/target)
	if(istype(target,/mob/living/simple_animal/cat) && !istype(target,/mob/living/simple_animal/cat/snek))
		return TRUE
	return ..()


/mob/living/complex_animal/panther/aggro_drawn(var/victim,var/state=ANIMAL_STATE_ATTACKING)
	playsound(loc, 'sound/voice/cathiss.ogg', 50, 1)
	emote("me", EMOTE_AUDIBLE, "hisses.")
	if(state==ANIMAL_STATE_ATTACKING && istype(victim,/mob))
		modify_affinity(victim,-1.0)
	..()

/mob/living/complex_animal/panther/trypet(mob/living/carbon/human/M)
	..()
	emote("me", MESSAGE_SEE, "purrs")
	playsound(loc, 'sound/voice/catpurr.ogg', 50, 1)
	modify_affinity(M,0.5)

/mob/living/complex_animal/panther/tryeat(var/victim)
	if(istype(target,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/F=target
		if(F.fingerprintslast)
			modify_affinity(get_mob_by_key(F.fingerprintslast),4.5)
	..()

//you can tame the kitty :)
/mob/living/complex_animal/panther/proc/modify_affinity(var/mob/M,var/affinity_change)
	if(!M)
		return
	if(!affinity_list[M])
		affinity_list[M]=0
	affinity_list[M]+=affinity_change
	var/aff=affinity_list[M]
	if(aff>10 && !(M in family) )
		to_chat(M,"<span class='notice'>\the [src] looks like it warmed up to you!</span>")
		family+=M
	if(aff<0 && (M in family))
		to_chat(M,"<span class='notice'>\the [src] looks at you with contempt.</span>")
		family-=M


