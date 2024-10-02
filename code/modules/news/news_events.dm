
/datum/event/news_event
	endWhen = 50			//this will be set randomly, later
	announceWhen = 15
	var/datum/feed_message/news/event/event_type
	var/datum/trade_destination/affected_dest

/datum/event/news_event/start()
	if(!setup_news)
		setup_news()

	affected_dest = pickweight(weighted_randomevent_locations)
	if(affected_dest.viable_random_events.len)
		endWhen = rand(60,300)
		var/inittype = pick(affected_dest.viable_random_events)
		event_type = new inittype(affected_dest)

		/*if(!istype(event_type))
			return

		for(var/good_type in event_type.dearer_goods)
			affected_dest.temp_price_change[good_type] = rand(1,100)
		for(var/good_type in event_type.cheaper_goods)
			affected_dest.temp_price_change[good_type] = rand(1,100) / 100*/

		//see if our location has custom event info for this event
		if(affected_dest.get_custom_eventstring(inittype))
			event_type.body = affected_dest.get_custom_eventstring(inittype)

/datum/event/news_event/announce()
	for(var/datum/feed_channel/FC in news_network.network_channels)
		if(FC.channel_name == "Tau Ceti Daily")
			FC.messages += event_type
			break
	for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
		NEWSCASTER.newsAlert("Tau Ceti Daily")

/*
/datum/event/news_event/end()
	for(var/good_type in event_type.dearer_goods)
		affected_dest.temp_price_change[good_type] = 1
	for(var/good_type in event_type.cheaper_goods)
		affected_dest.temp_price_change[good_type] = 1
*/
