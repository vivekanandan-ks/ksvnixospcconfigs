import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property bool isCapped: false
    property string statusText: "..."

    // Native DMS Control Center integration
    ccWidgetIcon: isCapped ? "battery_saver" : "battery_charging_full"
    ccWidgetPrimaryText: "Battery Limit"
    ccWidgetSecondaryText: statusText
    ccWidgetIsActive: isCapped

    function refreshStatus() {
        if (!statusProc.running) {
            statusProc.running = true
        }
    }

    onCcWidgetToggled: {
        Quickshell.execDetached(["battery-limit", "toggle"])
        refreshTimer.restart()
    }

    Component.onCompleted: {
        refreshStatus()
    }

    Process {
        id: statusProc
        command: ["battery-limit", "--short"]
        running: false

        stdout: SplitParser {
            onRead: function(data) {
                var out = data.trim()
                if (out.indexOf("60%") !== -1 || out.indexOf("80%") !== -1 || out.indexOf("🛡️") !== -1) {
                    root.isCapped = true
                    root.statusText = out
                } else if (out.indexOf("100%") !== -1 || out.indexOf("⚡") !== -1) {
                    root.isCapped = false
                    root.statusText = out
                } else {
                    root.statusText = out
                }
            }
        }
    }

    Timer {
        id: refreshTimer
        interval: 1000
        running: false
        repeat: false
        onTriggered: root.refreshStatus()
    }

    Timer {
        id: autoPollTimer
        interval: 10000
        running: true
        repeat: true
        onTriggered: root.refreshStatus()
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                name: root.isCapped ? "battery_saver" : "battery_charging_full"
                color: root.isCapped ? Theme.primary : Theme.surfaceVariantText
                size: Theme.iconSize - 4
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.statusText
                color: root.isCapped ? Theme.primary : Theme.surfaceVariantText
                font.pixelSize: Theme.fontSizeMedium
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
