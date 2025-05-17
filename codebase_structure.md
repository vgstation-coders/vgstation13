### Rough map of the codebase

SS13 is an old game with origin shrouded in myth, built on the back of hundreds of contributors across more than a decade, often working in different teams using different standards.
The engine it is built on allows a surprising amount of code decentralisation. As a result, the code is scattered and sometimes a bit confusing to read.

This file offers a rough map of the codebase, explainig what each folder does.

As this codebase uses different languages and tools, the folders can be divided in the following categeories:

	- `DM`: contains code written in the DM language, which is what players in the game interact with.
	- `Resources`: contains icons, sounds, or another media related to the game.
	- `Game files`: contains files produced by the game, such as logs.
	- `External tool`: contains a tool using non-DM language which players interact with.
	- `Build tool`: contains a tool which is used to build the project or in development.

#### Top level folder

	- `__odlint.dm`. **Type:** Build tool. Enables linter warnings in the OpenDream compile.
	- `.editorconfig`. *Deprecated*. Configures how Atom (an older editor) displayed DM code. Irrelevant if you use VSCode.
	- `BUILD.cmd`. **Type:** Build tool. Script for the compile process in VSCode.
	- `cleanLogs.bat`. This script calls a Python script to clear public logs of IP addresses. Used in production mode.
	- `README.md`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `codebase_structure.md`, `LICENCE`, `GPLv3.txt`. Documentation, coding practice and licencing files*.
	- `dependencies.sh`. **Type:** Build tool. This script is used to get the right version of Node.js, Python, and other external tools needed for the build process.
	- `players2_empty.sqlite` **Type**: Game files. This is the database BYOND uses to store player characters and preferences. It is accessed using BYOND internal procs. It does *not* contain bans, admins, or connection logs, which are stored using an external database.
	- `rust_g.dll`, `rust_g_old.dll`. **Type**: External tool. These DLLs are called in the DM code to handle operations which are expensive in DM but that players do not need to see results right away, such as *database operations*.
	- `SpacemanDMM.toml`. **Type:** Build tool. This is a configuration file for the integrated debugger mostly used when working with VSCode. It also enables live-debugging of the code with auxtools.
	- `.gitignore`, etc: Git files used to configure how git interacts with the project. `.gitignore` for example ignores changes to logs.
	- `vgstation13.dme`: **Type:** DM. This file contains `includes` to all the DM files that constitute your project.

#### Main folders

##### __DEFINES

**Type:** DM. This files contains macros, defines (used in place of `Enums`, which DM does not have), as well as global lists which are used in the rest of the codebase. It may also contains global procs.

- `__compile_options.dm`: Can be edited to toggle unit tests running locally, or switch to a desired map without changing the `.dme`
- `macros.dm`: Contains macros used extensively in the codebase.

##### .github

**Type:** Build tool. Contains templates for pull requests, issues, and workflows for Continous Integration using Github actions.

##### .vscode

**Type:** Build tool. Files contains configuration parameters for VSCode build tasks.

##### bin

**Type:** Build tool. Contains `.bat` files which are used in the VSCode build process to build TGUI or other tools such as the TGUI Debug server.

##### code

**Type:** DM. Contains the main DM code running on the server.

##### Config

**Type:** Game files. By default, contains gameplay-related configuation settings, such as default names and access.

##### Config-example

**Type:** Game files. Default configuration settings for the server. Copy those files in the `Config` folder.

##### Data

**Type:** Game files. Contains logs produced by the game. Git ignores these by default;

##### Docs

Contains documentation related to the code. Currently only contains a diagram explaining the logical flow of SayCode.

##### Goon

**Type:** DM. This folder exists for historical reasons when some code from the Goonstation leak in 2016 was used in the game.

- `code/datums/browserOutput.dm`: Code for Goonchat, the chat displaying HTML in your browser window.
- `code/obj/machinery/bot/chefbot.dm`: Code for Chef RAMsay, the bot in the Kitchen.

##### html

**Type:** Resources. Contains assets used in the game such as the changelog, icons and the admin panel. TGUI assets and NanoUI assets are in *different* folders.

- `font-awesome`: The free asset library we use for icons in NanoUI and TGUI.
- `changlogs`: Exists for historical reasons. The actual changelog generation is now automated.

##### icons

**Type:** Resources. Contains most `.dmi` icons used in the game.

##### interface

**Type:** Game files. This contains the `.dmf` keymaps used to interact in the game. A key can be associated to a verb. Users can supplement these mappings with macros or entirely redefine them. Contains a `skin_azerty.dmf` as a template for AZERTY keyboard users. Also defines how the right-side panel of the game looks.

