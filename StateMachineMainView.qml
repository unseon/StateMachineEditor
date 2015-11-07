import QtQuick 2.0

Rectangle {
    id: mainView
    color: "#ececec"

    property var targetState
    property alias draggingLayer: draggingLayer
    property var dropTarget

    signal stateItemLongTabbed(var sender, var mouse)

    property Component stateComponent: Component {
        StateItem{

        }
    }

    property Component topLevelStateComponent: Component {
        TopLevelStateItem{

        }
    }

    Rectangle {
        id: stage
        color: "#FBFFFA"
        anchors.fill: parent
    }

    Rectangle {
        id: draggingLayer

        anchors.fill: parent
        color: "transparent"
        property alias cursor: cursor

        function showCursor(item, x, y) {
            cursor.visible = true;
            var pos = draggingLayer.mapFromItem(item, x, y);

            console.log('cursor pos: ' + pos + 'from ' + x + "," + y + "/item pos: " + item.x + ", " + item.y);
            cursor.x = pos.x;
            cursor.y = pos.y;
        }

        Item {
            id: cursor

            visible: false

            Rectangle {
                x: -2
                y: -2

                color: "red"

                width: 5
                height: 5
            }
        }
    }

    onStateItemLongTabbed: {
        console.log("signal received");
        //sender.parent = draggingLayer;
    }

    onTargetStateChanged: {
        if (targetState) {
            //var topState = stateComponent.createObject(stage, {"width": mainView.width, "height": mainView.height});
            var topState = topLevelStateComponent.createObject(stage);//, {"target": targetState});
            topState.zoomed = true;
            topState.target = targetState;
            topState.width = Qt.binding(function(){return mainView.width});
            topState.height = Qt.binding(function(){return mainView.height});
        }
    }
}

