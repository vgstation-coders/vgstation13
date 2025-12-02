#define ANIMAL_BEHAVIOR_PREDATORY	(1<<0)	//if we will attack other mobs
#define ANIMAL_BEHAVIOR_TERRITORIAL	(1<<1)	//if we attack when approached
#define ANIMAL_BEHAVIOR_PACK_DYNAMICS	(1<<2)	//if we stay by others of our kind
#define ANIMAL_BEHAVIOR_AVOID_PRED	(1<<3)	//avoid predatory animals, not counting our own kind, of course.
#define ANIMAL_BEHAVIOR_RETALIATE	(1<<4)	//if we are attacked, we fight back.
#define ANIMAL_BEHAVIOR_DESTRUCTIVE	(1<<5)	//destroy objects in the environment. you'll probably want big bad animals to have this flag (eg, bears)
#define ANIMAL_BEHAVIOR_AVOID_CAPTURE	(1<<6) //try to escape containment (lockers, chairs). also see above.
#define ANIMAL_BEHAVIOR_UNDESIRABLE	(1<<7) //if predators should avoid us for whatever reason. not a hard stance, but it'll tilt the scale. eg, a creature which is poisonous.

#define ANIMAL_HERBIVORE	(1<<0)	//we can eat plants
#define ANIMAL_CARNIVORE	(1<<1)	//we can eat meat. combine with ANIMAL_HERBIVORE for an omnivore. you also need ANIMAL_BEHAVIOR_PREDATORY if you want it to hunt, otherwise it's just an opportunistic carnivore.
#define ANIMAL_FRUGIVORE	(1<<2 ) //fruits (jungle berry bushes). implied with HERBIVORE, but can be used on its own.

#define ANIMAL_FOODPRIORITY_CANNIBAL -5	//she rips out my bones just like i'm an animal
#define ANIMAL_FOODPRIORITY_PRECOOKED 5	//why would you eat a plant when you could eat a tasty donut or burger?
#define ANIMAL_FOODPRIORITY_PLANTS 2	//omnivores prefer not picking a fight. mildly, because we still want some action
#define ANIMAL_FOODPRIORITY_CORPSES 3	//no need to beat a dead horse. we should be eating it instead.
#define ANIMAL_FOODPRIORITY_SIZEDIFF_LARGER -5	//bigger=more dangerous, right?
#define ANIMAL_FOODPRIORITY_SIZEDIFF_SMALLER -2	//prefer bigger meals
#define ANIMAL_FOODPRIORITY_FAMILY -5	//hi ma :)
#define ANIMAL_FOODPRIORITY_UNDESIRABLE -5	//poison... poison... tasty fish!

#define ANIMAL_STATE_IDLE 0	//hanging around.
#define ANIMAL_STATE_HUNTING 1	//when we hongry
#define ANIMAL_STATE_DEFENDING 2	//from territorial
#define ANIMAL_STATE_ATTACKING 3	//from retaliation
#define ANIMAL_STATE_FLEEING 4	//oh SHIT
#define ANIMAL_STATE_MATING 5	//the birds and the birds. why would they try it with a bee? you sicken me.
#define ANIMAL_STATE_SPECIAL 6 //for special behaviors for the mob to do

/mob/living/complex_animal
	size=0
	icon='icons/mob/animal.dmi'
	can_butcher=TRUE
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	var/armor=list(melee=0,bullet=0,laser=0,energy=0,bomb=0,bio=0,rad=0)
	var/behavior_flags=0
	nutrition = 50
	var/max_food = 50
	var/food_per_tick = 0.0005 //how much of max_food should be deducted from food per tick. This number gives us about 4000 seconds until we starve
	var/food_flags = 0
	var/behavior_state = ANIMAL_STATE_IDLE
	var/last_state = -1
	var/ticks_this_state=0
	var/mob_age = 0
	var/mob_max_age = 450 //15 minutes. above this, the mob will start rolling to die of old age.
	var/atom/target = null
	var/turf/territory=null //turf location
	var/list/family = list() //list of mobs. avoid attacking them and whatnot. also can be used for taming.
	var/base_damage=2
	var/damage_variance=1
	var/movespeed=5 //lower=faster.
	var/pacify_aura=FALSE
	var/kin_check_type_path=null //for mobs with many subtypes. set to the parent mob type. leave null if not needed
	var/petable=FALSE
	var/lastmate=0
	var/matingcooldown=60 //2 minutes
	var/max_local_population=6 //to prevent total overpopulation
	var/icon_living = ""
	var/icon_dead = ""
	var/healthregen=0.01
	var/lasthealth=0.0
	var/ticks_dead=0
	
	//these are here because we, for some reason that i don't know, call attack_animal. that sounds good, until you realize that attack_animal wants a simple_animal. this causes a lot of runtimes, and i can't find where attack_animal is actually called, or why it's called when we're not even a simple_animal, so instead, we define some of the important variables here so it doesn't totally break. it's still a good practice to revise the code, as was done with most of the common objects that will be broken, like windows and lockers.
	var/environment_smash_flags = 0xFFFFFF
	var/melee_damage_upper=0
	var/melee_damage_lower=0
	

	
	//cache vars. we use this for extra SPEEEEEED. so you can ignore it for vving stuff.
	var/list/cache_objects_in_view=list()
	

