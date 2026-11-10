import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Services

Scope {
    id: map

    signal done()

    property real px: 0
    property real py: 0
    property real pz: 0
    property real yaw: 0
    property real pitch: 0
    property real aimYaw: 0
    property real aimPitch: 0
    property var vel: [0, 0, 0]
    property var held: ({})
    property var cam: ({ x: 0, y: 0, z: 0, cy: 1, sy: 0, cp: 1, sp: 0, f: focal, v: 0 })
    function setView(x, y, z, yw, pt, v) {
        px = x; py = y; pz = z; yaw = yw; pitch = pt
        v = Math.min(1, v ?? 0)
        cam = { x: x, y: y, z: z, cy: Math.cos(yw), sy: Math.sin(yw), cp: Math.cos(pt), sp: Math.sin(pt), f: focal / (1 + 0.28 * v), v: v }
    }
    property real bloom: 1
    function openSystem() { bloomAnim.restart() }
    SequentialAnimation {
        id: bloomAnim
        PropertyAction { target: map; property: "bloom"; value: 0 }
        PauseAnimation { duration: 160 }
        NumberAnimation { target: map; property: "bloom"; to: 1; duration: 900; easing.type: Easing.OutQuint }
    }
    property real ascent: 0
    readonly property real fall: Math.pow(Math.max(0, Math.min(1, (ascent - 0.05) / 0.65)), 2)
    property real ground: 1
    property real veil: 0
    property var sel: null
    property var landing: null
    property var transitKeys: []
    property var transitLight: null
    property var transitMoon: null

    readonly property var home: Quickshell.screens[0]
    readonly property real cx: home.x + home.width / 2
    readonly property real cy: home.y + home.height / 2
    property real zoomFactor: 1.0
    Behavior on zoomFactor { Settle { duration: SpaceTheme.ms(220) } }
    function zoomIn() { zoomFactor = Math.min(3.0, zoomFactor * 1.18) }
    function zoomOut() { zoomFactor = Math.max(0.35, zoomFactor / 1.18) }
    function zoomReset() { zoomFactor = 1.0 }

    readonly property real baseFocal: Math.max(home.width, home.height) * 0.6
    readonly property real focal: baseFocal * zoomFactor
    onFocalChanged: setView(px, py, pz, yaw, pitch, cam.v)
    readonly property real hover: focal / 35
    readonly property real planetR: 0.5
    readonly property real planetPx: 70
    readonly property real planetDist: planetR * focal / planetPx
    readonly property real endR: planetPx / home.height
    readonly property real homeR: 8
    readonly property real ringGap: 3
    readonly property real worldR: 0.34
    readonly property real moonR: 0.14

    // MangoWM tag / workspace tracking
    readonly property int current: {
        const activeOut = MangoService.activeOutput || (home?.name ?? "");
        const out = MangoService.outputs[activeOut];
        const at = out?.activeTags;
        return (at && at.length > 0 && at[0] > 0) ? at[0] : 1;
    }

    readonly property var used: {
        const activeOut = MangoService.activeOutput || (home?.name ?? "");
        const out = MangoService.outputs[activeOut];
        const list = [];
        const tagCount = MangoService.tagCount || 9;
        const allWindows = Array.isArray(MangoService.windows) ? MangoService.windows : [];

        for (let i = 1; i <= tagCount; i++) {
            const tagWins = allWindows.filter(w => {
                if (w.is_scratchpad || w.is_namedscratchpad) return false;
                if (Array.isArray(w.tags)) return w.tags.includes(i);
                return w.tag === i;
            }).map(w => ({
                id: w.id,
                address: w.id,
                title: w.title || "",
                appId: w.appid || w.app_id || "",
                lastIpcObject: {
                    class: w.appid || w.app_id || "",
                    title: w.title || "",
                    size: [w.width || 800, w.height || 600],
                    at: [w.x || 0, w.y || 0]
                }
            }));

            if (tagWins.length > 0 || i === current || i <= 5) {
                list.push({
                    kind: "ws",
                    id: i,
                    pos: SpaceWorld.starOf(i),
                    ws: {
                        id: i,
                        toplevels: { values: tagWins }
                    }
                });
            }
        }
        return list;
    }

    readonly property var scratch: {
        const allWindows = Array.isArray(MangoService.windows) ? MangoService.windows : [];
        const list = allWindows.filter(w => w.is_scratchpad || w.is_namedscratchpad);
        return list.map(w => ({
            name: "special:S-" + (w.appid || w.title || "scratch"),
            toplevels: {
                values: [{
                    id: w.id,
                    address: w.id,
                    title: w.title || "",
                    appId: w.appid || w.app_id || "",
                    lastIpcObject: {
                        class: w.appid || w.app_id || "",
                        title: w.title || "",
                        size: [w.width || 800, w.height || 600],
                        at: [w.x || 0, w.y || 0]
                    }
                }]
            }
        }));
    }

    function specialPos(name) {
        const h = [...name].reduce((a, c) => (a * 31 + c.charCodeAt(0)) | 0, 7), a = r3(h, 1, 2) * Math.PI * 2, r = 90 + r3(h, 3, 4) * 80
        return [Math.cos(a) * r, (r3(h, 5, 6) - 0.5) * 40, Math.sin(a) * r]
    }

    function starSize(s) { return Math.min(30, 5 + 7 * s) }
    function fwd() { return [Math.sin(yaw) * Math.cos(pitch), Math.sin(pitch), Math.cos(yaw) * Math.cos(pitch)] }
    function mix3(a, b, t) { return [a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t] }
    function sub3(a, b) { return [a[0] - b[0], a[1] - b[1], a[2] - b[2]] }
    function toCam(vx, vy, vz) {
        const c = cam
        const x1 = vx * c.cy - vz * c.sy, z1 = vx * c.sy + vz * c.cy
        return [x1, vy * c.cp - z1 * c.sp, vy * c.sp + z1 * c.cp]
    }
    function rel(p) { return toCam(p[0] - cam.x, p[1] - cam.y, p[2] - cam.z) }
    function project(p) {
        const c = cam, q = rel(p)
        if (q[2] < 1.5) return null
        return { x: cx + q[0] / q[2] * c.f, y: cy - q[1] / q[2] * c.f, s: c.f / q[2] / 8, z: q[2] }
    }
    function sunDir(from, to) {
        if (!from || !to) return Qt.vector4d(-0.35, 0.6, 0.7, 0)
        const q = toCam(...sub3(to, from)), l = Math.hypot(...q) || 1
        return Qt.vector4d(q[0] / l, q[1] / l, -q[2] / l, 0)
    }
    readonly property var moonEnd: {
        const m = transitMoon, b = transitLight
        const q = m && b ? project(shown(m)) : null, h = q ? project(b[0]) : null
        if (!q || !h) return Qt.vector4d(0, 0, 0, 0)
        const H = home.height
        return Qt.vector4d((q.x - cx) / H, 0.5 - (q.y - cy) / H, m.r * cam.f / q.z / H, q.z < h.z ? 2 : 1)
    }
    function segment(a, b) {
        const n = 1.5
        let qa = rel(a), qb = rel(b)
        if (qa[2] < n && qb[2] < n) return null
        if (qa[2] < n) qa = mix3(qa, qb, (n - qa[2]) / (qb[2] - qa[2]))
        else if (qb[2] < n) qb = mix3(qb, qa, (n - qb[2]) / (qa[2] - qb[2]))
        const sc = q => Qt.point(cx + q[0] / q[2] * cam.f, cy - q[1] / q[2] * cam.f)
        return [sc(qa), sc(qb)]
    }
    function lookAt(from, to) {
        const d = sub3(to, from)
        let y = Math.atan2(d[0], d[2])
        while (y - yaw > Math.PI) y -= Math.PI * 2
        while (y - yaw < -Math.PI) y += Math.PI * 2
        return [y, Math.atan2(d[1], Math.hypot(d[0], d[2]))]
    }

    readonly property int cell: 35
    readonly property real density: 0.3
    readonly property string here: [Math.floor(cam.x / cell), Math.floor(cam.y / cell), Math.floor(cam.z / cell)].join()
    property var wild: []
    ListModel { id: wildModel }
    function reroll() { wildModel.clear(); wild = []; rebuild() }
    Connections {
        target: SpaceWorld
        function onOffersChanged() { map.reroll() }
    }
    function hash(a, b, c) { return r3(a + SpaceWorld.seed * 31, b, c) }
    onHereChanged: rebuild()
    function rebuild() {
        const [a0, b0, c0] = here.split(",").map(Number), out = []
        for (let i = -4; i <= 4; i++) for (let j = -2; j <= 2; j++) for (let k = -4; k <= 4; k++) {
            const a = a0 + i, b = b0 + j, c = c0 + k
            if (hash(a, b, c) > density) continue
            out.push({ kind: "wild", id: a + "," + b + "," + c, hue: SpaceWorld.snap(hash(c, a, b), true), temp: hash(b, a, c), size: 0.6 + hash(a, c, b) * 0.9,
                       pos: [(a + hash(b, c, a)) * cell, (b + hash(c, b, a)) * cell * 0.6, (c + hash(a, a, c)) * cell] })
        }
        const byId = {}, have = new Set(), next = wild.slice(), free = []
        for (const w of out) byId[w.id] = w
        for (let i = 0; i < next.length; i++) {
            if (byId[next[i].id]) have.add(next[i].id)
            else free.push(i)
        }
        for (const w of out) {
            if (have.has(w.id)) continue
            const row = { sid: w.id, shue: w.hue, stemp: w.temp, ssize: w.size, wx: w.pos[0], wy: w.pos[1], wz: w.pos[2] }
            const slot = free.pop()
            if (slot === undefined) { wildModel.append(row); next.push(w) }
            else { wildModel.set(slot, row); next[slot] = w }
        }
        for (let i = free.length - 1; i >= 0; i--) { wildModel.remove(free[i]); next.splice(free[i], 1) }
        wild = next
    }
    readonly property var wildP: wild.map(w => project(w.pos))

    function r3(a, b, c) {
        let h = (a * 374761393 + b * 668265263 + c * 2147483647) | 0
        h = Math.imul(h ^ (h >>> 13), 1274126177)
        return ((h ^ (h >>> 16)) >>> 0) / 4294967295
    }
    function sysRand(s, n) { return r3(Math.round(s.pos[0]) + n * 7919, Math.round(s.pos[1]) + n * 104729, Math.round(s.pos[2])) }
    function sysHue(s) {
        if (s.kind === "wild") return s.hue
        const placed = SpaceWorld.stars[s.id]
        return placed?.[3] !== undefined && (SpaceWorld.random || SpaceWorld.themeFor(placed[3])) ? placed[3] : SpaceWorld.snap(sysRand(s, 1))
    }
    function worldHue(s, i) {
        const h = sysHue(s), f = SpaceWorld.random ? null : SpaceWorld.themeFor(h)
        if (!f) return (h + (i + 1) * 0.618) % 1
        return SpaceWorld.accentHue(f.t.c[SpaceWorld.pins[f.t.id] ?? 3 + (f.i - 3 + i + 1) % 6])
    }
    function sysSeed(s, n = 5) { return 1 + Math.round(sysRand(s, n) * 996) }
    function tiltOf(s) { return 0.22 + sysRand(s, 2) * 0.3 }
    function orbitC(c, t, r, a) {
        const x = Math.cos(a) * r, z = Math.sin(a) * r
        return [c[0] + x, c[1] - z * Math.sin(t), c[2] + z * Math.cos(t)]
    }
    function orbit(s, r, a) { return orbitC(s.pos, tiltOf(s), r, a) }
    function isTransit(o) { return transitKeys.indexOf(o.key) >= 0 }
    readonly property real viewEl: 0.85
    function viewOf(sys, h) {
        const t = tiltOf(sys), N = [0, Math.cos(t), Math.sin(t)], d = [0, 1, 2].map(i => sys.pos[i] - h[i]), l = Math.hypot(...d) || 1
        const u = d.map(v => v / l), w = [N[1] * u[2] - N[2] * u[1], N[2] * u[0] - N[0] * u[2], N[0] * u[1] - N[1] * u[0]]
        const ep = u.map((v, i) => v * Math.cos(2.0) + w[i] * Math.sin(2.0))
        return { e: ep.map((v, i) => v * Math.cos(viewEl) + N[i] * Math.sin(viewEl)),
                 a: Math.atan2(-ep[1] * Math.sin(t) + ep[2] * Math.cos(t), ep[0]) }
    }

    function homeOf(sys) {
        const a = sysRand(sys, 3) * Math.PI * 2
        return { kind: "home", key: "h" + sys.id, sys: sys, ring: homeR, r: planetR, hue: sysHue(sys), seed: sysSeed(sys), star: sys.pos, a: a, pos: orbit(sys, homeR, a) }
    }
    readonly property real natR: 1.7
    function moonOf(h) {
        const a = viewOf(h.sys, h.pos).a + 1.2, t = tiltOf(h.sys)
        return { kind: "moon", key: "n" + h.sys.id, natural: true, sys: h.sys, ring: "n", rr: natR, r: 0.17,
                 a: a, center: h.pos, star: h.sys.pos, hue: h.hue, seed: h.seed, pos: orbitC(h.pos, t, natR, a) }
    }
    readonly property var bodies: {
        if (!sel) return []
        const h = homeOf(sel), t = tiltOf(sel), out = [h, moonOf(h)]
        if (sel.kind === "ws") {
            sel.ws.toplevels.values.forEach((w, i) => {
                const r = homeR + ringGap * (i + 1), a = sysRand(sel, 20 + i) * Math.PI * 2
                out.push({ kind: "planet", key: "p" + w.address, window: w, wsid: sel.id, special: sel.special, ring: "p" + i, rr: r, r: worldR, center: sel.pos, star: sel.pos,
                           hue: worldHue(sel, i), seed: sysSeed(sel, 10 + i), a: a, pos: orbit(sel, r, a) })
            })
            scratch.forEach((w, i) => {
                const r = natR + 0.7 + i * 0.5, a = i * 2.4 + sysRand(sel, 4) * Math.PI * 2
                out.push({ kind: "moon", key: "s" + w.name, special: w.name.slice(8), sys: sel, ring: "m" + i, rr: r, r: moonR, center: h.pos, star: sel.pos,
                           hue: h.hue, seed: h.seed, a: a, pos: orbitC(h.pos, t, r, a) })
            })
        }
        return out
    }
    readonly property var rings: bodies.map(b => b.kind === "home" ? { key: homeR, c: sel.pos, r: homeR, moon: false, a0: b.a }
                                                              : { key: b.ring, c: b.center, r: b.rr, moon: b.kind === "moon", a0: b.a })
    property real ringDraw: 1
    function ringFrac(i) { return Math.max(0, Math.min(1, Math.min(ringDraw, bloom) * (1 + 0.15 * rings.length) - 0.15 * i)) }
    function ringPath(rg, f) {
        if (!sel || bloom < 0.02 || f <= 0) return []
        const out = []
        let seg = []
        const N = Math.max(2, Math.ceil((rg.moon ? 32 : 56) * f)), rr = rg.r * bloom, t = tiltOf(sel)
        const c = rg.moon ? shown({ star: true, pos: rg.c }) : rg.c
        for (let i = 0; i <= N; i++) {
            const q = project(orbitC(c, t, rr, (rg.a0 ?? 0) + i / N * f * Math.PI * 2))
            if (q && q.z > 4) seg.push(Qt.point(q.x, q.y))
            else { if (seg.length > 1) out.push(seg); seg = [] }
        }
        if (seg.length > 1) out.push(seg)
        return out
    }
    readonly property var ringPts: (1 - ground) > 0 ? rings.map((rg, i) => ringPath(rg, ringFrac(i))) : []
    property real ui: 1

    function shown(o) {
        if (bloom >= 1 || !o.star || !sel) return o.pos
        const c = o.center ?? o.pos, cs = mix3(sel.pos, c, bloom)
        return o.center ? mix3(cs, [cs[0] + o.pos[0] - c[0], cs[1] + o.pos[1] - c[1], cs[2] + o.pos[2] - c[2]], bloom) : cs
    }
    function screenOf(o) { return project(shown(o)) }
    function distFor(o) { return (o.r ?? planetR) * focal / planetPx }

    property real aimX: cx
    property real aimY: cy

    readonly property var aimed: {
        let best = null, bestD = 55
        const near = (p, o, far) => {
            if (!p || p.z > far) return
            const d = Math.hypot(p.x - aimX, p.y - aimY)
            if (d < bestD) { bestD = d; best = o }
        }
        const open = bloom > 0.9
        for (const o of bodies.concat(used)) {
            const body = !!o.star
            if (body && !open) continue
            near(screenOf(o), o, body ? 400 : 160)
        }
        const wp = wildP
        for (let i = 0; i < wp.length; i++) near(wp[i], wild[i], 160)
        return best
    }

    readonly property var carded: busy ? null : (aimed ?? sel)
    function colorOf(t) { return t < 0.2 ? "#d6e4ff" : t > 0.85 ? "#ffe9cf" : "#ffffff" }
    function appOf(w) { return (w?.lastIpcObject?.class || w?.title || "").split(".").pop() }
    function nameOf(ws) { return [...new Set((ws?.toplevels?.values ?? []).map(appOf).filter(x => x))].slice(0, 2).join(" · ") }
    function sysName(id) { return used.find(u => u.id === id)?.special ?? "tag " + String(id).padStart(2, "0") }
    function currentStar() {
        const u = Array.isArray(used) ? used : []
        const found = u.find(x => x && x.id === current)
        if (found) return found
        return { kind: "ws", id: current, pos: SpaceWorld.starOf(current) }
    }

    property real go: 0
    readonly property int takeoffMs: 3800
    readonly property int landMs: 3100
    readonly property var curve: [0.25, 0.1, 0.25, 1.0]
    readonly property var landCurve: [0.15, 0.25, 0.25, 1.0]
    readonly property real liftA: 0.5
    readonly property real takeOverAt: 0.9
    property var path: null
    function pathTo(h, e, d0, d1, to) {
        d1 = Math.max(d1, d0 * 1.3)
        const mu = Math.max(0.5, Math.min(3, Math.log(3.5 / endR) * 0.35 / 0.55 * (1 - liftA) / liftA / Math.log(d1 / d0)))
        return { h: h, e: e, d0: d0, d1: d1, to: to, mu: mu }
    }
    function pose(s) {
        const P = path
        if (!P) return
        const m = P.mu * s + (2 - 2 * P.mu) * s * s + (P.mu - 1) * s * s * s, k = s * s * (2 - s)
        const D = P.d0 * Math.pow(P.d1 / P.d0, m), c = P.h.map((v, i) => v + P.e[i] * D)
        const [y, pt] = lookAt(c, mix3(P.h, P.to, k))
        const w = Math.sin(Math.PI * s)
        setView(c[0], c[1], c[2], y, pt, w * w * 0.5)
        aimYaw = y; aimPitch = pt
        const now = Date.now()
        if (!track[1] || now - track[1].t >= 24) track = [track[1], { t: now, x: c[0], y: c[1], z: c[2], yw: y, pt: pt }]
    }
    property bool touched: false
    property bool poseDirty: false
    property var track: [null, null]
    property real kick: 0

    function flyPath() {
        poseDirty = false
        if (!path) return
        const s = (go - liftA) / (1 - liftA)
        ascent = 1; ground = 0; ringDraw = Math.min(1, s * 1.8); ui = Math.max(0.0015, Math.min(1, (s - 0.15) * 2))
        pose(s)
    }
    onGoChanged: {
        if (!path) return
        if (go > liftA) {
            if (ground === 1 || go >= 1) flyPath()
            else poseDirty = true
            return
        }
        poseDirty = false
        ringDraw = 0
        ui = 0.0015
        if (ascent === 1) pose(0)
        ascent = go / liftA
        if (descend.running && !touched) {
            touched = true
            if (!land()) { descend.stop(); done(); return }
        }
        ground = 1
    }

    Component.onCompleted: {
        try {
            sel = currentStar()
            const ho = homeOf(sel), h = ho.pos, e = viewOf(sel, h).e
            transitKeys = [ho.key, "n" + sel.id]
            transitLight = [h, sel.pos]
            transitMoon = moonOf(ho)
            path = pathTo(h, e, planetDist, hover * 0.6, h)
            pose(0)
            rebuild()
        } catch (err) {
            console.error("SpaceMap onCompleted error:", err)
            const defaultPos = [0, 0, 0]
            path = pathTo(defaultPos, [0, 0, 1], planetDist, hover * 0.6, defaultPos)
            pose(0)
        }
    }
    property var gate: takeoff
    readonly property bool warm: gate === takeoff
    property int gateFrames: 0
    onGateFramesChanged: if (gate && gateFrames >= Quickshell.screens.length * 3) openGate()
    function openGate() {
        const a = gate
        if (!a) return
        a.start()
        gate = null
    }
    Timer { running: !!map.gate; interval: 250; onTriggered: map.openGate() }
    function arrive() { path = null; ui = 1; ringDraw = 1 }
    function takeOver() {
        if (!takeoff.running) return true
        if (go < takeOverAt) return false
        if (poseDirty) flyPath()
        const a = track[0], dt = a ? (Date.now() - a.t) / 1000 : 0
        takeoff.stop()
        arrive()
        if (dt > 0.001) {
            vel = [(px - a.x) / dt, (py - a.y) / dt, (pz - a.z) / dt]
            aimYaw = yaw + (yaw - a.yw) / dt / 7
            aimPitch = pitch + (pitch - a.pt) / dt / 7
        }
        kick = cam.v
        return true
    }
    SequentialAnimation {
        id: takeoff
        onFinished: if (map.queued) map.close()
        ParallelAnimation {
            NumberAnimation { target: map; property: "veil"; to: 1; duration: 600; easing.type: Easing.OutCubic }
            SequentialAnimation {
                PauseAnimation { duration: 130 }
                NumberAnimation { target: map; property: "go"; from: 0; to: 1; duration: map.takeoffMs; easing.type: Easing.BezierSpline; easing.bezierCurve: map.curve.concat([1, 1]) }
            }
        }
        ScriptAction { script: map.arrive() }
    }

    property var flyFrom: [0, 0, 0, 0, 0]
    property var flyTo: [0, 0, 0, 0, 0]
    property real flyKick: 1
    property real flyT: 0
    function focus(o) {
        if (!o) return
        if (!o.star && sel?.id !== o.id) { sel = o; openSystem() }
        kick = 0
        const s = o.pos, d = [s[0] - px, s[1] - py, s[2] - pz], len = Math.max(0.001, Math.hypot(...d))
        const back = o.kind === "home" ? distFor(o) : o.star ? hover * 0.5 : hover
        const to = [s[0] - d[0] / len * back, s[1] - d[1] / len * back, s[2] - d[2] / len * back]
        const [ty, tp] = lookAt(to, s)
        flyFrom = [px, py, pz, yaw, pitch]
        flyTo = to.concat([ty, tp])
        fly.duration = Math.max(800, Math.min(1400, 560 + len * 4))
        flyKick = Math.min(1, len / 140)
        aimYaw = ty; aimPitch = tp
        vel = [0, 0, 0]
        fly.restart()
    }
    onFlyTChanged: {
        if (!fly.running && flyT < 1) return
        const k = flyT, w = Math.sin(Math.PI * k), v = flyFrom.map((a, i) => a + (flyTo[i] - a) * k)
        setView(v[0], v[1], v[2], v[3], v[4], w * w * flyKick)
    }
    NumberAnimation { id: fly; target: map; property: "flyT"; from: 0; to: 1; easing.type: Easing.InOutCubic }
    function act() {
        const o = aimed
        if (!o || busy) return
        if (o.star || (sel && o.id === sel.id)) warp(o)
        else focus(o)
    }

    function warp(o) {
        if (!o || busy) return
        landing = o
        kick = 0
        const dest = o.kind === "moon" ? homeOf(o.sys) : o.star ? o : homeOf(o)
        if (!o.star && sel?.id !== o.id) { bloomAnim.stop(); bloom = 1; sel = o }
        const home = dest.kind === "home"
        transitKeys = home ? [dest.key, "n" + dest.sys.id] : [dest.key]
        transitLight = [dest.pos, dest.star]
        transitMoon = home ? moonOf(dest) : null
        landHue = dest.hue
        landSeed = dest.seed
        recolored = landHue !== SpaceWorld.hue || landSeed !== SpaceWorld.landSeed
        if (recolored) SpaceWorld.reroll(landHue, landSeed)
        const l = o.star ? (o.kind === "planet" ? o : o.sys) : o
        shotWs = l.special ? current : l.kind === "planet" ? l.wsid : l.kind === "wild" ? -1 : l.id
        const h = dest.pos, v = [px - h[0], py - h[1], pz - h[2]], L = Math.hypot(...v) || 1, f = fwd()
        path = pathTo(h, v.map(x => x / L), distFor(dest), L, [px + f[0] * L, py + f[1] * L, pz + f[2] * L])
        fly.stop()
        vel = [0, 0, 0]
        touched = false
        descend.ms = landMs + Math.min(500, L * 5)
        gateFrames = 0
        gate = descend
    }
    property bool queued: false
    function close() {
        try {
            if (!busy) warp(currentStar())
            else queued = warm || takeoff.running
        } catch (err) {
            console.error("SpaceMap close error, force exiting:", err)
            takeoff.stop()
            descend.stop()
            fly.stop()
            map.done()
        }
    }
    SequentialAnimation {
        id: descend
        property int ms: 4200
        NumberAnimation { target: map; property: "go"; from: 1; to: 0; duration: descend.ms; easing.type: Easing.BezierSpline; easing.bezierCurve: map.landCurve.concat([1, 1]) }
        ScriptAction { script: map.settled = true }
        PauseAnimation { duration: map.recolored ? 150 : 0 }
        ScriptAction { script: map.veil = 0.5 }
        NumberAnimation { target: map; property: "veil"; to: 0; duration: 500; easing.type: Easing.InOutSine }
        ScriptAction { script: map.done() }
    }
    property int landWs: current
    property int shotWs: 0
    property bool recolored: false
    property bool settled: false
    property real landHue: -1
    property real landSeed: SpaceWorld.landSeed

    function land() {
        const l = landing.star ? (landing.kind === "planet" ? landing : landing.sys) : landing
        if (l.kind === "wild") {
            let id = 1
            while (used.some(u => u.id === id)) id++
            SpaceWorld.place(id, l.pos, l.hue)
            landWs = id
            landHue = l.hue
            MangoService.dispatch("view " + id)
        } else if (l.kind === "planet") {
            const winId = l.window.id
            landWs = l.special ? current : l.wsid
            MangoService.dispatch("view " + landWs)
            if (winId) MangoService.dispatch("focusclient " + winId)
        } else {
            landWs = l.special ? current : l.id
            if (l.id !== current && !l.special) MangoService.dispatch("view " + l.id)
            return true
        }
        return true
    }

    readonly property bool busy: !!gate || takeoff.running || fly.running || descend.running
    readonly property bool drawn: busy || veil > 0 || ascent > 0.001
    onDrawnChanged: if (!drawn) done()
    readonly property real steerDist: Math.hypot((aimX - cx) / Math.max(1, home.width / 2), (aimY - cy) / Math.max(1, home.height / 2))
    readonly property bool steering: steerDist > 0.45

    readonly property bool flying: kick > 0 || Object.keys(held).length > 0 || Math.hypot(...vel) > 0.05
        || Math.abs(aimYaw - yaw) > 0.0005 || Math.abs(aimPitch - pitch) > 0.0005 || steering
    FrameAnimation {
        running: map.flying && !map.busy
        onTriggered: {
            const dt = Math.min(0.05, frameTime), k = map.held, top = k.fast ? 260 : 80
            map.kick = map.kick > 0.002 ? map.kick * Math.exp(-dt * 4) : 0
            const f = map.fwd(), rx = Math.cos(map.yaw), rz = -Math.sin(map.yaw)
            const go = (k.f ? 1 : 0) - (k.b ? 1 : 0), side = (k.r ? 1 : 0) - (k.l ? 1 : 0)
            if (k.tl) map.aimYaw -= 1.2 * dt
            if (k.tr) map.aimYaw += 1.2 * dt

            // Continuous flight steering when mouse is outside the deadzone
            if (map.steering && !map.busy) {
                const srx = (map.aimX - map.cx) / Math.max(1, map.home.width / 2)
                const sry = (map.aimY - map.cy) / Math.max(1, map.home.height / 2)
                const d = map.steerDist
                const norm = Math.min(1.0, (d - 0.45) / (1.0 - 0.45))
                const rate = (map.held.fast ? 1.6 : 0.72) * Math.pow(norm, 1.5)
                map.aimYaw += (srx / d) * rate * dt
                map.aimPitch = Math.max(-1.3, Math.min(1.3, map.aimPitch - (sry / d) * rate * dt))
            }
            const want = [(f[0] * go + rx * side) * top, f[1] * go * top, (f[2] * go + rz * side) * top]
            const e = 1 - Math.exp(-dt * (go || side ? 4 : 2.2))
            const v = map.vel.map((c, i) => c + (want[i] - c) * e)
            map.vel = v
            const t = 1 - Math.exp(-dt * 7)
            map.setView(map.px + v[0] * dt, map.py + v[1] * dt, map.pz + v[2] * dt,
                        map.yaw + (map.aimYaw - map.yaw) * t, map.pitch + (map.aimPitch - map.pitch) * t, Math.max(map.kick, Math.hypot(...v) / 260))
        }
    }
    readonly property var binds: ({
        [Qt.Key_W]: "f", [Qt.Key_Up]: "f", [Qt.Key_K]: "f", [Qt.Key_S]: "b", [Qt.Key_Down]: "b", [Qt.Key_J]: "b",
        [Qt.Key_A]: "l", [Qt.Key_Left]: "l", [Qt.Key_H]: "l", [Qt.Key_D]: "r", [Qt.Key_Right]: "r", [Qt.Key_L]: "r",
        [Qt.Key_Q]: "tl", [Qt.Key_E]: "tr", [Qt.Key_Shift]: "fast"
    })
    function key(e, down) {
        if (e.isAutoRepeat) return

        // Instant and safe Escape: abort animations and exit immediately
        if (down && e.key === Qt.Key_Escape) {
            takeoff.stop()
            descend.stop()
            fly.stop()
            map.done()
            return
        }

        if (!takeOver() || descend.running) return
        if (down && (e.key === Qt.Key_Return || e.key === Qt.Key_Enter)) return act()
        if (down && e.key === Qt.Key_Space) return focus(currentStar())
        if (down && (e.key === Qt.Key_Tab || e.key === Qt.Key_Backtab) && used && used.length) {
            const i = Math.max(0, used.findIndex(u => u.id === sel?.id))
            return focus(used[(i + (e.key === Qt.Key_Backtab ? used.length - 1 : 1)) % used.length])
        }
        const b = binds[e.key]
        if (!b) return
        const h = Object.assign({}, held)
        if (down) h[b] = true
        else delete h[b]
        held = h
    }

    property real lastX: cx
    property real lastY: cy
    property bool idle: false
    Timer { running: true; interval: 6000; onTriggered: map.idle = true }
    function look(gx, gy) {
        aimX = gx
        aimY = gy
        lastX = gx
        lastY = gy
    }

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: win
            required property var modelData
            readonly property bool main: modelData === map.home
            readonly property real ox: modelData.x
            readonly property real oy: modelData.y
            screen: modelData
            visible: map.drawn
            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "space-overview"
            WlrLayershell.keyboardFocus: main ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            Connections {
                target: scene.Window.window
                function onFrameSwapped() {
                    if (map.gate) map.gateFrames++
                    else if (map.poseDirty) map.flyPath()
                    if (win.main && (takeoff.running || descend.running)) SpaceRenderScale.frame()
                }
            }
            Item {
                id: scene
                anchors.fill: parent

                Rectangle { anchors.fill: parent; color: "black"; visible: map.veil >= 0.5 }

                Item {
                    id: sky
                    anchors.fill: parent
                    visible: map.warm || map.ascent > 0.01
                    opacity: map.warm ? 0.0015 : Math.min(1, map.ascent * 1.5)

                    ShaderEffect {
                        anchors.fill: parent
                        readonly property real yaw: map.yaw
                        readonly property real pitch: map.pitch
                        readonly property real focal: map.cam.f
                        readonly property real offX: win.ox - map.cx
                        readonly property real offY: win.oy - map.cy
                        readonly property real sizeW: width
                        readonly property real sizeH: height
                        readonly property color tint1: SpaceTheme.accent
                        readonly property color tint2: SpaceTheme.accent2
                        readonly property color base: SpaceTheme.mix(SpaceTheme.bg, "#000000", 0.7)
                        fragmentShader: Qt.resolvedUrl("overview.frag.qsb")
                    }

                    Repeater {
                        model: wildModel
                        Rectangle {
                            required property real shue
                            required property real stemp
                            required property real ssize
                            required property int index
                            readonly property var p: map.wildP[index] ?? null
                            readonly property real far: p ? Math.min(1, p.z / 150) : 1
                            readonly property real dx: p ? p.x - map.cx : 0
                            readonly property real dy: p ? p.y - map.cy : 0
                            readonly property real d: p ? Math.max(2, Math.min(4.5, 1.2 + ssize * p.s * 0.45)) : 0
                            visible: !!p && far < 1 && p.z > 3
                            width: d + map.cam.v * Math.hypot(dx, dy) / Math.max(6, p?.z ?? 6) * 1.4
                            height: d
                            radius: d / 2
                            x: (p?.x ?? 0) - win.ox - width / 2
                            y: (p?.y ?? 0) - win.oy - height / 2
                            rotation: Math.atan2(dy, dx) * 180 / Math.PI
                            antialiasing: true
                            color: SpaceTheme.mix(map.colorOf(stemp), Qt.hsla(shue, 0.7, 0.7, 1), 0.5)
                            opacity: (1 - far * far) * Math.min(1, ((p?.z ?? 0) - 3) / 10) * (0.65 + ssize * 0.25)
                            Image {
                                anchors.centerIn: parent
                                width: 8 + parent.d * 6; height: width
                                source: "glow.png"
                                smooth: true
                                opacity: 0.95 * (1 - map.cam.v)
                            }
                        }
                    }

                    Repeater {
                        model: map.rings
                        Shape {
                            id: rg
                            required property var modelData
                            required property int index
                            readonly property real tone: map.sel ? map.sysHue(map.sel) : 0
                            readonly property bool lit: !!map.aimed && map.aimed.ring === modelData.key
                            x: -win.ox
                            y: -win.oy
                            width: win.width + win.ox
                            height: win.height + win.oy
                            z: 3
                            opacity: (1 - map.ground) * Math.min(1, map.bloom * 2)
                            preferredRendererType: Shape.CurveRenderer
                            ShapePath {
                                strokeWidth: rg.lit ? 1.5 : 1
                                strokeColor: Qt.hsla(rg.tone, 0.45, 0.72, rg.lit ? 0.7 : rg.modelData.moon ? 0.26 : 0.18)
                                fillColor: "transparent"
                                PathMultiline { paths: map.ringPts[rg.index] ?? [] }
                            }
                        }
                    }

                    Repeater {
                        model: map.used.length > 1 ? map.used.length - 1 : 0
                        Rectangle {
                            required property int index
                            readonly property var g: map.segment(map.used[index].pos, map.used[index + 1].pos)
                            visible: !!g
                            x: g ? g[0].x - win.ox : 0
                            y: g ? g[0].y - win.oy : 0
                            width: g ? Math.hypot(g[1].x - g[0].x, g[1].y - g[0].y) : 0
                            height: 1
                            rotation: g ? Math.atan2(g[1].y - g[0].y, g[1].x - g[0].x) * 180 / Math.PI : 0
                            transformOrigin: Item.Left
                            antialiasing: true
                            color: SpaceTheme.alpha(SpaceTheme.accent, 0.32 * map.ui)
                        }
                    }

                    Repeater {
                        model: map.used
                        Item {
                            id: u
                            required property var modelData
                            readonly property var p: map.project(modelData.pos)
                            readonly property real far: p ? Math.min(1, p.z / 170) : 1
                            readonly property bool picked: map.sel?.id === modelData.id
                            z: 5
                            Orb {
                                id: sb
                                property real boost: u.picked ? 1.7 : 1
                                Behavior on boost { Settle { duration: SpaceTheme.ms(500) } }
                                visible: !!u.p && u.p.z > 3
                                width: map.starSize(u.p?.s ?? 0) * boost
                                height: width
                                x: (u.p?.x ?? 0) - win.ox - width / 2
                                y: (u.p?.y ?? 0) - win.oy - height / 2
                                tint: SpaceTheme.mix("#ffffff", SpaceTheme.accent, 0.25)
                                core: 0.24
                                glow: 1
                                shade: 0
                                opacity: Math.max(0.55, 1 - u.far * u.far) * Math.min(1, ((u.p?.z ?? 0) - 3) / 10)
                            }
                            Column {
                                visible: sb.visible && map.ui > 0 && map.carded?.id !== u.modelData.id
                                opacity: map.ui
                                x: (u.p?.x ?? 0) - win.ox + sb.width / 2 + 6
                                y: (u.p?.y ?? 0) - win.oy - 8
                                DecodeText { decode: false; text: map.sysName(u.modelData.id) + (u.modelData.id === map.current ? "  ◂" : ""); color: u.picked ? SpaceTheme.accent : SpaceTheme.fg; opacity: u.picked || map.aimed === u.modelData ? 1 : 0.6 }
                                DecodeText { decode: false; text: map.nameOf(u.modelData.ws); font.pixelSize: 10; color: SpaceTheme.dim; visible: text !== "" && (u.picked || map.aimed === u.modelData || u.modelData.id === map.current) }
                            }
                        }
                    }

                    Repeater {
                        model: win.main ? map.used : []
                        Item {
                            id: mk
                            required property var modelData
                            readonly property var q: map.rel(modelData.pos)
                            readonly property var p: map.project(modelData.pos)
                            readonly property real lx: p ? p.x - win.ox : 0
                            readonly property real ly: p ? p.y - win.oy : 0
                            readonly property bool off: !p || lx < 40 || ly < 40 || lx > win.width - 40 || ly > win.height - 40
                            readonly property real ang: Math.atan2(-mk.q[1], mk.q[0])
                            readonly property real k: Math.min((win.width / 2 - 36) / Math.max(1e-3, Math.abs(Math.cos(ang))),
                                                               (win.height / 2 - 36) / Math.max(1e-3, Math.abs(Math.sin(ang))))
                            visible: off && !map.busy
                            opacity: map.ui
                            x: map.cx - win.ox + Math.cos(ang) * k
                            y: map.cy - win.oy + Math.sin(ang) * k
                            z: 11
                            Rectangle { anchors.centerIn: parent; width: 6; height: 6; rotation: 45; antialiasing: true; color: mk.modelData.id === map.current ? SpaceTheme.accent : SpaceTheme.fg }
                            Rectangle {
                                x: Math.cos(mk.ang) * 9 - 3; y: Math.sin(mk.ang) * 9 - 0.5
                                width: 6; height: 1; rotation: mk.ang * 180 / Math.PI; antialiasing: true; color: SpaceTheme.dim
                            }
                            DecodeText {
                                x: -Math.cos(mk.ang) * 20 - width / 2
                                y: -Math.sin(mk.ang) * 14 - height / 2
                                decode: false
                                text: mk.modelData.special ?? String(mk.modelData.id).padStart(2, "0")
                                font.pixelSize: 9
                                color: mk.modelData.id === map.current ? SpaceTheme.accent : SpaceTheme.dim
                            }
                        }
                    }

                    Repeater {
                        model: map.bodies
                        Item {
                            id: bd
                            required property var modelData
                            readonly property var p: map.screenOf(modelData)
                            readonly property real rpx: p ? modelData.r * map.bloom * map.cam.f / p.z : 0
                            z: 4 + (p ? 1 - Math.min(1, p.z / 500) : 0)
                            Terrain {
                                id: pl
                                visible: !!bd.p && bd.rpx > 1.2 && bd.p.z < 400
                                width: Math.max(4, bd.rpx / 0.4)
                                height: width
                                x: (bd.p?.x ?? 0) - win.ox - width / 2
                                y: (bd.p?.y ?? 0) - win.oy - height / 2
                                rise: 1
                                clear: 1
                                endR: 0.4
                                kind: bd.modelData.kind === "moon" ? 1 : 0
                                hue: bd.modelData.hue
                                seed: bd.modelData.seed
                                sun: map.sunDir(map.shown(bd.modelData), bd.modelData.star)
                                opacity: (bd.p ? Math.min(1, (400 - bd.p.z) / 120) : 0) * (map.isTransit(bd.modelData) && map.ascent < 0.995 ? 0 : 1)
                            }
                            DecodeText {
                                visible: pl.visible && bd.modelData.kind !== "home" && !bd.modelData.natural && map.aimed === bd.modelData
                                x: pl.x + pl.width / 2 + bd.rpx + 8
                                y: pl.y + pl.height / 2 - 7
                                decode: false
                                text: bd.modelData.kind === "moon" ? (bd.modelData.special ?? "") : map.appOf(bd.modelData.window)
                                font.pixelSize: 10
                                color: SpaceTheme.accent
                            }
                        }
                    }

                    Item {
                        readonly property var p: map.aimed && !map.busy ? map.screenOf(map.aimed) : null
                        visible: !!p
                        x: (p?.x ?? 0) - win.ox
                        y: (p?.y ?? 0) - win.oy
                        z: 8
                        Rectangle { anchors.centerIn: parent; width: 24; height: 24; rotation: 45; color: "transparent"; antialiasing: true; border.width: 1; border.color: SpaceTheme.accent }
                    }

                    Item {
                        id: cardBox
                        readonly property var o: map.carded
                        readonly property var p: o ? map.screenOf(o) : null
                        visible: !!p && p.x - win.ox > -320 && p.x - win.ox < win.width
                        x: p ? Math.min(win.width - 290, p.x - win.ox + 44) : 0
                        y: p ? Math.max(20, Math.min(win.height - card.height - 20, p.y - win.oy - 30)) : 0
                        z: 10
                        Rectangle {
                            id: card
                            width: 250
                            height: info.height + 22
                            color: SpaceTheme.alpha(SpaceTheme.bg, 0.72)
                            border.width: 1
                            border.color: SpaceTheme.alpha(SpaceTheme.fg, 0.08)
                            Rectangle { width: 2; height: parent.height; color: SpaceTheme.accent }
                            Column {
                                id: info
                                readonly property var o: cardBox.o
                                readonly property real hue: o ? o.hue ?? map.sysHue(o) : 0
                                readonly property string accent: SpaceWorld.palette(hue).colors.color9
                                readonly property string world: SpaceWorld.random ? accent : SpaceWorld.themeFor(hue)?.t.name ?? accent
                                readonly property string kind: o?.kind ?? ""
                                readonly property var wins: kind === "ws" ? (o.ws?.toplevels?.values ?? []) : []
                                x: 16
                                y: 11
                                width: parent.width - 30
                                spacing: 4
                                DecodeText {
                                    font.pixelSize: 12
                                    color: SpaceTheme.fg
                                    text: info.kind === "ws" ? map.sysName(info.o.id) + (info.o.id === map.current ? "  (you)" : "")
                                        : info.kind === "planet" ? map.appOf(info.o.window) || "planet"
                                        : info.kind === "moon" ? (info.o.natural ? "moon" : info.o.special)
                                        : info.kind === "home" ? (info.o.sys.kind === "ws" ? map.sysName(info.o.sys.id) + " home" : "uncharted world")
                                        : info.kind ? "uncharted system" : ""
                                }
                                Row {
                                    spacing: 8
                                    DecodeText {
                                        color: SpaceTheme.accent
                                        text: info.kind === "ws" ? (info.wins.length + 1) + (info.wins.length ? " planets" : " planet")
                                            : info.kind === "planet" ? "planet of " + map.sysName(info.o.wsid)
                                            : info.kind === "moon" ? (info.o.natural ? "of " + (info.o.sys.kind === "ws" ? map.sysName(info.o.sys.id) : "an uncharted world") : "scratchpad moon")
                                            : info.kind === "home" ? (info.o.sys.kind === "ws" ? "your world" : "a new world")
                                            : info.kind ? "1 planet  //  unexplored" : ""
                                    }
                                }
                                Repeater {
                                    model: info.wins.slice(0, 8)
                                    DecodeText {
                                        caps: false; elide: Text.ElideRight; font.pixelSize: 11; color: SpaceTheme.dim
                                        required property var modelData
                                        width: info.width
                                        text: "◦ " + (map.appOf(modelData) || "window") + (modelData.title ? "  " + modelData.title : "")
                                    }
                                }
                                DecodeText { caps: false; elide: Text.ElideRight; font.pixelSize: 11; color: SpaceTheme.dim; width: info.width; visible: info.kind === "planet"; text: info.o?.window?.title ?? "" }
                                Item {
                                    width: info.width
                                    height: hint.height
                                    DecodeText {
                                        id: hint
                                        color: SpaceTheme.alpha(SpaceTheme.fg, 0.4)
                                        font.pixelSize: 9
                                        text: !info.kind ? "" : info.o.star ? "click  land" : info.o.id === map.sel?.id ? "click  land here" : "click  fly to it"
                                    }
                                    DecodeText { anchors.right: parent.right; font.pixelSize: 9; visible: !!info.kind; text: info.world; color: info.accent }
                                }
                            }
                        }
                    }

                    // Center reference dot
                    Item {
                        visible: win.main
                        x: map.cx - win.ox
                        y: map.cy - win.oy
                        z: 11
                        opacity: map.ui * 0.3
                        Rectangle { anchors.centerIn: parent; width: 6; height: 6; radius: 3; color: "transparent"; border.width: 1; border.color: SpaceTheme.dim }
                    }

                    // Mouse targeting reticle (directly follows mouse position)
                    Item {
                        visible: win.main
                        x: map.aimX - win.ox
                        y: map.aimY - win.oy
                        z: 12
                        opacity: map.ui * 0.85
                        Rectangle {
                            anchors.centerIn: parent
                            width: 20
                            height: 20
                            radius: 10
                            color: "transparent"
                            border.width: 1.5
                            border.color: map.aimed ? SpaceTheme.accent : map.steering ? SpaceTheme.alpha(SpaceTheme.accent, 0.5) : SpaceTheme.fg
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                        }
                        Rectangle {
                            anchors.centerIn: parent
                            width: 4
                            height: 4
                            radius: 2
                            color: map.aimed ? SpaceTheme.accent : map.steering ? SpaceTheme.alpha(SpaceTheme.accent, 0.5) : SpaceTheme.fg
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    DecodeText {
                        visible: win.main && map.ui > 0
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: 26
                        opacity: map.ui * (map.idle ? 0 : 1)
                        Behavior on opacity { Settle { duration: SpaceTheme.ms(600) } }
                        decode: false
                        text: "mouse  aim & steer    scroll  zoom in/out    wasd  fly    shift  fast    q e  turn    tab  next    click  select    esc  exit"
                        color: SpaceTheme.alpha(SpaceTheme.fg, 0.45)
                    }
                }

                Terrain {
                    anchors.fill: parent
                    z: 50
                    visible: map.warm || map.ground * map.veil > 0
                    opacity: map.warm ? 0.0015 : map.ground * Math.min(1, map.veil * 2)
                    layer.enabled: visible && SpaceRenderScale.scale < 1
                    layer.textureSize: SpaceRenderScale.size(width, height, win.modelData)
                    ws: map.landWs
                    asTheme: true
                    screenX: win.ox
                    hue: map.landHue
                    seed: map.landSeed
                    rise: map.ascent
                    clear: 1
                    orbit: win.main ? 1 : 0
                    endR: map.endR
                    sun: map.sunDir(map.transitLight?.[0], map.transitLight?.[1])
                    moonless: win.modelData === home ? 0 : 1
                    moonEnd: win.main && !moonless ? map.moonEnd : Qt.vector4d(0, 0, 0, 0)
                }

                // Frosted window cards representation falling away on ascent
                Item {
                    id: shots
                    z: 51
                    width: win.width
                    height: win.height
                    y: map.fall * height
                    visible: map.fall < 1
                    opacity: 1 - map.fall

                    Repeater {
                        model: (MangoService.windows || []).filter(w => {
                            if (w.monitor && w.monitor !== win.modelData.name) return false;
                            if (Array.isArray(w.tags)) return w.tags.includes(map.current);
                            return w.tag === map.current;
                        })
                        Rectangle {
                            required property var modelData
                            x: (modelData.x || 100) - win.ox
                            y: (modelData.y || 100) - win.oy
                            width: modelData.width || 600
                            height: modelData.height || 400
                            radius: 8
                            color: SpaceTheme.alpha(SpaceTheme.bg, 0.5)
                            border.width: 1
                            border.color: SpaceTheme.alpha(SpaceTheme.accent, 0.3)

                            Column {
                                anchors.centerIn: parent
                                spacing: 8
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.appid || modelData.app_id || "Window"
                                    font.family: SpaceTheme.font
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: SpaceTheme.fg
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.title || ""
                                    font.family: SpaceTheme.font
                                    font.pixelSize: 11
                                    color: SpaceTheme.dim
                                    elide: Text.ElideRight
                                    width: Math.min(parent.parent.width - 40, 400)
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.BlankCursor
                onPositionChanged: m => map.look(m.x + win.ox, m.y + win.oy)
                onClicked: map.act()
                onWheel: wheel => {
                    if (wheel.angleDelta.y > 0) {
                        map.zoomIn()
                    } else if (wheel.angleDelta.y < 0) {
                        map.zoomOut()
                    }
                }
            }
            Item {
                id: keyCatcher
                focus: win.main
                Component.onCompleted: {
                    if (win.main) forceActiveFocus()
                }
                Keys.onPressed: e => map.key(e, true)
                Keys.onReleased: e => map.key(e, false)
            }
        }
    }
}
