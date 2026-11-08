import QtQuick
import Quickshell.Io
import Quickshell.Hyprland
import "root:/"

BarBlock {
    id: root
    property string submapName
    visible: submapName !== ""
    color: "orange"

    content: BarText {
        text: submapName
        color: "black"
        font.pointSize: Theme.get.fontSize
        font.family: Theme.get.fontfamily
        font.bold: true
    }

    // hyprland sends the submap name on entry and an empty one on reset
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "submap")
                root.submapName = event.data;
        }
    }

    // the event only fires on change, so read the current submap once at startup
    Process {
        command: ["hyprctl", "submap"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const name = this.text.trim();
                root.submapName = name === "default" ? "" : name;
            }
        }
    }
}
