globals [mouse-oldx mouse-oldy mouse-speed
  weapon-number weapons]

breed [buddies buddy]
breed [tickles tickle]
breed [punches punch]
breed [pistols pistol]
breed [machine-guns machine-gun]
breed [shotguns shotgun]
breed [flame-throwers flame-thrower]
breed [launchers launcher]
breed [missiles missile]
breed [mines mine]
breed [bombs bomb]

breed [bullets bullet]
breed [fireballs fireball]

buddies-own [flame-timer]
fireballs-own [extinguish]

to setup
  ca
  ask patches with [count neighbors != 8] [set pcolor blue]
  create-buddies 1 [set heading 0 set shape "sad buddy" set size 15]
  
  set-default-shape tickles "feather"
  set-default-shape punches "fist"
  set-default-shape pistols "pistol"
  set-default-shape machine-guns "machine gun"
  ;set-default-shape shotguns "shotgun"
  ;set-dafault-shape flame-throwers "flame thrower"
  
  ;set-default-shape bullets "bullet"
  set-default-shape fireballs "fire"
  
  set weapons (list "Tickle" "Punch" "Pistol" "Machine Gun" "Shotgun" "Flame Thrower" "Rocket Launcher" "Mines" "Bombs")
end

to play
  if Gravity = true [ask buddies [if ycor > (min-pycor + size * .27) [setxy xcor ycor - .065]]]
  if weapon = "Tickle" [tickle-move]
  if weapon = "Punch" [punch-move]
  if weapon = "Pistol" [pistol-move]
  if weapon = "Machine Gun" [machine-gun-move]
  if weapon = "Shotgun" [shotgun-move]
  if weapon = "Flame Thrower" [flame-thrower-move]
  
  bullet-move
  fireball-move
  buddy-effects
  wait .01
end

to tickle-move
  ifelse (count tickles = 0) [change-weapon
    create-tickles 1 [set size 6]] [
  ask tickles [weapon-target
    if any? buddies in-radius 3.5 [
      ask buddies [
        set shape "happy buddy"
        face myself
        set heading (heading + 180)
        if [count patches in-radius 2 with [pcolor = blue]] of patch-ahead 2 = 0 [fd 1]]]]]
end

to punch-move
  ifelse (count punches = 0) [change-weapon
    create-punches 1 [set size 5]] [
  every .2 [set mouse-oldx mouse-xcor set mouse-oldy mouse-ycor]
  ask punches [weapon-target
    if any? buddies in-radius 4 [  
      set mouse-speed (sqrt ((square (mouse-xcor - mouse-oldx)) + (square (mouse-ycor - mouse-oldy)))) / .5
      ask buddies [
        set shape "sad buddy"
        face myself 
        set heading (heading + 180)
        repeat (mouse-speed * 1.5) [ifelse [any? patches in-radius 2 with [pcolor = blue]] of patch-ahead 2
          [set heading (- heading)] [fd .4 wait .0035]]]]]]
end

to pistol-move
  ifelse (count pistols = 0) [change-weapon
    create-pistols 1 [set size 7]] [
  ask pistols [weapon-target]
  if mouse-down? [
    every .35 [ask pistols [hatch-bullets 1 [set size 2.5]]]]]
end

to machine-gun-move
  ifelse (count machine-guns = 0) [change-weapon
    create-machine-guns 1 [set size 7]] [
  ask machine-guns [weapon-target]
  if mouse-down? [
    every .05 [ask machine-guns [hatch-bullets 1 [set size 2.5]]]]]
end

to shotgun-move
  ifelse (count shotguns = 0) [change-weapon
    create-shotguns 1 [set size 7]] [
  ask shotguns [weapon-target]
  if mouse-down? [
    every .5 [ask shotguns [hatch-bullets 6 [set size 2.5 rt random 21 - 10]]]]]
end

to flame-thrower-move
  ifelse (count flame-throwers = 0) [change-weapon
    create-flame-throwers 1 [set size 7]] [
  ask flame-throwers [weapon-target]
  if mouse-down? [
    every .03 [ask flame-throwers [hatch-fireballs 2 [set size 4.5 
                                                      set heading (heading - 10 + random 21)
                                                      set extinguish 25]]]]]
end

