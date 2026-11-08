import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Hyprland
import "root:/utils" as Utils
import "root:/"

// todo: button to clear empty workspaces
// todo: highlight current workspace per monitor
// todo: highlight empty workspaces

RowLayout {
    id: root
    spacing: 0
    property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
    property int workspaceWidth: 30

    // name of the special (scratchpad) workspace open on this monitor, "" when none
    property string specialWorkspace: ""

    Rectangle {
        id: workspaceBar
        Layout.preferredWidth: Math.max(workspaceWidth, Utils.HyprlandUtils.maxWorkspace * workspaceWidth)
        Layout.preferredHeight: 16
        radius: 0

        Row {
            anchors.centerIn: parent
            spacing: workspaceWidth * 2 / 3

            Repeater {
                model: Utils.HyprlandUtils.maxWorkspace || 1

                Item {
                    required property int index
                    property bool focused: Hyprland.focusedMonitor?.activeWorkspace?.id === (index + 1)

                    implicitWidth: workspaceWidth / 3
                    height: 16
                    
                    Rectangle {
                        // this rect exists for mousearea and changing color down the line
                        visible: true
                        color: Theme.get.barBgColor
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                        }
                        height: 16
                        width: workspaceWidth

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = '${index + 1}'})`)
                        }
                    }

                    Rectangle {
                        visible: focused
                        color: "#458588"
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                        }
                        height: 16
                        width: workspaceWidth
                    }

                    Text {
                        text: (index + 1).toString()
                        color: Theme.get.textColor
                        font.pointSize: Theme.get.fontSize
                        font.bold: true
                        font.family: Theme.get.fontfamily
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        Layout.preferredWidth: workspaceWidth
        Layout.preferredHeight: 16
        visible: root.specialWorkspace !== ""
        color: "#b16286"

        Text {
            anchors.centerIn: parent
            text: root.specialWorkspace
            color: Theme.get.textColor
            font.pointSize: Theme.get.fontSize
            font.bold: true
            font.family: Theme.get.fontfamily
        }
    }

    // hyprland sends "special:NAME,MONITOR" when a scratchpad opens, ",MONITOR" when it closes
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name !== "activespecial")
                return;
            const [name, monitorName] = event.data.split(",");
            if (monitorName === root.monitor?.name)
                root.specialWorkspace = name.replace("special:", "");
        }
    }

    // the event only fires on change, so read what is already open at startup
    Process {
        command: ["hyprctl", "-j", "monitors"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const mon = JSON.parse(this.text).find(m => m.name === root.monitor?.name);
                root.specialWorkspace = (mon?.specialWorkspace?.name ?? "").replace("special:", "");
            }
        }
    }
}
