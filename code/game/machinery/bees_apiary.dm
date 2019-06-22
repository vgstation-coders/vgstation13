//http://www.youtube.com/watch?v=-1GadTfGFvU

#define MAX_BEES_PER_HIVE	40
#define EXILE_RESTRICTION	200

/*

> apiary tray
> angry-bee hive

*/
var/list/apiary_reservation = list()

var/list/apiaries_list = list()

/obj/machinery/apiary
	name = "apiary tray"
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "hydrotray3"
	density = 1
	anchored = 1
	var/apiary_icon = "apiary"
	var/beezeez = 0//beezeez removes 1 toxic and adds 1 nutrilevel per cycle
	var/nutrilevel = 0//consumed every round based on how many bees the apiary is sustaining.
	var/yieldmod = 1
	var/damage = 1
	var/toxic = 0

	var/lastcycle = 0
	var/cycledelay = 100
	var/list/pollen = list()//mostly unused for now. but might come handy later if we want to check what plants where pollinated by an apiary's bees

	var/queen_bees_inside = 0
	var/worker_bees_inside = 0
	var/list/bees_outside_hive = list()

	var/hydrotray_type = /obj/machinery/portable_atmospherics/hydroponics

	var/obj/item/weapon/reagent_containers/glass/consume = null

	var/wild = 0

	var/datum/bee_species/species = null

	var/open_for_exile = 0

	machine_flags = WRENCHMOVE

/obj/machinery/apiary/New()
	..()
	apiaries_list.Add(src)
	overlays += image('icons/obj/apiary_bees_etc.dmi', icon_state=apiary_icon)
	create_reagents(100)
	consume = new()
	spawn(EXILE_RESTRICTION)
		open_for_exile = 1

/obj/machinery/apiary/Destroy()
	apiaries_list.Remove(src)
	for (var/datum/bee/B in bees_outside_hive)
		B.home = null
		if (B.mob)
			B.mob.home = null
	..()

/obj/machinery/apiary/update_icon()
	overlays.len = 0
	overlays += image('icons/obj/apiary_bees_etc.dmi', icon_state=apiary_icon)

	var/image/I = null
	switch(reagents.total_volume)
		if(30 to 60)
			I = image('icons/obj/apiary_bees_etc.dmi', icon_state="honey_1")
		if(60 to 90)
			I = image('icons/obj/apiary_bees_etc.dmi', icon_state="honey_2")
		if(90 to INFINITY)
			I = image('icons/obj/apiary_bees_etc.dmi', icon_state="honey_3")
	if(!I)
		return
	I.color = mix_color_from_reagents(reagents.reagent_list)
	overlays += I

/obj/machinery/apiary/examine(mob/user)
	..()
	var/species_name = "bees"//people would expect an apiary to contain bees by default I guess.
	if (species)
		species_name = species.common_name
	if(!worker_bees_inside && !queen_bees_inside)
		to_chat(user, "<span class='info'>There doesn't seem to be any [species_name] in it.</span>")
	else
		if(worker_bees_inside < 10)
			to_chat(user, "<span class='info'>You can hear a few [species_name] buzzing inside.</span>")
		else if(worker_bees_inside > 35)
			to_chat(user, "<span class='danger'>The [species_name] are over-crowded!</span>")
		else
			to_chat(user, "<span class='info'>You hear a loud buzzing from the inside.</span>")

		if(nutrilevel < 0)
			to_chat(user, "<span class='danger'>The [species_name] inside appear to be starving.</span>")
		else if(nutrilevel < 10)
			to_chat(user, "<span class='warning'>The [species_name] inside appear to be low on food reserves.</span>")

		if(beezeez > 0)
			to_chat(user, "<span class='info'>The [species_name] are collecting the beezeez pellets.</span>")

		if(toxic > 5)
			if (toxic < 33)
				to_chat(user, "<span class='warning'>The [species_name] look a bit on edge, their diet might be toxic.</span>")
			else if (toxic < 50)
				to_chat(user, "<span class='warning'>The [species_name] are starting to act violent, the hive's toxicity is rising.</span>")
			else
				to_chat(user, "<span class='danger'>The [species_name] are violent and exhausted, the hive's toxicity is reaching critical levels.</span>")

	if (species.worker_product)
		switch(reagents.total_volume)
			if(30 to 60)
				to_chat(user, "<span class='info'>Looks like there's a bit of [reagent_name(species.worker_product)] in it.</span>")
			if(60 to 90)
				to_chat(user, "<span class='info'>There's a decent amount of [reagent_name(species.worker_product)] dripping from it!</span>")
			if(90 to INFINITY)
				to_chat(user, "<span class='info'>It's full of [reagent_name(species.worker_product)]!</span>")

