/datum/job/trader
	title = "Trader"
	flag = TRADER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "nobody"
	selection_color = "#dddddd"
	access = list(access_trade)
	minimal_access = list(access_trade)
	alt_titles = list("Merchant","Salvage Broker")

	species_whitelist = list("Vox", "Mushroom")
	species_blacklist = list() //for shrooms
	must_be_map_enabled = 1

	no_random_roll = 1 //Don't become a vox trader randomly
	no_crew_manifest = 1

	//Don't spawn with any of the average crew member's luxuries (only an ID)
	no_starting_money = 1

	spawns_from_edge = 1

	outfit_datum = /datum/outfit/trader

	//Both Restricted: Revolution, Revsquad
	//Merchant Restricted: Double Agent, Vampire, Cult

/datum/job/trader/introduce(mob/living/carbon/human/M, job_title)
	if(!job_title)
		job_title = src.title

	if(!trader_account)
		trader_account = create_trader_account
	M.mind.store_memory("<b>The joint trader account is:</b> #[trader_account.account_number]<br><b>Your shared account pin is:</b> [trader_account.remote_access_pin]<br>")

	log_admin("([M.ckey]/[M]) started the game as a [job_title].")

	to_chat(M, "<B>You are a [job_title].</B>")

	to_chat(M, "<b>You should do your best to sell what you can to fund new product sales. Ultimately, the mark of a good trader is profit -- but public relations are an important component of that end goal.</b>")

	if(M.mind.role_alt_title == "Merchant")
		to_chat(M, "<B><span class='info'>Your merchant's license paperwork has just cleared with Nanotrasen HQ. You have a loyalty implant and the staff has been notified that you are active in this sector.</span></B>")
		SendMerchantFax(M)

	to_chat(M, "<b>Despite not being a member of the crew, by default you are <u>not</u> an antagonist. Cooperating with antagonists is allowed - within reason. Ask admins via adminhelp if you're not sure.</b>")

	if(req_admin_notify)
		to_chat(M, "<b>You are playing a job that is important for Game Progression. If you have to disconnect, please notify the admins via adminhelp.</b>")
