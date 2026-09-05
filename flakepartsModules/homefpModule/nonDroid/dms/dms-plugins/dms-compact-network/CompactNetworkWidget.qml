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
        if (uptimeProc) uptimeProc.running = true;
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
    property real todayRx: 0
    property real todayTx: 0
    property real lastRawRx: 0
    property real lastRawTx: 0
    property bool bootedToday: true
    property var historyDays: [] // Array of { date: "YYYY-MM-DD", rx: Number, tx: Number }

    // Compatibility aliases
    readonly property real savedTodayRx: todayRx
    readonly property real savedTodayTx: todayTx

    // --- Data Plan & Quota Tracking ---
    property bool dataPlanEnabled: false
    property real dataPlanQuotaMB: 2048 // In MB (default 2048 MB = 2 GB)
    property var dataPlanRules: [
        { id: "rule_80", threshold: "80%", type: "percent", value: 80, command: "" },
        { id: "rule_100", threshold: "100%", type: "percent", value: 100, command: "" }
    ]
    property var firedRuleIds: []

    // --- 7-Day Weekly Metrics ---

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
            const val = parseFloat(str.slice(0, -1).trim());
            if (!isNaN(val) && val > 0) {
                return { threshold: `${val}%`, type: "percent", value: val };
            }
        } else if (str.toLowerCase().endsWith("gb")) {
            const val = parseFloat(str.slice(0, -2).trim());
            if (!isNaN(val) && val > 0) {
                return { threshold: `${val} GB`, type: "bytes", value: Math.round(val * 1024 * 1024 * 1024) };
            }
        } else if (str.toLowerCase().endsWith("g")) {
            const val = parseFloat(str.slice(0, -1).trim());
            if (!isNaN(val) && val > 0) {
                return { threshold: `${val} GB`, type: "bytes", value: Math.round(val * 1024 * 1024 * 1024) };
            }
        } else if (str.toLowerCase().endsWith("mb")) {
            const val = parseFloat(str.slice(0, -2).trim());
            if (!isNaN(val) && val > 0) {
                return { threshold: `${val} MB`, type: "bytes", value: Math.round(val * 1024 * 1024) };
            }
        } else if (str.toLowerCase().endsWith("m")) {
            const val = parseFloat(str.slice(0, -1).trim());
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

    function deleteRule(idx, ruleId) {
        let currentRules = Array.isArray(root.dataPlanRules) ? [...root.dataPlanRules] : [];
        if (ruleId) {
            currentRules = currentRules.filter(r => r && r.id !== ruleId);
        } else if (typeof idx === "number" && idx >= 0 && idx < currentRules.length) {
            currentRules.splice(idx, 1);
        }
        root.dataPlanRules = currentRules;
        root.saveHistory();
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
            todayRx = 0;
            todayTx = 0;
            lastRawRx = uptimeRx;
            lastRawTx = uptimeTx;
            bootedToday = false;
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
                todayRx = data.todayRx !== undefined ? data.todayRx : (data.savedTodayRx || 0);
                todayTx = data.todayTx !== undefined ? data.todayTx : (data.savedTodayTx || 0);
                lastRawRx = data.lastRawRx || 0;
                lastRawTx = data.lastRawTx || 0;
                historyDays = Array.isArray(data.historyDays) ? data.historyDays : [];
                firedRuleIds = Array.isArray(data.firedRuleIds) ? data.firedRuleIds : [];
            } else {
                let newHist = Array.isArray(data.historyDays) ? [...data.historyDays] : [];
                if (data.currentDate) {
                    newHist.push({
                        date: data.currentDate,
                        rx: data.todayRx !== undefined ? data.todayRx : (data.savedTodayRx || 0),
                        tx: data.todayTx !== undefined ? data.todayTx : (data.savedTodayTx || 0)
                    });
                }
                if (newHist.length > 6) {
                    newHist = newHist.slice(newHist.length - 6);
                }
                historyDays = newHist;
                currentDate = todayStr;
                todayRx = 0;
                todayTx = 0;
                lastRawRx = uptimeRx;
                lastRawTx = uptimeTx;
                bootedToday = false;
                firedRuleIds = [];
            }
        } catch (e) {
            initFresh();
        }

        if (uptimeProc) {
            uptimeProc.running = true;
        }
        root.updateTraffic();
        if (dataPlanEnabled) {
            checkQuotaRules();
        }
    }

    function initFresh() {
        currentDate = getTodayDateStr();
        todayRx = 0;
        todayTx = 0;
        lastRawRx = uptimeRx;
        lastRawTx = uptimeTx;
        if (bootedToday) {
            todayRx = uptimeRx;
            todayTx = uptimeTx;
        }
        historyDays = [];
        dataPlanEnabled = false;
        dataPlanQuotaMB = 2048;
        dataPlanRules = [
            { id: "rule_80", threshold: "80%", type: "percent", value: 80, command: "" },
            { id: "rule_100", threshold: "100%", type: "percent", value: 100, command: "" }
        ];
        firedRuleIds = [];
    }

    function saveHistory() {
        if (!currentDate) return;
        const data = {
            currentDate: currentDate,
            todayRx: todayRx,
            todayTx: todayTx,
            savedTodayRx: todayRx,
            savedTodayTx: todayTx,
            lastRawRx: lastRawRx,
            lastRawTx: lastRawTx,
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

    function updateTraffic() {
        const curRx = root.uptimeRx;
        const curTx = root.uptimeTx;
        if (curRx <= 0 && curTx <= 0) return;

        root.checkDayRollover();

        // Initial sample when lastRaw is not set
        if (root.lastRawRx === 0 && root.lastRawTx === 0) {
            root.lastRawRx = curRx;
            root.lastRawTx = curTx;
            if (root.bootedToday) {
                if (root.todayRx < curRx) root.todayRx = curRx;
                if (root.todayTx < curTx) root.todayTx = curTx;
            }
            root.checkQuotaRules();
            return;
        }

        let deltaRx = 0;
        let deltaTx = 0;

        if (curRx >= root.lastRawRx) {
            deltaRx = curRx - root.lastRawRx;
        } else {
            // Kernel counter wrapped or machine rebooted
            deltaRx = curRx;
        }

        if (curTx >= root.lastRawTx) {
            deltaTx = curTx - root.lastRawTx;
        } else {
            // Kernel counter wrapped or machine rebooted
            deltaTx = curTx;
        }

        root.todayRx += deltaRx;
        root.todayTx += deltaTx;
        root.lastRawRx = curRx;
        root.lastRawTx = curTx;

        // If the system booted today, today's traffic can never be less than uptime traffic
        if (root.bootedToday) {
            if (root.todayRx < curRx) root.todayRx = curRx;
            if (root.todayTx < curTx) root.todayTx = curTx;
        }

        root.checkQuotaRules();
    }

    Process {
        id: uptimeProc
        command: ["cat", "/proc/uptime"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                if (text && text.trim()) {
                    const secs = parseFloat(text.trim().split(" ")[0]);
                    if (!isNaN(secs) && secs > 0) {
                        const now = new Date();
                        const midnight = new Date(now.getFullYear(), now.getMonth(), now.getDate());
                        const secsSinceMidnight = (now.getTime() - midnight.getTime()) / 1000;
                        root.bootedToday = secs <= secsSinceMidnight;
                        if (root.bootedToday) {
                            if (root.todayRx < root.uptimeRx) root.todayRx = root.uptimeRx;
                            if (root.todayTx < root.uptimeTx) root.todayTx = root.uptimeTx;
                        }
                    }
                }
            }
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

    // Periodic rollover check and disk save every 10 minutes
    Timer {
        interval: 10 * 60 * 1000
        running: true
        repeat: true
        onTriggered: {
            if (uptimeProc) uptimeProc.running = true;
            root.checkDayRollover();
            root.checkQuotaRules();
            root.saveHistory();
        }
    }

    onUptimeRxChanged: root.updateTraffic()
    onUptimeTxChanged: root.updateTraffic()

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
                                id: gridLineItem
                                required property int index
                                required property real modelData

                                width: chartArea.width
                                y: chartArea.height * (1 - gridLineItem.modelData)
                                Rectangle {
                                    width: parent.width
                                    height: 1
                                    color: Theme.outlineLight
                                    opacity: 0.4
                                }
                                StyledText {
                                    text: root.formatBytes(chartArea.maxVal * gridLineItem.modelData)
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
                                    id: dayColItem
                                    required property int index
                                    required property var modelData

                                    width: chartArea.width / 7
                                    height: chartArea.height

                                    readonly property real dayTotal: (dayColItem.modelData?.rx || 0) + (dayColItem.modelData?.tx || 0)
                                    readonly property real barTotalHeight: Math.max(2, (dayTotal / chartArea.maxVal) * height)
                                    readonly property real rxHeight: dayTotal > 0 ? ((dayColItem.modelData?.rx || 0) / dayTotal) * barTotalHeight : 0
                                    readonly property real txHeight: dayTotal > 0 ? ((dayColItem.modelData?.tx || 0) / dayTotal) * barTotalHeight : 0

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
                                            opacity: popout.selectedDayIndex === dayColItem.index ? 1.0 : 0.85
                                        }

                                        // Download (Rx) Portion (Bottom)
                                        Rectangle {
                                            width: parent.width
                                            height: Math.max(0, rxHeight)
                                            color: Theme.primary
                                            radius: 2
                                            opacity: popout.selectedDayIndex === dayColItem.index ? 1.0 : 0.85
                                        }
                                    }

                                    // Hover inspection area
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: popout.selectedDayIndex = dayColItem.index
                                        onExited: {
                                            if (popout.selectedDayIndex === dayColItem.index) {
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
                                id: dayLabelItem
                                required property int index
                                required property var modelData

                                width: parent.width / 7
                                height: parent.height

                                StyledText {
                                    text: dayLabelItem.modelData?.dayLabel || ""
                                    anchors.centerIn: parent
                                    font.pixelSize: 9
                                    font.bold: (dayLabelItem.modelData?.isToday || false) || popout.selectedDayIndex === dayLabelItem.index
                                    color: popout.selectedDayIndex === dayLabelItem.index ? Theme.primary : ((dayLabelItem.modelData?.isToday || false) ? Theme.surfaceText : Theme.surfaceVariantText)
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
                                            id: presetChip
                                            required property int index
                                            required property var modelData

                                            width: presetText.implicitWidth + Theme.spacingS * 2
                                            height: 28
                                            radius: 4
                                            color: root.dataPlanQuotaMB === presetChip.modelData.val ? Theme.primary : (presetMouse.containsMouse ? Theme.surfaceTextHover : Theme.surfaceContainerHigh)
                                            border.width: 1
                                            border.color: root.dataPlanQuotaMB === presetChip.modelData.val ? Theme.primary : Theme.outlineLight

                                            StyledText {
                                                id: presetText
                                                anchors.centerIn: parent
                                                text: presetChip.modelData.label
                                                font.pixelSize: 10
                                                font.bold: true
                                                color: root.dataPlanQuotaMB === presetChip.modelData.val ? Theme.onPrimary : Theme.surfaceText
                                            }

                                            MouseArea {
                                                id: presetMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    root.dataPlanQuotaMB = presetChip.modelData.val;
                                                    quotaInput.text = String(presetChip.modelData.val);
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

                                StyledText {
                                    visible: !root.dataPlanRules || root.dataPlanRules.length === 0
                                    text: I18n.tr("No alert rules configured. Add one below.")
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.italic: true
                                    color: Theme.surfaceVariantText
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    topPadding: Theme.spacingXS
                                    bottomPadding: Theme.spacingXS
                                }

                                Repeater {
                                    id: rulesRepeater
                                    model: ScriptModel {
                                        values: root.dataPlanRules
                                    }

                                    delegate: Rectangle {
                                        id: ruleItemRect
                                        required property int index
                                        required property var modelData

                                        width: parent.width
                                        height: 34
                                        radius: 6
                                        color: Theme.surfaceContainerHigh
                                        border.width: 1
                                        border.color: Theme.outlineLight

                                        readonly property bool isFired: (root.firedRuleIds || []).indexOf(ruleItemRect.modelData?.id) !== -1

                                        // Threshold badge (anchored left)
                                        Rectangle {
                                            id: badgeRect
                                            anchors.left: parent.left
                                            anchors.leftMargin: Theme.spacingS
                                            anchors.verticalCenter: parent.verticalCenter
                                            height: 22
                                            width: badgeText.implicitWidth + 12
                                            radius: 4
                                            color: Theme.withAlpha(Theme.primary, 0.18)

                                            StyledText {
                                                id: badgeText
                                                anchors.centerIn: parent
                                                text: ruleItemRect.modelData?.threshold || ""
                                                font.pixelSize: 11
                                                font.bold: true
                                                color: Theme.primary
                                            }
                                        }

                                        // Status check if fired
                                        DankIcon {
                                            id: firedIcon
                                            visible: ruleItemRect.isFired
                                            anchors.left: badgeRect.right
                                            anchors.leftMargin: visible ? Theme.spacingXS : 0
                                            anchors.verticalCenter: parent.verticalCenter
                                            name: "check_circle"
                                            size: 14
                                            color: Theme.success
                                            width: visible ? 14 : 0
                                        }

                                        // Delete Rule Button (anchored right)
                                        Rectangle {
                                            id: deleteBtn
                                            anchors.right: parent.right
                                            anchors.rightMargin: Theme.spacingS
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: 26
                                            height: 26
                                            radius: 13
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
                                                onClicked: root.deleteRule(ruleItemRect.index, ruleItemRect.modelData?.id)
                                            }
                                        }

                                        // Command / Action description (anchored in between)
                                        StyledText {
                                            anchors.left: firedIcon.visible ? firedIcon.right : badgeRect.right
                                            anchors.leftMargin: Theme.spacingS
                                            anchors.right: deleteBtn.left
                                            anchors.rightMargin: Theme.spacingS
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: (ruleItemRect.modelData?.command && ruleItemRect.modelData.command.trim().length > 0) ? ruleItemRect.modelData.command : I18n.tr("Notification only")
                                            font.pixelSize: Theme.fontSizeSmall
                                            font.italic: !(ruleItemRect.modelData?.command && ruleItemRect.modelData.command.trim().length > 0)
                                            color: (ruleItemRect.modelData?.command && ruleItemRect.modelData.command.trim().length > 0) ? Theme.surfaceText : Theme.surfaceVariantText
                                            elide: Text.ElideMiddle
                                        }
                                    }
                                }
                            }

                            // Add New Rule input row
                            Rectangle {
                                id: addRuleBox
                                width: parent.width
                                implicitHeight: addRuleCol.implicitHeight + Theme.spacingS * 2
                                radius: 6
                                color: Theme.withAlpha(Theme.primary, 0.04)
                                border.width: 1
                                border.color: Theme.withAlpha(Theme.primary, 0.25)

                                function submitNewRule() {
                                    if (root.addRule(newThresholdInput.text, newCmdInput.text)) {
                                        newThresholdInput.text = "";
                                        newCmdInput.text = "";
                                    }
                                }

                                Column {
                                    id: addRuleCol
                                    anchors.centerIn: parent
                                    width: parent.width - Theme.spacingS * 2
                                    spacing: Theme.spacingS

                                    Item {
                                        width: parent.width
                                        height: 34

                                        DankTextField {
                                            id: newThresholdInput
                                            anchors.left: parent.left
                                            anchors.top: parent.top
                                            anchors.bottom: parent.bottom
                                            width: 110
                                            placeholderText: I18n.tr("80% or 1.5GB")
                                            onAccepted: addRuleBox.submitNewRule()
                                        }

                                        DankTextField {
                                            id: newCmdInput
                                            anchors.left: newThresholdInput.right
                                            anchors.leftMargin: Theme.spacingS
                                            anchors.right: addBtn.left
                                            anchors.rightMargin: Theme.spacingS
                                            anchors.top: parent.top
                                            anchors.bottom: parent.bottom
                                            placeholderText: I18n.tr("Command (optional)")
                                            onAccepted: addRuleBox.submitNewRule()
                                        }

                                        Rectangle {
                                            id: addBtn
                                            anchors.right: parent.right
                                            anchors.top: parent.top
                                            anchors.bottom: parent.bottom
                                            width: 70
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
                                                onClicked: addRuleBox.submitNewRule()
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
