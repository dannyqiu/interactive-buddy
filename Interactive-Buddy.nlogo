globals [mouse-oldx mouse-oldy mouse-speed
  weapon weapon-number
  weapons weapons-cost
  weapons-bought score money buddy-emotion
  old-weapon old-drawing]
extensions [sound]

breed [buddies buddy]
breed [tickles tickle]
breed [punches punch]
breed [pistols pistol]
breed [machine-guns machine-gun]
breed [shotguns shotgun]
breed [flame-throwers flame-thrower]
breed [hoses hose]
breed [rocket-launchers rocket-launcher]
breed [grenade-launchers grenade-launcher]
breed [bows bow]
breed [hands hand]
breed [god-hands god-hand]
breed [bullets bullet]
breed [fireballs fireball]
breed [waters water]
breed [rockets rocket]
breed [grenades grenade]
breed [arrows arrow]
breed [mines mine]
breed [bombs bomb]

breed [explosions explosion]
breed [anchors anchor]
breed [targets target]

buddies-own [flame-timer buddy-speed]
fireballs-own [extinguish-timer]
waters-own [dry-timer]
explosions-own [explosion-timer]
grenades-own [grenade-speed]
arrows-own [stick-timer hit?]
bombs-own [bomb-timer bomb-speed]

to startup
  ca
  user-message "Welcome and say \"Hello\" to your Interactive Buddy!"
  setup
  ifelse file-exists? "Saved.data" [ ;Imports saved data
    file-open "Saved.data" 
    set weapons-bought file-read
    set money file-read
    set score file-read
    set buddy-emotion file-read
    file-close] [
  user-message "It seems like you haven't played this game before." 
  user-message "Please read the Info tab for intructions on how to play with your Interactive Buddy!"
  set weapons-bought (list "Tickle")]
  
  sound:play-sound "Media/Soundtrack.wav"
end

to setup-check
  ;Checks to see if there is any saved data before clearing
  ifelse (weapons-bought != 0 and weapons-bought != ["Tickle"]) or money != 0 or score != 0 [
    ifelse user-yes-or-no? "Do you also want to clear all saved data?" [ca
      set weapons-bought (list "Tickle")] [ct cp clear-links]] [
  ca
  set weapons-bought (list "Tickle")]
  setup
end

to setup
  ;Assigns shapes for everything beforehand
  set-default-shape tickles "feather"
  set-default-shape punches "fist"
  set-default-shape pistols "pistol"
  set-default-shape machine-guns "machine gun"
  set-default-shape shotguns "shotgun"
  set-default-shape flame-throwers "flame thrower"
  set-default-shape hoses "hose"
  set-default-shape rocket-launchers "rocket launcher"
  set-default-shape grenade-launchers "grenade launcher"
  set-default-shape bows "bow"
  set-default-shape hands "hand"
  set-default-shape god-hands "god's hand"
  set-default-shape bullets "bullet"
  set-default-shape fireballs "fire"
  set-default-shape waters "water"
  set-default-shape rockets "rocket"
  set-default-shape grenades "grenade"
  set-default-shape arrows "arrow"
  set-default-shape mines "mine"
  set-default-shape bombs "bomb"
  set-default-shape explosions "explosion"
  set-default-shape targets "target"
  
  ask patches with [count neighbors != 8] [set pcolor blue] ;Creates blue border around world
  create-buddies 1 [set heading 0 set shape "sad buddy" set size 3]
  
  set weapons (list "Tickle" "Punch" "Pistol" "Machine Gun" "Shotgun" "Flame Thrower" "Hose" "Rocket Launcher" 
    "Grenade Launcher" "Bow And Arrow" "Mines" "Bombs" "God's Hand")
  set weapons-cost (list 0 60 125 320 250 450 500 800 300 350 290 255 2500)
  set weapon "Tickle"
end

to play
  ask buddies [gravity-move]
  if weapon = "Tickle" [tickle-move]
  if weapon = "Punch" [punch-move]
  if weapon = "Pistol" [pistol-move]
  if weapon = "Machine Gun" [machine-gun-move]
  if weapon = "Shotgun" [shotgun-move]
  if weapon = "Flame Thrower" [flame-thrower-move]
  if weapon = "Hose" [hose-move]
  if weapon = "Rocket Launcher" [rocket-launcher-move]
  if weapon = "Grenade Launcher" [grenade-launcher-move]
  if weapon = "Bow And Arrow" [bow-move]
  if weapon = "Mines" [mine-create]
  if weapon = "Bombs" [bomb-create]
  if weapon = "God's Hand" [god-hand-move]
  
  buddy-effects
  bullet-move
  fireball-move
  water-move
  rocket-move
  grenade-move
  arrow-move
  mine-move
  bomb-move
  explosion-fade
  
  ;The old- variables are to allow NetLogo to skip over these portions of the code so that it doesn't 
  ;need to constantly run the code until something changes.
  if old-weapon != weapon [
    clear-output
    output-print "Your Current Weapon:" 
    output-print weapon
    set old-weapon weapon]
  if old-drawing != Location [cd
    if Location = "City" [import-drawing "Media/City.jpg"]
    if Location = "Farm" [import-drawing "Media/Farm.jpg"]
    if Location = "School" [import-drawing "Media/School.jpg"]
    if Location = "Space" [import-drawing "Media/Space.jpg"]
    if Location = "Underwater" [import-drawing "Media/Underwater.jpg"]
    set old-drawing Location]
  
  ;Plays soundtrack continously (plays again once soundtrack has finished)
  if timer > 165 [
    reset-timer
    sound:play-sound "Media/Soundtrack.wav"]
  
  ;Saves weapons bought, money, and score data every 2 seconds
  every 2 [carefully [file-delete "Saved.data"][]
    file-open "Saved.data"
    file-write weapons-bought
    file-print ""
    file-print money
    file-print buddy-emotion
    file-print score
    file-close]
  
  wait .006
