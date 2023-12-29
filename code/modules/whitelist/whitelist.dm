/************************************************************
!
! WHITELIST MODULE
!
! Made by MarcusAga
!
! 14/12/2023
!
! Please note that the important piece of code is present in
! code/modules/new_player/new_player.dm file. If you're
! willing to use this Whitelist module then you should CTRL+F
! for 'ready' and 'late_join' hrefs, as that's where the main
! whitelist logic is. Make sure you use mySQL, and please
! credit the author. Cheers!

! SQL for the table can be found in 017-player_whitelist.dm
!
!-----------------------------------------------------------*/

/************************************************************
!
! KNOWN ISSUES:
!
! * invite_friend: empty field can be invited (fixed)
! * show_whitelist_panel: runtime when the 'invitedby' column stores 0 (fixed)
! * invite_friend: might be a good idea to limit invites/introduce timeout as there's posibility for invite-flooding, which isn't... quite good for the database
!
!-----------------------------------------------------------*/
/client
	var/lastinvitetime = 0

/client/verb/invite_friend() //Straight-forward. Player present in the whitelist sends an invite, no description required.
	set category = "OOC"
	set name = "Invite Friend"

	var/whitelistId = 0
	var/whitelistVerified = 0

	//var/difference = round(lastinvitetime-world.time)
	//to_chat(usr,"world.time = [world.time], invitetime = [lastinvitetime]")*/

	if (world.time < lastinvitetime)
		to_chat(usr, "<span class='warning'>You must wait before you can send another invite!</span>")
		return

	//Check whether the user is verified & whitelisted
	var/datum/DBQuery/query = SSdbcore.NewQuery("SELECT id, verified FROM player_whitelist WHERE ckey = :ckey", list("ckey" = "[usr.ckey]"))
	if(query.Execute())
		whitelistId = query.NextRow() //returns 1 if the row is found, otherwise 0
		if(whitelistId == 1) //found the row, so the player has been invited
			whitelistId = query.item[1]
			whitelistVerified = query.item[2]
			if(whitelistVerified == 1) //the player has been verified (1)
				var/friendCkey = copytext(trimtext(sanitize(input(usr, "Please specify your friend's Byond login. For example: marcusaga", "Whitelist", null))), 1)
				//to_chat(usr,"[friendCkey]")
				//COMPARE IF THERE'S ALREADY AN USER WITH SUCH CKEY PRESENT IN THE TABLE. Even tough MySQL already does that, it is a good idea to do on the code side as it will give a user-friendly error
				var/datum/DBQuery/queryFindFriend = SSdbcore.NewQuery("SELECT id FROM player_whitelist WHERE ckey = :ckey", list("ckey" = "[friendCkey]"))
				if(!isnull(friendCkey))
					if(queryFindFriend.Execute())
						var/friendId = queryFindFriend.NextRow()

						//if(!friendCkey == "")
						if (friendId == 0) //the ckey (friend) is not present in the table
							var/datum/DBQuery/queryInviteFriend = SSdbcore.NewQuery("INSERT INTO player_whitelist (ckey, invitedby) VALUES (TRIM(LOWER('[friendCkey]')), '[whitelistId]')")
							if(queryInviteFriend.Execute())
								to_chat(usr,"<span class='warning'>You have invited <b>[friendCkey]</b> to the server. It may take a little while before they get verified.</span>")
								lastinvitetime = world.time + 1 MINUTES
								message_admins("[ckey] have invited [friendCkey] to the server. Please verify them.")
								return
							else
								to_chat(usr,"Error inserting [friendCkey], [whitelistId] into player_whitelist: [queryInviteFriend.ErrorMsg()]")
								qdel(queryInviteFriend)
								return
						else
							to_chat(usr,"<span class='warning'><b>[friendCkey]</b> has already been invited!</span>")
							//message_admins("[ckey] tried to invite [friendCkey] despite them already being invited.")
							return
					else
						to_chat(usr,"Error fetching [ckey] id from player_whitelist: [queryFindFriend.ErrorMsg()]")
						qdel(queryFindFriend)
						return
			else //the player has not been verified yet (0)
				to_chat(usr, "<span class='warning'>You have not been verified yet despite being invited. Please wait till you get verified before you can invite others.</span")
				return
		else
			to_chat(usr, "<span class='warning'>You are not invited to play on this server.</span>")
			return
	else
		to_chat(usr,"Error fetching [ckey] id from player_whitelist: [query.ErrorMsg()]")
		qdel(query)
		return

//Less straight-forward than getting invited by a friend. In case of applying, the player is required to provide some sort of description of themself.
//Might be a better idea to force the Application window to the player once they receive the message saying they're not invited to play on the server.
/*/client/proc/apply_to_play(msg as text)
	set category = "OOC"
	set name = "Apply"
*/

