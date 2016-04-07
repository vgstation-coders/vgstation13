var/global/datum/controller/process/wagePayout/wagePayoutController = null
/datum/controller/process/wagePayout
	schedule_interval = 9000 // 15 minutes

/datum/controller/process/wagePayout/setup()
	name = "wage payout"
/datum/controller/process/wagePayout/doWork()
	wagePayout()
