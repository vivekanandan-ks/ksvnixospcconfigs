import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.DCommon.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "nostrUnlock"

    readonly property string adminBin: "/run/current-system/sw/bin/dms-nostr-unlock-admin"
    readonly property string stagingCleanupCmd: "amy --account dms-unlock-staging logoff --yes --offline >/dev/null 2>&1 || true; rm -rf \"$HOME/.amy/dms-unlock-staging\""
    readonly property string currentUser: UserInfoService.username || ""
    readonly property string hostName: UserInfoService.hostname || "localhost"
    readonly property string appLabel: currentUser
        ? (hostName + " DMS Lock (" + currentUser + ")")
        : (hostName + " DMS Lock")

    property bool paired: false
    property string pairedHex: ""
    property string pairedNpub: ""
    property string _npubHex: ""
    onPairedHexChanged: updatePairedNpub()
    property string relays: ""
    property string bunkerUri: ""

    property string busyPhase: ""
    property string pendingMode: ""
    property string statusMessage: ""
    property bool statusIsError: false

    property string qrPath: ""
    property string lastStderr: ""
    property bool pairExited: false
    property bool pairOutDone: false
    property int pairExitCode: -1
    property bool pairCancelled: false

    property string adminAction: ""
    property bool adminExited: false
    property bool adminErrDone: false
    property int adminExitCode: -1

    function syncTrustVars() {
        paired = Boolean(PluginService.getGlobalVar(root.pluginId, "paired", false));
        pairedHex = PluginService.getGlobalVar(root.pluginId, "pairedHex", "") || "";
    }

    function refreshDaemon() {
        PluginService.pluginDaemonInstances[root.pluginId]?.refreshTrustState?.();
        syncTrustVars();
        updatePairedNpub();
    }

    function updatePairedNpub() {
        const hex = pairedHex.trim().toLowerCase();
        if (!/^[0-9a-f]{64}$/.test(hex)) {
            pairedNpub = "";
            _npubHex = "";
            return;
        }
        if (hex === _npubHex && (pairedNpub !== "" || npubProc.running))
            return;
        _npubHex = hex;
        pairedNpub = "";
        if (npubProc.running)
            npubProc.running = false;
        npubProc.command = ["amy", "--json", "encode", "npub", hex];
        npubProc.running = true;
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

    function formatAdminError(rawErr, fallback) {
        const lines = (rawErr || "")
            .split(/\r?\n/)
            .map(s => s.trim())
            .filter(s => s.length > 0 && s !== "This incident has been reported.");
        return lines.length > 0 ? (fallback + " (" + lines[0] + ")") : fallback;
    }

    function runAdmin(action, busy, statusMsg, extraArg) {
        adminAction = action;
        adminExited = false;
        adminErrDone = false;
        adminExitCode = -1;
        busyPhase = busy;
        setStatus(statusMsg, false);
        const cmd = ["pkexec", adminBin, action, currentUser];
        if (extraArg !== undefined && extraArg !== "")
            cmd.push(extraArg);
        adminProc.command = cmd;
        adminProc.running = true;
    }

    function tryFinishAdmin() {
        if (!adminExited || !adminErrDone)
            return;

        const action = adminAction;
        const code = adminExitCode;
        const errText = adminErrCollector.text || "";

        if (code === 0) {
            if (action === "authorize")
                launchPairCommand();
            else if (action === "register")
                promoteProc.running = true;
            else if (action === "revoke")
                logoffProc.running = true;
            return;
        }

        busyPhase = "";
        if (action === "register")
            cleanupStaging();

        const fallbacks = {
            authorize: "Authorization cancelled or failed.",
            register: "Registration cancelled — existing configuration unchanged.",
            revoke: "Revoke cancelled or failed."
        };
        setStatus(formatAdminError(errText, fallbacks[action] || "Action failed."), true);
    }

    function startPairFlow(mode) {
        if (busyPhase !== "")
            return;
        if (paired) {
            setStatus("Revoke the current signer before pairing a new one.", true);
            return;
        }
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
        runAdmin("authorize", "authorizing", "Confirm administrator prompt to authorize pairing...");
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
            args.push("--nostrconnect", "--timeout", "120", "--perms", "sign_event:27235", "--name", appLabel);
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
        // Clear any leftover staging state synchronously so amy login cannot fail with "identity already exists"
        pairProc.command = ["sh", "-c", "rm -rf \"$HOME/.amy/dms-unlock-staging\" && exec \"$@\"", "sh"].concat(args);
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
            if (busyPhase === "waiting")
                busyPhase = "";
            if (busyPhase === "")
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

        runAdmin("register", "registering", "Confirm administrator prompt to register trusted signer key...", hex);
    }

    function startRevoke() {
        if (busyPhase !== "" || !currentUser)
            return;
        runAdmin("revoke", "revoking", "Confirm administrator prompt to revoke trusted signer...");
    }

    Connections {
        target: PluginService
        function onGlobalVarChanged(changedPluginId, key) {
            if (changedPluginId === root.pluginId)
                root.syncTrustVars();
        }
    }

    Process {
        id: adminProc

        stderr: StdioCollector {
            id: adminErrCollector
            onStreamFinished: {
                root.adminErrDone = true;
                root.tryFinishAdmin();
            }
        }

        onExited: (code, _) => {
            root.adminExitCode = code;
            root.adminExited = true;
            root.tryFinishAdmin();
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
        id: promoteProc
        command: [
            "sh", "-c",
            "set -eu; d=\"$HOME/.amy\"; mkdir -p \"$d\"; rm -rf \"$d/dms-unlock.old\"; had_old=0; if [ -d \"$d/dms-unlock\" ]; then mv \"$d/dms-unlock\" \"$d/dms-unlock.old\"; had_old=1; fi; if ! mv \"$d/dms-unlock-staging\" \"$d/dms-unlock\"; then if [ \"$had_old\" -eq 1 ] && [ -d \"$d/dms-unlock.old\" ] && [ ! -e \"$d/dms-unlock\" ]; then mv \"$d/dms-unlock.old\" \"$d/dms-unlock\" || true; fi; rm -rf \"$d/dms-unlock-staging\"; exit 1; fi; rm -rf \"$d/dms-unlock.old\""
        ]
        onExited: (code, _) => {
            root.busyPhase = "";
            if (code !== 0) {
                root.setStatus("Trusted key saved, but moving signer state failed; restored previous signer state.", true);
                return;
            }
            root.bunkerUri = "";
            root.refreshDaemon();
            root.setStatus("Nostr Signer paired successfully.", false);
        }
    }

    Process {
        id: logoffProc
        command: [
            "sh", "-c",
            "amy --account dms-unlock logoff --yes --offline >/dev/null 2>&1 || true; amy --account dms-unlock-staging logoff --yes --offline >/dev/null 2>&1 || true; rm -rf \"$HOME/.amy/dms-unlock\" \"$HOME/.amy/dms-unlock-staging\""
        ]
        onExited: (code, _) => {
            root.busyPhase = "";
            root.refreshDaemon();
            root.setStatus("Nostr Signer unpaired.", false);
        }
    }

    Process {
        id: cleanupProc
        command: ["sh", "-c", root.stagingCleanupCmd]
    }

    Process {
        id: npubProc
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(text || "{}");
                    if (root._npubHex === root.pairedHex.trim().toLowerCase())
                        root.pairedNpub = parsed.npub || "";
                } catch (e) {
                    root.pairedNpub = "";
                }
            }
        }
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
            wrapMode: Text.Wrap
            text: root.paired
                ? ("Paired trusted key: " + (root.pairedNpub || root.pairedHex))
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
                PluginService.savePluginState(root.pluginId, "relays", text.trim());
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
                enabled: (!root.paired && root.busyPhase === "") || (root.busyPhase === "waiting" && root.pendingMode === "qr")
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
            enabled: !root.paired && root.busyPhase === ""
            onTextEdited: root.bunkerUri = text
        }

        DButton {
            text: root.busyPhase === "waiting" && root.pendingMode === "bunker"
                ? "Cancel Pairing"
                : "Pair with Bunker URI"
            iconName: root.busyPhase === "waiting" && root.pendingMode === "bunker"
                ? "close"
                : "link"
            variant: "outlined"
            enabled: (!root.paired && root.busyPhase === "" && root.bunkerUri.trim().startsWith("bunker://"))
                || (root.busyPhase === "waiting" && root.pendingMode === "bunker")
            onClicked: {
                if (root.busyPhase === "waiting" && root.pendingMode === "bunker")
                    root.cancelPairing();
                else
                    root.startPairFlow("bunker");
            }
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
        relays = PluginService.loadPluginState(root.pluginId, "relays", "") || "";
        refreshDaemon();
    }

    Component.onDestruction: {
        if (busyPhase === "waiting") {
            pairCancelled = true;
            if (pairProc.running)
                pairProc.running = false;
        }
        clearQr();
        if (busyPhase === "waiting" || busyPhase === "registering")
            Quickshell.execDetached(["sh", "-c", stagingCleanupCmd]);
    }
}