/obj/machinery/apiary/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group || (height==0))
		return 1

	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

/obj/machinery/apiary/bullet_act(var/obj/item/projectile/Proj) //Works with the Somatoray to modify plant variables.
	if(istype(Proj ,/obj/item/projectile/energy/floramut))
		damage = round(rand(0,3))//0, 1, or 2 brute damage per stings...per bee in a swarm
	else if(istype(Proj ,/obj/item/projectile/energy/florayield))
		if(!yieldmod)
			yieldmod += 1
		else if (prob(1/(yieldmod * yieldmod) *100))//This formula gives you diminishing returns based on yield. 100% with 1 yield, decreasing to 25%, 11%, 6, 4, 2...
			yieldmod += 1
	else
		..()
		if(src)
			angry_swarm()
		return

/obj/machinery/apiary/hitby(AM as mob|obj)
	. = ..()
	if(.)
		return
	visible_message("<span class='warning'>\The [src] was hit by \the [AM].</span>", 1)
	angry_swarm()

/obj/machinery/apiary/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(..())
		return
	if(istype(O, /obj/item/device/analyzer/plant_analyzer))
		to_chat(user, "<span class='warning'>That's not a plant you dummy. You can get basic info about \the [src] by simply examining it.</span>")
		return
	if (wild)
		return
	if(istype(O, /obj/item/queen_bee))
		var/obj/item/queen_bee/bee_packet = O
		if(user.drop_item(bee_packet))
			nutrilevel = max(15,nutrilevel+15)
			if (!species || !(queen_bees_inside || worker_bees_inside))
				species = bee_packet.species
			queen_bees_inside++
			qdel(bee_packet)
			to_chat(user, "<span class='notice'>You carefully insert the queen into \the [src], she gets busy managing the hive.</span>")
	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/beezeez))
		var/i = O.reagents.trans_id_to(consume,NUTRIMENT,3)
		if (i)
			beezeez += i * 10
			if(queen_bees_inside || worker_bees_inside)
				to_chat(user, "<span class='notice'>You pour the BeezEez into \the [src]. A relaxed humming appears to pick up.</span>")
			else
				to_chat(user, "<span class='notice'>You pour the BeezEez into \the [src]. Now it just needs some bees.</span>")
		else
			to_chat(user, "<span class='notice'>There is no BeezEez in \the [O].</span>")
		user.drop_from_inventory(O)
		var/obj/item/trash/beezeez/TrashItem = new /obj/item/trash/beezeez(user)
		user.put_in_hands(TrashItem)
		qdel(O)
	else if(istype(O, /obj/item/weapon/hatchet))
		if(reagents.total_volume > 0)
			user.visible_message("<span class='notice'>\the [user] begins harvesting the honeycombs.</span>","<span class='danger'>You begin harvesting the honeycombs.</span>")
		else
			to_chat(user, "<span class='notice'>You begin to dislodge the apiary from the tray.</span>")

		if((queen_bees_inside || worker_bees_inside) && species.angery)
			user.visible_message("<span class='danger'>The [species.common_name] don't like that.</span>")
			angry_swarm(user)

		if(do_after(user, src, 50))
			var/obj/machinery/created_tray = new hydrotray_type(src.loc)
			created_tray.component_parts = list()
			for(var/obj/I in src.component_parts)
				created_tray.component_parts += I
				I.forceMove(created_tray)
				component_parts -= I
			for(var/obj/I in src.contents)
				I.forceMove(created_tray)
				contents -= I
			new /obj/item/apiary(src.loc)

			if(harvest_honeycombs())
				to_chat(user, "<span class='notice'>You successfully harvest the honeycombs. The empty apiary can be relocated.</span>")
			else
				to_chat(user, "<span class='notice'>You dislodge the apiary from the tray.</span>")

			if (queen_bees_inside || worker_bees_inside)
				empty_beehive()

			qdel(src)

	else if(istype(O, /obj/item/weapon/bee_net))
		var/obj/item/weapon/bee_net/N = O
		if(N.caught_bees.len)
			if (N.caught_bees.len+worker_bees_inside+queen_bees_inside+bees_outside_hive.len <= MAX_BEES_PER_HIVE)
				for (var/datum/bee/B in N.caught_bees)
					if (!species || !(queen_bees_inside || worker_bees_inside))
						species = B.species
					if (species == B.species)
						enterHive(B)
						N.caught_bees.Remove(B)
				N.current_species = null
				to_chat(user, "<span class='notice'>You empty the [species.common_name] into the apiary.</span>")
			else
				var allowed = MAX_BEES_PER_HIVE - worker_bees_inside+queen_bees_inside+bees_outside_hive.len
				if (allowed <= 0)
					to_chat(user, "<span class='warning'>There are too many [species.common_name] in the apiary already.</span>")
				else
					for (var/i = 1 to allowed)
						var/datum/bee/B = pick(N.caught_bees)
						if (!species || !(queen_bees_inside || worker_bees_inside))
							species = B.species
						if (species == B.species)
							enterHive(B)
							N.caught_bees.Remove(B)
					to_chat(user, "<span class='notice'>You empty [allowed] [species.common_name] into the apiary.</span>")
		else
			to_chat(user, "<span class='notice'>There are no more bees in the net.</span>")
	else
		user.visible_message("<span class='warning'>\the [user] hits \the [src] with \the [O]!</span>","<span class='warning'>You hit \the [src] with \the [O]!</span>")
		angry_swarm(user)

