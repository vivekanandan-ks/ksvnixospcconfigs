pragma ComponentBehavior: Bound

import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    Component.onCompleted: {
        DgopService.addRef(["network"]);
    }
    Component.onDestruction: {
        DgopService.removeRef(["network"]);
    }

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

    horizontalBarPill: Component {
        Item {
            implicitWidth: col.implicitWidth
            implicitHeight: root.widgetThickness

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

    verticalBarPill: Component {
        Item {
            implicitWidth: root.widgetThickness
            implicitHeight: vcol.implicitHeight

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
