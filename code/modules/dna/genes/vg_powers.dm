/*
This is /vg/'s nerf for hulk.  Feel free to steal it.

Obviously, requires DNA2.
*/

// When hulk was first applied (world.time).
/mob/living/carbon/human/var/hulk_time = 0
/mob/living/carbon/human/var/hulk_gene_active = FALSE //To avoid bugging out with the wizard's Mutate spell, differentiates them

// In decaseconds.
#define HULK_DURATION 300 // How long the effects last
#define HULK_COOLDOWN 600 // How long they must wait to hulk out.

/datum/dna/gene/basic/grant_spell/hulk
	name = "Hulk"
	desc = "Allows the subject to become the motherfucking Hulk."
	activation_messages = list("Your muscles hurt.")
	deactivation_messages = list("Your muscles quit tensing.")

	drug_activation_messages = list("You feel strong! You must've been working out lately.")
	drug_deactivation_messages = list("You return to your old lifestyle.")

	flags = GENE_UNNATURAL // Do NOT spawn on roundstart.

	spelltype = /spell/targeted/genetic/hulk

/datum/dna/gene/basic/grant_spell/hulk/deactivate(var/mob/M, var/connected, var/flags)
	M.mutations.Remove(M_HULK)
	M.update_mutations()
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		H.update_body()
	return ..()

/datum/dna/gene/basic/grant_spell/hulk/New()
	..()
	block = HULKBLOCK

/datum/dna/gene/basic/grant_spell/hulk/OnMobLife(var/mob/living/carbon/human/M)
	if(!istype(M))
		return
	if((M_HULK in M.mutations) && M.hulk_gene_active)
		var/timeleft = M.hulk_time - world.time
		if(M.health <= 25 || timeleft <= 0)
			M.hulk_time = 0
			M.mutations.Remove(M_HULK)
			M.hulk_gene_active = FALSE
			M.update_mutations()		//update our mutation overlays
			M.update_body()
			to_chat(M, "<span class='warning'>You suddenly feel very weak.</span>")
			M.Knockdown(3)
			M.Stun(3)
			M.emote("collapse")

/spell/targeted/genetic/hulk
	name = "Hulk Out"
	panel = "Mutant Powers"
	user_type = USER_TYPE_GENETIC
	range = SELFCAST

	charge_type = SP_RECHARGE
	charge_cooldown_max = HULK_COOLDOWN

	duration = HULK_DURATION

	spell_flags = INCLUDEUSER

	invocation_type = SP_INV_NONE

	override_base = "genetic"
	hud_state = "gen_hulk"

/spell/targeted/genetic/hulk/New()
	desc = "Get mad!  For [duration/10] seconds, anyway."
	..()

/spell/targeted/genetic/hulk/before_cast(list/targets, user, bypass_range)
	var/mob/living/carbon/human/H = user
	if(istype(H) && (M_HULK in H.mutations))
		to_chat(user, "<span class='warning'>You are already hulking out!</span>")
		return list()
	return ..()

/spell/targeted/genetic/hulk/cast(list/targets, mob/user)
	if (istype(user.loc,/mob))
		to_chat(usr, "<span class='warning'>You can't hulk out right now!</span>")
		return 1
	for(var/mob/living/carbon/human/M in targets)
		M.hulk_time = world.time + src.duration
		M.mutations.Add(M_HULK)
		M.update_mutations()		//update our mutation overlays
		M.update_body()
		M.hulk_gene_active = TRUE
		//M.say(pick("",";")+pick("HULK MAD","YOU MADE HULK ANGRY")) // Just a note to security.
		log_admin("[key_name(M)] has hulked out! ([formatJumpTo(M)])")
		message_admins("[key_name(M)] has hulked out! ([formatJumpTo(M)])")
	return

/datum/dna/gene/basic/grant_spell/farsight
	name = "Farsight"
	desc = "Increases the subjects ability to see things from afar."
	activation_messages = list("Your eyes focus.")
	deactivation_messages = list("Your eyes return to normal.")
	drug_activation_messages = list("You start feeling like an eagle, man!")
	drug_deactivation_messages = list("You feel less like an eagle and more like the rabbit!")
	spelltype = /spell/targeted/farsight

