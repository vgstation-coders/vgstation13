
/datum/event/mundane_news
	announceWhen = 1
	endWhen = 10

/datum/event/mundane_news/announce()
	var/datum/trade_destination/affected_dest = pickweight(weighted_mundaneevent_locations)
	var/datum/feed_message/news/mundane/event_type
	if(affected_dest.viable_mundane_events.len)
		var/inittype = pick(affected_dest.viable_mundane_events)
		event_type = new inittype(affected_dest)

		if(!istype(event_type))
			return

		//see if our location has custom event info for this event
		if(affected_dest.get_custom_eventstring(inittype))
			event_type.body = affected_dest.get_custom_eventstring(inittype)

		for(var/datum/feed_channel/FC in news_network.network_channels)
			if(FC.channel_name == "Tau Ceti Daily")
				FC.messages += event_type
				break
		for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
			NEWSCASTER.newsAlert("Tau Ceti Daily")

