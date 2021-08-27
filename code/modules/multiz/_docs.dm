/* Multi-Z code was ported from Polaris, which operates under the AGPL v3 license.
Permission for its use was obtained on 11/12/2017 from Neerti in the Polaris Discord. */

/* PORT NOTES
- Removed scaling with magboots / robots (pending discussion)
- We appear to already tell universe on turf change so I removed turf changed handling (see Polaris turf/ChangeTurf) which required their observer datum, instead
see turfs/turf.dm ChangeTurf()
- We handle building lattices and plating differently, see turfs.dm
- We don't have edge blending, but that's mostly for grass stuff anyway.
- We have scrapped connect type. We'll let you connect any two pipes on the same layer. Also note Polaris has no layered piping.
- Polaris uses some different hearing with hear_say, hear_quote, hear_radio. Our Hear() did not cover it, so it was updated to.
- Our pipes don't seem to use pipe_color, see update_icon
- Removed OS controller altogether
- When Bay/Polaris ported our ventcrawling, they adapted the relaymove in pipes into a proc ventcrawl_to. Now we've adapted to use that proc.
- Rather than try to implement audible_message from Polaris (a whole rabbithole of helper procs), converted them to visible_message
- Ported post_change() for turfs
- At 384 and 386 in process.dm we manually add to world.log, Polaris has logging procs (log_to_dd) that I didn't port
- Commented a log_runtime call at 365 for similar reasons
- MultiZAS: airflow between Z levels was merely a define and type changes away from working (ZAS/ConnectionManager.dm)
- Jetpacks and flight allow travelling up or down Z-levels

What's NOT ported?
- Elevators (modules/turbolift/)
- Powernet across Z levels?
*/