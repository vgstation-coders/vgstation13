//---- The following corporations are friendly with Nanotrasen and loosely enable trade and travel:
//Corporation Nanotrasen - Generalised / high tech research and plasma exploitation.
//Corporation Vessel Contracting - Ship and station construction, materials research.
//Corporation Osiris Atmospherics - Atmospherics machinery construction and chemical research.
//Corporation Second Red Cross Society - 26th century Red Cross reborn as a dominating economic force in biomedical science (research and materials).
//Corporation Blue Industries - High tech and high energy research, in particular into the mysteries of bluespace manipulation and power generation.
//Corporation Kusanagi Robotics - Founded by robotics legend Kaito Kusanagi in the 2070s, they have been on the forefront of mechanical augmentation and robotics development ever since.
//Corporation Free traders - Not so much a corporation as a loose coalition of spacers, Free Traders are a roving band of smugglers, traders and fringe elements following a rigid (if informal) code of loyalty and honour. Mistrusted by most corporations, they are tolerated because of their uncanny ability to smell out a profit.

//---- Descriptions of destination types
//Space stations can be purpose built for a number of different things, but generally require regular shipments of essential supplies.
//Corvettes are small, fast warships generally assigned to border patrol or chasing down smugglers.
//Battleships are large, heavy cruisers designed for slugging it out with other heavies or razing planets.
//Yachts are fast civilian craft, often used for pleasure or smuggling.
//Destroyers are medium sized vessels, often used for escorting larger ships but able to go toe-to-toe with them if need be.
//Frigates are medium sized vessels, often used for escorting larger ships. They will rapidly find themselves outclassed if forced to face heavy warships head on.

var/global/list/non_update_news_types = list(/datum/feed_message/news/misc/paycuts_confirmation,/datum/feed_message/news/misc/human_experiments,/datum/feed_message/news/misc/more_food_riots)
var/global/list/news_types = list()

var/setup_news = 0
/proc/setup_news()
	if(setup_news)
		return
	news_network.network_channels += new /datum/feed_channel/preset/tauceti
	news_network.network_channels += new /datum/feed_channel/preset/gibsongazette

	for(var/loc_type in subtypesof(/datum/trade_destination))
		var/datum/trade_destination/D = new loc_type
		weighted_randomevent_locations[D] = D.viable_random_events.len
		weighted_mundaneevent_locations[D] = D.viable_mundane_events.len

	news_types = subtypesof(/datum/feed_message/news/misc) - non_update_news_types
	setup_news = 1

var/scheduledNews = null
/proc/checkNews()
	if(!scheduledNews)
		var/delay = rand(eventTimeLower, eventTimeUpper) MINUTES
		scheduledNews = world.timeofday + delay
		message_admins("News cycle refreshed. Next post in [delay/600] minutes.")
	else if(world.timeofday >scheduledNews)
		var/datum/trade_destination/affected_dest = prob(90) || !news_types.len ? pickweight(weighted_mundaneevent_locations) : null
		var/datum/feed_message/news/newspost
		var/type
		if(affected_dest?.viable_mundane_events.len)
			type = pick(affected_dest.viable_mundane_events)
			newspost = new type(affected_dest)
			if(newspost.affected_dest.get_custom_eventstring(type))
				newspost.body = newspost.affected_dest.get_custom_eventstring(type)
		else
			type = pick(news_types)
			newspost = new type()
			news_types -= newspost
		announce_newscaster_news(newspost)
		scheduledNews = null
		checkNews()

/proc/announce_newscaster_news(datum/feed_message/news/news)

	if(news.affected_dest?.get_custom_eventstring(news.type))
		news.body = news.affected_dest.get_custom_eventstring(news.type)

	var/datum/feed_channel/sendto
	for(var/datum/feed_channel/FC in news_network.network_channels)
		if(FC.channel_name == news.channel_name)
			sendto = FC
			break

	if(!sendto)
		sendto = new /datum/feed_channel
		sendto.channel_name = news.channel_name
		sendto.author = news.author
		sendto.locked = 1
		sendto.is_admin_channel = 1
		news_network.network_channels += sendto

	sendto.messages += news

	for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
		NEWSCASTER.newsAlert(news.channel_name,news.headline)

	if(news.update_type)
		spawn(rand(news.update_delay_min,news.update_delay_max))
			announce_newscaster_news(new news.update_type)