/mob/living/complex_animal/New(var/loc)
	..()
	create_reagents(100)
	nutrition = rand(ceil(max_food*0.75),max_food)
	gender="female"
	if(prob(50))
		gender="male"
	territory=locate(x,y,z) //store turf where we were born/created
	
	melee_damage_upper=base_damage+damage_variance
	melee_damage_lower=base_damage-damage_variance


/mob/living/complex_animal/proc/allow_msg()
	for(var/mob/m in range(src,11)) //only do emotes/say things if a player is nearby. this is to reduce log spam and make obsgang not want to die, even though they should just play the game.
		if(m.client)
			return TRUE
	return FALSE

/mob/living/complex_animal/emote(act, m_type = null, message = null, ignore_status = FALSE, var/arguments)
	if(allow_msg())
		return ..()
	return null
	
/mob/living/complex_animal/say(message, var/datum/language/speaking, var/atom/movable/radio=src, var/class)
	if(allow_msg())
		return ..()
	return null

/mob/living/complex_animal/update_icon()
	..()
	icon_state=icon_living
	if (stat==DEAD)
		icon_state=icon_dead

/mob/living/complex_animal/Life()
	update_icon()
	if(!..())
		return 0
	if(stat == DEAD)
		ticks_dead++
		if(ticks_dead==75)
			visible_message("Bugs start flying around <b>\the [src]</b>'s corpse.")
		if(ticks_dead==150)
			visible_message("<b>\The [src]</b>'s corpse starts to smell...")	
		if(ticks_dead>150) //5 minute delay
			if(prob(10))
				visible_message("<b>\The [src]</b>'s corpse rots away into nothing...")
				qdel(src)
		return 0
	ticks_dead=0
	
	if(last_state!=behavior_state)
		ticks_this_state=0
		last_state=behavior_state
	else
		ticks_this_state++
	
	cache_objects_in_view = view(src,7) //refresh it every life tick.
	
	reagents?.metabolize(src)	
	
	nutrition-=max_food*food_per_tick
	
	lastmate--
	
	if(lasthealth<=health && health<maxHealth)
		health=min(maxHealth,health+maxHealth*healthregen)
		nutrition-=max_food*food_per_tick*0.25 //use extra food when regaining health
	lasthealth=health
	
	if(nutrition<0 && prob(20))
		emote("deathgasp")
		health=0
	if(health<=0 && stat != DEAD)
		death()
		return 0
	if(mob_max_age && mob_age > mob_max_age)
		var/chancetokeelover = (mob_age-mob_max_age)/mob_max_age
		chancetokeelover = 1-(1/(chancetokeelover+1))
		// math formula: 1-\frac{1}{\frac{\left(x-m\right)}{m}+1}
		//basically, the older you are, the more likley you are to die.
		//if you are twice as old as the max age, you have a 50% chance to die.
		//this is ran every tick, by the way, so the probabilities add up.
		chancetokeelover*=0.25 //ok nevermind reduce the chance a bit it happens a bit too fast.
		if(rand() < chancetokeelover)
			emote("deathgasp")
			health=0
			stat=DEAD
			return 0
	mob_age++
	
	escape()

	interrupt_hunger() //prioritize eating over all other things
	interrupt_territory() //next, prioritize defending our home
	interrupt_fear() //then, prioritize saving our own ass.

	switch(behavior_state)
		if(ANIMAL_STATE_IDLE)
			tick_state_idle()
		if(ANIMAL_STATE_HUNTING)
			tick_state_hunting()
		if(ANIMAL_STATE_DEFENDING)
			tick_state_defending()
		if(ANIMAL_STATE_ATTACKING)
			tick_state_attacking()
		if(ANIMAL_STATE_FLEEING)
			tick_state_fleeing()
		if(ANIMAL_STATE_MATING)
			tick_state_mating()
		if(ANIMAL_STATE_SPECIAL)
			tick_state_special()
	return 1

