#####v0.7 - 17-Sep-2016 - Improved graphics and guard at hole update
* Add: Guard exit hole (when have time)
* Add: Pause text at the center of the screen
* Add: New logo graphics, updated splash
* Add: Flags for debugging (stopGuards & immortal)
* Update: Randomize do not repeat consecutive sprite modes
* Fix: Falling on top of guards should not kill runner
* Fix: Sometimes Guards not showing after complete
* Fix: Sometimes when starting a level any key just kills the runner #7

#####v0.6 - 16-Sep-2016 - Simple Guards AI, Sounds and Credits
* Add: Simple Guards AI to validate animation
* Add: Runner death with guards
* Add: Cheat keys configuration (level or health)
* Add: Allow Pause the game
* Fix: Intro screen and Game Over not supporting Randomize Mode
* Fix: Game over image wrong on IBM-PC mode
* Fix: Sometimes Key get locked in one direction
* Fix: Climb ladder into a brick
* Fix: Complete level should be in blockY=0 and offsetY=0

#####v0.5 - 15-Sep-2016 - New skins, Pause and refactored char abstraction
* Add: Additional graphics: IBM PC, Atari 8 bits
* Add: Option to randomize graphics
* Refactor: Abstracted common behavior and properties in charActor

#####v0.4 - 14-Sep-2016 - Level Startup, Runner Death in Hole and Game Over
* Add: level startup fade in and flashing runner
* Add: Score animation when complete level
* Add: Runner death on hole
* Add: Game Over when there's no remaining life
* Fix: Hole fill time is too quick
* Fix: Back key on Menu is starting the game

#####v0.3 - 13-Sep-2016 - Runner Fall and Dig
* Add: Runner animation (fall empty and trap)
* Add: Runner animation (dig left, dig right)

#####v0.2 - 12-Sep-2016 - Menu and Runner Basic Animations
* Add: Main Menu
* Add: Runner animation (run left, run right)
* Add: Runner animation (up, down)
* Add: Runner animation (bar left, bar right)
* Add: Collect gold
* Add: Show exit latter when all gold is collected
* Add: Change to next level when hit the top

#####v0.1 - 10-Sep-2016 - Initial Version
* Add: Level map loading
* Add: Paint Level Map
* Add: Splash screen
* Add: Start screen
* Add: Two set of sprites: Commodore 64 and Apple II (config still hard coded)
