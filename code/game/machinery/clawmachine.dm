/*
 * A claw machine that hands out random plushies in exchange for quarters.
 */

#define PRIZEPOOL_STANDARD 1
#define PRIZEPOOL_PREMIUM 2
#define PRIZEPOOL_POMF 3
#define ANIMATION_LENGTH 31

/obj/machinery/claw_machine
	name = "claw machine"
	desc = "Exchange credits for disappointment. This pre-war model has an extra slot for antique coins, labeled \"PREMIUM\"."
	icon = 'icons/obj/plushie.dmi'
	icon_state = "claw"
	anchored = 1
	density = 1
	machine_flags = WRENCHMOVE | FIXED2WORK
	health = 100
	maxHealth = 100
	var/busy = FALSE
	var/cost_per_game = 5 //credits
	var/winning_odds_standard = 50 //percentage
	var/winning_odds_premium = 50

	var/list/prizes_standard = list(
		/obj/item/toy/plushie/bumbler,
		/obj/item/toy/plushie/bunny,
		/obj/item/toy/plushie/carp,
		/obj/item/toy/plushie/cat,
		/obj/item/toy/plushie/chicken,
		/obj/item/toy/plushie/corgi,
		/obj/item/toy/plushie/fancypenguin,
		/obj/item/toy/plushie/goat,
		/obj/item/toy/plushie/kitten,
		/obj/item/toy/plushie/kitten/wizard,
		/obj/item/toy/plushie/ladybug,
		/obj/item/toy/plushie/monkey,
		/obj/item/toy/plushie/narsie,
		/obj/item/toy/plushie/orca,
		/obj/item/toy/plushie/parrot,
		/obj/item/toy/plushie/penguin,
		/obj/item/toy/plushie/peacekeeper,
		/obj/item/toy/plushie/possum,
		/obj/item/toy/plushie/ratvar,
		/obj/item/toy/plushie/roach,
		/obj/item/toy/plushie/spacebear,
		/obj/item/toy/plushie/teddy
	)

	var/list/prizes_premium = list(
		/obj/item/toy/plushie/fumo/atmostech,
		/obj/item/toy/plushie/fumo/assistant,
		/obj/item/toy/plushie/fumo/borg,
		/obj/item/toy/plushie/fumo/chef,
		/obj/item/toy/plushie/fumo/clown,
		/obj/item/toy/plushie/fumo/clown/clownette,
		/obj/item/toy/plushie/fumo/captain,
		/obj/item/toy/plushie/fumo/engi,
		/obj/item/toy/plushie/fumo/librarian,
		/obj/item/toy/plushie/fumo/mime,
		/obj/item/toy/plushie/fumo/miner,
		/obj/item/toy/plushie/fumo/nukeop,
		/obj/item/toy/plushie/fumo/nurse,
		/obj/item/toy/plushie/fumo/plasmaman,
		/obj/item/toy/plushie/fumo/scientist,
		/obj/item/toy/plushie/fumo/secofficer,
		/obj/item/toy/plushie/fumo/vox,
		/obj/item/toy/plushie/fumo/wizard,
		/obj/item/toy/plushie/fumo/touhou/alice,
		/obj/item/toy/plushie/fumo/touhou/cirno,
		/obj/item/toy/plushie/fumo/touhou/marisa,
		/obj/item/toy/plushie/fumo/touhou/mokou,
		/obj/item/toy/plushie/fumo/touhou/nitori,
		/obj/item/toy/plushie/fumo/touhou/patchouli,
		/obj/item/toy/plushie/fumo/touhou/reimu,
		/obj/item/toy/plushie/fumo/touhou/remilia,
		/obj/item/toy/plushie/fumo/touhou/sakuya,
		/obj/item/toy/plushie/fumo/touhou/yukari
	)

	//These are only available with a pomf coin
	var/list/prizes_pomf = list(
		/obj/item/toy/plushie/chicken/pomf
	)

/obj/machinery/claw_machine/examine(mob/user)
	. = ..()
	if(stat & BROKEN)
		to_chat(user, "It looks to be broken.")
		return
	if(stat & NOPOWER)
		to_chat(user, "It looks to be unpowered.")
		return

	if(cost_per_game)
		to_chat(user, "A small screen displays \"$[cost_per_game]\".")
	else
		to_chat(user, "A small screen displays \"FREE\".")

