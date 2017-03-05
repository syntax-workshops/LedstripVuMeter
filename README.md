# Led strip VU Meter

This app turns your ws2812b Nodemcu powered LED strip into an awesome VU meter for parties! [Demo](http://i.imgur.com/67VBxJO.gif)

It was hacked together in a couple of hours, so the code isn't super pretty or finished.

The hardware setup is described [on workshop.syntaxleiden.nl](http://workshop.syntaxleiden.nl/ledstrip-esp8266-guide.html). This project assumes you have this kind of a setup.

## Installation

This project uses Swift 3 and Xcode 8.2.

1. Download/clone the project and open it in Xcode
2. Edit the `ipAddress` and `count` parameters in `AppDelegate.swift` to match your LED strip. A PR that adds UI controls for this is welcome!
3. Select your device and press the ► button

## License

MIT
