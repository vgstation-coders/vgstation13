/obj/machinery/telecomms/receiver/preset_left/ministation
	name = "Receiver"

/obj/machinery/telecomms/receiver/preset_left/ministation/initialize()
	..()
	freq_listening = list()

/obj/machinery/telecomms/bus/preset_one/ministation
	name = "Bus"
	autolinkers = list("processor1", "common")

/obj/machinery/telecomms/bus/preset_one/ministation/initialize()
	..()
	freq_listening = list()

/obj/machinery/telecomms/processor/preset_one/ministation
	name = "Processor"

/obj/machinery/telecomms/processor/preset_one/ministation/initialize()
	..()
	freq_listening = list()

/obj/machinery/telecomms/server/presets/common/ministation/initialize()
	..()
	freq_listening = list()

/obj/machinery/telecomms/broadcaster/preset_left/ministation
	name = "Broadcaster"

/obj/machinery/telecomms/broadcaster/preset_left/ministation/initialize()
	..()
	freq_listening = list()