#define MAX_DESIGNS 10

//The advanced pea-green monochrome lcd of tomorrow.

var/global/list/obj/item/device/pda/PDAs = list()


/obj/item/device/pda
	name = "\improper PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a preprogrammed ROM cartridge. Can download additional applications from PDA terminals."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	item_state = "electronic"
	w_class = 1.0
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_ID | SLOT_BELT

	//Main variables
	var/owner = null
	var/default_cartridge = 0 // Access level defined by cartridge
	var/obj/item/weapon/cartridge/cartridge = null //current cartridge
	var/mode = 0 //Controls what menu the PDA will display. 0 is hub; the rest are either built in or based on cartridge.

	//Secondary variables
	var/scanmode = 0 //1 is medical scanner, 2 is forensics, 3 is reagent scanner, 4 is halogen counter, 5 is gas scanner, 6 is device analyser -- keep this list updated if you add one
	var/fon = 0 //Is the flashlight function on?
	l_color = "#D8FFF2" //Related to the flashlight function. We Fallout now
	var/f_lum = 2 //Luminosity for the flashlight function
	var/silent = 0 //To beep or not to beep, that is the question
	var/toff = 0 //If 1, messenger disabled
	var/tnote = null //Current Texts
	var/last_text //No text spamming
	var/last_honk //Also no honk spamming that's bad too
	var/ttone = "beep" //The ringtone!
	var/lock_code = "" // Lockcode to unlock uplink
	var/honkamt = 0 //How many honks left when infected with honk.exe
	var/mimeamt = 0 //How many silence left when infected with mime.exe
	var/note = "Congratulations, your station has chosen the Thinktronic 5230 Personal Data Assistant!" //Current note in the notepad function
	var/notehtml = ""
	var/cart = "" //A place to stick cartridge menu information
	var/detonate = 1 // Can the PDA be blown up?
	var/hidden = 0 // Is the PDA hidden from the PDA list?

	var/obj/item/weapon/card/id/id = null //Making it possible to slot an ID card into the PDA so it can function as both.
	var/ownjob = null //related to above

	var/obj/item/device/paicard/pai = null	// A slot for a personal AI device
	var/obj/item/device/device_analyser/dev_analys = null

	var/MM = null
	var/DD = null

	var/list/applications = list()

	var/list/currentevents1 = list("The Prime Minister of Space Australia has announced today a new policy to hand out fake dollar bills to the poor.",
		"The President of Space America issued a press release today stating that he is not in fact, a Tajaran in disguise.",
		"The Prime Minister of Space England is in hot water today after he announced that space tea would now be made with 20% more nuclear waste.",
		"The Czar of the Space Soviet Union has issued a press release stating 'Spess Amerikans suck cocks!' we're working on a translation.",
		"Space Israel has not gotten into trouble for bombing dirty Space Palestine again today. Don't be so anti-semitic.",
		"Our sources tell us that the Earth country Poland has issued a press release stating that 'they didn't want to go to space anyway' and that 'space sucks'. More at eleven.",
		"Sources are saying that the Earth country Poland has issued another press release saying they were sorry and would very much like to be in space. The Intergalactic Empire responded with the word 'No'.",
		"The President of Space America has come under fire recently for stating that god was a chicken.",
		"The Intergalactic Empire is in hot water this week after proposing to rename Space-Milk to Milk. The newsroom would like to apologize to any readers offended by this news.",
		"The Prime Minister of Space Scotland has announced that 'Freedom Day' did not go as planned. Our sources report that over 2000 human heads are now being returned to their loved ones.",
		"The Prime Minister of Space Australia has come under fire for stating 'Women are in the kitchen, men are on the sofa, jews are in the oven. My country is doing well.",
		"Dirty Space Palestine just declared Jihad on Mighty Space Israel. For shame, Space Palestine.",
		"The President of Space America was questioned today about his reaction to the Space Superstorm Baldman disaster, he replied 'I didn't send anybody since I figured it would quit about three quarters through.",
		"The President of Space America was photographed today kicking a dog to death while muttering about how he liked cats better.",
		"The President of Space America was photographed today with a fairly obvious tail protruding out of his pants, he denies the photo is real, saying 'I, president T'jkar Aw'krejn, am no Tajaran-- I mean catbeast.",
		"The votes have come in, and the new Prime Minister of Space Uzbekistan is Kthchichikachi Breekikikiki. When questioned about his landslide victory, he replied 'SQAAAAAAAK'. His only opponent, Er'p Fh'goot, was the first openly gay catbeast to run for office.",
		"The President of Space America has issued a press release asking for more chips in his office.",
		"The Prime Minister of Space Uzbekistan has issued a press release, stating that 'SQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAK BAWWK BAAWWWWKK'. We would like to say that Faux News does not condone or support the words of Mr. Breekikikiki.",
		"The Prime Minister of Space Australia has come under fire for stating he was very upset with how many black people there was in his country.",
		"The Czar of Space Russia has accused the President of Space America of being a dirty catbeast. The President wiggled his trademark ears and said that if he was a Tajaran, the Czar was a space shark. The President is being treated for bite wounds.",
		"The 'Universes Largest Oven' has been completed today in Space Germany. Prime Minister Adole Himmler has invited Space Isreal to see the oven first at its grand opening."
		)
	var/list/currentevents2 = list("CEO Discount Dan has been sued. Again.",
		"NanoTrasen has inducted a new policy wherein clowns will be spanked for stealing milk.",
		"Discount Dan's has created a new line of Discountu Danu food product for Space Japan. The food is comprised of Space Carp on rice. More at ten.",
		"Discount Dan's has come under fire for their new 'Horsemeat Lasagna'",
		"NanoTrasen's official website has been hacked this morning. The site read 'NT SUXZ, GO SYNDIEKATTZ!!1!1!!' for 48 hours until the site was fixed.",
		"Read the all new book by a former unnamed syndicate, 'NanoTrasen sucks but the dental is good so whatever.'",
		"NanoTrasen has released a new study that has been made useless by the internet.",
		"Discount Dan's 'Spooky Dan' line of product has come under fire for being unintentionally racist toward ghosts.",
		"Discount Dan's 'Discounto Danito' line of product has come out with a new 'fiesta size' burrito. CEO Discount Dan has been quoted as saying, 'A big 'ol clot for a big 'ol family!'",
		"The Syndicate has issued a press release stating that 'NanoTrasen sucks dicks.'",
		"NanoTrasen CEO Johnson Lovelocker has been photographed kicking a Tajaran to death. This shameful publicity stunt is part of the new 'NT Hates Catbeasts, do you?' campaign.",
		"NanoTrasen CEO Johnson Lovelocker has been photographed kicking a Vox in the cloaca. He commented that, 'BIRDS BELONG IN MY FUCKING MEALS DAMN IT'.",
		"NanoTrasen CEO Johnson Lovelocker is in hot water for an alleged sex scandal with a confused syndicate woman that took the motto 'Fuck NT' too seriously.",
		"NanoTrasen CEO Johnson Lovelocker issued a press release stating, 'Anybody who's fucking impersonating me is going to get fucking bluespaced unto a spike.'. We do not condone Lovelocker's use of foul language in the newsroom.",
		"NanoTrasen CEO Johnson Lovelocker and Discount Dan's CEO Discount Dan have been photographed buying a new friend necklace. The Syndicate issued a statement that 'That's totally gay.'",
		"Discount Dan has been photographed this evening hunting the endangered albino space panda. When questioned, he replied that the endangered animal was 'Good eats'.",
		"NanoTrasen's head programmer quit this evening when people did not respond well to his new features on NTOS. Said features included the ability to instantly transmit pictures of your butt to people by blinking.",
		"NanoTrasen CEO Johnson Lovelocker was photographed this morning celebrating his birthday will well deserved hookers and blow.",
		"Discount Dan's stock has risen 20 points today after CEO Discount Dan promised to include a free toy in every 'Happy Dan' meal. In other news, we have over 300 confirmed reports of broken teeth and lead poisoning in children 6 and under.",
		"Discount Dan has come under fire today after trying to hug a plasmaman whilst smoking a cigar. He is being treated for 3rd degree burns at the moment, and we at the newsroom wish him luck.",
		"NanoTrasen's treasurer Shlomo Goldburginstein died today in a tragic cooking incident with NT Officer Gass Judenraigh."
		)
	var/list/currentevents3 = list("Border patrol around Space America has tightened today after a wave of Tajarans yiffed their way across. We have reports of over 2000 molested Space Americans. More to come at seven.",
		"Tajarans continue to protest in their 'Trillion Fur March' today. We have reports that the Space American army is giving a KOS order on all non-humans in the area.",
		"Read the all new book by known Plasmaman rights activist Spookler Boney, 'AGHGHHGHGH KILL ME IT BURNS AGHHHHHHH'",
		"Read the all new book by the worlds most renown skeleton Johnny Hips, 'It aint easy, being bony.'",
		"Scientists in Space Austria have found a chicken with the ability to warp space-time. More at ten.",
		"Scientists working on at the Bluespace Portal Research Facility (BPRF), have looked into the fabric of reality. They report that all it is out there is a bunch of fat nerds and a chicken.",
		"Scientists working at the Large Hadron Collider have discovered nothing today. A sceptical scientist was quoted as saying, 'It could be nothing, but it's probably just something again.'",
		"Johnny Hips has released a new album today, 'Tibia Blues'. The songs include classics such as 'I aint got money for milk.', 'Skeleton Rock', and a new song named, 'Bone Marrow'.",
		"Doctors have discovered that clowns indeed do have a funny bone.",
		"Renowned mime scientist Free Shrugs has discovered a new element today. He has named it '  ', he also says that it has the properties of '   '.",
		"Archaeologists have discovered god's final message to his creation today. The message reads, 'bawk'.",
		"Scientists have discovered a new type of elementary particle today. Our sources say it has a bad atitude, and enjoys the color blue.",
		"Today, a man was discovered to be living with a 20 year old ghost in his house. When the ghost was questioned who killed him, he responded 'A FAGGOT!'. More at four.",
		"Scientists report that ghosts do in fact exist, however, they are huge assholes.",
		"Supermatter researchers today have reported that the substance is highly volatile and could possibly rip apart the universe in large quantities. Discount Dan has been reported as ordering over 1000 pounds of supermatter shards.",
		"Scientists working at the BPRF have discovered a pocket universe comprised fully of dead clown souls today. 40 scientists are being treated for madness."
		)
	var/list/history = list("Adolf Hitler's cyborg body was lain to rest after the ending of WW4.",
		"World War Buttbot began, the following war claimed the asses of over 500000 young gentlemen.",
		"The 54th President of the United States of Space America was shot in the dick. He succumbed to his injuries after medbay threw him in cryo for an entire day.",
		"The first great zombie apocalypse began on Venus.",
		"The first man to step on Pluto slipped and was impaled on an ice spike shortly after landing.",
		"North Korea became the first country to land a rocket on the sun.",
		"Kim Jong Long Dong Silver, 58th generation leader of North Korea, died after being shot seventy two times in the chest.",
		"NanoTrasen's new 'Space Station 13' project was announced.",
		"Jupiter and Neptune became sentient for a period of 78 hours, Jupiter was heard screaming 'WHY AM I ALIVE DEAR GOD.', whilst curiously, Neptune only said 'Well here we go again.'.",
		"The first furry in space was thrown out an airlock, along with his fursuit.",
		"The 89th President of Space America read Woody's Got Wood aloud in his first State of the Union, and was beaten to death shortly after.",
		"Space France surrendered for the 10124th time, making it the most invaded country in the galaxy.",
		"Our glorious leader Karl Pilkington the 24th was crowned emperor of the Intergalactic Human Empire.",
		"Everyone in the universe said 'Dave sucks.' at the same time. The cause of this event was unknown, but over 200000 men named Dave were murdered.",
		"A cult religion following the belief god was a chicken was created.",
		)
	var/list/facts = list("If you have 3 quarters, 4 dimes, and 4 pennies, you have $1.19. You also have the largest amount of money in coins without being able to make change for a dollar.",
		"The numbers '172' can be found on the back of the U.S. $5 dollar bill in the bushes at the base of the Lincoln Memorial.",
		"President Kennedy was the fastest random speaker in the world with upwards of 350 words per minute.",
		"In the average lifetime, a person will walk the equivalent of 5 times around the equator.",
		"Odontophobia is the fear of teeth.",
		"The surface area of an average-sized brick is 79 cm squared.",
		"According to suicide statistics, Monday is the favoured day for self-destruction.",
		"When you die your hair still grows for a couple of months.",
		"The Neanderthal's brain was bigger than yours is.",
		"The pancreas produces Insulin.",
		"The word 'lethologica' describes the state of not being able to remember the word you want.",
		"Every year about 98% of the atoms in your body are replaced.",
		"The international telephone dialing code for Antarctica is 672.",
		"Women are 37% more likely to go to a psychiatrist than men are.",
		"The human heart creates enough pressure to squirt blood 30 feet (9 m).",
		"When snakes are born with two heads, they fight each other for food.",
		"Stressed is Desserts spelled backwards.",
		"The word 'nerd' was first coined by Dr. Seuss in 'If I Ran the Zoo.'",
		"Revolvers cannot be silenced because of all the noisy gasses which escape the cylinder gap at the rear of the barrel.",
		"Every human spent about half an hour as a single cell.",
		"7.5 million toothpicks can be created from a cord of wood."
		)
	var/currentevent1 = null
	var/currentevent2 = null
	var/currentevent3 = null
	var/onthisday = null
	var/didyouknow = null


