//Breakable items

//TODO:
//multiples of a single fragment
//add damaged text into the general examine proc
//check slimes
//add thrown response
//projectiles?
//kicking and biting?
//change "hit" to something else?
//hit sounds
//punching hurting hands and stuff?
//use kicking code
//generalize out of devices

/obj/item/device

	//Destructability parameters:
	var/breakable = 0 //1: breakable (by smashing it using the following flags
	var/breakable_flags = 0 /*possible flags include BREAKABLE_ALL | BREAKABLE_HIT | BREAKABLE_HIT_EMPTY | BREAKABLE_HIT_WEAPON | BREAKABLE_THROW
							BREAKABLE_HIT encompasses both BREAKABLE_HIT_EMPTY and BREAKABLE_HIT_WEAPON */
	var/struct_integ = 15 //structural integrity of the item, akin to HP.
	var/struct_integ_max = 15
	var/damage_armor = 5 //attacks of this much damage or below will glance off
	var/damage_resist = 5 //attacks stronger than damage_armor will have their damage reduced by this much
	var/damaged_text = "" //Addendum to the description when it's damaged eg. damaged_text of "It is dented." Empty string "" will skip this addendum.
	var/breaks_text = "" //Visible message when the items breaks. eg. "breaks apart" Empty string skips this.
	var/breaks_sound = "" //path to audible sound when the item breaks. Empty string skips this.
	var/list/breakable_fragments = list() //List of objects that will be produced when the item is broken apart. eg. /obj/weapon/item/shard

/obj/item/device/proc/on_broken() //Called right before an object breaks
	if(breaks_text!="")
		visible_message("<span class='notice'>\The [src] [breaks_text]!</span>")
	if(breaks_sound!="")
		playsound(src, breaks_sound, 50, 1)
	if(breakable_fragments.len)
		drop_fragments()

/obj/item/device/proc/drop_fragments() //Separate proc in case special stuff happens with a given item's fragments
	if(breakable_fragments.len)
		for(var/i in 1 to breakable_fragments.len)
			var/obj/item/thisfragment=breakable_fragments[i]
			new thisfragment(get_turf(src))

/obj/item/device/proc/receive_damage(var/incoming_damage)
	var/thisdmg=(incoming_damage>max(damage_armor,damage_resist)) * (incoming_damage-damage_resist) //damage is 0 if the incoming damage is less than either damage_armor or damage_resist, to prevent negative damage by weak attacks
	struct_integ-=thisdmg
	if(struct_integ<=0)
		on_broken()
		qdel(src)
	if(!thisdmg)
		return 0 //return 0 if the item took no damage (glancing attack)
	else
		return 1 //return 1 if the item took damage

/////////////////////


//Breaking items:

//Aliens
/obj/item/device/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(user.a_intent == I_HURT && breakable && breakable_flags | BREAKABLE_HIT_EMPTY)
		user.do_attack_animation(src, user)
		user.delayNextAttack(10)
		receive_damage(user.get_unarmed_damage()) ? user.visible_message("<span class='warning'>\The [user] [pick("slashes","claws")] \the [src]!</span>","<span class='notice'>You [pick("slash","claw")] \the [src]!</span>") : user.visible_message("<span class='warning'>\The [user] [pick("slash","claw")] \the [src], but it [pick("bounces","gleams","glances")] off!</span>","<span class='notice'>You hit \the [src], but it [pick("bounces","gleams","glances")] off!</span>")
	else
		..()

//Simple animals
/obj/item/device/attack_animal(mob/living/simple_animal/M)
	if(M.melee_damage_upper && M.a_intent == I_HURT && breakable && breakable_flags | BREAKABLE_HIT_EMPTY)
		M.do_attack_animation(src, M)
		M.delayNextAttack(10)
		receive_damage(rand(M.melee_damage_lower,M.melee_damage_upper)) ? M.visible_message("<span class='warning'>\The [M] [M.attacktext] \the [src]!</span>","<span class='notice'>You hit \the [src]!</span>") : M.visible_message("<span class='warning'>\The [M] [M.attacktext] \the [src], but it [pick("bounces","gleams","glances")] off!</span>","<span class='notice'>You hit \the [src], but it [pick("bounces","gleams","glances")] off!</span>")
	else
		..()

//Empty-handed attacks
/obj/item/device/attack_hand(mob/living/carbon/human/user)
	if(isobserver(user) || !Adjacent(user))
		return
	if(user.a_intent == I_HURT && breakable && breakable_flags | BREAKABLE_HIT_EMPTY)
		user.do_attack_animation(src, user)
		user.delayNextAttack(10)
		add_fingerprint(user)
		receive_damage(user.get_unarmed_damage()) ? user.visible_message("<span class='warning'>\The [user] [user.species.attack_verb] \the [src]!</span>","<span class='notice'>You hit \the [src]!</span>") : user.visible_message("<span class='warning'>\The [user] [user.species.attack_verb] \the [src], but it [pick("bounces","gleams","glances")] off!</span>","<span class='notice'>You hit \the [src], but it [pick("bounces","gleams","glances")] off!</span>")
	else
		..()


//Attacks with a wielded weapon
/obj/item/device/attackby(obj/item/weapon/W, mob/user)
	if(isobserver(user) || !Adjacent(user) || user.is_in_modules(src))
		return
	if(user.a_intent == I_HURT && breakable && breakable_flags | BREAKABLE_HIT_WEAPON)
		user.do_attack_animation(src, W)
		user.delayNextAttack(10)
		add_fingerprint(user)
		receive_damage(W.force) ? user.visible_message("<span class='warning'>\The [user] [pick(W.attack_verb)] \the [src] with \the [W]!</span>","<span class='notice'>You hit \the [src] with \the [W]!<span>") : user.visible_message("<span class='warning'>\The [user] [pick(W.attack_verb)] \the [src] with \the [W], but it [pick("bounces","gleams","glances")] off!</span>","<span class='notice'>You hit \the [src] with \the [W], but it [pick("bounces","gleams","glances")] off!<span>")
	else
		..()

//Being thrown and hitting something
//todo

//Kicks
//todo

//Bites
//todo


/////////////////////


/////////////////////
//Testing flashlight
/obj/item/device/flashlight/test
	name = "breakable flashlight"
	desc = "This flashlight looks particularly flimsy."
	breakable = 1
	breakable_flags = BREAKABLE_HIT
	struct_integ = 30
	damaged_text = "It has gone bad."
	breaks_text = "crumbles apart"
	breaks_sound = 'sound/misc/balloon_pop.ogg'
	breakable_fragments = list(/obj/item/weapon/shard, /obj/item/weapon/reagent_containers/food/snacks/hotdog, /obj/item/weapon/reagent_containers/food/snacks/hotdog)
/////////////////////