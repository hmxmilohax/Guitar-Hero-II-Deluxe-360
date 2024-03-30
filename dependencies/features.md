# Features

* No strum limit executable.

* In game readouts tracking FC, Note Streak, Overstrums, Missed Notes, Song Progress, Stars, Star Progress.

* Drums support including beta drum gems.

* "Overshell" - a custom on screen menu system for changing modifiers/speeds/themes/colors/characters/venues etc. Opened by pressing `Select Select` on most menu screens. You may just want to get in the habit of spamming select.

* User generated, sharable, ini-like config files to customize the look and feel of the ui, and in game track.

* An increasing selection of modifiers allowing tuning of how you want to play. These modifiers can also be setup as defaults.

* Randomized (or forced) Characters, Venues, and Guitars per song.

* Overhauled menus with additional features.

* Unlimited setlist scrolling. **Saving will be disabled after 241 (250 total) songs are loaded.**

* Modern Star calculation.

* Feature complete on both Xbox 360 Hardware and Xenia Emulator.

* No overscan by default (requires separate XEX)

* PS2 port in the works (currently unplayable).

# Modifiers

* Focus Mode - Blacks out the in-game Venue to focus on gameplay. Upon enabling, the intro/outro animations will be disabled, note streak popups will be disabled, and certain sound effects will be disabled.

* Whammy FX - Disables the pitch shift applied when using the whammy on sustains.

* Track Muting - Disables muting of the currently played instrument when notes are missed.

* No Flames - Removes flame animation on note hits.

* No Fail - Disables failing out of a song.

* Autoplay - Enables the Bot in game. Certain measures have been taken to discourage abuse.

* Tight Speedups - Keeps the default tightening of the engine that occurs when using in-engine speedups.

* Towel Hyperspeed - Mimicks old school Guitar Hero 1 gameplay of the same name, with no towel required. This will lock your track speed to 100%, and notes will be invisible until roughly the middle of the highway.

* Brutal Mode - A poor man's representation of the Rock Band 4 feature of the same name. Notes disappear as they travel down the track. However, the line in which they disappear does not move dynamically, and sustain notes do not disappear.

* Select to restart - Star Power is enabled in practice mode for SP pathing. This modifier will allow you to instead use the select button to reset the current section.

* Name Title - Displays the users given title below the fret smashers in game.

* Song Title Always - Always displays the song info display, this includes the Notes Missed and Overstrums readout.

* Clean MTV - Only displays song title, artist name, and if available, author on the song info display.

* Less Beat Lines - Removes quarter beat lines from the track for a more cleaner amount of beatlines.

* No Division Lines - removes the "strings" verticle lines between frets on the highway.

* Skip Intro - Skips the intro fly in animation when starting a song.

* Skip Outro - Skips the outro win animation when completing a song.

* Force Encore - Forces the current song to act as an encore, gives unique intro camera animation.

* Sound Effects - Disables certain sound effects such as the crowd in game.

* Note Streak Popups - Disables the note streak interval message popups in game.

* Star Power Popup - Disables the "Star Power Ready" message popups in game.

* Highway Shake - Disables the Highway shake on note miss and Star Power deployment. This is required for Clone Hero Hud/skinny highway.

* Monkey Head - The vanilla Monkey Crowd Head cheat.

* Eyeball Head - The vanilla Eyeball Crowd Head cheat.

* Flaming Head - The vanilla Flaming Head cheat.

* Performance Mode - The vanilla performance mode cheat. Combine with autoplay for venue captures.

* Neckless Mode - Removes only the highway in-game, leaving the score meter, crowd meter, and SP bar.

* Roxbury Mode - Hidden away in the vanilla files, this cheat rocks the track on beat in game. Named from the movie "A Night at the Roxbury", referencing the head bob characters in the movie perform.

# Track Modifiers

* Void Frets - Blacks out the inner portion of the fret smasher

![void_frets](dependencies/images/void_frets.png)

* Eyeball Gems - Tucked away in the vanilla files, this applies an eyeball texture to the gems.

![eyeball_gems](dependencies/images/eyeball_gems.png)

* Clone Hero Hud - Changes many aspects of the on screen track. Provides a Clone Hero/WoR Crowd meter, score meter, star power bar, and streak display.

![clonehero_hud](dependencies/images/clonehero_hud.png)

* Bright HOPOs - Applies a new texture to the hopo gems to fully white out the caps. Helps distinguish hopos from strums.

![bright_hopos](dependencies/images/bright_hopos.png)

* Dark Strums - Applies a new texture to the strum gems to darken the white portions of the gems. Helps distinguish strums from hopos.

![dark_strums](dependencies/images/dark_strums.png)

* GH1 Track - Port of the Guitar Hero 1 Gems and Smashers. These will produce a stutter on first load as shaders are being generated for the 3d models.

![gh1_track](dependencies/images/gh1_track.png)

* GH3 Frets - Custom textured fret smashers ripped from Guitar Hero III.

![gh3_frets](dependencies/images/gh3_frets.png)

# In-Depth Features

