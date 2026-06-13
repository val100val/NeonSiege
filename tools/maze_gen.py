"""
NeonSiege maze generators.

Coordinate system note: in the Swift engine, Cell(c, r) has r=0 at the BOTTOM
of the screen. We author here with a top-down grid (grid[0] = top row) and
convert to engine rows at emit time (r = rows-1 - top_row_index).

Every generator returns a set of (c, r_top) wall coordinates in TOP-DOWN space,
where r_top=0 is the top row. The level builder overlays spawns/core/portals and
the validator + codegen handle conversion to engine space.
"""
from __future__ import annotations
from collections import deque

# ---------------------------------------------------------------------------
# Low-level helpers (all in TOP-DOWN coordinates: (c, r) with r=0 at top)
# ---------------------------------------------------------------------------

def hwall(r, c1, c2):
    return {(c, r) for c in range(min(c1, c2), max(c1, c2) + 1)}

def vwall(c, r1, r2):
    return {(c, r) for r in range(min(r1, r2), max(r1, r2) + 1)}

def rect_border(c1, r1, c2, r2):
    s = set()
    s |= hwall(r1, c1, c2) | hwall(r2, c1, c2)
    s |= vwall(c1, r1, r2) | vwall(c2, r1, r2)
    return s

def diamond(c, r, k=1):
    s = set()
    for dr in range(-k, k + 1):
        span = k - abs(dr)
        for dc in range(-span, span + 1):
            s.add((c + dc, r + dr))
    return s


# ---------------------------------------------------------------------------
# Archetype generators
# ---------------------------------------------------------------------------

def serpentine(cols, rows, n_ribs, corridor=2, margin_top=0, margin_bot=0,
               first_open='right'):
    """Horizontal ribs that force a boustrophedon (snake) path.
    Ribs alternate which END is open, creating a long winding corridor.
    Corridor height = `corridor` rows between ribs."""
    walls = set()
    usable_top = margin_top
    usable_bot = rows - 1 - margin_bot
    # rib rows evenly spaced inside usable region
    span = usable_bot - usable_top
    open_side = first_open
    rib_rows = []
    step = (span) / (n_ribs + 1)
    for i in range(1, n_ribs + 1):
        r = usable_top + round(i * step)
        rib_rows.append(r)
    for r in rib_rows:
        if open_side == 'right':
            walls |= hwall(r, 0, cols - 3)        # open on the right
        else:
            walls |= hwall(r, 2, cols - 1)        # open on the left
        open_side = 'left' if open_side == 'right' else 'right'
    return walls


def switchback(cols, rows, n_ribs, first_open='bottom'):
    """Vertical ribs forcing a vertical snake (left->right march)."""
    walls = set()
    rib_cols = []
    step = cols / (n_ribs + 1)
    for i in range(1, n_ribs + 1):
        rib_cols.append(round(i * step))
    open_side = first_open
    for c in rib_cols:
        if open_side == 'bottom':
            walls |= vwall(c, 0, rows - 3)
        else:
            walls |= vwall(c, 2, rows - 1)
        open_side = 'top' if open_side == 'bottom' else 'bottom'
    return walls


def spiral(cols, rows, gap=2):
    """Inward rectangular spiral. Leaves a `gap`-wide corridor spiralling to the
    centre. Returns (walls, center) where center is the innermost open cell."""
    walls = set()
    c1, r1, c2, r2 = 1, 1, cols - 2, rows - 2
    ring = 0
    while c2 - c1 > 2 and r2 - r1 > 2:
        # draw three sides of a rectangle, leaving an entry gap so the corridor
        # threads inward
        top = hwall(r1, c1, c2)
        bot = hwall(r2, c1, c2)
        left = vwall(c1, r1, r2)
        right = vwall(c2, r1, r2)
        if ring % 2 == 0:
            # open a gap on the right end of the bottom wall
            bot -= {(c2 - 1, r2), (c2, r2)}
        else:
            top -= {(c1, r1), (c1 + 1, r1)}
        walls |= top | bot | left | right
        # carve next inner ring offset by gap+1
        c1 += gap + 1
        r1 += gap + 1
        c2 -= gap + 1
        r2 -= gap + 1
        ring += 1
    cx, cy = (c1 + c2) // 2, (r1 + r2) // 2
    return walls, (cx, cy)