/obj/item/device/pda/GetJobName() //Used in secHUD icon generation
	if(!src.id)
		return "Unknown"

	return src.id.GetJobName() //isn't it beautiful?


/obj/item/device/pda/medical
	name = "Medical PDA"
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-m"

/obj/item/device/pda/medical/New()
	..()
	var/datum/pda_app/ringer/app = new /datum/pda_app/ringer()
	app.onInstall(src)
	app.frequency = deskbell_freq_medbay

/obj/item/device/pda/viro
	name = "Virology PDA"
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-v"

/obj/item/device/pda/viro/New()
	..()
	var/datum/pda_app/ringer/app = new /datum/pda_app/ringer()
	app.onInstall(src)
	app.frequency = deskbell_freq_medbay

/obj/item/device/pda/engineering
	name = "Engineering PDA"
	default_cartridge = /obj/item/weapon/cartridge/engineering
	icon_state = "pda-e"

/obj/item/device/pda/security
	name = "Security PDA"
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-s"

/obj/item/device/pda/security/New()
	..()
	var/datum/pda_app/ringer/app = new /datum/pda_app/ringer()
	app.onInstall(src)
	app.frequency = deskbell_freq_brig

/obj/item/device/pda/detective
	name = "Detective PDA"
	default_cartridge = /obj/item/weapon/cartridge/detective
	icon_state = "pda-det"

/obj/item/device/pda/detective/New()
	..()
	var/datum/pda_app/light_upgrade/app1 = new /datum/pda_app/light_upgrade()
	app1.onInstall(src)
	var/datum/pda_app/balance_check/app2 = new /datum/pda_app/balance_check()
	app2.onInstall(src)

/obj/item/device/pda/warden
	name = "Warden PDA"
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-warden"

/obj/item/device/pda/warden/New()
	..()
	var/datum/pda_app/ringer/app = new /datum/pda_app/ringer()
	app.onInstall(src)
	app.frequency = deskbell_freq_brig

/obj/item/device/pda/janitor
	name = "Janitor PDA"
	default_cartridge = /obj/item/weapon/cartridge/janitor
	icon_state = "pda-j"
	ttone = "slip"

/obj/item/device/pda/toxins
	name = "Science PDA"
	default_cartridge = /obj/item/weapon/cartridge/signal/toxins
	icon_state = "pda-tox"
	ttone = "boom"

/obj/item/device/pda/toxins/New()
	..()
	var/datum/pda_app/ringer/app = new /datum/pda_app/ringer()
	app.onInstall(src)
	app.frequency = deskbell_freq_rnd

/obj/item/device/pda/clown
	name = "Clown PDA"
	default_cartridge = /obj/item/weapon/cartridge/clown
	icon_state = "pda-clown"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. The surface is coated with polytetrafluoroethylene and banana drippings."
	ttone = "honk"

/obj/item/device/pda/mime
	name = "Mime PDA"
	default_cartridge = /obj/item/weapon/cartridge/mime
	icon_state = "pda-mime"
	silent = 1
	ttone = "silence"

/obj/item/device/pda/heads
	name = "Head of department PDA"
	default_cartridge = /obj/item/weapon/cartridge/head
	icon_state = "pda-h"

/obj/item/device/pda/heads/hop
	name = "Head of Personnel PDA"
	default_cartridge = /obj/item/weapon/cartridge/hop
	icon_state = "pda-hop"

/obj/item/device/pda/heads/hop/New()
	..()
	var/datum/pda_app/ringer/app1 = new /datum/pda_app/ringer()
	app1.onInstall(src)
	app1.frequency = deskbell_freq_hop
	var/datum/pda_app/balance_check/app2 = new /datum/pda_app/balance_check()
	app2.onInstall(src)

/obj/item/device/pda/heads/hos
	name = "Head of Security PDA"
	default_cartridge = /obj/item/weapon/cartridge/hos
	icon_state = "pda-hos"

/obj/item/device/pda/heads/hos/New()
	..()
	var/datum/pda_app/ringer/app = new /datum/pda_app/ringer()
	app.onInstall(src)
	app.frequency = deskbell_freq_brig

/obj/item/device/pda/heads/ce
	name = "Chief Engineer PDA"
	default_cartridge = /obj/item/weapon/cartridge/ce
	icon_state = "pda-ce"

/obj/item/device/pda/heads/cmo
	name = "Chief Medical Officer PDA"
	default_cartridge = /obj/item/weapon/cartridge/cmo
	icon_state = "pda-cmo"

/obj/item/device/pda/heads/cmo/New()
	..()
	var/datum/pda_app/ringer/app = new /datum/pda_app/ringer()
	app.onInstall(src)
	app.frequency = deskbell_freq_medbay

/obj/item/device/pda/heads/rd
	name = "Research Director PDA"
	default_cartridge = /obj/item/weapon/cartridge/rd
	icon_state = "pda-rd"

/obj/item/device/pda/heads/rd/New()
	..()
	var/datum/pda_app/ringer/app = new /datum/pda_app/ringer()
	app.onInstall(src)
	app.frequency = deskbell_freq_rnd

/obj/item/device/pda/captain
	name = "Captain PDA"
	default_cartridge = /obj/item/weapon/cartridge/captain
	icon_state = "pda-c"
	detonate = 0
	//toff = 1

/obj/item/device/pda/captain/New()
	..()
	for(var/app_type in (typesof(/datum/pda_app) - /datum/pda_app))	//yes, the captain is such a baller that his PDA has all the apps by default.
		var/datum/pda_app/app = new app_type()						//will have to edit that when emagged/hidden apps get added.
		app.onInstall(src)

/obj/item/device/pda/cargo
	name = "Cargo PDA"
	default_cartridge = /obj/item/weapon/cartridge/quartermaster
	icon_state = "pda-cargo"

/obj/item/device/pda/quartermaster
	name = "Quartermaster PDA"
	default_cartridge = /obj/item/weapon/cartridge/quartermaster
	icon_state = "pda-q"

/obj/item/device/pda/shaftminer
	name = "Mining PDA"
	icon_state = "pda-miner"

/obj/item/device/pda/syndicate
	default_cartridge = /obj/item/weapon/cartridge/syndicate
	icon_state = "pda-syn"
	name = "Military PDA"
	owner = "John Doe"
	hidden = 1

/obj/item/device/pda/chaplain
	name = "Chaplain PDA"
	icon_state = "pda-holy"
	ttone = "holy"