end

;If the feather gets close to the buddy, the buddy will move away
to tickle-move
  ifelse (count tickles = 0) [change-weapon
    create-tickles 1 [set size 2]] [
  ask tickles [weapon-target
    if any? buddies in-radius 1.5 [
      ask buddies [
        set buddy-emotion (buddy-emotion + 5)
        set heading ([heading] of myself)
        set buddy-speed (buddy-speed + 2)]
      get-moneyscore 3]]]
end

;The code will calculate the speed at which the mouse is moving: (final position - intial position) / .2 seconds
to punch-move
  ifelse (count punches = 0) [change-weapon
    create-punches 1 [set size 2]] [
  every .2 [set mouse-oldx mouse-xcor set mouse-oldy mouse-ycor]
  ask punches [weapon-target
    if any? buddies in-radius 2 [  
      set mouse-speed (sqrt ((square (mouse-xcor - mouse-oldx)) + (square (mouse-ycor - mouse-oldy)))) * 2
      ask buddies [
        set buddy-emotion (buddy-emotion - 4)
        set heading ([heading] of myself)
        set buddy-speed (buddy-speed + mouse-speed * 10)]
      get-moneyscore 4]]]
end

to pistol-move
  ifelse (count pistols = 0) [change-weapon
    create-pistols 1 [set size 3]] [
  ask pistols [weapon-target]
  if mouse-down? [
    every .35 [ask pistols [
      hatch-bullets 1 [set size 1.5]]]]]
end

to machine-gun-move
  ifelse (count machine-guns = 0) [change-weapon
    create-machine-guns 1 [set size 4.5]] [
  ask machine-guns [weapon-target]
  if mouse-down? [
    every .05 [ask machine-guns [
      hatch-bullets 1 [set size 1.5]]]]]
end

to shotgun-move
  ifelse (count shotguns = 0) [change-weapon
    create-shotguns 1 [set size 4.4]] [
  ask shotguns [weapon-target]
  if mouse-down? [
    every .65 [ask shotguns [
      hatch-bullets 6 [
        set size 1.5 
        rt random 17 - 8]]]]]
end

to flame-thrower-move
  ifelse (count flame-throwers = 0) [change-weapon
    create-flame-throwers 1 [set size 4.3]] [
  ask flame-throwers [weapon-target]
  if mouse-down? [
    every .03 [ask flame-throwers [
      hatch-fireballs (random 3) + 1 [
        set size 1.5 
        set heading (heading - 10 + random 21)
        set extinguish-timer 22]]]]]
end

;Creates a link from the hose nozzle to a hidden turtle located at the top of the world. The link 
;will act as a pipe and will change shape from left to right to make it seem more realistic
to hose-move
  ifelse (count hoses = 0) [change-weapon
    create-hoses 1 [
      set size 5
      hatch-anchors 1 [ht
        create-link-with myself
        setxy 0 max-pycor
        ask my-links [
          set thickness .55
          set color (random 14 * 10 + 5)]]]] [
  ask hoses [weapon-target]
  ask links [ifelse [heading] of one-of hoses > 180 [
      set shape "hose right"] [
      set shape "hose left"]]
  if mouse-down? [
    every .03 [ask hoses [
      hatch-waters (random 5) + 10 [
        set size .3
        set heading (heading - 15 + random 31)
        set dry-timer 40]]]]]
end
  
to rocket-launcher-move
  ifelse (count rocket-launchers = 0) [change-weapon
    create-rocket-launchers 1 [set size 4.7]] [
  ask rocket-launchers [weapon-target]
  if mouse-down? [
    every 1 [ask rocket-launchers [
      hatch-rockets 1 [set size 2.6]]]]]
end

;The grenades will be aimed at a location about the buddy so that the trajectory will be a parabola
to grenade-launcher-move
  ifelse (count grenade-launchers = 0) [change-weapon
    create-grenade-launchers 1 [set size 4]] [
  ask grenade-launchers [
    setxy mouse-xcor mouse-ycor
    facexy ([xcor] of one-of buddies) ([ycor] of one-of buddies + (distance one-of buddies) / 2)]
  if mouse-down? [
    every .7 [ask grenade-launchers [
      hatch-grenades 1 [
        set size 2.6
        set grenade-speed (abs (xcor - [xcor] of one-of buddies) / sqrt (distance one-of buddies)) / 15]]]]]
