import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "root:/blocks" as Blocks
import "root:/"

Scope {
    IpcHandler {
        target: "bar"

        function toggleVis(): void {
            // Toggle visibility of all bar instances
            for (let i = 0; i < Quickshell.screens.length; i++) {
                barInstances[i].visible = !barInstances[i].visible;
            }
        }
    }

    property var barInstances: []

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            property var modelData
            screen: modelData

            Component.onCompleted: {
                barInstances.push(bar);
            }

            Rectangle {
                id: highlight
                anchors.fill: parent
                color: Theme.get.barBgColor
            }

            implicitHeight: 16

            visible: true

            anchors {
                top: true
                bottom: false
                left: true
                right: true
            }

            // Left side
            RowLayout {
                id: leftBlocks
                spacing: 10
                Layout.alignment: Qt.AlignLeft
                Layout.fillWidth: true

                Blocks.Workspaces {}
                Blocks.Submap {}
            }

            // Middle
            RowLayout {
                id: middleBlocks
                anchors.horizontalCenter: parent.horizontalCenter

                Blocks.Date {}
                Blocks.Time {}
            }

            // Right side
            RowLayout {
                id: rightBlocks
                spacing: 0
                anchors.right: parent.right

                Blocks.SystemTray {}
                Blocks.Sound {}
                Blocks.Brightness {}
                Blocks.Battery {}
            }
        }
    }
}
