//http://www.youtube.com/watch?v=-1GadTfGFvU

/obj/machinery/apiary
	name = "apiary tray"
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "hydrotray3"
	density = 1
	anchored = 1
	var/nutrilevel = 0
	var/yieldmod = 1
	var/damage = 1
	var/toxic = 0

	var/lastcycle = 0
	var/cycledelay = 100
	var/list/pollen = list()

	var/queen_bees_inside = 0
	var/worker_bees_inside = 0
	var/list/bees_outside_hive = list()

	var/hydrotray_type = /obj/machinery/portable_atmospherics/hydroponics

	var/obj/item/weapon/reagent_containers/glass/consume = null

	var/wild = 0

	machine_flags = WRENCHMOVE

/obj/machinery/apiary/New()
	..()
	overlays += image('icons/obj/apiary_bees_etc.dmi', icon_state="apiary")
	create_reagents(100)
	consume = new()

/obj/machinery/apiary/Destroy()
	for (var/datum/bee/B in bees_outside_hive)
		B.home = null
		if (B.mob)
			B.mob.home = null
	..()

/obj/machinery/apiary/update_icon()
	overlays.len = 0
	overlays += image('icons/obj/apiary_bees_etc.dmi', icon_state="apiary")

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
	if(worker_bees_inside || queen_bees_inside)
		to_chat(user, "You can hear a loud buzzing coming from the inside.")
	else
		to_chat(user, "There doesn't seem to be any bees in it.")

	switch(reagents.total_volume)
		if(30 to 60)
			to_chat(user, "<span class='info'>Looks like there's a bit of honey in it.</span>")
		if(60 to 90)
			to_chat(user, "<span class='info'>There's a decent amount of honey dripping from it!</span>")
		if(90 to INFINITY)
			to_chat(user, "<span class='info'>It's full of honey!</span>")

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

/obj/machinery/apiary/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(..())
		return
	if (wild)
		return
	if(istype(O, /obj/item/queen_bee))
		if(user.drop_item(O))
			nutrilevel = min(15,nutrilevel+15)
			queen_bees_inside++
			qdel(O)
			to_chat(user, "<span class='notice'>You carefully insert the queen into [src], she gets busy managing the hive.</span>")
	else if(istype(O, /obj/item/weapon/reagent_containers))
		if (O.reagents.trans_id_to(src,BEEZEEZ,20))
			if(queen_bees_inside || worker_bees_inside)
				to_chat(user, "<span class='notice'>You transfer some BeezEez into \the [src]. A relaxed humming appears to pick up.</span>")
			else
				to_chat(user, "<span class='notice'>You transfer some BeezEez into \the [src]. Now it just needs some bees.</span>")
		else
			to_chat(user, "<span class='notice'>There is no BeezEez in \the [O].</span>")

	else if(istype(O, /obj/item/weapon/hatchet))
		if(reagents.total_volume > 0)
			user.visible_message("<span class='notice'>\the [user] begins harvesting the honeycombs.</span>","<span class='danger'>You begin harvesting the honeycombs.</span>")
		else
			to_chat(user, "<span class='notice'>You begin to dislodge the dead apiary from the tray.</span>")

		if(queen_bees_inside || worker_bees_inside)
			user.visible_message("<span class='danger'>The bees don't like that.</span>")
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

			for (var/datum/bee/B in bees_outside_hive)
				B.home = null

			qdel(src)

	else if(istype(O, /obj/item/weapon/bee_net))
		var/obj/item/weapon/bee_net/N = O
		if(N.caught_bees.len)
			to_chat(user, "<span class='notice'>You empty the bees into the apiary.</span>")
			for (var/datum/bee/B in N.caught_bees)
				enterHive(B)
			N.caught_bees = list()
		else
			to_chat(user, "<span class='notice'>There are no more bees in the net.</span>")
	else
		user.visible_message("<span class='warning'>\the [user] hits \the [src] with \the [O]!</span>","<span class='warning'>You hit \the [src] with \the [O]!</span>")
		angry_swarm(user)

