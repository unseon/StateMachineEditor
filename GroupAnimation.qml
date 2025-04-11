import QtQuick
import QtQuick.Controls

BaseAnimation {
    id: root

    Item {
        id: propertyEdit
        parent: root.editArea
        anchors.fill: parent
        Row {
            spacing: 2

            Switch {
                text: checked ? "Parallel" : "Sequential"

                y: 2
                height: propertyEdit.height - 4

                onCheckedChanged: {
                    root.isParallel = checked
                }
            }
        }
    }
}
