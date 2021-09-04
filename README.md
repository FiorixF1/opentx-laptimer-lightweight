# OpenTX Laptimer Lightweight

This is a very simple laptimer for those who enjoy racing in a field with multicopters and wish to know how much fast they are!

The project was actually made by [RCdiy](https://github.com/RCdiy), but since it has been discontinued, it is not compatible with modern transmitters anymore.

I took some time to make it compatible with the latest firmware of OpenTX 2.3 for the popular transmitter Radiomaster TX16S.

The way it works is so simple: it uses a logic or physical switch to decide when to begin recording and another logical or physical switch to stop the recording of the current lap and start the next one.

You have to set these two switches inside the `LapTmr.lua` file, where more details are presented. The advice is to use a logical switch that is triggered when throttle is above zero as a way to begin the recording and the momentary switch SH to record the time of a single lap.

Have fun!
