import QtQuick
import qs.Common
import qs.Services
import qs.DCommon.Widgets
import qs.Modules.Plugins

DesktopPluginComponent {
    id: root

    property var lockHost: null
    readonly property real defaultWidth: 260
    readonly property real defaultHeight: 44

    minWidth: 220
    minHeight: 40
    focus: false

    property bool paired: false
    property string unlockState: "idle"
    property string errorMessage: ""

    readonly property bool interactive: root.lockScreen && root.paired
    readonly property string statusLabel: {
        if (!root.lockScreen)
            return "Lock screen only";
        if (!root.paired)
            return "Not paired — configure in Settings";
        if (root.unlockState === "pending")
            return "Waiting for Nostr Signer...";
        if (root.unlockState === "error")
            return root.errorMessage || "Signer timed out or rejected — tap to retry";
        return "Unlock with Nostr Signer";
    }
    readonly property string statusIcon: {
        if (!root.lockScreen || !root.paired)
            return "phonelink_lock";
        if (root.unlockState === "pending")
            return "hourglass_top";
        if (root.unlockState === "error")
            return "error_outline";
        return "key";
    }

    function syncFromDaemon() {
        if (!root.pluginId)
            return;
        paired = Boolean(PluginService.getGlobalVar(root.pluginId, "paired", false));
        unlockState = PluginService.getGlobalVar(root.pluginId, "unlockState", "idle") || "idle";
        errorMessage = PluginService.getGlobalVar(root.pluginId, "errorMessage", "") || "";
    }

    Connections {
        target: PluginService
        function onGlobalVarChanged(changedPluginId, key) {
            if (changedPluginId === root.pluginId)
                root.syncFromDaemon();
        }
    }

    onPluginIdChanged: syncFromDaemon()
    Component.onCompleted: syncFromDaemon()

    Rectangle {
        id: pill
        anchors.fill: parent
        radius: height / 2
        color: {
            if (!root.interactive)
                return Theme.surfaceContainer;
            if (root.unlockState === "error")
                return Theme.errorContainer;
            if (root.unlockState === "pending" || mouseArea.containsMouse)
                return Theme.primaryContainer;
            return Theme.surfaceContainerHigh;
        }
        border.width: 1
        border.color: {
            if (!root.interactive)
                return Theme.outlineVariant;
            if (root.unlockState === "error")
                return Theme.error;
            return Theme.primary;
        }
        opacity: root.interactive ? 1.0 : 0.72

        Row {
            anchors.centerIn: parent
            width: Math.min(parent.width - 24, implicitWidth)
            spacing: 8

            DIcon {
                anchors.verticalCenter: parent.verticalCenter
                name: root.statusIcon
                size: 18
                color: {
                    if (!root.interactive)
                        return Theme.onSurfaceVariant;
                    if (root.unlockState === "error")
                        return Theme.onErrorContainer;
                    if (root.unlockState === "pending")
                        return Theme.onPrimaryContainer;
                    return Theme.onSurface;
                }
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(implicitWidth, pill.width - 54)
                text: root.statusLabel
                elide: Text.ElideRight
                font.pixelSize: 13
                font.weight: Font.Medium
                color: {
                    if (!root.interactive)
                        return Theme.onSurfaceVariant;
                    if (root.unlockState === "error")
                        return Theme.onErrorContainer;
                    if (root.unlockState === "pending")
                        return Theme.onPrimaryContainer;
                    return Theme.onSurface;
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            enabled: root.interactive
            hoverEnabled: enabled
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            focus: false

            onClicked: {
                const daemon = PluginService.pluginDaemonInstances[root.pluginId];
                if (daemon) {
                    if (root.unlockState === "pending")
                        daemon.cancelUnlock();
                    else
                        daemon.requestUnlock();
                }
                root.lockHost?.focusPasswordField?.();
            }
        }
    }
}
