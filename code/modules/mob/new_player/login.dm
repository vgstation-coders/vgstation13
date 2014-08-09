/mob/new_player/Login()
	update_Login_details()	//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
	if(join_motd)
		src << "<div class=\"motd\">[join_motd]</div>"

	if(!mind)
		mind = new /datum/mind(key)
		mind.active = 1
		mind.current = src

	if(length(newplayer_start))
		loc = pick(newplayer_start)
	else
		loc = locate(1,1,1)
	lastarea = loc

	sight |= SEE_TURFS
	player_list |= src

/*
	var/list/watch_locations = list()
	for(var/obj/effect/landmark/landmark in landmarks_list)
		if(landmark.tag == "landmark*new_player")
			watch_locations += landmark.loc

	if(watch_locations.len>0)
		loc = pick(watch_locations)
*/
	new_player_panel()
	spawn(40)
		if(client)
			//If the changelog has changed, show it to them
			spawn(1)
				if(client.prefs.lastchangelog != changelog_hash)
					// Need to send them the CSS and images :V
					client.getFiles(
						'nano/images/uiBackground.png',
						'nano/mapbase1024.png',
						'nano/NTLogoRevised.fla',
						'nano/uiBackground.fla',
						'nano/images/source/icon-eye.xcf',
						'nano/images/source/NTLogoRevised.fla',
						'nano/images/source/splash-ds.html',
						'nano/images/source/uiBackground.fla',
						'nano/images/source/uiBackground.xcf',
						'nano/images/source/uiBackground-Syndicate.xcf',
						'nano/images/source/uiBasicBackground.xcf',
						'nano/images/source/uiIcons16Green.xcf',
						'nano/images/source/uiIcons16Red.xcf',
						'nano/images/source/uiIcons24.xcf',
						'nano/images/source/uiNoticeBackground.xcf',
						'nano/images/source/uiTitleBackground.xcf',
						'nano/images/loading.gif',
						'nano/images/icon-eye.xcf',
						'nano/images/uiBackground.png',
						'nano/images/uiBackground.xcf',
						'nano/images/uiBackground-Syndicate.xcf',
						'nano/images/uiBasicBackground.png',
						'nano/images/nanomap.png',
						'nano/images/nanomap1.png',
						'nano/images/nanomap2.png',
						'nano/images/nanomap3.png',
						'nano/images/nanomap4.png',
						'nano/images/nanomap5.png',
						'nano/images/nanomap6.png',
						'nano/images/nanomapBackground.png',
						'nano/images/uiBackground-Syndicate.png',
						'nano/images/uiIcons16.png',
						'nano/images/uiIcons16Green.png',
						'nano/images/uiIcons16Red.png',
						'nano/images/uiIcons16Orange.png',
						'nano/images/uiIcons24.png',
						'nano/images/uiIcons24.xcf',
						'nano/images/uiLinkPendingIcon.gif',
						'nano/images/uiMaskBackground.png',
						'nano/images/uiNoticeBackground.jpg',
						'nano/images/uiTitleFluff.png',
						'nano/images/uiTitleFluff-Syndicate.png',
						'nano/templates/apc.tmpl',
						'nano/templates/accounts_terminal.tmpl',
						'nano/templates/advanced_airlock_console.tmpl',
						'nano/templates/ame.tmpl',
						'nano/templates/atmos_control.tmpl',
						'nano/templates/atmos_control_map_content.tmpl',
						'nano/templates/atmos_control_map_header.tmpl',
						'nano/templates/comm_console.tmpl',
						'nano/templates/disease_splicer.tmpl',
						'nano/templates/dish_incubator.tmpl',
						'nano/templates/docking_airlock_console.tmpl',
						'nano/templates/door_access_console.tmpl',
						'nano/templates/engines_control.tmpl',
						'nano/templates/escape_pod_berth_console.tmpl',
						'nano/templates/escape_pod_console.tmpl',
						'nano/templates/escape_shuttle_control_console.tmpl',
						'nano/templates/helm.tmpl',
						'nano/templates/isolation_centrifuge.tmpl',
						'nano/templates/layout_default.tmpl',
						'nano/templates/multi_docking_console.tmpl',
						'nano/templates/omni_filter.tmpl',
						'nano/templates/omni_mixer.tmpl',
						'nano/templates/pathogenic_isolator.tmpl',
						'nano/templates/shuttle_control_console.tmpl',
						'nano/templates/shuttle_control_console_exploration.tmpl',
						'nano/templates/simple_airlock_console.tmpl',
						'nano/templates/simple_docking_console.tmpl',
						'nano/templates/simple_docking_console_pod.tmpl',
						'nano/templates/TemplatesGuide.txt',
						'nano/templates/air_alarm.tmpl',
						'nano/templates/atmos_control.tmpl',
						'nano/templates/atmos_control_map_header.tmpl',
						'nano/templates/atmos_control_map_content.tmpl',
						'nano/templates/crew_monitor.tmpl',
						'nano/templates/crew_monitor_map_content.tmpl',
						'nano/templates/crew_monitor_map_header.tmpl',
						'nano/templates/canister.tmpl',
						'nano/templates/chem_dispenser.tmpl',
						'nano/templates/crew_monitor.tmpl',
						'nano/templates/cryo.tmpl',
						'nano/templates/dna_modifier.tmpl',
						'nano/templates/freezer.tmpl',
						'nano/templates/geoscanner.tmpl',
						'nano/templates/identification_computer.tmpl',
						'nano/templates/pda.tmpl',
						'nano/templates/smartfridge.tmpl',
						'nano/templates/smes.tmpl',
						'nano/templates/tanks.tmpl',
						'nano/templates/telescience_console.tmpl',
						'nano/templates/transfer_valve.tmpl',
						'nano/templates/uplink.tmpl',
						'nano/js/libraries/1-jquery.js',
						'nano/js/libraries.min.js',
						'nano/js/libraries/2-doT.js',
						'nano/js/libraries/3-jquery.timers.js',
						'nano/js/pngfix.js',
						'nano/js/nano_template.js',
						'nano/js/nano_base_helpers.js',
						'nano/js/nano_update.js',
						'nano/js/nano_config.js',
						'nano/js/nano_utility.js',
						'nano/js/nano_base_callbacks.js',
						'nano/js/nano_state.js',
						'nano/js/nano_state_manager.js',
						'nano/js/nano_state_default.js',
						'nano/css/layout_basic.css',
						'nano/css/nlayout_default.css',
						'nano/css/layout_default.css',
						'nano/css/icons.css',
						'nano/css/shared.css',
						'html/painew.png',
						'html/loading.gif',
						'html/search.js',
						'html/panels.css',
						'icons/pda_icons/pda_atmos.png',
						'icons/pda_icons/pda_back.png',
						'icons/pda_icons/pda_bell.png',
						'icons/pda_icons/pda_blank.png',
						'icons/pda_icons/pda_boom.png',
						'icons/pda_icons/pda_bucket.png',
						'icons/pda_icons/pda_crate.png',
						'icons/pda_icons/pda_cuffs.png',
						'icons/pda_icons/pda_eject.png',
						'icons/pda_icons/pda_exit.png',
						'icons/pda_icons/pda_flashlight.png',
						'icons/pda_icons/pda_honk.png',
						'icons/pda_icons/pda_mail.png',
						'icons/pda_icons/pda_medical.png',
						'icons/pda_icons/pda_menu.png',
						'icons/pda_icons/pda_mule.png',
						'icons/pda_icons/pda_notes.png',
						'icons/pda_icons/pda_power.png',
						'icons/pda_icons/pda_rdoor.png',
						'icons/pda_icons/pda_reagent.png',
						'icons/pda_icons/pda_refresh.png',
						'icons/pda_icons/pda_scanner.png',
						'icons/pda_icons/pda_signaler.png',
						'icons/pda_icons/pda_status.png',
						'icons/spideros_icons/sos_1.png',
						'icons/spideros_icons/sos_2.png',
						'icons/spideros_icons/sos_3.png',
						'icons/spideros_icons/sos_4.png',
						'icons/spideros_icons/sos_5.png',
						'icons/spideros_icons/sos_6.png',
						'icons/spideros_icons/sos_7.png',
						'icons/spideros_icons/sos_8.png',
						'icons/spideros_icons/sos_9.png',
						'icons/spideros_icons/sos_10.png',
						'icons/spideros_icons/sos_11.png',
						'icons/spideros_icons/sos_12.png',
						'icons/spideros_icons/sos_13.png',
						'icons/spideros_icons/sos_14.png',
						'icons/xenoarch_icons/chart1.jpg',
						'icons/xenoarch_icons/chart2.jpg',
						'icons/xenoarch_icons/chart3.jpg',
						'icons/xenoarch_icons/chart4.jpg',
						'html/postcardsmall.jpg',
						'html/somerights20.png',
						'html/88x31.png',
						'html/bug-minus.png',
						'html/cross-circle.png',
						'html/hard-hat-exclamation.png',
						'html/image-minus.png',
						'html/image-plus.png',
						'html/music-minus.png',
						'html/music-plus.png',
						'html/tick-circle.png',
						'html/wrench-screwdriver.png',
						'html/spell-check.png',
						'html/burn-exclamation.png',
						'html/chevron.png',
						'html/chevron-expand.png',
						'html/changelog.css',
						'html/changelog.js',
						'html/changelog.html'
						)
					src << browse('html/changelog.html', "window=changes;size=675x650")
					client.prefs.lastchangelog = changelog_hash
					client.prefs.save_preferences()
					winset(client, "rpane.changelog", "background-color=none;font-style=;")
			client.playtitlemusic()