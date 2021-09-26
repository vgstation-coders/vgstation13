#define LATEJOIN_TIME_CUTOFF (10 MINUTES)
#define TRADE_GREET_FREQ (30 SECONDS)

var/static/list/tw_face_not_visible = list("I don't talk to anyone whose face I can't see.", "Hey, mask off!", "Let me look you in the eyes before we do business.")
var/static/list/tw_not_enough_cash = list("Put some more cash up.","More creds.","Keh, don't short me.", "This isn't enough.","This isn't a charity.", "Cash on the table.")

var/static/list/tw_sale_generic = list("Very nice, here you go.", "Enjoy, sell it quickly.", "No refunds, no returns.")
var/static/list/tw_sale_good_deal = list("Good time to buy.", "The market favors this one.", "The timing was right.", "Investing while it's cheap -- good!")
var/static/list/tw_sale_expensive = list("Was it hard to part with so much?", "This is expensive, so earn it back quickly.", "You better get your money's worth.")
var/static/list/tw_adminbus_freeitem = list("Keh, freebie. Someone likes you.", "Word from top, something free.", "Eh, for you, take it.", "This one, free.")

var/static/list/tw_market_flux = list("Market flux!", "Market forces shifting...", "Just got an update on prices!", "Turn on VNN, new prices!", "Just got an update on prices!", "Hey, hey, price update!", "Get over here, new prices!")

var/static/list/tw_advertise_generic = list("Get over here, take a look at this stuff.", "You seen the new market prices?", "Still a lot of products left.")
var/static/list/tw_advertise_low_price = list("Good deal on TWPRODUCT. Have a look.", "Market favors TWPRODUCT right now.", "Think you could sell TWPRODUCT? Good time to buy.", "TWRATE OFF? On TWPRODUCT?! You can't pass this up!", "TWRATE off deal on TWPRODUCT!", "Deals as low as TWRATE off!")

var/static/list/tw_low_sales = list("You're just getting started, after all.", "You better earn your keep.", "Let's see if you're worth investing in, eh?")
var/static/list/tw_medium_sales = list("Making good progress. Keep it up.", "Your sales are growing, good.", "Hey, I appreciate the business, again.", "I love a repeat customer, keh!")
var/static/list/tw_high_sales = list("You've come some way, haven't you?", "My favorite customer, eh?", "How fast can you move this one, super-seller?")

var/static/list/tw_empty_shoal = list("Eh, Shoal's bankrupt, though. You'll put some cash in, eh?", "You lot haven't done anything for the Shoal yet. Don't you know about the trader account?", "Don't forget to contribute to the Shoal.")
var/static/list/tw_low_shoal = list("Your crew is making some progress with the Shoal, pool more.", "I've seen some Shoal contributions here - not enough.", "Remember, 10% of your earnings go into the Shoal. No, 20%!")
var/static/list/tw_satisfied_shoal = list("You've done well here, a good trade outpost.", "Your earnings are a mark of pride.", "The Shoal is healthy thanks to your crew, but no time to stop.")
var/static/list/tw_high_shoal = list("The Shoal is swollen with earnings.","This crew's wealth is legendary.","No one can doubt what profits have been made here.")

var/static/list/tw_greet_initial = list("TWUSER, eh? ", "I've got it here somewhere - oh, TWUSER, right? ", "That face... you're TWUSER? ")
var/static/list/tw_greet_latejoin = list("Took your sweet time, hmm? ", "Well, you're not exactly here for the shift start. ", "How was the flight in? ")
var/static/list/tw_greet_precursors = list("Well, at least you can count on ", "Keep your eyes open for ", "There's also ")
var/static/list/tw_greet_captain = list("Keh, early bird gets the worm! ", "Here first, looking to take charge? ", "You're fast, eh? Don't leave behind the others. ")
var/static/list/tw_greet_follower = list("Not as fast as TWCAPTAIN, but you're here, that's what counts. ", "Stick with TWCAPTAIN, okay? ", "Good to have you on too. Make much coin. ", "Mhm, you've got spirit. Not going to be beat by TWCAPTAIN, huh? ", "I see potential in you, too. ", "Tall for a trader, eh? You warrior stock? ")
var/static/list/tw_greet_solo = list("Just you and me out here, yeah? ", "Shoal has sent us two ahead to prospect. ", "No one to watch your back, stay safe, eh? ", "Just us? Maybe they send someone else, later, eh? ")
var/static/list/tw_merchant = list("Oh, before I forget - this is for you. ", "Your licence was sent in today. ", "This is for you - hey, you look just like your picture. ", "Your paperwork got here first. ", "I suppose you'll be wanting this licence, too. ", "Hey, don't run off without your papers, yeah? ")

