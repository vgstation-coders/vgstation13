<!--
Pull requests must be atomic.  Change one set of related things at a time.  Bundling sucks for everyone.
This means, primarily, that you shouldn't fix bugs and add content in the same PR. When we mean 'bundling', we mean making one PR for multiple, unrelated changes.

Test your changes. PRs that do not compile will not be accepted.
Testing your changes locally is incredibly important. If you break the serb we will be very upset with you.

Large changes require discussion.  If you're doing a large, game-changing modification, or a new layout for something, discussion with the community is required as of 26/6/2014.  Map and sprite changes require pictures of before and after.  MAINTAINERS ARE NOT IMMUNE TO THIS.  GET YOUR ASS IN IRC.

Merging your own PRs is considered bad practice, as it generally means you bypass peer review, which is a core part of how we develop.

It is also suggested that you hop into irc.rizon.net #vgstation or the coding discord (you can find an invite link on the irc or the thread) to discuss your changes, or if you need help.

== SELF LABELLING PRs ==
You can now self-label your PR! The syntax is simple. Just put [<labeltag>] anywhere in your PR,
where <labeltag> is to be replaced by one of the following (allowing with the resultant tag)
just ctrl+f the list or something. I know it's long.

administration = "Logging / Administration"
away = "Mapping (Away Mission :earth_africa:)"
bagel = "Mapping (Bagel :o:)"
box = "Mapping (Box :baby:)"
bugfix = "Bug / Fix"
bus = "Mapping (Bus :bus:)"
byond = "T-Thanks BYOND"
consistency = "Consistency Issue"
controversial = "Controversial"
deff = "Mapping (Deff :wastebasket:)"
discussion = "Discussion"
dnm = "✋ Do Not Merge ✋"
easy = "Easy Fix"
exploitable = "Exploitable"
featureloss = "Feature Loss"
featurerequest = "Feature Request"
first = "good first issue"
formatting = "Grammar / Formatting"
gamemode = "Gameplay / Gamemode"
gameplay = "Gameplay / Gamemode"
general = "Mapping (General :world_map:)"
goonchat = "Goonchat"
grammar = "Grammar / Formatting"
help = "help wanted"
hotfix = "Hotfix"
libvg = "libvg"
logging = "Logging / Administration"
meta = "Mapping (Meta :no_mobile_phones:)"
needspritework = "Needs Spritework"
oversight = "Oversight"
packed = "Mapping (Packed :package:)"
parallax = "Parallax"
qol = "❤️ Quality of Life ❤️"
roid = "Mapping (Roidstation :pick:)"
role = "Role Datums"
roleissue = "Role Datums Issue"
runtime = "Runtime Log"
sanity = "Sanity / Ghosthands"
snowmap = "Mapping (Snowmap ❄)"
sound = "Sound"
sprites = "Sprites"
spriteworkdone = "Spritework Done Needs Coder"
system = "System"
taxi = "Mapping (Taxi :taxi:)"
tested = "100%  tested"
tweak = "Tweak"
ui = "UI"
vault = "Mapping (Vault :question:)"
vote = "⛔ Requires Server Vote ⛔"
wip = "WiP"

== CHANGELOGS ==
Changelogs can be attached either by following the instructions in html/changelogs/example.yml, or by attaching an in-body changelog like the one attached to your PR automatically.

For the keys you can use in an in-body changelog, they are the same as described in example.yml
NOTE that anything *after* the :cl: will be parsed as a changelog, if it somehow manages to be parseable as such, so always put the changelog at the VERY end!

Valid Prefixes:
bugfix
wip (For works in progress)
tweak
soundadd
sounddel
rscdel (general deleting of nice things)
rscadd (general adding of nice things)
imageadd
imagedel
spellcheck (typo fixes)
experiment
tgs (TG-ported fixes?)

An example changelog is attached to this PR for your convenience:
-->
:cl:
 * rscadd: Did stuff!
 * rscdel: did other stuff!