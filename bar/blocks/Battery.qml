import Quickshell
import QtQuick
import Quickshell.Io
import "root:/"

// todo: make widget with expected battery (upower)

BarBlock {
    property string battery
    property bool hasBattery: false
    visible: hasBattery

    content: BarText {
        text: battery
        color: Theme.get.textColor
        font.pointSize: Theme.get.fontSize
        font.family: Theme.get.fontfamily
        font.bold: true
    }

    Process {
        id: batteryCheck
        command: ["sh", "-c", "test -d /sys/class/power_supply/BAT*"]
        running: true
        onExited: function (exitCode) {
            hasBattery = exitCode === 0;
        }
    }

    Process {
        id: batteryProc
        // Modify command to get both capacity and status in one call
        command: ["sh", "-c", "echo $(cat /sys/class/power_supply/BAT*/capacity),$(cat /sys/class/power_supply/BAT*/status)"]
        running: hasBattery

        stdout: SplitParser {
            onRead: function (data) {
                const [capacityStr, status] = data.trim().split(',');
                // waybar's full-at: a charge limit of Theme.get.fullAt reads as 100%
                const chargeLevel = Math.min(100, Math.ceil(parseInt(capacityStr) / Theme.get.fullAt * 100));
                let batteryIcon = "󰂃";
                if (chargeLevel <= 20)
                    batteryIcon = "󰁺";
                else if (chargeLevel <= 40)
                    batteryIcon = "󰁽";
                else if (chargeLevel <= 60)
                    batteryIcon = "󰁿";
                else if (chargeLevel <= 80)
                    batteryIcon = "󰂁";
                else
                    batteryIcon = "󰁹";

                const symbol = status === "Charging" ? "󰂄" : batteryIcon;
                battery = `${symbol} ${chargeLevel}%`;
            }
        }
    }

    Timer {
        interval: 1000
        running: hasBattery
        repeat: true
        onTriggered: batteryProc.running = true
    }
}
