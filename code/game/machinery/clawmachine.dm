/*
 * A claw machine that hands out random plushies in exchange for quarters.
 */

#define PRIZEPOOL_STANDARD 1
#define PRIZEPOOL_PREMIUM 2
#define ANIMATION_LENGTH 28

/obj/machinery/claw_machine
	name = "claw machine"
	desc = "Exchange credits for disappointment. This pre-war model has an extra slot for antique coins, labeled \"PREMIUM\"."
	icon = 'icons/obj/plushie.dmi'
	icon_state = "claw"
	anchored = 1
	density = 1
	machine_flags = WRENCHMOVE | FIXED2WORK
	var/busy = FALSE
	var/cost_per_game = 5 //credits
	var/winning_odds_standard = 50 //percentage
	var/winning_odds_premium = 50

	var/list/prizes_standard = list(
		/obj/item/toy/plushie/bee,
		/obj/item/toy/plushie/bumbler,
		/obj/item/toy/plushie/bunny,
		/obj/item/toy/plushie/carp,
		/obj/item/toy/plushie/cat,
		/obj/item/toy/plushie/corgi,
		/obj/item/toy/plushie/fancypenguin,
		/obj/item/toy/plushie/goat,
		/obj/item/toy/plushie/kitten,
		/obj/item/toy/plushie/kitten/wizard,
		/obj/item/toy/plushie/monkey,
		/obj/item/toy/plushie/narsie,
		/obj/item/toy/plushie/ratvar,
		/obj/item/toy/plushie/nukie,
		/obj/item/toy/plushie/orca,
		/obj/item/toy/plushie/parrot,
		/obj/item/toy/plushie/penguin,
		/obj/item/toy/plushie/peacekeeper,
		/obj/item/toy/plushie/possum,
		/obj/item/toy/plushie/spacebear,
		/obj/item/toy/plushie/teddy
	)

	var/list/prizes_premium = list(
		/obj/item/toy/plushie/fumo/alice,
		/obj/item/toy/plushie/fumo/cirno,
		/obj/item/toy/plushie/fumo/marisa,
		/obj/item/toy/plushie/fumo/mokou,
		/obj/item/toy/plushie/fumo/nitori,
		/obj/item/toy/plushie/fumo/patchouli,
		/obj/item/toy/plushie/fumo/reimu,
		/obj/item/toy/plushie/fumo/remilia,
		/obj/item/toy/plushie/fumo/sakuya,
		/obj/item/toy/plushie/fumo/yukari
	)

/obj/machinery/claw_machine/examine(mob/user)
	if(cost_per_game)
		to_chat(user, "A small screen displays \"$[cost_per_game]\".")
	else
		to_chat(user, "A small screen displays \"FREE\".")

/obj/machinery/claw_machine/update_icon()
	..()
	if((stat & BROKEN) && icon_state != "claw-broken")
		icon_state = "claw-broken"
	else
		icon_state = "claw"

/obj/machinery/claw_machine/attackby(var/obj/O as obj, var/mob/user as mob)
	if(busy)
		to_chat(user, "<span class='notice'>\The [src] is already being used.</span>")
		return

	if(is_type_in_list(O, list(/obj/item/weapon/coin, /obj/item/weapon/reagent_containers/food/snacks/chococoin)))
		//take coin, play premium game
		if(user.drop_item(O, src))
			playsound(src, 'sound/machines/capsulebuy.ogg', 50, 1)
			if(istype(O, /obj/item/weapon/coin))
				var/obj/item/weapon/coin/C = O
				if(C.string_attached)
					if(prob(50))
						to_chat(user, "<span class='notice'>You manage to yank the coin back out before the machine swallows it!</span>")
						user.put_in_hands(O)
					else
						to_chat(user, "<span class='notice'>You weren't able to pull the coin out in time and the machine swallows it, string and all.</span>")
						qdel(O)
			else
				qdel(O)
			to_chat(user, "<span class='notice'>You insert a coin into \the [src] and grab the joystick...</span>")
			play_game(user, PRIZEPOOL_PREMIUM)
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
				playsound(src, 'sound/items/polaroid1.ogg', 50, 1)
			else
				playsound(src, 'sound/items/polaroid2.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You insert some credits into \the [src] and grab the joystick...</span>")
		play_game(user, PRIZEPOOL_STANDARD)
	else if(!cost_per_game)
		//the games are on the house
		to_chat(user,"<span class='notice'>You hit the blinking start button on \the [src] and grab the joystick...</span>")
		play_game(user, PRIZEPOOL_STANDARD)


/obj/machinery/claw_machine/proc/play_game(var/mob/user, var/prizepool = PRIZEPOOL_STANDARD)
	if(busy)
		return
	busy = TRUE
	flick("claw-playing", src)
	sleep(ANIMATION_LENGTH)
	var/winning_odds = prizepool == PRIZEPOOL_STANDARD ? winning_odds_standard : winning_odds_premium
	if(prob(winning_odds))
		//dispense prize
		var/P
		if(prizepool == PRIZEPOOL_STANDARD)
			P = pick(prizes_standard)
		else
			P = pick(prizes_premium)
		var/obj/item/toy/plushie/prize = new P(src.loc)
		to_chat(user, "<span class='notice'>\The [src] drops \a [prize] into its winnings chute with a satisfying clank.</span>")
		playsound(src, 'sound/machines/claw_machine_success.ogg', 50, 1)
	else
		//dispense disappointment
		src.visible_message("<span class='notice'>\The [src]'s claw drops the prize it was carrying prematurely. Disappointing!</span>")
		playsound(src, 'sound/machines/claw_machine_fail.ogg', 50, 1)
	busy = FALSE

#undef PRIZEPOOL_STANDARD
#undef PRIZEPOOL_PREMIUM
#undef ANIMATION_LENGTH
