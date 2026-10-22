import QtQuick
import QtQuick.Shapes
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: topo

    property var rootWidget: null
    property int selectedNodeIndex: -1 // -1 = none, 0 = wifi, 1 = eth, 2 = bt, 10..14 = virtual, 30 = internet
    property var selectedNodeData: null

    implicitWidth: parent ? parent.width : 500
    implicitHeight: 340
    clip: true

    // --- Dynamic Theme Colors (Bound to DMS Material Theme) ---
    readonly property color nightSky: "#050711"
    readonly property color colRx: Theme.primary           // Cyan / Emerald (Download)
    readonly property color colTx: Theme.tertiary          // Magenta / Violet / Coral (Upload)
    readonly property color colVirtual: Theme.secondary    // Indigo / Lavender
    readonly property color colInactive: Theme.outlineLight

    // --- Active Live Rates ---
    readonly property real rxRate: rootWidget ? rootWidget.displayRxRate : 0
    readonly property real txRate: rootWidget ? rootWidget.displayTxRate : 0

    // Normalized speed multipliers (0.2 idle crawl up to 5.0 fast sprint)
    readonly property real rxSpeedMult: (rxRate > 512) ? Math.min(5.0, 0.8 + Math.log10(rxRate / 512) * 1.0) : 0.25
    readonly property real txSpeedMult: (txRate > 512) ? Math.min(5.0, 0.8 + Math.log10(txRate / 512) * 1.0) : 0.25

    // High-performance VSync animation clock (active only when visible)
    property real animTime: 0
    NumberAnimation on animTime {
        from: 0
        to: 3600
        duration: 3600000 // 1 hour continuous loop
        loops: Animation.Infinite
        running: topo.visible && !SessionService.locked
    }

    onAnimTimeChanged: {
        if (wavesCanvas.available) {
            wavesCanvas.requestPaint();
        }
    }

    // --- Cached Node Coordinates (Eliminates mapToItem from paint loop) ---
    property real hwX: 0
    property real hwY: 0
    property real netX: 0
    property real netY: 0
    property var virtCoords: []

    function updateCoords() {
        if (!wavesCanvas.available) return;

        let hw = topo.activeCarrierItem;
        if (hw) {
            let pt = hw.mapToItem(wavesCanvas, hw.width / 2, hw.height / 2);
            topo.hwX = pt.x;
            topo.hwY = pt.y;
        }

        if (internetSphere) {
            let pt = internetSphere.mapToItem(wavesCanvas, internetSphere.width / 2, internetSphere.height / 2);
            topo.netX = pt.x;
            topo.netY = pt.y;
        }

        let nodes = [nodeNetBird, nodeWireGuard, nodeYggdrasil, nodeTor, nodeFips];
        let c = [];
        for (let i = 0; i < nodes.length; i++) {
            let n = nodes[i];
            if (n) {
                let pt = n.mapToItem(wavesCanvas, n.width / 2, n.height / 2);
                c.push({ x: pt.x, y: pt.y });
            } else {
                c.push({ x: 0, y: 0 });
            }
        }
        topo.virtCoords = c;
    }

    Component.onCompleted: Qt.callLater(topo.updateCoords)
    onWidthChanged: Qt.callLater(topo.updateCoords)
    onHeightChanged: Qt.callLater(topo.updateCoords)
    onActiveCarrierItemChanged: Qt.callLater(topo.updateCoords)

    // --- Interfaces Classification ---
    readonly property var allIfaces: rootWidget ? (rootWidget.discoveredInterfaces || []) : []
    readonly property var virtIfaces: allIfaces.filter(i => !i.isPhysical)
    readonly property var physIfaces: allIfaces.filter(i => i.isPhysical)

    // Hardware status
    readonly property bool wifiConnected: physIfaces.some(i => i.dev.startsWith("wl") && ((i.rxRate > 0 || i.txRate > 0) || i.rx > 0)) || (physIfaces.length === 0)
    readonly property bool ethConnected: physIfaces.some(i => (i.dev.startsWith("en") || i.dev.startsWith("eth")) && (i.rxRate > 0 || i.txRate > 0))
    readonly property bool btConnected: physIfaces.some(i => (i.dev.startsWith("bnep") || i.dev.startsWith("bt")) && (i.rxRate > 0 || i.txRate > 0))

    readonly property var activePhysIface: {
        for (let i = 0; i < physIfaces.length; i++) {
            if (physIfaces[i].dev.startsWith("wl") && wifiConnected) return physIfaces[i];
            if ((physIfaces[i].dev.startsWith("en") || physIfaces[i].dev.startsWith("eth")) && ethConnected) return physIfaces[i];
        }
        return physIfaces[0] || { dev: "wlan0", name: "Wi-Fi", rxRate: topo.rxRate, txRate: topo.txRate };
    }

    readonly property var activeCarrierItem: {
        if (topo.ethConnected) return ethSphere;
        if (topo.btConnected) return btSphere;
        return wifiSphere;
    }

    // Static stardust seeds for GPU-accelerated canvas background rendering
    readonly property var starSeeds: [
        { x: 0.05, y: 0.15, r: 1.0, c: 0 }, { x: 0.15, y: 0.45, r: 1.4, c: 1 },
        { x: 0.22, y: 0.82, r: 1.1, c: 2 }, { x: 0.35, y: 0.25, r: 1.6, c: 0 },
        { x: 0.42, y: 0.65, r: 1.0, c: 1 }, { x: 0.52, y: 0.18, r: 1.3, c: 2 },
        { x: 0.62, y: 0.78, r: 1.5, c: 0 }, { x: 0.72, y: 0.32, r: 1.0, c: 1 },
        { x: 0.80, y: 0.60, r: 1.2, c: 2 }, { x: 0.88, y: 0.12, r: 1.4, c: 0 },
        { x: 0.94, y: 0.85, r: 1.1, c: 1 }, { x: 0.28, y: 0.55, r: 1.2, c: 2 },
        { x: 0.48, y: 0.88, r: 1.3, c: 0 }, { x: 0.68, y: 0.14, r: 1.1, c: 1 }
    ]

    // Background Canvas: Deep Night Sky Card with Border
    Rectangle {
        id: bgCard
        anchors.fill: parent
        radius: Theme.cornerRadius
        color: topo.nightSky
        border.width: 1
        border.color: Theme.outlineLight

        // Background click clears selected node
        MouseArea {
            anchors.fill: parent
            onClicked: {
                topo.selectedNodeIndex = -1;
                topo.selectedNodeData = null;
            }
        }

        // --- Header Legend ---
        Item {
            anchors.top: parent.top
            anchors.topMargin: Theme.spacingS
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacingM
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacingM
            height: 20

            Row {
                anchors.left: parent.left
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter

                StyledText {
                    text: I18n.tr("VIRTUAL")
                    font.pixelSize: 9
                    font.bold: true
                    color: topo.colVirtual
                }
                StyledText {
                    text: "➔"
                    font.pixelSize: 8
                    color: Theme.surfaceVariantText
                }
                StyledText {
                    text: I18n.tr("HARDWARE")
                    font.pixelSize: 9
                    font.bold: true
                    color: topo.colRx
                }
                StyledText {
                    text: "➔"
                    font.pixelSize: 8
                    color: Theme.surfaceVariantText
                }
                StyledText {
                    text: I18n.tr("INTERNET")
                    font.pixelSize: 9
                    font.bold: true
                    color: Theme.surfaceText
                }
            }

            StyledText {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: I18n.tr("Click sphere for details")
                font.pixelSize: 9
                color: Theme.surfaceVariantText
            }
        }

        // --- High-Performance GPU-Optimized Canvas Layer ---
        Canvas {
            id: wavesCanvas
            anchors.fill: parent
            antialiasing: true

            onPaint: {
                let ctx = getContext("2d");
                let w = width;
                let h = height;
                ctx.clearRect(0, 0, w, h);

                let t = topo.animTime;

                // 1. Ultra-fast Ambient Stardust in Canvas (Zero QML Item Overhead)
                let stars = topo.starSeeds;
                let sLen = stars.length;
                for (let s = 0; s < sLen; s++) {
                    let st = stars[s];
                    let sx = (st.x * w + t * 8 * (0.2 + (s % 3) * 0.15)) % w;
                    let sy = st.y * h + 2 * Math.sin(t * 1.2 + s);
                    let alpha = 0.15 + 0.35 * (0.5 + 0.5 * Math.sin(t * 1.8 + s));
                    ctx.fillStyle = st.c === 0 ? Qt.rgba(topo.colRx.r, topo.colRx.g, topo.colRx.b, alpha)
                                  : (st.c === 1 ? Qt.rgba(topo.colTx.r, topo.colTx.g, topo.colTx.b, alpha)
                                  : Qt.rgba(0.9, 0.95, 1.0, alpha));
                    ctx.fillRect(sx, sy, st.r, st.r);
                }

                // Check cached positions (fall back safely if not yet cached)
                let targetX = topo.hwX;
                let targetY = topo.hwY;
                let netX = topo.netX;
                let netY = topo.netY;

                if (targetX === 0 || netX === 0) {
                    topo.updateCoords();
                    targetX = topo.hwX;
                    targetY = topo.hwY;
                    netX = topo.netX;
                    netY = topo.netY;
                    if (targetX === 0 || netX === 0) return;
                }

                let rxSpeed = topo.rxSpeedMult;
                let txSpeed = topo.txSpeedMult;

                // 2. High-Speed Trunk Conduits (Middle Hardware <===> Right Internet)
                // Downstream Trunk (Top track: Internet -> Hardware)
                let trunkTopY_net = netY - 5;
                let trunkTopY_hw = targetY - 5;
                let trunkMidX = (targetX + netX) / 2;

                // Outer casing for download trunk
                ctx.beginPath();
                ctx.moveTo(targetX, trunkTopY_hw);
                ctx.lineTo(netX, trunkTopY_net);
                ctx.strokeStyle = Qt.rgba(topo.colRx.r, topo.colRx.g, topo.colRx.b, 0.18);
                ctx.lineWidth = 3;
                ctx.stroke();

                // Inner core line
                ctx.beginPath();
                ctx.moveTo(targetX, trunkTopY_hw);
                ctx.lineTo(netX, trunkTopY_net);
                ctx.strokeStyle = Qt.rgba(topo.colRx.r, topo.colRx.g, topo.colRx.b, 0.45);
                ctx.lineWidth = 1.0;
                ctx.stroke();

                // Upstream Trunk (Bottom track: Hardware -> Internet)
                let trunkBotY_net = netY + 5;
                let trunkBotY_hw = targetY + 5;

                // Outer casing for upload trunk
                ctx.beginPath();
                ctx.moveTo(targetX, trunkBotY_hw);
                ctx.lineTo(netX, trunkBotY_net);
                ctx.strokeStyle = Qt.rgba(topo.colTx.r, topo.colTx.g, topo.colTx.b, 0.18);
                ctx.lineWidth = 3;
                ctx.stroke();

                // Inner core line
                ctx.beginPath();
                ctx.moveTo(targetX, trunkBotY_hw);
                ctx.lineTo(netX, trunkBotY_net);
                ctx.strokeStyle = Qt.rgba(topo.colTx.r, topo.colTx.g, topo.colTx.b, 0.45);
                ctx.lineWidth = 1.0;
                ctx.stroke();

                // 3. Bidirectional Live Packets Between Hardware & Internet
                // Inward Packets (Download / Rx: Internet -> Hardware)
                let rxBeadCount = (topo.rxRate > 1024 * 1024) ? 4 : ((topo.rxRate > 1024 * 50) ? 3 : 2);
                for (let b = 0; b < rxBeadCount; b++) {
                    let p = ((t * rxSpeed * 0.45 + b / rxBeadCount) % 1.0);
                    // Inward: from netX to targetX
                    let bx = (1 - p) * netX + p * targetX;
                    let by = (1 - p) * trunkTopY_net + p * trunkTopY_hw;

                    // Double-pass hardware glow (zero CPU Gaussian blur)
                    ctx.beginPath();
                    ctx.arc(bx, by, 4.2, 0, Math.PI * 2);
                    ctx.fillStyle = Qt.rgba(topo.colRx.r, topo.colRx.g, topo.colRx.b, 0.35);
                    ctx.fill();

                    ctx.beginPath();
                    ctx.arc(bx, by, 2.0, 0, Math.PI * 2);
                    ctx.fillStyle = "#ffffff";
                    ctx.fill();
                }

                // Outward Packets (Upload / Tx: Hardware -> Internet)
                let txBeadCount = (topo.txRate > 1024 * 512) ? 4 : ((topo.txRate > 1024 * 20) ? 3 : 2);
                for (let b = 0; b < txBeadCount; b++) {
                    let p = ((t * txSpeed * 0.45 + b / txBeadCount) % 1.0);
                    // Outward: from targetX to netX
                    let bx = (1 - p) * targetX + p * netX;
                    let by = (1 - p) * trunkBotY_hw + p * trunkBotY_net;

                    // Double-pass hardware glow (zero CPU Gaussian blur)
                    ctx.beginPath();
                    ctx.arc(bx, by, 4.2, 0, Math.PI * 2);
                    ctx.fillStyle = Qt.rgba(topo.colTx.r, topo.colTx.g, topo.colTx.b, 0.35);
                    ctx.fill();

                    ctx.beginPath();
                    ctx.arc(bx, by, 2.0, 0, Math.PI * 2);
                    ctx.fillStyle = "#ffffff";
                    ctx.fill();
                }

                // 4. Concentric Radiowave Ripples (Active Hardware Carrier)
                let numWaves = 3;
                for (let w = 0; w < numWaves; w++) {
                    let wProg = ((t * rxSpeed * 0.2 + w * 0.33) % 1.0);
                    let r = 16 + wProg * 70;
                    let alpha = Math.max(0.04, 0.5 * (1.0 - wProg));

                    ctx.beginPath();
                    ctx.arc(targetX, targetY, r, -Math.PI * 0.3, Math.PI * 0.3, false);
                    ctx.strokeStyle = Qt.rgba(topo.colRx.r, topo.colRx.g, topo.colRx.b, alpha);
                    ctx.lineWidth = 1.3;
                    ctx.stroke();
                }

                // 5. Flexible Optical Tubes (Left Virtual <===> Middle Hardware)
                let virtNodes = [nodeNetBird, nodeWireGuard, nodeYggdrasil, nodeTor, nodeFips];
                let coords = topo.virtCoords;
                let cLen = coords ? coords.length : 0;

                for (let v = 0; v < cLen; v++) {
                    let vc = coords[v];
                    let node = virtNodes[v];
                    if (!vc || !node || vc.x === 0) continue;

                    let vnX = vc.x;
                    let vnY = vc.y;
                    let cpX = (vnX + targetX) / 2;
                    let cpY = vnY;
                    let isActive = node.isActive;

                    // Outer transparent casing
                    ctx.beginPath();
                    ctx.moveTo(vnX, vnY);
                    ctx.quadraticCurveTo(cpX, cpY, targetX, targetY);
                    ctx.strokeStyle = Qt.rgba(topo.colVirtual.r, topo.colVirtual.g, topo.colVirtual.b, isActive ? 0.30 : 0.10);
                    ctx.lineWidth = isActive ? 3.0 : 1.6;
                    ctx.stroke();

                    // Inner glowing optical thread
                    ctx.beginPath();
                    ctx.moveTo(vnX, vnY);
                    ctx.quadraticCurveTo(cpX, cpY, targetX, targetY);
                    ctx.strokeStyle = Qt.rgba(topo.colVirtual.r, topo.colVirtual.g, topo.colVirtual.b, isActive ? 0.70 : 0.20);
                    ctx.lineWidth = isActive ? 1.2 : 0.6;
                    ctx.stroke();

                    // Bidirectional data packets along the conduit
                    if (isActive) {
                        // Inward packet (Hardware -> Virtual / Local Host for Download)
                        let pIn = ((t * rxSpeed * 0.35 + v * 0.2) % 1.0);
                        let mtIn = 1 - pIn;
                        let dotInX = mtIn * mtIn * targetX + 2 * mtIn * pIn * cpX + pIn * pIn * vnX;
                        let dotInY = mtIn * mtIn * targetY + 2 * mtIn * pIn * cpY + pIn * pIn * vnY;

                        ctx.beginPath();
                        ctx.arc(dotInX, dotInY, 3.8, 0, Math.PI * 2);
                        ctx.fillStyle = Qt.rgba(topo.colRx.r, topo.colRx.g, topo.colRx.b, 0.30);
                        ctx.fill();

                        ctx.beginPath();
                        ctx.arc(dotInX, dotInY, 1.8, 0, Math.PI * 2);
                        ctx.fillStyle = "#ffffff";
                        ctx.fill();

                        // Outward packet (Virtual -> Hardware for Upload)
                        let pOut = ((t * txSpeed * 0.35 + v * 0.2) % 1.0);
                        let mtOut = 1 - pOut;
                        let dotOutX = mtOut * mtOut * vnX + 2 * mtOut * pOut * cpX + pOut * pOut * targetX;
                        let dotOutY = mtOut * mtOut * vnY + 2 * mtOut * pOut * cpY + pOut * pOut * targetY;

                        ctx.beginPath();
                        ctx.arc(dotOutX, dotOutY, 3.8, 0, Math.PI * 2);
                        ctx.fillStyle = Qt.rgba(topo.colTx.r, topo.colTx.g, topo.colTx.b, 0.30);
                        ctx.fill();

                        ctx.beginPath();
                        ctx.arc(dotOutX, dotOutY, 1.8, 0, Math.PI * 2);
                        ctx.fillStyle = "#ffffff";
                        ctx.fill();
                    } else {
                        // Subtle idle pulse
                        let pIdle = ((t * 0.15 + v * 0.2) % 1.0);
                        let mt = 1 - pIdle;
                        let dotX = mt * mt * vnX + 2 * mt * pIdle * cpX + pIdle * pIdle * targetX;
                        let dotY = mt * mt * vnY + 2 * mt * pIdle * cpY + pIdle * pIdle * targetY;

                        ctx.beginPath();
                        ctx.arc(dotX, dotY, 1.5, 0, Math.PI * 2);
                        ctx.fillStyle = Qt.rgba(1, 1, 1, 0.25);
                        ctx.fill();
                    }
                }
            }
        }

        // --- 3 Main Columns Container ---
        Item {
            anchors.fill: parent
            anchors.topMargin: 36
            anchors.bottomMargin: 12
            anchors.leftMargin: Theme.spacingM
            anchors.rightMargin: Theme.spacingM

            // 1. LEFT COLUMN: 5 Virtual Interface Spheres (NetBird, WireGuard, Yggdrasil, Tor, FIPS)
            Column {
                id: leftCol
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                // NetBird (wt0) Sphere
                Item {
                    id: nodeNetBird
                    width: 36
                    height: 38
                    readonly property bool isActive: topo.virtIfaces.some(i => i.dev.startsWith("wt"))
                    readonly property var detectedIface: topo.virtIfaces.find(i => i.dev.startsWith("wt"))

                    Rectangle {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 26
                        height: 26
                        radius: 13
                        color: topo.selectedNodeIndex === 10 ? Theme.primary : (nodeNetBird.isActive ? "#0d1b33" : "#080c18")
                        border.width: nodeNetBird.isActive ? 1.5 : 1
                        border.color: nodeNetBird.isActive ? topo.colVirtual : Qt.rgba(topo.colVirtual.r, topo.colVirtual.g, topo.colVirtual.b, 0.3)
                        opacity: nodeNetBird.isActive ? 1.0 : 0.55

                        DankIcon {
                            anchors.centerIn: parent
                            name: "hub"
                            size: 13
                            color: nodeNetBird.isActive ? topo.colVirtual : Theme.surfaceVariantText
                        }
                    }

                    StyledText {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "NetBird"
                        font.pixelSize: 8
                        font.bold: nodeNetBird.isActive
                        color: nodeNetBird.isActive ? Theme.surfaceText : Theme.surfaceVariantText
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            topo.selectedNodeIndex = 10;
                            let iface = nodeNetBird.detectedIface || { dev: "wt0", rxRate: 0, txRate: 0 };
                            topo.selectedNodeData = {
                                title: "NetBird Mesh Overlay",
                                dev: iface.dev,
                                status: nodeNetBird.isActive ? "Encapsulated P2P WireGuard (Active)" : "Mesh Standby",
                                rx: iface.rxRate,
                                tx: iface.txRate,
                                extra: "Zero-trust P2P overlay routing via active hardware carrier"
                            };
                        }
                    }
                }

                // WireGuard (wg0) Sphere
                Item {
                    id: nodeWireGuard
                    width: 36
                    height: 38
                    readonly property bool isActive: topo.virtIfaces.some(i => i.dev.startsWith("wg"))
                    readonly property var detectedIface: topo.virtIfaces.find(i => i.dev.startsWith("wg"))

                    Rectangle {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 26
                        height: 26
                        radius: 13
                        color: topo.selectedNodeIndex === 11 ? Theme.primary : (nodeWireGuard.isActive ? "#0d1b33" : "#080c18")
                        border.width: nodeWireGuard.isActive ? 1.5 : 1
                        border.color: nodeWireGuard.isActive ? topo.colVirtual : Qt.rgba(topo.colVirtual.r, topo.colVirtual.g, topo.colVirtual.b, 0.3)
                        opacity: nodeWireGuard.isActive ? 1.0 : 0.55

                        DankIcon {
                            anchors.centerIn: parent
                            name: "shield"
                            size: 13
                            color: nodeWireGuard.isActive ? topo.colVirtual : Theme.surfaceVariantText
                        }
                    }

                    StyledText {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "WireGuard"
                        font.pixelSize: 8
                        font.bold: nodeWireGuard.isActive
                        color: nodeWireGuard.isActive ? Theme.surfaceText : Theme.surfaceVariantText
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            topo.selectedNodeIndex = 11;
                            let iface = nodeWireGuard.detectedIface || { dev: "wg0", rxRate: 0, txRate: 0 };
                            topo.selectedNodeData = {
                                title: "WireGuard Tunnel",
                                dev: iface.dev,
                                status: nodeWireGuard.isActive ? "Kernel Crypto Tunnel Active" : "Tunnel Standby",
                                rx: iface.rxRate,
                                tx: iface.txRate,
                                extra: "High-speed ChaCha20-Poly1305 encrypted UDP transport"
                            };
                        }
                    }
                }

                // Yggdrasil (ygg0) Sphere
                Item {
                    id: nodeYggdrasil
                    width: 36
                    height: 38
                    readonly property bool isActive: topo.virtIfaces.some(i => i.dev.startsWith("ygg"))
                    readonly property var detectedIface: topo.virtIfaces.find(i => i.dev.startsWith("ygg"))

                    Rectangle {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 26
                        height: 26
                        radius: 13
                        color: topo.selectedNodeIndex === 12 ? Theme.primary : (nodeYggdrasil.isActive ? "#0d1b33" : "#080c18")
                        border.width: nodeYggdrasil.isActive ? 1.5 : 1
                        border.color: nodeYggdrasil.isActive ? topo.colVirtual : Qt.rgba(topo.colVirtual.r, topo.colVirtual.g, topo.colVirtual.b, 0.3)
                        opacity: nodeYggdrasil.isActive ? 1.0 : 0.55

                        DankIcon {
                            anchors.centerIn: parent
                            name: "device_hub"
                            size: 13
                            color: nodeYggdrasil.isActive ? topo.colVirtual : Theme.surfaceVariantText
                        }
                    }

                    StyledText {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Yggdrasil"
                        font.pixelSize: 8
                        font.bold: nodeYggdrasil.isActive
                        color: nodeYggdrasil.isActive ? Theme.surfaceText : Theme.surfaceVariantText
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            topo.selectedNodeIndex = 12;
                            let iface = nodeYggdrasil.detectedIface || { dev: "ygg0", rxRate: 0, txRate: 0 };
                            topo.selectedNodeData = {
                                title: "Yggdrasil Network",
                                dev: iface.dev,
                                status: nodeYggdrasil.isActive ? "Encrypted IPv6 Mesh Active" : "Mesh Standby",
                                rx: iface.rxRate,
                                tx: iface.txRate,
                                extra: "Fully end-to-end encrypted global compact routing scheme"
                            };
                        }
                    }
                }

                // Tor (tun-tor) Sphere
                Item {
                    id: nodeTor
                    width: 36
                    height: 38
                    readonly property bool isActive: topo.virtIfaces.some(i => i.dev.includes("tor") || i.dev.includes("onion"))
                    readonly property var detectedIface: topo.virtIfaces.find(i => i.dev.includes("tor") || i.dev.includes("onion"))

                    Rectangle {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 26
                        height: 26
                        radius: 13
                        color: topo.selectedNodeIndex === 13 ? Theme.primary : (nodeTor.isActive ? "#0d1b33" : "#080c18")
                        border.width: nodeTor.isActive ? 1.5 : 1
                        border.color: nodeTor.isActive ? topo.colVirtual : Qt.rgba(topo.colVirtual.r, topo.colVirtual.g, topo.colVirtual.b, 0.3)
                        opacity: nodeTor.isActive ? 1.0 : 0.55

                        DankIcon {
                            anchors.centerIn: parent
                            name: "vpn_lock"
                            size: 13
                            color: nodeTor.isActive ? topo.colVirtual : Theme.surfaceVariantText
                        }
                    }

                    StyledText {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Tor"
                        font.pixelSize: 8
                        font.bold: nodeTor.isActive
                        color: nodeTor.isActive ? Theme.surfaceText : Theme.surfaceVariantText
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            topo.selectedNodeIndex = 13;
                            let iface = nodeTor.detectedIface || { dev: "tun-tor", rxRate: 0, txRate: 0 };
                            topo.selectedNodeData = {
                                title: "Tor Onion Network",
                                dev: iface.dev,
                                status: nodeTor.isActive ? "Onion Circuit Active" : "Standby (Inactive)",
                                rx: iface.rxRate,
                                tx: iface.txRate,
                                extra: "Anonymized multi-hop layered onion routing protocol"
                            };
                        }
                    }
                }

                // FIPS / VPN (tun0) Sphere
                Item {
                    id: nodeFips
                    width: 36
                    height: 38
                    readonly property bool isActive: topo.virtIfaces.some(i => i.dev.startsWith("fips") || i.dev.startsWith("tun"))
                    readonly property var detectedIface: topo.virtIfaces.find(i => i.dev.startsWith("fips") || i.dev.startsWith("tun"))

                    Rectangle {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 26
                        height: 26
                        radius: 13
                        color: topo.selectedNodeIndex === 14 ? Theme.primary : (nodeFips.isActive ? "#0d1b33" : "#080c18")
                        border.width: nodeFips.isActive ? 1.5 : 1
                        border.color: nodeFips.isActive ? topo.colVirtual : Qt.rgba(topo.colVirtual.r, topo.colVirtual.g, topo.colVirtual.b, 0.3)
                        opacity: nodeFips.isActive ? 1.0 : 0.55

                        DankIcon {
                            anchors.centerIn: parent
                            name: "security"
                            size: 13
                            color: nodeFips.isActive ? topo.colVirtual : Theme.surfaceVariantText
                        }
                    }

                    StyledText {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "FIPS/VPN"
                        font.pixelSize: 8
                        font.bold: nodeFips.isActive
                        color: nodeFips.isActive ? Theme.surfaceText : Theme.surfaceVariantText
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            topo.selectedNodeIndex = 14;
                            let iface = nodeFips.detectedIface || { dev: "tun0", rxRate: 0, txRate: 0 };
                            topo.selectedNodeData = {
                                title: "FIPS 140-2 / Enterprise VPN",
                                dev: iface.dev,
                                status: nodeFips.isActive ? "Encrypted Tunnel Active" : "Standby (Disconnected)",
                                rx: iface.rxRate,
                                tx: iface.txRate,
                                extra: "NIST FIPS 140-2 cryptographic compliant gateway"
                            };
                        }
                    }
                }
            }

            // 2. MIDDLE COLUMN: 3 Hardware Interfaces (Active vs Greyed Out)
            Column {
                id: middleCol
                anchors.centerIn: parent
                spacing: 16

                // Wi-Fi Sphere (ACTIVE)
                Item {
                    id: wifiSphere
                    width: 44
                    height: 44

                    // Aura Ring
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width + 6 + Math.sin(topo.animTime * 4) * 3
                        height: width
                        radius: width / 2
                        color: "transparent"
                        border.width: 1.2
                        border.color: topo.colRx
                        opacity: topo.wifiConnected ? 0.45 : 0.1
                    }

                    // Main Sphere Disc
                    Rectangle {
                        anchors.centerIn: parent
                        width: 36
                        height: 36
                        radius: 18
                        color: topo.selectedNodeIndex === 0 ? Theme.primary : (topo.wifiConnected ? "#09192c" : "#070912")
                        border.width: topo.wifiConnected ? 2 : 1
                        border.color: topo.wifiConnected ? topo.colRx : Theme.outlineLight

                        DankIcon {
                            anchors.centerIn: parent
                            name: "wifi"
                            size: 16
                            color: topo.wifiConnected ? topo.colRx : Theme.surfaceVariantText
                        }
                    }

                    StyledText {
                        anchors.top: parent.bottom
                        anchors.topMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Wi-Fi 6"
                        font.pixelSize: 9
                        font.bold: topo.wifiConnected
                        color: topo.wifiConnected ? Theme.surfaceText : Theme.surfaceVariantText
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            topo.selectedNodeIndex = 0;
                            topo.selectedNodeData = {
                                title: "Wi-Fi 6 Hardware Interface",
                                dev: topo.activePhysIface.dev || "wlan0",
                                status: topo.wifiConnected ? "Active Carrier (Connected)" : "Disconnected",
                                rx: topo.rxRate,
                                tx: topo.txRate,
                                extra: "Carrying Virtual Overlays & Internet Traffic"
                            };
                        }
                    }
                }

                // Ethernet Sphere (GREYED OUT)
                Item {
                    id: ethSphere
                    width: 36
                    height: 36
                    opacity: topo.ethConnected ? 1.0 : 0.35

                    Rectangle {
                        anchors.centerIn: parent
                        width: 30
                        height: 30
                        radius: 15
                        color: topo.selectedNodeIndex === 1 ? Theme.primary : "#070914"
                        border.width: 1
                        border.color: topo.ethConnected ? topo.colRx : Theme.outlineLight

                        DankIcon {
                            anchors.centerIn: parent
                            name: "lan"
                            size: 13
                            color: topo.ethConnected ? topo.colRx : Theme.surfaceVariantText
                        }
                    }

                    StyledText {
                        anchors.top: parent.bottom
                        anchors.topMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Ethernet"
                        font.pixelSize: 8
                        color: Theme.surfaceVariantText
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            topo.selectedNodeIndex = 1;
                            topo.selectedNodeData = {
                                title: "Ethernet Hardware Interface",
                                dev: "eth0",
                                status: topo.ethConnected ? "Active 1000Mbps Carrier" : "Standby (Cable Unplugged)",
                                rx: 0,
                                tx: 0,
                                extra: "Auto-routes priority traffic when link carrier activates"
                            };
                        }
                    }
                }

                // Bluetooth Sphere (GREYED OUT)
                Item {
                    id: btSphere
                    width: 36
                    height: 36
                    opacity: topo.btConnected ? 1.0 : 0.35

                    Rectangle {
                        anchors.centerIn: parent
                        width: 28
                        height: 28
                        radius: 14
                        color: topo.selectedNodeIndex === 2 ? Theme.primary : "#070914"
                        border.width: 1
                        border.color: topo.btConnected ? topo.colRx : Theme.outlineLight

                        DankIcon {
                            anchors.centerIn: parent
                            name: "bluetooth"
                            size: 12
                            color: topo.btConnected ? topo.colRx : Theme.surfaceVariantText
                        }
                    }

                    StyledText {
                        anchors.top: parent.bottom
                        anchors.topMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Bluetooth"
                        font.pixelSize: 8
                        color: Theme.surfaceVariantText
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            topo.selectedNodeIndex = 2;
                            topo.selectedNodeData = {
                                title: "Bluetooth PAN Tethering",
                                dev: "bnep0",
                                status: topo.btConnected ? "Active PAN Tethering" : "Standby (Low Power)",
                                rx: 0,
                                tx: 0,
                                extra: "Personal Area Network standby profile"
                            };
                        }
                    }
                }
            }

            // 3. RIGHT COLUMN: Internet Sphere (WAN / Gateway)
            Item {
                id: rightCol
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                width: 64
                height: 64

                Item {
                    id: internetSphere
                    anchors.centerIn: parent
                    width: 56
                    height: 56

                    // Nocturnal Internet Globe Disc
                    Rectangle {
                        anchors.centerIn: parent
                        width: 52
                        height: 52
                        radius: 26
                        color: "#0a1124"
                        border.width: 1.5
                        border.color: Qt.rgba(topo.colRx.r, topo.colRx.g, topo.colRx.b, 0.5)

                        DankIcon {
                            anchors.centerIn: parent
                            name: "public"
                            size: 24
                            color: Theme.surfaceText
                            opacity: 0.90
                        }
                    }

                    StyledText {
                        anchors.top: parent.bottom
                        anchors.topMargin: 4
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Internet"
                        font.pixelSize: 9
                        font.bold: true
                        color: Theme.surfaceText
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            topo.selectedNodeIndex = 30;
                            topo.selectedNodeData = {
                                title: "Internet Gateway (WAN)",
                                dev: "Default Gateway",
                                status: "Global Internet Backbone",
                                rx: topo.rxRate,
                                tx: topo.txRate,
                                extra: "Live bidirectional packet transmission & reception"
                            };
                        }
                    }
                }
            }
        }

        // --- INTERACTIVE DETAIL POPOVER (Expands when any sphere is clicked) ---
        Rectangle {
            id: detailPopover
            visible: topo.selectedNodeData !== null
            anchors.centerIn: parent
            width: Math.min(290, parent.width - 40)
            height: 140
            radius: Theme.cornerRadius
            color: "#0b1226"
            border.width: 1.5
            border.color: topo.colRx
            z: 10

            Column {
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: 4

                Item {
                    width: parent.width
                    height: 20

                    StyledText {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: topo.selectedNodeData ? topo.selectedNodeData.title : ""
                        font.pixelSize: 11
                        font.bold: true
                        color: Theme.surfaceText
                    }

                    DankIcon {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        name: "close"
                        size: 14
                        color: Theme.surfaceVariantText
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                topo.selectedNodeIndex = -1;
                                topo.selectedNodeData = null;
                            }
                        }
                    }
                }

                StyledText {
                    text: topo.selectedNodeData ? ("Interface: " + topo.selectedNodeData.dev) : ""
                    font.pixelSize: 10
                    color: topo.colRx
                }

                StyledText {
                    text: topo.selectedNodeData ? ("Status: " + topo.selectedNodeData.status) : ""
                    font.pixelSize: 9
                    color: Theme.surfaceVariantText
                }

                Row {
                    spacing: 12
                    StyledText {
                        text: "↓ " + (rootWidget ? rootWidget.formatSpeed(topo.selectedNodeData ? topo.selectedNodeData.rx : 0) : "0 B") + "/s"
                        font.pixelSize: 10
                        font.bold: true
                        color: topo.colRx
                    }
                    StyledText {
                        text: "↑ " + (rootWidget ? rootWidget.formatSpeed(topo.selectedNodeData ? topo.selectedNodeData.tx : 0) : "0 B") + "/s"
                        font.pixelSize: 10
                        font.bold: true
                        color: topo.colTx
                    }
                }

                StyledText {
                    text: topo.selectedNodeData ? topo.selectedNodeData.extra : ""
                    font.pixelSize: 9
                    color: Theme.surfaceVariantText
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }
    }
}