/obj/item/device/pda/lawyer
	name = "Lawyer PDA"
	default_cartridge = /obj/item/weapon/cartridge/lawyer
	icon_state = "pda-lawyer"
	ttone = "..."

/obj/item/device/pda/botanist
	name = "Botany PDA"
	//default_cartridge = /obj/item/weapon/cartridge/botanist
	icon_state = "pda-hydro"

/obj/item/device/pda/roboticist
	name = "Robotics PDA"
	icon_state = "pda-robot"

/obj/item/device/pda/librarian
	name = "Librarian PDA"
	icon_state = "pda-libb"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a WGW-11 series e-reader."
	note = "Congratulations, your station has chosen the Thinktronic 5290 WGW-11 Series E-reader and Personal Data Assistant!"
	silent = 1 //Quiet in the library!

/obj/item/device/pda/clear
	icon_state = "pda-transp"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a special edition with a transparent case."
	note = "Congratulations, you have chosen the Thinktronic 5230 Personal Data Assistant Deluxe Special Max Turbo Limited Edition!"

/obj/item/device/pda/chef
	name = "Chef PDA"
	default_cartridge = /obj/item/weapon/cartridge/chef
	icon_state = "pda-chef"

/obj/item/device/pda/bar
	name = "Bartender PDA"
	icon_state = "pda-bar"

/obj/item/device/pda/atmos
	name = "Atmospherics PDA"
	default_cartridge = /obj/item/weapon/cartridge/atmos
	icon_state = "pda-atmo"

/obj/item/device/pda/mechanic
	name = "Mechanic PDA"
	default_cartridge = /obj/item/weapon/cartridge/mechanic
	icon_state = "pda-atmo"

/obj/item/device/pda/chemist
	name = "Chemistry PDA"
	default_cartridge = /obj/item/weapon/cartridge/chemistry
	icon_state = "pda-chem"

/obj/item/device/pda/geneticist
	name = "Genetics PDA"
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-gene"


// Special AI/pAI PDAs that cannot explode.
/obj/item/device/pda/ai
	icon_state = "NONE"
	ttone = "data"
	detonate = 0

/obj/item/device/pda/ai/New()
	..()
	var/datum/pda_app/spam_filter/app = new /datum/pda_app/spam_filter()
	app.onInstall(src)


/obj/item/device/pda/ai/proc/set_name_and_job(newname as text, newjob as text)
	owner = newname
	ownjob = newjob
	name = newname + " (" + ownjob + ")"


//AI verb and proc for sending PDA messages.
/mob/living/silicon/ai/proc/cmd_send_pdamesg()
	var/list/names = list()
	var/list/plist = list()
	var/list/namecounts = list()

	if(usr.stat == 2)
		usr << "You can't send PDA messages because you are dead!"
		return

	if(src.aiPDA.toff)
		usr << "Turn on your receiver in order to send messages."
		return

	for (var/obj/item/device/pda/P in get_viewable_pdas())
		if (P == src)
			continue
		else if (P == src.aiPDA)
			continue

		var/name = P.owner
		if (name in names)
			namecounts[name]++
			name = text("[name] ([namecounts[name]])")
		else
			names.Add(name)
			namecounts[name] = 1

		plist[text("[name]")] = P

	var/c = input(usr, "Please select a PDA") as null|anything in sortList(plist)

	if (!c)
		return

	var/selected = plist[c]
	src.aiPDA.create_message(src, selected)

//AI verb and proc for sending PDA messages.
/obj/item/device/pda/ai/verb/cmd_send_pdamesg()
	set category = "AI Commands"
	set name = "Send Message"
	set src in usr
	if(usr.stat == 2)
		usr << "You can't send PDA messages because you are dead!"
		return
	var/list/plist = available_pdas()
	if (plist)
		var/c = input(usr, "Please select a PDA") as null|anything in sortList(plist)
		if (!c) // if the user hasn't selected a PDA file we can't send a message
			return
		var/selected = plist[c]
		create_message(usr, selected)


/obj/item/device/pda/ai/verb/cmd_toggle_pda_receiver()
	set category = "AI Commands"
	set name = "Toggle Sender/Receiver"
	set src in usr
	if(usr.stat == 2)
		usr << "You can't do that because you are dead!"
		return
	toff = !toff
	usr << "<span class='notice'>PDA sender/receiver toggled [(toff ? "Off" : "On")]!</span>"


/obj/item/device/pda/ai/verb/cmd_toggle_pda_silent()
	set category = "AI Commands"
	set name = "Toggle Ringer"
	set src in usr
	if(usr.stat == 2)
		usr << "You can't do that because you are dead!"
		return
	silent=!silent
	usr << "<span class='notice'>PDA ringer toggled [(silent ? "Off" : "On")]!</span>"


/obj/item/device/pda/ai/verb/cmd_show_message_log()
	set category = "AI Commands"
	set name = "Show Message Log"
	set src in usr
	if(usr.stat == 2)
		usr << "You can't do that because you are dead!"
		return
	var/HTML = "<html><head><title>AI PDA Message Log</title></head><body>[tnote]</body></html>"
	usr << browse(HTML, "window=log;size=400x444;border=1;can_resize=1;can_close=1;can_minimize=0")

/mob/living/silicon/ai/proc/cmd_show_message_log()
	if(usr.stat == 2)
		usr << "You can't do that because you are dead!"
		return
	if(!isnull(aiPDA))
		var/HTML = "<html><head><title>AI PDA Message Log</title></head><body>[aiPDA.tnote]</body></html>"
		usr << browse(HTML, "window=log;size=400x444;border=1;can_resize=1;can_close=1;can_minimize=0")
	else
		usr << "You do not have a PDA. You should make an issue report about this."

/obj/item/device/pda/ai/attack_self(mob/user as mob)
	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)
	return


/obj/item/device/pda/ai/pai
	ttone = "assist"


/*
 *	The Actual PDA
 */
/obj/item/device/pda/pickup(mob/user)
	if(fon)
		SetLuminosity(0)
		user.SetLuminosity(user.luminosity + f_lum)

/obj/item/device/pda/dropped(mob/user)
	if(fon)
		user.SetLuminosity(user.luminosity - f_lum)
		SetLuminosity(f_lum)

/obj/item/device/pda/New()
	..()
	PDAs += src
	if(default_cartridge)
		cartridge = new default_cartridge(src)
	new /obj/item/weapon/pen(src)
	MM = text2num(time2text(world.timeofday, "MM")) 	// get the current month
	DD = text2num(time2text(world.timeofday, "DD")) 	// get the day
	currentevent1 = pick(currentevents1)
	currentevent2 = pick(currentevents2)
	currentevent3 = pick(currentevents3)
	onthisday = pick(history)
	didyouknow = pick(facts)

/obj/item/device/pda/proc/can_use(mob/user)
	if(user && ismob(user))
		if(user.stat || user.restrained() || user.paralysis || user.stunned || user.weakened)
			return 0
		if(loc == user)
			return 1
	return 0

/obj/item/device/pda/GetAccess()
	if(id)
		return id.GetAccess()
	else
		return ..()

/obj/item/device/pda/GetID()
	return id

/obj/item/device/pda/MouseDrop(obj/over_object as obj, src_location, over_location)
	var/mob/M = usr
	if((!istype(over_object, /obj/screen)) && can_use(M))
		return attack_self(M)
	return

