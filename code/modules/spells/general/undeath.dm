/spell/undeath
	name = "Cheat Death"
	desc = "Instantly return to un-life."
	abbreviation = "UD"

	school = "vampire"
	user_type = USER_TYPE_VAMPIRE

	charge_type = Sp_RECHARGE
	charge_max = 1 SECONDS
	invocation_type = SpI_NONE
	range = 0
	spell_flags = STATALLOWED | NEEDSHUMAN
	cooldown_min = 45 SECONDS

	override_base = "vamp"
	hud_state = "vamp_cheatdeath"

	var/blood_cost = 0

/spell/undeath/cast_check(var/skipcharge = 0, var/mob/user = usr)
	. = ..()
	var/datum/role/vampire/V = isvampire(user)
	if (!.) // No need to go further.
		return FALSE
	if (!user.vampire_power(blood_cost, DEAD))
		return FALSE
	if (!user.isDead())
		to_chat(user, "<span class='warning'>You need to be dead to do that. Well, you're already dead; undead to be precise, but you need to be DEAD dead to use it.</span>")
		return FALSE
	if(user.on_fire || V && V.smitecounter)
		to_chat(user, "<span class='warning'>Your corpse has been sanctified!</span>")
		return FALSE

/spell/undeath/choose_targets(var/mob/user = usr)
	return list(user) // Self-cast

/spell/undeath/cast(var/list/targets, var/mob/user)

	var/datum/role/vampire/V = isvampire(user)
	if (V.reviving)
		to_chat(user, "<span class='warning'>You are already rising from your grave.</span>")
		return FALSE

	var/mob/living/carbon/human/H = user
	to_chat(H, "You attempt to recover. This may take between 30 and 45 seconds.")
	V.reviving = TRUE
	var/delay = rand(30 SECONDS, 45 SECONDS)

	spawn()
		user.update_canmove()
		sleep(delay)
		if (H.client && cast_check()) // If he didn't log out + if we didn't get revived/smitted in the meantime already
			to_chat(H, "<span class='sinister'>Your corpse twitches slightly. It's safe to assume nobody noticed.</span>")
			to_chat(H, "<span class = 'notice'>Click the action button to revive.</span>")
			var/datum/action/undeath/undeath_action = new()
			undeath_action.Grant(H)
		else
			to_chat(H, "<span class = 'warning'>It seems you couldn't complete the spell.</span>")
			V.reviving = FALSE
			return FALSE

// Action button for actual revival

/datum/action/undeath
	name = "Return to unlife"
	desc = "Allows you to walk among the living once more."
	icon_icon = 'icons/mob/screen_spells.dmi'
	button_icon_state = "vamp_cheatdeath2"

/datum/action/undeath/Trigger()
	var/mob/living/M = owner
	var/datum/role/vampire/V = isvampire(M)
	M.revive(FALSE)
	V.remove_blood(V.blood_usable-10)
	V.check_vampire_upgrade()
	V.reviving = FALSE
	to_chat(M, "<span class='sinister'>You awaken, ready to strike fear into the hearts of mortals once again.</span>")
	Remove(owner)
