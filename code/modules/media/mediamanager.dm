/**********************
 * AWW SHIT IT'S TIME FOR RADIO
 *
 * Concept stolen from D2K5
 *
 * Rewritten by N3X15
 ***********************/

// Uncomment to test the mediaplayer
//#define DEBUG_MEDIAPLAYER

// Open up VLC and play musique.
// Converted to VLC for cross-platform and ogg support. - N3X
var/const/PLAYER_HTML=@{"
<object classid="clsid:9BE31822-FDAD-461B-AD51-BE1D1C159921" codebase="http://download.videolan.org/pub/videolan/vlc/last/win32/axvlc.cab" id="player"></object>
<script>
function noErrorMessages () { return true; }
window.onerror = noErrorMessages;
function SetMusic(url, time, volume) {
	var vlc = document.getElementById('player');
	// Stop playing
	vlc.playlist.stop();

	// Clear playlist
	vlc.playlist.items.clear();

	// Add new playlist item.
	var id = vlc.playlist.add(url);

	// Play playlist item
	vlc.playlist.playItem(id);
	vlc.input.time = time*1000; // VLC takes milliseconds.
	// volume is in the range [0-200]
	vlc.audio.volume = +volume;
	setTimeout(function(){ // If we don't do this it might not set the volume to the right value SOMETIMES
		vlc.audio.volume = +volume;
	}, 2000);
}
</script>
"}

/* OLD, DO NOT USE.  CONTROLS.CURRENTPOSITION IS BROKEN.*/
/*var/const/PLAYER_OLD_HTML={"
	<OBJECT id='playerwmp' CLASSID='CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6' type='application/x-oleobject'></OBJECT>
	<script>
function noErrorMessages () { return true; }
window.onerror = noErrorMessages;
function SetMusic(url, time, volume) {
	var player = document.getElementById('playerwmp');
	player.URL = url;
	player.controls.currentPosition = time;
	player.settings.volume = volume;
}
	</script>"}

*/

var/const/PLAYER_OLD_HTML={"
	<OBJECT id='player' CLASSID='CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6' type='application/x-oleobject'></OBJECT>
	<script>
function noErrorMessages () { return true; }
window.onerror = noErrorMessages;
function SetMusic(url, time, volume) {
	var player = document.getElementById('player');
	player.URL = url;
	player.Controls.currentPosition = +time;
	player.Settings.volume = +volume;
}
	</script>"}

/proc/stop_all_media()
	for(var/mob/M in mob_list)
		if(M && M.client)
			M.stop_all_music()

// Hook into the events we desire.
// Set up player on login
/hook_handler/soundmanager/proc/OnLogin(var/list/args)
	//testing("Received OnLogin.")
	var/client/C = args["client"]
	C.media = new /datum/media_manager(args["mob"])
	C.media.open()
	C.media.update_music()

/hook_handler/soundmanager/proc/OnReboot(var/list/args)
	//testing("Received OnReboot.")
	log_startup_progress("Stopping all playing media...")
	// Stop all music.
	stop_all_media()
	//  SHITTY HACK TO AVOID RACE CONDITION WITH SERVER REBOOT.
	sleep(10)

// Update when moving between areas.
/hook_handler/soundmanager/proc/OnMobAreaChange(var/list/args)
	var/mob/M = args["mob"]
	//if(istype(M, /mob/living/carbon/human)||istype(M, /mob/dead/observer))
	//	testing("Received OnMobAreaChange for [M.type] [M] (M.client=[M.client==null?"null":"/client"]).")
	if(M.client && M.client.media && !M.client.media.forced)
		M.update_music()


/hook_handler/shuttlejukes/proc/OnEmergencyShuttleDeparture(var/list/args)
	for(var/obj/machinery/media/jukebox/superjuke/shuttle/SJ in machines)
		SJ.playing=1
		SJ.update_music()
		SJ.update_icon()

/mob/proc/update_music()
	if (client && client.media && !client.media.forced)
		client.media.update_music()

/mob/proc/stop_all_music()
	if (client)
		src << sound(null, repeat = 0, wait = 0, volume = 0, channel = CHANNEL_ADMINMUSIC)
		if(client.media)
			client.media.push_music("",0,1)

/mob/verb/stop_admin_music()
	set name = "Stop Admin Music"
	set desc = "Stops all playing admin sounds."
	set category = "OOC"
	
	src << sound(null, repeat = 0, wait = 0, volume = 0, channel = CHANNEL_ADMINMUSIC)
			
/mob/proc/force_music(var/url,var/start,var/volume=1)
	if (client && client.media)
		client.media.forced=(url!="")
		if(client.media.forced)
			client.media.push_music(url,start,volume)
		else
			client.media.update_music()

/area
	// One media source per area.
	var/obj/machinery/media/media_source = null

#ifdef DEBUG_MEDIAPLAYER
to_chat(#define MP_DEBUG(x) owner, x)
#warn Please comment out #define DEBUG_MEDIAPLAYER before committing.
#else
#define MP_DEBUG(x)
#endif

/datum/media_manager
	var/url = ""
	var/start_time = 0
	var/source_volume = 1 // volume * source_volume

	var/volume = 50
	var/client/owner
	var/mob/mob

	var/forced=0

	var/const/window = "rpane.hosttracker"
	//var/const/window = "mediaplayer" // For debugging.
	var/playerstyle

/datum/media_manager/New(var/mob/holder)
	src.mob=holder
	owner=src.mob.client
	if(owner.prefs)
		if(!isnull(owner.prefs.volume))
			volume = owner.prefs.volume
		if(owner.prefs.usewmp)
			playerstyle = PLAYER_OLD_HTML
		else
			playerstyle = PLAYER_HTML

// Actually pop open the player in the background.
/datum/media_manager/proc/open()
	owner << browse(null, "window=[window]")
	owner << browse(playerstyle, "window=[window]")
	send_update()

// Tell the player to play something via JS.
/datum/media_manager/proc/send_update()
	if(!(owner.prefs))
		return
	if(!(owner.prefs.toggles & SOUND_STREAMING) && url != "")
		return // Nope.
	MP_DEBUG("<span class='good'>Sending update to VLC ([url])...</span>")
	owner << output(list2params(list(url, (world.time - start_time) / 10, volume*source_volume)), "[window]:SetMusic")

/datum/media_manager/proc/push_music(var/targetURL,var/targetStartTime,var/targetVolume)
	if (url != targetURL || abs(targetStartTime - start_time) > 1 || abs(targetVolume - source_volume) > 0.1 /* 10% */)
		url = targetURL
		start_time = targetStartTime
		source_volume = Clamp(targetVolume, 0, 1)
		send_update()

/datum/media_manager/proc/stop_music()
	push_music("",0,1)

// Scan for media sources and use them.
/datum/media_manager/proc/update_music()
	var/targetURL = ""
	var/targetStartTime = 0
	var/targetVolume = 0

	if (forced || !owner)
		return

	var/area/A = get_area(mob)
	if(!A)
		//testing("[owner] in [mob.loc].  Aborting.")
		stop_music()
		return
	var/obj/machinery/media/M = A.media_source // TODO: turn into a list, then only play the first one that's playing.
	if(M && M.playing)
		targetURL = M.media_url
		targetStartTime = M.media_start_time
		targetVolume = M.volume
//			to_chat(owner, "Found audio source: [M.media_url] @ [(world.time - start_time) / 10]s.")
	//else
	//	testing("M is not playing or null.")
	push_music(targetURL,targetStartTime,targetVolume)

/datum/media_manager/proc/update_volume(var/value)
	volume = value
	send_update()

/client/verb/change_volume()
	set name = "Set Volume"
	set category = "OOC"
	set desc = "Set jukebox volume"

/client/proc/set_new_volume()
	if(!media || !istype(media))
		to_chat(usr, "You have no media datum to change, if you're not in the lobby tell an admin.")
		return
	var/oldvolume = prefs.volume
	var/value = input("Choose your Jukebox volume.", "Jukebox volume", media.volume)
	value = round(max(0, min(100, value)))
	media.update_volume(value)
	if(prefs && (oldvolume != value))
		prefs.volume = value
		prefs.save_preferences_sqlite(src, ckey)