end

to bow-move
  ifelse (count bows = 0) [change-weapon
    create-bows 1 [set size 5]] [
  ask bows [weapon-target]
  if mouse-down? [
    every .85 [ask bows [
        hatch-arrows 1 [
          set size 4
          set stick-timer 600]]]]]
end

to mine-create
  ifelse (count hands = 0) [change-weapon
    create-hands 1 [set size 3]] [
  ask hands [weapon-target]
  if mouse-down? [
    every .5 [ask hands [
      hatch-mines 1 [set size 2.2]]]]]
end

;Creates a target and links it to the hand. Then the target can be dragged around while the hand 
;stays put. When the mouse is released, the target is not being dragged and the hand will create 
;a bomb and set its speed to how far the target was from the hand
to bomb-create
  ifelse (count hands = 0) [change-weapon
    create-hands 1 [set size 3]] [
  if (count targets = 0) [ask hands [weapon-target]]
  ask hands [
    ifelse mouse-down? [
      ifelse (count targets = 0) [
        hatch-targets 1 [
          set size 8
          create-link-from myself]] [
      set shape "closed hand"
      ask targets [setxy mouse-xcor mouse-ycor]]] [
    if any? targets [
      face one-of targets
      hatch-bombs 1 [
        set size 3
        set bomb-timer 330
        set bomb-speed [link-length] of one-of links / 60]
      ask targets [die]
      set shape "hand"]]]]
end

;Just creates explosions that fade out and make it seem as if it leaves a trail
to god-hand-move
  ifelse (count god-hands = 0) [change-weapon
    create-god-hands 1 [set size 4]] [
  ask god-hands [
    setxy mouse-xcor mouse-ycor
    set heading (heading + 3)]
  if mouse-down? [
    every .011 [ask god-hands [
      hatch-explosions 2 [
        set explosion-timer 50
        set heading random 360
        fd 1.4]
      if any? buddies in-radius 6 [
        ask buddies [
          set buddy-emotion (buddy-emotion - 1)
          set buddy-speed (buddy-speed + 300)
          face myself
          set heading (heading + 180)]
        get-moneyscore 5]]]]]
end

to bullet-move
  ask bullets [
    if any? buddies in-radius 3 [
      ask buddies [
        set buddy-emotion (buddy-emotion - .4)
        set heading ([heading] of myself)
        	set buddy-speed (buddy-speed + 2)]
      get-moneyscore 1.5
      die]
    ifelse can-move? 1 [fd .5] [die]]
end
  
to fireball-move
  ask fireballs [
    if any? buddies in-radius 1 [
      ask buddies [
        set buddy-emotion (buddy-emotion - .3)
        set flame-timer (flame-timer + 1.5)
        set buddy-speed (buddy-speed + .04)
        set heading ([heading] of myself)] 
      get-moneyscore .5
      die]
    ifelse can-move? 1 [fd .41 
      set extinguish-timer (extinguish-timer - 1)] [die]
    if extinguish-timer <= 0 [die]]
end
  
to water-move
  ask waters [
    if any? buddies in-radius 2 [
      ask buddies [
        set buddy-emotion (buddy-emotion + .2)
        if flame-timer > 5 [set flame-timer (flame-timer - .5)]
        set buddy-speed (buddy-speed + .03)
        set heading ([heading] of myself)]
      get-moneyscore .1
      die]
    ifelse can-move? .5 [fd .3
      set dry-timer (dry-timer - 1)] [die]
    if dry-timer <= 0 [die]]
end

to rocket-move
  ask rockets [
    if any? buddies in-radius 4 [
      ask buddies [
        set buddy-emotion (buddy-emotion - 20)
        set buddy-speed (buddy-speed + 500)
        set heading ([heading] of myself)]
      get-moneyscore 20
      explode 70]
    ifelse can-move? 1.2 [jump 1.2] [die]]
end

to grenade-move
  ask grenades [
    gravity-move
    if any? buddies in-radius 2 [
      ask buddies [
        set buddy-emotion (buddy-emotion - 7)
        set buddy-speed (buddy-speed + 300)
        face myself
        set heading (heading + 180)]
      get-moneyscore 10
      explode 25]
    if can-move? grenade-speed and ycor > (min-pycor + 1) [
      fd grenade-speed
      set grenade-speed (grenade-speed * .989)]] ;Speed of grenade is decreased to achieve a parabola
end

;The arrows will follow the buddy when it has hit it. The arrow will earn money for damaging, but will 
;expire after a short period of time
to arrow-move
  ask arrows [
    ifelse hit? = true [
      move-to one-of buddies
      bk .5
      set stick-timer (stick-timer - 1)
      get-moneyscore .01
      if stick-timer <= 0 [die]] [
    if any? buddies in-radius 2 [
      ask buddies [
        set buddy-emotion (buddy-emotion - 6)
        set buddy-speed (buddy-speed + 20)
        set heading ([heading] of myself)]
      set hit? true
      set shape "bloody arrow"
      get-moneyscore 7.5]
    ifelse can-move? 1 [fd 1] [die]]]
