import QtQuick 2.0

Rectangle {
    id: mainView
    color: "#ececec"

    property var targetState
    property alias helper: helper
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
        id: helper

        anchors.fill: parent
        color: "transparent"
        property alias cursor: cursor

        function showCursor(item, x, y) {
            cursor.visible = true;
            var pos = helper.mapFromItem(item, x, y);

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

        MouseArea {
            id: contentRect
            visible: mainView.state === ""
            anchors.fill: parent
            propagateComposedEvents: true

            hoverEnabled: true

            onClicked: {
                console.log("contentRect clicked");
            }

            onPositionChanged: {
//                // stateMachine should be hit
//                var item = stage.childAt(mouse.x, mouse.y);

//                // find child of stateMachine rect
//                var pos = item.mapFromItem(stage, mouse.x, mouse.y);
//                var cItem = item.childAt(pos.x, pos.y);

                var hit = hitTest(stage, mouse.x, mouse.y);
                if (hit) {
                    console.log("hit on " + hit.parent.label);
                }
            }

            function hitTest(target, x, y) {
                var item = target.childAt(x, y);
                if (item) {
                    var pos = item.mapFromItem(target, x, y);
                    var childItem = item.childAt(pos.x, pos.y);

                    if (childItem.objectName === "content") {
                        var contentPos = childItem.mapFromItem(target, x, y);

                        var hitItem = hitTest(childItem, contentPos.x, contentPos.y);

                        if (hitItem) {
                            return hitItem;
                        } else {
                            //console.log('hit content of ' + item.label);
                            return childItem;
                        }

                    } else {
                        //console.log('hit header of ' + item.label);
                        return childItem;
                    }
                } else {
                    return null;
                }
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

    states: [
        State {
            name: "dragging"
        }
    ]
}

