// Proc called at Login() to show the tip
// Check for preferences

/mob/new_player/proc/show_tip_of_the_day()
	if (client?.prefs.tip_of_the_day)
		var/list/tips_weights = list()
		for (var/tip in subtypesof(/datum/tip_of_the_day))
			var/datum/tip_of_the_day/T = tip
			tips_weights[T] = initial(T.weight)

		var/datum/tip_of_the_day/tip_picked = pickweight(tips_weights)
		show_tip(tip_picked)

/mob/new_player/proc/show_tip(var/datum/tip_of_the_day/tip_picked)
	var/datum/browser/popup = new(src, "\ref[src]", "Tip of the day", 500, 150)
	var/html = {"
		[initial(tip_picked.desc)] <br/>
		<br/>
		[initial(tip_picked.category)] - <a href='?src=\ref[src]&refresh_tip=1&current_tip=[tip_picked]'>Refresh tip</a> <br/>
		<i>You can disable showing tips at roundstart in your preferences.</i>
	"}
	popup.set_content(html)
	popup.open()
