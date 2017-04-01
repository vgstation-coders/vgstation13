/*
General Explination:
The research datum is the "folder" where all the research information is stored in a R&D console. It's also a holder for all the
various procs used to manipulate it. It has four variables and seven procs:

Variables:
- possible_tech is a list of all the /datum/tech that can potentially be researched by the player. The RefreshResearch() proc
(explained later) only goes through those when refreshing what you know. Generally, possible_tech contains ALL of the existing tech
but it is possible to add tech to the game that DON'T start in it (example: Xeno tech). Generally speaking, you don't want to mess
with these since they should be the default version of the datums. They're actually stored in a list rather then using typesof to
refer to them since it makes it a bit easier to search through them for specific information.
- know_tech is the companion list to possible_tech. It's the tech you can actually research and improve. Until it's added to this
list, it can't be improved. All the tech in this list are visible to the player.
- possible_designs is functionally identical to possbile_tech except it's for /datum/design.
- known_designs is functionally identical to known_tech except it's for /datum/design

Procs:
- TechHasReqs: Used by other procs (specifically RefreshResearch) to see whether all of a tech's requirements are currently in
known_tech and at a high enough level.
- DesignHasReqs: Same as TechHasReqs but for /datum/design and known_design.
- AddTech2Known: Adds a /datum/tech to known_tech. It checks to see whether it already has that tech (if so, it just replaces it). If
it doesn't have it, it adds it. Note: It does NOT check possible_tech at all. So if you want to add something strange to it (like
a player made tech?) you can.
- AddDesign2Known: Same as AddTech2Known except for /datum/design and known_designs.
- RefreshResearch: This is the workhorse of the R&D system. It updates the /datum/research holder and adds any unlocked tech paths
and designs you have reached the requirements for. It only checks through possible_tech and possible_designs, however, so it won't
accidentally add "secret" tech to it.
- UpdateTech is used as part of the actual researching process. It takes an ID and finds techs with that same ID in known_tech. When
it finds it, it checks to see whether it can improve it at all. If the known_tech's level is less then or equal to
the inputted level, it increases the known tech's level to the inputted level -1 or know tech's level +1 (whichever is higher).

The tech datums are the actual "tech trees" that you improve through researching. Each one has five variables:
- Name:		Pretty obvious. This is often viewable to the players.
- Desc:		Pretty obvious. Also player viewable.
- ID:		This is the unique ID of the tech that is used by the various procs to find and/or maniuplate it.
- Level:	This is the current level of the tech. All techs start at 1 and have a max of 20. Devices and some techs require a certain
level in specific techs before you can produce them.
- Req_tech:	This is a list of the techs required to unlock this tech path. If left blank, it'll automatically be loaded into the
research holder datum.

*/
/***************************************************************
**						Master Types						  **
**	Includes all the helper procs and basic tech processing.  **
***************************************************************/

var/global/list/design_list = list()
var/global/list/tech_list = list()

var/global/list/hidden_tech = list(
	/datum/tech,
	/datum/tech/nanotrasen,
	)

/datum/research								//Holder for all the existing, archived, and known tech. Individual to console.
	var/list/known_tech = list()			//List of locally known tech.
	var/list/known_designs = list()			//List of available designs (at base reliability).

/datum/research/New()		//Insert techs into possible_tech here. Known_tech automatically updated.
	if(!tech_list.len)
		for(var/T in typesof(/datum/tech) - hidden_tech)
			tech_list += new T()
	if(!design_list.len)
		for(var/D in typesof(/datum/design) - /datum/design)
			design_list += new D()
	RefreshResearch()



//Checks to see if tech has all the required pre-reqs.
//Input: datum/tech; Output: 0/1 (false/true)
/datum/research/proc/TechHasReqs(var/datum/tech/T)
	if(T.req_tech.len == 0)
		return 1
	var/matches = 0
	for(var/req in T.req_tech)
		for(var/datum/tech/known in known_tech)
			if((req == known.id) && (known.level >= T.req_tech[req]))
				matches++
				break
	if(matches == T.req_tech.len)
		return 1
	else
		return 0

