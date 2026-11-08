import QtQuick
import Quickshell.Services.Pipewire
import "root:/"

BarBlock {	
    id: root
    property PwNode node: Pipewire.defaultAudioSink;
    PwObjectTracker { objects: [ node ] }

    content: BarText {
        text: `${node?.audio?.muted ? "󰖁" : "󰕾"} ${Math.round(node.audio.volume * 100)}%`
        color: Theme.get.textColor
        font.pointSize: Theme.get.fontSize
        font.family: Theme.get.fontfamily
        font.bold: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: node?.audio && (node.audio.muted = !node.audio.muted)
        onWheel: function (event) {
            if (node?.audio) {
                node.audio.volume = Math.max(0, Math.min(1, node.audio.volume + (event.angleDelta.y * -1 / 120) * 0.01));
            }
        }
    }
}

