pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property Item get: custom

    Item {
        id: custom
        property string barBgColor: "#282828"
        property string textColor: "#EBDBB2"
        property bool buttonBorderShadow: true
        property int fontSize: 10
        property string fontfamily: "Fira Code Mono"
        property int fullAt: 79
    }
}