//runs independently of other states so we won't starve to death running away.
/mob/living/complex_animal/proc/interrupt_hunger()
	if(behavior_state==ANIMAL_STATE_HUNTING || behavior_state==ANIMAL_STATE_ATTACKING || behavior_state==ANIMAL_STATE_DEFENDING)
		return FALSE
	if(nutrition<max_food*0.5)
		visible_message("<b>\the [src]</b> looks hungry...")
		abort_target()
		behavior_state=ANIMAL_STATE_HUNTING
		return TRUE

//so we aren't too busy to run from a bear.
/mob/living/complex_animal/proc/interrupt_fear()
	if(behavior_state==ANIMAL_STATE_HUNTING || behavior_state==ANIMAL_STATE_ATTACKING || behavior_state==ANIMAL_STATE_DEFENDING)
		return FALSE
	for(var/mob/living/M in cache_objects_in_view) //check for danger and flee
		if(determine_isthreat(M))
			get_flee_msg(M)
			abort_target()
			target=M
			behavior_state = ANIMAL_STATE_FLEEING
			return TRUE

//defend our /turf before other stuff
/mob/living/complex_animal/proc/interrupt_territory()
	if(behavior_state==ANIMAL_STATE_HUNTING || behavior_state==ANIMAL_STATE_ATTACKING || behavior_state==ANIMAL_STATE_DEFENDING)
		return FALSE
	for(var/mob/living/M in cache_objects_in_view) //if not, check for trespassers
		if(behavior_flags & ANIMAL_BEHAVIOR_TERRITORIAL && get_dist(M,territory)<10 && determine_tresspass(M) )
			get_tesspass_msg(M)
			abort_target()
			behavior_state = ANIMAL_STATE_DEFENDING
			target=M
			return FALSE

//state functions return TRUE if the behavior_state is unchanged, and FALSE if not. basically just do if(..())
/mob/living/complex_animal/proc/tick_state_idle()
	abort_target()
	
	//attempt reproduction only while full
	if(nutrition >= (max_food- get_offspring_cost()*2) && get_offspring_cost() && prob(20) && lastmate<=0)
		behavior_state=ANIMAL_STATE_MATING
		return FALSE
	
	get_idle_sounds()
	
	if(prob(25))//move around randomly sometimes
		if(territory && prob(50))
			walk_to(src,locate(territory.x+rand(-3,3),territory.y+rand(-3,3),territory.z),0,movespeed)
		else
			walk_to(src,locate(x+rand(-3,3),y+rand(-3,3),z),0,movespeed)
	
	if(territory && prob(25)) //randomly move the territory
		if(behavior_flags & ANIMAL_BEHAVIOR_PACK_DYNAMICS) //move our territory closer to pack members
			var/list/mob/living/complex_animal/members=list()
			for(var/mob/living/complex_animal/M in cache_objects_in_view)
				if(is_kin(M))
					members+=M
			if(members.len)
				var/mob/living/complex_animal/M = pick(members) //pick a random member to move territory towards
				var/traversedir = get_dir(territory,M.territory)
				for(var/i=0,i<4,i++) //4 steps ensures that we will overshoot regularly, which adds a bit of random flavor to the pack position
					var/turf/T=get_step(M.territory,traversedir)
					if(T)
						territory =T
		else //just random movment
			territory=locate(territory.x+rand(-4,4),territory.y+rand(-4,4),territory.z)
	
	if(behavior_flags & ANIMAL_BEHAVIOR_TERRITORIAL && !territory) //if we can't find the territory, regenerate it
		territory=locate(x,y,z)
	return TRUE

