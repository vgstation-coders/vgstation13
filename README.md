# /vg/station [![Build Status](https://travis-ci.org/vgstation-coders/vgstation13.svg?branch=master)](https://travis-ci.org/vgstation-coders/vgstation13)

[![forinfinityandbyond](https://user-images.githubusercontent.com/5211576/29499758-4efff304-85e6-11e7-8267-62919c3688a9.gif)](https://www.reddit.com/r/SS13/comments/5oplxp/what_is_the_main_problem_with_byond_as_an_engine/dclbu1a)

[Website](http://ss13.moe) - [Code](https://github.com/vgstation-coders/vgstation13)

Discord Coding Server Invite Link:
No longer available from github due to spambots using it.
Check the thread on /vg/ for a link or ask a player in-game for an invite.

---

### GETTING THE CODE
The simplest but least useful way to obtain the code is using the Github .zip feature. You can click [here](https://github.com/vgstation-coders/vgstation13/archive/Bleeding-Edge.zip) to get the latest stable code as a .zip file, then unzip it to wherever you want. This is mostly useful for people looking to get assets from the server or to host a quick short-term game between friends.

Alternatively, the code can be acquired via the use of a Git client as described below. If you're still having difficulty, reach out to one of our coders on Discord and they should be happy to help.

### Git client

The slightly more complicated but way more useful way is to use a Git client. If you want to contribute code and updates to /vg/, you're going to want to do things this way.

We recommend our users use the Github Desktop client, available [here](https://desktop.github.com/). After installing the client and logging in with your Github account, go back to the [Github page](https://github.com/vgstation-coders/vgstation13) for our code and press the "Fork" button at the top of the page. This will walk you through the process of creating a clone of our codebase on your account.

Once the fork is complete, go back to the Github Desktop client and press the 'Current Reposistory' button at the top left. From there, click 'Add', then 'Clone Reposistory'. If your fork doesn't appear on the list immediately, press the refresh button at the top right and it should find it. Once you've selected it, Github Desktop will then begin downloading the codebase to the specified location on your machine. Once the clone finishes downloading, you've got your own copy of the code ready to go complete with easy tools to keep it sync'd and to make your own PRs to the repo.

If your repository is behind on the latest updates to the code, navigate to the page for your forked repository on Github and press the 'Sync Fork' button near the top of the page and then press the 'Update Branch' button. Once that's done, press the 'Fetch Origin' button on your Github Desktop client and after it completes that action it should prompt your to 'Pull' the newest updates which will bring your code back up to date with /vg/.

#### Contributing Code

To contribute code updates to /vg/, open your Github Desktop client and from the 'Branch' dropdown menu, select 'New Branch'. Give this new branch a name that reflects what you're looking to change or update. From the main screen, press the 'Publish Branch' button to add it to your repo. From there, it's simply a matter of editing the files you wish to change in your editor of choice. By pressing the 'Commit' button on Github Desktop, you save your current changes to your branch and then press 'Push Origin' to upload them to your online repository which means you can change branch to another project should you need to without losing any of your work. Once you've committed all the changes you wanted and have tested your work, you can press the 'Preview Pull Request' button to see a summary of all the changes you've made, then 'Create Pull Request' to submit your proposed changes to Github for review by the Collaborators in charge of the master codebase.

#### Branches

Keep in mind that we have multiple branches for various purposes.

* *Bleeding-Edge* - The latest code, this code is run on the main server.  _Please do any development against this branch!_
* *master* - "stable" but ancient code, it was used on the main server until we realized we like living on the edge  :sunglasses:.

### INSTALLATION

First-time installation should be fairly straightforward.  First, you'll need BYOND installed.  You can get it from [here](http://www.byond.com/).

This is a sourcecode-only release, so the next step is to compile the server files.  Open vgstation13.dme by double-clicking it, open the Build menu, and click compile.  This'll take a little while, and if everything's done right you'll get a message like this:

    saving vgstation13.dmb (DEBUG mode)

    vgstation13.dmb - 0 errors, 0 warnings

If you see any errors or warnings, something has gone wrong - possibly a corrupt download or the files extracted wrong, or a code issue on the main repo.  Ask on IRC.

To use the SQLite preferences, rename players2_empty.sqlite to players2.sqlite

Next, copy everything from config-example/ to config/ so you have some default configuration.

Once that's done, open up the config folder.  You'll want to edit config.txt to set the probabilities for different gamemodes in Secret and to set your server location so that all your players don't get disconnected at the end of each round.  It's recommended you don't turn on the gamemodes with probability 0, as they have various issues and aren't currently being tested, so they may have unknown and bizarre bugs.

You'll also want to edit admins.txt to remove the default admins and add your own.  "Host" is the highest level of access, and the other recommended admin levels for now are "Game Master", "Game Admin" and "Moderator".  The format is:

    byondkey - Rank

where the BYOND key must be in lowercase and the admin rank must be properly capitalized.  There are a bunch more admin ranks, but these two should be enough for most servers, assuming you have trustworthy admins.

Finally, to start the server, run Dream Daemon and enter the path to your compiled vgstation13.dmb file.  Make sure to set the port to the one you  specified in the config.txt, and set the Security box to 'Trusted'.  Then press GO and the server should start up and be ready to join.

---

### Configuration

For a basic setup, simply copy every file from config-example/ to config/ and then add yourself as admin via `admins.txt`.

---

### SQL Setup

The SQL backend for the library and stats tracking requires a MySQL server.  (Linux servers will need to put libmysql.so into the same directory as vgstation13.dme.)  Your server details go in /config/dbconfig.txt.

The database is automatically installed during server startup, but you need to ensure the database and user are present and have necessary permissions.

---

### IRC Bot Setup

Included in the repo is an IRC bot capable of relaying adminhelps to a specified IRC channel/server (replaces the older one by Skibiliano).  Instructions for bot setup are included in the /bot/ folder along with the bot/relay script itself.

---

### LICENSE

All code is licensed under the [GNU GPL v3.0](https://www.gnu.org/licenses/gpl-3.0.html) unless specified otherwise.

TGUI and the tgstation-server DMAPI are licensed under the MIT license.

Goonchat is licensed under [CC BY-NC-SA 3.0](http://creativecommons.org/licenses/by-nc-sa/3.0/us/).

Assets, including icons and sounds, are licensed under [CC BY-SA 3.0](http://creativecommons.org/licenses/by-sa/3.0/us/) unless specified otherwise.
