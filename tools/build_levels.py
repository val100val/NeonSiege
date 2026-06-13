"""
Build all 20 NeonSiege maze levels: generate geometry, validate (BFS path
exists + is winding + buildable space remains), preview ASCII, and emit Swift
for LevelLibrary.swift.

Run:  python tools/build_levels.py            # validate + preview
      python tools/build_levels.py --emit     # write Swift to stdout
"""
from __future__ import annotations
import sys
from maze_gen import (hwall, vwall, rect_border, diamond, serpentine, switchback,
                      spiral, concentric_rings, diamond_lattice, rooms,
                      braid_maze, bfs_path_len)

# Each level is authored in TOP-DOWN coords (r=0 = top row). We convert to
# engine coords (r=0 = bottom) when emitting/validating.


def L(**kw):
    return kw


def carve(walls, cells):
    for x in cells:
        walls.discard(x)
    return walls


def mouth(walls, cell, cols, rows):
    """Ensure a cell and a short tunnel toward map interior is open."""
    c, r = cell
    walls.discard(cell)
    if c == 0:
        carve(walls, [(1, r), (2, r)])
    elif c == cols - 1:
        carve(walls, [(cols - 2, r), (cols - 3, r)])
    if r == 0:
        carve(walls, [(c, 1), (c, 2)])
    elif r == rows - 1:
        carve(walls, [(c, rows - 2), (c, rows - 3)])
    return walls


# ---------------------------------------------------------------------------
# Level definitions
# ---------------------------------------------------------------------------