/mob/living/complex_animal/proc/tick_state_hunting()
	if(nutrition>max_food*0.75)
		abort_target()
		return FALSE
	if(!verify_target(target,20,TRUE) || (ticks_this_state>9 && prob(25)) )
		abort_target(FALSE)
		var/list/possible=rank_foodsources(get_food())
		var/list/pickfrom=list()
		var/highestprio=-999999
		for(var/atom/A in possible) //get the highest ranked objects
			var/rank=possible[A]
			if(rank>highestprio)
				pickfrom=list(A)
				highestprio=rank
			else if(rank==highestprio)
				pickfrom+=A
		if(pickfrom.len)
			target=pick(pickfrom)
		if(highestprio<0 && nutrition>max_food*0.2) //avoid disliked targets, unless we are really desperate for food.
			target=null
		if(highestprio<-4 && nutrition>max_food*0.05) //I NEEEEEEEED IIIIIIIIT
			target=null
		if(!target) //if we can't find a suitable target, move around randomly
			walk_to(src,locate(x+rand(-15,15),y+rand(-15,15),z),0,movespeed)
		else
			get_hunting_msg(target)
			aggro_drawn(target,ANIMAL_STATE_HUNTING,TRUE)
	else
		fuckshitup()
		if(get_dist(src,target)>1)
			walk_to(src,target,0,movespeed)
		else //attack em!
			tryeat(target)
	return TRUE

/mob/living/complex_animal/proc/tick_state_defending()
	if(!verify_target(target))
		abort_target()
		return FALSE
	else
		if(get_dist(territory,target)>10) //if they're far enough from our territory, forget about them
			abort_target()
			return FALSE
		if(get_dist(src,target)>1)
			fuckshitup()
			walk_to(src,target,0,movespeed)
		else //attack em!
			attack(target)
	return TRUE

/mob/living/complex_animal/proc/tick_state_attacking()
	if(!verify_target(target,15))
		abort_target()
		return FALSE
	else
		fuckshitup()
		aggro_drawn(target,ANIMAL_STATE_ATTACKING,TRUE)
		if(get_dist(src,target)>1)
			walk_to(src,target,0,movespeed)
		else //attack em!
			attack(target)
	return TRUE

/mob/living/complex_animal/proc/tick_state_fleeing()
	if(!verify_target(target,10))
		abort_target()
		return FALSE
	else
		fuckshitup()
		walk_away(src,target,10,movespeed)
	return TRUE

/mob/living/complex_animal/proc/tick_state_mating()
	if(!verify_target(target,8))
		for(var/atom/A in cache_objects_in_view)
			if(istype(A,/mob/living/complex_animal))
				var/mob/living/complex_animal/CA=A
				if(can_offspring(CA) && CA.can_offspring(src) && CA.behavior_state==ANIMAL_STATE_MATING && !CA.target) //you better believe we're going to enforce the communicative property.
					visible_message("<b>\the [src]</b> looks lovingly at \the [CA].")
					target=CA
					CA.visible_message("<b>\the [CA]</b> looks lovingly at \the [src].")
					CA.target=src
		if(!target) //if we can't find one, exit back to idle
			abort_target()
			return FALSE
	else
		if(!istype(target,/mob/living/complex_animal)) //something has gone terribly wrong
			abort_target()
			return FALSE
		var/mob/living/complex_animal/M = target
		if(get_dist(src,M)>1)
			walk_to(src,M,0,movespeed)
		else
			if(gender=="female")
				if(generate_offspring(M))
					M.nutrition-=M.get_offspring_cost()
					M.abort_target()
				
					nutrition-=get_offspring_cost()
					abort_target()
					
					M.lastmate=M.matingcooldown
					src.lastmate=src.matingcooldown
					return FALSE
	return TRUE

/mob/living/complex_animal/proc/tick_state_special()
	return TRUE


//checks our target variable and returns if it's valid.
/mob/living/complex_animal/proc/verify_target(var/atom/targ,var/max_distance=-1,var/allow_dead=FALSE)
	if(!targ)
		return FALSE
	if(max_distance>=0)
		if(get_dist(src,targ)>max_distance)
			return FALSE
	if(targ.z!=src.z)
		return FALSE
	if(!allow_dead && istype(targ,/mob/living))
		var/mob/living/M = targ
		if(M.stat==DEAD)
			return FALSE
	return TRUE

/mob/living/complex_animal/proc/abort_target(var/reset_state=TRUE)
	target=null
	walk(src,0)
	if(reset_state)
		behavior_state=ANIMAL_STATE_IDLE

/mob/living/complex_animal/proc/is_kin(var/mob/target)
	if(!istype(target,/mob))
		return FALSE
	if(target in family)
		return TRUE
	if(target.faction == src.faction && src.faction!="neutral")
		return TRUE
	if(kin_check_type_path)
		if(istype(target,kin_check_type_path))
			return TRUE
	else
		if(istype(target,src.type) || istype(src,target.type))
			return TRUE
	return FALSE

