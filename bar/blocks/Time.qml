import QtQuick
import Quickshell
import "root:/"

BarBlock {
    id: text
    content: BarText {
        text: Qt.formatDateTime(clock.date, "h:mm AP")
        // https://doc.qt.io/qt-6/qml-qtqml-qt.html#formatDateTime-method
        color: Theme.get.textColor
        font.pointSize: Theme.get.fontSize
        font.family: Theme.get.fontfamily
        font.bold: true
    }

    SystemClock {
      id: clock
      precision: SystemClock.Seconds
    }
}