/obj/machinery/claw_machine/update_icon()
	..()
	if(stat & BROKEN)
		icon_state = "claw-broken"
	else if(stat & (NOPOWER | FORCEDISABLE))
		icon_state = "claw-off"
	else
		icon_state = "claw"

/obj/machinery/claw_machine/power_change()
	if(!(stat & BROKEN))
		if( powered() )
			stat &= ~NOPOWER
			update_icon()
		else
			spawn(rand(0, 15))
				stat |= NOPOWER
				update_icon()

//Dump some random plushies and then break
//this kick code is mostly aped from vending machines
/obj/machinery/claw_machine/proc/malfunction()
	var/lost_inventory = rand(1, 6)
	for(var/i=0, i < lost_inventory, i++)
		//this is imitated from kickcode
		var/D = pick(alldirs)
		var/turf/T = get_edge_target_turf(loc, D)
		var/power = rand(1, 2)
		var/P
		if(rand(1, 6) == 1) //1 in 6 will be a rare plushie
			P = pick(prizes_premium)
		else
			P = pick(prizes_standard)
		var/obj/item/plush = new P(src.loc)
		plush.kicked_item_arc_animation(power)
		plush.throw_at(T, power, 1)
	src.visible_message("<span class='notice'>Some plushies spill out of \the [src].</span>")
	stat |= BROKEN
	update_icon()

/obj/machinery/claw_machine/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				malfunction()

/obj/machinery/claw_machine/proc/damaged(var/mult=1)
	src.health -= 4*mult
	if(src.health <= 0)
		stat |= BROKEN
		src.update_icon()
		return
	if(prob(2*mult)) //Jackpot!
		malfunction()

/obj/machinery/claw_machine/kick_act(mob/living/carbon/human/user)
	. = ..()
	damaged()

/obj/machinery/claw_machine/attack_construct(var/mob/user)
	if (!Adjacent(user))
		return 0
	if(istype(user,/mob/living/simple_animal/construct/armoured))
		shake(1, 3)
		playsound(src, 'sound/weapons/heavysmash.ogg', 75, 1)
		damaged(4)
		return 1
	return 0

/obj/machinery/claw_machine/attack_hand(mob/living/user as mob)
	if(!isAdminGhost(usr) && (user.lying || user.incapacitated() || !Adjacent(user)))
		return 0
	if(stat & BROKEN)
		to_chat(user, "<span class='warning'>\The [src] is broken! Replace the reinforced glass first.</span>")
		return
	if(stat & (NOPOWER|FORCEDISABLE))
		to_chat(user, "<span class='warning'>\The [src] is dark and unresponsive.</span>")
		return

	//Telekinetic thievery requires focus, so you have to be next to the machine to see what you're doing
	if((M_TK in user.mutations) && iscarbon(user))
		to_chat(user, "<span class='notice'>You try to use your telekinetic powers to lift a plushie out of \the [src]...</span>")
		if(!do_after(user, src, 20))
			to_chat(user, "<span class='notice'>You get distracted and the plushie falls back in \the [src].</span>")
			return
		var/P
		switch(rand(1, 20))
			if(1)
				to_chat(user, "<span class='danger'>You accidentally damage \the [src]!</span>")
				visible_message("<span class='danger'>\The [src] rattles violently!</span>")
				shake(1, 1)
				playsound(src, 'sound/effects/grillehit.ogg', 50, 1)
				damaged()
				return
			if(2 to 5)
				to_chat(user, "<span class='notice'>You miss the chute, and the plushie falls back in \the [src].</span>")
				return
			if(6 to 16)
				P = pick(prizes_standard)
			else
				P = pick(prizes_premium)
		var/obj/item/toy/plushie/prize = new P(src.loc)
		to_chat(user, "<span class='notice'>You manage to telekinetically carry \a [prize] into the winnings chute, and it falls out of the machine with a satisfying clank.</span>")
		playsound(src, 'sound/machines/claw_machine_success.ogg', 50, 1)
		return

	add_fingerprint(user)
	to_chat(user, "<span class='notice'>The display on the machine scrolls: \"INSERT CREDIT\".</span>")