end

to mine-move
  ask mines [
    if any? buddies in-radius 2 [
      ask buddies [
        set buddy-emotion (buddy-emotion - 6)
        set buddy-speed (buddy-speed + 200)
        face myself
        set heading (heading + 180)]
      get-moneyscore 8
      explode 20]]
end

to bomb-move
  ask bombs [
    gravity-move
    set bomb-timer (bomb-timer - 1)
    if bomb-timer <= 0 [
      ask buddies in-radius 3 [
        set buddy-emotion (buddy-emotion - 6)
        set buddy-speed (buddy-speed + 200)
        face myself
        set heading (heading + 180)]
      get-moneyscore 12
      explode 30]
    if can-move? bomb-speed and ycor > (min-pycor + 1) [
      fd bomb-speed
      set bomb-speed (bomb-speed * .99)]] ;Used to create parabola like in grenades
end

to buddy-effects
  ask buddies [
    ifelse flame-timer > 0 [
      set shape "buddy on fire"
      set size 6
      set flame-timer (flame-timer - .5)
      set buddy-speed (buddy-speed + .1)] [
    set size 3
    ifelse buddy-emotion > 10 [set shape "happy buddy"] [
      ifelse buddy-emotion < -10 [set shape "sad buddy"] [
        set shape "buddy"]]]
    if buddy-speed > .1 [
      if abs [pxcor] of patch-ahead 1 = max-pxcor [ ;Code was copied from the Bounce example
        set heading (- heading)]
      if abs [pycor] of patch-ahead 1 = max-pycor [
        set heading (180 - heading)]
      fd 1
      set buddy-speed (buddy-speed - (sqrt buddy-speed))]] ;Buddy's speed decreases so that it doesn't keep moving
end

;The explosions will slowly fade out after a period of time
to explosion-fade
  ask explosions [
    set size (explosion-timer / 3)
    set color (scale-color red explosion-timer 50 0)
    set explosion-timer (explosion-timer - 1.5)
    if explosion-timer <= 0 [die]]
end

;Used to aim at the buddy with the weapons
to weapon-target
  setxy mouse-xcor mouse-ycor
  if any? buddies [face one-of buddies]
end

;Kills all other weapons so that a new weapon can be chosen
to change-weapon
  ask turtles with [breed != buddies and 
                    breed != bullets and 
                    breed != fireballs and
                    breed != waters and
                    breed != rockets and
                    breed != grenades and
                    breed != arrows and
                    breed != mines and
                    breed != bombs and
                    breed != explosions] [die]
end

to explode [strength]
  hatch-explosions 1 [
    set explosion-timer strength
    set heading random 360]
  die
end

to get-moneyscore [amount]
  set score (score + (amount * 10))
  set money (money + amount)
end

;The universal gravitational force that affects buddies, grenades, and bombs
to gravity-move
  if Gravity = true [if ycor > (min-pycor + size * .3) [set ycor (ycor - .065)]]
end 

to-report square [x]
  report x * x
end

;Used to display the happiness/sadness of the buddy
to-report emotions
  ifelse buddy-emotion > 300 [report "VERY Happy"] [
    ifelse buddy-emotion > 20 [report "Happy"] [
      ifelse buddy-emotion < -300 [report "VERY Sad"] [
        ifelse buddy-emotion < -20 [report "Sad"] [
          report "BORED"]]]]
end

;List processing so that it displays the weapons that you can afford and haven't bought when you 
;click "Buy A New Weapon"
to buy-weapon
  let weapons-can-buy []
  foreach weapons-cost [if ? < money [set weapons-can-buy lput (item (position ? weapons-cost) weapons) weapons-can-buy]]
  let weapons-not-bought (filter [not (member? ? weapons-bought)] weapons)
  let weapons-list (filter [((member? ? weapons-not-bought) and (member? ? weapons-can-buy))] weapons)
  ifelse empty? weapons-list
    [ifelse empty? weapons-can-buy or empty? weapons-not-bought
      [ifelse empty? weapons-can-buy
        [let null user-one-of "Which weapon would you like to buy?" ["You can't afford any new weapons!"]]
        [let null user-one-of "Which weapon would you like to buy?" ["You already bought all the weapons!"]]]
      [let null user-one-of "Which weapon would you like to buy?" ["Get more money to buy weapons!"]]]
    [let bought-weapon (user-one-of "Which weapon would you like to buy?" weapons-list)
      set weapons-bought lput bought-weapon weapons-bought
      set money (money - (item (position bought-weapon weapons) weapons-cost))
      set weapon bought-weapon]
end

to select-weapon
  set weapon user-one-of "Which weapon do you want to use?" weapons-bought
end

;Some more list processing so that you can change weapons using the keys on the keyboard
to next-weapon
  set weapon-number position weapon weapons-bought
  set weapon-number (weapon-number + 1)
  if weapon-number > (length weapons-bought - 1) [set weapon-number 0]
  set weapon item weapon-number weapons-bought
