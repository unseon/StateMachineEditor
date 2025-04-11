import QtQuick
import QtQuick.Controls

BaseAnimation {
    id: root
    isGroup: false
    type: "single"

    Item {
        id: propertyEdit
        parent: root.editArea
        anchors.fill: parent
        Row {
            spacing: 2
            TextField {
                placeholderText: "target"
                height: propertyEdit.height
                width: 80
                text: root.targetItem
                onAccepted: {
                    root.targetItem = text
                }
            }

            TextField {
                placeholderText: "property"
                height: propertyEdit.height
                width: 50
                text: root.targetProperties
                onAccepted: {
                    root.targeProperties = text
                }
            }

            TextField {
                placeholderText: "duration"
                height: propertyEdit.height
                width: 50
                text: root.duration
                onAccepted: {
                    root.duration = text
                }
            }
        }
    }
}
