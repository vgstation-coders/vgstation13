var/list/laser_tag_games = list()

/datum/laser_tag_participant
    var/nametag = ""
    var/total_shoots = 0
    var/total_hits = 0
    var/total_hit_by = 0
    var/team = ""
    var/list/hit_by = list()

/datum/laser_tag_game/New()
    laser_tag_games += src
    return ..()

/datum/laser_tag_game/Destroy()
    laser_tag_games -= src
    owner = null
    for (var/obj/item/clothing/suit/tag/tag_vest in tag_suits_list)
        if (tag_vest.my_laser_tag_game == src)
            tag_vest.my_laser_tag_game = null
    return ..()

/datum/laser_tag_game
    var/name = ""
    var/mode = LT_MODE_TEAM
    var/datum/laser_tag_participant/owner = null
    var/list/teams = list(
        "Blue" = list(),
        "Red" = list(),
    )
    // In seconds
    var/stun_time = 4
    var/disable_time = 0

    var/fire_mode = LT_FIREMODE_LASER

/datum/laser_tag_game/proc/get_score_board(var/mob/M)
    var/dat = list()
    dat += "<h3>Laser tag game</h3><br/>"
    dat += "<b>Mode:</b> [mode]<br/>"
    
    dat += "<hr/>"

    for (var/team in teams)
        var/list/team_members = teams[team]
        if (team_members.len)
            dat += "<h4>[team] Team </h4>"
            dat += "<hr/>"
            for (var/datum/laser_tag_participant/gamer in team_members)
                dat += "<b>[gamer.nametag]</b> <br/>"
                dat += "Hit by: "
                for (var/pwner in gamer.hit_by)
                    dat += "<i>[pwner]</i> : [gamer.hit_by[pwner]]  "
                if (gamer.hit_by.len == 0)
                    dat += "nobody (yet)"
                dat += "<br/>"
                dat += "<b>Accuracy: </b> [round(gamer.total_hits/(max(gamer.total_shoots, 1)), 0.01)*100]% (Shoots: [gamer.total_shoots], hits: [gamer.total_hits])<br/>"
                dat += "<b>Score: </b> [gamer.total_hits * 100 - gamer.total_hit_by * 50]" // -50 for being hit, +100 for hitting someone
                dat += "<hr/>"
            dat += "<hr/>"
    
    var/text = jointext(dat,"")
    var/obj/item/weapon/paper/P = new(get_turf(M))
    P.info = text
    P.name = "Laser tag scoreboard"
    M.put_in_hands(P)

/datum/laser_tag_game/proc/handle_new_player(var/datum/laser_tag_participant/new_player, var/mob/player_mob)
    teams[new_player.team] |= new_player // Allows people to rejoin games they left.

/datum/laser_tag_game/proc/kick_player(var/mob/player_mob)
    var/obj/item/clothing/suit/tag/tag_vest = get_tag_armor(player_mob)
    if (tag_vest)
        tag_vest.my_laser_tag_game = null // Don't delete their particpant datum, we need it for the score.