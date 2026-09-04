pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    Component.onCompleted: {
        DgopService.addRef(["network"]);
        root.checkDayRollover();
    }

    Component.onDestruction: {
        root.saveHistory();
        DgopService.removeRef(["network"]);
    }

    // --- Rate & Byte Formatting Helpers ---
    function formatSpeed(bytesPerSec) {
        if (!bytesPerSec || bytesPerSec <= 0) return "0 K";
        if (bytesPerSec < 1024) return bytesPerSec.toFixed(0) + " B";
        if (bytesPerSec < 1024 * 1024) return (bytesPerSec / 1024).toFixed(0) + " K";
        if (bytesPerSec < 1024 * 1024 * 1024) {
            var mb = bytesPerSec / (1024 * 1024);
            return (mb < 10 ? mb.toFixed(1) : mb.toFixed(0)) + " M";
        }
        return (bytesPerSec / (1024 * 1024 * 1024)).toFixed(1) + " G";
    }

    function formatBytes(bytes) {
        if (!bytes || bytes <= 0) return "0B";
        if (bytes < 1024) return bytes.toFixed(0) + "B";
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + "K";
        if (bytes < 1024 * 1024 * 1024) return (bytes / (1024 * 1024)).toFixed(1) + "M";
        return (bytes / (1024 * 1024 * 1024)).toFixed(1) + "G";
    }

    // --- Uptime Metrics (from /proc/net/dev via DgopService) ---
    readonly property real uptimeRx: DgopService.lastNetworkStats ? (DgopService.lastNetworkStats.rx || 0) : 0
    readonly property real uptimeTx: DgopService.lastNetworkStats ? (DgopService.lastNetworkStats.tx || 0) : 0

    // --- Persistence & History State ---
    property string currentDate: ""
    property real bootBaselineRx: 0
    property real bootBaselineTx: 0
    property real savedTodayRx: 0
    property real savedTodayTx: 0
    property var historyDays: [] // Array of { date: "YYYY-MM-DD", rx: Number, tx: Number }

    // --- Data Plan & Quota Tracking ---
    property bool dataPlanEnabled: false
    property real dataPlanQuotaMB: 2048 // In MB (default 2048 MB = 2 GB)
    property var dataPlanRules: [
        { id: "rule_80", threshold: "80%", type: "percent", value: 80, command: "" },
        { id: "rule_100", threshold: "100%", type: "percent", value: 100, command: "" }
    ]
    property var firedRuleIds: []

    // --- Today & 7-Day Weekly Metrics ---
    readonly property real sessionTodayRx: (bootBaselineRx > 0 && uptimeRx >= bootBaselineRx) ? (uptimeRx - bootBaselineRx) : 0
    readonly property real sessionTodayTx: (bootBaselineTx > 0 && uptimeTx >= bootBaselineTx) ? (uptimeTx - bootBaselineTx) : 0
    readonly property real todayRx: savedTodayRx + sessionTodayRx
    readonly property real todayTx: savedTodayTx + sessionTodayTx

    readonly property real weeklyRx: {
        let sum = todayRx;
        for (let i = 0; i < historyDays.length; i++) {
            sum += (historyDays[i].rx || 0);
        }
        return sum;
    }

    readonly property real weeklyTx: {
        let sum = todayTx;
        for (let i = 0; i < historyDays.length; i++) {
            sum += (historyDays[i].tx || 0);
        }
        return sum;
    }

    // --- Quota Computed Metrics ---
    readonly property real dataPlanUsedBytes: todayRx + todayTx
    readonly property real dataPlanQuotaBytes: Math.max(1, dataPlanQuotaMB * 1024 * 1024)
    readonly property real dataPlanProgress: Math.min(1.0, dataPlanUsedBytes / dataPlanQuotaBytes)
    readonly property real dataPlanPercent: Math.min(100.0, (dataPlanUsedBytes / dataPlanQuotaBytes) * 100.0)

    readonly property string summaryTooltipText: {
        let t = `↓ ${root.formatBytes(root.uptimeRx)}/${root.formatBytes(root.todayRx)}/${root.formatBytes(root.weeklyRx)}  ↑ ${root.formatBytes(root.uptimeTx)}/${root.formatBytes(root.todayTx)}/${root.formatBytes(root.weeklyTx)}`;
        if (root.dataPlanEnabled) {
            t += `\nQuota: ${root.formatBytes(root.dataPlanUsedBytes)} / ${root.formatBytes(root.dataPlanQuotaBytes)} (${root.dataPlanPercent.toFixed(0)}%)`;
        }
        return t;
    }

    // --- Date & Cache Engine Helpers ---
    function getTodayDateStr() {
        const d = new Date();
        const year = d.getFullYear();
        const month = String(d.getMonth() + 1).padStart(2, '0');
        const day = String(d.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }

    function parseThreshold(input) {
        if (!input) return null;
        const str = input.trim();
        if (!str) return null;

        if (str.endsWith("%")) {
            const val = parseFloat(str.replace("%", "").trim());
            if (!isNaN(val) && val > 0) {
                return { threshold: `${val}%`, type: "percent", value: val };
            }
        } else if (str.toLowerCase().endsWith("gb") || str.toLowerCase().endsWith("g")) {
            const numStr = str.toLowerCase().replace(/gb|g/, "").trim();
            const val = parseFloat(numStr);
            if (!isNaN(val) && val > 0) {
                return { threshold: `${val} GB`, type: "bytes", value: Math.round(val * 1024 * 1024 * 1024) };
            }
        } else if (str.toLowerCase().endsWith("mb") || str.toLowerCase().endsWith("m")) {
            const numStr = str.toLowerCase().replace(/mb|m/, "").trim();
            const val = parseFloat(numStr);
            if (!isNaN(val) && val > 0) {
                return { threshold: `${val} MB`, type: "bytes", value: Math.round(val * 1024 * 1024) };
            }
        } else {
            const val = parseFloat(str);
            if (!isNaN(val) && val > 0) {
                if (val <= 100) {
                    return { threshold: `${val}%`, type: "percent", value: val };
                } else {
                    return { threshold: `${val} MB`, type: "bytes", value: Math.round(val * 1024 * 1024) };
                }
            }
        }
        return null;
    }

    function isRuleTriggered(rule, usedBytes, quotaBytes) {
        if (!rule) return false;
        if (rule.type === "percent") {
            if (quotaBytes <= 0) return false;
            const pct = (usedBytes / quotaBytes) * 100;
            return pct >= rule.value;
        } else if (rule.type === "bytes") {
            return usedBytes >= rule.value;
        } else if (rule.type === "mb") {
            return usedBytes >= (rule.value * 1024 * 1024);
        }
        return false;
    }

    function checkQuotaRules() {
        if (!dataPlanEnabled || dataPlanQuotaMB <= 0) return;

        const used = dataPlanUsedBytes;
        const quota = dataPlanQuotaBytes;
        let modified = false;
        const currentFired = Array.isArray(firedRuleIds) ? [...firedRuleIds] : [];

        for (let i = 0; i < dataPlanRules.length; i++) {
            const rule = dataPlanRules[i];
            if (!rule || !rule.id) continue;
            if (currentFired.indexOf(rule.id) !== -1) continue;

            if (isRuleTriggered(rule, used, quota)) {
                currentFired.push(rule.id);
                modified = true;

                const pct = dataPlanPercent.toFixed(1);
                let bodyText = `Used: ${root.formatBytes(used)} / ${root.formatBytes(quota)} (${pct}%)`;
                const cmd = (rule.command || "").trim();
                if (cmd.length > 0) {
                    bodyText += `\nExecuted: ${cmd}`;
                    try {
                        Quickshell.execDetached(["sh", "-c", cmd]);
                    } catch (err) {
                        console.warn("Failed to execute data plan action:", err);
                    }
                }

                const urgency = dataPlanPercent >= 90 ? "critical" : "normal";
                try {
                    Quickshell.execDetached(["notify-send", "-u", urgency, "-a", "DMS Network", `⚠️ Data Quota Alert (${rule.threshold})`, bodyText]);
                } catch (err) {
                    console.warn("Failed to send quota notification:", err);
                }
            }
        }

        if (modified) {
            firedRuleIds = currentFired;
            saveHistory();
        }
    }

    function addRule(threshStr, cmdStr) {
        const parsed = root.parseThreshold(threshStr);
        if (!parsed) return false;
        const newRule = {
            id: "rule_" + Date.now() + "_" + Math.floor(Math.random() * 1000),
            threshold: parsed.threshold,
            type: parsed.type,
            value: parsed.value,
            command: (cmdStr || "").trim()
        };
        const currentRules = Array.isArray(root.dataPlanRules) ? [...root.dataPlanRules] : [];
        currentRules.push(newRule);
        root.dataPlanRules = currentRules;
        root.saveHistory();
        root.checkQuotaRules();
        return true;
    }

    function deleteRule(idx) {
        if (idx >= 0 && idx < root.dataPlanRules.length) {
            const currentRules = [...root.dataPlanRules];
            currentRules.splice(idx, 1);
            root.dataPlanRules = currentRules;
            root.saveHistory();
        }
    }

    function resetFiredRules() {
        root.firedRuleIds = [];
        root.saveHistory();
        root.checkQuotaRules();
    }

    function checkDayRollover() {
        const todayStr = getTodayDateStr();
        if (!currentDate) {
            currentDate = todayStr;
            bootBaselineRx = uptimeRx;
            bootBaselineTx = uptimeTx;
            return;
        }

        if (currentDate !== todayStr) {
            const completedDay = {
                date: currentDate,
                rx: todayRx,
                tx: todayTx
            };
            let newHist = [...historyDays, completedDay];
            if (newHist.length > 6) {
                newHist = newHist.slice(newHist.length - 6);
            }
            historyDays = newHist;
            currentDate = todayStr;
            savedTodayRx = 0;
            savedTodayTx = 0;
            bootBaselineRx = uptimeRx;
            bootBaselineTx = uptimeTx;
            firedRuleIds = [];
            saveHistory();
        }
    }

    function getSevenDaysList() {
        const list = [];
        const d = new Date();
        const daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

        for (let i = 6; i >= 1; i--) {
            const pastDate = new Date();
            pastDate.setDate(d.getDate() - i);
            const y = pastDate.getFullYear();
            const m = String(pastDate.getMonth() + 1).padStart(2, '0');
            const day = String(pastDate.getDate()).padStart(2, '0');
            const dateStr = `${y}-${m}-${day}`;
            const dayName = daysOfWeek[pastDate.getDay()];

            let found = null;
            for (let j = 0; j < historyDays.length; j++) {
                if (historyDays[j].date === dateStr) {
                    found = historyDays[j];
                    break;
                }
            }

            list.push({
                dayLabel: dayName,
                dateStr: dateStr,
                rx: found ? (found.rx || 0) : 0,
                tx: found ? (found.tx || 0) : 0,
                isToday: false
            });
        }

        list.push({
            dayLabel: "Today",
            dateStr: currentDate || getTodayDateStr(),
            rx: todayRx,
            tx: todayTx,
            isToday: true
        });

        return list;
    }

    function loadHistory(content) {
        try {
            if (!content || !content.trim()) {
                initFresh();
                return;
            }
            const data = JSON.parse(content);
            const todayStr = getTodayDateStr();

            dataPlanEnabled = (data.dataPlanEnabled !== undefined) ? data.dataPlanEnabled : false;
            dataPlanQuotaMB = data.dataPlanQuotaMB || 2048;
            dataPlanRules = Array.isArray(data.dataPlanRules) ? data.dataPlanRules : [
                { id: "rule_80", threshold: "80%", type: "percent", value: 80, command: "" },
                { id: "rule_100", threshold: "100%", type: "percent", value: 100, command: "" }
            ];

            if (data.currentDate === todayStr) {
                currentDate = todayStr;
                savedTodayRx = data.savedTodayRx || 0;
                savedTodayTx = data.savedTodayTx || 0;
                historyDays = Array.isArray(data.historyDays) ? data.historyDays : [];
                firedRuleIds = Array.isArray(data.firedRuleIds) ? data.firedRuleIds : [];
            } else {
                let newHist = Array.isArray(data.historyDays) ? [...data.historyDays] : [];
                if (data.currentDate) {
                    newHist.push({
                        date: data.currentDate,
                        rx: data.savedTodayRx || 0,
                        tx: data.savedTodayTx || 0
                    });
                }
                if (newHist.length > 6) {
                    newHist = newHist.slice(newHist.length - 6);
                }
                historyDays = newHist;
                currentDate = todayStr;
                savedTodayRx = 0;
                savedTodayTx = 0;
                firedRuleIds = [];
            }
        } catch (e) {
            initFresh();
        }

        bootBaselineRx = uptimeRx;
        bootBaselineTx = uptimeTx;
        if (dataPlanEnabled) {
            checkQuotaRules();
        }
    }

    function initFresh() {
        currentDate = getTodayDateStr();
        savedTodayRx = 0;
        savedTodayTx = 0;
        historyDays = [];
        dataPlanEnabled = false;
        dataPlanQuotaMB = 2048;
        dataPlanRules = [
            { id: "rule_80", threshold: "80%", type: "percent", value: 80, command: "" },
            { id: "rule_100", threshold: "100%", type: "percent", value: 100, command: "" }
        ];
        firedRuleIds = [];
        bootBaselineRx = uptimeRx;
        bootBaselineTx = uptimeTx;
    }

    function saveHistory() {
        if (!currentDate) return;
        const data = {
            currentDate: currentDate,
            savedTodayRx: todayRx,
            savedTodayTx: todayTx,
            historyDays: historyDays,
            dataPlanEnabled: dataPlanEnabled,
            dataPlanQuotaMB: dataPlanQuotaMB,
            dataPlanRules: dataPlanRules,
            firedRuleIds: firedRuleIds
        };
        try {
            historyFile.setText(JSON.stringify(data, null, 2));
        } catch (e) {
            console.warn("Failed to save compact network history:", e);
        }
    }

    // --- Quickshell Native File Storage ---
    FileView {
        id: historyFile
        path: Quickshell.env("HOME") + "/.cache/DankMaterialShell/compact-network-history.json"
        blockLoading: true
        blockWrites: true
        atomicWrites: true
        watchChanges: false
        onLoaded: root.loadHistory(historyFile.text())
        onLoadFailed: error => root.initFresh()
    }

    // Periodic rollover check and disk save every 30 minutes
    Timer {
        interval: 30 * 60 * 1000
        running: true
        repeat: true
        onTriggered: {
            root.checkDayRollover();
            root.checkQuotaRules();
            root.saveHistory();
        }
    }

    onUptimeRxChanged: {
        if (bootBaselineRx === 0 && uptimeRx > 0) {
            bootBaselineRx = uptimeRx;
            bootBaselineTx = uptimeTx;
        }
        root.checkDayRollover();
        root.checkQuotaRules();
    }

    // --- Dropdown Popout Settings ---
    popoutWidth: 420
    popoutHeight: 340

    popoutContent: Component {
        PopoutComponent {
            id: popout

            headerText: I18n.tr("Network Statistics")
            detailsText: I18n.tr("Uptime / Today / 7-Day")
            showCloseButton: true

            property int selectedDayIndex: -1
            property var daysData: root.getSevenDaysList()

            Column {
                width: parent.width
                spacing: Theme.spacingM

                // --- Summary Stats Card (Download & Upload) ---
                Rectangle {
                    width: parent.width
                    implicitHeight: statsCol.implicitHeight + Theme.spacingM * 2
                    radius: Theme.cornerRadius
                    color: Theme.nestedSurface
                    border.width: 1
                    border.color: Theme.outlineLight

                    Column {
                        id: statsCol
                        anchors.centerIn: parent
                        width: parent.width - Theme.spacingM * 2
                        spacing: Theme.spacingS

                        Row {
                            width: parent.width
                            spacing: Theme.spacingS

                            StyledText {
                                text: "↓ " + I18n.tr("Download")
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                                color: Theme.primary
                                width: 85
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: `${root.formatBytes(root.uptimeRx)} / ${root.formatBytes(root.todayRx)} / ${root.formatBytes(root.weeklyRx)}`
                                font.pixelSize: Theme.fontSizeSmall
                                isMonospace: true
                                color: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingS

                            StyledText {
                                text: "↑ " + I18n.tr("Upload")
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                                color: Theme.tertiary
                                width: 85
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: `${root.formatBytes(root.uptimeTx)} / ${root.formatBytes(root.todayTx)} / ${root.formatBytes(root.weeklyTx)}`
                                font.pixelSize: Theme.fontSizeSmall
                                isMonospace: true
                                color: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                // --- Quota Progress Bar Card (visible when dataPlanEnabled) ---
                Rectangle {
                    visible: root.dataPlanEnabled
                    width: parent.width
                    implicitHeight: visible ? (quotaCol.implicitHeight + Theme.spacingM * 2) : 0
                    radius: Theme.cornerRadius
                    color: Theme.nestedSurface
                    border.width: 1
                    border.color: Theme.outlineLight

                    Column {
                        id: quotaCol
                        anchors.centerIn: parent
                        width: parent.width - Theme.spacingM * 2
                        spacing: Theme.spacingS

                        Item {
                            width: parent.width
                            height: 18

                            StyledText {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: I18n.tr("Daily Quota")
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                                color: Theme.surfaceText
                            }

                            StyledText {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: `${root.formatBytes(root.dataPlanUsedBytes)} / ${root.formatBytes(root.dataPlanQuotaBytes)} (${root.dataPlanPercent.toFixed(1)}%)`
                                font.pixelSize: Theme.fontSizeSmall
                                isMonospace: true
                                font.bold: true
                                color: root.dataPlanPercent >= 100 ? Theme.error : (root.dataPlanPercent >= 80 ? Theme.warning : Theme.primary)
                            }
                        }

                        // Progress Bar Track & Indicator
                        Rectangle {
                            width: parent.width
                            height: 8
                            radius: 4
                            color: Theme.outlineLight
                            clip: true

                            Rectangle {
                                width: Math.min(parent.width, parent.width * root.dataPlanProgress)
                                height: parent.height
                                radius: 4
                                color: root.dataPlanPercent >= 100 ? Theme.error : (root.dataPlanPercent >= 80 ? Theme.warning : Theme.primary)

                                Behavior on width {
                                    NumberAnimation {
                                        duration: Theme.shortDuration
                                        easing.type: Theme.standardEasing
                                    }
                                }
                            }
                        }
                    }
                }

                // --- 7-Day Stock-Style Bar & Trendline Chart ---
                Rectangle {
                    width: parent.width
                    height: 190
                    radius: Theme.cornerRadius
                    color: Theme.nestedSurface
                    border.width: 1
                    border.color: Theme.outlineLight
                    clip: true

                    // Chart Header Bar (shows hovered day info or general subtitle)
                    Row {
                        anchors.top: parent.top
                        anchors.topMargin: Theme.spacingS
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingM
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacingM
                        height: 20

                        StyledText {
                            text: {
                                if (popout.selectedDayIndex >= 0 && popout.selectedDayIndex < popout.daysData.length) {
                                    const d = popout.daysData[popout.selectedDayIndex];
                                    return `${d.dayLabel} (${d.dateStr}):  ↓ ${root.formatBytes(d.rx)}   ↑ ${root.formatBytes(d.tx)}`;
                                }
                                return I18n.tr("7-Day Traffic Trend");
                            }
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: popout.selectedDayIndex >= 0
                            color: popout.selectedDayIndex >= 0 ? Theme.primary : Theme.surfaceVariantText
                        }
                    }

                    // Main Chart Drawing Canvas
                    Item {
                        id: chartArea
                        anchors.top: parent.top
                        anchors.topMargin: 30
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingM
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacingM
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 24

                        readonly property real maxVal: {
                            let m = 1024 * 1024 * 100; // Minimum 100MB scale
                            for (let i = 0; i < popout.daysData.length; i++) {
                                const tot = (popout.daysData[i].rx || 0) + (popout.daysData[i].tx || 0);
                                if (tot > m) m = tot;
                            }
                            return m * 1.2;
                        }

                        // Horizontal Reference Grid Lines
                        Repeater {
                            model: [0.33, 0.66, 1.0]
                            Item {
                                width: chartArea.width
                                y: chartArea.height * (1 - modelData)
                                Rectangle {
                                    width: parent.width
                                    height: 1
                                    color: Theme.outlineLight
                                    opacity: 0.4
                                }
                                StyledText {
                                    text: root.formatBytes(chartArea.maxVal * modelData)
                                    font.pixelSize: 8
                                    color: Theme.surfaceVariantText
                                    opacity: 0.65
                                    anchors.right: parent.right
                                    anchors.bottom: parent.top
                                    anchors.bottomMargin: 1
                                }
                            }
                        }

                        // Stock-Style Trendline & Area Gradient
                        Canvas {
                            id: trendCanvas
                            anchors.fill: parent
                            renderStrategy: Canvas.Cooperative

                            property var days: popout.daysData
                            property real maxV: chartArea.maxVal

                            onDaysChanged: requestPaint()
                            onWidthChanged: requestPaint()
                            onHeightChanged: requestPaint()

                            onPaint: {
                                const ctx = getContext("2d");
                                ctx.reset();
                                ctx.clearRect(0, 0, width, height);

                                if (!days || days.length === 0) return;

                                const step = width / days.length;
                                const pts = [];
                                for (let i = 0; i < days.length; i++) {
                                    const tot = (days[i].rx || 0) + (days[i].tx || 0);
                                    const x = step * i + step / 2;
                                    const y = height - (tot / maxV) * height;
                                    pts.push({ x: x, y: y });
                                }

                                // Area fill gradient under curve
                                const grad = ctx.createLinearGradient(0, 0, 0, height);
                                grad.addColorStop(0, Theme.withAlpha(Theme.primary, 0.28));
                                grad.addColorStop(1, Theme.withAlpha(Theme.primary, 0.01));

                                ctx.fillStyle = grad;
                                ctx.beginPath();
                                ctx.moveTo(pts[0].x, height);
                                for (let i = 0; i < pts.length; i++) {
                                    ctx.lineTo(pts[i].x, pts[i].y);
                                }
                                ctx.lineTo(pts[pts.length - 1].x, height);
                                ctx.closePath();
                                ctx.fill();

                                // Smooth trendline stroke
                                ctx.strokeStyle = Theme.primary;
                                ctx.lineWidth = 2;
                                ctx.beginPath();
                                for (let i = 0; i < pts.length; i++) {
                                    if (i === 0) ctx.moveTo(pts[i].x, pts[i].y);
                                    else ctx.lineTo(pts[i].x, pts[i].y);
                                }
                                ctx.stroke();

                                // Stock node indicators (circles)
                                for (let i = 0; i < pts.length; i++) {
                                    ctx.fillStyle = Theme.primary;
                                    ctx.beginPath();
                                    ctx.arc(pts[i].x, pts[i].y, 3.5, 0, 2 * Math.PI);
                                    ctx.fill();

                                    ctx.fillStyle = Theme.surface;
                                    ctx.beginPath();
                                    ctx.arc(pts[i].x, pts[i].y, 1.5, 0, 2 * Math.PI);
                                    ctx.fill();
                                }
                            }
                        }

                        // 7 Vertical Dual-Color Volume Columns
                        Row {
                            anchors.fill: parent
                            spacing: 0

                            Repeater {
                                model: popout.daysData

                                Item {
                                    width: chartArea.width / 7
                                    height: chartArea.height

                                    readonly property real dayTotal: (modelData.rx || 0) + (modelData.tx || 0)
                                    readonly property real barTotalHeight: Math.max(2, (dayTotal / chartArea.maxVal) * height)
                                    readonly property real rxHeight: dayTotal > 0 ? ((modelData.rx || 0) / dayTotal) * barTotalHeight : 0
                                    readonly property real txHeight: dayTotal > 0 ? ((modelData.tx || 0) / dayTotal) * barTotalHeight : 0

                                    Column {
                                        anchors.bottom: parent.bottom
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: Math.max(12, Math.min(22, parent.width * 0.45))
                                        spacing: 0

                                        // Upload (Tx) Portion (Top)
                                        Rectangle {
                                            width: parent.width
                                            height: Math.max(0, txHeight)
                                            color: Theme.tertiary
                                            radius: 2
                                            opacity: popout.selectedDayIndex === index ? 1.0 : 0.85
                                        }

                                        // Download (Rx) Portion (Bottom)
                                        Rectangle {
                                            width: parent.width
                                            height: Math.max(0, rxHeight)
                                            color: Theme.primary
                                            radius: 2
                                            opacity: popout.selectedDayIndex === index ? 1.0 : 0.85
                                        }
                                    }

                                    // Hover inspection area
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: popout.selectedDayIndex = index
                                        onExited: {
                                            if (popout.selectedDayIndex === index) {
                                                popout.selectedDayIndex = -1;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Weekday Labels
                    Row {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Theme.spacingXS
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingM
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacingM
                        height: 16

                        Repeater {
                            model: popout.daysData

                            Item {
                                width: parent.width / 7
                                height: parent.height

                                StyledText {
                                    text: modelData.dayLabel
                                    anchors.centerIn: parent
                                    font.pixelSize: 9
                                    font.bold: modelData.isToday || popout.selectedDayIndex === index
                                    color: popout.selectedDayIndex === index ? Theme.primary : (modelData.isToday ? Theme.surfaceText : Theme.surfaceVariantText)
                                }
                            }
                        }
                    }
                }

                // --- Data Plan & Trigger Rules Settings Card ---
                Rectangle {
                    width: parent.width
                    implicitHeight: planCardCol.implicitHeight + Theme.spacingM * 2
                    radius: Theme.cornerRadius
                    color: Theme.nestedSurface
                    border.width: 1
                    border.color: Theme.outlineLight

                    Column {
                        id: planCardCol
                        anchors.centerIn: parent
                        width: parent.width - Theme.spacingM * 2
                        spacing: Theme.spacingM

                        // Enable / Disable Toggle
                        DankToggle {
                            id: planToggle
                            text: I18n.tr("Data Quota Plan")
                            description: I18n.tr("Configure daily limits and custom action triggers")
                            checked: root.dataPlanEnabled
                            onToggled: function(val) {
                                root.dataPlanEnabled = val;
                                root.saveHistory();
                                if (val) {
                                    root.checkQuotaRules();
                                }
                            }
                        }

                        // Expanded Settings (visible only when enabled)
                        Column {
                            visible: root.dataPlanEnabled
                            width: parent.width
                            spacing: Theme.spacingM

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: Theme.outlineLight
                                opacity: 0.5
                            }

                            // Quota limit configuration row
                            Row {
                                width: parent.width
                                spacing: Theme.spacingS

                                Column {
                                    spacing: 2
                                    width: 100
                                    anchors.verticalCenter: parent.verticalCenter

                                    StyledText {
                                        text: I18n.tr("Daily Quota")
                                        font.pixelSize: Theme.fontSizeSmall
                                        font.bold: true
                                        color: Theme.surfaceText
                                    }

                                    StyledText {
                                        text: I18n.tr("in Megabytes (MB)")
                                        font.pixelSize: 9
                                        color: Theme.surfaceVariantText
                                    }
                                }

                                DankTextField {
                                    id: quotaInput
                                    width: 80
                                    height: 32
                                    text: String(root.dataPlanQuotaMB)
                                    placeholderText: "2048"
                                    onEditingFinished: {
                                        const v = parseFloat(text);
                                        if (!isNaN(v) && v > 0) {
                                            root.dataPlanQuotaMB = v;
                                            root.saveHistory();
                                            root.checkQuotaRules();
                                        }
                                    }
                                    onAccepted: editingFinished()
                                }

                                // Preset quick-select chips
                                Row {
                                    spacing: Theme.spacingXS
                                    anchors.verticalCenter: parent.verticalCenter

                                    Repeater {
                                        model: [
                                            { label: "1GB", val: 1024 },
                                            { label: "2GB", val: 2048 },
                                            { label: "5GB", val: 5120 }
                                        ]

                                        Rectangle {
                                            width: presetText.implicitWidth + Theme.spacingS * 2
                                            height: 28
                                            radius: 4
                                            color: root.dataPlanQuotaMB === modelData.val ? Theme.primary : (presetMouse.containsMouse ? Theme.surfaceTextHover : Theme.surfaceContainerHigh)
                                            border.width: 1
                                            border.color: root.dataPlanQuotaMB === modelData.val ? Theme.primary : Theme.outlineLight

                                            StyledText {
                                                id: presetText
                                                anchors.centerIn: parent
                                                text: modelData.label
                                                font.pixelSize: 10
                                                font.bold: true
                                                color: root.dataPlanQuotaMB === modelData.val ? Theme.onPrimary : Theme.surfaceText
                                            }

                                            MouseArea {
                                                id: presetMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    root.dataPlanQuotaMB = modelData.val;
                                                    quotaInput.text = String(modelData.val);
                                                    root.saveHistory();
                                                    root.checkQuotaRules();
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Rules Section Header
                            Item {
                                width: parent.width
                                height: 20

                                StyledText {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: I18n.tr("Notification & Action Rules")
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.bold: true
                                    color: Theme.surfaceText
                                }

                                // Reset fired button if any rule fired today
                                Rectangle {
                                    visible: (root.firedRuleIds || []).length > 0
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: resetRow.implicitWidth + 8
                                    height: 20
                                    radius: 4
                                    color: resetMouse.containsMouse ? Theme.surfaceTextHover : "transparent"

                                    Row {
                                        id: resetRow
                                        anchors.centerIn: parent
                                        spacing: 2
                                        DankIcon {
                                            name: "refresh"
                                            size: 11
                                            color: Theme.primary
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        StyledText {
                                            text: I18n.tr("Reset alerts")
                                            font.pixelSize: 9
                                            color: Theme.primary
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    MouseArea {
                                        id: resetMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.resetFiredRules()
                                    }
                                }
                            }

                            // Existing Rules List
                            Column {
                                width: parent.width
                                spacing: Theme.spacingXS

                                Repeater {
                                    model: root.dataPlanRules

                                    Rectangle {
                                        width: parent.width
                                        height: 32
                                        radius: 6
                                        color: Theme.surfaceContainerHigh
                                        border.width: 1
                                        border.color: Theme.outlineLight

                                        readonly property bool isFired: (root.firedRuleIds || []).indexOf(modelData.id) !== -1

                                        Row {
                                            anchors.left: parent.left
                                            anchors.leftMargin: Theme.spacingS
                                            anchors.right: deleteBtn.left
                                            anchors.rightMargin: Theme.spacingS
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: Theme.spacingS

                                            // Threshold badge
                                            Rectangle {
                                                height: 20
                                                width: badgeText.implicitWidth + 10
                                                radius: 4
                                                color: Theme.withAlpha(Theme.primary, 0.18)
                                                anchors.verticalCenter: parent.verticalCenter

                                                StyledText {
                                                    id: badgeText
                                                    anchors.centerIn: parent
                                                    text: modelData.threshold || ""
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                    color: Theme.primary
                                                }
                                            }

                                            // Status check if fired
                                            DankIcon {
                                                visible: isFired
                                                name: "check_circle"
                                                size: 14
                                                color: Theme.success
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            // Command / Action description
                                            StyledText {
                                                text: modelData.command ? modelData.command : I18n.tr("Notification only")
                                                font.pixelSize: Theme.fontSizeSmall
                                                font.italic: !modelData.command
                                                color: modelData.command ? Theme.surfaceText : Theme.surfaceVariantText
                                                elide: Text.ElideMiddle
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: Math.max(50, parent.width - badgeText.implicitWidth - (isFired ? 24 : 0) - 20)
                                            }
                                        }

                                        // Delete Rule Button
                                        Rectangle {
                                            id: deleteBtn
                                            anchors.right: parent.right
                                            anchors.rightMargin: Theme.spacingS
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: 24
                                            height: 24
                                            radius: 12
                                            color: delMouse.containsMouse ? Theme.withAlpha(Theme.error, 0.15) : "transparent"

                                            DankIcon {
                                                anchors.centerIn: parent
                                                name: "close"
                                                size: 14
                                                color: delMouse.containsMouse ? Theme.error : Theme.surfaceVariantText
                                            }

                                            MouseArea {
                                                id: delMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: root.deleteRule(index)
                                            }
                                        }
                                    }
                                }
                            }

                            // Add New Rule input row
                            Rectangle {
                                width: parent.width
                                implicitHeight: addRuleCol.implicitHeight + Theme.spacingS * 2
                                radius: 6
                                color: Theme.withAlpha(Theme.primary, 0.04)
                                border.width: 1
                                border.color: Theme.withAlpha(Theme.primary, 0.25)

                                Column {
                                    id: addRuleCol
                                    anchors.centerIn: parent
                                    width: parent.width - Theme.spacingS * 2
                                    spacing: Theme.spacingS

                                    Row {
                                        width: parent.width
                                        spacing: Theme.spacingS

                                        DankTextField {
                                            id: newThresholdInput
                                            width: 110
                                            height: 34
                                            placeholderText: I18n.tr("80% or 1.5GB")
                                            onAccepted: addBtnMouse.clicked(null)
                                        }

                                        DankTextField {
                                            id: newCmdInput
                                            width: parent.width - 110 - 70 - Theme.spacingS * 2
                                            height: 34
                                            placeholderText: I18n.tr("Command (optional)")
                                            onAccepted: addBtnMouse.clicked(null)
                                        }

                                        Rectangle {
                                            id: addBtn
                                            width: 70
                                            height: 34
                                            radius: Theme.cornerRadius
                                            color: addBtnMouse.containsMouse ? Theme.withAlpha(Theme.primary, 0.85) : Theme.primary

                                            Row {
                                                anchors.centerIn: parent
                                                spacing: 2

                                                DankIcon {
                                                    name: "add"
                                                    size: 14
                                                    color: Theme.onPrimary
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                StyledText {
                                                    text: I18n.tr("Add")
                                                    font.pixelSize: Theme.fontSizeSmall
                                                    font.bold: true
                                                    color: Theme.onPrimary
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }

                                            MouseArea {
                                                id: addBtnMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (root.addRule(newThresholdInput.text, newCmdInput.text)) {
                                                        newThresholdInput.text = "";
                                                        newCmdInput.text = "";
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // --- Horizontal Bar Pill (with hover tooltip) ---
    horizontalBarPill: Component {
        Item {
            id: horizItem
            implicitWidth: col.implicitWidth
            implicitHeight: root.widgetThickness

            Loader {
                id: horizTooltipLoader
                active: false
                sourceComponent: DankTooltip {}
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton // Lets click pass to BasePill for popout!

                onEntered: {
                    horizTooltipLoader.active = true;
                    if (horizTooltipLoader.item) {
                        const localPos = mapToItem(null, width / 2, height / 2);
                        const currentScreen = root.parentScreen || Screen;
                        const tooltipX = localPos.x;
                        const tooltipY = root.axis?.edge === "bottom" ? (localPos.y - 32) : (localPos.y + 32);
                        horizTooltipLoader.item.show(root.summaryTooltipText, tooltipX, tooltipY, currentScreen, false, false);
                    }
                }
                onExited: {
                    if (horizTooltipLoader.item) {
                        horizTooltipLoader.item.hide();
                    }
                    horizTooltipLoader.active = false;
                }
            }

            Column {
                id: col
                anchors.centerIn: parent
                spacing: 0

                Row {
                    spacing: 2
                    anchors.horizontalCenter: parent.horizontalCenter

                    StyledText {
                        text: "↓"
                        font.pixelSize: Math.max(9, Math.round(Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText) * 0.72))
                        font.bold: true
                        color: Theme.info
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    NumericText {
                        isMonospace: true
                        text: root.formatSpeed(DgopService.networkRxRate)
                        font.pixelSize: Math.max(9, Math.round(Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText) * 0.78))
                        color: Theme.widgetTextColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    spacing: 2
                    anchors.horizontalCenter: parent.horizontalCenter

                    StyledText {
                        text: "↑"
                        font.pixelSize: Math.max(9, Math.round(Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText) * 0.72))
                        font.bold: true
                        color: Theme.error
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    NumericText {
                        isMonospace: true
                        text: root.formatSpeed(DgopService.networkTxRate)
                        font.pixelSize: Math.max(9, Math.round(Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText) * 0.78))
                        color: Theme.widgetTextColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }

    // --- Vertical Bar Pill (with hover tooltip) ---
    verticalBarPill: Component {
        Item {
            id: vertItem
            implicitWidth: root.widgetThickness
            implicitHeight: vcol.implicitHeight

            Loader {
                id: vertTooltipLoader
                active: false
                sourceComponent: DankTooltip {}
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton

                onEntered: {
                    vertTooltipLoader.active = true;
                    if (vertTooltipLoader.item) {
                        const localPos = mapToItem(null, width / 2, height / 2);
                        const currentScreen = root.parentScreen || Screen;
                        const tooltipX = root.axis?.edge === "right" ? (localPos.x - 120) : (localPos.x + 40);
                        const tooltipY = localPos.y;
                        const isLeft = root.axis?.edge === "left";
                        vertTooltipLoader.item.show(root.summaryTooltipText, tooltipX, tooltipY, currentScreen, isLeft, !isLeft);
                    }
                }
                onExited: {
                    if (vertTooltipLoader.item) {
                        vertTooltipLoader.item.hide();
                    }
                    vertTooltipLoader.active = false;
                }
            }

            Column {
                id: vcol
                anchors.centerIn: parent
                spacing: 1

                StyledText {
                    text: "↓"
                    font.pixelSize: Math.max(9, Math.round(Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText) * 0.72))
                    font.bold: true
                    color: Theme.info
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                NumericText {
                    isMonospace: true
                    text: root.formatSpeed(DgopService.networkRxRate)
                    font.pixelSize: Math.max(9, Math.round(Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText) * 0.78))
                    color: Theme.widgetTextColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                StyledText {
                    text: "↑"
                    font.pixelSize: Math.max(9, Math.round(Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText) * 0.72))
                    font.bold: true
                    color: Theme.error
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                NumericText {
                    isMonospace: true
                    text: root.formatSpeed(DgopService.networkTxRate)
                    font.pixelSize: Math.max(9, Math.round(Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText) * 0.78))
                    color: Theme.widgetTextColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