end

to previous-weapon
  set weapon-number position weapon weapons-bought
  set weapon-number (weapon-number - 1)
  if weapon-number < 0 [set weapon-number (length weapons-bought - 1)]
  set weapon item weapon-number weapons-bought
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
902
503
15
10
22.0
1
10
1
1
1
0
0
0
1
-15
15
-10
10
0
0
1
ticks
30.0

BUTTON
14
36
80
69
Setup
setup-check
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
87
36
196
69
Play
play
T
1
T
OBSERVER
NIL
P
NIL
NIL
1

SWITCH
54
263
157
296
Gravity
Gravity
0
1
-1000

BUTTON
117
156
198
189
Next Weapon
next-weapon
NIL
1
T
OBSERVER
NIL
D
NIL
NIL
1

BUTTON
14
156
115
189
Previous Weapon
previous-weapon
NIL
1
T
OBSERVER
NIL
A
NIL
NIL
1

OUTPUT
13
202
197
252
12

MONITOR
56
313
155
358
Buddy's Emotion
emotions
17
1
11

BUTTON
35
85
182
118
Buy A New Weapon
buy-weapon
NIL
1
T
OBSERVER
NIL
W
NIL
NIL
1

BUTTON
35
119
182
152
Choose A New Weapon
select-weapon
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

MONITOR
18
368
100
413
Money
money
1
1
11

MONITOR
109
368
193
413
Score
score
0
1
11

CHOOSER
35
438
173
483
Location
Location
"Room" "City" "Farm" "School" "Space" "Underwater"
0

@#$#@#$#@
## WHAT IS IT?

**Interactive Buddy
Made by Sayid Elsaieh and Danny Qiu**

