/mob/living/silicon/robot/Login()
	..()
	regenerate_icons()
	show_laws(0)
	if(module)
		module.UpdateModuleHolder(src)
	if (mind && !stored_freqs)
		spawn(1)
			mind.store_memory("Frequencies list: <br/><b>Command:</b> [COMM_FREQ] <br/> <b>Security:</b> [SEC_FREQ] <br/> <b>Medical:</b> [MED_FREQ] <br/> <b>Science:</b> [SCI_FREQ] <br/> <b>Engineering:</b> [ENG_FREQ] <br/> <b>Service:</b> [SER_FREQ] <b>Cargo:</b> [SUP_FREQ]<br/> <b>AI private:</b> [AIPRIV_FREQ]<br/>")
		stored_freqs = 1
	/*if(mind)
		ticker.mode.remove_revolutionary(mind)
	*/
