# OpenTX Laptimer Lightweight

This is a basic laptimer for those who enjoy racing in a field with multicopters and wish to know how much fast they are!

The project was actually made by [RCdiy](https://github.com/RCdiy), but since it has been discontinued, it is not compatible with modern transmitters anymore.

I took some time to make it compatible with the latest firmware of OpenTX 2.3 for the popular transmitter Radiomaster TX16S.

The way it works is so simple: it uses a logical or physical switch to activate the timer and another logical or physical switch to record the current lap and start the next one.

## Installation

1. Copy the folders `SCRIPTS` and `WIDGETS` into your SD card.
2. Configure the logical switch `ls1` on your radio as `a>x, THR, -100`.
3. Create a new tab on your model screen and add `LapTmr` as widget. This way the script will keep running in the background.

The timer will be activated every time you raise the throttle. Use the momentary switch `SH` to record the current lap and start the next one. Move the switch when the throttle is idle to reset the timer.

This is enough for many usecases and won't be developed anymore. If you are looking for a more advanced laptimer, check [this](https://github.com/FiorixF1/opentx-laptimer) out. Have fun!