/datum/dna/gene/basic/grant_spell/farsight/New()
	block = FARSIGHTBLOCK
	..()

/datum/dna/gene/basic/grant_spell/farsight/can_activate(var/mob/M,var/flags)
	// Can't be big AND small.
	if((M.sdisabilities & BLIND) || (M.disabilities & NEARSIGHTED))
		return 0
	return ..(M,flags)

/datum/dna/gene/basic/grant_spell/farsight/deactivate(var/mob/M,var/connected,var/flags)
	if(..())
		if(M.client && M.client.view == world.view + 2)
			M.client.changeView()

/spell/targeted/farsight
	name = "Far Sight"
	desc = "Allows you to toggle farther vision at will."
	user_type = USER_TYPE_GENETIC
	panel = "Mutant Powers"
	range = SELFCAST
	charge_type = SP_RECHARGE
	charge_cooldown_max = 5 SECONDS
	invocation_type = SP_INV_NONE
	spell_flags = INCLUDEUSER
	override_base = "genetic"
	hud_state = "wiz_sleepold"
	var/active = 0

/spell/targeted/farsight/cast(list/targets, mob/user)
	for(var/mob/living/carbon/human/F in targets)
		if(!active)
			F.client.changeView(max(F.client.view, world.view+2))
			to_chat(F, "<span class='notice'>You focus your eyes to see farther.</span>")
			active = 1
		else
			F.client.changeView()
			to_chat(F, "<span class='notice'>You no longer focus your eyes.</span>")
			active = 0

// NOIR

#define NOIR_ANIM_TIME 170

/datum/dna/gene/basic/noir
	name = "Noir"
	desc = "In recent years there's been a real push towards 'Detective Noir' movies, but since the last black and white camera was lost many centuries ago, scientists had to develop a way to turn any movie noir."
	activation_messages = list("The vibrant colors of the station hit your eyes for the last time before fading into a more appropriate tone. Something's off about this place, but you can't quite put your finger on it. You're compelled to check out the bar, maybe get to the bottom of what's going on in this godforsaken place.")
	deactivation_messages = list("You now feel soft-boiled.")
	activation_prob = 100
	mutation = M_NOIR

/datum/dna/gene/basic/noir/New()
	block = NOIRBLOCK
	..()

/datum/dna/gene/basic/noir/activate(var/mob/M)
	..()
	M.update_colour(NOIR_ANIM_TIME)
	if(M.client) // wow it's almost like non-client mobs can get mutations!
		M << sound('sound/misc/noirdarkcoffee.ogg')

/datum/dna/gene/basic/noir/deactivate(var/mob/M,var/connected,var/flags)
	if(..())
		M.update_colour(NOIR_ANIM_TIME)
		if(M.client)
			M.client.screen -= noir_master

//CHARGE

/datum/dna/gene/basic/grant_spell/charge
	name = "CHARGE"
	desc = "Peform a short sprint, knocking down walls and people alike.</span>"
	activation_messages = list("You feel a surge of energy in your body.")
	deactivation_messages = list("You suddenly don't feel so pumped.")

	drug_activation_messages = list()
	drug_deactivation_messages = list()

	spelltype = /spell/targeted/charge
	flags = GENE_UNNATURAL // Do NOT spawn on roundstart.

/datum/dna/gene/basic/grant_spell/charge/New()
	..()
	block = CHARGEBLOCK

/spell/targeted/charge
	name = "Charge"
	desc = "Charge forward, knocking down walls and people alike.</span>"
	panel = "Mutant Powers"
	user_type = USER_TYPE_GENETIC
	range = 4

	charge_type = SP_RECHARGE
	charge_cooldown_max = 15 SECONDS

	spell_flags = WAIT_FOR_CLICK | CAN_CHANNEL_RESTRAINED
	invocation_type = SP_INV_NONE

	hud_state = "gen_leap"
	override_base = "genetic"

/spell/targeted/charge/choose_targets(var/mob/user = usr)
	return list(user)

/spell/targeted/charge/cast_check(var/skipcharge = FALSE, var/mob/user = usr)
	if(user.throwing)
		return FALSE
	else
		return ..()

