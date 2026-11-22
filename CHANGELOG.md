# Changelog

## 2.0.0

### Two versions now: enable one
The Workshop item now holds two versions. They cannot be enabled together.

- **Water Physicality - Viewpoint (3D + isometric)** (Mod ID `WaterPhysicality`): both kinds of water. Real 3D water and streams in Viewpoint's 3D view, and the painted water in the isometric view. Without Viewpoint it shows only the isometric water.
- **Water Physicality - Flat** (Mod ID `WaterPhysicalityFlat`): isometric water only. Lighter: no 3D models and no Java part.

Existing saves keep working with the Viewpoint version, with or without Viewpoint. Servers: use the Mod ID of the version you want.

### Requirements
- 0.1.1 required Project Viewpoint, ZombieBuddy and Take A Bath And Shower. 2.0.0 requires nothing.
- Project Viewpoint and ZombieBuddy are only needed for the 3D water (Viewpoint version).
- Take A Bath And Shower or Lifestyle: Hobbies are optional.

### New
- Isometric water. 0.1.1 drew water only in Viewpoint's 3D view. Now sinks and tubs also show their water and tap stream in the isometric view, painted into the fixture's own art so it sorts and fades with the fixture.
- Lifestyle: Hobbies support. Tub water rises while the tub fills, stays while you bathe and drains afterwards, with Lifestyle's steam and bubbles drawn on top. The shower spray runs while you shower. Other players see it too.
- Works without any bath mod: sinks, tubs and showers show water and a stream while a normal water action (drinking, washing, filling a container) runs on them. Drinking or washing at a tub runs its tap.
- Take A Bath And Shower and Lifestyle: Hobbies are detected at runtime. With both enabled, Take A Bath And Shower takes over bathing.
- Drinking fountains: the stream is now an arcing jet from the bubbler.

### Improved
- Sink water and tap streams are re-fitted to each sink model. Streams now start at the faucet's spout; on several sinks they were up to 6 cm off.
- Large industrial sinks: the water sat about 20 cm above the basin and the stream came from the wrong spot. Both now fit the sink.
- Sinks no longer fill to the brim. In 0.1.1 a sink in use filled to 80%, and on about a dozen sinks (among them the double kitchen sink, the beige bathroom sink and a drinking fountain) that put the water above the rim. A sink in use now fills halfway, inside the basin.
- The water surface no longer pokes through the outer wall of several sinks.
- A filled tub no longer refills from empty every time you come near it or load a save next to it: it shows its real level at once.
- A brief hitch or chunk reload no longer drains a tub's water and refills it.
- Multiplayer: after the server resent a chunk, the mod kept using the old copy of its fixtures, so sinks there could stop showing their tap (and tubs stop following their level) until you walked away and back.
- Multiplayer: the tap relay now tells only players nearby instead of everyone on the server, and no longer echoes back to the player using the tap (that kept their own stream running a moment after they stopped).

## 0.1.1
- Multiplayer: sink taps are shared. When a player uses a sink, everyone nearby sees the tap stream. The server needs the mod enabled for this.
- The in-game mod description no longer says taps are unsupported.
- Author name added to the mod info.

## 0.1.0
- First release: 3D water for Project Viewpoint. Bathtubs fill and drain with Take A Bath And Shower, with a stream from the tub tap while filling. Sinks show water and a tap stream while used. Showers get a spray from the shower head.
- Required Project Viewpoint, ZombieBuddy and Take A Bath And Shower.
