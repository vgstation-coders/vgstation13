//________________________________________________

#define ADD_REVOLUTIONARY_FAIL_IS_COMMAND -1
#define ADD_REVOLUTIONARY_FAIL_IS_JOBBANNED -2
#define ADD_REVOLUTIONARY_FAIL_IS_IMPLANTED -3
#define ADD_REVOLUTIONARY_FAIL_IS_REV -4

/datum/faction/revolution
	name = "Revolutionaries"
	ID = REVOLUTION
	required_pref = ROLE_REV
	initial_role = HEADREV
	late_role = REV
	desc = "Viva!"
	logo_state = "rev-logo"
	initroletype = /datum/role/revolutionary/leader
	roletype = /datum/role/revolutionary

/datum/faction/revolution/HandleRecruitedMind(var/datum/mind/M)
	if(M.assigned_role in command_positions)
		return ADD_REVOLUTIONARY_FAIL_IS_COMMAND

	var/mob/living/carbon/human/H = M.current

	if(jobban_isbanned(H, "revolutionary"))
		return ADD_REVOLUTIONARY_FAIL_IS_JOBBANNED

	for(var/obj/item/weapon/implant/loyalty/L in H) // check loyalty implant in the contents
		if(L.imp_in == H) // a check if it's actually implanted
			return ADD_REVOLUTIONARY_FAIL_IS_IMPLANTED

	if(isrev(H)) //HOW DO YOU FUCK UP THIS BADLY.
		return ADD_REVOLUTIONARY_FAIL_IS_REV

	return ..()

/datum/faction/revolution/forgeObjectives()
	var/list/heads = get_living_heads()
	for(var/datum/mind/head_mind in heads)
		var/datum/objective/target/assassinate/A = new(auto_target = FALSE)
		if(A.set_target(head_mind))
			AppendObjective(A)

#define ALL_HEADS_DEAD 1
#define ALL_REVS_DEAD 2

/datum/faction/revolution/process()
    // -- 1. Are all the heads dead ?
    var/total_heads = 0
    var/incapacitated_heads = 0

    for (var/mob/living/carbon/human/H in player_list)
        var/datum/mind/M = H.mind
        if (!M)
            continue
        if (M.assigned_role in command_positions)
            total_heads++
            if (H.isDead() || H.z =! map.zMainStation)
                incapacitated_heads++

    if (incapacitated_heads >= total_heads)
        return end(ALL_HEADS_DEAD)