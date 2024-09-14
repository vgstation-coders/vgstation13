/datum/pda_app/alarm
	name = "Alarm"
	desc = "Set a time for a personal alarm to trigger."
	price = 0
	menu = FALSE // It's listed elsewhere by the clock
	icon = "pda_clock"
	var/target = 0
	var/status = 1			//	0=off 1=on
	var/lasttimer = 0

/datum/pda_app/alarm/get_dat(var/mob/user)
	return {"
		<h4>Alarm Application</h4>
		The alarm is currently <a href='byond://?src=\ref[src];toggleAlarm=1'>[status ? "ON" : "OFF"]</a><br>
		Current Time:[worldtime2text()]<BR>
		Alarm Time: [target ? "[worldtime2text(target)]" : "Unset"] <a href='byond://?src=\ref[src];setAlarm=1'>SET</a><BR>
		"}

/datum/pda_app/alarm/Topic(href, href_list)
	if(..())
		return
	if(href_list["toggleAlarm"])
		status = !status
	if(href_list["setAlarm"])
		var/nutime = round(input("How long before the alarm triggers, in seconds?", "Alarm", 1) as num)
		if(set_alarm(nutime))
			to_chat(usr, "[bicon(pda_device)]<span class='info'>The PDA confirms your [nutime] second timer.</span>")
	if(href_list["restartAlarm"])
		if(restart_alarm())
			to_chat(usr, "[bicon(pda_device)]<span class='info'>The PDA confirms your [lasttimer] second timer.</span>")
			no_refresh = TRUE
	refresh_pda()

/datum/pda_app/alarm/proc/set_alarm(var/await)
	if(await<=0)
		return FALSE
	target = world.time + (await SECONDS)
	lasttimer = await
	spawn((await SECONDS) + 1 SECONDS)
		alarm()
	return TRUE

/datum/pda_app/alarm/proc/alarm()
	if(!status || world.time < target)
		return //End the loop if it was disabled or if the target isn't here yet. e.g.: target changed
	playsound(pda_device, 'sound/machines/chime.ogg', 40, FALSE, -2)
	var/mob/living/L = get_holder_of_type(pda_device,/mob/living)
	if(L)
		to_chat(usr, "[bicon(pda_device)]<span class='info'>Timer for [lasttimer] seconds has finished. <a href='byond://?src=\ref[src];restartAlarm=1'>(Restart?)</a></span>")

/datum/pda_app/alarm/proc/restart_alarm()
	if(!status || world.time < target || lasttimer <= 0)
		return //End the loop if it was disabled or already active
	return set_alarm(lasttimer)

/datum/pda_app/notekeeper
	name = "Notekeeper"
	desc = "For when your mind isn't focused enough to keep them."
	price = 0
	icon = "pda_notes"
	var/note = "Congratulations, your station has chosen the Thinktronic 5230 Personal Data Assistant!" //Current note in the notepad function
	var/notehtml = ""

/datum/pda_app/notekeeper/get_dat(var/mob/user)
	return "<h4><span class='pda_icon pda_notes'></span> Notekeeper V2.1</h4> <a href='byond://?src=\ref[src];Edit=1'>Edit</a><br>[note]"

/datum/pda_app/notekeeper/Topic(href, href_list)
	if(..())
		return
	var/mob/living/U = usr
	if (href_list["Edit"])
		var/n = input(U, "Please enter message", name, notehtml) as message
		if (in_range(pda_device, U) && pda_device.loc == U)
			n = copytext(adminscrub(n), 1, MAX_MESSAGE_LEN)
			if (pda_device.current_app == src)
				note = replacetext(n, "\n", "<BR>")
				notehtml = n

				var/log = replacetext(n, "\n", "(new line)")//no intentionally spamming admins with 100 lines, nice try
				log_say("[pda_device] notes - [U] changed the text to: [log]")
				for(var/mob/dead/observer/M in player_list)
					if(M.stat == DEAD && M.client && (M.client.prefs.toggles & CHAT_GHOSTPDA))
						M.show_message("<span class='game say'>[pda_device] notes - <span class = 'name'>[U]</span> changed the text to:</span> [log]")
		else
			U << browse(null, "window=pda")
			return
	refresh_pda()

var/global/list/currentevents1 = list("The Prime Minister of Space Australia has announced today a new policy to hand out fake dollar bills to the poor.",
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
var/global/list/currentevents2 = list("CEO Discount Dan has been sued. Again.",
	"Nanotrasen has inducted a new policy wherein clowns will be spanked for stealing milk.",
	"Discount Dan's has created a new line of Discountu Danu food product for Space Japan. The food is comprised of Space Carp on rice. More at ten.",
	"Discount Dan's has come under fire for their new 'Horsemeat Lasagna'",
	"Nanotrasen's official website has been hacked this morning. The site read 'NT SUXZ, GO SYNDIEKATTZ!!1!1!!' for 48 hours until the site was fixed.",
	"Read the all new book by a former unnamed syndicate, 'Nanotrasen sucks but the dental is good so whatever.'",
	"Nanotrasen has released a new study that has been made useless by the internet.",
	"Discount Dan's 'Spooky Dan' line of product has come under fire for being unintentionally racist toward ghosts.",
	"Discount Dan's 'Discounto Danito' line of product has come out with a new 'fiesta size' burrito. CEO Discount Dan has been quoted as saying, 'A big 'ol clot for a big 'ol family!'",
	"The Syndicate has issued a press release stating that 'Nanotrasen sucks dicks.'",
	"Nanotrasen CEO John Nanotrasen has been photographed kicking a Tajaran to death. This shameful publicity stunt is part of the new 'NT Hates Catbeasts, do you?' campaign.",
	"Nanotrasen CEO John Nanotrasen has been photographed kicking a Vox in the cloaca. He commented that, 'BIRDS BELONG IN MY FUCKING MEALS DAMN IT'.",
	"Nanotrasen CEO John Nanotrasen is in hot water for an alleged sex scandal with a confused syndicate woman that took the motto 'Fuck NT' too seriously.",
	"Nanotrasen CEO John Nanotrasen issued a press release stating, 'Anybody who's fucking impersonating me is going to get fucking bluespaced unto a spike.'. We do not condone Mr. Nanotrasen's use of foul language in the newsroom.",
	"Nanotrasen CEO John Nanotrasen and Discount Dan's CEO Discount Dan have been photographed buying a new friend necklace. The Syndicate issued a statement that 'That's totally gay.'",
	"Discount Dan has been photographed this evening hunting the endangered albino space panda. When questioned, he replied that the endangered animal was 'Good eats'.",
	"Nanotrasen's head programmer quit this evening when people did not respond well to his new features on NTOS. Said features included the ability to instantly transmit pictures of your butt to people by blinking.",
	"Nanotrasen CEO John Nanotrasen was photographed this morning celebrating his birthday with well deserved hookers and blow.",
	"Discount Dan's stock has risen 20 points today after CEO Discount Dan promised to include a free toy in every 'Happy Dan' meal. In other news, we have over 300 confirmed reports of broken teeth and lead poisoning in children 6 and under.",
	"Discount Dan has come under fire today after trying to hug a plasmaman whilst smoking a cigar. He is being treated for 3rd degree burns at the moment, and we at the newsroom wish him luck.",
	"Nanotrasen's treasurer Shlomo Goldburginstein died today in a tragic cooking incident with NT Officer Gass Judenraigh."
	)
var/global/list/currentevents3 = list("Border patrol around Space America has tightened today after a wave of Tajarans yiffed their way across. We have reports of over 2000 molested Space Americans. More to come at seven.",
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
	"Today, a man was discovered to be living with a 20 year old ghost in his house. When the ghost was questioned who killed him, he responded 'A BASTARD!'. More at four.",
	"Scientists report that ghosts do in fact exist, however, they are huge assholes.",
	"Supermatter researchers today have reported that the substance is highly volatile and could possibly rip apart the universe in large quantities. Discount Dan has been reported as ordering over 1000 pounds of supermatter shards.",
	"Scientists working at the BPRF have discovered a pocket universe comprised fully of dead clown souls today. 40 scientists are being treated for madness."
	)
var/global/list/history = list("Adolf Hitler's cyborg body was lain to rest after the ending of WW4.",
	"World War Buttbot began, the following war claimed the asses of over 500000 young gentlemen.",
	"The 54th President of the United States of Space America was shot in the dick. He succumbed to his injuries after medbay threw him in cryo for an entire day.",
	"The first great zombie apocalypse began on Venus.",
	"The first man to step on Pluto slipped and was impaled on an ice spike shortly after landing.",
	"North Korea became the first country to land a rocket on the sun.",
	"Kim Jong Long Dong Silver, 58th generation leader of North Korea, died after being shot seventy two times in the chest.",
	"Nanotrasen's new 'Space Station 13' project was announced.",
	"Jupiter and Neptune became sentient for a period of 78 hours, Jupiter was heard screaming 'WHY AM I ALIVE DEAR GOD.', whilst curiously, Neptune only said 'Well here we go again.'.",
	"The first furry in space was thrown out an airlock, along with his fursuit.",
	"The 89th President of Space America read Woody's Got Wood aloud in his first State of the Union, and was beaten to death shortly after.",
	"Space France surrendered for the 10124th time, making it the most invaded country in the galaxy.",
	"Our glorious leader Karl Pilkington the 24th was crowned emperor of the Intergalactic Human Empire.",
	"Everyone in the universe said 'Dave sucks.' at the same time. The cause of this event was unknown, but over 200000 men named Dave were murdered.",
	"A cult religion following the belief god was a chicken was created.",
	)
var/global/list/facts = list("If you have 3 quarters, 4 dimes, and 4 pennies, you have $1.19. You also have the largest amount of money in coins without being able to make change for a dollar.",
	"The numbers '172' can be found on the back of the U.S. $5 dollar bill in the bushes at the base of the Lincoln Memorial.",
	"President Kennedy was the fastest random speaker in the world with upwards of 350 words per minute.",
	"In the average lifetime, a person will walk the equivalent of 5 times around the equator.",
	"Odontophobia is the fear of teeth.",
	"The surface area of an average-sized brick is 79 cm squared.",
	"According to suicide statistics, Monday is the favoured day for self-destruction.",
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
	"7.5 million toothpicks can be created from a cord of wood.",
	"If the Earth's sun were just inch in diameter, the nearest star would be 445 miles away.",
	"There is no word in the English language that rhymes with month, orange, silver or purple.",
	"Starfish have no brains.",
	"2 and 5 are the only prime numbers that end in 2 or 5.",
	"'Pronunciation' is the word which is mispronounced the most in the English language.",
	"Women blink nearly twice as much as men.",
	"Owls are the only birds who can see the color blue.",
	"A pizza that has radius 'z' and height 'a' has volume Pi × z × z × a.",
	"Months that begin on a Sunday will always have a 'Friday the 13th.'",
	"Zero is an even number.",
	"The longest English word that can be spelled without repeating any letters is 'uncopyrightable'.",
	"10! (Ten factorial) seconds equals exactly six Earth weeks.",
	"Want to remember the first digits of Pi easily? You can do it by counting each word's letters in 'May I have a large container of plasma?'"
	)

/datum/pda_app/events
	name = "Current Events"
	desc = "It's happening."
	price = 0
	icon = "pda_clock"
	var/currentevent1 = null
	var/currentevent2 = null
	var/currentevent3 = null
	var/onthisday = null

/datum/pda_app/events/onInstall()
	..()
	currentevent1 = pick(currentevents1)
	currentevent2 = pick(currentevents2)
	currentevent3 = pick(currentevents3)
	onthisday = pick(history)

/datum/pda_app/events/get_dat(var/mob/user)
    return {"<h4><span class='pda_icon pda_clock'></span> Current Events</h4>
        Station Time: <b>[worldtime2text()]</b>.<br>
        Empire Date: <b>[pda_device.MM]/[pda_device.DD]/[game_year]</b>.<br><br>
        <b>Current Events,</b><br>
        <li>[currentevent1]</li<br>
        <li>[currentevent2]</li><br>
        <li>[currentevent3]</li><br><br>
        <b>On this day,</b><br>
        <li>[onthisday]</li><br><br>
        <b>Did you know...</b><br>
        <li>[pick(facts)]</li><br>"}

/datum/pda_app/manifest
	name = "View Crew Manifest"
	desc = "Find out which captain you should call a comdom."
	price = 0
	icon = "pda_notes"

/datum/pda_app/manifest/get_dat(var/mob/user)
    var/dat = {"<h4><span class='pda_icon pda_notes'></span> Crew Manifest</h4>
        Entries cannot be modified from this terminal.<br><br>"}
    if(data_core)
        dat += data_core.get_manifest(1) // make it monochrome
    dat += "<br>"
    return dat

/datum/pda_app/balance_check
	name = "Virtual Wallet and Balance Check"
	desc = "Connects to the Account Database to check the balance history the inserted ID card."
	price = 0
	icon = "pda_money"
	var/obj/machinery/account_database/linked_db

/datum/pda_app/balance_check/onInstall()
	..()
	reconnect_database()

/datum/pda_app/balance_check/get_dat(var/mob/user)
	var/dat = {"<h4><span class='pda_icon [icon]'></span> Virtual Wallet and Balance Check Application</h4>"}
	if(!pda_device.id)
		dat += {"<i>Insert an ID card in the PDA to use this application.</i>"}
	else
		var/MM = pda_device.MM
		var/DD = pda_device.DD
		if(!pda_device.id.virtual_wallet)
			pda_device.id.update_virtual_wallet()
		dat += {"<hr>
			<h5>Virtual Wallet</h5>
			Owner: <b>[pda_device.id.virtual_wallet.owner_name]</b><br>
			Balance: <b>[pda_device.id.virtual_wallet.money]</b>$  <u><a href='byond://?src=\ref[src];printCurrency=1'><span class='pda_icon [icon]'></span>Print Currency</a></u>
			<h6>Transaction History</h6>
			On [MM]/[DD]/[game_year]:
			<ul>
			"}
		var/list/v_log = list()
		for(var/e in pda_device.id.virtual_wallet.transaction_log)
			v_log += e
		for(var/datum/transaction/T in reverseRange(v_log))
			dat += {"<li>\[[T.time]\] [T.amount]$, [T.purpose] at [T.source_terminal]</li>"}
		dat += {"</ul><hr>"}
		if(!(linked_db))
			reconnect_database()
		if(linked_db)
			if(linked_db.activated)
				var/datum/money_account/D = linked_db.attempt_account_access(pda_device.id.associated_account_number, 0, 2, 0)
				if(D)
					dat += {"
						<h5>Bank Account</h5>
						Owner: <b>[D.owner_name]</b><br>
						Balance: <b>[D.money]</b>$
						<h6>Transaction History</h6>
						On [MM]/[DD]/[game_year]:
						<ul>
						"}
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
					dat += {"
						<h5>Bank Account</h5>
						<i>Unable to access bank account. Either its security settings don't allow remote checking or the account is nonexistent.</i>
						"}
			else
				dat += {"
					<h5>Bank Account</h5>
					<i>Unfortunately your station's Accounts Database doesn't allow remote access. Negociate with your HoP or Captain to solve this issue.</i>
					"}
		else
			dat += {"
				<h5>Bank Account</h5>
				<i>Unable to connect to accounts database. The database is either nonexistent, inoperative, or too far away.</i>
				"}
	return dat

/datum/pda_app/balance_check/Topic(href, href_list)
	if(..())
		return
	if(href_list["printCurrency"])
		var/mob/user = usr
		var/amount = round(input("How much money do you wish to print?", "Currency Printer", 0) as num)
		if(!amount || (amount < 0) || (pda_device.id.virtual_wallet.money <= 0))
			to_chat(user, "[bicon(pda_device)]<span class='warning'>The PDA's screen flashes, 'Invalid value.'</span>")
			return
		if(amount > pda_device.id.virtual_wallet.money)
			amount = pda_device.id.virtual_wallet.money
		if(amount > 10000) // prevent crashes
			to_chat(user, "[bicon(pda_device)]<span class='notice'>The PDA's screen flashes, 'Maximum single withdrawl limit reached, defaulting to 10,000.'</span>")
			amount = 10000

		if(withdraw_arbitrary_sum(user,amount))
			pda_device.id.virtual_wallet.money -= amount
			if(prob(50))
				playsound(pda_device, 'sound/items/polaroid1.ogg', 50, 1)
			else
				playsound(pda_device, 'sound/items/polaroid2.ogg', 50, 1)

			new /datum/transaction(pda_device.id.virtual_wallet, "Currency printed", "-[amount]", pda_device.name, user.name)
	refresh_pda()

/datum/pda_app/balance_check/proc/reconnect_database()
	for(var/obj/machinery/account_database/DB in account_DBs)
		//Checks for a database on its Z-level, else it checks for a database at the main Station.
		if((pda_device.loc && (DB.z == pda_device.loc.z)) || (DB.z == map.zMainStation))
			if((DB.stat == 0) && DB.activated )//If the database if damaged or not powered, people won't be able to use the app anymore.
				linked_db = DB
				break

//Convert money from the virtual wallet into physical bills
/datum/pda_app/balance_check/proc/withdraw_arbitrary_sum(var/mob/user,var/arbitrary_sum)
	if(!linked_db)
		reconnect_database() //Make one attempt to reconnect
	if(!linked_db || !linked_db.activated || linked_db.stat & (BROKEN|NOPOWER))
		to_chat(user, "[bicon(pda_device)] <span class='warning'>No connection to account database.</span>")
		return 0
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(istype(H.wear_id,/obj/item/weapon/storage/wallet))
			dispense_cash(arbitrary_sum,H.wear_id)
			to_chat(usr, "[bicon(pda_device)]<span class='notice'>Funds were transferred into your physical wallet!</span>")
			return 1
	var/list/L = dispense_cash(arbitrary_sum,get_turf(src))
	for(var/obj/I in L)
		user.put_in_hands(I)
	return 1

/datum/pda_app/balance_check/Destroy()
	linked_db = null
	..()

/datum/pda_app/atmos_scan
	name = "Atmospheric Scan"
	desc = "Provides a readout of atmospheric data around the user."
	category = "Utilities"
	price = 0
	icon = "pda_atmos"

/datum/pda_app/atmos_scan/get_dat(var/mob/user)
	var/dat = "<h4><span class='pda_icon pda_atmos'></span> Atmospheric Readings</h4>"

	if (isnull(user.loc))
		dat += "Unable to obtain a reading.<br>"
	else
		var/datum/gas_mixture/environment = user.loc.return_air()

		if(!environment)
			dat += "No gasses detected.<br>"

		else
			var/pressure = environment.return_pressure()
			var/total_moles = environment.total_moles()

			dat += "Air Pressure: [round(pressure,0.1)] kPa<br>"

			if (total_moles)
				var/o2_level = environment[GAS_OXYGEN]/total_moles
				var/n2_level = environment[GAS_NITROGEN]/total_moles
				var/co2_level = environment[GAS_CARBON]/total_moles
				var/plasma_level = environment[GAS_PLASMA]/total_moles
				var/unknown_level =  1-(o2_level+n2_level+co2_level+plasma_level)

				dat += {"Nitrogen: [round(n2_level*100)]%<br>
					Oxygen: [round(o2_level*100)]%<br>
					Carbon Dioxide: [round(co2_level*100)]%<br>
					Plasma: [round(plasma_level*100)]%<br>"}
				if(unknown_level > 0.01)
					dat += "OTHER: [round(unknown_level)]%<br>"
			dat += "Temperature: [round(environment.temperature-T0C)]&deg;C<br>"
	return dat

/datum/pda_app/light
	name = "Flashlight"
	desc = "Turns on the PDA flashlight."
	category = "Utilities"
	price = 0
	has_screen = FALSE
	icon = "pda_flashlight"
	var/fon = 0 //Is the flashlight function on?
	var/f_lum = 2 //Luminosity for the flashlight function

/datum/pda_app/light/onInstall()
	..()
	name = "[fon ? "Disable" : "Enable"] Flashlight"
	f_lum = pda_device && (locate(/datum/pda_app/light_upgrade) in pda_device.applications) ? 3 : 2

/datum/pda_app/light/onUninstall()
	fon = 0
	if(pda_device)
		pda_device.set_light(0)
	..()

/datum/pda_app/light/on_select(var/mob/user)
	if(pda_device)
		if(fon)
			fon = 0
			pda_device.set_light(0)
		else
			fon = 1
			pda_device.set_light(f_lum)
	name = "[fon ? "Disable" : "Enable"] Flashlight"
