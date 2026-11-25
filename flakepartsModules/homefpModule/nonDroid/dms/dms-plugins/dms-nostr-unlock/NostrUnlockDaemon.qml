import QtQuick
import Quickshell.Io
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root

    readonly property string anchorPath: UserInfoService.username
        ? ("/var/lib/dms-nostr-unlock/" + UserInfoService.username + "/trusted_pubkey")
        : ""

    property bool cancelling: false

    function applyAnchorText(raw) {
        const cleaned = (raw || "").trim().toLowerCase();
        const valid = /^[0-9a-f]{64}$/.test(cleaned);
        PluginService.setGlobalVar(root.pluginId, "paired", valid);
        PluginService.setGlobalVar(root.pluginId, "pairedHex", valid ? cleaned : "");
    }

    function publishState(state, errorMessage) {
        PluginService.setGlobalVar(root.pluginId, "unlockState", state);
        PluginService.setGlobalVar(root.pluginId, "errorMessage", errorMessage || "");
    }

    function refreshTrustState() {
        if (anchorWatcher.path !== "") {
            anchorWatcher.reload();
            applyAnchorText(anchorWatcher.text());
        } else {
            applyAnchorText("");
        }
    }

    function requestUnlock() {
        if (!IdleService.isSessionLockSecure)
            return;

        refreshTrustState();
        if (!PluginService.getGlobalVar(root.pluginId, "paired", false)) {
            publishState("idle", "");
            return;
        }
        if (unlockProc.running)
            return;

        cancelling = false;
        publishState("pending", "");
        unlockProc.running = true;
    }

    function cancelUnlock() {
        if (unlockProc.running) {
            cancelling = true;
            unlockProc.running = false;
        }
        publishState("idle", "");
    }

    FileView {
        id: anchorWatcher
        path: root.anchorPath
        blockLoading: true
        watchChanges: true
        printErrors: false

        onLoaded: root.applyAnchorText(text())
        onLoadFailed: root.applyAnchorText("")
        onFileChanged: reload()
    }

    Process {
        id: unlockProc
        command: ["dms-nostr-unlock-sign"]

        onExited: (exitCode, exitStatus) => {
            const wasCancelling = root.cancelling;
            root.cancelling = false;
            if (wasCancelling) {
                root.publishState("idle", "");
                return;
            }

            if (exitCode === 0 && IdleService.isSessionLockSecure) {
                root.publishState("idle", "");
                IdleService.lockComponent?.unlock();
                return;
            }

            if (IdleService.isSessionLockSecure)
                root.publishState("error", "Signer timed out or rejected — tap to retry");
            else
                root.publishState("idle", "");
        }
    }

    Connections {
        target: IdleService
        function onIsSessionLockSecureChanged() {
            if (!IdleService.isSessionLockSecure) {
                root.cancelUnlock();
            } else {
                root.refreshTrustState();
                if (PluginService.getGlobalVar(root.pluginId, "unlockState", "idle") === "error")
                    root.publishState("idle", "");
            }
        }
    }

    Component.onCompleted: {
        publishState("idle", "");
        refreshTrustState();
    }

    Component.onDestruction: cancelUnlock()
}