//Called every time a bee enters the hive.
/obj/machinery/apiary/proc/enterHive(var/datum/bee/B)
	bees_outside_hive.Remove(B)
	if (istype(B,/datum/bee/queen_bee))
		queen_bees_inside++
		var/datum/bee/queen_bee/Q = B
		if (Q.colonizing)
			apiary_reservation.Remove(src)
			nutrilevel = max(15,nutrilevel+15)
	else
		worker_bees_inside++
	if (!species)
		species = B.species
	B.home = src
	B.state = null
	B.health = B.maxHealth
	for (var/datum/seed/S in B.pollens)
		var/potency = round(S.potency)
		var/totalreagents = 0
		for(var/chem in S.chems)
			var/list/reagent_data = list()
			if (chem == NUTRIMENT)
				if (S.products.len && juice_items.Find(S.products[1]))
					reagent_data = S.chems[chem]
				else
					continue
			else
				reagent_data = S.chems[chem]
			var/rtotal = reagent_data[1]
			if(reagent_data.len > 1 && potency > 0)
				rtotal += round(potency/reagent_data[2])
			totalreagents += rtotal

		if(totalreagents)
			for(var/chem in S.chems)
				var/list/reagent_data = list()
				var/chemToAdd = null
				if (chem == NUTRIMENT)
					if (S.products.len && juice_items.Find(S.products[1]))
						var/i = juice_items.Find(S.products[1])
						chemToAdd = pick(juice_items[juice_items[i]])
						reagent_data = S.chems[chem]
					else
						continue
				else
					reagent_data = S.chems[chem]
					chemToAdd = chem
				var/rtotal = reagent_data[1]
				if(reagent_data.len > 1 && potency > 0)
					rtotal += round(potency/reagent_data[2])
				var/amountToAdd = min(1, max(0.25, rtotal/4))
				var/difference = amountToAdd + 0.25 + reagents.total_volume - reagents.maximum_volume
				if (difference>0)
					reagents.trans_to(consume, difference)//This allows bees to bring in new reagents even if the hive is full
				reagents.add_reagent(chemToAdd, amountToAdd * yieldmod)
		if (!pollen.Find(S))
			pollen.Add(S)
		if (istype(B,/datum/bee/queen_bee) && species.queen_product)
			reagents.add_reagent(species.queen_product,0.75 * yieldmod)
		else if (species.worker_product)
			reagents.add_reagent(species.worker_product,0.75 * yieldmod)
		reagents.add_reagent(SUGAR, 0.1 * yieldmod)

	if (B.toxins > toxic)
		toxic += B.toxins * 0.1

	qdel(B)
	update_icon()

/obj/machinery/apiary/proc/harvest_honeycombs()
	if (reagents.total_volume < 1)
		return 0

	var/number_of_honeycombs = min(round(reagents.total_volume / 12.5) + 1 , 8)
	var/reagents_per_honeycomb = reagents.total_volume / number_of_honeycombs
	var/turf/T = get_turf(src)

	var/image/I = image('icons/obj/food.dmi', icon_state="honeycomb-color")
	I.color = mix_color_from_reagents(reagents.reagent_list)

	for (var/i = 1 to number_of_honeycombs)
		var/obj/item/weapon/reagent_containers/food/snacks/honeycomb/H = new(T)
		H.reagents.clear_reagents()
		H.reagents.add_reagent(NUTRIMENT, 0.5)
		H.icon_state = "[species.prefix]honeycomb-base"
		H.overlays += I
		reagents.trans_to(H,reagents_per_honeycomb)

	return 1

