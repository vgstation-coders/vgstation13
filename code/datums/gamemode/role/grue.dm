/datum/role/grue
	name = GRUE
	id = GRUE
	special_role = GRUE
	required_pref = ROLE_GRUE
//	wikiroute = ROLE_GRUE
	logo_state = "grue-logo"
	default_admin_voice = "Your Grue Instincts"
	admin_voice_style = "grue"
	var/eatencount=0

/datum/role/grue/Greet()
	to_chat(antag.current, "<span class='danger'>You are a grue.</span>")
	to_chat(antag.current, "<span class='danger'>Darkness is your ally, bright light is harmful to your kind. You hunger... specifically for sentient beings, but you are still young and cannot eat until you are fully mature.</span>")
	to_chat(antag.current, "<span class='danger'>Bask in shadows to prepare to moult. The more sentient beings you eat, the more powerful you will become.</span>")

/datum/role/grue/ForgeObjectives()
	AppendObjective(/datum/objective/grue/eat_basic)