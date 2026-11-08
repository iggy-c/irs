import QtQuick
import Quickshell
import "root:/"

BarBlock {
    id: text
    content: BarText {
        text: Qt.formatDateTime(clock.date, "MM-dd-yyyy")
        color: Theme.get.textColor
        font.pointSize: Theme.get.fontSize
        font.family: Theme.get.fontfamily
        font.bold: true
    }

    SystemClock {
      id: clock
      precision: SystemClock.Minutes
    }
}

