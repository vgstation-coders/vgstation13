/datum/objective/reach_followers
	var/followers_jectie = 15
	explanation_text = "Reach 15 followers."
	name = "(streamer) Reach followers"

/datum/objective/reach_followers/PostAppend()
	followers_jectie = round(rand(10, 20))
	explanation_text = "Reach [followers_jectie] followers."
	return TRUE

/datum/objective/reach_followers/IsFulfilled()
	if (..())
		return TRUE
	var/datum/role/streamer/S = owner.GetRole(STREAMER)
	if (!S)
		message_admins("BUG: [owner.current] was given a streamer objective but is not affiliated with Spess.TV!")
		return FALSE
	return length(S.followers) >= followers_jectie

/datum/objective/reach_subscribers
	var/subscribers_jectie = 7
	explanation_text = "Reach 7 subscribers."
	name = "(streamer) Reach subscribers"

/datum/objective/reach_subscribers/PostAppend()
	subscribers_jectie = round(rand(5, 10))
	explanation_text = "Reach [subscribers_jectie] subscribers."
	return TRUE

/datum/objective/reach_subscribers/IsFulfilled()
	if (..())
		return TRUE
	var/datum/role/streamer/S = owner.GetRole(STREAMER)
	if (!S)
		message_admins("BUG: [owner.current] was given a streamer objective but is not affiliated with Spess.TV!")
		return FALSE
	return length(S.subscribers) >= subscribers_jectie