//NOTE: graphic resources are loaded on client login
/obj/item/device/pda/attack_self(mob/user as mob)

	user.set_machine(src)

	if(active_uplink_check(user))
		return


	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\PDA\PDA.dm:313: var/dat = "<html><head><title>Personal Data Assistant</title></head><body bgcolor=\"#808000\"><style>a, a:link, a:visited, a:active, a:hover { color: #000000; }img {border-style:none;}</style>"
	var/dat = {"<html><head><title>Personal Data Assistant</title></head><body bgcolor=\"#808000\"><style>a, a:link, a:visited, a:active, a:hover { color: #000000; }img {border-style:none;}</style>
<a href='byond://?src=\ref[src];choice=Close'><img src=pda_exit.png> Close</a>"}
	// END AUTOFIX
	if ((!isnull(cartridge)) && (mode == 0))
		dat += " | <a href='byond://?src=\ref[src];choice=Eject'><img src=pda_eject.png> Eject [cartridge]</a>"
	if (mode)
		dat += " | <a href='byond://?src=\ref[src];choice=Return'><img src=pda_menu.png> Return</a>"

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\PDA\PDA.dm:321: dat += " | <a href='byond://?src=\ref[src];choice=Refresh'><img src=pda_refresh.png> Refresh</a>"
	dat += {"| <a href='byond://?src=\ref[src];choice=Refresh'><img src=pda_refresh.png> Refresh</a>
		<br>"}
	// END AUTOFIX
	if (!owner)

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\PDA\PDA.dm:326: dat += "Warning: No owner information entered.  Please swipe card.<br><br>"
		dat += {"Warning: No owner information entered.  Please swipe card.<br><br>
			<a href='byond://?src=\ref[src];choice=Refresh'><img src=pda_refresh.png> Retry</a>"}
		// END AUTOFIX
	else
		switch (mode)
			if (0)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\PDA\PDA.dm:331: dat += "<h2>PERSONAL DATA ASSISTANT v.1.3</h2>"
				dat += {"<h2>PERSONAL DATA ASSISTANT v.1.3</h2>
					Owner: [owner], [ownjob]<br>"}
				// END AUTOFIX
				dat += text("ID: <A href='?src=\ref[src];choice=Authenticate'>[id ? "[id.registered_name], [id.assignment]" : "----------"]")
				dat += text("<br><A href='?src=\ref[src];choice=UpdateInfo'>[id ? "Update PDA Info" : ""]</A><br><br>")


				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\PDA\PDA.dm:336: dat += "Station Time: [worldtime2text()]"//:[world.time / 100 % 6][world.time / 100 % 10]"
				dat += {"Station Time: [worldtime2text()]
					<br><br>
					<h4>General Functions</h4>
					<ul>
					<li><a href='byond://?src=\ref[src];choice=1'><img src=pda_notes.png> Notekeeper</a></li>
					<li><a href='byond://?src=\ref[src];choice=2'><img src=pda_mail.png> Messenger</a></li>
					<li><a href='byond://?src=\ref[src];choice=50'><img src=pda_clock.png> Current Events</a></li>"}
				// END AUTOFIX
				//dat += "<li><a href='byond://?src=\red[src];choice=chatroom'><img src=pda_chatroom.png> Nanotrasen Relay Chat</a></li>"

				dat += "<li><a href='byond://?src=\ref[src];choice=41'><img src=pda_notes.png> View Crew Manifest</a></li>"

				if (cartridge)
					if (cartridge.access_clown)
						dat += "<li><a href='byond://?src=\ref[src];choice=Honk'><img src=pda_honk.png> Honk Synthesizer</a></li>"
					if(cartridge.access_status_display)
						dat += "<li><a href='byond://?src=\ref[src];choice=42'><img src=pda_status.png> Set Status Display</a></li>"

				dat += "</ul>"
				dat += {"<h4>Applications</h4>"}

				if(applications.len == 0)
					dat += {"<i>No application currently installed.</i>"}
				else
					dat += {"<ul>"}
					for(var/datum/pda_app/app in applications)
						if(app.menu)
							dat += {"<li><a href='byond://?src=\ref[src];choice=[app.menu]'>[app.name]</a></li>"}
						else
							dat += {"<li>[app.name]</li>"}
					dat += {"</ul>"}

				if (cartridge)
					if (cartridge.access_engine)
						// AUTOFIXED BY fix_string_idiocy.py
						// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\PDA\PDA.dm:355: dat += "<h4>Engineering Functions</h4>"
						dat += {"<h4>Engineering Functions</h4>
							<ul>
							<li><a href='byond://?src=\ref[src];choice=43'><img src=pda_power.png> Power Monitor</a></li>
							</ul>"}
						// END AUTOFIX

					if (cartridge.access_mechanic)
						dat += {"<h4>Mechanic Functions</h4>
							<ul>
							<li><a href='byond://?src=\ref[src];choice=Device Analyser'><img src=pda_scanner.png> [scanmode == 6 ? "Disable" : "Enable" ] Device Analyser</a></li>
							</ul>"}

					if (cartridge.access_medical)

						// AUTOFIXED BY fix_string_idiocy.py
						// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\PDA\PDA.dm:360: dat += "<h4>Medical Functions</h4>"
						dat += {"<h4>Medical Functions</h4>
							<ul>
							<li><a href='byond://?src=\ref[src];choice=44'><img src=pda_medical.png> Medical Records</a></li>
							<li><a href='byond://?src=\ref[src];choice=Medical Scan'><img src=pda_scanner.png> [scanmode == 1 ? "Disable" : "Enable"] Medical Scanner</a></li>
							</ul>"}
						// END AUTOFIX
					if (cartridge.access_security)

						// AUTOFIXED BY fix_string_idiocy.py
						// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\PDA\PDA.dm:366: dat += "<h4>Security Functions</h4>"
						dat += {"<h4>Security Functions</h4>
							<ul>
							<li><a href='byond://?src=\ref[src];choice=45'><img src=pda_cuffs.png> Security Records</A></li>"}
						// END AUTOFIX
					if(istype(cartridge.radio, /obj/item/radio/integrated/beepsky))

						// AUTOFIXED BY fix_string_idiocy.py
						// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\PDA\PDA.dm:370: dat += "<li><a href='byond://?src=\ref[src];choice=46'><img src=pda_cuffs.png> Security Bot Access</a></li>"
						dat += {"<li><a href='byond://?src=\ref[src];choice=46'><img src=pda_cuffs.png> Security Bot Access</a></li>
							</ul>"}
						// END AUTOFIX
					else	dat += "</ul>"
					if(cartridge.access_quartermaster)

						// AUTOFIXED BY fix_string_idiocy.py
						// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\PDA\PDA.dm:374: dat += "<h4>Quartermaster Functions:</h4>"
						dat += {"<h4>Quartermaster Functions:</h4>
							<ul>
							<li><a href='byond://?src=\ref[src];choice=47'><img src=pda_crate.png> Supply Records</A></li>
							<li><a href='byond://?src=\ref[src];choice=48'><img src=pda_mule.png> Delivery Bot Control</A></li>
							</ul>"}
				// END AUTOFIX

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\PDA\PDA.dm:379: dat += "</ul>"
				dat += {"</ul>
					<h4>Utilities</h4>
					<ul>"}
				// END AUTOFIX
				if (cartridge)
					if (cartridge.access_janitor)
						dat += "<li><a href='byond://?src=\ref[src];choice=49'><img src=pda_bucket.png> Custodial Locator</a></li>"
					if (istype(cartridge.radio, /obj/item/radio/integrated/signal))
						dat += "<li><a href='byond://?src=\ref[src];choice=40'><img src=pda_signaler.png> Signaler System</a></li>"
					if (cartridge.access_reagent_scanner)
						dat += "<li><a href='byond://?src=\ref[src];choice=Reagent Scan'><img src=pda_reagent.png> [scanmode == 3 ? "Disable" : "Enable"] Reagent Scanner</a></li>"
					if (cartridge.access_engine)
						dat += "<li><a href='byond://?src=\ref[src];choice=Halogen Counter'><img src=pda_reagent.png> [scanmode == 4 ? "Disable" : "Enable"] Halogen Counter</a></li>"
					if (cartridge.access_atmos)
						dat += "<li><a href='byond://?src=\ref[src];choice=Gas Scan'><img src=pda_reagent.png> [scanmode == 5 ? "Disable" : "Enable"] Gas Scanner</a></li>"
					if (cartridge.access_remote_door)
						dat += "<li><a href='byond://?src=\ref[src];choice=Toggle Door'><img src=pda_rdoor.png> Toggle Remote Door</a></li>"

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\PDA\PDA.dm:396: dat += "<li><a href='byond://?src=\ref[src];choice=3'><img src=pda_atmos.png> Atmospheric Scan</a></li>"
				dat += {"<li><a href='byond://?src=\ref[src];choice=3'><img src=pda_atmos.png> Atmospheric Scan</a></li>
					<li><a href='byond://?src=\ref[src];choice=Light'><img src=pda_flashlight.png> [fon ? "Disable" : "Enable"] Flashlight</a></li>"}
				// END AUTOFIX
				if (pai)
					if(pai.loc != src)
						pai = null
					else

						// AUTOFIXED BY fix_string_idiocy.py
						// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\PDA\PDA.dm:402: dat += "<li><a href='byond://?src=\ref[src];choice=pai;option=1'>pAI Device Configuration</a></li>"
						dat += {"<li><a href='byond://?src=\ref[src];choice=pai;option=1'>pAI Device Configuration</a></li>
							<li><a href='byond://?src=\ref[src];choice=pai;option=2'>Eject pAI Device</a></li>"}
						// END AUTOFIX
				dat += "</ul>"

			if (1)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\PDA\PDA.dm:407: dat += "<h4><img src=pda_notes.png> Notekeeper V2.1</h4>"
				dat += {"<h4><img src=pda_notes.png> Notekeeper V2.1</h4>
					<a href='byond://?src=\ref[src];choice=Edit'> Edit</a><br>"}
				// END AUTOFIX
				dat += note

			if (2)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\PDA\PDA.dm:412: dat += "<h4><img src=pda_mail.png> SpaceMessenger V3.9.4</h4>"
				dat += {"<h4><img src=pda_mail.png> SpaceMessenger V3.9.4</h4>
					<a href='byond://?src=\ref[src];choice=Toggle Ringer'><img src=pda_bell.png> Ringer: [silent == 1 ? "Off" : "On"]</a> |
					<a href='byond://?src=\ref[src];choice=Toggle Messenger'><img src=pda_mail.png> Send / Receive: [toff == 1 ? "Off" : "On"]</a> |
					<a href='byond://?src=\ref[src];choice=Ringtone'><img src=pda_bell.png> Set Ringtone</a> |
					<a href='byond://?src=\ref[src];choice=21'><img src=pda_mail.png> Messages</a><br>"}
				// END AUTOFIX
				if (istype(cartridge, /obj/item/weapon/cartridge/syndicate))
					dat += "<b>[cartridge:shock_charges] detonation charges left.</b><HR>"
				if (istype(cartridge, /obj/item/weapon/cartridge/clown))
					dat += "<b>[cartridge:honk_charges] viral files left.</b><HR>"
				if (istype(cartridge, /obj/item/weapon/cartridge/mime))
					dat += "<b>[cartridge:mime_charges] viral files left.</b><HR>"


				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\PDA\PDA.dm:425: dat += "<h4><img src=pda_menu.png> Detected PDAs</h4>"
				dat += {"<h4><img src=pda_menu.png> Detected PDAs</h4>
					<ul>"}
				// END AUTOFIX
				var/count = 0

				if (!toff)
					for (var/obj/item/device/pda/P in sortNames(get_viewable_pdas()))
						if (P == src)	continue
						if(P.hidden) continue
						dat += "<li><a href='byond://?src=\ref[src];choice=Message;target=\ref[P]'>[P]</a>"
						if (istype(cartridge, /obj/item/weapon/cartridge/syndicate) && P.detonate)
							dat += " (<a href='byond://?src=\ref[src];choice=Detonate;target=\ref[P]'><img src=pda_boom.png>*Detonate*</a>)"
						if (istype(cartridge, /obj/item/weapon/cartridge/clown))
							dat += " (<a href='byond://?src=\ref[src];choice=Send Honk;target=\ref[P]'><img src=pda_honk.png>*Send Virus*</a>)"
						if (istype(cartridge, /obj/item/weapon/cartridge/mime))
							dat += " (<a href='byond://?src=\ref[src];choice=Send Silence;target=\ref[P]'>*Send Virus*</a>)"
						dat += "</li>"
						count++
				dat += "</ul>"
				if (count == 0)
					dat += "None detected.<br>"

			if(21)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\PDA\PDA.dm:448: dat += "<h4><img src=pda_mail.png> SpaceMessenger V3.9.4</h4>"
				dat += {"<h4><img src=pda_mail.png> SpaceMessenger V3.9.4</h4>
					<a href='byond://?src=\ref[src];choice=Clear'><img src=pda_blank.png> Clear Messages</a>
					<h4><img src=pda_mail.png> Messages</h4>"}
				// END AUTOFIX
				dat += tnote
				dat += "<br>"

			if (3)
				dat += "<h4><img src=pda_atmos.png> Atmospheric Readings</h4>"

				var/turf/T = get_turf(user.loc)
				if (isnull(T))
					dat += "Unable to obtain a reading.<br>"
				else
					var/datum/gas_mixture/environment = T.return_air()

					var/pressure = environment.return_pressure()
					var/total_moles = environment.total_moles()

					dat += "Air Pressure: [round(pressure,0.1)] kPa<br>"

					if (total_moles)
						var/o2_level = environment.oxygen/total_moles
						var/n2_level = environment.nitrogen/total_moles
						var/co2_level = environment.carbon_dioxide/total_moles
						var/plasma_level = environment.toxins/total_moles
						var/unknown_level =  1-(o2_level+n2_level+co2_level+plasma_level)

						// AUTOFIXED BY fix_string_idiocy.py
						// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\PDA\PDA.dm:476: dat += "Nitrogen: [round(n2_level*100)]%<br>"
						dat += {"Nitrogen: [round(n2_level*100)]%<br>
							Oxygen: [round(o2_level*100)]%<br>
							Carbon Dioxide: [round(co2_level*100)]%<br>
							Plasma: [round(plasma_level*100)]%<br>"}
						// END AUTOFIX
						if(unknown_level > 0.01)
							dat += "OTHER: [round(unknown_level)]%<br>"
					dat += "Temperature: [round(environment.temperature-T0C)]&deg;C<br>"
				dat += "<br>"

			if (5)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\PDA\PDA.dm:486: dat += "<h4><img src=pda_chatroom.png> Nanotrasen Relay Chat</h4>"
				dat += {"<h4><img src=pda_chatroom.png> Nanotrasen Relay Chat</h4>
					<h4><img src=pda_menu.png> Detected Channels</h4>: <li>"}
				// END AUTOFIX
				for(var/datum/chatroom/C in chatrooms)
					dat += "<a href='byond://?src=\ref[src];pdachannel=[C.name]'>#[html_encode(lowertext(C.name))]"
					if(C.password != "")
						dat += " <img src=pda_locked.png>"
					dat += "</li>"

			if (41) //Allows everyone to access crew

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\PDA\cart.dm:281: menu = "<h4><img src=pda_notes.png> Crew Manifest</h4>"
				dat += {"<h4><img src=pda_notes.png> Crew Manifest</h4>
					Entries cannot be modified from this terminal.<br><br>"}
				// END AUTOFIX
				if(data_core)
					dat += data_core.get_manifest(1) // make it monochrome
				dat += "<br>"

			if (50) //Current events.
				dat += {"<h4><img src=pda_clock.png> Current Events</h4>
					Station Time: <b>[worldtime2text()]</b>.<br>
					Empire Date: <b>[MM]/[DD]/[game_year]</b>.<br><br>
					<b>Current Events,</b><br>
					<li>[currentevent1]</li<br>
					<li>[currentevent2]</li><br>
					<li>[currentevent3]</li><br><br>
					<b>On this day,</b><br>
					<li>[onthisday]</li><br><br>
					<b>Did you know...</b><br>
					<li>[didyouknow]</li><br>"}

			if (101)//Ringer app
				var/datum/pda_app/ringer/app = locate(/datum/pda_app/ringer) in applications
				dat += {"<h4>Ringer Application</h4>"}
				if(app)
					dat += {"
					Status: <a href='byond://?src=\ref[src];choice=toggleDeskRinger'>[app.status ? "On" : "Off"]</a><br>
					Frequency:
						<a href='byond://?src=\ref[src];choice=ringerFrequency;rfreq=-10'>-</a>
						<a href='byond://?src=\ref[src];choice=ringerFrequency;rfreq=-2'>-</a>
						[format_frequency(app.frequency)]
						<a href='byond://?src=\ref[src];choice=ringerFrequency;rfreq=2'>+</a>
						<a href='byond://?src=\ref[src];choice=ringerFrequency;rfreq=10'>+</a><br>
						<br>
					"}

			if (102)//Spam filter app
				var/datum/pda_app/spam_filter/app = locate(/datum/pda_app/spam_filter) in applications
				dat += {"<h4>Spam Filtering Application</h4>"}
				if(app)
					dat += {"
					<ul>
					<li>[(app.function == 2) ? "<b>Block the spam.</b>" : "<a href='byond://?src=\ref[src];choice=setFilter;filter=2'>Block the spam.</a>"]</li>
					<li>[(app.function == 1) ? "<b>Conceal the spam.</b>" : "<a href='byond://?src=\ref[src];choice=setFilter;filter=1'>Conceal the spam.</a>"]</li>
					<li>[(app.function == 0) ? "<b>Do nothing.</b>" : "<a href='byond://?src=\ref[src];choice=setFilter;filter=0'>Do nothing.</a>"]</li>
					</ul>
					"}

			if (103)//Balance check app
				var/datum/pda_app/balance_check/app = locate(/datum/pda_app/balance_check) in applications
				dat += {"<h4>Balance Check Application</h4>"}
				if(app)
					if(!id)
						dat += {"<i>Insert an ID card linked to the account to check.</i>"}
					else
						if(!(app.linked_db))
							app.reconnect_database()
						if(app.linked_db)
							if(app.linked_db.activated)
								var/datum/money_account/D = app.linked_db.attempt_account_access(id.associated_account_number, 0, 2, 0)
								if(D)
									dat += {"Owner: <b>[D.owner_name]</b><br>
										Current Balance: <b>[D.money]</b>$
										<h5>Transaction History</h5>
										On [MM]/[DD]/[game_year]:
										<ul>"}
									var/list/t_log = list()
									for(var/e in D.transaction_log)
										t_log += e
									for(var/datum/transaction/T in reverseRange(t_log))
										if(T.purpose == "Account creation")//always the last element of the reverse transaction_log
											dat += {"</ul>
												On [(DD == 1) ? "[((MM-2)%12)+1]" : "[MM]"]/[((DD-2)%30)+1]/[(DD == MM == 1) ? "[game_year - 1]" : "[game_year]"]:
												<ul>
												<li>\[[T.time]\] [T.amount]$, [T.purpose] at [T.source_terminal]</li>
												</ul>"}
										else
											dat += {"<li>\[[T.time]\] [T.amount]$, [T.purpose] at [T.source_terminal]</li>"}
									if(!D.transaction_log.len)
										dat += {"</ul>"}
								else
									dat += {"<i>Unable to access account. Either its security settings don't allow remote checking or the account is nonexistent.</i>"}
							else
								dat += {"<i>Unfortunately your station's Accounts Database doesn't allow remote access. Negociate with your HoP or Captain to solve this issue.</i>"}
						else
							dat += {"<i>Unable to connect to accounts database. The database is either nonexistent, inoperative, or too far away.</i>"}

			if (104)//Station map app
				var/datum/pda_app/station_map/app = locate(/datum/pda_app/station_map) in applications
				dat += {"<h4>Station Map Application</h4>"}
				if(app)
					var/turf/T = get_turf(src.loc)

					if(!fexists("icons/pda_icons/pda_minimap_[map.nameShort].png"))
						dat += {"<span class='warning'>It appears that our services have yet to produce a minimap of this station. We apologize for the inconvenience.</span>"}

					if(T.z == map.zMainStation)
						dat += {"Current Location: <b>[T.loc.name] ([T.x-WORLD_X_OFFSET],[T.y-WORLD_Y_OFFSET],1)</b><br>"}	//it's a "Station Map" app, so it only gives information reguarding
					else																									//the station's z-level
						dat += {"Current Location: <b>Unknown</b><br>"}

					if(fexists("icons/pda_icons/pda_minimap_[map.nameShort].png"))
						dat += {"
						<div style="position: relative; left: 0; top: 0;">
						<img src="pda_minimap_[map.nameShort].png" style="position: relative; top: 0; left: 0;"/>
						"}
						if(T.z == map.zMainStation)
							dat += {"<img src="pda_minimap_loc.gif" style="position: absolute; top: [(T.y * -1) + 247]px; left: [T.x-8]px;"/>"}
						for(var/datum/minimap_marker/mkr in app.markers)
							dat += {"<img src="pda_minimap_mkr.gif" style="position: absolute; top: [((mkr.y+WORLD_Y_OFFSET) * -1) + 247]px; left: [mkr.x+WORLD_X_OFFSET-8]px;"/>"}
						dat += {"</div>"}

					else
						dat += {"
						<div style="position: relative; left: 0; top: 0;">
						<img src="pda_minimap_bg_notfound.png" style="position: relative; top: 0; left: 0;"/>
						"}
						if(T.z == map.zMainStation)
							dat += {"<img src="pda_minimap_loc.gif" style="position: absolute; top: [(T.y * -1) + 247]px; left: [T.x-8]px;"/>"}
						for(var/datum/minimap_marker/mkr in app.markers)
							dat += {"<img src="pda_minimap_mkr.gif" style="position: absolute; top: [((mkr.y+WORLD_Y_OFFSET) * -1) + 247]px; left: [mkr.x+WORLD_X_OFFSET-8]px;"/>"}
						dat += {"</div>"}

/*
					dat += {"
					<div style="position: relative; left: 0; top: 0;">
					<img src="pda_minimap_bg.png" style="position: relative; top: 0; left: 0;"/>
					"}
					if(T.z == map.zMainStation)
						dat += {"<img src="pda_minimap_loc.gif" style="position: absolute; top: [(T.y * -1) + 247]px; left: [T.x-8]px;"/>"}
					for(var/datum/minimap_marker/mkr in app.markers)
						dat += {"<img src="pda_minimap_mkr.gif" style="position: absolute; top: [((mkr.y+WORLD_Y_OFFSET) * -1) + 247]px; left: [mkr.x+WORLD_X_OFFSET-8]px;"/>"}

					dat += {"</div>"}
*/
					dat += {"<h5>Markers</h5>
					<a href='byond://?src=\ref[src];choice=minimapMarker;mMark=x'>X=[app.markx]</a>;
					<a href='byond://?src=\ref[src];choice=minimapMarker;mMark=y'>Y=[app.marky]</a>;
					<a href='byond://?src=\ref[src];choice=minimapMarker;mMark=add'>Add New Marker</a>
					"}

					if(!(app.markers.len))
						dat += {"<br><span class='warning'>no markers</span>"}
					else
						dat +={"<ul>"}
						for(var/datum/minimap_marker/mkr in app.markers)
							dat += {"<li>[mkr.name] ([mkr.x]/[mkr.y]) <a href='byond://?src=\ref[src];choice=removeMarker;rMark=[mkr.num]'>remove</a></li>"}
						dat += {"</ul>"}

			else//Else it links to the cart menu proc. Although, it really uses menu hub 4--menu 4 doesn't really exist as it simply redirects to hub.
				dat += cart

	dat += "</body></html>"
	user << browse(dat, "window=pda;size=400x444;border=1;can_resize=1;can_close=0;can_minimize=0")
	onclose(user, "pda", src)

/obj/item/device/pda/Topic(href, href_list)
	..()
	var/mob/living/U = usr
	//Looking for master was kind of pointless since PDAs don't appear to have one.
	//if ((src in U.contents) || ( istype(loc, /turf) && in_range(src, U) ) )

	if(can_use(U)) //Why reinvent the wheel? There's a proc that does exactly that.
		add_fingerprint(U)
		U.set_machine(src)

		switch(href_list["choice"])

//BASIC FUNCTIONS===================================

			if("Close")//Self explanatory
				U.unset_machine()
				U << browse(null, "window=pda")
				return
			if("Refresh")//Refresh, goes to the end of the proc.
			if("Return")//Return
				if((mode<=9) || (locate(mode) in pda_app_menus))
					mode = 0
				else
					mode = round(mode/10)
					if(mode==4)//Fix for cartridges. Redirects to hub.
						mode = 0
					else if(mode >= 40 && mode <= 49)//Fix for cartridges. Redirects to refresh the menu.
						cartridge.mode = mode
						cartridge.unlock()
			if ("Authenticate")//Checks for ID
				id_check(U, 1)
			if("UpdateInfo")
				ownjob = id.assignment
				name = "PDA-[owner] ([ownjob])"
			if("Eject")//Ejects the cart, only done from hub.
				if (!isnull(cartridge))
					var/turf/T = loc
					if(ismob(T))
						T = T.loc
					cartridge.loc = T
					scanmode = 0
					if (cartridge.radio)
						cartridge.radio.hostpda = null
					cartridge = null

//MENU FUNCTIONS===================================

			if("0")//Hub
				mode = 0
			if("1")//Notes
				mode = 1
			if("2")//Messenger
				mode = 2
			if("21")//Read messeges
				mode = 21
			if("3")//Atmos scan
				mode = 3
			if("4")//Redirects to hub
				mode = 0
			if("41")
				mode = 41
			if("chatroom") // chatroom hub
				mode = 5

//APPLICATIONS FUNCTIONS===========================

			if("101")
				mode = 101
			if("toggleDeskRinger")
				var/datum/pda_app/ringer/app = locate(/datum/pda_app/ringer) in applications
				if(app)
					app.status = !(app.status)
			if("ringerFrequency")
				var/datum/pda_app/ringer/app = locate(/datum/pda_app/ringer) in applications
				if(app)
					var/i = app.frequency + text2num(href_list["rfreq"])
					if(i < MINIMUM_FREQUENCY)
						i = 1201
					if(i > MAXIMUM_FREQUENCY)
						i = 1599
					app.frequency = i
			if("102")
				mode = 102
			if("setFilter")
				var/datum/pda_app/spam_filter/app = locate(/datum/pda_app/spam_filter) in applications
				if(app)
					app.function = text2num(href_list["filter"])
			if("103")
				mode = 103

			if("104")
				mode = 104

			if("minimapMarker")
				var/datum/pda_app/station_map/app = locate(/datum/pda_app/station_map) in applications
				switch(href_list["mMark"])
					if("x")
						var/new_x = input("Please input desired X coordinate.", "Station Map App", app.markx) as num
						var/x_validate=new_x+WORLD_X_OFFSET
						if(x_validate < 1 || x_validate > 255)
							usr << "<span class='caution'>Error: Invalid X coordinate.</span>"
						else
							app.markx = new_x
					if("y")
						var/new_y = input("Please input desired Y coordinate.", "Station Map App", app.marky) as num
						var/y_validate=new_y+WORLD_Y_OFFSET
						if(y_validate < 1 || y_validate > 255)
							usr << "<span class='caution'>Error: Invalid Y coordinate.</span>"
						else
							app.marky = new_y
					if("add")
						var/marker_name = copytext(sanitize(input("Give a name to your marker", "Station Map App", "default marker") as null|text),1,MAX_NAME_LEN)
						var/datum/minimap_marker/mkr = new/datum/minimap_marker()
						mkr.x = app.markx
						mkr.y = app.marky
						mkr.name = marker_name
						app.markers += mkr
						mkr.num = app.markers.len

			if("removeMarker")
				var/datum/pda_app/station_map/app = locate(/datum/pda_app/station_map) in applications
				var/to_remove = text2num(href_list["rMark"])
				var/datum/minimap_marker/mkr = app.markers[to_remove]
				del(mkr)

//MAIN FUNCTIONS===================================

			if("Light")
				if(fon)
					fon = 0
					if(src in U.contents)	U.SetLuminosity(U.luminosity - f_lum)
					else					SetLuminosity(0)
				else
					fon = 1
					if(src in U.contents)	U.SetLuminosity(U.luminosity + f_lum)
					else					SetLuminosity(f_lum)
			if("Medical Scan")
				if(scanmode == 1)
					scanmode = 0
				else if((!isnull(cartridge)) && (cartridge.access_medical))
					scanmode = 1
			if("Reagent Scan")
				if(scanmode == 3)
					scanmode = 0
				else if((!isnull(cartridge)) && (cartridge.access_reagent_scanner))
					scanmode = 3
			if("Halogen Counter")
				if(scanmode == 4)
					scanmode = 0
				else if((!isnull(cartridge)) && (cartridge.access_engine))
					scanmode = 4
			if("Honk")
				if ( !(last_honk && world.time < last_honk + 20) )
					playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
					last_honk = world.time
			if("Gas Scan")
				if(scanmode == 5)
					scanmode = 0
				else if((!isnull(cartridge)) && (cartridge.access_atmos))
					scanmode = 5
			if("Device Analyser")
				if(scanmode == 6)
					scanmode = 0
				else if((!isnull(cartridge)) && (cartridge.access_mechanic))
					if(!dev_analys)
						dev_analys = new //let's create that device analyser
					scanmode = 6

//MESSENGER/NOTE FUNCTIONS===================================

			if ("Edit")
				var/n = input(U, "Please enter message", name, notehtml) as message
				if (in_range(src, U) && loc == U)
					n = copytext(adminscrub(n), 1, MAX_MESSAGE_LEN)
					if (mode == 1)
						note = replacetext(n, "\n", "<BR>")
						notehtml = n
				else
					U << browse(null, "window=pda")
					return
			if("Toggle Messenger")
				toff = !toff
			if("Toggle Ringer")//If viewing texts then erase them, if not then toggle silent status
				silent = !silent
			if("Clear")//Clears messages
				tnote = null
			if("Ringtone")
				var/t = input(U, "Please enter new ringtone", name, ttone) as text
				if (in_range(src, U) && loc == U)
					if (t)
						if(src.hidden_uplink && hidden_uplink.check_trigger(U, trim(lowertext(t)), trim(lowertext(lock_code))))
							U << "The PDA softly beeps."
							U << browse(null, "window=pda")
							src.mode = 0
						else
							t = copytext(sanitize(t), 1, 20)
							ttone = t
				else
					U << browse(null, "window=pda")
					return
			if("Message")
				var/obj/item/device/pda/P = locate(href_list["target"])
				src.create_message(U, P)

			if("Send Honk")//Honk virus
				if(istype(cartridge, /obj/item/weapon/cartridge/clown))//Cartridge checks are kind of unnecessary since everything is done through switch.
					var/obj/item/device/pda/P = locate(href_list["target"])//Leaving it alone in case it may do something useful, I guess.
					if(!isnull(P))
						if (!P.toff && cartridge:honk_charges > 0)
							cartridge:honk_charges--
							U.show_message("\blue Virus sent!", 1)
							P.honkamt = (rand(15,20))
					else
						U << "PDA not found."
				else
					U << browse(null, "window=pda")
					return
			if("Send Silence")//Silent virus
				if(istype(cartridge, /obj/item/weapon/cartridge/mime))
					var/obj/item/device/pda/P = locate(href_list["target"])
					if(!isnull(P))
						if (!P.toff && cartridge:mime_charges > 0)
							cartridge:mime_charges--
							U.show_message("\blue Virus sent!", 1)
							P.silent = 1
							P.ttone = "silence"
					else
						U << "PDA not found."
				else
					U << browse(null, "window=pda")
					return


//SYNDICATE FUNCTIONS===================================

			if("Toggle Door")
				if(cartridge && cartridge.access_remote_door)
					for(var/obj/machinery/door/poddoor/M in world)
						if(M.id_tag == cartridge.remote_door_id)
							if(M.density)
								M.open()
							else
								M.close()

			if("Detonate")//Detonate PDA
				if(istype(cartridge, /obj/item/weapon/cartridge/syndicate))
					var/obj/item/device/pda/P = locate(href_list["target"])
					if(!isnull(P))
						if (!P.toff && cartridge:shock_charges > 0)
							cartridge:shock_charges--

							var/difficulty = 0

							if(P.cartridge)
								difficulty += P.cartridge.access_medical
								difficulty += P.cartridge.access_security
								difficulty += P.cartridge.access_engine
								difficulty += P.cartridge.access_clown
								difficulty += P.cartridge.access_janitor
								difficulty += P.cartridge.access_manifest * 2
							else
								difficulty += 2

							if(prob(difficulty * 12) || (P.hidden_uplink))
								U.show_message("\red An error flashes on your [src].", 1)
							else if (prob(difficulty * 3))
								U.show_message("\red Energy feeds back into your [src]!", 1)
								U << browse(null, "window=pda")
								explode()
								log_admin("[key_name(U)] just attempted to blow up [P] with the Detomatix cartridge but failed, blowing themselves up")
								message_admins("[key_name_admin(U)] just attempted to blow up [P] with the Detomatix cartridge but failed, blowing themselves up", 1)
							else
								U.show_message("\blue Success!", 1)
								log_admin("[key_name(U)] just attempted to blow up [P] with the Detomatix cartridge and succeded")
								message_admins("[key_name_admin(U)] just attempted to blow up [P] with the Detomatix cartridge and succeded", 1)
								P.explode()
					else
						U << "PDA not found."
				else
					U.unset_machine()
					U << browse(null, "window=pda")
					return

//pAI FUNCTIONS===================================
			if("pai")
				switch(href_list["option"])
					if("1")		// Configure pAI device
						pai.attack_self(U)
					if("2")		// Eject pAI device
						var/turf/T = get_turf(src.loc)
						if(T)
							pai.loc = T

//LINK FUNCTIONS===================================

			else//Cartridge menu linking
				mode = text2num(href_list["choice"])
				cartridge.mode = mode
				cartridge.unlock()
	else//If not in range, can't interact or not using the pda.
		U.unset_machine()
		U << browse(null, "window=pda")
		return

//EXTRA FUNCTIONS===================================

	if (mode == 2||mode == 21)//To clear message overlays.
		overlays.Cut()

	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)

	if(U.machine == src && href_list["skiprefresh"]!="1")//Final safety.
		attack_self(U)//It auto-closes the menu prior if the user is not in range and so on.
	else
		U.unset_machine()
		U << browse(null, "window=pda")
	return

/obj/item/device/pda/proc/remove_id()
	if (id)
		if (ismob(loc))
			var/mob/M = loc
			M.put_in_hands(id)
			usr << "<span class='notice'>You remove the ID from the [name].</span>"
		else
			id.loc = get_turf(src)
		id = null

/obj/item/device/pda/proc/create_message(var/mob/living/U = usr, var/obj/item/device/pda/P)

	var/t = input(U, "Please enter message", name, null) as text
	t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
	if (!t || !istype(P))
		return
	if (!in_range(src, U) && loc != U)
		return

	if (isnull(P)||P.toff || toff)
		return

	if (last_text && world.time < last_text + 5)
		return

	if(!can_use(U))
		return

	last_text = world.time
	// check if telecomms I/O route 1459 is stable
	//var/telecomms_intact = telecomms_process(P.owner, owner, t)
	var/obj/machinery/message_server/useMS = null
	if(message_servers)
		for (var/obj/machinery/message_server/MS in message_servers)
		//PDAs are now dependant on the Message Server.
			if(MS.active)
				useMS = MS
				break

	var/datum/signal/signal = src.telecomms_process()

	var/useTC = 0
	if(signal)
		if(signal.data["done"])
			useTC = 1
			var/turf/pos = get_turf(P)
			if(pos.z in signal.data["level"])
				useTC = 2
				//Let's make this barely readable
				if(signal.data["compression"] > 0)
					t = Gibberish(t, signal.data["compression"] + 50)

	if(useMS && useTC) // only send the message if it's stable
		if(useTC != 2) // Does our recepient have a broadcaster on their level?
			U << "ERROR: Cannot reach recepient."
			return
		useMS.send_pda_message("[P.owner]","[owner]","[t]")

		tnote += "<i><b>&rarr; To [P.owner]:</b></i><br>[t]<br>"
		P.tnote += "<i><b>&larr; From <a href='byond://?src=\ref[P];choice=Message;target=\ref[src]'>[owner]</a> ([ownjob]):</b></i><br>[t]<br>"
		for(var/mob/dead/observer/M in player_list)
			if(M.stat == DEAD && M.client && (M.client.prefs.toggles & CHAT_GHOSTPDA)) // src.client is so that ghosts don't have to listen to mice
				M.show_message("<span class='game say'>PDA Message - <span class='name'>[owner]</span> -> <span class='name'>[P.owner]</span>: <span class='message'>[t]</span></span>")


		if (prob(15)) //Give the AI a chance of intercepting the message
			var/who = src.owner
			if(prob(50))
				who = P:owner
			for(var/mob/living/silicon/ai/ai in mob_list)
				// Allows other AIs to intercept the message but the AI won't intercept their own message.
				if(ai.aiPDA != P && ai.aiPDA != src)
					ai.show_message("<i>Intercepted message from <b>[who]</b>: [t]</i>")

		if (!P.silent)
			playsound(P.loc, 'sound/machines/twobeep.ogg', 50, 1)
		for (var/mob/O in hearers(3, P.loc))
			if(!P.silent) O.show_message(text("\icon[P] *[P.ttone]*"))
		//Search for holder of the PDA.
		var/mob/living/L = null
		if(P.loc && isliving(P.loc))
			L = P.loc
		//Maybe they are a pAI!
		else
			L = get(P, /mob/living/silicon)

		if(L)
			L << "\icon[P] <b>Message from [src.owner] ([ownjob]), </b>\"[t]\" (<a href='byond://?src=\ref[P];choice=Message;skiprefresh=1;target=\ref[src]'>Reply</a>)"

		log_pda("[usr] (PDA: [src.name]) sent \"[t]\" to [P.name]")
		P.overlays.Cut()
		P.overlays += image('icons/obj/pda.dmi', "pda-r")
	else
		U << "<span class='notice'>ERROR: Messaging server is not responding.</span>"


/obj/item/device/pda/verb/verb_remove_id()
	set category = "Object"
	set name = "Remove id"
	set src in usr

	if(issilicon(usr))
		return

	if ( can_use(usr) )
		if(id)
			remove_id()
		else
			usr << "<span class='notice'>This PDA does not have an ID in it.</span>"
	else
		usr << "<span class='notice'>You cannot do this while restrained.</span>"


/obj/item/device/pda/verb/verb_remove_pen()
	set category = "Object"
	set name = "Remove pen"
	set src in usr

	if(issilicon(usr))
		return

	if ( can_use(usr) )
		var/obj/item/weapon/pen/O = locate() in src
		if(O)
			if (istype(loc, /mob))
				var/mob/M = loc
				if(M.get_active_hand() == null)
					M.put_in_hands(O)
					usr << "<span class='notice'>You remove \the [O] from \the [src].</span>"
					return
			O.loc = get_turf(src)
		else
			usr << "<span class='notice'>This PDA does not have a pen in it.</span>"
	else
		usr << "<span class='notice'>You cannot do this while restrained.</span>"

/obj/item/device/pda/proc/id_check(mob/user as mob, choice as num)//To check for IDs; 1 for in-pda use, 2 for out of pda use.
	if(choice == 1)
		if (id)
			remove_id()
		else
			var/obj/item/I = user.get_active_hand()
			if (istype(I, /obj/item/weapon/card/id))
				user.drop_item()
				I.loc = src
				id = I
	else
		var/obj/item/weapon/card/I = user.get_active_hand()
		if (istype(I, /obj/item/weapon/card/id) && I:registered_name)
			var/obj/old_id = id
			user.drop_item()
			I.loc = src
			id = I
			user.put_in_hands(old_id)
	return

// access to status display signals
/obj/item/device/pda/attackby(obj/item/C as obj, mob/user as mob)
	..()
	if(istype(C, /obj/item/weapon/cartridge) && !cartridge)
		cartridge = C
		user.drop_item()
		cartridge.loc = src
		user << "<span class='notice'>You insert [cartridge] into [src].</span>"
		if(cartridge.radio)
			cartridge.radio.hostpda = src

	else if(istype(C, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/idcard = C
		if(!idcard.registered_name)
			user << "<span class='notice'>\The [src] rejects the ID.</span>"
			return
		if(!owner)
			owner = idcard.registered_name
			ownjob = idcard.assignment
			name = "PDA-[owner] ([ownjob])"
			user << "<span class='notice'>Card scanned.</span>"
		else
			//Basic safety check. If either both objects are held by user or PDA is on ground and card is in hand.
			if(((src in user.contents) && (C in user.contents)) || (istype(loc, /turf) && in_range(src, user) && (C in user.contents)) )
				if( can_use(user) )//If they can still act.
					id_check(user, 2)
					user << "<span class='notice'>You put the ID into \the [src]'s slot.</span>"
					updateSelfDialog()//Update self dialog on success.
			return	//Return in case of failed check or when successful.
		updateSelfDialog()//For the non-input related code.
	else if(istype(C, /obj/item/device/paicard) && !src.pai)
		user.drop_item()
		C.loc = src
		pai = C
		user << "<span class='notice'>You slot \the [C] into [src].</span>"
		updateUsrDialog()
	else if(istype(C, /obj/item/weapon/pen))
		var/obj/item/weapon/pen/O = locate() in src
		if(O)
			user << "<span class='notice'>There is already a pen in \the [src].</span>"
		else
			user.drop_item()
			C.loc = src
			user << "<span class='notice'>You slide \the [C] into \the [src].</span>"
	return

/obj/item/device/pda/attack(mob/living/carbon/C, mob/living/user as mob)
	if(istype(C))
		switch(scanmode)

			if(1)

				for (var/mob/O in viewers(C, null))
					O.show_message("\red [user] has analyzed [C]'s vitals!", 1)

				user.show_message("\blue Analyzing Results for [C]:")
				user.show_message("\blue \t Overall Status: [C.stat > 1 ? "dead" : "[C.health - C.halloss]% healthy"]", 1)
				user.show_message("\blue \t Damage Specifics: [C.getOxyLoss() > 50 ? "\red" : "\blue"][C.getOxyLoss()]-[C.getToxLoss() > 50 ? "\red" : "\blue"][C.getToxLoss()]-[C.getFireLoss() > 50 ? "\red" : "\blue"][C.getFireLoss()]-[C.getBruteLoss() > 50 ? "\red" : "\blue"][C.getBruteLoss()]", 1)
				user.show_message("\blue \t Key: Suffocation/Toxin/Burns/Brute", 1)
				user.show_message("\blue \t Body Temperature: [C.bodytemperature-T0C]&deg;C ([C.bodytemperature*1.8-459.67]&deg;F)", 1)
				if(C.tod && (C.stat == DEAD || (C.status_flags & FAKEDEATH)))
					user.show_message("\blue \t Time of Death: [C.tod]")
				if(istype(C, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = C
					var/list/damaged = H.get_damaged_organs(1,1)
					user.show_message("\blue Localized Damage, Brute/Burn:",1)
					if(length(damaged)>0)
						for(var/datum/organ/external/org in damaged)
							user.show_message(text("\blue \t []: []\blue-[]",capitalize(org.display_name),(org.brute_dam > 0)?"\red [org.brute_dam]":0,(org.burn_dam > 0)?"\red [org.burn_dam]":0),1)
					else
						user.show_message("\blue \t Limbs are OK.",1)

				for(var/datum/disease/D in C.viruses)
					if(!D.hidden[SCANNER])
						user.show_message(text("\red <b>Warning: [D.form] Detected</b>\nName: [D.name].\nType: [D.spread].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure]"))

			if(2)
				if (!istype(C:dna, /datum/dna))
					user << "\blue No fingerprints found on [C]"
				else if(!istype(C, /mob/living/carbon/monkey))
					if(!isnull(C:gloves))
						user << "\blue No fingerprints found on [C]"
				else
					user << text("\blue [C]'s Fingerprints: [md5(C:dna.uni_identity)]")
				if ( !(C:blood_DNA) )
					user << "\blue No blood found on [C]"
					if(C:blood_DNA)
						del(C:blood_DNA)
				else
					user << "\blue Blood found on [C]. Analysing..."
					spawn(15)
						for(var/blood in C:blood_DNA)
							user << "\blue Blood type: [C:blood_DNA[blood]]\nDNA: [blood]"

			if(4)
				for (var/mob/O in viewers(C, null))
					O.show_message("\red [user] has analyzed [C]'s radiation levels!", 1)

				user.show_message("\blue Analyzing Results for [C]:")
				if(C.radiation)
					user.show_message("\green Radiation Level: \black [C.radiation]")
				else
					user.show_message("\blue No radiation detected.")

/obj/item/device/pda/afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
	switch(scanmode)

		if(3)
			if(!isnull(A.reagents))
				if(A.reagents.reagent_list.len > 0)
					var/reagents_length = A.reagents.reagent_list.len
					user << "\blue [reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found."
					for (var/re in A.reagents.reagent_list)
						user << "\blue \t [re]"
				else
					user << "\blue No active chemical agents found in [A]."
			else
				user << "\blue No significant chemical agents found in [A]."

		if(5)
			if((istype(A, /obj/item/weapon/tank)) || (istype(A, /obj/machinery/portable_atmospherics)))
				var/obj/icon = A
				for (var/mob/O in viewers(user, null))
					O << "\red [user] has used [src] on \icon[icon] [A]"
				var/pressure = A:air_contents.return_pressure()

				var/total_moles = A:air_contents.total_moles()

				user << "\blue Results of analysis of \icon[icon]"
				if (total_moles>0)
					var/o2_concentration = A:air_contents.oxygen/total_moles
					var/n2_concentration = A:air_contents.nitrogen/total_moles
					var/co2_concentration = A:air_contents.carbon_dioxide/total_moles
					var/plasma_concentration = A:air_contents.toxins/total_moles

					var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)

					user << "\blue Pressure: [round(pressure,0.1)] kPa"
					user << "\blue Nitrogen: [round(n2_concentration*100)]%"
					user << "\blue Oxygen: [round(o2_concentration*100)]%"
					user << "\blue CO2: [round(co2_concentration*100)]%"
					user << "\blue Plasma: [round(plasma_concentration*100)]%"
					if(unknown_concentration>0.01)
						user << "\red Unknown: [round(unknown_concentration*100)]%"
					user << "\blue Temperature: [round(A:air_contents.temperature-T0C)]&deg;C"
				else
					user << "\blue Tank is empty!"

			if (istype(A, /obj/machinery/atmospherics/pipe/tank))
				var/obj/icon = A
				for (var/mob/O in viewers(user, null))
					O << "\red [user] has used [src] on \icon[icon] [A]"

				var/obj/machinery/atmospherics/pipe/tank/T = A
				var/pressure = T.parent.air.return_pressure()
				var/total_moles = T.parent.air.total_moles()

				user << "\blue Results of analysis of \icon[icon]"
				if (total_moles>0)
					var/o2_concentration = T.parent.air.oxygen/total_moles
					var/n2_concentration = T.parent.air.nitrogen/total_moles
					var/co2_concentration = T.parent.air.carbon_dioxide/total_moles
					var/plasma_concentration = T.parent.air.toxins/total_moles

					var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)

					user << "\blue Pressure: [round(pressure,0.1)] kPa"
					user << "\blue Nitrogen: [round(n2_concentration*100)]%"
					user << "\blue Oxygen: [round(o2_concentration*100)]%"
					user << "\blue CO2: [round(co2_concentration*100)]%"
					user << "\blue Plasma: [round(plasma_concentration*100)]%"
					if(unknown_concentration>0.01)
						user << "\red Unknown: [round(unknown_concentration*100)]%"
					user << "\blue Temperature: [round(T.parent.air.temperature-T0C)]&deg;C"
				else
					user << "\blue Tank is empty!"

		if (6)
			if(dev_analys) //let's use this instead. Much neater
				dev_analys.afterattack(A, user)
				A.attackby(src, user)

	if (!scanmode && istype(A, /obj/item/weapon/paper) && owner)
		note = A:info
		user << "\blue Paper scanned." //concept of scanning paper copyright brainoblivion 2009


/obj/item/device/pda/proc/explode() //This needs tuning.
	if(!src.detonate) return
	var/turf/T = get_turf(src.loc)

	if (ismob(loc))
		var/mob/M = loc
		M.show_message("\red Your [src] explodes!", 1)

	if(T)
		T.hotspot_expose(700,125,surfaces=istype(loc,/turf))

		explosion(T, -1, -1, 2, 3)

	del(src)
	return

/obj/item/device/pda/Destroy()
	PDAs -= src
	if (src.id)
		src.id.loc = get_turf(src.loc)
	if(src.pai)
		src.pai.loc = get_turf(src.loc)
	..()

/obj/item/device/pda/clown/Crossed(AM as mob|obj) //Clown PDA is slippery.
	if (istype(AM, /mob/living/carbon))
		var/mob/M =	AM
		if ((istype(M, /mob/living/carbon/human) && (istype(M:shoes, /obj/item/clothing/shoes) && M:shoes.flags&NOSLIP)) || M.m_intent == "walk")
			return

		if ((istype(M, /mob/living/carbon/human) && (M.real_name != src.owner) && (istype(src.cartridge, /obj/item/weapon/cartridge/clown))))
			if (src.cartridge:honk_charges < 5)
				src.cartridge:honk_charges++

		M.stop_pulling()
		M << "\blue You slipped on the PDA!"
		playsound(get_turf(src), 'sound/misc/slip.ogg', 50, 1, -3)
		M.Stun(8)
		M.Weaken(5)

/obj/item/device/pda/proc/available_pdas()
	var/list/names = list()
	var/list/plist = list()
	var/list/namecounts = list()

	if (toff)
		usr << "Turn on your receiver in order to send messages."
		return

	for (var/obj/item/device/pda/P in PDAs)
		if (!P.owner)
			continue
		else if(P.hidden)
			continue
		else if (P == src)
			continue
		else if (P.toff)
			continue

		var/name = P.owner
		if (name in names)
			namecounts[name]++
			name = text("[name] ([namecounts[name]])")
		else
			names.Add(name)
			namecounts[name] = 1

		plist[text("[name]")] = P
	return plist


//Some spare PDAs in a box
/obj/item/weapon/storage/box/PDAs
	name = "spare PDAs"
	desc = "A box of spare PDA microcomputers."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdabox"

	New()
		..()
		new /obj/item/device/pda(src)
		new /obj/item/device/pda(src)
		new /obj/item/device/pda(src)
		new /obj/item/device/pda(src)
		new /obj/item/weapon/cartridge/head(src)

		var/newcart = pick(	/obj/item/weapon/cartridge/engineering,
							/obj/item/weapon/cartridge/security,
							/obj/item/weapon/cartridge/medical,
							/obj/item/weapon/cartridge/signal/toxins,
							/obj/item/weapon/cartridge/quartermaster)
		new newcart(src)

// Pass along the pulse to atoms in contents, largely added so pAIs are vulnerable to EMP
/obj/item/device/pda/emp_act(severity)
	for(var/atom/A in src)
		A.emp_act(severity)

/proc/get_viewable_pdas()
	. = list()
	// Returns a list of PDAs which can be viewed from another PDA/message monitor.
	for(var/obj/item/device/pda/P in PDAs)
		if(!P.owner || P.toff || P.hidden) continue
		. += P
	return .
