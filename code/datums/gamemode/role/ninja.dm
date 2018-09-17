/datum/role/ninja
	name = "Space Ninja"
	id = NINJA
	logo_state = "ninja-logo"

/datum/role/ninja/OnPostSetup()
	. =..()
	if(ishuman(antag.current))
		antag.current << sound('sound/effects/gong.ogg')
		equip_ninja(antag.current)
		name_ninja(antag.current)

/datum/role/ninja/ForgeObjectives()
	AppendObjective(/datum/objective/target/steal)
	AppendObjective(/datum/objective/target/assassinate)
	AppendObjective(/datum/objective/target/skulls)
	AppendObjective(/datum/objective/escape)