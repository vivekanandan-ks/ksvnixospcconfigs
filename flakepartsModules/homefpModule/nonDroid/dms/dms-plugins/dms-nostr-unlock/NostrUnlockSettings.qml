import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Common
import qs.Services
import qs.DCommon.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "nostrUnlock"

    readonly property string adminBin: "/run/current-system/sw/bin/dms-nostr-unlock-admin"
    readonly property string currentUser: UserInfoService.username || ""
    readonly property string hostName: UserInfoService.hostname || "localhost"
    readonly property string appLabel: currentUser
        ? ("DMS Lock (" + currentUser + "@" + hostName + ")")
        : "DMS Lock"

    property bool paired: false
    property string pairedHex: ""
    property string relays: ""
    property string bunkerUri: ""

    property string busyPhase: ""
    property string pendingMode: ""
    property string pendingHex: ""
    property string statusMessage: ""
    property bool statusIsError: false

    property string qrPath: ""
    property string lastStderr: ""
    property bool pairExited: false
    property bool pairOutDone: false
    property int pairExitCode: -1
    property bool pairCancelled: false

    function syncTrustVars() {
        paired = Boolean(PluginService.getGlobalVar(root.pluginId, "paired", false));
        pairedHex = PluginService.getGlobalVar(root.pluginId, "pairedHex", "") || "";
    }

    function refreshDaemon() {
        PluginService.pluginDaemonInstances[root.pluginId]?.refreshTrustState?.();
        syncTrustVars();
    }

    function setStatus(msg, isErr) {
        statusMessage = msg || "";
        statusIsError = Boolean(isErr);
    }

    function clearQr() {
        if (qrPath !== "") {
            const p = qrPath;
            qrPath = "";
            DMSService.sendRequest("network.delete-qrcode", { path: p }, () => {});
        }
    }

    function parseRelays() {
        const parts = (relays || "").split(",").map(s => s.trim()).filter(s => s.length > 0);
        for (let i = 0; i < parts.length; i++) {
            if (!/^wss?:\/\/\S+$/i.test(parts[i]))
                return null;
        }
        return parts;
    }

    function cleanupStaging() {
        if (!cleanupProc.running)
            cleanupProc.running = true;
    }

    function startPairFlow(mode) {
        if (busyPhase !== "")
            return;
        if (!currentUser) {
            setStatus("Cannot determine current Linux user.", true);
            return;
        }
        if (mode === "bunker" && !bunkerUri.trim().startsWith("bunker://")) {
            setStatus("Enter a valid bunker:// URI.", true);
            return;
        }
        if (mode === "qr" && parseRelays() === null) {
            setStatus("Relays must be comma-separated wss:// URLs.", true);
            return;
        }

        clearQr();
        pendingMode = mode;
        pendingHex = "";
        busyPhase = "authorizing";
        setStatus("Confirm administrator prompt to authorize pairing...", false);
        authProc.command = ["pkexec", adminBin, "authorize", currentUser];
        authProc.running = true;
    }

    function launchPairCommand() {
        const args = [
            "amy",
            "--account", "dms-unlock-staging",
            "--secret-backend", "plaintext",
            "--json",
            "login"
        ];
        if (pendingMode === "qr") {
            args.push("--nostrconnect", "--timeout", "120", "--name", appLabel);
            const parsed = parseRelays();
            if (parsed && parsed.length > 0)
                args.push("--relay", parsed.join(","));
        } else {
            args.push(bunkerUri.trim());
        }

        pairExited = false;
        pairOutDone = false;
        pairExitCode = -1;
        pairCancelled = false;
        lastStderr = "";
        busyPhase = "waiting";
        setStatus(
            pendingMode === "qr"
                ? "Scan the QR code in your Nostr Signer app and approve..."
                : "Approve the connection in your remote Nostr Signer...",
            false
        );
        pairProc.command = args;
        pairProc.running = true;
    }

    function cancelPairing() {
        pairCancelled = true;
        if (pairProc.running)
            pairProc.running = false;
        clearQr();
        cleanupStaging();
        busyPhase = "";
        setStatus("Pairing cancelled.", false);
    }

    function tryFinishPairing() {
        if (!pairExited || !pairOutDone)
            return;

        clearQr();
        if (pairCancelled) {
            busyPhase = "";
            cleanupStaging();
            return;
        }

        if (pairExitCode !== 0) {
            busyPhase = "";
            cleanupStaging();
            setStatus(lastStderr || "Pairing failed or timed out.", true);
            return;
        }

        let hex = "";
        try {
            const parsed = JSON.parse(pairOutCollector.text || "{}");
            hex = (parsed.hex || "").trim().toLowerCase();
        } catch (e) {
            hex = "";
        }

        if (!/^[0-9a-f]{64}$/.test(hex)) {
            busyPhase = "";
            cleanupStaging();
            setStatus("Signer returned invalid public key.", true);
            return;
        }

        pendingHex = hex;
        busyPhase = "registering";
        setStatus("Confirm administrator prompt to register trusted signer key...", false);
        registerProc.command = ["pkexec", adminBin, "register", currentUser, hex];
        registerProc.running = true;
    }

    function startRevoke() {
        if (busyPhase !== "" || !currentUser)
            return;
        busyPhase = "revoking";
        setStatus("Confirm administrator prompt to revoke trusted signer...", false);
        revokeProc.command = ["pkexec", adminBin, "revoke", currentUser];
        revokeProc.running = true;
    }

    Connections {
        target: PluginService
        function onGlobalVarChanged(changedPluginId, key, val) {
            if (changedPluginId !== root.pluginId)
                return;
            if (key === "paired")
                root.paired = Boolean(val);
            else if (key === "pairedHex")
                root.pairedHex = val || "";
        }
    }

    Process {
        id: authProc
        onExited: (code, _) => {
            if (code !== 0) {
                root.busyPhase = "";
                root.setStatus("Authorization cancelled or failed.", true);
                return;
            }
            root.launchPairCommand();
        }
    }

    Process {
        id: pairProc

        stderr: SplitParser {
            onRead: line => {
                const idx = line.indexOf("nostrconnect://");
                if (idx !== -1) {
                    const uri = line.slice(idx).trim();
                    DMSService.sendRequest("network.generate-qrcode", { text: uri }, resp => {
                        const nextPath = resp?.result?.[1] || "";
                        if (!nextPath)
                            return;
                        if (root.pairCancelled || root.busyPhase !== "waiting") {
                            DMSService.sendRequest("network.delete-qrcode", { path: nextPath }, () => {});
                            return;
                        }
                        root.clearQr();
                        root.qrPath = nextPath;
                    });
                } else if (line.trim() !== "") {
                    root.lastStderr = line.trim();
                }
            }
        }

        stdout: StdioCollector {
            id: pairOutCollector
            onStreamFinished: {
                root.pairOutDone = true;
                root.tryFinishPairing();
            }
        }

        onExited: (code, _) => {
            root.pairExitCode = code;
            root.pairExited = true;
            root.tryFinishPairing();
        }
    }

    Process {
        id: registerProc
        onExited: (code, _) => {
            if (code !== 0) {
                root.busyPhase = "";
                root.cleanupStaging();
                root.setStatus("Registration cancelled — existing configuration unchanged.", true);
                return;
            }
            promoteProc.running = true;
        }
    }

    Process {
        id: promoteProc
        command: [
            "sh", "-c",
            "set -eu; d=\"$HOME/.amy\"; mkdir -p \"$d\"; rm -rf \"$d/dms-unlock.old\"; if [ -d \"$d/dms-unlock\" ]; then mv \"$d/dms-unlock\" \"$d/dms-unlock.old\"; fi; mv \"$d/dms-unlock-staging\" \"$d/dms-unlock\"; rm -rf \"$d/dms-unlock.old\""
        ]
        onExited: (code, _) => {
            root.busyPhase = "";
            if (code !== 0) {
                root.setStatus("Trusted key saved, but moving signer state failed.", true);
                return;
            }
            root.bunkerUri = "";
            root.refreshDaemon();
            root.setStatus("Nostr Signer paired successfully.", false);
        }
    }

    Process {
        id: revokeProc
        onExited: (code, _) => {
            if (code !== 0) {
                root.busyPhase = "";
                root.setStatus("Revoke cancelled or failed.", true);
                return;
            }
            logoffProc.running = true;
        }
    }

    Process {
        id: logoffProc
        command: [
            "sh", "-c",
            "amy --account dms-unlock logoff --yes --offline >/dev/null 2>&1 || true; amy --account dms-unlock-staging logoff --yes --offline >/dev/null 2>&1 || true"
        ]
        onExited: (code, _) => {
            root.busyPhase = "";
            root.refreshDaemon();
            root.setStatus("Nostr Signer unpaired.", false);
        }
    }

    Process {
        id: cleanupProc
        command: ["amy", "--account", "dms-unlock-staging", "logoff", "--yes", "--offline"]
    }

    ColumnLayout {
        width: parent.width
        spacing: Theme.spacingM

        StyledText {
            Layout.fillWidth: true
            text: "Nostr Signer Unlock"
            font.pixelSize: Theme.fontSizeLarge
            font.weight: Font.DemiBold
            color: Theme.onSurface
        }

        StyledText {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: root.paired
                ? ("Paired trusted key: " + root.pairedHex.slice(0, 12) + "…" + root.pairedHex.slice(-8))
                : "Not paired. Pairing stores the trusted public key root-owned so local processes cannot swap unlock keys silently."
            color: root.paired ? Theme.primary : Theme.onSurfaceVariant
            font.pixelSize: Theme.fontSizeMedium
        }

        DTextField {
            id: relaysField
            Layout.fillWidth: true
            labelText: "Relays for QR pairing (optional, comma-separated wss://)"
            placeholderText: "Leave empty for default NIP-46 relays"
            text: root.relays
            enabled: root.busyPhase === ""
            onTextEdited: {
                root.relays = text;
                root.saveState("relays", text.trim());
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingS

            DButton {
                text: root.busyPhase === "waiting" && root.pendingMode === "qr"
                    ? "Cancel Pairing"
                    : "Pair with QR"
                iconName: root.busyPhase === "waiting" && root.pendingMode === "qr"
                    ? "close"
                    : "qr_code_2"
                variant: "filled"
                enabled: root.busyPhase === "" || (root.busyPhase === "waiting" && root.pendingMode === "qr")
                onClicked: {
                    if (root.busyPhase === "waiting" && root.pendingMode === "qr")
                        root.cancelPairing();
                    else
                        root.startPairFlow("qr");
                }
            }

            DButton {
                text: "Revoke"
                iconName: "link_off"
                variant: "tonal"
                danger: true
                visible: root.paired
                enabled: root.busyPhase === ""
                onClicked: root.startRevoke()
            }
        }

        Image {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 220
            Layout.preferredHeight: 220
            visible: root.qrPath !== ""
            source: root.qrPath ? ("file://" + root.qrPath) : ""
            fillMode: Image.PreserveAspectFit
            cache: false
        }

        DTextField {
            Layout.fillWidth: true
            labelText: "Or connect using bunker:// URI"
            placeholderText: "bunker://<pubkey>?relay=wss://..."
            text: root.bunkerUri
            enabled: root.busyPhase === ""
            onTextEdited: root.bunkerUri = text
        }

        DButton {
            text: "Pair with Bunker URI"
            iconName: "link"
            variant: "outlined"
            enabled: root.busyPhase === "" && root.bunkerUri.trim().startsWith("bunker://")
            onClicked: root.startPairFlow("bunker")
        }

        StyledText {
            Layout.fillWidth: true
            visible: root.statusMessage !== ""
            wrapMode: Text.WordWrap
            text: root.statusMessage
            color: root.statusIsError ? Theme.error : Theme.onSurfaceVariant
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    Component.onCompleted: {
        relays = root.loadState("relays", "");
        refreshDaemon();
    }

    Component.onDestruction: {
        if (busyPhase === "waiting")
            cancelPairing();
        else
            clearQr();
    }
}