/mob/living/carbon/human/var/charge_gene_active = FALSE

/mob/living/carbon/human/var/throw_source = null

/spell/targeted/charge/cast(var/list/targets, var/mob/user)
    var/mob/living/carbon/human/human = null
    if (istype(user, /mob/living/carbon/human))
        human = user
    // Only proceed if the spell is not on cooldown and can be cast
    if (!src.cast_check(FALSE, user))
        // Reset throw_source if charge can't be cast
        if (human)
            human.throw_source = null
            human.charge_gene_active = FALSE
        return
    playsound(user, 'sound/effects/chargeaction.ogg', 100, 1)
    if (human)
        human.charge_gene_active = TRUE
        human.throw_source = "charge"
        var/landing = get_distant_turf(get_turf(user), human.dir, range)
        human.throw_at(landing, range, 2)

/mob/living/carbon/human/special_thrown_behaviour()
	if(src.throw_source == "charge" && src.charge_gene_active)
		throwing = 2 // charge throw
	else
		throwing = 1 // normal throw (tackle, slip, etc.)
		// Always clear charge state for non-charge throws
		src.throw_source = null
		src.charge_gene_active = FALSE

/mob/living/carbon/human/to_bump(var/atom/obstacle)
    var/dash_dir = null
    var/turf/crashing = null

    // Charge bump logic
    if(src.throwing && src.throw_source == "charge" && src.charge_gene_active)
        var/breakthrough = 0

        // Break all windows, grilles, tables, racks on this tile
        for(var/obj/O in get_turf(obstacle))
            if(istype(O, /obj/structure/window/))
                var/obj/structure/window/W = O
                W.shatter()
                breakthrough = 1
            else if(istype(O, /obj/structure/grille/))
                var/obj/structure/grille/G = O
                G.health = 0
                G.healthcheck()
                breakthrough = 1
            else if(istype(O, /obj/structure/table))
                var/obj/structure/table/T = O
                T.destroy()
                breakthrough = 1
            else if(istype(O, /obj/structure/rack))
                new /obj/item/weapon/rack_parts(O.loc)
                qdel(O)
                breakthrough = 1

        // Handle walls as before
        if(istype(obstacle, /turf/simulated/wall))
            var/turf/simulated/wall/W = obstacle
            if (W.hardness <= 60)
                playsound(W, 'sound/weapons/chargeimpact.ogg', 75, 1)
                W.dismantle_wall(1)
                breakthrough = 1
            src.throwing = 0
            src.charge_gene_active = FALSE
            src.throw_source = null

        else if(istype(obstacle, /obj/structure/reagent_dispensers))
            var/obj/structure/reagent_dispensers/R = obstacle
            R.explode(src)

        else if(istype(obstacle, /mob/living))
            var/mob/living/L = obstacle
            if (L.flags & INVULNERABLE)
                src.throwing = 0
                src.charge_gene_active = FALSE
                src.throw_source = null
            else if (!(L.status_flags & CANKNOCKDOWN) || (M_HULK in L.mutations) || istype(L,/mob/living/silicon))
                src.throwing = 0
                src.charge_gene_active = FALSE
                src.throw_source = null
                L.take_overall_damage(5,0)
                if(L.locked_to)
                    L.locked_to.unlock_atom(L)
            else
                L.take_overall_damage(5,0)
                if(L.locked_to)
                    L.locked_to.unlock_atom(L)
                L.Stun(2)
                L.Knockdown(2)
                L.apply_effect(5, STUTTER)
                playsound(src, 'sound/weapons/chargeimpact.ogg', 50, 0, 0)
                breakthrough = 1
        else
            src.throwing = 0
            src.charge_gene_active = FALSE
            src.throw_source = null

        if(breakthrough)
            dash_dir = src.dir
            crashing = get_step(get_turf(src), dash_dir)
            if(crashing && !istype(crashing, /turf/space))
                spawn(1)
                    src.throw_at(crashing, 50, src.throw_speed)
                return
            src.throwing = 0
            src.charge_gene_active = FALSE
            src.throw_source = null

    else
        ..()
