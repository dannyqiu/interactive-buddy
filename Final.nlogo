globals [mouse-oldx mouse-oldy mouse-speed
  weapon-number weapons]

breed [buddies buddy]
breed [tickles tickle]
breed [punches punch]
breed [pistols pistol]
breed [machine-guns machine-gun]
breed [shotguns shotgun]
breed [flame-throwers flame-thrower]
breed [rocket-launchers rocket-launcher]
breed [grenade-launchers grenade-launcher]
breed [mines mine]
breed [bombs bomb]

breed [bullets bullet]
breed [fireballs fireball]
breed [grenades grenade]
breed [rockets rocket]

breed [explosions explosion]

buddies-own [flame-timer]
fireballs-own [extinguish]
explosions-own [explosion-timer]

to setup
  ca
  ask patches with [count neighbors != 8] [set pcolor blue]
  create-buddies 1 [set heading 0 set shape "sad buddy" set size 15]
  
  set-default-shape tickles "feather"
  set-default-shape punches "fist"
  set-default-shape pistols "pistol"
  set-default-shape machine-guns "machine gun"
  set-default-shape shotguns "shotgun"
  set-default-shape flame-throwers "flame thrower"
  set-default-shape rocket-launchers "rocket launcher"
  ;set-default-shape grenade-launchers "grenade launcher"
  set-default-shape mines "mine"
  ;set-default-shape bombs "bomb"
  
  set-default-shape bullets "bullet"
  set-default-shape fireballs "fire"
  set-default-shape rockets "rocket"
  set-default-shape grenades "grenade"
  
  set-default-shape explosions "explosion"
  
  set weapons (list "Tickle" "Punch" "Pistol" "Machine Gun" "Shotgun" "Flame Thrower" "Rocket Launcher" "Grenade Launcher" "Mines" "Bombs")
end

to play
  if Gravity = true [ask buddies [if ycor > (min-pycor + size * .27) [setxy xcor ycor - .065]]]
  if weapon = "Tickle" [tickle-move]
  if weapon = "Punch" [punch-move]
  if weapon = "Pistol" [pistol-move]
  if weapon = "Machine Gun" [machine-gun-move]
  if weapon = "Shotgun" [shotgun-move]
  if weapon = "Flame Thrower" [flame-thrower-move]
  if weapon = "Rocket Launcher" [rocket-launcher-move]
  if weapon = "Grenade Launcher" [grenade-launcher-move]
  
  bullet-move
  fireball-move
  rocket-move
  ;grenade-move
  
  buddy-effects
  explosion-fade
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
    create-pistols 1 [set size 6]] [
  ask pistols [weapon-target]
  if mouse-down? [
    every .35 [ask pistols [hatch-bullets 1 [set size 3]]]]]
end

to machine-gun-move
  ifelse (count machine-guns = 0) [change-weapon
    create-machine-guns 1 [set size 8.5]] [
  ask machine-guns [weapon-target]
  if mouse-down? [
    every .05 [ask machine-guns [hatch-bullets 1 [set size 3]]]]]
end

to shotgun-move
  ifelse (count shotguns = 0) [change-weapon
    create-shotguns 1 [set size 9]] [
  ask shotguns [weapon-target]
  if mouse-down? [
    every .65 [ask shotguns [hatch-bullets 6 [set size 3 rt random 21 - 10]]]]]
end

to flame-thrower-move
  ifelse (count flame-throwers = 0) [change-weapon
    create-flame-throwers 1 [set size 10]] [
  ask flame-throwers [weapon-target]
  if mouse-down? [
    every .03 [ask flame-throwers [hatch-fireballs 2 [set size 4.5 
                                                      set heading (heading - 10 + random 21)
                                                      set extinguish 25]]]]]
end

to rocket-launcher-move
  ifelse (count rocket-launchers = 0) [change-weapon
    create-rocket-launchers 1 [set size 10]] [
  ask rocket-launchers [weapon-target]
  if mouse-down? [
    every 1 [ask rocket-launchers [hatch-rockets 1 [set size 7]]]]]
end