to bullet-move
  ask bullets [
    if any? buddies in-radius 3 [
      ask buddies [
        set shape "sad buddy"
        face myself
        set heading (heading + 180)
        if [count patches in-radius 2 with [pcolor = blue]] of patch-ahead 2 = 0 [jump 2.5]]
      die]
    ifelse can-move? 1 [fd 1] [die]]
end

to fireball-move
  ask fireballs [
    if any? buddies in-radius 4 [
      ask buddies [set flame-timer (flame-timer + 1.5)]
      die]
    ifelse can-move? 1 [fd 1 set extinguish (extinguish - 1)] [die]
    if extinguish <= 0 [die]]
end

to buddy-effects
  ask buddies [
    if flame-timer > 0 [
      ;set shape "buddy on fire"
      set flame-timer (flame-timer - .5)]]
end

to weapon-target
  setxy mouse-xcor mouse-ycor
  if any? buddies [face one-of buddies]
end
  
to change-weapon
  ask turtles with [breed != buddies and breed != bullets] [die]
end
  
to-report square [x]
  report x * x
end
  
to next-weapon
  set weapon-number position weapon weapons 
  set weapon-number (weapon-number + 1)
  if weapon-number > 7 [set weapon-number 0]
  set weapon item weapon-number weapons
end
  
to previous-weapon
  set weapon-number (position weapon weapons)
  set weapon-number (weapon-number - 1)
  if weapon-number < 0 [set weapon-number 7]
  set weapon item weapon-number weapons
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
843
510
40
30
7.7
1
10
1
1
1
0
0
0
1
-40
40
-30
30
0
0
1
ticks
30.0

BUTTON
63
55
129
88
NIL
setup
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
65
96
128
129
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

CHOOSER
27
148
178
193
Weapon
Weapon
"Tickle" "Punch" "Pistol" "Machine Gun" "Shotgun" "Flame Thrower" "Rocket Launcher" "Mines" "Bombs"
5

SWITCH
10
352
113
385
Gravity
Gravity
1
1
-1000

BUTTON
13
205
93
238
Next Weapon
next-weapon
NIL
1
T
OBSERVER
NIL
A
NIL
NIL
1

BUTTON
96
205
198
238
Previous Weapon
previous-weapon
NIL
1
T
OBSERVER
NIL
D
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

This is
Made by Sayid Elsaieh and Danny Qiu

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

bullet (handgun)
true
0
Rectangle -7500403 true true 135 135 165 180
Circle -7500403 true true 135 120 30

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

happy buddy
false
10
Circle -13345367 true true 108 131 85
Circle -13345367 true true 107 131 85
Circle -1184463 true false 123 80 54
Circle -1 true false 91 130 26
Circle -1 true false 173 189 32
Circle -14835848 true false 155 94 8
Line -16777216 false 162 122 139 122
Line -16777216 false 133 112 138 122
Circle -1 true false 183 130 26
Circle -1 true false 95 189 32
Line -16777216 false 138 122 161 122
Line -16777216 false 167 112 162 122
Circle -14835848 true false 137 94 8

machine gun
true
0
Polygon -7500403 true true 125 113 129 79 135 63 137 39 141 35 141 9 147 9 149 58 154 105 162 103 170 99 177 93 183 85 193 96 183 108 174 115 166 119 155 124 155 146 156 169 192 180 188 199 155 188 151 209 173 288 133 287 130 212 125 204
Polygon -7500403 false true 154 169 175 175 175 170 174 166 172 162 169 158 165 154 160 151 154 149
Line -7500403 true 156 166 163 164
Line -7500403 true 167 160 162 164

pistol
true
0
Polygon -7500403 true true 91 52 115 45 139 51 139 166 239 195 238 239 149 216 142 220 137 225 135 234 135 241 90 244
Polygon -7500403 false true 127 164 140 164 148 162 154 158 158 152 165 137 132 138
Line -7500403 true 143 138 142 146
Line -7500403 true 142 147 148 155

sad buddy
false
10
Circle -13345367 true true 108 131 85
Circle -13345367 true true 107 131 85
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

shotgun (wip)
true
0
Rectangle -7500403 true true 150 120 270 150
Line -16777216 false 150 135 270 135
Polygon -6459832 true false 180 135 195 165 120 165 105 135 180 135 181 137 182 137 182 137 197 167
Polygon -6459832 true false 150 121 148 123 85 120 42 139 8 125 11 174 45 155 111 153 151 141

@#$#@#$#@
NetLogo 5.0.2
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

@#$#@#$#@
0
@#$#@#$#@