/obj/machinery/apiary/proc/empty_beehive()
	if (!queen_bees_inside && !worker_bees_inside)
		return
	var/mob/living/simple_animal/bee/lastBees = getFromPool(/mob/living/simple_animal/bee,get_turf(src))
	for(var/i = 1 to worker_bees_inside)
		worker_bees_inside--
		lastBees.addBee(new species.bee_type())
	for(var/i = 1 to queen_bees_inside)
		queen_bees_inside--
		lastBees.addBee(new species.queen_type())

/obj/machinery/apiary/proc/exile_swarm(var/obj/machinery/apiary/A)
	if (A == src)//can't colonize our own apiary
		return 0
	if (!A.open_for_exile)//This hive was made recently, homeless queen bees have priority to claim it for themselves
		return 0
	if (A in apiary_reservation)//another queen has marked this one for herself
		return 0
	if (A.queen_bees_inside > 0 || locate(/datum/bee/queen_bee) in A.bees_outside_hive)//another queen made her way there somehow
		return 0
	var/mob/living/simple_animal/bee/B_mob = getFromPool(/mob/living/simple_animal/bee, get_turf(src), src)
	var/datum/bee/queen_bee/new_queen = new species.queen_type(src)
	queen_bees_inside--
	B_mob.addBee(new_queen)
	for (var/i = 1 to 10)
		var/datum/bee/B = new species.bee_type(src)
		B_mob.addBee(B)
		worker_bees_inside--
	new_queen.setHome(A)
	A.reserve_apiary(B_mob)
	return 1

/obj/machinery/apiary/proc/reserve_apiary(var/mob/living/simple_animal/bee/B_swarm)
	apiary_reservation.Add(B_swarm)
	spawn (300)
		apiary_reservation.Remove(B_swarm)
		if (B_swarm)//so we can't reach the apiary somehow? then we've become homeless
			B_swarm.visible_message("<span class='notice'>A swarm has lost its way.</span>")
			B_swarm.mood_change(BEE_ROAMING)

/obj/machinery/apiary/proc/angry_swarm(var/mob/M = null)
	if (!species.angery)
		return

	for(var/datum/bee/B in bees_outside_hive)
		B.angerAt(M)

	var/mob/living/simple_animal/bee/B_mob = getFromPool(/mob/living/simple_animal/bee, get_turf(src), get_turf(src), src)
	for (var/i=1 to worker_bees_inside)
		var/datum/bee/B = new species.bee_type(src)
		B_mob.addBee(B)
		worker_bees_inside--
		bees_outside_hive.Add(B)
	B_mob.mood_change(BEE_OUT_FOR_ENEMIES,M)
	B_mob.update_icon()