//return a list of valid salad
/mob/living/complex_animal/proc/get_food()
	var/list/foodsources=list()
	for(var/atom/A in cache_objects_in_view)
		if(A==src) //do not eat ourselves
			continue
		if(food_flags & ANIMAL_HERBIVORE)
			if(istype(A,/obj/structure/flora) && !istype(A,/obj/structure/flora/tree) && !istype(A,/obj/structure/flora/rock))
				foodsources+=A
				continue
			if(istype(A,/turf/unsimulated/floor/jungle/grass))
				foodsources+=A
				continue
		if(food_flags & ANIMAL_FRUGIVORE)
			if(istype(A,/obj/structure/flora/jungle_berries))
				var/obj/structure/flora/jungle_berries/bush=A
				if(bush.hasberries)
					foodsources+=A
					continue
		if(food_flags & ANIMAL_CARNIVORE)
			if(istype(A,/mob/living/carbon) || istype(A,/mob/living/simple_animal) || istype(A,/mob/living/complex_animal))
				var/mob/living/M=A
				if(M.stat!=DEAD)
					if(!is_pacified() && behavior_flags & ANIMAL_BEHAVIOR_PREDATORY)
						foodsources+=M
						continue
				else
					foodsources+=M
					continue
			else if(istype(A,/obj/item/organ) && !istype(A,/obj/item/organ/external/head) && !istype(A,/obj/item/organ/internal/brain)) //we don't want to round remove people
				foodsources+=A
				continue
				
		//no easy way to check if it's meat. oh well.
		if(istype(A,/obj/item/weapon/reagent_containers/food/snacks))
			foodsources+=A
			continue
	for(var/atom/A in foodsources)
		if(!verify_target(A,-1,TRUE))
			foodsources-=A
	return foodsources

//take the list from get_food, and create an associated list ranking our affinity for them
/mob/living/complex_animal/proc/rank_foodsources(var/list/sources)
	var/list/out=list() //associate list time!!!!!!!!!! I LOVE BYOND!!!!111!
	for(var/atom/A in sources)
		var/p=rand(-2,2) // randomize it for a bit of spice
		if(istype(A,/mob/living))
			var/mob/M=A
			if(M.stat==DEAD)
				p+=ANIMAL_FOODPRIORITY_CORPSES
			if(is_kin(M))
				p+=ANIMAL_FOODPRIORITY_CANNIBAL
			if(M.size > src.size) //we avoid attacking things bigger than us
				p+=ANIMAL_FOODPRIORITY_SIZEDIFF_LARGER
			if(M.size < src.size-2) //smaller things ain't worth our time
				p+=ANIMAL_FOODPRIORITY_SIZEDIFF_SMALLER
			if(M in family)
				p+=ANIMAL_FOODPRIORITY_FAMILY
			if(istype(A,/mob/living/simple_animal))
				var/mob/living/simple_animal/SA=A
				if(SA.is_poisonous)
					p+=ANIMAL_FOODPRIORITY_UNDESIRABLE
			if(istype(A,/mob/living/complex_animal))
				var/mob/living/complex_animal/CA=A
				if(CA.behavior_flags & ANIMAL_BEHAVIOR_UNDESIRABLE)
					p+=ANIMAL_FOODPRIORITY_UNDESIRABLE
		if(istype(A,/obj/item/weapon/reagent_containers/food/snacks))
			p+=ANIMAL_FOODPRIORITY_PRECOOKED
		if(istype(A,/obj/structure/flora))
			p+=ANIMAL_FOODPRIORITY_PLANTS
		out[A]=p
	return out


/mob/living/complex_animal/UnarmedAttack(var/atom/A, var/proximity_flag, var/params)
	if(attack_delayer.next_allowed<=world.time)
		..()
		delayNextAttack(2 SECONDS) //fixes hitting same object multiple times rapidly

/mob/living/complex_animal/proc/aggro_drawn(var/victim,var/state=ANIMAL_STATE_ATTACKING,var/skipsmg=FALSE)
	if(!victim)
		return
	if(!skipsmg && target!=victim && state!=behavior_state)
		get_aggro_msg(victim)
	target=victim
	behavior_state=state
	if( !(behavior_flags & ANIMAL_BEHAVIOR_PACK_DYNAMICS) && !family.len)
		return
	if(istype(target,/mob/living))
		var/mob/living/T=target
		if(T.stat!=DEAD)
			for(var/mob/living/complex_animal/M in cache_objects_in_view)
				if( (behavior_flags & ANIMAL_BEHAVIOR_PACK_DYNAMICS) || (M in family))
					if(is_kin(M) && !M.is_kin(target)) //rally the pack to us, if the target is not kin
						if(M.behavior_state!=state) //if the pack member is not engaged in similar activity
							M.aggro_drawn(victim,state) //do this recursively for each. don't kick the bee hive.
	