def build_levels():
    levels = []

    # 1 — Boot Camp: gentle S, mostly open to teach tower-mazing.
    cols, rows = 26, 14
    w = set()
    w |= hwall(5, 0, 17)
    w |= hwall(9, 8, 25)
    levels.append(L(name="Boot Camp", subtitle="Shape the maze. Hold the line.",
        cols=cols, rows=rows, walls=w, spawns=[(0, 7)], core=(25, 7),
        portals=[], credits=200, shards=10, wave="makeWaves", count=8, lid=1))

    # 2 — Twin Streams: two lanes split by a central spine, merge at the core.
    cols, rows = 28, 14
    w = set()
    w |= vwall(13, 0, 5) | vwall(13, 8, 13)
    w |= hwall(6, 4, 9) | hwall(7, 4, 9)
    w |= hwall(4, 18, 24) | hwall(9, 18, 24)
    levels.append(L(name="Twin Streams", subtitle="Two fronts. One core.",
        cols=cols, rows=rows, walls=w, spawns=[(0, 0), (0, 13)], core=(27, 7),
        portals=[], credits=240, shards=8, wave="makeWaves", count=10, lid=2))

    # 3 — The Spiral: concentric rings with rotating doorways = a true spiral
    # corridor winding inward to the core at the eye.
    cols, rows = 26, 16
    w, center = concentric_rings(cols, rows, n=5, gap_size=2)
    levels.append(L(name="The Spiral", subtitle="The long way in.",
        cols=cols, rows=rows, walls=w, spawns=[(0, 8)], core=center,
        portals=[], credits=280, shards=8, wave="makeWaves", count=10, lid=3,
        spawn_link=True))

    # 4 — Crossfire: four corner gates spiral inward to a central core.
    cols, rows = 26, 16
    w, center = concentric_rings(cols, rows, n=4, gap_size=2)
    levels.append(L(name="Crossfire", subtitle="Surrounded on all sides.",
        cols=cols, rows=rows, walls=w, spawns=[(0, 0), (25, 0), (0, 15), (25, 15)],
        core=center, portals=[], credits=300, shards=8, wave="makeWaves",
        count=12, lid=4))

    # 5 — Glitch Gate: serpentine + a portal pair that warps lanes.
    cols, rows = 28, 15
    w = serpentine(cols, rows, n_ribs=4, first_open='right')
    levels.append(L(name="Glitch Gate", subtitle="Reality is optional here.",
        cols=cols, rows=rows, walls=w, spawns=[(0, 2), (0, 12)], core=(27, 7),
        portals=[((4, 2), (23, 12)), ((4, 12), (23, 2))], credits=320, shards=8,
        wave="makeWaves", count=12, lid=5, spawn_link=True, core_link=True))

    # 6 — The Gauntlet: long horizontal serpentine, 6 ribs.
    cols, rows = 30, 15
    w = serpentine(cols, rows, n_ribs=6, first_open='right')
    levels.append(L(name="The Gauntlet", subtitle="Six gates. No mercy.",
        cols=cols, rows=rows, walls=w, spawns=[(0, 1)], core=(29, 13),
        portals=[], credits=320, shards=8, wave="makeWaves", count=12, lid=6,
        spawn_link=True, core_link=True))

    # 7 — Parallax: vertical switchback (left->right vertical snake).
    cols, rows = 28, 16
    w = switchback(cols, rows, n_ribs=6, first_open='bottom')
    levels.append(L(name="Parallax", subtitle="Up, down, repeat.",
        cols=cols, rows=rows, walls=w, spawns=[(1, 0)], core=(26, 15),
        portals=[], credits=340, shards=8, wave="makeWaves", count=12, lid=7,
        spawn_link=True, core_link=True))

    # 8 — Reactor Ring: concentric rings, core in the heart.
    cols, rows = 28, 16
    w, center = concentric_rings(cols, rows, n=4, gap_size=2)
    levels.append(L(name="Reactor Ring", subtitle="Breach every ring.",
        cols=cols, rows=rows, walls=w, spawns=[(0, 0), (27, 0), (0, 15), (27, 15)],
        core=center, portals=[], credits=360, shards=8, wave="makeWaves",
        count=13, lid=8))

    # 9 — Vortex Run: ring spiral with a lateral portal that swaps the two
    # incoming lanes (a warp, not a core shortcut).
    cols, rows = 28, 16
    w, center = concentric_rings(cols, rows, n=4, gap_size=2)
    levels.append(L(name="Vortex Run", subtitle="The lanes betray you.",
        cols=cols, rows=rows, walls=w, spawns=[(0, 2), (0, 13)], core=center,
        portals=[((1, 2), (1, 13))], credits=360, shards=8,
        wave="makeWaves", count=14, lid=9, spawn_link=True, core_link=True))

    # 10 — Final Protocol: a long vertical switchback, three gates + a lateral
    # warp early in the run.
    cols, rows = 30, 16
    w = switchback(cols, rows, n_ribs=7, first_open='bottom')
    levels.append(L(name="Final Protocol", subtitle="Everything. All at once.",
        cols=cols, rows=rows, walls=w, spawns=[(1, 0), (1, 15)],
        core=(28, 8), portals=[((3, 0), (3, 15))], credits=400, shards=8,
        wave="makeWaves", count=15, lid=10, spawn_link=True, core_link=True))

    # 11 — The Switchback: dense vertical switchback, 8 ribs.
    cols, rows = 32, 16
    w = switchback(cols, rows, n_ribs=8, first_open='bottom')
    levels.append(L(name="The Switchback", subtitle="Eight gates. Zero shortcuts.",
        cols=cols, rows=rows, walls=w, spawns=[(1, 0)], core=(30, 15),
        portals=[], credits=440, shards=8, wave="makeEpicWaves", count=13, lid=11,
        spawn_link=True, core_link=True))

    # 12 — Diamond Field: staggered diamond lattice.
    cols, rows = 30, 16
    w = diamond_lattice(cols, rows, spacing_c=6, spacing_r=4, k=1)
    levels.append(L(name="Diamond Field", subtitle="Cut by crystal.",
        cols=cols, rows=rows, walls=w, spawns=[(0, 1), (0, 14)], core=(29, 8),
        portals=[], credits=460, shards=8, wave="makeEpicWaves", count=13, lid=12))

    # 13 — The Hive: honeycomb chambers, three mouths.
    cols, rows = 30, 16
    w = rooms(cols, rows, cellw=7, cellh=5)
    levels.append(L(name="The Hive", subtitle="They pour from three mouths.",
        cols=cols, rows=rows, walls=w, spawns=[(0, 1), (0, 8), (0, 14)],
        core=(29, 8), portals=[], credits=480, shards=8, wave="makeEpicWaves",
        count=13, lid=13, spawn_link=True, core_link=True))

    # 14 — Mirror Maze: mirrored serpentine + a flipping portal.
    cols, rows = 30, 16
    w = serpentine(cols, rows, n_ribs=6, first_open='left')
    levels.append(L(name="Mirror Maze", subtitle="Left is right. Right is wrong.",
        cols=cols, rows=rows, walls=w, spawns=[(0, 13)], core=(29, 2),
        portals=[], credits=500, shards=8, wave="makeEpicWaves",
        count=14, lid=14, spawn_link=True, core_link=True))

    # 15 — Pinwheel: rotational ring maze, four corner gates.
    cols, rows = 30, 16
    w, center = concentric_rings(cols, rows, n=4, gap_size=2)
    # rotate flavour: add four spokes for a pinwheel look (with passages)
    w |= vwall(center[0], 0, 2) | hwall(center[1], cols - 3, cols - 1)
    levels.append(L(name="Pinwheel", subtitle="The whole map spins against you.",
        cols=cols, rows=rows, walls=w, spawns=[(0, 0), (29, 0), (0, 15), (29, 15)],
        core=center, portals=[], credits=520, shards=8, wave="makeEpicWaves",
        count=14, lid=15))

    # 16 — Catacombs: a long horizontal serpentine of burial corridors with a
    # lateral crypt warp.
    cols, rows = 32, 16
    w = serpentine(cols, rows, n_ribs=6, first_open='right')
    levels.append(L(name="Catacombs", subtitle="Narrow doors. Heavy traffic.",
        cols=cols, rows=rows, walls=w, spawns=[(0, 1)], core=(31, 14),
        portals=[], credits=540, shards=8, wave="makeEpicWaves",
        count=14, lid=16, spawn_link=True, core_link=True))

    # 17 — Twin Vortex: double spiral feel via two ring clusters + portal bridge.
    cols, rows = 32, 16
    w = set()
    w |= rect_border(2, 2, 13, 13)
    carve(w, [(13, 7), (13, 8)])           # right doorway of left chamber
    w |= rect_border(6, 5, 9, 10)
    carve(w, [(6, 7), (6, 8)])
    w |= rect_border(18, 2, 29, 13)
    carve(w, [(18, 7), (18, 8)])           # left doorway of right chamber
    w |= rect_border(22, 5, 25, 10)
    carve(w, [(25, 7), (25, 8)])
    levels.append(L(name="Twin Vortex", subtitle="Two storms, one eye.",
        cols=cols, rows=rows, walls=w, spawns=[(0, 0), (0, 15)], core=(31, 8),
        portals=[((8, 8), (23, 8))], credits=560, shards=8, wave="makeEpicWaves",
        count=15, lid=17, spawn_link=True, core_link=True))

    # 18 — The Crucible: kill-box rings around the core, four gates + portal shaft.
    cols, rows = 30, 16
    w, center = concentric_rings(cols, rows, n=3, gap_size=2)
    w |= rect_border(center[0] - 2, center[1] - 2, center[0] + 2, center[1] + 2)
    carve(w, [(center[0], center[1] - 2), (center[0], center[1] + 2)])
    levels.append(L(name="The Crucible", subtitle="Forge your last stand.",
        cols=cols, rows=rows, walls=w, spawns=[(0, 0), (29, 0), (0, 15), (29, 15)],
        core=center, portals=[((center[0], 0), (center[0], 15))], credits=600,
        shards=8, wave="makeEpicWaves", count=15, lid=18, core_link=True))

    # 19 — Labyrinth of Echoes: the longest serpentine in the game (7 ribs) with
    # an echo warp that loops you backward.
    cols, rows = 32, 17
    w = serpentine(cols, rows, n_ribs=7, first_open='right')
    levels.append(L(name="Labyrinth of Echoes", subtitle="Every step repeats.",
        cols=cols, rows=rows, walls=w, spawns=[(0, 1)], core=(31, 15),
        portals=[], credits=640, shards=8, wave="makeEpicWaves",
        count=15, lid=19, spawn_link=True, core_link=True))

    # 20 — Omega Citadel: grand concentric fortress, four armies, OMEGA PRIME at
    # the eye. The portal is a lateral warp on the outer wall (no shortcut).
    cols, rows = 32, 17
    w, center = concentric_rings(cols, rows, n=5, gap_size=2)
    levels.append(L(name="Omega Citadel", subtitle="OMEGA PRIME awaits.",
        cols=cols, rows=rows, walls=w, spawns=[(0, 0), (31, 0), (0, 16), (31, 16)],
        core=center, portals=[((1, 1), (1, 15))], credits=760,
        shards=8, wave="makeEpicWaves", count=16, finale=True, lid=20))

    return levels