/obj/machinery/apiary/process()
	if(world.time > (lastcycle + cycledelay))//about 10 seconds by default
		lastcycle = world.time

		if(!queen_bees_inside && !worker_bees_inside)//if the apiary is empty, let's not waste time processing it
			return
		else if (!species)//preventing runtimes caused by casual varedits
			species = bees_species[BEESPECIES_NORMAL]

		//HANDLE BEEZEEZ
		if(beezeez)
			beezeez--
			nutrilevel++

			if(toxic > 0)
				toxic--

		//HANDLE NUTRILEVEL
		nutrilevel -= worker_bees_inside / 20 + queen_bees_inside /5 + bees_outside_hive.len / 10 //Bees doing work need more nutrients

		nutrilevel += 5 * reagents.trans_to(consume, reagents.total_volume / 100)

		//reagents left in small enough quantities get removed, except nutriments so they can build up
		for(var/datum/reagent/R in reagents.reagent_list)
			if (R.volume < 0.01)
				if (R == NUTRIMENT) continue
				reagents.del_reagent(R.id,update_totals=0)

		nutrilevel = min(max(nutrilevel,-10),100)

		//PRODUCING QUEEN BEES
		if(reagents.get_reagent_amount(species.queen_product) >= 0.5 && nutrilevel > 10 && queen_bees_inside < species.max_queen_inside && worker_bees_inside > 1)
			queen_bees_inside++
			reagents.remove_reagent(species.queen_product, 0.5)
			worker_bees_inside--


		//PRODUCING WORKER BEES
		if(nutrilevel > 10 && queen_bees_inside > 0 && worker_bees_inside < MAX_BEES_PER_HIVE/2)
			worker_bees_inside += queen_bees_inside

		// We're getting in dire need of nutrients, let's starve bees so others can survive
		else if (nutrilevel < -5 && worker_bees_inside >= 10)
			nutrilevel += 3
			worker_bees_inside--
			new species.corpse(get_turf(src))

		//We're low on nutrients, let's call back some bees to reduce our food costs
		else if (nutrilevel <= 0 && bees_outside_hive.len > 1)
			for (var/i = 1 to max(1,round(bees_outside_hive.len/3)))
				var/datum/bee/B = locate() in bees_outside_hive
				if (istype(B))
					B.homeCall()


		//HANDLE TOXICITY
		for(var/datum/reagent/R in consume.reagents.reagent_list)
			if (species.toxic_reagents.Find(R.id))
				toxic += R.volume * species.toxic_reagents[R.id]
			if (R.id == MUTAGEN)
				damage = round(rand(0,3))

		if(toxic > 0)
			toxic -= 0.1
		toxic = min(100,max(0,toxic))

		//NOISE
		if(prob(2))
			playsound(src, 'sound/effects/bees.ogg', min(20+(reagents.total_volume),100), 1)

		update_icon()

		//SENDING OUT BEES
		if(worker_bees_inside >= 10 && bees_outside_hive.len < 11)
			var/turf/T = get_turf(src)
			var/mob/living/simple_animal/bee/B_mob = getFromPool(/mob/living/simple_animal/bee, T, src)
			var/datum/bee/B = null
			if (species.queen_wanders && queen_bees_inside > 0 && nutrilevel > 0 && worker_bees_inside > 15 && prob(nutrilevel/3))
				B = new species.queen_type(src)
				queen_bees_inside--
			else
				B = new species.bee_type(src)
				worker_bees_inside--
			bees_outside_hive.Add(B)
			B_mob.addBee(B)
			if (prob(species.aggressiveness) || (toxic > species.toxic_threshold_anger && prob(toxic/1.5)))//if our beehive is full of toxicity, bees will become ANGRY
				B_mob.mood_change(BEE_OUT_FOR_ENEMIES)
			else
				B_mob.mood_change(BEE_OUT_FOR_PLANTS)
			B_mob.update_icon()

		//OFF TO COLONIZE EMPTY BEE-HIVES
		if(queen_bees_inside > 1 && worker_bees_inside >= 10)
			for(var/obj/machinery/apiary/A in range(src,5))
				if (exile_swarm(A))
					break

		consume.reagents.clear_reagents()

///////////////////////////WILD BEEHIVES////////////////////////////

/obj/structure/wild_apiary
	name = "wild bug hive"
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "apiary-wild-inprogress0"
	density = 0
	anchored = 1
	var/base_icon_state = "apiary-wild-inprogress"
	var/prefix = ""
	var/remaining_work = 10
	var/health = 20

/obj/structure/wild_apiary/New(turf/loc, var/p = "")
	prefix = p
	icon_state = "[prefix][base_icon_state]0"

/obj/structure/wild_apiary/proc/work()
	remaining_work--
	switch(remaining_work)
		if (1 to 3)
			icon_state = "[prefix][base_icon_state]2"
		if (4 to 6)
			icon_state = "[prefix][base_icon_state]1"
		if (7 to 9)
			icon_state = "[prefix][base_icon_state]0"
	if (remaining_work<=0)
		var/obj/machinery/apiary/wild/W = new /obj/machinery/apiary/wild(loc)
		W.icon_state = "[prefix][W.icon_state]"
		for (var/mob/living/simple_animal/bee/B_mob in loc)
			//The bees that built the hive become its starting population
			if (B_mob.state == BEE_BUILDING)
				for(var/datum/bee/B in B_mob.bees)
					W.enterHive(B)
				qdel(B_mob)

			//Nearby homeless bees get a free invite.
			if (W.species && W.species == B_mob.bee_species && (B_mob.bees + W.worker_bees_inside + W.queen_bees_inside) <= MAX_BEES_PER_HIVE)
				for(var/datum/bee/B in B_mob.bees)
					W.enterHive(B)
				qdel(B_mob)
		qdel(src)


/obj/structure/wild_apiary/bullet_act(var/obj/item/projectile/P)
	..()
	if(P.damage && P.damtype != HALLOSS)
		health -= P.damage
		updateHealth()