/obj/machinery/claw_machine/attackby(var/obj/item/O as obj, var/mob/user as mob)
	add_fingerprint(user)
	if(stat & BROKEN && !O.is_wrench(user))
		if(istype(O, /obj/item/stack/sheet/glass/rglass))
			var/obj/item/stack/sheet/glass/rglass/G = O
			to_chat(user, "<span class='notice'>You replace the broken glass.</span>")
			G.use(1)
			stat &= ~BROKEN
			src.health = 100
			power_change()
			new /obj/item/weapon/shard(loc)
		else
			to_chat(user, "<span class='warning'>\The [src] is broken! Replace the reinforced glass first.</span>")
		return

	if(stat & (NOPOWER|FORCEDISABLE) && !O.is_wrench(user))
		to_chat(user, "<span class='warning'>\The [src] is dark and unresponsive.</span>")
		return
	if(busy)
		to_chat(user, "<span class='notice'>\The [src] is already being used.</span>")
		return

	. = ..()
	if(.)
		return .

	if(is_type_in_list(O, list(/obj/item/weapon/coin, /obj/item/weapon/reagent_containers/food/snacks/chococoin)))
		//take coin, play premium game
		if(user.drop_item(O, src))
			playsound(src, 'sound/machines/capsulebuy.ogg', 50, 1)
			if(istype(O, /obj/item/weapon/coin))
				var/obj/item/weapon/coin/C = O
				if(C.string_attached)
					if(prob(50))
						to_chat(user, "<span class='notice'>You manage to yank \the [C] back out before the machine swallows it!</span>")
						user.put_in_hands(O)
					else
						to_chat(user, "<span class='notice'>You weren't able to pull \the [C] out in time and the machine swallows it, string and all.</span>")
						qdel(O)
			else
				qdel(O)
			to_chat(user, "<span class='notice'>You insert \a [O] into \the [src] and grab the joystick...</span>")
			if(istype(O, /obj/item/weapon/coin/pomf))
				play_game(user, PRIZEPOOL_POMF)
			else
				play_game(user, PRIZEPOOL_PREMIUM)
			return 1
	else if(istype(O, /obj/item/weapon/spacecash))
		//take money, dispense change, play regular game
		var/obj/item/weapon/spacecash/cash = O
		var/amount = cash.get_total()
		if(amount < cost_per_game)
			playsound(src, 'sound/machines/denied.ogg', 50, 1) //this pre-war machine only takes the exact amount or greater
			return
		qdel(cash)
		if(amount > cost_per_game)
			var/list/obj/item/weapon/spacecash/change = dispense_cash(amount - cost_per_game, src.loc)
			for(var/obj/item/weapon/spacecash/C in change)
				user.put_in_hands(C)
			if(prob(50))
				playsound(src, 'sound/items/polaroid1.ogg', 25, 1)
			else
				playsound(src, 'sound/items/polaroid2.ogg', 25, 1)
		to_chat(user, "<span class='notice'>You insert some credits into \the [src] and grab the joystick...</span>")
		play_game(user, PRIZEPOOL_STANDARD)
		return 1
	else if(!cost_per_game)
		//the games are on the house
		to_chat(user,"<span class='notice'>You hit the blinking start button on \the [src] and grab the joystick...</span>")
		play_game(user, PRIZEPOOL_STANDARD)
		return 1

/obj/machinery/claw_machine/proc/play_game(var/mob/user, var/prizepool = PRIZEPOOL_STANDARD)
	if(busy)
		return
	busy = TRUE
	use_power(10)
	flick("claw-playing", src)
	sleep(ANIMATION_LENGTH)
	var/winning_odds
	switch(prizepool)
		if(PRIZEPOOL_STANDARD)
			winning_odds = winning_odds_standard
		if(PRIZEPOOL_PREMIUM)
			winning_odds = winning_odds_premium
		if(PRIZEPOOL_POMF)
			winning_odds = 100
	if(prob(winning_odds))
		//dispense prize
		var/P
		if(prizepool == PRIZEPOOL_STANDARD)
			P = pick(prizes_standard)
		else if(prizepool == PRIZEPOOL_POMF)
			P = pick(prizes_pomf)
		else
			P = pick(prizes_premium)
		var/obj/item/toy/plushie/prize = new P(src.loc)
		to_chat(user, "<span class='notice'>\The [src] drops \a [prize] into its winnings chute with a satisfying clank.</span>")
		playsound(src, 'sound/machines/claw_machine_success.ogg', 50, 1)
	else
		//dispense disappointment
		to_chat(user, "<span class='notice'>\The [src]'s claw drops the prize it was carrying prematurely. Disappointing!</span>")
		playsound(src, 'sound/machines/claw_machine_fail.ogg', 50, 1)
	busy = FALSE

#undef PRIZEPOOL_STANDARD
#undef PRIZEPOOL_PREMIUM
#undef PRIZEPOOL_POMF
#undef ANIMATION_LENGTH
