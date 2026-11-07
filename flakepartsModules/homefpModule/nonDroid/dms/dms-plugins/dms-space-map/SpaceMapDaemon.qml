import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root

    property bool isOpen: false

    function toggle() {
        if (isOpen) close();
        else open();
    }

    function open() {
        isOpen = true;
    }

    function close() {
        isOpen = false;
    }

    IpcHandler {
        target: "spaceMap"

        function toggle(): string {
            root.toggle();
            return root.isOpen ? "OPENED" : "CLOSED";
        }

        function open(): string {
            root.open();
            return "OPENED";
        }

        function close(): string {
            root.close();
            return "CLOSED";
        }
    }

    LazyLoader {
        id: overlayLoader
        active: root.isOpen

        Overview {
            id: overview
            onDone: root.isOpen = false
        }
    }
}
