globals [mouse-oldx mouse-oldy mouse-speed
  weapons weapons-bought weapon
  weapon-number old-weapon]

breed [buddies buddy]
breed [tickles tickle]
breed [punches punch]
breed [pistols pistol]
breed [machine-guns machine-gun]
breed [shotguns shotgun]
breed [flame-throwers flame-thrower]
breed [rocket-launchers rocket-launcher]
breed [grenade-launchers grenade-launcher]
breed [hands hand]
breed [god-hands god-hand]

breed [bullets bullet]
breed [fireballs fireball]
breed [grenades grenade]
breed [rockets rocket]
breed [mines mine]
breed [bombs bomb]

breed [explosions explosion]
breed [targets target]

buddies-own [flame-timer buddy-speed buddy-emotion]
fireballs-own [extinguish-timer]
explosions-own [explosion-timer]
grenades-own [grenade-speed]
bombs-own [bomb-timer bomb-speed]

to setup
  ca
  ask patches with [count neighbors != 8] [set pcolor blue]
  create-buddies 1 [set heading 0 set shape "sad buddy" set size 3]
  
  set-default-shape tickles "feather"
  set-default-shape punches "fist"
  set-default-shape pistols "pistol"
  set-default-shape machine-guns "machine gun"
  set-default-shape shotguns "shotgun"
  set-default-shape flame-throwers "flame thrower"
  set-default-shape rocket-launchers "rocket launcher"
  set-default-shape grenade-launchers "grenade launcher"
  ;set-default-shape hands "hand"
  ;set-default-shape gods-hand "god's hand"
  
  set-default-shape bullets "bullet"
  set-default-shape fireballs "fire"
  set-default-shape rockets "rocket"
  set-default-shape grenades "grenade"
  set-default-shape mines "mine"
  set-default-shape bombs "bomb"
  
  set-default-shape explosions "explosion"
  set-default-shape targets "target"
  
  set weapons (list "Tickle" "Punch" "Pistol" "Machine Gun" "Shotgun" "Flame Thrower" "Rocket Launcher" 
    "Grenade Launcher" "Mines" "Bombs" "God's Hand") 
  set weapons-bought (list "Tickle")
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
  if weapon = "Rocket Launcher" [rocket-launcher-move]
  if weapon = "Grenade Launcher" [grenade-launcher-move]
  if weapon = "Mines" [mines-create]
  if weapon = "Bombs" [bombs-create]
  if weapon = "God's Hand" [god-hand-move]
  
  bullet-move
  fireball-move
  rocket-move
  grenade-move
  mine-move
  bomb-move
  
  buddy-effects
  explosion-fade
  
  if old-weapon != weapon [
    clear-output
    output-print "Your Current Weapon:" 
    output-print weapon
    set old-weapon weapon]
  wait .01
end

to tickle-move
  ifelse (count tickles = 0) [change-weapon
    create-tickles 1 [set size 2]] [
  ask tickles [weapon-target
    if any? buddies in-radius 1.5 [
      ask buddies [
        set buddy-emotion (buddy-emotion + 5)
        set heading ([heading] of myself)
        set buddy-speed (buddy-speed + 2)]]]]
end

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
        set buddy-speed (buddy-speed + mouse-speed * 10)]]]]
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

to rocket-launcher-move
  ifelse (count rocket-launchers = 0) [change-weapon
    create-rocket-launchers 1 [set size 4.7]] [
  ask rocket-launchers [weapon-target]
  if mouse-down? [
    every 1 [ask rocket-launchers [
        hatch-rockets 1 [set size 2.6]]]]]
end

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
          set grenade-speed (abs (xcor - [xcor] of one-of buddies) / 65)]]]]]
end

to mines-create
  ifelse (count hands = 0) [change-weapon
    create-hands 1 [set size 3]] [
  ask hands [weapon-target]
  if mouse-down? [
    every .5 [ask hands [
        hatch-mines 1 [set size 2.2]]]]]
end

to bombs-create
  ifelse (count hands = 0) [change-weapon
    create-hands 1 [set size 3]] [
  ask hands [weapon-target]
  if mouse-down? [
    ask hands [
      hatch-bombs 1 [
        set size 3
        set bomb-timer 330
        hatch-targets 1 [
          ht
          create-link-from myself]
        while [mouse-down?] [
          set bomb-speed [link-length] of one-of links / 80
          ask targets [setxy mouse-xcor mouse-ycor]]
        face one-of targets
        ask targets [die]]]]]
end
  