# ---------------------------------------------------------------------------
# Post-processing: connect spawns/core, convert coords, validate, preview
# ---------------------------------------------------------------------------

def finalize(level):
    cols, rows = level['cols'], level['rows']
    w = set(level['walls'])
    # clear special cells & carve mouths so everything connects
    for s in level['spawns']:
        mouth(w, s, cols, rows)
    mouth(w, level['core'], cols, rows)
    for a, b in level['portals']:
        w.discard(a)
        w.discard(b)
    # keep walls in-bounds
    w = {(c, r) for (c, r) in w if 0 <= c < cols and 0 <= r < rows}
    level['walls'] = w
    return level


def to_engine(cell, rows):
    c, r = cell
    return (c, rows - 1 - r)


def validate(level):
    cols, rows = level['cols'], level['rows']
    we = {to_engine(x, rows) for x in level['walls']}
    spawns = [to_engine(s, rows) for s in level['spawns']]
    core = to_engine(level['core'], rows)
    portals = [(to_engine(a, rows), to_engine(b, rows)) for a, b in level['portals']]
    reachable, mlen, dist = bfs_path_len(cols, rows, we, spawns, core, portals)
    total = cols * rows
    buildable = total - len(we) - 1 - len(spawns) - 2 * len(portals)
    return reachable, mlen, buildable, cols, rows


