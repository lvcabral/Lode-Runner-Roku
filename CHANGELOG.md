## Lode Runner Changelog

### v0.16 15-July-2019 - Removed Deprecated SDK v1 Objects

* Change: Game code do not rely anymore on deprecated SDK v1 objects #47

### v0.15 22-Aug-2017 - Fixes and Improvements

* Add: Performance improvements #42
* Fix: Background flickering on some devices #43
* Fix: Crash when adding name to high score #44

### v0.14 11-Feb-2017 - NES Sprite Mode, improved animations

* Add: NES Sprite Mode #39
* Fix: Runner and guards run animations have a missing frame #40
* Fix: Hole and shake timing are not matching original game #20
* Fix: Rebirth animation not implemented #41

### v0.13 - 12-Nov-2016 - Improved Performance

* Fix: Poor performance on low end devices caused by DrawStatusBar() #37

### v0.12 - 03-Oct-2016 - Test Custom Level inside Editor

* Add: Allow test level inside the editor #34
* Change: Game remote key does not repeat on level editor #35
* Fix: Level editor has poor performance on low end devices #33
* Fix: The image thumbnails are painting the hidden ladders #36

### v0.11 - 01-Oct-2016 - Start Level Selection and Dynamic Map Thumbnails

* Add: Custom Level Editor #28
* Change: The button pressed to start level shall start executing the action relative to it #29
* Change: Keys REW and FF should move the menu to first and last items #30

### v0.10 - 30-Sep-2016 - Start Level Selection and Dynamic Map Thumbnails

* Add: Option to select Start Level
* Fix: Runner is not falling when starts the level with no floor below him (L150) #19
* Fix: Two Guards got stuck in the wall at the top left in Level 6 after rebirth #21
* Fix: Dig should not be possible if guard is too close #14 (reopened)
* Fix: Sometimes a guard get stuck in front of the runner without killing him #17
* Fix: Runner is dying when walking over the guards #27

### v0.9 - 26-Sep-2016 - Save Game and High Scores

* Add: Save game status and option to restore at the start #3
* Add: Save and display High Scores for each version #2
* Change: Remote keys reorganization
* Change: Use dynamic thumbnails on Version menu option #26
* Fix: 75 Points should be added when a guard falls into a hole and also when it dies #16
* Fix: Handle correctly the end of game (complete last level) #15
* Fix: Sound effects are not overlapping #9
* Fix: Dig should not be possible if guard is too close #14
* Fix: Kid moving down from a ladder with a space before a brick starts falling #12
* Fix: Using the button to restart the level should remove one life #25
* Fix: The game becomes slower after the last gold is taken and the exit ladder is shown #24
* Fix: Hidden ladder do not act like a real ladder so Level 11 can't be finished #23
* Fix: Crash when a guard is climbing a ladder until the top of the screen #22

### v0.8 - 23-Sep-2016 - Original Guards AI, Sound Effects, ZX Spectrum sprites and Speed Configuration

* Add: Ported original guards AI
* Add: Sounds effects support
* Add: Speed Configuration
* Add: Credits Screen
* Add: Sinclair ZX Spectrum sprites
* Fix: Issues with low end Roku devices (list screen not cleared, fade-in flicks, performance)
* Fix: Gold should be released just when guard falls in hole
* Fix: Runner dies with any key at level start

### v0.7 - 17-Sep-2016 - Improved graphics and guard at hole update

* Add: Guard exit hole (when have time)
* Add: Pause text at the center of the screen
* Add: New logo graphics, updated splash
* Add: Flags for debugging (stopGuards & immortal)
* Update: Randomize do not repeat consecutive sprite modes
* Fix: Falling on top of guards should not kill runner
* Fix: Sometimes Guards not showing after complete
* Fix: Sometimes when starting a level any key just kills the runner - #7

### v0.6 - 16-Sep-2016 - Simple Guards AI, Cheat Keys and Pause

* Add: Simple Guards AI to validate animation
* Add: Runner death with guards
* Add: Cheat keys configuration (level or health)
* Add: Allow Pause the game
* Fix: Intro screen and Game Over not supporting Randomize Mode
* Fix: Game over image wrong on IBM-PC mode
* Fix: Sometimes Key get locked in one direction
* Fix: Climb ladder into a brick
* Fix: Complete level should be in blockY=0 and offsetY=0

### v0.5 - 15-Sep-2016 - New skins and refactored char abstraction

* Add: Additional graphics: IBM PC, Atari 8 bits
* Add: Option to randomize graphics
* Refactor: Abstracted common behavior and properties in charActor

### v0.4 - 14-Sep-2016 - Level Startup, Runner Death in Hole and Game Over

* Add: level startup fade in and flashing runner
* Add: Score animation when complete level
* Add: Runner death on hole
* Add: Game Over when there's no remaining life
* Fix: Hole fill time is too quick
* Fix: Back key on Menu is starting the game

### v0.3 - 13-Sep-2016 - Runner Fall and Dig

* Add: Runner animation (fall empty and trap)
* Add: Runner animation (dig left, dig right)

### v0.2 - 12-Sep-2016 - Menu and Runner Basic Animations

* Add: Main Menu
* Add: Runner animation (run left, run right)
* Add: Runner animation (up, down)
* Add: Runner animation (bar left, bar right)
* Add: Collect gold
* Add: Show exit latter when all gold is collected
* Add: Change to next level when hit the top

### v0.1 - 10-Sep-2016 - Initial Version

* Add: Level map loading
* Add: Paint Level Map
* Add: Splash screen
* Add: Start screen
* Add: Two set of sprites: Commodore 64 and Apple II (config still hard coded)
