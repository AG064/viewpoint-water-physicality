# Changelog

## 2.0.0

### Two versions now: enable one
The Workshop item now holds two versions. They cannot be enabled together.

- **Water Physicality - Viewpoint** (Mod ID `WaterPhysicality`): real 3D water and streams with Project Viewpoint, plus the isometric water. Without Viewpoint it simply shows the isometric water.
- **Water Physicality - Flat** (Mod ID `WaterPhysicalityFlat`): isometric water only. Lighter: no 3D models and no Java part.

Existing saves keep working with the Viewpoint version, with or without Viewpoint. Servers: use the Mod ID of the version you want.

### Requirements
- No required mods any more.
- Project Viewpoint and ZombieBuddy are only needed for the 3D water (Viewpoint version).
- Take A Bath And Shower is now optional.

### New
- Isometric water for the base game view: sinks and tubs show water and their tap stream painted into the fixture's own art, so it sorts and fades with the fixture and never spills over the rim or shows through walls and mirrors.
- Lifestyle: Hobbies support. Tub water rises while the tub fills, stays while you bathe and drains afterwards, with Lifestyle's steam and bubbles drawn on top. The shower spray runs while you shower. Other players see it too.
- Works without any bath mod: sinks, tubs and showers show water and a stream while a normal water action (drinking, washing, filling a container) runs on them.
- Drinking or washing at a tub runs its tap.
- Drinking fountains get an arcing jet from the bubbler.
- Take A Bath And Shower and Lifestyle: Hobbies are detected at runtime. With both enabled, Take A Bath And Shower takes over bathing.

### Fixed
- Sink tap streams start at each faucet's real spout. Before, several sinks had a stream floating under the arc of the faucet or starting too low.
- Large industrial sinks: the stream comes from the faucet spout instead of the sprayer post, and reaches the water.
- The beige bathroom sink (two of its four rotations) and one square kitchen sink: the water no longer sits above the rim.
- Double kitchen sink: the 3D water sat too low to be seen.
- Several sinks: the water surface no longer pokes through the outer wall as a thin line.
- Multiplayer: "someone is using this fixture" now goes only to players nearby, not the whole server, and is no longer echoed back to the player who sent it (that kept their tap running for a moment after they stopped).

## 0.1.1
- Multiplayer: sink taps are shared. When a player uses a sink, everyone nearby sees the tap stream. The server needs the mod enabled for this.
- The in-game mod description no longer says taps are unsupported.
- Author name added to the mod info.

## 0.1.0
- First release: 3D water for Project Viewpoint. Bathtubs fill and drain with Take A Bath And Shower, with a stream from the tub tap while filling. Sinks show water and a tap stream while used. Showers get a spray from the shower head.
- Required Project Viewpoint, ZombieBuddy and Take A Bath And Shower.
