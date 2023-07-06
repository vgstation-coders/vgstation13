// PHARAOH'S RICHES
//
// Adjust your bet if your poor!
// Get 10 ANKH RANKHS to enter the BONUS MODE, receiving free spins and
//   a chance to win the SPECIAL JACKPOT

// TODO:
//   Steal a bunch of sounds from Pharaoh
//   Spirites (ask for help)
//   write the code lol

/obj/machinery/computer/slot_machine/pharaoh
	name = "Pharaoh's Riches"
	desc = "Abandon hope all ye who enter here."
	icon = 'icons/obj/slot_machine.dmi'
	icon_state = "slot"

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK
	computer_flags = NO_ONOFF_ANIMS

	var/image/overlay_1
	var/image/overlay_2
	var/image/overlay_3

	var/value_1 = 1
	var/value_2 = 1
	var/value_3 = 1

	var/current_bet = 1 //players can set their own bet up to ??? 100? more?
	var/stored_money = 0
	var/current_ankhs = 0

	var/spinning = 0

/obj/machinery/computer/slot_machine/pharaoh/New()
	. = ..()
	update_icon()

/obj/machinery/computer/slot_machine/pharaoh/update_icon()
	..()
	//blah

/obj/machinery/computer/slot_machine/pharaoh/attackby(obj/item/I as obj, mob/user as mob)
	..()
	if (istype(I,/obj/item/weapon/spacecash))
		var/obj/item/weapon/spacecash/S = I
		var/money_add = S.amount * S.worth
		if (user.drop_item(I))
			qdel(I)
			src.stored_money += money_add
			src.updateUsrDialog()

/obj/machinery/computer/slot_machine/pharaoh/proc/spin(mob/user)
	if (spinning)
		return

	if (stored_money >= current_bet)
		stored_money -= current_bet
	else
		return

	spinning = 1

	//reset overlays

	//actually roll the wheel values

	//set overlay to spinning

	//sleeps, set wheels, play sound, 3x

	//check scores on wheels (??? we can do this earlier while its spinning)

	spinning = 0


