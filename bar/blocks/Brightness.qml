import QtQuick
import Quickshell.Io
import "root:/"

BarBlock {
    id: root
    property real brightness

    content: BarText {
        text: "󰃠 " + Math.round(brightness) + "%"
        // todo: make that ^ better
        color: Theme.get.textColor
        font.pointSize: Theme.get.fontSize
        font.family: Theme.get.fontfamily
        font.bold: true
    }

    Process {
        command: ["sh", "-c", "udevadm monitor --subsystem-match=backlight --udev"]
        running: true
        stdout: SplitParser {
            onRead: if (!setBrightness.running && !root.pending) updateBrightness.running = true
        }
    }

    Process {
        id: updateBrightness
        command: ["sh", "-c", "brightnessctl -m"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const value = Number(this.text.split(",")[3].replace("%", ""));
                // ignore readbacks that match what we already show, so a scroll
                // remainder like 50.4 isn't rounded away between wheel events
                if (Math.round(root.brightness) !== value)
                    root.brightness = value;
            }
        }
    }

    // a wheel event arrives every few ms, so writes are throttled and the last
    // value wins, instead of spawning a brightnessctl per event
    property bool pending: false
    function apply() {
        pending = true;
        if (!throttle.running)
            flush();
    }
    function flush() {
        if (setBrightness.running) {
            throttle.restart();
            return;
        }
        pending = false;
        setBrightness.exec(["brightnessctl", "-q", "set", Math.round(brightness) + "%"]);
        throttle.restart();
    }

    Timer {
        id: throttle
        interval: 25
        onTriggered: if (root.pending) root.flush()
    }

    Process {
        id: setBrightness
    }

    MouseArea {
        anchors.fill: parent
        onWheel: function(event) {
            brightness = Math.max(0, Math.min(100, brightness + (event.angleDelta.y * -1 / 120)))
            root.apply()
        }
        // onWheel: function(event) {
            //         sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + (event.angleDelta.y * -1 / 120) * 0.05))
            // }
        }
}