/obj/machinery/apiary/proc/enterHive(var/datum/bee/B)
	bees_outside_hive.Remove(B)
	if (istype(B,/datum/bee/queen_bee))
		queen_bees_inside++
		var/datum/bee/queen_bee/Q = B
		if (Q.colonizing)
			nutrilevel = min(15,nutrilevel+15)
	else
		worker_bees_inside++
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
			var/coeff = min(reagents.maximum_volume / totalreagents, 1)

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
				var/amountToAdd = max(1, round(rtotal*coeff, 0.1))
				var/difference = amountToAdd + 2.5 + reagents.total_volume - reagents.maximum_volume
				if (difference>0)
					reagents.trans_to(consume, difference)//This allows bees to bring in new reagents even if the hive is full
				reagents.add_reagent(chemToAdd, amountToAdd)
		if (!pollen.Find(S))
			pollen.Add(S)
		if (istype(B,/datum/bee/queen_bee))
			reagents.add_reagent(ROYALJELLY,2)
		else
			reagents.add_reagent(HONEY,2)
		reagents.add_reagent(NUTRIMENT, 0.1)
		reagents.add_reagent(SUGAR, 0.4)

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
		H.icon_state = "honeycomb-base"
		H.overlays += I
		reagents.trans_to(H,reagents_per_honeycomb)

	return 1

/obj/machinery/apiary/proc/empty_beehive()
	if (!queen_bees_inside && !worker_bees_inside)
		return
	var/mob/living/simple_animal/bee/lastBees = getFromPool(/mob/living/simple_animal/bee,get_turf(src))
	for(var/i = 1 to worker_bees_inside)
		worker_bees_inside--
		lastBees.addBee(new/datum/bee(src))
	for(var/i = 1 to queen_bees_inside)
		queen_bees_inside--
		lastBees.addBee(new/datum/bee/queen_bee(src))

/obj/machinery/apiary/proc/exile_swarm(var/obj/machinery/apiary/A)
	if (A == src)
		return 0
	if (A.queen_bees_inside > 0 || is_type_in_list(/datum/bee/queen_bee,A.bees_outside_hive))
		return 0
	var/mob/living/simple_animal/bee/B_mob = getFromPool(/mob/living/simple_animal/bee, get_turf(src), src)
	var/datum/bee/queen_bee/new_queen = new(src)
	queen_bees_inside--
	B_mob.addBee(new_queen)
	for (var/i = 1 to 10)
		var/datum/bee/B = new(src)
		B_mob.addBee(B)
		worker_bees_inside--
	new_queen.setHome(A)
	return 1

/obj/machinery/apiary/proc/angry_swarm(var/mob/M = null)
	for(var/datum/bee/B in bees_outside_hive)
		B.angerAt(M)

	var/mob/living/simple_animal/bee/B_mob = getFromPool(/mob/living/simple_animal/bee, get_turf(src), get_turf(src), src)
	for (var/i=1 to worker_bees_inside)
		var/datum/bee/B = new(src)
		B_mob.addBee(B)
		worker_bees_inside--
		bees_outside_hive.Add(B)
		B.angerAt(M)
	B_mob.update_icon()


