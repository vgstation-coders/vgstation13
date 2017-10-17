var/datum/subsystem/processing/fastprocess/SSfastprocess

/datum/subsystem/processing/fastprocess
    name = "Fast Processing"
    wait = 0.2 SECONDS
    stat_tag = "FP"

/datum/subsystem/processing/fastprocess/New()
    NEW_SS_GLOBAL(SSfastprocess)