pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common as DmsCommon

Singleton {
    id: root

    readonly property string font: DmsCommon.Theme.defaultMonoFontFamily || "JetBrainsMono Nerd Font"

    property var saved: null

    function c(i, fallback) {
        if (saved && saved.colors && saved.colors["color" + i])
            return saved.colors["color" + i];
        const dank = DmsCommon.Theme.dank16;
        if (dank && dank["color" + i])
            return dank["color" + i];
        return fallback;
    }

    // Dynamic DMS Matugen wallpaper-derived theme colors
    readonly property color accent: DmsCommon.Theme.primary || c(9, "#8fd3ff")
    readonly property color accent2: DmsCommon.Theme.secondary || c(13, "#c3a6ff")
    readonly property color warn: DmsCommon.Theme.error || c(1, "#e06c75")
    readonly property color fg: DmsCommon.Theme.surfaceText || c(15, "#d8e2f0")
    readonly property color bg: DmsCommon.Theme.background || c(0, "#05070c")
    readonly property color dim: alpha(fg, 0.5)
    readonly property color faint: alpha(fg, 0.14)
    readonly property color edge: alpha(accent, 0.35)
    readonly property color void_: Qt.darker(bg, 2.2)

    readonly property var settle: [0.2, 0.9, 0.3, 1, 1, 1]
    readonly property var leave: [0.2, 0.9, 0.3, 1, 1, 1]

    readonly property int quick: ms(180)
    readonly property int slow: ms(560)

    function ms(d) {
        return Math.round(d);
    }

    function alpha(colorVal, a) {
        const cVal = Qt.color(colorVal);
        return Qt.rgba(cVal.r, cVal.g, cVal.b, a);
    }

    function mix(a, b, t) {
        const ca = Qt.color(a);
        const cb = Qt.color(b);
        return Qt.rgba(ca.r + (cb.r - ca.r) * t, ca.g + (cb.g - ca.g) * t, ca.b + (cb.b - ca.b) * t, 1);
    }

    function slotOf(role) {
        return 9;
    }

    function readable(cVal) {
        return Qt.color(cVal);
    }
}
