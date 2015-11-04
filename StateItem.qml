import QtQuick 2.0
import QtGraphicalEffects 1.0

Rectangle {
    id: stateItem

    radius: 10
    width: 100
    height: 100
    color: "transparent"

    property var target

    property string label: "untitled"
    property string type: "state"

    property alias header: header
    property alias content: content

    property bool isGroup

    function typeName(obj) {
        return obj.toString().split("(")[0];
    }

    onTargetChanged: {
        label = target.objectName;

        var component = Qt.createComponent("StateItem.qml");

        if (target.children) {
            for (var i = 0; i < target.children.length; i++) {
                var child = target.children[i];
                //console.log(target.children[i].toString() + "->" + typeName(target.children[i]));

                if (typeName(child) === "State" || typeName(child) === "FinalState") {
                    var item = component.createObject(content, {"x": i * 120, "y": 0});
                    item.anchors.verticalCenter = Qt.binding(function(){return content.verticalCenter;});
                    item.height = Qt.binding(function(){return height * 0.5;});
                    //item.label = target.children[i].objectName;
                    item.target = target.children[i];

                    isGroup = true;
                }
            }
        }
    }

    states: [
        State {
            name: "dragging"
        }
    ]

    Rectangle {
        id: body
        x: parent.state === "dragging" ? -3 : 0
        y: parent.state === "dragging" ? -3 : 0

        width: parent.width
        height: parent.height

        color: "transparent"
        radius: 10

        Rectangle {
            id: header
            objectName: "header"

            clip: true
            width: parent.width
            height: 25
            color: "transparent"

            Rectangle {
                width: parent.width
                height: parent.height + radius
                radius: 10

                color: "#CCEEAA"

                Rectangle {
                    id: labelRect
                    width: parent.width
                    height: parent.height - parent.radius
                    color: "transparent"

                    Text {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: stateItem.label
                    }
                }
            }
        }

        Rectangle {
            id: content
            objectName: "content"

            clip: true
            y: header.height
            width: parent.width
            height: parent.height - header.height
            color: "transparent"

            Rectangle {
                y: -radius
                width: parent.width
                height: parent.height + radius
                radius: 10

                color: "#f9fff0"
            }
        }

        Rectangle {
            id: borderLine

            radius: parent.radius
            anchors.fill: parent

            color: "transparent"
            border.color: "#9Ab29A"
            border.width: 2

            Rectangle {
                y: header.height
                width: parent.width
                height: 2
                border.color: parent.border.color
                border.width: 2
            }
        }
    }



    Rectangle {
        width: parent.width
        height: parent.height
        radius: parent.radius
        color: "gray"

        z: -1

        opacity: 0.5

        visible: parent.state === "dragging"
    }

    Rectangle {
        width: header.width
        height: header.height

        color: "transparent"

        id: headerRect
        objectName: "headerRect"
    }
}