/obj/machinery/apiary/process()
	if(world.time > (lastcycle + cycledelay))//about 10 seconds by default
		lastcycle = world.time

		if(!queen_bees_inside && !worker_bees_inside)//if the apiary is empty, let's not waste time processing it
			return

		//HANDLE NUTRILEVEL
		nutrilevel -= worker_bees_inside / 20 + queen_bees_inside /4 + bees_outside_hive.len / 10 //Bees doing work need more nutrients

		nutrilevel += 2 * reagents.trans_to(consume, reagents.total_volume * 2 / 100)


		for(var/datum/reagent/R in reagents.reagent_list)
			if (R.volume < 0.09)
				if (R == NUTRIMENT) continue
				reagents.del_reagent(R.id,update_totals=0)

		nutrilevel = min(max(nutrilevel,-10),100)

		//PRODUCING QUEEN BEES
		if(reagents.get_reagent_amount(ROYALJELLY) >= 5 && nutrilevel > 10 && queen_bees_inside <= 0 && worker_bees_inside > 1)
			queen_bees_inside++
			reagents.remove_reagent(ROYALJELLY, 5)
			worker_bees_inside--


		//PRODUCING WORKER BEES
		if(nutrilevel > 10 && queen_bees_inside > 0 && worker_bees_inside < 20)
			worker_bees_inside += queen_bees_inside
		else if (nutrilevel < -5 && worker_bees_inside >= 10)// We're getting in dire need of nutrients, let's starve bees so others can survive
			nutrilevel += 3
			worker_bees_inside--
		else if (nutrilevel <= 0 && bees_outside_hive.len > 1) // We're low on nutrients, let's call back some bees to reduce our costs
			for (var/i = 1 to max(1,round(bees_outside_hive.len/3)))
				var/datum/bee/B = pick(bees_outside_hive)
				B.homeCall()


		//HANDLE TOXICITY
		var/list/toxic_reagents = list(
			TOXIN = 2,
			STOXIN = 1,
			FLUORINE = 1,
			RADIUM = 3,
			FUEL = 2,
			VOMIT = 1,
			BLEACH = 2,
			PLANTBGONE = 3,
			PLASMA = 2,
			SACID = 1,
			PACID = 3,
			CYANIDE = 4,
			AMATOXIN = 2,
			AMANATIN = 3,
			POISONBERRYJUICE = 2,
			CARPOTOXIN = 2,
			ZOMBIEPOWDER = 3,
			MINDBREAKER = 1,
			PLASTICIDE = 2,
			BEEZEEZ = -3,
		)

		for(var/datum/reagent/R in consume.reagents.reagent_list)
			if (toxic_reagents.Find(R.id))
				toxic += R.volume * toxic_reagents[R.id]
			if (R.id == MUTAGEN)
				damage = round(rand(0,3))
			if (R.id == BEEZEEZ)
				nutrilevel = max(15,nutrilevel + 2 * R.volume)//BeezEez gives double nutrilevel

		if(toxic > 0)
			toxic -= 0.1
		toxic = min(100,max(0,toxic))

		to_chat(world,"toxicity = [toxic]")

		//NOISE
		if(prob(2))
			playsound(get_turf(src), 'sound/effects/bees.ogg', min(20+(reagents.total_volume),100), 1)

		update_icon()

		//SENDING OUT BEES TO POLLINATE
		if(worker_bees_inside >= 10 && bees_outside_hive.len < 11)
			var/turf/T = get_turf(src)
			var/mob/living/simple_animal/bee/B_mob = getFromPool(/mob/living/simple_animal/bee, T, src)
			var/datum/bee/B = null
			if (queen_bees_inside > 0 && nutrilevel > 0 && worker_bees_inside > 15 && prob(nutrilevel/3))
				B = new/datum/bee/queen_bee(src)
				queen_bees_inside--
			else
				B = new(src)
				worker_bees_inside--
			bees_outside_hive.Add(B)
			B_mob.addBee(B)
			if ()
				B.angerAt()
			else
				B.goPollinate()

		if(queen_bees_inside > 1 && worker_bees_inside >= 10)
			for(var/obj/machinery/apiary/A in range(src,5))
				if (exile_swarm(A))
					break

		consume.reagents.clear_reagents()

///////////////////////////WILD BEEHIVES////////////////////////////

/obj/machinery/apiary/wild
	name = "angry-bee hive"
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "apiary-wild"
	density = 1
	anchored = 1
	nutrilevel = 100
	damage = 1.5
	toxic = 2.5

	cycledelay = 50

	queen_bees_inside = 1
	worker_bees_inside = 20
	wild = 1

	var/health = 100

/obj/machinery/apiary/wild/New()
	..()
	reagents.add_reagent(ROYALJELLY,5)
	reagents.add_reagent(HONEY,75)
	reagents.add_reagent(NUTRIMENT, 4)
	reagents.add_reagent(SUGAR, 16)
	update_icon()


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
	else if(O.force)
		user.delayNextAttack(10)
		if(queen_bees_inside || worker_bees_inside)
			to_chat(user,"<span class='warning'>You hit \the [src] with your [O].</span>")
			angry_swarm(user)

		playsound(get_turf(src), O.hitsound, 50, 1, -1)
		health -= O.force
		updateHealth()

/obj/machinery/apiary/wild/proc/updateHealth()
	if(health <= 0)
		visible_message("<span class='notice'>\The [src] falls apart.</span>")

		if (queen_bees_inside || worker_bees_inside)
			empty_beehive()

		for (var/datum/bee/B in bees_outside_hive)
			B.home = null

		harvest_honeycombs()

		qdel(src)

/obj/machinery/apiary/wild/process()
	if(world.time > (lastcycle + cycledelay))
		lastcycle = world.time

		if(!queen_bees_inside && !worker_bees_inside)
			return

		//PRODUCING WORKER BEES
		if(worker_bees_inside < 20)
			worker_bees_inside += queen_bees_inside

		//making noise
		if(prob(10))
			playsound(get_turf(src), 'sound/effects/bees.ogg', min(20+(reagents.total_volume),100), 1)

		//sending out bees to KILL
		if(worker_bees_inside >= 10 && bees_outside_hive.len < 15)
			var/turf/T = get_turf(src)
			var/mob/living/simple_animal/bee/B_mob = getFromPool(/mob/living/simple_animal/bee, T, src)
			var/datum/bee/B = new(src)
			worker_bees_inside--
			bees_outside_hive.Add(B)
			B_mob.addBee(B)
			B.angerAt()

/obj/machinery/apiary/wild/update_icon()
	overlays.len = 0
	return