to grenade-launcher-move
  ifelse (count grenade-launchers = 0) [change-weapon
    create-grenade-launchers 1 [set size 10]] [
  ask grenade-launchers [weapon-target]
  if mouse-down? [
    every .7 [ask grenade-launchers [hatch-grenades 1 [set size 5]]]]]
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
    ifelse can-move? 1 [fd .5] [die]]
end

to fireball-move
  ask fireballs [
    if any? buddies in-radius 4 [
      ask buddies [set flame-timer (flame-timer + 1.5)]
      die]
    ifelse can-move? 1 [fd 1 set extinguish (extinguish - 1)] [die]
    if extinguish <= 0 [die]]
end

to rocket-move
  ask rockets [
    if any? buddies in-radius 4 [
      hatch-explosions 1 [set explosion-timer 49
                          set heading random 360]
      die]
    ifelse can-move? 1.2 [jump 1.2] [die]]
end

to buddy-effects
  ask buddies [
    if flame-timer > 0 [
      set shape "buddy on fire"
      set flame-timer (flame-timer - .5)]]
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
                    breed != explosions] [die]
end

to explosion-fade
  ask explosions [set size explosion-timer
                  set color (scale-color red explosion-timer 49 0)
                  set explosion-timer (explosion-timer - 1.5)
                  if explosion-timer <= 0 [die]]
end

to-report square [x]
  report x * x
end
  
to next-weapon
  set weapon-number position weapon weapons 
  set weapon-number (weapon-number + 1)
  if weapon-number > 9 [set weapon-number 0]
  set weapon item weapon-number weapons
end
  
to previous-weapon
  set weapon-number (position weapon weapons)
  set weapon-number (weapon-number - 1)
  if weapon-number < 0 [set weapon-number 9]
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
189
193
Weapon
Weapon
"Tickle" "Punch" "Pistol" "Machine Gun" "Shotgun" "Flame Thrower" "Rocket Launcher" "Grenade Launcher" "Mines" "Bombs"
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

mine
true
0
Circle -7500403 true true 75 75 150
Circle -2674135 true false 116 116 67
Circle -10899396 true false 135 135 30

pistol
true
0
Polygon -7500403 true true 91 52 115 45 139 51 139 166 239 195 238 239 149 216 142 220 137 225 135 234 135 241 90 244
Polygon -7500403 false true 127 164 140 164 148 162 154 158 158 152 165 137 132 138
Line -7500403 true 143 138 142 146
Line -7500403 true 142 147 148 155

rocket
true
0
Rectangle -7500403 true true 120 105 180 225
Polygon -7500403 true true 181 105 160 77 139 77 119 105
Circle -7500403 true true 141 68 20
Polygon -7500403 true true 120 180 105 225 120 225
Polygon -7500403 true true 180 180 195 225 180 225
Polygon -7500403 true true 119 105 140 77 161 77 181 105
Circle -7500403 true true 139 68 20

rocket launcher
true
0
Rectangle -7500403 true true 165 225 210 240
Rectangle -7500403 true true 165 105 195 120
Rectangle -7500403 true true 120 60 165 256
Rectangle -7500403 true true 105 105 120 120
Polygon -7500403 true true 120 60 126 31 159 31 165 60
Circle -16777216 true false 108 108 10
Line -7500403 true 108 113 119 113
Line -7500403 true 113 118 113 108
Polygon -7500403 false true 188 225 188 207 185 204 180 201 172 199 162 197 148 196 155 223 156 225
Line -7500403 true 166 224 180 212

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

shotgun
true
1
Circle -7500403 false false 154 168 28
Line -16777216 false 150 135 270 135
Polygon -2674135 true true 136 136 136 18 164 18 165 137
Polygon -6459832 true false 136 136 165 136 165 193 168 204 172 208 179 213 180 220 177 224 178 235 188 274 156 277 155 229 158 225 160 221 159 218 155 215 144 196 139 179
Line -16777216 false 150 135 150 18
Line -7500403 false 165 182 167 186
Line -7500403 false 168 186 171 187
Line -7500403 false 171 187 175 186

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
