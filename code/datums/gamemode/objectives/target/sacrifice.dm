// For legacy cult

/datum/objective/target/assasinate/sacrifice
    name = "Sacrifice <target>"
    bad_assassinate_targets = list("AI","Cyborg","Mobile MMI","Trader", "Chief Medical Officer", "Research Director", "Chief Engineer", 
                                    "Medical Doctor", "Paramedic", "Chemist", "Geneticist", "Virologist",
                                    "Scientist", "Roboticist",
                                    "Station Engineer", "Atmospheric Technician", "Mechanic",
                                    "Cargo Technician", "Quarter Master",
                                    "Bartender", "Chef", "Botanist", "Mime", "Clown", "Assistant") // Basically anyone that is not sec or chaplain.

/datum/objective/target/assassinate/sacrifice/find_target()
	..()
	if(target && target.current)
		explanation_text = "Sacrifice [target.current.real_name], the [target.assigned_role=="MODE" ? (target.special_role) : (target.assigned_role)]."
		return TRUE
	return FALSE


/datum/objective/target/assassinate/sacrifice/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Sacrifice [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
		return TRUE
	return FALSE

/datum/objective/target/assassinate/sacrifice/feedbackText()
	if(target && target.current)
		return "<span class = 'sinister'>You succesfully sacrificied [target.current.real_name]. The veil between this world and Nar'Sie grows thinner.</span>"
  		//return "<span class = 'sinister'>You succesfully sacrificied [target.current.real_name]. The veil between this world and Nar'Sie grows thinner.</span>"