/client/proc/whitelist_panel() //Only available to admins, as that's where they verify the players
	set name = "Whitelist Panel"
	set category = "Admin"

	if(!usr.client || !usr.client.holder)
		to_chat(usr, "<span class='warning'>You need to be an administrator to access this.</span>")
		return

	if(holder)
		holder.show_whitelist_panel()
		feedback_add_details("admin_verb","WLP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return

/datum/admins/proc/show_whitelist_panel()
	var rowsCount = 0
	//var totalRowsCount = 0

	//Count the rows first
	var/datum/DBQuery/queryRowsCount = SSdbcore.NewQuery("SELECT COUNT(*) FROM player_whitelist WHERE verified = '0'")

	if(queryRowsCount.Execute())
		queryRowsCount.NextRow()
		rowsCount = queryRowsCount.item[1]
		//to_chat(usr, "[rowsCount]")
	else
		to_chat(usr,"Error fetching row quantity from player_whitelist: [queryRowsCount.ErrorMsg()]")
		qdel(queryRowsCount)

	//Then select the rows
	var/datum/DBQuery/querySelectRow = SSdbcore.NewQuery("SELECT * FROM player_whitelist WHERE verified = '0'")

	if(querySelectRow.Execute())
	else to_chat(usr,"Error fetching from player_whitelist: [querySelectRow.ErrorMsg()]")

	/*
	//Select all verified users (potential inviters), as we will be giving their CKeys instead of IDs in the table
	var/datum/DBQuery/queryInviterCkey = SSdbcore.NewQuery("SELECT id, ckey FROM player_whitelist WHERE verified = '1'")
	*/

	if(querySelectRow.Execute())
	else to_chat(usr,"Error fetching from player_whitelist: [querySelectRow.ErrorMsg()]")

	/*var/datum/DBQuery/queryCountRows = SSdbcore.NewQuery("SELECT COUNT(id) FROM player_whitelist")
	if(queryCountRows.Execute())
		totalRowsCount = queryRowsCount.item[1]
		to_chat(usr, "row quantity: [totalRowsCount]")
	else
		to_chat(usr,"Error fetching row quantity from player_whitelist: [queryCountRows.ErrorMsg()]")
		qdel(queryCountRows)*/

	/*var/datum/DBQuery/querySelectAllRows = SSdbcore.NewQuery("SELECT id, ckey FROM player_whitelist")
	if(querySelectAllRows.Execute())
	else to_chat(usr,"Error fetching id, ckeys from player_whitelist: [querySelectAllRows.ErrorMsg()]")*/

	//Browser starts here
	var/dat = "<head><meta charset='UTF-8'></head><HR><span class='warning'><b>(VERIFY)</b> = Add to the whitelist</span><HR><table border=1 rules=all frame=void cellspacing=0 cellpadding=3 >"

	var/i = 0
	while(i < rowsCount)
		//to_chat(usr, "i=[i], rowsCount=[rowsCount]")
		i++
		querySelectRow.NextRow()
		var/ref						= "\ref[src]"
		var/whitelistId				= querySelectRow.item[1]
		var/whitelistCkey			= querySelectRow.item[2]
		var/whitelistInvitedBy		= querySelectRow.item[3]
		var/whitelistDateInvited	= querySelectRow.item[4]
		var/whitelistDescription	= querySelectRow.item[6]
		//to_chat(usr, "[whitelistId] [whitelistCkey] [whitelistInvitedBy] [whitelistDateInvited] [whitelistDescription]")

		var/whitelistInvitedByCkey = "UNKNOWN"

		var/datum/DBQuery/queryGetInviterCkey = SSdbcore.NewQuery("SELECT ckey FROM player_whitelist WHERE id = '[whitelistInvitedBy]'")
		if(queryGetInviterCkey.Execute())
			var/foundrow = queryGetInviterCkey.NextRow() //returns 1 if the row is found, otherwise 0
			if(foundrow == 1) //found the row, so the inviter is not 0 (e.g. applied to join instead of getting invited)
				var/result = queryGetInviterCkey.item[1]
				whitelistInvitedByCkey = result
			else
				whitelistInvitedByCkey = "SERVER"
		else
			to_chat(usr,"Error fetching ckey from player_whitelist where id = '[whitelistInvitedBy]: [queryGetInviterCkey.ErrorMsg()]")
			qdel(queryGetInviterCkey)

		dat += text("<tr><td><a href='?src=[ref];verify=[whitelistId]'>VERIFY</a></td> <td>ID: <B>[whitelistId]</B></td><td>CKey: <B>[whitelistCkey]</B></td><td>Inviter: <B>[whitelistInvitedByCkey] (id:[whitelistInvitedBy])</B></td><td>Date: <B>[whitelistDateInvited]</B></td><td>Description: <B>[whitelistDescription]</B></td></tr>")
	dat += "</table><HR><B>Total:</B> <FONT COLOR=green>[rowsCount] pending applications</FONT><HR>"
	usr << browse(dat, "window=whitelistp;size=875x400")

	//нужно: 1. доделать whitelistInvitedByCkey, 2. кнопку верификации