This is our little version of the popular flash game, [Interactive Buddy] (http://www.kongregate.com/games/shockvalue_/interactive-buddy?acomplete=my+inter), recreated in NetLogo. It is essentially a room where you test out various weapons on the buddy to gain money, in which you use to buy more weapons. The weapons get progressively better, starting with a feather (used for tickling) and ending with a God's hand. The buddies emotions also vary depending on how you treat it.

Though this game may seem cruel, no real buddies were hurt in the process of making this game. 

## HOW IT WORKS

Generally, every weapon has it own procedure to move and create bullets, fireballs, water, etc... Then, there are other procedures that make the bullets, fireballs, water, etc... move. This creates an easy to follow code and a more stable code as a plus. Most of the explanation of how each weapon works is in the code's comments.

Game stats are auto-saved using the file- functions in NetLogo. So, there is no need to be scared that your precious weapons will disappear once you quit NetLogo.

## HOW TO USE IT

This game is fairly intuitive with its minimal number of buttons to click. You might want to select the location from the chooser to match the place where you would like the events to take place.

First, setup the game by pressing "`Setup`". Then, press "`Play`" to start the game.

When you move your mouse into the screen, you will notice that your mouse cursor is now a feather. This is your default weapon. Bring your mouse close to the buddy on the screen and it will react. Various weapons will have various affects on the buddy.

The more you interact with your buddy (hence the name of the game), the more money you will earn to buy better weapons. To buy a new weapon, hit "`Buy A New Weapon`" and to choose a new weapon, hit "`Choose A New Weapon`". A drop-down list will appear and select the weapon you desire from it.

### Weapons to choose from:

>  * Tickle - Move the feather around to tickle the buddy. Increases happiness.
>  * Punch - Move the fist around to punch the buddy. Decreases happiness.
>  * Pistol - Shoots one bullet at the buddy. Decreases happiness.
>  * Machine Gun - Shoots bullets at a rapid rate towards the buddy. Decreases happiness.
>  * Shotgun - Shoots six rounds at the buddy that spreads out the farther it goes. Decreases happiness.
>  * Rocket launcher - Shoots a rocket towards the buddy. Decreases happiness by a LARGE amount.
>  * Flamethrower - Shoots flames towards the buddy. Will ignite buddy and cause it to run. Happiness will decrease since the buddy is scared of pyromaniacs.
>  * Hose - Sprays the buddy with clean water, straight from the water filtration system. The pureness makes the buddy happy and it stops fires.
>  * Grenade Launcher - Shoots grenades that detonate when touched. Affected by gravity. Decreases happiness if explosion is near buddy.
>  * Bow - Shoots an arrow at the buddy, causing extreme pain as the arrow is embedded into the buddy's skin.
>  * Mines - Place mines that detonate when touched. Not affected by gravity. Decreases happiness if explosion is near buddy.
>  * Bombs - Place explosives that detonate after a few seconds. Affected by gravity. Decreases happiness if explosion is near buddy.
>  * God's Hand - Will continually make explosions as long as the mouse button is held down. God is punishing the buddy, causing extreme depression.

## CREDITS AND REFERENCES

First, we would like to thank the creators of the **_bounce_** and **_link breeds_** examples in the NetLogo library. They were extremely helpful in explaining basic concepts in keeping a turtle in a defined area and linking turtles to each other.

Also, we would like to thank various students for their NetLogo projects done in the past, such as the one by [Jimmy Yang (Raiden)] (http://bert.stuy.edu/common/IntroToCompSci/NetLogoDemos/Jimmy-Yang-Raiden.html) for showing the potential of separating the tasks into multiple procedures and calling them all in the main procedure and others.

As always, we would like to thank the NetLogo Dictionary for being a valuable resource to us during the course of this project.

Lastly, we would like to thank Ms.Pascu for being a wonderful _Intro to Computer Science_ teacher. She has been amazing and has helped us numerous times during the course of the term.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

arrow
true
0
Polygon -7500403 true true 143 269 133 298 134 259 145 242 145 171 132 179 150 147 168 179 155 171 155 242 166 259 167 298 157 269

bloody arrow
true
0
Polygon -7500403 true true 143 269 133 298 134 259 145 242 145 171 132 179 150 147 168 179 155 171 155 242 166 259 167 298 157 269
Polygon -2674135 true false 150 147 132 179 146 169 145 190 155 190 154 169 168 179

bomb
true
0
Polygon -6459832 true false 148 115 150 100 157 92 166 87 176 85 185 85 195 89 204 97 202 102 198 102 195 99 190 94 181 92 169 93 163 95 159 98 155 106 153 117
Circle -7500403 true true 108 108 85
Rectangle -7500403 true true 143 98 164 112
Polygon -2674135 true false 200 96 199 95 203 86 205 97 211 89 212 99 218 103 208 103 211 112 204 108 199 112 199 102 189 107 192 100 186 95 193 96 192 86

bow
true
0
Polygon -7500403 false true 45 150 50 132 57 117 76 97 113 77 140 70 160 70 187 77 224 97 243 117 250 132 255 150
Rectangle -7500403 true true 45 151 255 156

buddy
false
10
Circle -13345367 true true 60 101 182
Circle -1184463 true false 98 10 104
Line -16777216 false 177 84 122 84
Circle -13345367 true true 124 39 14
Circle -13345367 true true 162 39 14
Circle -1 true false 40 108 64
Circle -1 true false 54 226 66
Circle -1 true false 196 108 64
Circle -1 true false 180 226 66
Line -16777216 false 123 84 178 84

buddy on fire
false
10
Polygon -2674135 true false 145 244 170 241 195 235 220 220 240 198 251 148 254 91 258 29 215 87 189 20 147 68 101 13 88 78 52 31 50 131 67 197 77 224 107 243
Circle -13345367 true true 108 131 85
Circle -13345367 true true 109 130 85
Circle -1184463 true false 123 80 54
Circle -1 true false 91 130 26
Circle -1 true false 173 189 32
Circle -2674135 true false 156 91 8
Circle -2674135 true false 136 91 8
Line -16777216 false 162 110 139 110
Line -16777216 false 138 110 161 110
Line -16777216 false 168 118 162 110
Line -16777216 false 132 118 138 110
Circle -1 true false 183 130 26
Circle -1 true false 95 189 32

bullet
true
0
Rectangle -7500403 true true 135 135 165 180
Circle -7500403 true true 135 120 30

closed hand
false
0
Circle -7500403 true true 82 86 136
Polygon -7500403 true true 68 110 67 128 88 176 118 162 103 116 85 104 74 104
Polygon -7500403 true true 101 80 99 104 120 189 156 174 130 92 121 79 110 75
Polygon -7500403 true true 210 90 213 106 186 195 150 180 176 98 185 85 196 81
Polygon -7500403 true true 165 74 171 94 168 189 135 179 137 93 142 75 155 67
Polygon -7500403 true true 241 131 243 147 198 203 176 168 204 134 217 122 230 121

explosion
true
0
Polygon -7500403 true true 243 176 183 146 183 206
Polygon -7500403 true true 155 85 125 145 185 145
Polygon -7500403 true true 158 267 128 207 188 207
Polygon -7500403 true true 70 175 130 145 130 205
Polygon -7500403 true true 112 176 157 221 97 236
Polygon -7500403 true true 104 181 149 136 89 121
Polygon -7500403 true true 159 133 204 178 219 118
Polygon -7500403 true true 202 171 157 216 217 231
Circle -7500403 true true 113 135 76
Polygon -1184463 true false 119 163 100 134 133 141 151 108 175 141 208 128 195 159 219 173 197 189 208 214 182 205 164 245 148 219 111 221 117 189 88 174
Polygon -955883 true false 142 145 150 121 165 147 192 138 184 159 203 171 191 185 200 206 179 202 164 234 147 210 120 211 128 186 99 175 127 163 104 139 141 150
Polygon -2674135 true false 147 150 151 132 161 155 184 144 176 161 195 171 183 184 194 200 176 194 166 222 154 203 131 206 136 186 112 176 135 166 112 145

feather
true
0
Line -7500403 true 150 135 150 285
Line -7500403 true 120 90 150 150
Line -7500403 true 150 60 150 90
Line -7500403 true 180 135 150 165
Line -7500403 true 180 135 150 180
Line -7500403 true 180 150 150 195
Line -7500403 true 180 165 150 210
Line -7500403 true 180 180 150 225
Line -7500403 true 180 195 150 240
Line -7500403 true 180 210 150 240
Line -7500403 true 180 105 150 165
Line -7500403 true 171 83 150 144
Line -7500403 true 164 69 149 134
Line -7500403 true 156 59 149 117
Line -7500403 true 142 58 150 122
Line -7500403 true 138 69 151 134
Line -7500403 true 131 68 150 129
Line -7500403 true 120 75 150 135
Line -7500403 true 120 105 150 165
Line -7500403 true 120 135 150 165
Line -7500403 true 120 135 150 173
Line -7500403 true 120 105 150 150
Line -7500403 true 120 150 150 195
Line -7500403 true 120 135 150 180
Line -7500403 true 120 165 150 210
Line -7500403 true 120 180 150 225
Line -7500403 true 120 210 150 240
Line -7500403 true 120 195 150 240
Line -7500403 true 180 135 150 173
Line -7500403 true 180 105 150 150
Line -7500403 true 180 90 150 150

fire
true
0
Polygon -7500403 true true 149 14 166 18 197 18 241 52 260 90 268 143 263 192 232 154 229 191 217 228 189 273 173 245 152 289 133 259 120 188 105 243 83 209 74 174 73 97 44 144 44 99 62 37 87 22 117 19
Polygon -955883 true false 174 16 209 49 215 88 209 132 197 168 182 147 175 119 165 159 149 204 115 139 105 97 107 47 136 14
Polygon -2674135 true false 145 16 128 32 128 57 138 76 152 99 170 67 169 40 165 18

fist
true
0
Polygon -7500403 true true 67 59 76 52 102 51 102 99 67 106
Polygon -7500403 true true 105 99 106 51 142 50 141 162 127 176 106 162 106 144 126 133 127 95
Polygon -7500403 true true 154 164 175 150 175 51 145 50 144 158
Polygon -7500403 true true 123 131 103 144 104 166 126 181 146 163 153 169 181 149 210 145 210 72 241 147 240 207 195 246 130 247 53 201 60 110 123 99
Polygon -7500403 true true 178 146 178 51 207 51 206 142

flame thrower
true
3
Line -7500403 false 180 241 151 214
Rectangle -2674135 true false 145 106 159 218
Polygon -6459832 true true 158 129 203 110 219 102 220 35 202 26 203 19 189 15 184 25 195 34 199 30 208 37 209 91 209 97 155 119
Polygon -1 true false 145 188 149 197 163 201 163 219 196 220 196 201 214 188 216 169 214 146 199 119 200 106 171 106 156 106 154 117 135 122 139 192
Polygon -6459832 true true 133 30 145 37 158 39 171 40 184 31 178 87 130 85
Polygon -6459832 true true 150 80 130 124 130 219 147 218 147 118 163 83
Polygon -2674135 true false 130 146 213 143 208 132 130 134 129 129
Polygon -2674135 true false 130 183 214 187 217 175 130 174
Polygon -2674135 true false 146 217 130 217 124 223 117 227 113 238 113 255 127 280 139 278 154 299 169 292 149 269 170 247 169 231
Polygon -2674135 false false 169 249 184 271 165 288 144 271 151 244
Line -2674135 false 160 259 164 270
Line -2674135 false 165 270 171 276
Line -7500403 false 172 251 180 242
Line -7500403 false 173 255 183 243
Line -7500403 false 184 242 158 219

god's hand
true
0
Circle -1184463 true false 18 9 268
Circle -7500403 true true 82 123 136
Polygon -7500403 true true 55 84 54 102 89 191 105 136 81 93 72 78 61 78
Polygon -7500403 true true 87 43 85 67 106 152 142 137 116 55 107 42 96 38
Polygon -7500403 true true 221 37 223 61 202 146 166 131 192 49 201 36 212 32
Polygon -7500403 true true 163 29 169 49 166 144 133 134 135 48 141 22 153 22
Polygon -7500403 true true 267 134 271 148 205 223 202 171 230 137 243 125 256 124

grenade
true
0
Rectangle -7500403 true true 135 90 165 135
Circle -7500403 true true 108 108 85
Line -16777216 false 120 120 120 180
Line -16777216 false 135 105 135 195
Line -16777216 false 150 105 150 195
Line -16777216 false 165 105 165 195
Line -16777216 false 180 120 180 180
Line -16777216 false 105 135 195 135
Line -16777216 false 120 120 180 120
Line -16777216 false 105 150 195 150
Line -16777216 false 105 165 195 165
Line -16777216 false 120 180 180 180
Circle -7500403 false true 160 72 30

grenade launcher
true
3
Circle -7500403 false false 139 168 28
Polygon -7500403 true false 121 136 121 18 149 18 150 137
Polygon -6459832 true true 121 136 150 136 150 193 153 204 157 208 164 213 165 220 162 224 163 235 173 274 141 277 140 229 143 225 145 221 144 218 140 215 129 196 124 179
Line -16777216 false 135 135 135 18
Line -7500403 false 150 182 152 186
Line -7500403 false 153 186 156 187
Line -7500403 false 156 187 160 186
Rectangle -7500403 false false 90 60 135 75
Line -7500403 false 105 75 105 60
Line -7500403 false 90 66 120 66

hand
false
0
Circle -7500403 true true 82 123 136
Polygon -7500403 true true 55 84 54 102 89 191 105 136 81 93 72 78 61 78
Polygon -7500403 true true 87 39 85 63 106 148 142 133 116 51 107 38 96 34
Polygon -7500403 true true 221 37 223 61 202 146 166 131 192 49 201 36 212 32
Polygon -7500403 true true 163 29 169 49 166 144 133 134 135 48 141 22 153 22
Polygon -7500403 true true 267 134 271 148 205 223 202 171 230 137 243 125 256 124

happy buddy
false
10
Circle -13345367 true true 60 101 182
Circle -1184463 true false 98 10 104
Line -16777216 false 181 80 167 94
Line -16777216 false 166 95 134 95
Circle -13345367 true true 124 39 14
Line -16777216 false 119 80 133 94
Circle -13345367 true true 162 39 14
Circle -1 true false 40 108 64
Circle -1 true false 54 226 66
Circle -1 true false 196 108 64
Circle -1 true false 180 226 66

hose
true
0
Polygon -7500403 true true 128 97 172 97 165 124 166 151 134 151 135 124

machine gun
true
0
Polygon -7500403 true true 131 113 135 79 141 63 143 39 147 35 147 9 153 9 155 58 160 105 168 103 176 99 183 93 189 85 199 96 189 108 180 115 172 119 161 124 161 146 162 169 198 180 194 199 161 188 157 209 179 288 139 287 136 212 131 204
Polygon -7500403 false true 160 170 181 176 181 171 180 167 178 163 175 159 171 155 166 152 160 150
Line -7500403 true 162 165 169 163
Line -7500403 true 172 160 167 164

mine
true
0
Circle -7500403 true true 75 75 150
Circle -2674135 true false 116 116 67
Circle -10899396 true false 135 135 30

pistol
true
0
Polygon -7500403 true true 121 51 145 44 169 50 169 165 269 194 268 238 179 215 172 219 167 224 165 233 165 240 120 243
Polygon -7500403 false true 194 173 194 160 192 152 188 146 182 142 167 135 168 168
Line -7500403 true 167 151 175 152
Line -7500403 true 176 153 182 161

rocket
true
0
Rectangle -7500403 true true 120 105 180 225
Polygon -7500403 true true 181 105 160 77 139 77 119 105
Circle -7500403 true true 141 68 20
Polygon -7500403 true true 120 181 105 226 120 226
Polygon -7500403 true true 180 181 195 226 180 226
Polygon -7500403 true true 119 105 140 77 161 77 181 105
Circle -7500403 true true 139 68 20

rocket launcher
true
0
Rectangle -7500403 true true 173 224 218 239
Rectangle -7500403 true true 173 105 203 120
Rectangle -7500403 true true 128 60 173 256
Rectangle -7500403 true true 113 105 128 120
Polygon -7500403 true true 128 60 134 31 167 31 173 60
Circle -16777216 true false 115 107 10
Line -7500403 true 114 111 125 111
Line -7500403 true 119 116 119 106
Polygon -7500403 false true 203 225 203 207 200 204 195 201 187 199 177 197 163 196 170 223 171 225
Line -7500403 true 181 224 195 212

sad buddy
false
10
Circle -13345367 true true 60 101 182
Circle -1184463 true false 98 10 104
Line -16777216 false 122 91 133 81
Line -16777216 false 134 80 166 80
Circle -13345367 true true 124 39 14
Circle -13345367 true true 162 39 14
Circle -1 true false 40 108 64
Circle -1 true false 54 226 66
Circle -1 true false 196 108 64
Circle -1 true false 180 226 66
Line -16777216 false 178 91 167 81

shotgun
true
1
Circle -7500403 false false 154 168 28
Polygon -2674135 true true 136 136 136 18 164 18 165 137
Polygon -6459832 true false 136 136 165 136 165 193 168 204 172 208 179 213 180 220 177 224 178 235 188 274 156 277 155 229 158 225 160 221 159 218 155 215 144 196 139 179
Line -16777216 false 150 135 150 18
Line -7500403 false 165 182 167 186
Line -7500403 false 168 186 171 187
Line -7500403 false 171 187 175 186

target
false
0
Circle -2674135 false false 135 135 30
Line -2674135 false 120 150 180 150
Line -2674135 false 150 120 150 180

water
true
0
Circle -7500403 true true 73 15 152
Polygon -7500403 true true 219 119 205 148 185 180 174 205 163 236 156 263 149 293 147 134
Polygon -7500403 true true 79 118 95 148 115 180 126 205 137 236 144 263 150 294 154 135

@#$#@#$#@
NetLogo 5.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

hose left
4.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0

hose right
-4.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0

@#$#@#$#@
0
@#$#@#$#@