def preview(level):
    cols, rows = level['cols'], level['rows']
    walls = level['walls']
    spawns = set(level['spawns'])
    core = level['core']
    pset = {}
    for i, (a, b) in enumerate(level['portals']):
        pset[a] = chr(ord('a') + i)
        pset[b] = chr(ord('A') + i)
    out = []
    for r in range(rows):           # top-down already
        line = []
        for c in range(cols):
            cell = (c, r)
            if cell in spawns:
                line.append('S')
            elif cell == core:
                line.append('C')
            elif cell in pset:
                line.append(pset[cell])
            elif cell in walls:
                line.append('#')
            else:
                line.append('.')
        out.append(''.join(line))
    return '\n'.join(out)


# ---------------------------------------------------------------------------
# Swift emit
# ---------------------------------------------------------------------------

def cell_literal(cell, rows):
    c, r = to_engine(cell, rows)
    return f"Cell(c: {c}, r: {r})"


def emit_swift(level):
    rows = level['rows']
    name_id = level['name'][0].lower() + level['name'][1:].replace(' ', '')
    # build sorted wall list (engine coords)
    we = sorted({to_engine(x, rows) for x in level['walls']}, key=lambda p: (p[1], p[0]))
    wall_items = ', '.join(f"Cell(c: {c}, r: {r})" for c, r in we)
    spawns = ', '.join(cell_literal(s, rows) for s in level['spawns'])
    core = cell_literal(level['core'], rows)
    portals = ', '.join(f"({cell_literal(a, rows)}, {cell_literal(b, rows)})"
                        for a, b in level['portals'])
    finale = level.get('finale', False)
    if level['wave'] == 'makeEpicWaves':
        wave_call = (f"makeEpicWaves(count: {level['count']}, levelId: {level['lid']}"
                     + (", finale: true)" if finale else ")"))
    else:
        wave_call = f"makeWaves(count: {level['count']}, levelId: {level['lid']})"
    ident = IDENT[level['lid'] - 1]
    return f'''    private static let {ident} = LevelDef(
        id: {level['lid']},
        name: "{level['name']}",
        subtitle: "{level['subtitle']}",
        cols: {level['cols']}, rows: {level['rows']},
        walls: [{wall_items}],
        spawns: [{spawns}],
        core: {core},
        portalPairs: [{portals}],
        startCredits: {level['credits']},
        shards: {level['shards']},
        waves: {wave_call}
    )'''


IDENT = ["bootCamp", "twinStreams", "theSpiral", "crossfire", "glitchGate",
         "theGauntlet", "parallax", "reactorRing", "vortexRun", "finalProtocol",
         "theSwitchback", "diamondField", "theHive", "mirrorMaze", "pinwheel",
         "catacombs", "twinVortex", "theCrucible", "labyrinthOfEchoes",
         "omegaCitadel"]


def main():
    levels = [finalize(l) for l in build_levels()]
    emit = '--emit' in sys.argv
    ok = True
    for lv in levels:
        reachable, mlen, buildable, cols, rows = validate(lv)
        min_len = cols - 4 if lv['lid'] == 1 else cols   # level 1 is gentle by design
        status = 'OK ' if (reachable and mlen and mlen >= min_len and buildable > 40) else 'FAIL'
        if status == 'FAIL':
            ok = False
        if not emit:
            print(f"[{status}] {lv['lid']:2d} {lv['name']:<22} {cols}x{rows} "
                  f"pathlen={mlen} buildable={buildable} walls={len(lv['walls'])}")
            if status == 'FAIL' or '--show' in sys.argv:
                print(preview(lv))
                print()
    if emit:
        print(';\n'.join(emit_swift(lv) for lv in levels))
    if not ok and not emit:
        print("\n*** Some levels FAILED validation ***")
        sys.exit(1)


if __name__ == '__main__':
    main()