/mob/living/complex_animal/proc/attack(var/victim)
	if(!verify_target(victim,1,TRUE))
		return FALSE
	if(is_pacified())
		return FALSE
	if(!victim)
		return FALSE
	if(istype(victim,/mob))
		return unarmed_attack_mob(victim)
	return UnarmedAttack(victim,Adjacent(victim))

/mob/living/complex_animal/proc/tryeat(var/victim)
	if(!victim)
		return FALSE
	if(!verify_target(victim,1,TRUE))
		return FALSE
	if(istype(target,/mob/living))
		var/mob/living/M=target
		if(M.stat!=DEAD)
			return attack(victim)
		else
			if(unarmed_attack_mob(victim))
				nutrition+=M.size*5
				emote("me",MESSAGE_SEE,"chomps on \the [target], tearing them apart!")
				if(M.butchering_drops && M.butchering_drops.len)
					for(var/datum/butchering_product/product in M.butchering_drops)
						while(product.spawn_result(M.loc,M))
							; //you need this semicolon here or else it won't compile because muh whitespace sensitive language
				if(M.meat_type)
					while(M.drop_meat())
						;  //see above.
				M.gib()
				return TRUE
	else if(istype(target,/obj/item/organ))
		var/obj/item/organ/O=target
		emote("me",MESSAGE_SEE,"scarfs down \the [O].")
		nutrition+=O.w_class*4
		qdel(O)
		target=null
	else if(istype(target,/obj/structure/flora))
		if(istype(target,/obj/structure/flora/jungle_berries))
			var/obj/structure/flora/jungle_berries/bush=target
			if(bush.hasberries)
				visible_message("<b>\The [src]</b> shakes \the [target].")
				bush.attack_hand(src)
				target=null //loose target so it doesn't destroy the bush by then eating it.
				return TRUE
		if(prob(20))
			visible_message("<b>\The [src]</b> nibbles at what's left of \the [target] into nothing...")
			qdel(target)
		else
			visible_message("<b>\The [src]</b> nibbles at \the [target].")
		nutrition+=5
		
	else if (istype(target,/turf))
		nutrition+=1
		visible_message("<b>\The [src]</b> nibbles at \the [target].")
	else if(istype(target,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/F=target
		visible_message("<b>\The [src]</b> takes a bite out of <b>\the [F]</b>.")
		F.consume(src)
	return TRUE

//stolen from simple_animal/hostile
/mob/living/complex_animal/proc/escape()
	if(!(behavior_flags & ANIMAL_BEHAVIOR_AVOID_CAPTURE))
		return
	if(locked_to)
		UnarmedAttack(locked_to, Adjacent(locked_to))
	if(!isturf(src.loc) && src.loc != null)
		var/atom/A = src.loc
		UnarmedAttack(A, Adjacent(A))

//stolen from simple_animal/hostile
/mob/living/complex_animal/proc/fuckshitup()
	if(!target)
		return
	if(!(behavior_flags & ANIMAL_BEHAVIOR_DESTRUCTIVE))
		return
	var/list/smash_dirs = list(0)
	var/targdir = get_dir(src, target)
	smash_dirs |= widen_dir(targdir) //otherwise smash towards the target
	for(var/dir in smash_dirs)
		var/turf/T = get_step(src, dir)
		for(var/atom/A in T)
			var/static/list/destructible_objects = list(/obj/structure/window,
				 /obj/structure/closet,
				 /obj/structure/table,
				 /obj/structure/grille,
				 /obj/structure/girder,
				 /obj/structure/rack,
				 /obj/structure/railing,
				 /obj/machinery/door/window,
				 /obj/item/tape,
				 /obj/item/toy/balloon/inflated/decoy,
				 /obj/machinery/door/airlock,
				 /obj/machinery/door/firedoor,
				 /obj/item/weapon/beartrap,)
			if(is_type_in_list(A, destructible_objects) && Adjacent(A))
				if(istype(A, /obj/machinery/door/airlock))
					var/obj/machinery/door/airlock/AIR = A
					if(!AIR.density || AIR.locked || AIR.welded || AIR.operating)
						continue
				if(istype(A, /obj/machinery/door/firedoor))
					var/obj/machinery/door/firedoor/FIR = A
					if(!FIR.density || FIR.blocked || FIR.operating)
						continue
				UnarmedAttack(A, Adjacent(A))


//only fired when the mob is within our territory, and we have the TERRITORIAL flag
/mob/living/complex_animal/proc/determine_tresspass(var/mob/trespasser)
	if(!verify_target(trespasser))
		return FALSE
	if(is_pacified())
		return FALSE
	if(istype(trespasser,/mob/living/simple_animal))
		var/mob/living/simple_animal/A=trespasser
		if(A.pacify_aura)
			return FALSE
	if(istype(trespasser,/mob/living/complex_animal))
		var/mob/living/complex_animal/A=trespasser
		if(A.pacify_aura || (A.behavior_flags & ANIMAL_BEHAVIOR_UNDESIRABLE) )
			return FALSE
	return !is_kin(trespasser)

//only fired when the mob is seen by us, and we have the AVOID_PRED flag
/mob/living/complex_animal/proc/determine_isthreat(var/mob/individual)
	if(!verify_target(individual))
		return FALSE
	if(is_pacified())
		return FALSE
	if(is_kin(individual))
		return FALSE
	if(behavior_flags & ANIMAL_BEHAVIOR_AVOID_PRED)
		if(istype(individual,/mob/living/carbon))
			return !(behavior_flags & ANIMAL_BEHAVIOR_TERRITORIAL)
		if(istype(individual,/mob/living/silicon))
			return !(behavior_flags & ANIMAL_BEHAVIOR_TERRITORIAL)
		if(istype(individual,/mob/living/simple_animal))
			return istype(individual,/mob/living/simple_animal/hostile)
		if(istype(individual,/mob/living/complex_animal))
			var/mob/living/complex_animal/A = individual
			return A.behavior_flags & (ANIMAL_BEHAVIOR_PREDATORY | ANIMAL_BEHAVIOR_TERRITORIAL)
	return FALSE


/mob/living/complex_animal/proc/get_aggro_msg(var/individual)
	emote("me",MESSAGE_SEE,"stares alertly at \the [individual].")

/mob/living/complex_animal/proc/get_flee_msg(var/individual)
	emote("me",MESSAGE_SEE,"stares at \the [individual] and runs away.")

/mob/living/complex_animal/proc/get_tesspass_msg(var/individual)
	emote("me",MESSAGE_SEE,"stares alertly at \the [individual].")

/mob/living/complex_animal/proc/get_hunting_msg(var/individual)
	if(istype(individual,/mob))
		emote("me",MESSAGE_SEE,"stares hungrily at \the [individual].")
	else
		visible_message("<b>\The [src]</b> stares hungrily at <b>\the [individual]</b>.")

/mob/living/complex_animal/proc/get_attack_msg(var/individual)
	emote("me",MESSAGE_SEE,"attacks \the [individual]!")

/mob/living/complex_animal/proc/get_idle_sounds()
	if(prob(10))
		emote("me",MESSAGE_HEAR, "vocalizes.")


/mob/living/complex_animal/proc/get_offspring_cost()
	return size*7.5

// if you don't want offspring, then return FALSE here.
/mob/living/complex_animal/proc/can_offspring(var/mob/living/complex_animal/mate)
	if(!mate)
		return FALSE
	if(mate.type!=src.type)
		return FALSE
	var/localcount=0
	for(var/mob/living/complex_animal/A in cache_objects_in_view)
		if(A.type==src.type && A.stat!=DEAD)
			localcount++
	if(localcount>max_local_population)
		return FALSE
	if(mob_age>mob_max_age*1.5 || mob_age<mob_max_age*0.1) //too young or too old? no can do.
		return FALSE
	if(lastmate>0)
		return FALSE
	if((src.gender=="male" && mate.gender=="female") || (mate.gender=="male" && src.gender=="female"))
		return TRUE
	return FALSE

//this proc is ran on the mother only.
/mob/living/complex_animal/proc/generate_offspring(var/mob/living/complex_animal/father)
	var/mob/living/complex_animal/child=new src.type(loc)
	child.faction=faction
	child.nutrition=child.max_food*0.5
	family+=child
	father.family+=child
	child.family+=src
	child.family+=father
	if(!child)
		return FALSE
	return child
	
	
/mob/living/complex_animal/get_unarmed_damage(var/atom/victim)
	return base_damage+ (damage_variance ? rand(-damage_variance,damage_variance) : 0)



/mob/living/complex_animal/init_butchering_list()
	if(butchering_drops && butchering_drops.len) //Already initialized
		return

	butchering_drops = list()
	var/list/animal_butchering_products = get_butchering_products()
	if(animal_butchering_products.len > 0)
		for(var/butchering_type in animal_butchering_products)
			butchering_drops += new butchering_type()

/mob/living/complex_animal/death(gibbed) //stolen from simple_animal
	..()
	init_butchering_list()
	if((status_flags & BUDDHAMODE) || stat == DEAD)
		return

	if(!gibbed)
		emote("deathgasp", message = TRUE)
	health = 0 
	stat = DEAD
	update_icon()
	walk(src,0)
	setDensity(FALSE)

/mob/living/complex_animal/attack_hand(var/mob/living/carbon/human/H)
	H.delayNextAttack(2 SECONDS)
	if(H.a_intent==I_HURT)
		H.unarmed_attack_mob(src)
		if(health<=0)
			death()
		else
			if(behavior_flags & ANIMAL_BEHAVIOR_RETALIATE)
				behavior_state=behavior_state=ANIMAL_STATE_ATTACKING
				aggro_drawn(H,ANIMAL_STATE_ATTACKING)
			else
				get_flee_msg(H)
				behavior_state = ANIMAL_STATE_FLEEING
				target=H
		return
	else if(H.a_intent==I_HELP)
		if(stat!=DEAD)
			trypet(H)
			return
	..()

/mob/living/complex_animal/proc/trypet(var/mob/living/carbon/human/H)
	if(petable)
		H.emote("me",MESSAGE_SEE,"pets \the [src].")
		var/image/heart = image('icons/mob/animal.dmi',src,"heart-ani2")
		heart.plane = ABOVE_HUMAN_PLANE
		flick_overlay(heart, list(H.client), 20)
		
/mob/living/complex_animal/attackby(var/obj/item/I, var/mob/user, var/no_delay = 0, var/originator = null, var/def_zone = null)
	if(user.a_intent == I_HELP)
		user.visible_message("<span class='notice'>[user] [pick(list("pokes","prods","taps"))] \the [src] with \the [I].</span>")
		to_chat(user, "<span class='notice'>You [pick(list("poke","prod","tap"))] \the [src] with \the [I].</span>")
	else
		..()
		user.visible_message("<span class='danger'>[user] hits \the [src] with \the [I]!</span>")
		to_chat(user, "<span class='danger'>You hit \the [src] with \the [I]!</span>")
		if(health<=0)
			death()
		if(behavior_flags & ANIMAL_BEHAVIOR_RETALIATE)
			behavior_state=behavior_state=ANIMAL_STATE_ATTACKING
			aggro_drawn(user,ANIMAL_STATE_ATTACKING)
		else
			get_flee_msg(user)
			behavior_state = ANIMAL_STATE_FLEEING
			target=user


/mob/living/complex_animal/assaulted_by(var/mob/M,var/weak_assault=FALSE)	
	if(behavior_flags & ANIMAL_BEHAVIOR_RETALIATE)
		behavior_state=behavior_state=ANIMAL_STATE_ATTACKING
		aggro_drawn(M,ANIMAL_STATE_ATTACKING)
	else
		get_flee_msg(M)
		behavior_state = ANIMAL_STATE_FLEEING
		target=M
	return ..()

/mob/living/complex_animal/unarmed_attacked(mob/living/attacker, damage, damage_type, zone)
	if(behavior_flags & ANIMAL_BEHAVIOR_RETALIATE)
		behavior_state=behavior_state=ANIMAL_STATE_ATTACKING
		aggro_drawn(attacker,ANIMAL_STATE_ATTACKING)
	else
		get_flee_msg(attacker)
		behavior_state = ANIMAL_STATE_FLEEING
		target=attacker
	return ..()

/mob/living/complex_animal/getarmor(var/def_zone, var/type)
	return armor[type] || 0

/mob/living/complex_animal/beartrap_act(var/obj/item/weapon/beartrap/trap)
	if(flying)
		return FALSE
	if(size>SIZE_TINY)
		return FALSE
	trap.trapped = 1
	trap.trappedcanimal = src
	trap.armed = 0
	playsound(trap, 'sound/effects/snap.ogg', 60, 1)
	trap.lock_atom(src, /datum/locking_category/beartrap)
	adjustBruteLoss(20)
	update_canmove()
	update_icon()
	emote("me", EMOTE_AUDIBLE, "cries out in pain")
	if(behavior_flags & ANIMAL_BEHAVIOR_AVOID_CAPTURE )
		behavior_state = ANIMAL_STATE_ATTACKING
		target = src
	return TRUE
