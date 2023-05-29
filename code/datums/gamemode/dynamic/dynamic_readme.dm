/*
Dynamic flow looks like this:

ROUNDSTART
Dynamic rolls threat based on a special sauce formula rand(1,100)*0.6 + rand(1,100)*0.4
LJ/MR injection timers set randomly between LJ(330,510)/MR(600,1050)

https://docs.google.com/spreadsheets/d/1QLN_OBHqeL4cm9zTLEtxlnaJHHUu0IUPzPbsI-DFFmc/edit#gid=499381388

rigged_roundstart() is called instead if there are forced rules (e.g.: an admin set the mode)

can_start() -> Setup() -> roundstart() OR rigged_roundstart() -> picking_roundstart_rule(drafted_rules) -> PostSetup()
**All existing roles and factions ForgeObjectives in PostSetup()

PROCESS (about every 2 sec)
Calls all rule, faction, and role process()
Every sixty seconds, update_playercounts()
Both Injection timers -1                                                 **NOTE this means a roll of 600 ticks means 1200 seconds, or 20 minutes)
If latejoin reaches 0, it stays there  until someone joins.
If midround reaches 0, it updates playercounts again, then tries to inject and resets its timer regardless of whether a rule is picked.

ROLE process()
Does nothing.

FACTION process()
Calls process to each member role

RULE process()
Nothing at root level. As of 2/14 only ruleset to use this is roundstart autotraitor, which finds its own tots.

LATEJOIN
latespawn(newPlayer) -> injection_attempt() -> [For each latespawn rule...]
-> acceptable() -> trim_candidates() -> ready(forced=FALSE) **If true, add to drafted rules
**NOTE that acceptable uses threat_level not threat! 				 **NOTE Latejoin timer is ONLY reset if at least one rule was drafted.
**NOTE the new_player.dm AttemptLateSpawn() calls OnPostSetup for all roles (unless assigned role is MODE)

[After collecting all draftble rules...]
-> picking_latejoin_ruleset(drafted_rules) -> spend threat -> ruleset.execute()


MIDROUND
process() -> injection_attempt() -> [For each midround rule...]
-> acceptable() -> trim_candidates() -> ready(forced=FALSE)
[After collecting all draftble rules...]
-> picking_midround_ruleset(drafted_rules) -> spend threat -> ruleset.execute()


FORCED
For latejoin, it simply sets forced_latejoin_rule
latespawn(newPlayer) -> trim_candidates() -> ready(forced=TRUE) **NOTE no acceptable() call

For midround, calls the below proc with forced = TRUE
picking_specific_rule(ruletype,forced) -> forced OR acceptable() -> trim_candidates() -> ready(forced) -> spend threat -> execute()
**NOTE specific rule can be called by RS traitor->MR autotraitor w/ forced=FALSE
**NOTE that due to short circuiting acceptable() need not be called if forced.

RULESET
acceptable(p) just checks if enough threat_level for population indice.
**NOTE that we currently only send threat_level as the second arg, not threat.
ready(forced) checks if enough candidates and calls the map's map_ruleset(dynamic_ruleset) at the parent level
logo_state: if creating a non-faction role, name should be the same for both the role (for role_HUD_icons.dmi) and the ruleset (for logos.dmi) to prevent scoreboard bugs

trim_candidates() varies significantly according to the ruleset type
Roundstart: All candidates are new_player mobs. Check them for standard stuff: connected, desire role, not banned, etc.
**NOTE Roundstart deals with both candidates (trimmed list of valid players) and mode.candidates (everyone readied up). Don't confuse them!
Latejoin: Only one candidate, the latejoiner. Standard checks.
Midround: Instead of building a single list candidates, candidates contains four lists: living, dead, observing, and living antags. Standard checks in trim_list(list).

Midround - Rulesets have additional types
/from_ghosts: execute() -> send_applications() -> review_applications() -> finish_setup(mob/newcharacter,index) -> setup_role(role)
**NOTE: execute() here adds dead players and observers to candidates list

/from_ghosts/faction_based: as above, but setup_role() -> faction.HandleRecruitedRole(role)
** NOTE: setup_role normally calls OnPostSetup, faction_based calls the faction's OnPostSetup one time the first time the faction is made instead.
** The main implication of this is that it's inuitive for factions like Nuke Ops where all ghosts spawn at once, and bad for Ragin' Mages where they come one/time.

*/