var/static/list/tw_greet_short_wait = list("Still browsing? ", "Come over here, TWUSER, let's have a little chat. ", "Hey, my favorite trader! Not left yet? ", "Taking off soon? Gotta earn somehow. ", "Hey, TWUSER, don't get left behind, okay? ","Go with your gut, don't worry too much about the exact right product. You'll sell it. ", "Hey, I know you're leaving soon - don't forget to check in once in a while, okay? ", "Fifty three plus twenty... Eh? Yeah, I'm still listening! ", "Do do do do do. Chik-chika, chik-chika. ", "Yeah, yeah, catalog's still here. ", "Hm? Something else? ", "What, another? ", "Is there something more? ", "Keh, greedy for products. ", "That one? ", "TWUSER, TWUSER... ", "I'd say the list isn't going to change if you keep staring at it, but it's not quite true. ")
var/static/list/tw_greet_medium_wait = list("How was it over there? Good sales?", "Welcome back, TWUSER.", "Hey TWUSER! Stocking up?", "Come back for more, TWUSER?", "TWUSER's back again, I bet I know what for...", "There you are, TWUSER!")
var/static/list/tw_greet_long_wait = list("Still alive? That's great. Been way too long since I've seen you. Was it busy on station, or did you go for some deep space salvage? ","Still in one piece, TWUSER? To be honest, I was getting worried I wouldn't see you again. This is a partnership you know, you can check in once in a while! ", "You made it back, eh? Good! That was quite a trip - been away from the outpost too long. ","Been awhile, TWUSER, I was getting worried! Ranging out a bit isn't bad, but I do want to know that you're checking in regularly. It's a hostile place out there, for our like. ", "There he is! And still hearty. Feels like it has been a long time, hasn't it? Well, let's get down to business, then. ", "TWUSER! My friend! ")

var/static/list/tw_advice_intro = list("Hey, a word of advice: ", "Some advice: ", "I was thinking... ", "My two cents - ", "Here's the thing... ", "Want a tip? ")
var/static/list/tw_advice = list("remember, buy low, sell high.", "hey, there's rewards for success. Bank some credits.", "don't lose the Shoal card. Important.", "don't cause trouble for other traders.", "if you can't trust other traders, who can you trust?",
		"if you got a stethoscope, you could crack that old safe, yeah?", "you tried a gimmick? Humans love gimmicks.", "try taking them some home-cooked Vox food.", "target the ones with money... miners, department heads.", "Hey, remind them they can print money from PDA.",
		"sometimes freebies lure customers to the ship. Something small, like a gacha toy or free drink.", "Remember, trust is currency. Become rich in trust.", "remember, slave trading is almost always a bad idea. Leave that to raiders.", "treat this place like your home, but never forget that it is not.",
		"consider getting a PDA. Remote control of ship can help.", "don't leave stock unattended.", "humans don't like having to walk to ship. Try PDA marketing and deliveries.", "targeted advertising works, try it.", "if you get lonely, try planting mushroom nodes. Sometimes, a friend.")

var/static/list/tw_induct_cantspeak = list("If you don't speak the language, this is going to be tough. ", "These words are lost on you, eh? ","This book has what you need to get started. ")
var/static/list/tw_induct_traditional = list("I dub thee, trader. Here, you get these, too. ", "These are for you. Little gift. ", "Something else - traditional for starting out. ")

