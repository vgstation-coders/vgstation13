#define LATEJOIN_TIME_CUTOFF (10 MINUTES)
#define TRADE_GREET_FREQ (30 SECONDS)

var/static/list/tw_face_not_visible = list("I don't talk to anyone whose face I can't see.", "Hey, mask off!", "Let me look you in the eyes before we do business.")

var/static/list/tw_sale_generic = list("Very nice, here you go.", "Enjoy, sell it quickly.", "No refunds, no returns.")
var/static/list/tw_sale_good_deal = list("Good time to buy.", "The market favors this one.", "The timing was right.", "Investing while it's cheap -- good!")
var/static/list/tw_sale_expensive = list("Was it hard to part with so much?", "This is expensive, so earn it back quickly.", "You better get your money's worth.")

var/static/list/tw_market_flux = list("Market flux!", "Market forces shifting...", "Just got an update on prices!", "Turn on VNN, new prices!", "Just got an update on prices!", "Hey, hey, price update!", "Get over here, new prices!")

var/static/list/tw_advertise_generic = list("Get over here, take a look at this stuff.", "You seen the new market prices?", "Still a lot of products left.")
var/static/list/tw_advertise_low_price = list("Good deal on PRODUCT. Have a look.", "Market favors PRODUCT right now.", "Think you could sell PRODUCT? Good time to buy.")

var/static/list/tw_low_sales = list("You're just getting started, after all.", "You better earn your keep.", "Let's see if you're worth investing in, eh?")
var/static/list/tw_medium_sales = list("Making good progress. Keep it up.", "Your sales are growing, good.", "Hey, I appreciate the business, again.", "I love a repeat customer, keh!")
var/static/list/tw_high_sales = list("You've come some way, haven't you?", "My favorite customer, eh?", "How fast can you move this one, super-seller?")

var/static/list/tw_empty_shoal = list("Eh, Shoal's bankrupt, though.", "You lot haven't done anything for the Shoal yet.", "Don't forget to contribute to the Shoal.")
var/static/list/tw_low_shoal = list("Your crew is making some progress with the Shoal, pool more.", "I've seen some Shoal contributions here - not enough.", "Remember, 10% of your earnings go into the Shoal. No, 20%!")
var/static/list/tw_satisfied_shoal = list("You've done well here, a good trade outpost.", "Your earnings are a mark of pride.", "The Shoal is healthy thanks to your crew, but no time to stop.")
var/static/list/tw_high_shoal = list("The Shoal is swollen with earnings.","This crew's wealth is legendary.","No one can doubt what profits have been made here.")

var/static/list/tw_greet_initial = list("USER, eh? ", "I've got it here somewhere - oh, USER, right? ", "That face... you're USER? ")
var/static/list/tw_greet_latejoin = list("Took your sweet time, hmm? ", "Well, you're not exactly here for the shift start. ", "How was the flight in? ")
var/static/list/tw_greet_precursors = list("Well, at least you can count on ", "Keep your eyes open for ", "There's also ")
var/static/list/tw_greet_captain = list("Keh, early bird gets the worm! ", "Here first, looking to take charge? ", "You're fast, eh? Don't leave behind the others. ")
var/static/list/tw_greet_follower = list("Not as fast as CAPTAIN, but you're here, that's what counts. ", "Stick with CAPTAIN, okay? ", "Good to have you on too. Make much coin. ", "Mhm, you've got spirit. Not going to be beat by CAPTAIN, huh? ", "I see potential in you, too. ", "Tall for a trader, eh? You warrior stock? ")
var/static/list/tw_greet_solo = list("Just you and me out here, yeah? ", "Shoal has sent us two ahead to prospect. ", "No one to watch your back, stay safe, eh? ", "Just us? Maybe they send someone else, later, eh? ")

var/static/list/tw_greet_short_wait = list("Still browsing? ", "Come over here, USER, let's have a little chat. ", "Hey, my favorite trader! Not left yet? ", "Taking off soon? Gotta earn somehow. ", "Hey, USER, don't get left behind, okay? ")
var/static/list/tw_greet_medium_wait = list("How was it over there? Good sales?", "Welcome back, USER.", "Hey USER! Stocking up?", "Come back for more, USER?", "USER's back again, I bet I know what for...", "There you are, USER!")
var/static/list/tw_greet_long_wait = list("Still alive? That's great. ","Still in one piece, USER? ", "You made it back, eh? Good! ","Been awhile, USER, I was getting worried! ", "There he is! And still hearty. ", "USER! My friend! ")

var/static/list/tw_advice = list("Remember, buy low, sell high.", "Hey, there's rewards for success. Bank some credits.", "Don't lose the Shoal card. Important.", "Don't cause trouble for other traders.", "If you can't trust other traders, who can you trust?",
		"If you got a stethoscope, you could crack that old safe, yeah?", "You tried a gimmick? Humans love gimmicks.", "Try taking them some home-cooked Vox food.", "Target the ones with money... miners, department heads.", "Hey, remind them they can print money from PDA.",
		"Sometimes freebies lure customers to the ship. Something small, like a gacha toy or free drink.", "Remember, trust is currency. Become rich in trust.", "Remember, slave trading is almost always a bad idea. Leave that to raiders.", "Treat this place like your home, but never forget that it is not.",
		"Consider getting a PDA. Remote control of ship can help.", "Don't leave stock unattended.", "Humans don't like having to walk to ship. Try PDA marketing and deliveries.", "Targeted advertising works, try it.")

/obj/structure/trade_window/proc/greet(mob/living/carbon/human/user)
	var/buildgreet
	var/username = user.get_face_name()
	if(!(username in last_greeted)) //First time greeting
		buildgreet += pick(tw_greet_initial)
		if(world.time > LATEJOIN_TIME_CUTOFF) //Greet a latejoiner
			buildgreet += pick(tw_greet_latejoin)
			var/position = SStrade.loyal_customers.Find(username)
			if(position > 1)
				buildgreet +=  pick(tw_greet_precursors) + english_list(last_greeted) + "."
			else
				buildgreet += "You're starting from scratch out there. Good luck. Feh."
		else //Greet an roundstart/early arrival
			if(SStrade.loyal_customers.len > 1) //Greet one from a group
				if(last_greeted.len == 0) //Greet the first player who isn't the only trader
					buildgreet += pick(tw_greet_captain)
				else //Greet someone who didn't get to the window first
					buildgreet += replacetext(pick(tw_greet_follower),"CAPTAIN",last_greeted[1])
			else //Greet a solo trader
				buildgreet += pick(tw_greet_solo)

	else
		message_admins("Debug: Last talked [last_greeted[username]], current [world.time], and gap is [TRADE_GREET_FREQ].")
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
				buildgreet = trim(buildgreet)
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
				buildgreet += pick(tw_advice)
			if(17 to 20) //advertise
				var/target_product
				for(var/datum/trade_product/TP in SStrade.all_trade_merch)
					if(TP.flux_rate <= 0.85)
						target_product = TP.name
						break
				if(target_product)
					buildgreet += replacetext(pick(tw_advertise_low_price),"PRODUCT",target_product)
				else
					buildgreet += pick(tw_advertise_generic)

	last_greeted[username] = world.time
	buildgreet = replacetext(buildgreet, "USER", username)
	say(buildgreet)