# tactics.p8

An attempt to create a turn-based tactics game for the [PICO-8 fantasy console](http://www.lexaloffle.com/pico-8.php), similar in spirit to something like Fire Emblem, Shining Force, or Final Fantasy Tactics. My hope is that PICO-8's harsh code size limitations will keep this project small and focused so it has a fighting chance of being finished one day.

This project is still very much in its infancy. I've been focusing on getting the code in place first. So far it has:

- A grid system with a selection cursor.
- Unit archetypes with their own sprites, speed, and attack range attributes.
- The ability to explore possible spaces to move based on unit speed and environmental obstacles.
- The ability to determine possible attack targets given a minimum and maximum attack range.
- A battle animation sequence showing each unit's stats.

Here are how things look so far:

![Moving and Fighting](http://i.imgur.com/O39mhb0.gif)
*Explore possible moves (blue) find possible
attacks (yellow) and initiate battle.*

I've written about some of the challenges I've encountered at [my game development blog](http://www.craigstephenson.us/blog/category/game-development/). Stay tuned for more!
