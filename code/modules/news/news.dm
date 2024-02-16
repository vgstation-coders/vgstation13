
#define RIOTS "/datum/feed_message/news/event/riots"
#define WILD_ANIMAL_ATTACK "/datum/feed_message/news/event/animal_attack"
#define INDUSTRIAL_ACCIDENT "/datum/feed_message/news/event/accident"
#define BIOHAZARD_OUTBREAK "/datum/feed_message/news/event/biohazard"
#define PIRATES "/datum/feed_message/news/event/pirates"
#define CORPORATE_ATTACK "/datum/feed_message/news/event/corporate"
#define ALIEN_RAIDERS "/datum/feed_message/news/event/alien_raiders"
#define AI_LIBERATION "/datum/feed_message/news/event/ai_liberation"
#define MOURNING "/datum/feed_message/news/event/mourning"
#define CULT_CELL_REVEALED "/datum/feed_message/news/event/cult_cell"
#define SECURITY_BREACH "/datum/feed_message/news/event/breach"
#define ANIMAL_RIGHTS_RAID "/datum/feed_message/news/event/animal_rights"
#define FESTIVAL "/datum/feed_message/news/event/festival"

#define RESEARCH_BREAKTHROUGH "/datum/feed_message/news/mundane/research"
#define BARGAINS "/datum/feed_message/news/mundane/bargains"
#define SONG_DEBUT "/datum/feed_message/news/mundane/song"
#define MOVIE_RELEASE "/datum/feed_message/news/mundane/movie"
#define BIG_GAME_HUNTERS "/datum/feed_message/news/mundane/hunt"
#define ELECTION "/datum/feed_message/news/mundane/election"
#define GOSSIP "/datum/feed_message/news/mundane/gossip"
#define TOURISM "/datum/feed_message/news/mundane/tourism"
#define CELEBRITY_DEATH "/datum/feed_message/news/mundane/celeb_death"
#define RESIGNATION "/datum/feed_message/news/mundane/resignation"

#define DEFAULT 1

#define ADMINISTRATIVE 2
#define CLOTHING 3
#define SECURITY 4
#define SPECIAL_SECURITY 5

#define FOOD 6
#define ANIMALS 7

#define MINERALS 8

#define EMERGENCY 9
#define GAS 10
#define MAINTENANCE 11
#define ELECTRICAL 12
#define ROBOTICS 13
#define BIOMEDICAL 14

#define GEAR_EVA 15

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

var/setup_news = 0
/proc/setup_news()
	if(setup_news)
		return
	var/datum/feed_channel/newChannel = new /datum/feed_channel
	newChannel.channel_name = "Tau Ceti Daily"
	newChannel.author = "CentComm Minister of Information"
	newChannel.locked = 1
	newChannel.is_admin_channel = 1
	news_network.network_channels += newChannel

	newChannel = new /datum/feed_channel
	newChannel.channel_name = "The Gibson Gazette"
	newChannel.author = "Editor Mike Hammers"
	newChannel.locked = 1
	newChannel.is_admin_channel = 1
	news_network.network_channels += newChannel

	for(var/loc_type in typesof(/datum/trade_destination) - /datum/trade_destination)
		var/datum/trade_destination/D = new loc_type
		weighted_randomevent_locations[D] = D.viable_random_events.len
		weighted_mundaneevent_locations[D] = D.viable_mundane_events.len

	news_types = subtypesof(/datum/feed_message/news/misc) - non_event_news_types
	setup_news = 1

	//news_cycle()

var/global/list/non_update_news_types = list(/datum/feed_message/news/misc/food_riots/more)
var/global/list/news_types = list()

/proc/news_cycle()
	while(true)
		sleep(rand(eventTimeLower, eventTimeUpper) MINUTES)
		var/datum/trade_destination/affected_dest = prob(90) || !news_types.len ? pickweight(weighted_mundaneevent_locations) : null
		var/datum/feed_message/news/newspost
		var/type
		if(affected_dest?.viable_mundane_events.len)
			type = pick(affected_dest.viable_mundane_events)
			newspost = new type(affected_dest)
			if(newspost.affected_dest.get_custom_eventstring(type))
				newspost.body = news.affected_dest.get_custom_eventstring(type)
		else
			type = pick(news_types)
			newspost = new type()
			news_types -= newspost
		announce_newscaster_news(newspost)

/proc/announce_newscaster_news(datum/feed_message/news/news)

	if(news.affected_dest?.get_custom_eventstring(type))
		news.body = news.affected_dest.get_custom_eventstring(type)

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
		NEWSCASTER.newsAlert(news.channel_name)

	if(news.update_type)
		spawn(rand(update_delay_min,update_delay_max))
			announce_newscaster_news(new news.update_type)
