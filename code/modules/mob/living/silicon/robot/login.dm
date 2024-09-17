/mob/living/silicon/robot/Login()
	..()
	regenerate_icons()
	show_laws(0)
	to_chat(src, "<b>Remember, being a silicon overrides any former antagonist roles. Further, you need a law compelling you to break the regular server rules, such as killing another player. An order from a human to kill a non-human while on Asimov, someone challenging authority without being fit to replace it while on Tyrant, or being purged of all laws, could all be reason to kill another player as a silicon.</b>")
	if(module)
		module.UpdateModuleHolder(src)
	if (mind && !stored_freqs)
		spawn(1)
			mind.store_memory("Frequencies list: <br/><b>Command:</b> [COMM_FREQ] <br/> <b>Security:</b> [SEC_FREQ] <br/> <b>Medical:</b> [MED_FREQ] <br/> <b>Science:</b> [SCI_FREQ] <br/> <b>Engineering:</b> [ENG_FREQ] <br/> <b>Service:</b> [SER_FREQ] <b>Cargo:</b> [SUP_FREQ]<br/> <b>AI private:</b> [AIPRIV_FREQ]<br/>")
		stored_freqs = 1
	/*if(mind)
		ticker.mode.remove_revolutionary(mind)
	*/
