import QtQuick
import QtQuick.Controls

BaseAnimation {
    id: root

    property var parentAnimation: null
    headerRect.visible: false

    property string from
    property string to

    objectName: "Transition"
    isRoot: true

    Item {
        id: propertyEdit
        parent: root.editArea
        anchors.fill: parent
        Row {
            spacing: 2
            TextField {
                placeholderText: "from"
                height: propertyEdit.height
                width: 80
                text: root.from
                onAccepted: {
                    root.from = text
                }
            }

            TextField {
                placeholderText: "to"
                height: propertyEdit.height
                width: 80
                text: root.to
                onAccepted: {
                    root.to = text
                }
            }
        }
    }

}

