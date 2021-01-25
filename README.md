# Jayden Garrick

![alt text](https://i.imgur.com/9F7nuJd.png)


## Build Tools & Versions Used
This was developed on _Xcode 12.1_ using _Swift 5_

## Focus Areas
* The biggest focus-area for me is probably the architecture and testability of the app. 
* I tried to leverage dependency injection as much as possible in order to be able to mock out as many dependecies as possible for UI testing.
* I tried to follow SOLID principles, and break out logic into workable modular pieces with a MVP with POP + Coordinator approach.
* I also tried to be efficient with my networking resources and do simple cacheing where available.

## Approach
The approach I took was MVP with POP (Protocol Oriented Programming) + Coordinators and Navigators. I tried to separate my dependencies out into interfaces so I can easily mock them out for efficient Unit Testing. 

## Findings / Notes
* Adding call / email functionality was surprisingly easy, and I thought it'd be a cool idea since the API gives you back a phone number and an email address.
* Ideally I wouldn't use IB / Storyboard. I didn't want to spend a ton of time on the UI (given I also didn't have designs to work off of), I find that IB is good for quickly throwing something together. 
* I tried something new for me that I hope to implement in some personal projects, and that was sending the low-res image to the detail view, and using that image as a placeholder while fetching the high-res image. Typically I would just put a generic placehodlder while fetching the high res, but I realized that the low res already exists.

## How Long I Spent on the Project
I spent roughly 6 hours on the project... I said I was done about 4 hours in, and I could've probably submitted what I had, but I kind of got carried away writing code in Native again (been doing some Flutter / CI/CD stuff at my current company), and I had a lot of fun adding stuff in

## Code That Was Already Written
The two biggest pieces of code I pasted in were the protocols inside `NetworkingProtocols.swift` and the `Coordinator.swift` protocols. The actual implementation of these protocols I did custom though. This was code written fairly recently for a coding challenge I did not too long ago. 

## If I Had More Time
* I wanted to add unit tests to the networking client + image stuff, unfortunately I ran out of time, and I hope my presenter tests show my unit test competency
* The detail view controller could probably be cleaned up a bit - I was running out of time to work on this so I kind of quickly whipped it together. 
* I'd want to fix up the UX a bit - add some kind of indicator to the "searching" header when the callback comes back empty or with an error.