//Checks to see if design has all the required pre-reqs.
//Input: datum/design; Output: 0/1 (false/true)
/datum/research/proc/DesignHasReqs(var/datum/design/D)
	if(D.req_tech.len == 0)
		return 1
	var/matches = 0
	var/list/k_tech = list()
	for(var/datum/tech/known in known_tech)
		k_tech[known.id] = known.level
	for(var/req in D.req_tech)
		if(!isnull(k_tech[req]) && k_tech[req] >= D.req_tech[req])
			matches++
	if(matches == D.req_tech.len)
		return 1
	else
		return 0
/*
//Checks to see if design has all the required pre-reqs.
//Input: datum/design; Output: 0/1 (false/true)
/datum/research/proc/DesignHasReqs(var/datum/design/D)
	if(D.req_tech.len == 0)
		return 1
	var/matches = 0
	for(var/req in D.req_tech)
		for(var/datum/tech/known in known_tech)
			if((req == known.id) && (known.level >= D.req_tech[req]))
				matches++
				break
	if(matches == D.req_tech.len)
		return 1
	else
		return 0
*/
//Adds a tech to known_tech list. Checks to make sure there aren't duplicates and updates existing tech's levels if needed.
//Input: datum/tech; Output: Null
/datum/research/proc/AddTech2Known(var/datum/tech/T)
	for(var/datum/tech/known in known_tech)
		if(T.id == known.id)
			if(T.level > known.level)
				known.level = T.level
			return 1
	known_tech += T
	return 2

/datum/research/proc/AddDesign2Known(var/datum/design/D)
	if(!(D in known_designs))
		for(var/datum/design/known in known_designs)
			if(D.id == known.id)
				if(D.reliability_mod > known.reliability_mod)
					known.reliability_mod = D.reliability_mod
				return
		known_designs += D
	return

//Refreshes known_tech and known_designs list. Then updates the reliability vars of the designs in the known_designs list.
//Input/Output: n/a
/datum/research/proc/RefreshResearch()
	for(var/datum/tech/PT in tech_list)
		if(TechHasReqs(PT))
			AddTech2Known(PT)
	for(var/datum/design/PD in design_list)
		if(DesignHasReqs(PD))
			AddDesign2Known(PD)
	for(var/datum/tech/T in known_tech)
		T = Clamp(T.level, 1, 20)
	for(var/datum/design/D in known_designs)
		D.CalcReliability(known_tech)
	return

//Refreshes the levels of a given tech.
//Input: Tech's ID and Level; Output: null
/datum/research/proc/UpdateTech(var/ID, var/level)
	for(var/datum/tech/KT in known_tech)
		if(KT.id == ID)
			if(KT.level <= level)
				KT.level = max((KT.level + 1), (level - 1))
	return

/datum/research/proc/UpdateDesign(var/path)
	for(var/datum/design/KD in known_designs)
		if(KD.build_path == path)
			KD.reliability_mod += rand(1,2)
			break
	return

/***************************************************************
 **						Technology Datums					  **
 **	Includes all the various technoliges and what they make.  **
 ***************************************************************/

datum/tech	//Datum of individual technologies.
	var/name = "name"					//Name of the technology.
	var/desc = "description"			//General description of what it does and what it makes.
	var/id = "id"						//An easily referenced ID. Must be alphanumeric, lower-case, and no symbols.
	var/level      = 1					//A simple number scale of the research level. Level 0 = Secret tech.
	var/max_level  = 1					// Maximum level this can be at (for admin hax)
	var/goal_level =-1					// Used for job objectives.  Set to max_level unless max_level is unobtainable.
	var/list/req_tech = list()			//List of ids associated values of techs required to research this tech. "id" = #
	var/new_category = null

/datum/tech/New()
	if(goal_level==-1)
		goal_level=max_level
	..()

//Trunk Technologies (don't require any other techs and you start knowning them).

datum/tech/materials
	name = "Materials Research"
	desc = "Development of new and improved materials."
	id = "materials"
	max_level=9
	goal_level=8 // 9 is Phazon.

datum/tech/engineering
	name = "Engineering Research"
	desc = "Development of new and improved engineering parts and."
	id = "engineering"
	max_level=5

datum/tech/phorontech
	name = "Phoron Research"
	desc = "Research into the mysterious substance colloqually known as 'phoron'."
	id = "phorontech"
	max_level=4

datum/tech/powerstorage
	name = "Power Manipulation Technology"
	desc = "The various technologies behind the storage and generation of electicity."
	id = "powerstorage"
	max_level=6

