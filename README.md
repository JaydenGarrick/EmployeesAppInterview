# Jayden Garrick

## Approach
The approach I took was MVP with POP (Protocol Oriented Programming). I tried to separate my dependencies out into interfaces so I can easily mock them out for efficient Unit Testing. 

## Findings / Notes
* Adding call / email functionality was surprisingly easy, and I thought it'd be a cool idea since the API gives you back a phone number and an email address.
* Ideally I wouldn't use IB / Storyboard. I didn't want to spend a ton of time on the UI (given I also didn't have designs to work off of), I find that IB is good for quickly throwing something together. 
* Ideally too I would have add a coordinator to handle navigation, however with such a simple project I decided to bypass that idea and just push the detail VC in the `EmployeesCollectionViewController`
* I tried something new for me that I hope to implement in some personal projects, and that was sending the low-res image to the detail view, and using that image as a placeholder while fetching the high-res image. Typically I would just put a generic placehodlder while fetching the high res, but I realized that the low res already exists.

## If I Had More Time
* I wanted to add unit tests to the networking client + image stuff, unfortunately I ran out of time, and I hope my presenter tests show my unit test competency
* The detail view controller could probably be cleaned up a bit - I was running out of time to work on this so I kind of quickly whipped it together. 
* I'd want to fix up the UX a bit - add some kind of indicator to the "searching" header when the callback comes back empty or with an error