## Overshell

Opened by pressing `Select Select` on most menu screens. Overshell is the primary way to customize all aspects of Guitar Hero II Deluxe from within the game. Overshell contains submenus and sometimes even helpful tips as you set new modifications. Some Overshell screens even graphically show you the current selection.

Difficulty - Opens the difficulty menu. This is also where you can set lefty flip.

Color Selector - Opens the color picker menu for various ui elements. Inside is a "Pick Element" button with a list of customizable ui elements. You cannot save these selections from in game for subsequent reboots.

Speed Settings - Opens a slider menu to choose Track Speed, Song Speed, Venue FPS, as well as a shortcut to turning on Focus Mode.

Modifiers - Opens the Modifiers sub-menu. This menu also contains the Select Highway, Select Font, and Track Modifiers sub-menus.

Venue Select - Menu to force a selected venue.

Character Select - Menu to force a selected character.

Guitar Select - Menu to force a selected guitar.

Theme Select - Menu to choose the current UI theme.

Audio Options - The vanilla Audio Options screen for volume adjustments.

![Overshell](dependencies/images/overshell.png)

## Song Select

The Select Song screen has been re-worked to allow a theoretical infinite amount of songs to be scrolled through.

However, a big drawback is the save file is limited to a total of 250 songs saved before the save will no longer load. To combat this, saving is automatically disabled if the amount of songs loaded exceeds 250 songs.

Guitar Hero II Deluxe technically uses career mode for quickplay gameplay, as such, scores will be shown on the song select screen.

A random song button is also included on the song select screen to shuffle the library.

Additionally, detailed song information in the style of RB/CH is available for DX songs out of the box. As of writing, Onyx support to output this information for dx on new conversions, is currently in development. Some specific artists, namely Harmonix and Neversoft, have custom colors for their author name.

Potential detailed song information includes

* Artist
* Author
* Album
* Year
* Genre
* Origin
* Difficulty
* Length

![detailed_song](dependencies/images/detailed_song.png)

Previously converted tracks for gh2dx will not have this information unless manually applied.

Album art is also supported via a bmp_xbox (512x512) or bmp_ps2 (256x256) image file in the song folder, in a `gen` subfolder. The image should be named exactly the same as the shortname of the song. Ex:

* _xenia\content\415607E7\00000002\GHIIDX\songs\arterialblack\arterialblack.bmp_xbox

The build scripts will automatically detect album art in the `/Content/` directories for your song, and generate them where they need to go.

These images are read in game from outside of the ARK as raw files. An `album_art` folder will be generated in `_build/Xbox` that contains these images for you.

This image generation support is also planned to be coming in a future Onyx update.

![Song Select](dependencies/images/songselect.png)

## Endgame Screen

The endgame screen has seen some layout changes to make room for some new upgrades.

Average Multiplier, SP Phrases, and Notes Hit are now found on this screen, rather than the section stats screen.

Stars now show a more detailed readout, tracking to the hundredths place.

Notes Hit Percentage now shows a more detailed readout, tracking to the hundredths place.

Various modifier status is reported on screen to give indication on how the player prefers to play.

![Endgame Screen](dependencies/images/endgame.png)

## Themes

Theming of a good chunk of UI and Track items is supported in Guitar Hero II Deluxe.

This can be accomplished by modifying `_theme/init_track_theme.dta` or `_theme/init_ui_theme.dta`.

Inside both of these scripts are a variety of options to choose from and change colors for your own personalized track theme or ui theme for the game.

![init_themes](dependencies/images/init_themes.png)

Once done editing the dta file to your liking, or installing one found from #gh2-theme-share channel in the Milohax discord, run `_theme-dta2b.bat` from the root of the repo.

Theme dta files can be shared and transferred between installations just like clone here ini's. Just run `_theme-dta2b.bat` after aquiring your theme dta.

Re-running Xenia will apply your changes, or, if on hardware, simply copy the two new `.dtb` files from the `_build/Xbox/gen` folder to the same location on your Xbox.

The different menu themes in Guitar Hero 2 Deluxe all utilize this theme system for their respective themes, so there is a great variety to choose from!

![UI-theme](dependencies/images/theme_ui.png)

![theme_track](dependencies/images/theme_track.png)

## Init/Setting Custom Defaults

Custom defaults, such as always setting your preferred track speed, are not saved automatically by Guitar Hero II Deluxe.

Instead, you will have to manually edit a file or two and rebuild the game to save your custom modifiers.

This has been setup to be as easy as possible.

Simply open `_ark/ui/init.dta` and start editing to your liking. Each modifier has an associated comment paired with it to detail it's functions. Theming options can be found above, reading the `Themes` section of this readme.

![init_init](dependencies/images/init_init.png)

Once done, save the edited dta, and build the ark again. If playing on real hardware, you will have to transfer the entire ark to your Xbox again for the new saved settings.

Editing init.dta will cause conflicts down the road if the file is changed on the repo. if you are having trouble getting new features when building the arks, run `_reset.bat` to restore the repo to a clean state, and build again.