to god-hand-move
  ifelse (count god-hands = 0) [change-weapon
    create-god-hands 1 [set size 4]] [
  ask god-hands [weapon-target]
    if mouse-down? [
      every .03 [ask god-hands [
        hatch-explosions 3 [
          set explosion-timer 50
          set heading random 360
          fd 1.4]
        if any? buddies in-radius 6 [
          ask buddies [
            set buddy-emotion (buddy-emotion - 1)
            set buddy-speed (buddy-speed + 300)
            face myself
            set heading (heading + 180)]]]]]]
end

to bullet-move
  ask bullets [
    if any? buddies in-radius 3 [
      ask buddies [
        set buddy-emotion (buddy-emotion - .4)
        set heading ([heading] of myself)
      	set buddy-speed (buddy-speed + 2)]
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
      die]
    ifelse can-move? 1 [fd .41 
      set extinguish-timer (extinguish-timer - 1)] [die]
    if extinguish-timer <= 0 [die]]
end

to rocket-move
  ask rockets [
    if any? buddies in-radius 4 [
      ask buddies [
        set buddy-emotion (buddy-emotion - 20)
        set buddy-speed (buddy-speed + 500)
        set heading ([heading] of myself)]
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
      explode 25]
    if can-move? grenade-speed and ycor > (min-pycor + 1) [
      fd grenade-speed
      set grenade-speed (grenade-speed * 99 / 100)]]
end

to mine-move
  ask mines [
    if any? buddies in-radius 2 [
      ask buddies [
        set buddy-emotion (buddy-emotion - 6)
        set buddy-speed (buddy-speed + 200)
        face myself
        set heading (heading + 180)]
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
      explode 30]
    if can-move? bomb-speed and ycor > (min-pycor + 1) [
      fd bomb-speed
      set bomb-speed (bomb-speed * 99 / 100)]]
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
      if abs [pxcor] of patch-ahead 1 = max-pxcor[
        set heading (- heading)]
      if abs [pycor] of patch-ahead 1 = max-pycor[
        set heading (180 - heading)]
      fd 1
      set buddy-speed (buddy-speed - (sqrt buddy-speed))]]
end

to explosion-fade
  ask explosions [set size (explosion-timer / 3)
                  set color (scale-color red explosion-timer 50 0)
                  set explosion-timer (explosion-timer - 1.5)
                  if explosion-timer <= 0 [die]]
end

to weapon-target
  setxy mouse-xcor mouse-ycor
  if any? buddies [face one-of buddies]
end
  
to change-weapon
  ask turtles with [breed != buddies and 
                    breed != bullets and 
                    breed != fireballs and
                    breed != grenades and
                    breed != rockets and
                    breed != mines and
                    breed != bombs and
                    breed != explosions] [die]
end

to explode [strength]
  hatch-explosions 1 [set explosion-timer strength
                      set heading random 360]
  die
end

to gravity-move
  if Gravity = true [if ycor > (min-pycor + size * .3) [set ycor (ycor - .065)]]
end 

to-report square [x]
  report x * x
end

to-report emotions
  let x [buddy-emotion] of one-of buddies
  ifelse x > 300 [report "VERY Happy"] [
    ifelse x > 20 [report "Happy"] [
      ifelse x < -300 [report "VERY Sad"] [
        ifelse x < -20 [report "Sad"] [
          report "BORED"]]]]
end

to buy-weapon
  let weapons-not-bought (filter [not (member? ? weapons-bought)] weapons)
  let bought-weapon (user-one-of "Which weapon would you like to buy?" weapons-not-bought)
  set weapons-bought lput bought-weapon weapons-bought
end

to select-weapon
  set weapon user-one-of "Which weapon do you want to use?" weapons-bought
end

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
52
80
85
Setup
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
87
52
196
85
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
46
373
149
406
Gravity
Gravity
0
1
-1000

BUTTON
117
172
198
205
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
172
115
205
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
221
197
269
12

MONITOR
48
293
147
338
Buddy's Emotion
emotions
17
1
11

BUTTON
35
101
182
134
Buy A New Weapon
buy-weapon
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
35
135
182
168
Choose A New Weapon
select-weapon
NIL
1
T
OBSERVER
NIL
NIL
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

Credits to the bounce example in the NetLogo library
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

bomb
true
0
Polygon -6459832 true false 148 115 150 100 157 92 166 87 176 85 185 85 195 89 204 97 202 102 198 102 195 99 190 94 181 92 169 93 163 95 159 98 155 106 153 117
Circle -7500403 true true 108 108 85
Rectangle -7500403 true true 143 98 164 112
Polygon -2674135 true false 200 96 199 95 203 86 205 97 211 89 212 99 218 103 208 103 211 112 204 108 199 112 199 102 189 107 192 100 186 95 193 96 192 86

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
true
0
Circle -2674135 false false 135 135 30
Line -2674135 false 120 150 180 150
Line -2674135 false 150 120 150 180

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

@#$#@#$#@
0
@#$#@#$#@
