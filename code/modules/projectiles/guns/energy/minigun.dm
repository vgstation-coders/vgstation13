/obj/item/weapon/gun/energy/gatling
	name = "gatling laser"
	desc = "An ancient gatling laser. The inscriptions are unreadable. Rigged to be powered by energy cells."

	icon = 'icons/obj/gun_experimental.dmi'
	var/base_icon_state = "minigun_laser"
	icon_state = "minigun_laser"
	item_state = "minigun_laser0"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')

	projectile_type = "/obj/item/projectile/beam/weaklaser"

	fire_sound = 'sound/weapons/gatling_energy.ogg'
	empty_sound = 'sound/weapons/gatling_empty.ogg'
	var/end_sound = 'sound/weapons/gatling_energy_end.ogg' // Plays at the end of a burst
	reload_sound = 'sound/weapons/gatling_reload.ogg'
	unload_sound = 'sound/weapons/gatling_unload.ogg'

	w_class = W_CLASS_HUGE
	w_type = RECYK_ELECTRONIC

	flags = FPRINT | TWOHANDABLE | SLOWDOWN_WHEN_CARRIED
	slowdown = MINIGUN_SLOWDOWN_NONWIELDED

	detachable_cell = TRUE
	rechargeable = FALSE // Does not fit in a recharger, it's just too huge!

	origin_tech = Tc_COMBAT + "=6;" + Tc_POWERSTORAGE + "=5" + Tc_MATERIALS + "=5"

	cell_type = "/obj/item/weapon/cell/high"
	charge_cost = 100
	var/beams_per_burst = 10
	fire_delay = 1
	delay_user = 2

/obj/item/weapon/gun/energy/gatling/New()
	. = ..()

	if (prob(50))
		fire_sound = 'sound/weapons/gatling_energy_alt.ogg'
		end_sound = 'sound/weapons/gatling_energy_alt_end.ogg'

/obj/item/weapon/gun/energy/gatling/rusty
	desc = "An ancient gatling laser. The battery compartment is rusted shut."

	detachable_cell = FALSE
	projectile_type = "/obj/item/projectile/beam/weakerlaser"

/obj/item/weapon/gun/energy/gatling/update_wield(mob/user)
	item_state = "[base_icon_state][wielded ? 1 : 0]"
	if (wielded)
		slowdown = MINIGUN_SLOWDOWN_WIELDED
	else
		slowdown = MINIGUN_SLOWDOWN_NONWIELDED

/obj/item/weapon/gun/energy/gatling/attack_self(mob/user)
	if (wielded)
		unwield(user)
	else
		wield(user)

/obj/item/weapon/gun/energy/gatling/examine(mob/user)
	..()
	if (!power_supply || power_supply.maxcharge == 0)
		return
	to_chat(user, "<span class='info'>The power meter reads [(power_supply.charge / power_supply.maxcharge) * 100]%.</span>")

/obj/item/weapon/gun/energy/gatling/afterattack(atom/A, mob/living/user, flag, params, struggle = 0)
	if (flag)
		return
	if (!wielded)
		to_chat(user, "<span class='warning'>You must dual-wield \the [src] before you can fire it!</span>")
		return
	return ..()

/obj/item/weapon/gun/energy/gatling/Fire(atom/target, mob/living/user, params, reflex = 0, struggle = 0, var/use_shooter_turf = FALSE)
	if (!power_supply || power_supply.charge < charge_cost)
		return click_empty()

	..()

	var/list/turf/possible_turfs = list()
	for (var/turf/T in orange(target, 1))
		possible_turfs += T
	spawn()
		for (var/i = 1; i < beams_per_burst; i++)
			if (power_supply.charge < charge_cost)
				break
			sleep(0.5)
			var/newturf = pick(possible_turfs)
			..(newturf, user, params, reflex, struggle)
		playsound(src, end_sound, 100, 1)
