/spell/changeling/boost_range
	name = "Ranged Sting"
	desc = "We evolve the ability to shoot our stingers at humans, with some preperation."
	abbreviation = "BR"

	chemcost = 10

//Boosts the range of your next sting attack by 1
/spell/changeling/boost_range/cast(var/list/targets, var/mob/user)
    var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)
	if(!changeling)
		return 0
	to_chat(user, "<span class='notice'>Our throat adjusts to launch the sting.</span>")
	changeling.sting_range = 2
	feedback_add_details("changeling_powers","RS")

	..()