/obj/structure/wild_apiary/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(..())
		return
	else if(O.force)
		to_chat(user,"<span class='warning'>You hit \the [src] with your [O].</span>")
		O.on_attack(src, user)
		health -= O.force
		updateHealth()

/obj/structure/wild_apiary/proc/updateHealth()
	if(health <= 0)
		visible_message("<span class='notice'>\The [src] falls apart.</span>")
		qdel(src)

/obj/machinery/apiary/wild
	name = "hive"
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "apiary-wild"
	density = 1
	anchored = 1
	nutrilevel = 15

	cycledelay = 100

	//we'll allow those to start pumping out bees right away
	wild = 1
	var/health = 100

/obj/machinery/apiary/wild/bullet_act(var/obj/item/projectile/P)
	..()
	if(P.damage && P.damtype != HALLOSS)
		health -= P.damage
		updateHealth()

/obj/machinery/apiary/wild/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(..())
		return
	if(istype(O, /obj/item/queen_bee))
		to_chat(user, "<span class='warning'>This type of bee hive isn't fit for domesticated bees.</span>")
	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/beezeez))
		to_chat(user, "<span class='warning'>These bees don't want your candies, they want your blood!</span>")
	else if(O.force)
		to_chat(user,"<span class='warning'>You hit \the [src] with your [O].</span>")
		if(queen_bees_inside || worker_bees_inside)
			angry_swarm(user)
		O.on_attack(src, user)
		health -= O.force
		updateHealth()

/obj/machinery/apiary/wild/proc/updateHealth()
	if(health <= 0)
		visible_message("<span class='notice'>\The [src] falls apart.</span>")

		if (queen_bees_inside || worker_bees_inside)
			empty_beehive()

		harvest_honeycombs()

		qdel(src)

/obj/machinery/apiary/wild/update_icon()
	overlays.len = 0
	return

/obj/machinery/apiary/wild/angry
	name = "angry-bee hive"
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "apiary-wild"
	density = 1
	anchored = 1
	nutrilevel = 100
	damage = 1.5
	toxic = 25

	cycledelay = 50

	//we'll allow those to start pumping out bees right away
	queen_bees_inside = 1
	worker_bees_inside = 20
	wild = 1

	health = 100

/obj/machinery/apiary/wild/angry/New()
	..()
	reagents.add_reagent(ROYALJELLY,5)
	reagents.add_reagent(HONEY,75)
	reagents.add_reagent(NUTRIMENT, 4)
	reagents.add_reagent(SUGAR, 16)
	update_icon()
	initialize()

/obj/machinery/apiary/wild/angry/initialize()
	species = bees_species[BEESPECIES_NORMAL]

/obj/machinery/apiary/wild/angry/process()
	if(world.time > (lastcycle + cycledelay))
		lastcycle = world.time

		if(!queen_bees_inside && !worker_bees_inside)
			return

		//PRODUCING WORKER BEES
		if(worker_bees_inside < 20)
			worker_bees_inside += queen_bees_inside

		//making noise
		if(prob(10))
			playsound(src, 'sound/effects/bees.ogg', min(20+(reagents.total_volume),100), 1)

		//sending out bees to KILL
		if(worker_bees_inside >= 10 && bees_outside_hive.len < 15)
			var/turf/T = get_turf(src)
			var/mob/living/simple_animal/bee/B_mob = getFromPool(/mob/living/simple_animal/bee, T, src)
			var/datum/bee/B = new species.bee_type(src)
			worker_bees_inside--
			bees_outside_hive.Add(B)
			B_mob.addBee(B)
			B_mob.mood_change(BEE_OUT_FOR_ENEMIES)
			B_mob.update_icon()


/obj/machinery/apiary/wild/angry/hornet
	name = "deadly hornet hive"
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "hornet_apiary-wild"
	density = 1
	anchored = 1
	nutrilevel = 100
	damage = 1//hornets are already pretty dangerous by themselves.
	toxic = 0

	cycledelay = 50

	//we'll allow those to start pumping out bees right away
	queen_bees_inside = 1
	worker_bees_inside = 20
	wild = 1

	health = 100

/obj/machinery/apiary/wild/angry/hornet/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent(ROYALJELLY,15)
	reagents.add_reagent(NUTRIMENT, 64)
	reagents.add_reagent(SUGAR, 21)

/obj/machinery/apiary/wild/angry/hornet/initialize()
	species = bees_species[BEESPECIES_HORNET]

#undef MAX_BEES_PER_HIVE
#undef EXILE_RESTRICTION
