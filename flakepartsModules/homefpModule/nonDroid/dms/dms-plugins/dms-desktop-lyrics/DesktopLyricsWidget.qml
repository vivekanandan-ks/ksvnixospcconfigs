import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Modules.Plugins

DesktopPluginComponent {
    id: root

    minWidth: 200
    minHeight: 60

    LyricsSubscription {
        active: true
    }

    readonly property var controller: LyricsService.controller
    readonly property bool isMusicPlaying: controller.playing
    readonly property int activeIndex: controller.activeIndex
    readonly property var lines: controller.synced ? controller.lines : controller.plainLines
    readonly property var currentLine: (lines && activeIndex >= 0 && activeIndex < lines.length)
        ? lines[activeIndex]
        : null
    readonly property var nextLine: (lines && activeIndex + 1 < lines.length)
        ? lines[activeIndex + 1]
        : null

    readonly property real customFontSize: pluginData.fontSize ?? 22

    visible: isMusicPlaying && (controller.state === "ready" || controller.state === "instrumental")

    Column {
        anchors.centerIn: parent
        width: parent.width
        spacing: Theme.spacingXS

        Text {
            width: parent.width
            text: {
                if (controller.state === "instrumental")
                    return I18n.tr("♪ Instrumental ♪");
                return root.currentLine ? (root.currentLine.x ?? "") : "";
            }
            color: Theme.primary
            font.family: SettingsData.fontFamily
            font.pixelSize: root.customFontSize
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            visible: text !== ""
        }

        Text {
            width: parent.width
            text: root.nextLine ? (root.nextLine.x ?? "") : ""
            color: Theme.onSurfaceVariant
            opacity: 0.6
            font.family: SettingsData.fontFamily
            font.pixelSize: Math.max(12, root.customFontSize - 6)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            visible: text !== "" && controller.state !== "instrumental"
        }
    }
}
