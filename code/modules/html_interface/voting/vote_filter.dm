/datum/vote_filter/proc/filter_vote_list(list/votes)

/datum/vote_filter/rank_filter
	//A value of 0 is no filtering
	var/minimum_ranking = 2

/datum/vote_filter/rank_filter/New(var/min_rank)
	if(isnum(min_rank))
		minimum_ranking = min_rank

/datum/vote_filter/rank_filter/filter_vote_list(list/votes)
	//Removes the least-weighted choice from picking so long as the list is too large
	if(minimum_ranking > 0)
		while(votes.len > minimum_ranking)
			var/smallest = null
			for (var/choice in votes)
				if(!smallest || votes[choice] < votes[smallest])
					smallest = choice

			votes -= smallest

/datum/vote_filter/share_filter
	var/minimum_share = 0.2

/datum/vote_filter/share_filter/New(var/min_share)
	if(isnum(min_share))
		//Can't have less than no votes or more than all the votes
		minimum_share = Clamp(min_share, 0, 1)

/datum/vote_filter/share_filter/filter_vote_list(list/votes)
	var/total = 0

	for(var/choice in votes)
		total += votes[choice]

	//We use a list to avoid modifying votes while we for over it
	var/list/bad_choices = new /list()

	for(var/choice in votes)
		//We got too few votes to be a choice
		if(votes[choice]/total < minimum_share)
			bad_choices += choice

	votes -= bad_choices