/obj/structure/trade_window/proc/greet(mob/living/carbon/human/user)
	var/buildgreet
	var/username = user.get_face_name()
	if(!(username in last_greeted)) //First time greeting
		if(SStrade.loyal_customers[username] == -1) //Special introduction for a recruit
			if(!(trader_language in user.languages))
				buildgreet += pick(tw_induct_cantspeak)
				tablenew(/obj/item/dictionary/vox, TRUE)
				playsound(loc, "pageturn", 50, 1)
			else
				buildgreet += pick(tw_induct_traditional)
				tablenew(/obj/item/weapon/storage/box/donkpockets/random_amount)
				tablenew(/obj/item/weapon/reagent_containers/food/drinks/thermos/full)
				tablenew(/obj/item/weapon/coin/trader)
				tablenew(/obj/item/weapon/storage/wallet)
			SStrade.loyal_customers[username] = 0
		else
			buildgreet += pick(tw_greet_initial)
			if(world.time > LATEJOIN_TIME_CUTOFF) //Greet a latejoiner
				buildgreet += pick(tw_greet_latejoin)
				var/position = SStrade.loyal_customers.Find(username)
				if(position > 1)
					buildgreet +=  pick(tw_greet_precursors) + english_list(last_greeted) + "."
				else
					buildgreet += "You're starting from scratch out there. Good luck. Feh. "
			else //Greet an roundstart/early arrival
				if(SStrade.loyal_customers.len > 1) //Greet one from a group
					if(last_greeted.len == 0) //Greet the first player who isn't the only trader
						buildgreet += pick(tw_greet_captain)
					else //Greet someone who didn't get to the window first
						buildgreet += replacetext(pick(tw_greet_follower),"CAPTAIN",last_greeted[1])
				else //Greet a solo trader
					buildgreet += pick(tw_greet_solo)

			if(user.mind.role_alt_title == "Merchant")
				buildgreet += pick(tw_merchant)
				var/obj/ML = new /obj/item/weapon/paper/merchant(loc,user)
				ML.pixel_x = rand(-5,5) * PIXEL_MULTIPLIER
				ML.pixel_y = -3 * PIXEL_MULTIPLIER
				ML.shake(1,3)
				playsound(loc, "pageturn", 50, 1)

	else
		if(world.time < last_greeted[username] + (TRADE_GREET_FREQ))
			return //greeted recently
		else if(world.time > last_greeted[username] + (TRADE_GREET_FREQ*40)) //20 minutes
			buildgreet += pick(tw_greet_long_wait)
		else if(world.time > last_greeted[username] + (TRADE_GREET_FREQ*10)) //5 minutes
			buildgreet += pick(tw_greet_medium_wait)
		else //30 seconds
			buildgreet += pick(tw_greet_short_wait)
		switch(rand(1,20))
			if(1 to 7) //33% chance to say nothing else.
			if(8 to 10) //Comment on shoal account
				switch(trader_account.money)
					if(0)
						buildgreet += pick(tw_empty_shoal)
					if(1 to 499)
						buildgreet += pick(tw_low_shoal)
					if(500 to 999)
						buildgreet += pick(tw_satisfied_shoal)
					if(1000 to INFINITY)
						buildgreet += pick(tw_high_shoal)
			if(11 to 13) //Comment on sales
				switch(SStrade.loyal_customers[username])
					if(0 to 299)
						buildgreet += pick(tw_low_sales)
					if(300 to 999)
						buildgreet += pick(tw_medium_sales)
					if(1000 to INFINITY)
						buildgreet += pick(tw_high_sales)
			if(14 to 16) //advice
				buildgreet += pick(tw_advice_intro) + pick(tw_advice)
			if(17 to 20) //advertise
				buildgreet += advertisement()

	last_greeted[username] = world.time
	buildgreet = trim(buildgreet)
	buildgreet = replacetext(buildgreet, "TWUSER", username)
	say(buildgreet)

/obj/structure/trade_window/proc/advertisement()
	var/target_product
	var/readable_rate = "0%"
	var/list/shuffledmerch = shuffle(SStrade.all_trade_merch)
	for(var/datum/trade_product/TP in shuffledmerch)
		if(TP.flux_rate <= 0.85)
			target_product = TP.name
			readable_rate = "[100-(100*TP.flux_rate)]%"
			break
	if(target_product)
		return replacetext(replacetext(pick(tw_advertise_low_price),"TWPRODUCT",target_product), "TWRATE",readable_rate)
	else
		return pick(tw_advertise_generic)