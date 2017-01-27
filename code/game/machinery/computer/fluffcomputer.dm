/* this entire thing is a non player operatable computer that just gives a access denied message or something like that when you try to use it.
It does nothing and only serves to look good and for immhulsions. intended for vaults away missions and things of that sort.
This is not related to actual functional consoles in any way */

/obj/machinery/computer/unusable_communication_relay
    name = "Communications Relay"
    desc = "A code locked console that you do not know how to use. Probably doesnt do anything interesting."
    icon_state = "comm"
    circuit = "/obj/item/weapon/circuitboard/unusable_communication_relay"

    light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/unusable_communication_relay/attack_ai(var/mob/user as mob)
        to_chat(user, "The systems firewall prevents you from accessing it.")

/obj/machinery/computer/unusable_communication_relay/attack_paw(var/mob/user as mob)

    return src.attack_hand(user)
    return

/obj/machinery/computer/unusable_communication_relay/attack_hand(var/mob/user as mob)
    say("Access Denied")


/obj/machinery/computer/unusable_communication_relay/emag(mob/user as mob)
    to_chat(user, "You hold the cryptographic sequencer up to the ID scanner and nothing happens. Guess this only works with NT technology ")

/obj/machinery/computer/unusable_shuttle_control_1 /*fluff shuttle console 1 */
    name = "Shuttle Control"
    desc = "A code locked console that controls the ship. Doesnt look like you will be flying the ship anytime soon."
    icon_state = "shuttle"
    circuit = "/obj/item/weapon/circuitboard/unusable_shuttle_control_1"

    light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/unusable_shuttle_control_1/attack_ai(var/mob/user as mob)
        to_chat(user, "The systems firewall prevents you from accessing it.")

/obj/machinery/computer/unusable_shuttle_control_1/attack_paw(var/mob/user as mob)

    return src.attack_hand(user)
    return

/obj/machinery/computer/unusable_shuttle_control_1/attack_hand(var/mob/user as mob)
    say("Access Denied")

/obj/machinery/computer/unusable_shuttle_control_1/emag(mob/user as mob)
    to_chat(user, "You hold the cryptographic sequencer up to the ID scanner and nothing happens. Guess this only works with NT technology")

/obj/machinery/computer/unusable_shuttle_control_2 /*fluff shuttle control 2 */
    name = "Shuttle Control"
    desc = "A code locked console that controls the ship. Doesn't look like you will be flying the ship anytime soon."
    icon_state = "syndishuttle"
    circuit = "/obj/item/weapon/circuitboard/unusable_shuttle_control_2"

    light_color = LIGHT_COLOR_RED

/obj/machinery/computer/unusable_shuttle_control_2/attack_ai(var/mob/user as mob)
        to_chat(user, "The systems firewall prevents you from accessing it.")

/obj/machinery/computer/unusable_shuttle_control_2/attack_paw(var/mob/user as mob)

    return src.attack_hand(user)
    return

/obj/machinery/computer/unusable_shuttle_control_2/attack_hand(var/mob/user as mob)
    say("Access Denied")

/obj/machinery/computer/unusable_shuttle_control_2/emag(mob/user as mob)
    to_chat(user, "You hold the cryptographic sequencer up to the ID scanner and nothing happens. Guess this only works with NT technology")


/obj/machinery/computer/unusable_shuttle_engine_control /*fluff shuttle console 3 */
    name = "Engine Control"
    desc = "A code locked console that controls the ship's engines and power systems."
    icon_state = "airtunnel01"
    circuit = "/obj/item/weapon/circuitboard/unusable_shuttle_engine_control"

    light_color = LIGHT_COLOR_RED

/obj/machinery/computer/unusable_shuttle_engine_control/attack_ai(var/mob/user as mob)
        to_chat(user, "The systems firewall prevents you from accessing it.")

/obj/machinery/computer/unusable_shuttle_engine_control/attack_paw(var/mob/user as mob)

    return src.attack_hand(user)
    return

/obj/machinery/computer/unusable_shuttle_engine_control/attack_hand(var/mob/user as mob)
    say("Access Denied")

/obj/machinery/computer/unusable_shuttle_engine_control/emag(mob/user as mob)
    to_chat(user, "You hold the cryptographic sequencer up to the ID scanner and nothing happens. Guess this only works with NT technology ")


 /* the next 2 are for the white ship */

/obj/machinery/computer/whiteship_console_1  /*console 1*/
    name = "Starmap"
    desc = "A console with a map of the local area. Just by looking at this thing you can tell it is years out of date and is too old to be used effectivly"
    icon_state = "comm_serv"
    circuit = "/obj/item/weapon/circuitboard/whiteship_console_1"

    light_color = LIGHT_COLOR_GREEN

/obj/machinery/computer/whiteship_console_1/attack_ai(var/mob/user as mob)
        to_chat(user, "The console is so old that it cannot be remotely controlled by silicons.")

/obj/machinery/computer/whiteship_console_1/attack_paw(var/mob/user as mob)

    return src.attack_hand(user)
    return

/obj/machinery/computer/whiteship_console_1/attack_hand(var/mob/user as mob)
    say("Access Denied") /* maybe if it displayed a static image of like a outdated map of the local area for lore purposes? */

/obj/machinery/computer/whiteship_console_1/emag(mob/user as mob)
	to_chat(user, "The cryptographic sequencer causes some lights on the console to light up before emitting a dull buzzing noise.")


/obj/machinery/computer/whiteship_console_2  /*console 2*/
    name = "Engine Control"
    desc = "A console displaying the status of the ship's engines."
    icon_state = "engine1"
    circuit = "/obj/item/weapon/circuitboard/whiteship_console_2"

    light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/whiteship_console_2/attack_ai(var/mob/user as mob)
        to_chat(user, "The console is so old that it cannot be remotely controlled by silicons.")

/obj/machinery/computer/whiteship_console_2/attack_paw(var/mob/user as mob)

    return src.attack_hand(user)
    return

/obj/machinery/computer/whiteship_console_2/attack_hand(var/mob/user as mob)
    say("WARNING: FUEL RESERVES LOW. ENGINES SHUTTING DOWN.") /*needs a better message for why it doesnt work. Taking suggestions */

/obj/machinery/computer/whiteship_console_2/emag(mob/user as mob)
    to_chat(user, "The cryptographic sequencer causes some lights on the console to light up before emitting a dull buzzing noise.")
