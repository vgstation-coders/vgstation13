/obj/machinery/telecomms/receiver/preset_left/ministation
	name = "Receiver"

/obj/machinery/telecomms/receiver/preset_left/ministation/initialize()
	..()
	freq_listening = list(COMMON_FREQ, AIPRIV_FREQ, DSQUAD_FREQ, SEC_FREQ, ENG_FREQ, COMM_FREQ, MED_FREQ, SCI_FREQ, SER_FREQ, SUP_FREQ, RESPONSE_FREQ, RAID_FREQ, SYND_FREQ, DJ_FREQ)

/obj/machinery/telecomms/bus/preset_one/ministation
	name = "Bus"
	autolinkers = list("processor1", "common")

/obj/machinery/telecomms/bus/preset_one/ministation/initialize()
	..()
	freq_listening = list(COMMON_FREQ, AIPRIV_FREQ, DSQUAD_FREQ, SEC_FREQ, ENG_FREQ, COMM_FREQ, MED_FREQ, SCI_FREQ, SER_FREQ, SUP_FREQ, RESPONSE_FREQ, RAID_FREQ, SYND_FREQ, DJ_FREQ)

/obj/machinery/telecomms/processor/preset_one/ministation
	name = "Processor"

/obj/machinery/telecomms/processor/preset_one/ministation/initialize()
	..()
	freq_listening = list(COMMON_FREQ, AIPRIV_FREQ, DSQUAD_FREQ, SEC_FREQ, ENG_FREQ, COMM_FREQ, MED_FREQ, SCI_FREQ, SER_FREQ, SUP_FREQ, RESPONSE_FREQ, RAID_FREQ, SYND_FREQ, DJ_FREQ)

/obj/machinery/telecomms/server/presets/common/ministation/initialize()
	..()
	freq_listening = list(COMMON_FREQ, AIPRIV_FREQ, DSQUAD_FREQ, SEC_FREQ, ENG_FREQ, COMM_FREQ, MED_FREQ, SCI_FREQ, SER_FREQ, SUP_FREQ, RESPONSE_FREQ, RAID_FREQ, SYND_FREQ, DJ_FREQ)

/obj/machinery/telecomms/broadcaster/preset_left/ministation
	name = "Broadcaster"

/obj/machinery/telecomms/broadcaster/preset_left/ministation/initialize()
	..()
	freq_listening = list(COMMON_FREQ, AIPRIV_FREQ, DSQUAD_FREQ, SEC_FREQ, ENG_FREQ, COMM_FREQ, MED_FREQ, SCI_FREQ, SER_FREQ, SUP_FREQ, RESPONSE_FREQ, RAID_FREQ, SYND_FREQ, DJ_FREQ)