def concentric_rings(cols, rows, n, gap_size=2):
    """Rectangular rings around the centre, each with an offset doorway."""
    walls = set()
    cx, cy = cols // 2, rows // 2
    sides = ['right', 'top', 'left', 'bottom']
    for i in range(n):
        inset_c = 2 + i * 3
        inset_r = 2 + i * 2
        c1, r1, c2, r2 = inset_c, inset_r, cols - 1 - inset_c, rows - 1 - inset_r
        if c2 - c1 < 3 or r2 - r1 < 3:
            break
        ring = rect_border(c1, r1, c2, r2)
        side = sides[i % 4]
        if side == 'right':
            ring -= {(c2, cy + d) for d in range(-(gap_size // 2), gap_size // 2 + 1)}
        elif side == 'left':
            ring -= {(c1, cy + d) for d in range(-(gap_size // 2), gap_size // 2 + 1)}
        elif side == 'top':
            ring -= {(cx + d, r1) for d in range(-(gap_size // 2), gap_size // 2 + 1)}
        else:
            ring -= {(cx + d, r2) for d in range(-(gap_size // 2), gap_size // 2 + 1)}
        walls |= ring
    return walls, (cx, cy)


def diamond_lattice(cols, rows, spacing_c=5, spacing_r=4, k=1):
    """Staggered diamond clusters that fracture the field into winding channels."""
    walls = set()
    row_i = 0
    r = 2
    while r < rows - 2:
        offset = (spacing_c // 2) if row_i % 2 else 0
        c = 2 + offset
        while c < cols - 2:
            walls |= diamond(c, r, k)
            c += spacing_c
        r += spacing_r
        row_i += 1
    return walls


def rooms(cols, rows, cellw=8, cellh=6):
    """Grid of chambers separated by walls with single-cell doorways between
    adjacent rooms -> a rooms-and-corridors maze."""
    walls = set()
    # vertical dividers
    xs = list(range(cellw, cols - 1, cellw))
    ys = list(range(cellh, rows - 1, cellh))
    for x in xs:
        col = vwall(x, 0, rows - 1)
        # punch a door at a pseudo-random but deterministic row per segment
        seg = 0
        for y0 in [0] + ys:
            y1 = next((y for y in ys if y > y0), rows - 1)
            door = y0 + ((x + y0) % max(1, (y1 - y0 - 1))) + 1
            col.discard((x, door))
            col.discard((x, min(door + 1, rows - 1)))
            seg += 1
        walls |= col
    for y in ys:
        roww = hwall(y, 0, cols - 1)
        for x0 in [0] + xs:
            x1 = next((x for x in xs if x > x0), cols - 1)
            door = x0 + ((y + x0 * 3) % max(1, (x1 - x0 - 1))) + 1
            roww.discard((door, y))
            roww.discard((min(door + 1, cols - 1), y))
        walls |= roww
    return walls


def braid_maze(cols, rows, seed=1):
    """Recursive-division maze on a coarse lattice, then widen corridors to 2
    cells so towers remain placeable. Produces a dense true-labyrinth feel."""
    import random
    rnd = random.Random(seed)
    # work on coarse cells of size 3 (2 open + 1 wall)
    walls = set()

    def divide(c1, r1, c2, r2, horizontal):
        if c2 - c1 < 6 or r2 - r1 < 6:
            return
        if horizontal:
            # pick a wall row on a multiple-of-3 boundary
            choices = [r for r in range(r1 + 3, r2 - 2) if (r - r1) % 3 == 0]
            if not choices:
                return
            wr = rnd.choice(choices)
            door = rnd.randrange(c1, c2)
            for c in range(c1, c2 + 1):
                if abs(c - door) > 1:
                    walls.add((c, wr))
            divide(c1, r1, c2, wr - 1, False)
            divide(c1, wr + 1, c2, r2, False)
        else:
            choices = [c for c in range(c1 + 3, c2 - 2) if (c - c1) % 3 == 0]
            if not choices:
                return
            wc = rnd.choice(choices)
            door = rnd.randrange(r1, r2)
            for r in range(r1, r2 + 1):
                if abs(r - door) > 1:
                    walls.add((wc, r))
            divide(c1, r1, wc - 1, r2, True)
            divide(wc + 1, r1, c2, r2, True)

    divide(0, 0, cols - 1, rows - 1, rnd.random() < 0.5)
    return walls


# ---------------------------------------------------------------------------
# Validation (engine-space BFS, mirrors Grid.swift)
# ---------------------------------------------------------------------------

def bfs_path_len(cols, rows, walls_engine, spawns, core, portals):
    """Shortest path length (in cells) from any spawn to core, routing around
    walls and through portals. Returns (reachable, min_len, dist_map)."""
    pmap = {}
    for a, b in portals:
        pmap[a] = b
        pmap[b] = a
    blocked = set(walls_engine)

    def neighbors(cell):
        c, r = cell
        for dc, dr in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (c + dc, r + dr)
            if 0 <= n[0] < cols and 0 <= n[1] < rows and n not in blocked:
                yield n
        if cell in pmap and pmap[cell] not in blocked:
            yield pmap[cell]

    dist = {core: 0}
    q = deque([core])
    while q:
        cur = q.popleft()
        for n in neighbors(cur):
            if n not in dist:
                dist[n] = dist[cur] + 1
                q.append(n)
    reachable = all(s in dist for s in spawns)
    min_len = min((dist[s] for s in spawns if s in dist), default=None)
    return reachable, min_len, dist