##### maprendering

**Type:** Build tool. This module contains a proc which exports a high-definition `.png` render of the current map. Due to heavy lag it should not be used in production.

##### maps

**Type:** DM. This contains all the maps currently in rotation, vaults, and away missions.

- `_map.dm`: The protoype `/datum/map`, which contains documentation on map datums.
- `[example_map].dm`: Contains an `/datum/map/active` which defines the example map properties.
- `[example_map].dmm`: The actual map in DreamMaker or SpaceManDMM. Uses SpacemanDMM format.

##### nano

**Type:** Resources. Contains all assets related to NanoUI.

- `templates`: Contains the interfaces seen by players.

##### scripts

**Type:** Build tool/external tool. Contains Python scripts to automate some workflow in development*.

- `copy_logs.dm`: The script ran automatically by the server to clean logs of IP addresses and copy them to a public hosting page.

##### sound

**Type:** Resources. Contains all sound files used by the game, such as ambiant music, sound effects. Does *not* contain streamed/jukebox music, which is hosted seperately and is streamed synchronously to all players.

##### SQL

**Type:** Game files. SQL schemas for the database used in the game. These schemas should be kept up to date with the current version of the game.

##### TGUI

**Type:** External tool. Self-contained folder containing all the non-DM elements of TGUI interfaces, including the `.yarn` package manager.

- `packages/tgui/interfaces`: Contains the interfaces seen by players.

##### tmp

This folder is empty and is used by tools to create temporary files.

##### tools

**Type:** Build tool. Contains all the build tools as well as some script to automate workflow on the codebase.

#### `code` folder

##### __HELPERS

- Various helpers procs and macros used in the codebase. `lists.dm`, `logging.dm`, `game.dm` and `misc.dm` are the most commonly used.
- `math`: Folder containing vector and raycasting code.

##### _hooks

- Contains code related to "events", which are our codebase to dynamically link two datums at runtime.

##### _onlick

- All code related to clicking on things, including Alt-Click, Control-Click, and overrides such as telekinesis, mutual cuffing, drag and drop, and blob overmind controls.

##### ~secrets

- *Deprecated.* For secret repo includes.

##### controllers

- Contains code for various core features of the game (such as the emergency shuttle, radios, and configuration).
- `mc`: the "master controller" which periodically ticks to update processing objects, UIs, and machinery. It can pause itself in case of lag.
- `subsystem`: various subsystems for compartimentalising features of the game that should be updated by the master controller.

##### datums

- Contains code for data structures which are used by the game mechanics.
- `gamemode`: contains basic datums for role and faction datums. Content should go in `game/gamemodes`

##### game

- Contains the core code for the main content of the game.

Folders:

- `adminbus_events`: for content specifically needed for certain events.
- `area`: specifies all areas used in the game. Areas are used in mapping.
- `gamemodes`: contains all gamemode and role-specific content.
- `machinery`: contains definition and mechanics for machinery in the game that does not fit into more thematic `modules`.
- `objects`: contains definition and mechanics for objects in the game that does not fit into more thematic `modules`.
- `procs`: global procs used for mechanics, such as command alerts, biohazard alerts, and captain announcements.
- `turf`: base code and definitions for floors used in the game.
- `verbs`: basic verbs. Contain `OOC`, `Suicide`, and `Who`.

Files:

- `atoms_movable.dm`: definitions for atom movables and movement procs.
- `atoms.dm`: definition for basic atoms. Contains beam code, bumping, and basic `_act` procs such as `emp_act`, `bullet_act`.

##### js

- Contains an implementation of JS to dynamically change BYOND HTML pages. Mostly *deprecated* now due to NanoUI, TGUI, and HTML Interfaces.
- Currently only used in mech code.

##### libs

Various libraries from other BYOND projects.

- `Get Flat Icon`: a proc that converts what a player sees (including overlays, underlays, etc) into a `/icon` object.

##### modules

Thematic folders containing code for various features of the game that takes too much space for it to be in the `game` folder.
Modules to note:

- `dna`: Contains all code related to human apperance and power modification by genetics.
- `admin`: Contains all admin-related code.
- `migrations`: DM files that will automatically run SQL commands to update database schemas to meet what the code expects.
- `mob`: Contains inventory code, hostile simple mob code, species code.
- `jobs`: Contains code related to job assignement at roundstart
- `html_interface`: Code for browser datums, the painting tool, and the roundstart map voting.
- `nano`: All nanoUI DM-side code.
- `tgui`: All TGUI DM-side code.
- `client`: Contains preferences, ban-checking, asset sending.
