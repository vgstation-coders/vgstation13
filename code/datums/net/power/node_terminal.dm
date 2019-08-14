/datum/net_node/power/with_terminal
    var/datum/net_node/power/terminal/terminal

/datum/net_node/power/with_terminal/proc/add_terminal(var/datum/net_node/power/terminal/T)
    terminal = T
    terminal.master = src

/datum/net_node/power/with_terminal/Destroy()
    . = ..()
    active = FALSE
    if(terminal)
        terminal.master = null
        terminal.rebuild_connections()
    terminal = null

/datum/net_node/power/with_terminal/get_connections()
    . = ..()
    if(terminal)
        . |= terminal

/datum/net_node/power/terminal
    var/datum/net_node/power/with_terminal/master

/datum/net_node/power/terminal/proc/add_master(/datum/net_node/power/with_terminal/M)
    master = M
    master.terminal = src

/datum/net_node/power/terminal/Destroy()
    . = ..()
    master.terminal = null
    master = null

/datum/net_node/power/terminal/get_connections()
    . = ..()
    if(master)
        . |= master