// ### Preset machines  ###

//Relay

/obj/machinery/telecomms/relay/preset
	network = "tcommsat"

/obj/machinery/telecomms/relay/preset/station
	id = "Station Relay"
	listening_level = 1
	autolinkers = list("s_relay")

/obj/machinery/telecomms/relay/preset/telecomms
	id = "Telecomms Relay"
	autolinkers = list("relay")

/obj/machinery/telecomms/relay/preset/mining
	id = "Mining Relay"
	autolinkers = list("m_relay")

/obj/machinery/telecomms/relay/preset/ruskie
	id = "Ruskie Relay"
	hide = 1
	toggled = 0
	autolinkers = list("r_relay")

/obj/machinery/telecomms/relay/preset/centcom
	id = "Centcom Relay"
	hide = 1
	toggled = 1
	//anchored = 1
	//use_power = 0
	//idle_power_usage = 0
	heating_power = 0
	autolinkers = list("c_relay")

//HUB

/obj/machinery/telecomms/hub/preset
	id = "Hub"
	network = "tcommsat"
	autolinkers = list("hub", "relay", "c_relay", "s_relay", "m_relay", "r_relay", "science", "medical",
	"supply", "service", "common", "command", "engineering", "security",
	"receiverA", "receiverB", "broadcasterA", "broadcasterB")

//Receivers

//--PRESET LEFT--//

/obj/machinery/telecomms/receiver/preset_left
	id = "Receiver A"
	network = "tcommsat"
	autolinkers = list("receiverA") // link to relay

/obj/machinery/telecomms/receiver/preset_left/initialize()
	..()
	freq_listening = list(SCI_FREQ, MED_FREQ, SUP_FREQ, SER_FREQ) // science, medical, supply, service


//--PRESET RIGHT--//

/obj/machinery/telecomms/receiver/preset_right
	id = "Receiver B"
	network = "tcommsat"
	autolinkers = list("receiverB") // link to relay

/obj/machinery/telecomms/receiver/preset_right/initialize()
	..()
	freq_listening = list(RESPONSE_FREQ, COMM_FREQ, ENG_FREQ, SEC_FREQ, COMMON_FREQ) //ert, command, engineering, security
	for(var/i = 1441, i < 1489, i += 2)
		freq_listening |= i

/obj/machinery/telecomms/receiver/preset_complete
	name = "Receiver"
	freq_listening = list()

//Buses

/obj/machinery/telecomms/bus/preset_one
	id = "Bus 1"
	network = "tcommsat"
	autolinkers = list("processor1", "science", "medical")

/obj/machinery/telecomms/bus/preset_one/initialize()
	..()
	freq_listening = list(SCI_FREQ, MED_FREQ)

/obj/machinery/telecomms/bus/preset_two
	id = "Bus 2"
	network = "tcommsat"
	autolinkers = list("processor2", "supply", "service")

/obj/machinery/telecomms/bus/preset_two/initialize()
	..()
	freq_listening = list(SUP_FREQ, SER_FREQ)

/obj/machinery/telecomms/bus/preset_three
	id = "Bus 3"
	network = "tcommsat"
	autolinkers = list("processor3", "security", "command")

/obj/machinery/telecomms/bus/preset_three/initialize()
	..()
	freq_listening = list(SEC_FREQ, COMM_FREQ)

/obj/machinery/telecomms/bus/preset_four
	id = "Bus 4"
	network = "tcommsat"
	autolinkers = list("processor4", "engineering", "common")

/obj/machinery/telecomms/bus/preset_four/initialize()
	..()
	freq_listening = list(ENG_FREQ, COMMON_FREQ)
	for(var/i = 1441, i < 1489, i += 2)
		freq_listening |= i

/obj/machinery/telecomms/bus/preset_complete
	id = "Bus Complete"
	network = "tcommsat"
	freq_listening = list()
	autolinkers = list("processor1", "common")

//Processors

/obj/machinery/telecomms/processor/preset_one
	id = "Processor 1"
	network = "tcommsat"
	autolinkers = list("processor1") // processors are sort of isolated; they don't need backward links

/obj/machinery/telecomms/processor/preset_two
	id = "Processor 2"
	network = "tcommsat"
	autolinkers = list("processor2")

/obj/machinery/telecomms/processor/preset_three
	id = "Processor 3"
	network = "tcommsat"
	autolinkers = list("processor3")

/obj/machinery/telecomms/processor/preset_four
	id = "Processor 4"
	network = "tcommsat"
	autolinkers = list("processor4")


/obj/machinery/telecomms/processor/preset_complete
	name = "Processor"

//Servers

/obj/machinery/telecomms/server/presets
	network = "tcommsat"

/obj/machinery/telecomms/server/presets/New()
	..()
	name = id


/obj/machinery/telecomms/server/presets/science
	id = "Science Server"
	autolinkers = list("science")

/obj/machinery/telecomms/server/presets/science/initialize()
	..()
	freq_listening = list(SCI_FREQ)

/obj/machinery/telecomms/server/presets/medical
	id = "Medical Server"
	autolinkers = list("medical")

/obj/machinery/telecomms/server/presets/medical/initialize()
	..()
	freq_listening = list(MED_FREQ)

/obj/machinery/telecomms/server/presets/supply
	id = "Supply Server"
	autolinkers = list("supply")

/obj/machinery/telecomms/server/presets/supply/initialize()
	..()
	freq_listening = list(SUP_FREQ)

//Using old mining channel frequency for a service channel for the bartender, botanist and chef.
//Also cleaned up all the references to the mining channel I could find, it most likely will never be used again anyway. - Duny
/obj/machinery/telecomms/server/presets/service
	id = "Service Server"
	autolinkers = list("service")

/obj/machinery/telecomms/server/presets/service/initialize()
	..()
	freq_listening = list(SER_FREQ)

/obj/machinery/telecomms/server/presets/common
	id = "Common Server"
	autolinkers = list("common")

/obj/machinery/telecomms/server/presets/common/initialize()
	..()
	freq_listening = list(COMMON_FREQ)
	//Common and other radio frequencies for people to freely use
	// 1441 to 1489
/obj/machinery/telecomms/server/presets/common/New()
	for(var/i = 1441, i < 1489, i += 2)
		if(radiochannelsreverse.Find("[i]"))
			continue
		freq_listening |= i
	..()

/obj/machinery/telecomms/server/presets/complete
	id = "Master Server"
	freq_listening = list()

/obj/machinery/telecomms/server/presets/command
	id = "Command Server"
	autolinkers = list("command")

/obj/machinery/telecomms/server/presets/command/initialize()
	..()
	freq_listening = list(COMM_FREQ)

/obj/machinery/telecomms/server/presets/engineering
	id = "Engineering Server"
	autolinkers = list("engineering")

/obj/machinery/telecomms/server/presets/engineering/initialize()
	..()
	freq_listening = list(ENG_FREQ)

/obj/machinery/telecomms/server/presets/security
	id = "Security Server"
	autolinkers = list("security")

/obj/machinery/telecomms/server/presets/security/initialize()
	..()
	freq_listening = list(SEC_FREQ)

//Broadcasters

//--PRESET LEFT--//

/obj/machinery/telecomms/broadcaster/preset_left
	id = "Broadcaster A"
	network = "tcommsat"
	autolinkers = list("broadcasterA")

//--PRESET RIGHT--//

/obj/machinery/telecomms/broadcaster/preset_right
	id = "Broadcaster B"
	network = "tcommsat"
	autolinkers = list("broadcasterB")

/obj/machinery/telecomms/broadcaster/preset_complete
	name = "Broadcaster"
	network = "tcommsat"
