# My Storm Sounds

<img src="https://github.com/tuppaware/my-storm-sounds/blob/main/My%20Storm/Assets.xcassets/icon_transparent.imageset/icon_transparent.png" width="250" height="250">

This project is an example project created on the back of the API used in the iOS app [Infinite Storm](https://apps.apple.com/app/id576664798) using similar data-structure and sharing common functionality.  It pulls a json data feed of available sounds to download and then once downloaded lets you play various _relaxing and pleasing_ sounds, many based on various forms of white noise using rain.

This app was created as a demonstration of my general programming skills in iOS development, obviously not the limit or full list of my skills and I plan to add various features over time. The backend API also was created by me and is running on a Lumen (aka Laravel) framework. 

## Structure and Design 

The project uses a MVP design pattern allowing the business logic of the views to be kept in the presenter and seperated from the view logic. In the cases on collection-views the cells have their own logic that is generally kept local to the cell scope. 

API functions and data retrieval are handled in singletons for ease of use, data is stored in extended objects stored within UserDefaults. In a larger/more complex/more secure environment this data could be stored in keychain or core data.

Views are based in xib files rather than storyboards which is a more team friendly and easier way to handle growing projects. 

## Installing
Clone the repo first :-P

do a test thing

The project currently uses Cocoapods for dependancy management, to run the application clone/download the repo and run:
```
pod install
```
Making sure that you have [Cocoapods](https://cocoapods.org) installed. 

## Todo

- (Feature) Volume Control per sound.
- (Tool-chain) Move to Swift Package Manager rather than CocoaPods.
- (Testing) Add ui-tests and unit-tests.

## Contact Me

If you've gotten this far its likely I sent you here. 
Email me at tuppaware at gmail dot com ;-)
