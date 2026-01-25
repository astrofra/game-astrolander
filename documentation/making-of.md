# The Making of Astrolander

I developed Astrolander between 2011 and 2012, on my personal time. I kept a
development log on TigSource.com, an indie dev forum, sharing screenshots,
playable prototypes, and technical notes. That ongoing log and the community
feedback gave me steady energy and helped shape both design and gameplay.

## Why this game
I wanted to revisit a kind of game that always struck me for its difficulty
and immersive potential. Astrolander draws from Lunar Lander (Atari, 1979),
Gravity Force (Amiga), and Uchuusen (Chris Nimmo, 2010). They all center on
gravity and inertia, but they also bring frustration. My goal was clear: keep
physics as the core of the fun while reducing frustration and making controls
readable, especially on tablets and smartphones.

## The control principle
I chose a minimal two-button control scheme. Each thruster activation applies
two forces:
- a linear force on the ship's center of mass
- a force applied at an offset point, generating torque and rotation

The ship responds to real physics, but I also added an auto-align function. It
applies corrective torque to avoid ending up upside down. That small assist
keeps the piloting feel without pure frustration.

## The sense of presence
While testing, I observed a strong sensorimotor effect: when the ship grazes
walls, players move their bodies, anticipate, tense up. Using forces rather
than impulses, the perceived weight of the ship, and the sound design all
reinforce that presence. Those observations pushed me to read work on
immersion and presence in virtual environments, including Sas and O'Hare
(2003), which validated many of my choices.

## The engine and technical context
The whole game was built on GameStart, a 3D engine I also used professionally
at the time. I used that experience to build a full project: physics,
rendering, shaders, assets, UI, and game logic.

### Update vs physics separation
The architecture relies on a clear separation between input capture and
physics computation. Inputs are read in the scene update callback, while
forces are applied in the physics callback. That decoupling keeps controls out
of the solver and ensures key behaviors (like auto-align) stay stable even
when render cadence varies.

### Camera smoothing
I also had to deal with micro-stutters every two or three seconds during
lateral camera follow. The cause was display sync on modern OSes, which can
introduce a periodic offset between measured time and the displayed frame. I
worked around it by smoothing the player position over one second and using
that filtered position for the camera. The result is a slight latency, much
less noticeable than regular stutters.

## Building the game, iteration by iteration
The project evolved over two years. Each iteration added features and pushed
the game toward a higher level of polish.

### Foundations
Early versions established the core: ship controls, a minimal HUD for fuel and
damage, elastic camera, thruster sounds, and temporary music. The goal was to
validate the piloting feel first.

### Goals and win conditions
I then integrated win and loss conditions, along with artifact collection.
That structure gave a clear progression framework for players and for
community testing.

### Minimap, obstacles, and levels
A minimap made navigation more comfortable by showing the player and
artifacts. I added moving obstacles (lasers, rotating barriers) and built 25
levels. I also tested a PNG-based level generator, though it was not kept as a
runtime feature.

### UI and polish
The UI was fully redesigned: title screen, menus, level select, in-game pause.
I added a mouse cursor for PC, improved mobile touch responsiveness, added
save/load, and integrated a dozen music tracks. I also added end-of-level
screens with score and bonuses.

### Narrative and illustrations
Camille Coq contributed 2D illustrations and a narrative concept: the
character searches for body parts scattered across the levels. That story gave
emotional meaning to progression and strengthened attachment to the ship.
Aside from music and those illustrations, I created everything myself: game
design, code, 3D graphics, and shaders.

## Community and feedback
TigSource was a key driver. Tests and discussion on the forum helped balance
difficulty, adjust controls, and fix friction points. I learned how to talk
with a community, prioritize feedback, and iterate quickly.

## What the project gave me
Astrolander was selected on Steam Greenlight, but I did not pursue
commercialization due to administrative constraints and added feature demands.
The project still gave me:
- a full end-to-end production experience
- deep knowledge of physics systems and Android development
- practice in project management and feedback-driven iteration

I also used the project as a teaching tool: interns tried level design, and
some of their ideas made it into the final version. That approach later became
the basis for workshops with CESI engineering students a decade later.

## Closing
Astrolander gave me a complete view of game creation: technical, design,
narrative, and community-facing. It taught me how to work with real
constraints, choose priorities, and turn technical frustrations into creative
solutions :)