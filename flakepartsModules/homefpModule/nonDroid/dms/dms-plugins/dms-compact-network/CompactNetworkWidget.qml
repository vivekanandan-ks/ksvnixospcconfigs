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
        if (netDevProc) netDevProc.running = true;
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

    // --- Live Speed History & Extremes ---
    property var history5mRx: []
    property var history5mTx: []
    property var history30mRx: []
    property var history30mTx: []
    property real sessionPeakRx: 0
    property real sessionPeakTx: 0
    property real sessionMinRx: 0
    property real sessionMinTx: 0
    property real sessionTotalRxBytes: 0
    property real sessionTotalTxBytes: 0
    property int sessionSampleCount: 0
    readonly property real sessionAvgRx: sessionSampleCount > 0 ? (sessionTotalRxBytes / sessionSampleCount) : 0
    readonly property real sessionAvgTx: sessionSampleCount > 0 ? (sessionTotalTxBytes / sessionSampleCount) : 0
    property int sampleCounter10s: 0

    // --- Discovered Network Devices & Multi-Filter State ---
    property var discoveredInterfaces: []
    property var prevInterfaceBytes: ({})
    property var interfaceHistory5m: ({})
    property var interfaceHistory30m: ({})
    property var selectedInterfaceFilter: [] // Array of dev strings. Empty = All Networks (Physical Total)

    property real activeRxRate: 0
    property real activeTxRate: 0
    property real totalPhysicalRxRate: 0
    property real totalPhysicalTxRate: 0

    readonly property real displayRxRate: (root.activeRxRate > 0 || root.activeTxRate > 0 || root.selectedInterfaceFilter.length > 0) ? root.activeRxRate : (DgopService.networkRxRate || 0)
    readonly property real displayTxRate: (root.activeRxRate > 0 || root.activeTxRate > 0 || root.selectedInterfaceFilter.length > 0) ? root.activeTxRate : (DgopService.networkTxRate || 0)

    function getInterfaceIcon(dev) {
        if (!dev) return "public";
        const d = dev.toLowerCase();
        if (d.startsWith("wl")) return "wifi";
        if (d.startsWith("en") || d.startsWith("eth")) return "lan";
        if (d.startsWith("wt")) return "hub";
        if (d.startsWith("fips")) return "verified_user";
        if (d.startsWith("wg")) return "security";
        if (d.includes("tor") || d.includes("onion")) return "vpn_lock";
        if (d.startsWith("tailscale")) return "vpn_lock";
        if (d.startsWith("ygg")) return "device_hub";
        if (d.startsWith("podman") || d.startsWith("cni-podman") || d.startsWith("pasta")) return "inventory_2";
        if (d.startsWith("docker") || (d.startsWith("br-") && d.length === 15)) return "dns";
        if (d.startsWith("veth")) return "device_hub";
        if (d.startsWith("tun") || d.startsWith("tap") || d.startsWith("ppp")) return "shield";
        return "settings_ethernet";
    }

    function getFilterButtonLabel() {
        if (root.selectedInterfaceFilter.length === 0) {
            return I18n.tr("All Networks");
        }
        if (root.selectedInterfaceFilter.length === 1) {
            const dev = root.selectedInterfaceFilter[0];
            for (let i = 0; i < root.discoveredInterfaces.length; i++) {
                if (root.discoveredInterfaces[i].dev === dev) {
                    return `${root.discoveredInterfaces[i].name} (${dev})`;
                }
            }
            return dev;
        }
        if (root.selectedInterfaceFilter.length === 2) {
            return root.selectedInterfaceFilter.join(" + ");
        }
        return `${root.selectedInterfaceFilter[0]} + ${root.selectedInterfaceFilter[1]} + ${root.selectedInterfaceFilter.length - 2}`;
    }

    function toggleInterfaceFilter(dev) {
        let list = [...root.selectedInterfaceFilter];
        const idx = list.indexOf(dev);
        if (idx >= 0) {
            list.splice(idx, 1);
        } else {
            list.push(dev);
        }
        root.selectedInterfaceFilter = list;
        root.rebuildActiveHistory();
    }

    function clearInterfaceFilter() {
        root.selectedInterfaceFilter = [];
        root.rebuildActiveHistory();
    }

    function rebuildActiveHistory() {
        const isFilterEmpty = root.selectedInterfaceFilter.length === 0;
        let targetDevs = [];
        if (isFilterEmpty) {
            for (let i = 0; i < root.discoveredInterfaces.length; i++) {
                if (root.discoveredInterfaces[i].isPhysical) {
                    targetDevs.push(root.discoveredInterfaces[i].dev);
                }
            }
        } else {
            targetDevs = root.selectedInterfaceFilter;
        }

        // Rebuild 5m buffer
        let max5mLen = 0;
        for (let d of targetDevs) {
            const h = root.interfaceHistory5m[d];
            if (h && h.rx.length > max5mLen) max5mLen = h.rx.length;
        }
        let new5mRx = [];
        let new5mTx = [];
        for (let idx = 0; idx < max5mLen; idx++) {
            let rSum = 0;
            let tSum = 0;
            for (let d of targetDevs) {
                const h = root.interfaceHistory5m[d];
                if (h && h.rx.length > idx) {
                    rSum += (h.rx[idx] || 0);
                    tSum += (h.tx[idx] || 0);
                }
            }
            new5mRx.push(rSum);
            new5mTx.push(tSum);
        }
        root.history5mRx = new5mRx;
        root.history5mTx = new5mTx;

        // Rebuild 30m buffer (180 data points @ 10s)
        let max30mLen = 0;
        for (let d of targetDevs) {
            const h = root.interfaceHistory30m[d];
            if (h && h.rx.length > max30mLen) max30mLen = h.rx.length;
        }
        let new30mRx = [];
        let new30mTx = [];
        for (let idx = 0; idx < max30mLen; idx++) {
            let rSum = 0;
            let tSum = 0;
            for (let d of targetDevs) {
                const h = root.interfaceHistory30m[d];
                if (h && h.rx.length > idx) {
                    rSum += (h.rx[idx] || 0);
                    tSum += (h.tx[idx] || 0);
                }
            }
            new30mRx.push(rSum);
            new30mTx.push(tSum);
        }
        root.history30mRx = new30mRx;
        root.history30mTx = new30mTx;

        // Recalculate extremes
        root.sessionPeakRx = 0;
        root.sessionPeakTx = 0;
        root.sessionMinRx = 0;
        root.sessionMinTx = 0;
        root.sessionTotalRxBytes = 0;
        root.sessionTotalTxBytes = 0;
        root.sessionSampleCount = 0;

        for (let i = 0; i < new5mRx.length; i++) {
            const rxVal = new5mRx[i];
            const txVal = new5mTx[i] || 0;
            if (rxVal > root.sessionPeakRx) root.sessionPeakRx = rxVal;
            if (txVal > root.sessionPeakTx) root.sessionPeakTx = txVal;
            if (rxVal > 0 && (root.sessionMinRx === 0 || rxVal < root.sessionMinRx)) root.sessionMinRx = rxVal;
            if (txVal > 0 && (root.sessionMinTx === 0 || txVal < root.sessionMinTx)) root.sessionMinTx = txVal;
            root.sessionTotalRxBytes += rxVal;
            root.sessionTotalTxBytes += txVal;
            root.sessionSampleCount++;
        }

        // Current rates
        let curRx = 0;
        let curTx = 0;
        for (let iface of root.discoveredInterfaces) {
            if (targetDevs.includes(iface.dev)) {
                curRx += (iface.rxRate || 0);
                curTx += (iface.txRate || 0);
            }
        }
        root.activeRxRate = curRx;
        root.activeTxRate = curTx;
    }

    function parseNetDevOutput(text) {
        if (!text || !text.trim()) return;
        const now = Date.now();
        const lines = text.trim().split("\n");
        const list = [];
        let physRxRate = 0;
        let physTxRate = 0;
        let selRxRate = 0;
        let selTxRate = 0;
        const isFilterEmpty = root.selectedInterfaceFilter.length === 0;

        for (let i = 2; i < lines.length; i++) {
            const line = lines[i];
            const colonIdx = line.indexOf(":");
            if (colonIdx === -1) continue;
            const dev = line.substring(0, colonIdx).trim();
            if (dev === "lo") continue; // Exclude loopback

            const rest = line.substring(colonIdx + 1).trim();
            const stats = rest.split(/\s+/);
            if (stats.length < 9) continue;
            const rx = parseInt(stats[0], 10) || 0;
            const tx = parseInt(stats[8], 10) || 0;

            let rxRate = 0;
            let txRate = 0;
            const prev = root.prevInterfaceBytes[dev];
            if (prev) {
                const dt = Math.max(0.5, (now - prev.time) / 1000);
                rxRate = Math.max(0, (rx - prev.rx) / dt);
                txRate = Math.max(0, (tx - prev.tx) / dt);
            }
            root.prevInterfaceBytes[dev] = { rx: rx, tx: tx, time: now };

            const isPhysical = dev.startsWith("wl") || dev.startsWith("en") || dev.startsWith("eth");
            let icon = "settings_ethernet";
            let friendlyName = dev;
            let subType = isPhysical ? "Physical Carrier" : "Virtual Interface";
            const d = dev.toLowerCase();
            if (d.startsWith("wl")) { icon = "wifi"; friendlyName = "Wi-Fi"; subType = "Wireless 802.11"; }
            else if (d.startsWith("en") || d.startsWith("eth")) { icon = "lan"; friendlyName = "Ethernet"; subType = "Wired LAN"; }
            else if (d.startsWith("wt")) { icon = "hub"; friendlyName = "NetBird"; subType = "P2P WireGuard Mesh"; }
            else if (d.startsWith("fips")) { icon = "verified_user"; friendlyName = "FIPS Mesh"; subType = "FIPS 140-2 Crypto"; }
            else if (d.startsWith("wg")) { icon = "security"; friendlyName = `WireGuard (${dev})`; subType = "Kernel Crypto Tunnel"; }
            else if (d.includes("tor") || d.includes("onion")) { icon = "vpn_lock"; friendlyName = "Tor"; subType = "Onion Proxy Circuit"; }
            else if (d.startsWith("tailscale")) { icon = "vpn_lock"; friendlyName = "Tailscale"; subType = "Tailscale Mesh"; }
            else if (d.startsWith("ygg")) { icon = "device_hub"; friendlyName = "Yggdrasil"; subType = "IPv6 Encrypted Mesh"; }
            else if (d.startsWith("podman") || d.startsWith("cni-podman") || d.startsWith("pasta")) { icon = "inventory_2"; friendlyName = `Podman (${dev})`; subType = "Podman Container Network"; }
            else if (d.startsWith("docker") || (d.startsWith("br-") && d.length === 15)) { icon = "dns"; friendlyName = `Docker (${dev})`; subType = "Docker Bridge Network"; }
            else if (d.startsWith("veth")) { icon = "device_hub"; friendlyName = `veth (${dev})`; subType = "Container Veth Pair"; }
            else if (d.startsWith("tun") || d.startsWith("tap") || d.startsWith("ppp")) { icon = "shield"; friendlyName = `VPN (${dev})`; subType = "Encrypted Tunnel"; }

            list.push({
                dev: dev,
                name: friendlyName,
                subType: subType,
                icon: icon,
                isPhysical: isPhysical,
                rx: rx,
                tx: tx,
                rxRate: rxRate,
                txRate: txRate
            });

            // Store per-device 5m rolling history
            if (!root.interfaceHistory5m[dev]) root.interfaceHistory5m[dev] = { rx: [], tx: [] };
            let h5 = root.interfaceHistory5m[dev];
            h5.rx.push(rxRate);
            if (h5.rx.length > 300) h5.rx.shift();
            h5.tx.push(txRate);
            if (h5.tx.length > 300) h5.tx.shift();

            // Store per-device 30m rolling history (180 points @ 10s)
            if (!root.interfaceHistory30m[dev]) root.interfaceHistory30m[dev] = { rx: [], tx: [] };
            if (root.sampleCounter10s >= 10 || root.interfaceHistory30m[dev].rx.length === 0) {
                let h30 = root.interfaceHistory30m[dev];
                h30.rx.push(rxRate);
                if (h30.rx.length > 180) h30.rx.shift();
                h30.tx.push(txRate);
                if (h30.tx.length > 180) h30.tx.shift();
            }

            if (isPhysical) {
                physRxRate += rxRate;
                physTxRate += txRate;
            }

            if (!isFilterEmpty && root.selectedInterfaceFilter.includes(dev)) {
                selRxRate += rxRate;
                selTxRate += txRate;
            }
        }

        root.totalPhysicalRxRate = physRxRate;
        root.totalPhysicalTxRate = physTxRate;
        root.discoveredInterfaces = list;

        // Determine active rate
        const rx = isFilterEmpty ? physRxRate : selRxRate;
        const tx = isFilterEmpty ? physTxRate : selTxRate;
        root.activeRxRate = rx;
        root.activeTxRate = tx;

        // Active 5-minute rolling buffer
        let h5Rx = [...root.history5mRx, rx];
        if (h5Rx.length > 300) h5Rx.shift();
        root.history5mRx = h5Rx;

        let h5Tx = [...root.history5mTx, tx];
        if (h5Tx.length > 300) h5Tx.shift();
        root.history5mTx = h5Tx;

        // Extremes tracking for active stream
        if (rx > root.sessionPeakRx) root.sessionPeakRx = rx;
        if (tx > root.sessionPeakTx) root.sessionPeakTx = tx;
        if (rx > 0 && (root.sessionMinRx === 0 || rx < root.sessionMinRx)) root.sessionMinRx = rx;
        if (tx > 0 && (root.sessionMinTx === 0 || tx < root.sessionMinTx)) root.sessionMinTx = tx;

        root.sessionTotalRxBytes += rx;
        root.sessionTotalTxBytes += tx;
        root.sessionSampleCount++;

        // 30-minute rolling buffer (180 data points @ 10s)
        root.sampleCounter10s++;
        if (root.sampleCounter10s >= 10 || root.history30mRx.length === 0) {
            root.sampleCounter10s = 0;
            let h30Rx = [...root.history30mRx, rx];
            if (h30Rx.length > 180) h30Rx.shift();
            root.history30mRx = h30Rx;

            let h30Tx = [...root.history30mTx, tx];
            if (h30Tx.length > 180) h30Tx.shift();
            root.history30mTx = h30Tx;
        }
    }

    Timer {
        id: liveSampleTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            if (netDevProc && !netDevProc.running) {
                netDevProc.running = true;
            } else if (!netDevProc) {
                const rx = DgopService.networkRxRate || 0;
                const tx = DgopService.networkTxRate || 0;
                let h5Rx = [...root.history5mRx, rx];
                if (h5Rx.length > 300) h5Rx.shift();
                root.history5mRx = h5Rx;

                let h5Tx = [...root.history5mTx, tx];
                if (h5Tx.length > 300) h5Tx.shift();
                root.history5mTx = h5Tx;

                if (rx > root.sessionPeakRx) root.sessionPeakRx = rx;
                if (tx > root.sessionPeakTx) root.sessionPeakTx = tx;
                if (rx > 0 && (root.sessionMinRx === 0 || rx < root.sessionMinRx)) root.sessionMinRx = rx;
                if (tx > 0 && (root.sessionMinTx === 0 || tx < root.sessionMinTx)) root.sessionMinTx = tx;

                root.sessionTotalRxBytes += rx;
                root.sessionTotalTxBytes += tx;
                root.sessionSampleCount++;

                root.sampleCounter10s++;
                if (root.sampleCounter10s >= 10 || root.history30mRx.length === 0) {
                    root.sampleCounter10s = 0;
                    let h30Rx = [...root.history30mRx, rx];
                    if (h30Rx.length > 180) h30Rx.shift();
                    root.history30mRx = h30Rx;

                    let h30Tx = [...root.history30mTx, tx];
                    if (h30Tx.length > 180) h30Tx.shift();
                    root.history30mTx = h30Tx;
                }
            }
        }
    }

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

    Process {
        id: netDevProc
        command: ["cat", "/proc/net/dev"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                if (text && text.trim()) {
                    root.parseNetDevOutput(text);
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
    popoutWidth: 500
    popoutHeight: 650

    popoutContent: Component {
        PopoutComponent {
            id: popout

            headerText: I18n.tr("Network Statistics")
            detailsText: {
                if (popout.activeTab === 0) {
                    if (root.selectedInterfaceFilter.length > 0) {
                        return `${I18n.tr("Filtered")}: ${root.getFilterButtonLabel()}`;
                    }
                    return I18n.tr("Real-time Throughput & Session Extremes");
                }
                if (popout.activeTab === 1) return I18n.tr("Uptime / Today / 7-Day Traffic");
                return I18n.tr("Daily Limits & Notification Rules");
            }
            showCloseButton: true

            property int activeTab: 0
            property int liveGraphRange: 0 // 0 = 5m, 1 = 30m
            property string expandedInterface: "" // Expanded interface in live list
            property int hoveredPointIndex: -1
            property real hoverX: 0
            property int selectedDayIndex: -1
            property var daysData: root.getSevenDaysList()
            property bool ifaceMenuOpen: false

            Column {
                width: parent.width
                spacing: Theme.spacingM

                // --- Tab Selection Bar ---
                Rectangle {
                    width: parent.width
                    height: 34
                    radius: Theme.cornerRadius
                    color: Theme.nestedSurface
                    border.width: 1
                    border.color: Theme.outlineLight

                    Row {
                        anchors.centerIn: parent
                        spacing: 4

                        Repeater {
                            model: [
                                { id: 0, label: I18n.tr("Live Speed"), icon: "speed" },
                                { id: 1, label: I18n.tr("7-Day Usage"), icon: "bar_chart" },
                                { id: 2, label: I18n.tr("Data Quota"), icon: "data_usage" }
                            ]

                            Rectangle {
                                id: tabBtn
                                required property int index
                                required property var modelData

                                width: (popout.width - Theme.spacingM * 2 - 16) / 3
                                height: 26
                                radius: Math.max(2, Theme.cornerRadius - 2)
                                color: popout.activeTab === tabBtn.modelData.id ? Theme.primary : (tabMouse.containsMouse ? Theme.surfaceTextHover : "transparent")

                                Behavior on color {
                                    ColorAnimation { duration: Theme.shortDuration }
                                }

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    DankIcon {
                                        name: tabBtn.modelData.icon
                                        size: 13
                                        color: popout.activeTab === tabBtn.modelData.id ? Theme.onPrimary : Theme.surfaceText
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    StyledText {
                                        text: tabBtn.modelData.label
                                        font.pixelSize: 11
                                        font.bold: popout.activeTab === tabBtn.modelData.id
                                        color: popout.activeTab === tabBtn.modelData.id ? Theme.onPrimary : Theme.surfaceText
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                MouseArea {
                                    id: tabMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: popout.activeTab = tabBtn.modelData.id
                                }
                            }
                        }
                    }
                }

                // ==========================================
                // === TAB 0: LIVE SPEED & GRAPH VIEW ===
                // ==========================================
                Column {
                    id: liveTabCol
                    visible: popout.activeTab === 0
                    width: parent.width
                    spacing: Theme.spacingM

                    // --- Live Rate Banner Card ---
                    Rectangle {
                        width: parent.width
                        height: 48
                        radius: Theme.cornerRadius
                        color: Theme.nestedSurface
                        border.width: 1
                        border.color: Theme.outlineLight

                        Row {
                            anchors.centerIn: parent
                            spacing: Theme.spacingL

                            Row {
                                spacing: 6
                                anchors.verticalCenter: parent.verticalCenter
                                StyledText {
                                    text: "↓"
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: Theme.info
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Column {
                                    spacing: 0
                                    anchors.verticalCenter: parent.verticalCenter
                                    StyledText {
                                        text: root.selectedInterfaceFilter.length > 0 ? (root.getFilterButtonLabel() + " ↓") : I18n.tr("Download Rate")
                                        font.pixelSize: 9
                                        color: Theme.surfaceVariantText
                                    }
                                    NumericText {
                                        isMonospace: true
                                        text: root.formatSpeed(root.displayRxRate) + "/s"
                                        font.pixelSize: 13
                                        font.bold: true
                                        color: Theme.surfaceText
                                    }
                                }
                            }

                            Rectangle {
                                width: 1
                                height: 26
                                color: Theme.outlineLight
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Row {
                                spacing: 6
                                anchors.verticalCenter: parent.verticalCenter
                                StyledText {
                                    text: "↑"
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: Theme.error
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Column {
                                    spacing: 0
                                    anchors.verticalCenter: parent.verticalCenter
                                    StyledText {
                                        text: root.selectedInterfaceFilter.length > 0 ? (root.getFilterButtonLabel() + " ↑") : I18n.tr("Upload Rate")
                                        font.pixelSize: 9
                                        color: Theme.surfaceVariantText
                                    }
                                    NumericText {
                                        isMonospace: true
                                        text: root.formatSpeed(root.displayTxRate) + "/s"
                                        font.pixelSize: 13
                                        font.bold: true
                                        color: Theme.surfaceText
                                    }
                                }
                            }
                        }
                    }

                    // --- Live Speed Graph Card (5m / 1h) ---
                    Rectangle {
                        id: speedGraphCard
                        width: parent.width
                        implicitHeight: 180 + ifaceFilterDrawer.implicitHeight + (popout.ifaceMenuOpen ? 6 : 0)
                        height: implicitHeight
                        radius: Theme.cornerRadius
                        color: Theme.nestedSurface
                        border.width: 1
                        border.color: Theme.outlineLight
                        clip: true

                        Behavior on implicitHeight {
                            NumberAnimation {
                                duration: Theme.shortDuration
                                easing.type: Theme.standardEasing
                            }
                        }

                        // Graph Card Header: Title + Resolution Toggle
                        Item {
                            id: graphHeader
                            anchors.top: parent.top
                            anchors.topMargin: Theme.spacingS
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingM
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.spacingM
                            height: 22

                            StyledText {
                                anchors.left: parent.left
                                anchors.right: headerControlsRow.left
                                anchors.rightMargin: 6
                                anchors.verticalCenter: parent.verticalCenter
                                elide: Text.ElideRight
                                text: {
                                    if (popout.hoveredPointIndex >= 0) {
                                        const rxList = popout.liveGraphRange === 0 ? root.history5mRx : root.history30mRx;
                                        const txList = popout.liveGraphRange === 0 ? root.history5mTx : root.history30mTx;
                                        const rx = rxList[popout.hoveredPointIndex] || 0;
                                        const tx = txList[popout.hoveredPointIndex] || 0;
                                        const secsAgo = popout.liveGraphRange === 0
                                            ? `${rxList.length - 1 - popout.hoveredPointIndex}s ago`
                                            : `${Math.round((rxList.length - 1 - popout.hoveredPointIndex) * 10 / 60)}m ago`;
                                        return `${secsAgo}:  ↓ ${root.formatSpeed(rx)}/s   ↑ ${root.formatSpeed(tx)}/s`;
                                    }
                                    return popout.liveGraphRange === 0 ? I18n.tr("Speed Trend (Last 5 Minutes)") : I18n.tr("Speed Trend (Last 30 Minutes)");
                                }
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: popout.hoveredPointIndex >= 0
                                color: popout.hoveredPointIndex >= 0 ? Theme.primary : Theme.surfaceText
                            }

                            // Controls Row: Dropdown Button + Resolution Toggle
                            Row {
                                id: headerControlsRow
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 5

                                // Interface Filter Dropdown Button
                                Rectangle {
                                    id: ifaceDropdownBtn
                                    width: ifaceBtnRow.implicitWidth + 12
                                    height: 20
                                    radius: 4
                                    color: popout.ifaceMenuOpen ? Theme.primary : (ifaceBtnMouse.containsMouse ? Theme.surfaceTextHover : Theme.surfaceContainerHigh)
                                    border.width: 1
                                    border.color: popout.ifaceMenuOpen ? Theme.primary : Theme.outlineLight

                                    Row {
                                        id: ifaceBtnRow
                                        anchors.centerIn: parent
                                        spacing: 3

                                        DankIcon {
                                            name: root.selectedInterfaceFilter.length === 0 ? "public" : (root.selectedInterfaceFilter.length === 1 ? root.getInterfaceIcon(root.selectedInterfaceFilter[0]) : "tune")
                                            size: 11
                                            color: popout.ifaceMenuOpen ? Theme.onPrimary : Theme.surfaceText
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        StyledText {
                                            text: root.getFilterButtonLabel()
                                            font.pixelSize: 9
                                            font.bold: true
                                            color: popout.ifaceMenuOpen ? Theme.onPrimary : Theme.surfaceText
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        DankIcon {
                                            name: popout.ifaceMenuOpen ? "arrow_drop_up" : "arrow_drop_down"
                                            size: 13
                                            color: popout.ifaceMenuOpen ? Theme.onPrimary : Theme.surfaceText
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    MouseArea {
                                        id: ifaceBtnMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: popout.ifaceMenuOpen = !popout.ifaceMenuOpen
                                    }
                                }

                                // 5m / 30m Resolution Toggle Chips
                                Row {
                                    spacing: 2
                                    anchors.verticalCenter: parent.verticalCenter

                                    Rectangle {
                                        width: 32
                                        height: 20
                                        radius: 4
                                        color: popout.liveGraphRange === 0 ? Theme.primary : (range5Mouse.containsMouse ? Theme.surfaceTextHover : Theme.surfaceContainerHigh)
                                        border.width: 1
                                        border.color: popout.liveGraphRange === 0 ? Theme.primary : Theme.outlineLight

                                        StyledText {
                                            anchors.centerIn: parent
                                            text: "5m"
                                            font.pixelSize: 10
                                            font.bold: true
                                            color: popout.liveGraphRange === 0 ? Theme.onPrimary : Theme.surfaceText
                                        }

                                        MouseArea {
                                            id: range5Mouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: popout.liveGraphRange = 0
                                        }
                                    }

                                    Rectangle {
                                        width: 32
                                        height: 20
                                        radius: 4
                                        color: popout.liveGraphRange === 1 ? Theme.primary : (range30mMouse.containsMouse ? Theme.surfaceTextHover : Theme.surfaceContainerHigh)
                                        border.width: 1
                                        border.color: popout.liveGraphRange === 1 ? Theme.primary : Theme.outlineLight

                                        StyledText {
                                            anchors.centerIn: parent
                                            text: "30m"
                                            font.pixelSize: 10
                                            font.bold: true
                                            color: popout.liveGraphRange === 1 ? Theme.onPrimary : Theme.surfaceText
                                        }

                                        MouseArea {
                                            id: range30mMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: popout.liveGraphRange = 1
                                        }
                                    }
                                }
                            }
                        }

                        // Collapsible Interface Filter Drawer
                        Rectangle {
                            id: ifaceFilterDrawer
                            anchors.top: graphHeader.bottom
                            anchors.topMargin: popout.ifaceMenuOpen ? 6 : 0
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingM
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.spacingM
                            implicitHeight: popout.ifaceMenuOpen ? Math.min(220, filterDrawerCol.implicitHeight + Theme.spacingS * 2) : 0
                            visible: implicitHeight > 0
                            clip: true
                            radius: 6
                            color: Theme.surfaceContainerLowest
                            border.width: popout.ifaceMenuOpen ? 1 : 0
                            border.color: Theme.outlineLight

                            Behavior on implicitHeight {
                                NumberAnimation {
                                    duration: Theme.shortDuration
                                    easing.type: Theme.standardEasing
                                }
                            }
                            Behavior on anchors.topMargin {
                                NumberAnimation {
                                    duration: Theme.shortDuration
                                    easing.type: Theme.standardEasing
                                }
                            }

                            Flickable {
                                id: drawerFlickable
                                anchors.fill: parent
                                anchors.margins: Theme.spacingS
                                contentHeight: filterDrawerCol.implicitHeight
                                clip: true
                                boundsBehavior: Flickable.StopAtBounds

                                Column {
                                    id: filterDrawerCol
                                    width: drawerFlickable.width
                                    spacing: 2

                                    // Drawer Title & Close Button
                                    Item {
                                        width: parent.width
                                        height: 18

                                        StyledText {
                                            anchors.left: parent.left
                                            anchors.leftMargin: 4
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: I18n.tr("Select Interface Filter")
                                            font.pixelSize: 9
                                            font.bold: true
                                            color: Theme.surfaceVariantText
                                        }

                                        Rectangle {
                                            anchors.right: parent.right
                                            anchors.rightMargin: 4
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: 16
                                            height: 16
                                            radius: 8
                                            color: closeDrawerMouse.containsMouse ? Theme.surfaceTextHover : "transparent"

                                            DankIcon {
                                                anchors.centerIn: parent
                                                name: "close"
                                                size: 11
                                                color: Theme.surfaceVariantText
                                            }

                                            MouseArea {
                                                id: closeDrawerMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: popout.ifaceMenuOpen = false
                                            }
                                        }
                                    }

                                    // "All Networks (Physical)" Option
                                    Rectangle {
                                        width: parent.width
                                        height: 26
                                        radius: 4
                                        color: allRowMouse.containsMouse ? Theme.surfaceTextHover : "transparent"

                                        Row {
                                            anchors.left: parent.left
                                            anchors.leftMargin: 4
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 6

                                            DankIcon {
                                                name: root.selectedInterfaceFilter.length === 0 ? "check_box" : "check_box_outline_blank"
                                                size: 14
                                                color: root.selectedInterfaceFilter.length === 0 ? Theme.primary : Theme.surfaceVariantText
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            DankIcon {
                                                name: "public"
                                                size: 13
                                                color: root.selectedInterfaceFilter.length === 0 ? Theme.primary : Theme.surfaceText
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            StyledText {
                                                text: I18n.tr("All Networks (Physical - Wi-Fi + Ethernet)")
                                                font.pixelSize: 10
                                                font.bold: root.selectedInterfaceFilter.length === 0
                                                color: root.selectedInterfaceFilter.length === 0 ? Theme.primary : Theme.surfaceText
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                        StyledText {
                                            anchors.right: parent.right
                                            anchors.rightMargin: 4
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: root.formatSpeed(root.totalPhysicalRxRate) + "/s"
                                            font.pixelSize: 9
                                            isMonospace: true
                                            color: Theme.surfaceVariantText
                                        }

                                        MouseArea {
                                            id: allRowMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.clearInterfaceFilter()
                                        }
                                    }

                                    // Physical Hardware Divider & Header
                                    Rectangle {
                                        width: parent.width
                                        height: 1
                                        color: Theme.outlineLight
                                        opacity: 0.4
                                    }

                                    StyledText {
                                        text: I18n.tr("PHYSICAL HARDWARE")
                                        font.pixelSize: 8
                                        font.bold: true
                                        color: Theme.surfaceVariantText
                                        leftPadding: 4
                                        topPadding: 2
                                        bottomPadding: 2
                                    }

                                    Repeater {
                                        model: root.discoveredInterfaces.filter(function(item) { return item.isPhysical; })

                                        Rectangle {
                                            id: physRow
                                            required property var modelData
                                            width: filterDrawerCol.width
                                            height: 26
                                            radius: 4
                                            color: physRowMouse.containsMouse ? Theme.surfaceTextHover : "transparent"

                                            readonly property bool isChecked: root.selectedInterfaceFilter.includes(physRow.modelData.dev)

                                            Row {
                                                anchors.left: parent.left
                                                anchors.leftMargin: 4
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 6

                                                DankIcon {
                                                    name: physRow.isChecked ? "check_box" : "check_box_outline_blank"
                                                    size: 14
                                                    color: physRow.isChecked ? Theme.primary : Theme.surfaceVariantText
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                DankIcon {
                                                    name: physRow.modelData.icon
                                                    size: 13
                                                    color: physRow.isChecked ? Theme.primary : Theme.surfaceText
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                StyledText {
                                                    text: `${physRow.modelData.name} (${physRow.modelData.dev})`
                                                    font.pixelSize: 10
                                                    font.bold: physRow.isChecked
                                                    color: physRow.isChecked ? Theme.primary : Theme.surfaceText
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }

                                            StyledText {
                                                anchors.right: parent.right
                                                anchors.rightMargin: 4
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: root.formatSpeed(physRow.modelData.rxRate) + "/s"
                                                font.pixelSize: 9
                                                isMonospace: true
                                                color: physRow.modelData.rxRate > 0 ? Theme.info : Theme.surfaceVariantText
                                            }

                                            MouseArea {
                                                id: physRowMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: root.toggleInterfaceFilter(physRow.modelData.dev)
                                            }
                                        }
                                    }

                                    // Overlays & Tunnels Divider & Header
                                    Rectangle {
                                        visible: root.discoveredInterfaces.some(function(item) { return !item.isPhysical; })
                                        width: parent.width
                                        height: 1
                                        color: Theme.outlineLight
                                        opacity: 0.4
                                    }

                                    StyledText {
                                        visible: root.discoveredInterfaces.some(function(item) { return !item.isPhysical; })
                                        text: I18n.tr("OVERLAYS & TUNNELS")
                                        font.pixelSize: 8
                                        font.bold: true
                                        color: Theme.surfaceVariantText
                                        leftPadding: 4
                                        topPadding: 2
                                        bottomPadding: 2
                                    }

                                    Repeater {
                                        model: root.discoveredInterfaces.filter(function(item) { return !item.isPhysical; })

                                        Rectangle {
                                            id: virtRow
                                            required property var modelData
                                            width: filterDrawerCol.width
                                            height: 26
                                            radius: 4
                                            color: virtRowMouse.containsMouse ? Theme.surfaceTextHover : "transparent"

                                            readonly property bool isChecked: root.selectedInterfaceFilter.includes(virtRow.modelData.dev)

                                            Row {
                                                anchors.left: parent.left
                                                anchors.leftMargin: 4
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 6

                                                DankIcon {
                                                    name: virtRow.isChecked ? "check_box" : "check_box_outline_blank"
                                                    size: 14
                                                    color: virtRow.isChecked ? Theme.primary : Theme.surfaceVariantText
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                DankIcon {
                                                    name: virtRow.modelData.icon
                                                    size: 13
                                                    color: virtRow.isChecked ? Theme.primary : Theme.surfaceText
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                StyledText {
                                                    text: `${virtRow.modelData.name} (${virtRow.modelData.dev})`
                                                    font.pixelSize: 10
                                                    font.bold: virtRow.isChecked
                                                    color: virtRow.isChecked ? Theme.primary : Theme.surfaceText
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }

                                            StyledText {
                                                anchors.right: parent.right
                                                anchors.rightMargin: 4
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: root.formatSpeed(virtRow.modelData.rxRate) + "/s"
                                                font.pixelSize: 9
                                                isMonospace: true
                                                color: virtRow.modelData.rxRate > 0 ? Theme.info : Theme.surfaceVariantText
                                            }

                                            MouseArea {
                                                id: virtRowMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: root.toggleInterfaceFilter(virtRow.modelData.dev)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Drawing Area
                        Item {
                            id: liveChartArea
                            anchors.top: ifaceFilterDrawer.bottom
                            anchors.topMargin: 6
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingM
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.spacingM
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: Theme.spacingS

                            readonly property var activeRxData: popout.liveGraphRange === 0 ? root.history5mRx : root.history30mRx
                            readonly property var activeTxData: popout.liveGraphRange === 0 ? root.history5mTx : root.history30mTx

                            readonly property real maxSpeed: {
                                let m = 50 * 1024;
                                for (let i = 0; i < activeRxData.length; i++) {
                                    if (activeRxData[i] > m) m = activeRxData[i];
                                }
                                for (let i = 0; i < activeTxData.length; i++) {
                                    if (activeTxData[i] > m) m = activeTxData[i];
                                }
                                return m * 1.15;
                            }

                            // Horizontal Grid Lines
                            Repeater {
                                model: [0.5, 1.0]
                                Item {
                                    id: liveGridLine
                                    required property int index
                                    required property real modelData

                                    width: liveChartArea.width
                                    y: liveChartArea.height * (1 - liveGridLine.modelData)

                                    Rectangle {
                                        width: parent.width
                                        height: 1
                                        color: Theme.outlineLight
                                        opacity: 0.35
                                    }

                                    StyledText {
                                        text: root.formatSpeed(liveChartArea.maxSpeed * liveGridLine.modelData) + "/s"
                                        font.pixelSize: 8
                                        color: Theme.surfaceVariantText
                                        opacity: 0.7
                                        anchors.right: parent.right
                                        anchors.bottom: parent.top
                                        anchors.bottomMargin: 1
                                    }
                                }
                            }

                            // Smooth Curves Canvas
                            Canvas {
                                id: speedCanvas
                                anchors.fill: parent
                                renderStrategy: Canvas.Cooperative

                                property var rx: liveChartArea.activeRxData
                                property var tx: liveChartArea.activeTxData
                                property real maxV: liveChartArea.maxSpeed

                                onRxChanged: requestPaint()
                                onTxChanged: requestPaint()
                                onWidthChanged: requestPaint()
                                onHeightChanged: requestPaint()

                                onPaint: {
                                    const ctx = getContext("2d");
                                    ctx.reset();
                                    ctx.clearRect(0, 0, width, height);

                                    if (!rx || rx.length < 2) return;

                                    const count = rx.length;
                                    const step = width / (count - 1);

                                    function drawLine(data, strokeColor, fillColor) {
                                        if (!data || data.length === 0) return;
                                        const pts = [];
                                        for (let i = 0; i < data.length; i++) {
                                            const x = i * step;
                                            const y = height - (Math.min(maxV, Math.max(0, data[i])) / maxV) * height;
                                            pts.push({ x: x, y: y });
                                        }

                                        // Area gradient fill
                                        const grad = ctx.createLinearGradient(0, 0, 0, height);
                                        grad.addColorStop(0, Theme.withAlpha(strokeColor, 0.22));
                                        grad.addColorStop(1, Theme.withAlpha(strokeColor, 0.01));
                                        ctx.fillStyle = grad;
                                        ctx.beginPath();
                                        ctx.moveTo(0, height);
                                        for (let i = 0; i < pts.length; i++) {
                                            ctx.lineTo(pts[i].x, pts[i].y);
                                        }
                                        ctx.lineTo(pts[pts.length - 1].x, height);
                                        ctx.closePath();
                                        ctx.fill();

                                        // Stroke curve
                                        ctx.strokeStyle = strokeColor;
                                        ctx.lineWidth = 1.8;
                                        ctx.beginPath();
                                        for (let i = 0; i < pts.length; i++) {
                                            if (i === 0) ctx.moveTo(pts[i].x, pts[i].y);
                                            else ctx.lineTo(pts[i].x, pts[i].y);
                                        }
                                        ctx.stroke();
                                    }

                                    // Draw Tx (Upload - Red/Orange)
                                    drawLine(tx, Theme.error, Theme.error);
                                    // Draw Rx (Download - Blue/Cyan)
                                    drawLine(rx, Theme.info, Theme.info);

                                    // Draw hover scrub cursor line if active
                                    if (popout.hoveredPointIndex >= 0 && popout.hoveredPointIndex < count) {
                                        const hx = popout.hoveredPointIndex * step;
                                        ctx.strokeStyle = Theme.primary;
                                        ctx.lineWidth = 1;
                                        ctx.setLineDash([3, 3]);
                                        ctx.beginPath();
                                        ctx.moveTo(hx, 0);
                                        ctx.lineTo(hx, height);
                                        ctx.stroke();
                                        ctx.setLineDash([]);

                                        // Cursor point indicators
                                        const hyRx = height - (Math.min(maxV, Math.max(0, rx[popout.hoveredPointIndex])) / maxV) * height;
                                        ctx.fillStyle = Theme.info;
                                        ctx.beginPath();
                                        ctx.arc(hx, hyRx, 3, 0, 2 * Math.PI);
                                        ctx.fill();

                                        const hyTx = height - (Math.min(maxV, Math.max(0, tx[popout.hoveredPointIndex])) / maxV) * height;
                                        ctx.fillStyle = Theme.error;
                                        ctx.beginPath();
                                        ctx.arc(hx, hyTx, 3, 0, 2 * Math.PI);
                                        ctx.fill();
                                    }
                                }
                            }

                            // Mouse scrub area
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onPositionChanged: mouse => {
                                    const data = liveChartArea.activeRxData;
                                    if (!data || data.length === 0) return;
                                    const idx = Math.round((mouse.x / width) * (data.length - 1));
                                    popout.hoveredPointIndex = Math.max(0, Math.min(data.length - 1, idx));
                                    popout.hoverX = mouse.x;
                                    speedCanvas.requestPaint();
                                }
                                onExited: {
                                    popout.hoveredPointIndex = -1;
                                    speedCanvas.requestPaint();
                                }
                            }
                        }
                    }

                    // --- Session Extremes Row (Peak / Average / Floor) ---
                    Row {
                        width: parent.width
                        spacing: Theme.spacingS

                        // Peak Card
                        Rectangle {
                            width: (parent.width - Theme.spacingS * 2) / 3
                            height: 62
                            radius: Theme.cornerRadius
                            color: Theme.nestedSurface
                            border.width: 1
                            border.color: Theme.outlineLight

                            Column {
                                anchors.centerIn: parent
                                spacing: 1
                                StyledText {
                                    text: I18n.tr("Session Peak")
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: Theme.primary
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                StyledText {
                                    text: "↓ " + root.formatSpeed(root.sessionPeakRx) + "/s"
                                    font.pixelSize: 10
                                    isMonospace: true
                                    color: Theme.info
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                StyledText {
                                    text: "↑ " + root.formatSpeed(root.sessionPeakTx) + "/s"
                                    font.pixelSize: 10
                                    isMonospace: true
                                    color: Theme.error
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }

                        // Average Card
                        Rectangle {
                            width: (parent.width - Theme.spacingS * 2) / 3
                            height: 62
                            radius: Theme.cornerRadius
                            color: Theme.nestedSurface
                            border.width: 1
                            border.color: Theme.outlineLight

                            Column {
                                anchors.centerIn: parent
                                spacing: 1
                                StyledText {
                                    text: I18n.tr("Session Average")
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: Theme.surfaceText
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                StyledText {
                                    text: "↓ " + root.formatSpeed(root.sessionAvgRx) + "/s"
                                    font.pixelSize: 10
                                    isMonospace: true
                                    color: Theme.info
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                StyledText {
                                    text: "↑ " + root.formatSpeed(root.sessionAvgTx) + "/s"
                                    font.pixelSize: 10
                                    isMonospace: true
                                    color: Theme.error
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }

                        // Floor Card
                        Rectangle {
                            width: (parent.width - Theme.spacingS * 2) / 3
                            height: 62
                            radius: Theme.cornerRadius
                            color: Theme.nestedSurface
                            border.width: 1
                            border.color: Theme.outlineLight

                            Column {
                                anchors.centerIn: parent
                                spacing: 1
                                StyledText {
                                    text: I18n.tr("Active Floor")
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: Theme.surfaceVariantText
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                StyledText {
                                    text: "↓ " + (root.sessionMinRx > 0 ? (root.formatSpeed(root.sessionMinRx) + "/s") : "0 B/s")
                                    font.pixelSize: 10
                                    isMonospace: true
                                    color: Theme.info
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                StyledText {
                                    text: "↑ " + (root.sessionMinTx > 0 ? (root.formatSpeed(root.sessionMinTx) + "/s") : "0 B/s")
                                    font.pixelSize: 10
                                    isMonospace: true
                                    color: Theme.error
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }

                    // --- Live Dynamic Interface Usage Card (Interactive & Expandable) ---
                    Rectangle {
                        width: parent.width
                        implicitHeight: ifaceCardCol.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Theme.nestedSurface
                        border.width: 1
                        border.color: Theme.outlineLight

                        Column {
                            id: ifaceCardCol
                            anchors.centerIn: parent
                            width: parent.width - Theme.spacingM * 2
                            spacing: Theme.spacingS

                            // Header: Title & Active Count Badge
                            Item {
                                width: parent.width
                                height: 20

                                Row {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 6

                                    DankIcon {
                                        name: "swap_calls"
                                        size: 14
                                        color: Theme.primary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    StyledText {
                                        text: I18n.tr("Live Interface Usage")
                                        font.pixelSize: Theme.fontSizeSmall
                                        font.bold: true
                                        color: Theme.surfaceText
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: activeCountText.implicitWidth + 10
                                    height: 18
                                    radius: 9
                                    color: Theme.withAlpha(Theme.primary, 0.15)

                                    readonly property int activeCount: {
                                        let c = 0;
                                        for (let i = 0; i < root.discoveredInterfaces.length; i++) {
                                            if (root.discoveredInterfaces[i].rxRate > 0 || root.discoveredInterfaces[i].txRate > 0) c++;
                                        }
                                        return c;
                                    }

                                    StyledText {
                                        id: activeCountText
                                        anchors.centerIn: parent
                                        text: `${parent.activeCount} active`
                                        font.pixelSize: 8
                                        font.bold: true
                                        color: Theme.primary
                                    }
                                }
                            }

                            // Divider
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: Theme.outlineLight
                                opacity: 0.35
                            }

                            // Scrollable list container for multiple interfaces (Docker, Podman, VPNs, Wi-Fi)
                            Flickable {
                                id: ifaceFlickable
                                width: parent.width
                                implicitHeight: Math.min(240, ifaceListCol.implicitHeight)
                                contentHeight: ifaceListCol.implicitHeight
                                clip: true
                                boundsBehavior: Flickable.StopAtBounds

                                Column {
                                    id: ifaceListCol
                                    width: ifaceFlickable.width
                                    spacing: Theme.spacingXS

                                    Repeater {
                                        model: {
                                            if (!root.discoveredInterfaces || root.discoveredInterfaces.length === 0) return [];
                                            let copy = [...root.discoveredInterfaces];
                                            copy.sort((a, b) => ((b.rxRate + b.txRate) - (a.rxRate + a.txRate)));
                                            return copy;
                                        }

                                        Rectangle {
                                            id: ifaceRowItem
                                            required property var modelData
                                            required property int index

                                            readonly property bool isSelected: root.selectedInterfaceFilter.includes(ifaceRowItem.modelData.dev)
                                            readonly property bool isExpanded: popout.expandedInterface === ifaceRowItem.modelData.dev
                                            readonly property bool isActiveRate: ifaceRowItem.modelData.rxRate > 0 || ifaceRowItem.modelData.txRate > 0

                                            width: ifaceListCol.width
                                            height: isExpanded ? 116 : 38
                                            radius: 6
                                            color: ifaceRowMouse.containsMouse ? Theme.surfaceTextHover : (isSelected ? Theme.surfaceContainerHighest : (isActiveRate ? Theme.surfaceContainerHigh : "transparent"))
                                            border.width: 1
                                            border.color: isSelected ? Theme.primary : (isActiveRate ? Theme.withAlpha(Theme.primary, 0.25) : Theme.withAlpha(Theme.outlineLight, 0.25))

                                            Behavior on height {
                                                NumberAnimation { duration: Theme.shortDuration; easing.type: Theme.standardEasing }
                                            }

                                            Column {
                                                anchors.fill: parent
                                                anchors.margins: Theme.spacingS
                                                spacing: 4

                                                // Main Row
                                                Row {
                                                    width: parent.width

                                                    // Left icon & labels
                                                    Row {
                                                        spacing: Theme.spacingS
                                                        anchors.verticalCenter: parent.verticalCenter

                                                        Rectangle {
                                                            width: 22
                                                            height: 22
                                                            radius: 11
                                                            color: ifaceRowItem.isSelected ? Theme.primary : (ifaceRowItem.isActiveRate ? Theme.withAlpha(Theme.primary, 0.18) : Theme.surfaceContainerLowest)

                                                            DankIcon {
                                                                anchors.centerIn: parent
                                                                name: ifaceRowItem.modelData.icon || "settings_ethernet"
                                                                size: 12
                                                                color: ifaceRowItem.isSelected ? Theme.onPrimary : (ifaceRowItem.isActiveRate ? Theme.primary : Theme.surfaceVariantText)
                                                            }
                                                        }

                                                        Column {
                                                            spacing: 0
                                                            anchors.verticalCenter: parent.verticalCenter

                                                            Row {
                                                                spacing: 4
                                                                StyledText {
                                                                    text: ifaceRowItem.modelData.name || ifaceRowItem.modelData.dev
                                                                    font.pixelSize: 11
                                                                    font.bold: true
                                                                    color: ifaceRowItem.isSelected ? Theme.primary : Theme.surfaceText
                                                                }
                                                                StyledText {
                                                                    text: `(${ifaceRowItem.modelData.dev})`
                                                                    font.pixelSize: 8
                                                                    isMonospace: true
                                                                    color: Theme.surfaceVariantText
                                                                    anchors.verticalCenter: parent.verticalCenter
                                                                }
                                                            }

                                                            StyledText {
                                                                text: ifaceRowItem.modelData.subType || "Interface"
                                                                font.pixelSize: 8
                                                                color: Theme.surfaceVariantText
                                                            }
                                                        }
                                                    }

                                                    // Right rates
                                                    Row {
                                                        anchors.right: parent.right
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        spacing: Theme.spacingS

                                                        Column {
                                                            spacing: 0
                                                            anchors.verticalCenter: parent.verticalCenter

                                                            Row {
                                                                spacing: 3
                                                                anchors.right: parent.right
                                                                StyledText { text: "↓"; font.pixelSize: 9; font.bold: true; color: Theme.info }
                                                                NumericText {
                                                                    isMonospace: true
                                                                    text: root.formatSpeed(ifaceRowItem.modelData.rxRate) + "/s"
                                                                    font.pixelSize: 10
                                                                    font.bold: ifaceRowItem.modelData.rxRate > 0
                                                                    color: ifaceRowItem.modelData.rxRate > 0 ? Theme.surfaceText : Theme.surfaceVariantText
                                                                }
                                                            }

                                                            Row {
                                                                spacing: 3
                                                                anchors.right: parent.right
                                                                StyledText { text: "↑"; font.pixelSize: 9; font.bold: true; color: Theme.error }
                                                                NumericText {
                                                                    isMonospace: true
                                                                    text: root.formatSpeed(ifaceRowItem.modelData.txRate) + "/s"
                                                                    font.pixelSize: 10
                                                                    font.bold: ifaceRowItem.modelData.txRate > 0
                                                                    color: ifaceRowItem.modelData.txRate > 0 ? Theme.surfaceText : Theme.surfaceVariantText
                                                                }
                                                            }
                                                        }
                                                    }
                                                }

                                                // Expanded details drawer (Live mini-graph & lifetime stats)
                                                Column {
                                                    visible: ifaceRowItem.isExpanded
                                                    width: parent.width
                                                    spacing: 3

                                                    Canvas {
                                                        id: ifaceSparkline
                                                        width: parent.width
                                                        height: 34
                                                        renderStrategy: Canvas.Cooperative
                                                        property var rxData: popout.liveGraphRange === 0 ? (root.interfaceHistory5m[ifaceRowItem.modelData.dev]?.rx || []) : (root.interfaceHistory30m[ifaceRowItem.modelData.dev]?.rx || [])
                                                        property var txData: popout.liveGraphRange === 0 ? (root.interfaceHistory5m[ifaceRowItem.modelData.dev]?.tx || []) : (root.interfaceHistory30m[ifaceRowItem.modelData.dev]?.tx || [])

                                                        onRxDataChanged: requestPaint()
                                                        onTxDataChanged: requestPaint()

                                                        onPaint: {
                                                            const ctx = getContext("2d");
                                                            ctx.reset();
                                                            ctx.clearRect(0, 0, width, height);
                                                            if (!rxData || rxData.length < 2) return;
                                                            const count = rxData.length;
                                                            const step = width / (count - 1);
                                                            let maxV = 10 * 1024;
                                                            for (let i = 0; i < count; i++) {
                                                                if (rxData[i] > maxV) maxV = rxData[i];
                                                                if (txData && txData[i] > maxV) maxV = txData[i];
                                                            }
                                                            function drawMini(data, col) {
                                                                ctx.strokeStyle = col;
                                                                ctx.lineWidth = 1.3;
                                                                ctx.beginPath();
                                                                for (let i = 0; i < data.length; i++) {
                                                                    const x = i * step;
                                                                    const y = height - (Math.min(maxV, Math.max(0, data[i])) / maxV) * (height - 2) - 1;
                                                                    if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
                                                                }
                                                                ctx.stroke();
                                                            }
                                                            if (txData && txData.length > 0) drawMini(txData, Theme.error);
                                                            drawMini(rxData, Theme.info);
                                                        }
                                                    }

                                                    Row {
                                                        width: parent.width
                                                        StyledText {
                                                            anchors.left: parent.left
                                                            text: `Session: ↓ ${root.formatBytes(ifaceRowItem.modelData.rx)}  ↑ ${root.formatBytes(ifaceRowItem.modelData.tx)}`
                                                            font.pixelSize: 8
                                                            isMonospace: true
                                                            color: Theme.surfaceVariantText
                                                        }

                                                        StyledText {
                                                            anchors.right: parent.right
                                                            text: ifaceRowItem.isSelected ? I18n.tr("Filtered in main graph") : I18n.tr("Click to filter main graph")
                                                            font.pixelSize: 8
                                                            font.bold: ifaceRowItem.isSelected
                                                            color: ifaceRowItem.isSelected ? Theme.primary : Theme.surfaceVariantText
                                                        }
                                                    }
                                                }
                                            }

                                            MouseArea {
                                                id: ifaceRowMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    popout.expandedInterface = (popout.expandedInterface === ifaceRowItem.modelData.dev) ? "" : ifaceRowItem.modelData.dev;
                                                    root.toggleInterfaceFilter(ifaceRowItem.modelData.dev);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ==========================================
                // === TAB 1: 7-DAY USAGE VIEW ===
                // ==========================================
                Column {
                    id: historyTabCol
                    visible: popout.activeTab === 1
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
                }

                // ==========================================
                // === TAB 2: DATA QUOTA & RULES VIEW ===
                // ==========================================
                Column {
                    id: quotaTabCol
                    visible: popout.activeTab === 2
                    width: parent.width
                    spacing: Theme.spacingM

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
                        text: root.formatSpeed(root.displayRxRate)
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
                        text: root.formatSpeed(root.displayTxRate)
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
                    text: root.formatSpeed(root.displayRxRate)
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
                    text: root.formatSpeed(root.displayTxRate)
                    font.pixelSize: Math.max(9, Math.round(Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText) * 0.78))
                    color: Theme.widgetTextColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
