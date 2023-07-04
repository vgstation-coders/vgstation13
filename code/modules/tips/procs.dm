// Proc called at Login() to show the tip
// Check for preferences

/mob/new_player/proc/show_tip(var/datum/pomf_tip/tip_picked)
	var/html = {"<hr/> <b>Pomf tip</b> <br/>
		[initial(tip_picked.desc)] <br/>
		<br/>
		[initial(tip_picked.category)] - <a href='?src=\ref[src]&refresh_tip=1'>Refresh tip</a> <br/>
		<i>You can disable showing tips at roundstart in your preferences.</i>
	"}
	return html