datum/tech/bluespace
	name = "'Blue-space' Research"
	desc = "Research into the sub-reality known as 'blue-space'"
	id = "bluespace"
	max_level =10
	goal_level=4 // Without phazon.

datum/tech/biotech
	name = "Biological Technology"
	desc = "Research into the deeper mysteries of life and organic substances."
	id = "biotech"
	max_level=5 // Max USABLE level.

datum/tech/combat
	name = "Combat Systems Research"
	desc = "The development of offensive and defensive systems."
	id = "combat"
	goal_level=5 // Pulse rifles don't count.
	max_level=6

datum/tech/magnets
	name = "Electromagnetic Spectrum Research"
	desc = "Research into the electromagnetic spectrum. No clue how they actually work, though."
	id = "magnets"
	goal_level=5 // No phazon
	max_level=8

datum/tech/programming
	name = "Data Theory Research"
	desc = "The development of new computer and artificial intelligence and data storage systems."
	id = "programming"
	max_level=5

datum/tech/syndicate
	name = "Illegal Technologies Research"
	desc = "The study of technologies that violate standard Nanotrasen regulations."
	id = "syndicate"
	goal_level=0 // Doesn't count towards maxed research, since it's illegal.
	max_level=8

datum/tech/nanotrasen
	name = "Nanotrasen Experimental Technologies"
	desc = "The research of miscellaneous bleeding-edge technologies, sponsored by Nanotrasen."
	id = "nanotrasen"
	goal_level=0 // Doesn't count towards maxed research, since it's bonus.
	max_level=8
	new_category = "Nanotrasen"

datum/tech/anomaly
	name = "Anomaly Research"
	desc = "The study of high energy materials and technology reconstruction."
	id = "anomaly"
	max_level=6

/*
datum/tech/arcane
	name = "Arcane Research"
	desc = "Research into the occult and arcane field for use in practical science"
	id = "arcane"
	level = 0 //It didn't become "secret" as advertised.

//Branch Techs
datum/tech/explosives
	name = "Explosives Research"
	desc = "The creation and application of explosive materials."
	id = "explosives"
	req_tech = list(Tc_MATERIALS = 3)

datum/tech/generators
	name = "Power Generation Technology"
	desc = "Research into more powerful and more reliable sources."
	id = "generators"
	req_tech = list(Tc_POWERSTORAGE = 2)

datum/tech/robotics
	name = "Robotics Technology"
	desc = "The development of advanced automated, autonomous machines."
	id = "robotics"
	req_tech = list(Tc_MATERIALS = 3, Tc_PROGRAMMING = 3)
*/


/obj/item/weapon/disk/tech_disk
	name = "Technology Disk"
	desc = "A disk for storing technology data for further research."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = W_CLASS_TINY
	starting_materials = list(MAT_IRON = 30, MAT_GLASS = 10)
	w_type = RECYK_ELECTRONIC
	var/datum/tech/stored

/obj/item/weapon/disk/tech_disk/New()
	..()
	src.pixel_x = rand(-5, 5) * PIXEL_MULTIPLIER
	src.pixel_y = rand(-5, 5) * PIXEL_MULTIPLIER

/obj/item/weapon/disk/tech_disk/nanotrasen
	name = "Technology Disk (Nanotrasen 1)"

/obj/item/weapon/disk/tech_disk/nanotrasen/New()
	..()
	stored = new/datum/tech/nanotrasen(src)

/obj/item/weapon/paper/tech_nanotrasen
	name = "paper - 'Nanotrasen Experimental Technologies'"
	info = "<B>Thank you for participating in this Nanotrasen-sponsored initiative!</B><BR><BR>This technology disk will open you the doors of Nanotrasen's most bleeding-edge experimental devices, and we look forward to you testing them for us! Also, note that you will still need to perform some research before these designs become available for you to print, but here's a guide to the tech levels that they will require.<br><ol><li><b>Hookshot</b>: Materials=2, Engineering=5, Electromagnetic=2</li><li><b>Ricochet Rifle</b>: Materials=3, Power=3, Combat=3</li><li><b>Gravity Well Gun</b>: Materials=7, Bluespace=5, Electromagnetic=5</li><li><b>Machine-Man Interface</b>: Biotech=4, Data Theory=4</li></ol><br>We look forward to the results of your experiments. Depending on their success we might grant you access to even more bleeding-edge technologies in the future! Make Science proud!<br><br><i>Central Command R&D Lab</i>"
