import QtQuick 2.0

Rectangle {
    id: mainView
    color: "#ececec"

    property var targetState
    property var stateMachineItem

    property alias helper: helper
    property alias mouseHelper: mouseHelper
    property alias curosr: cursor

    property Component stateMachineComponent: Component {
        StateMachineItem{

        }
    }

    onTargetStateChanged: {
        if (targetState) {
            //var topState = stateComponent.createObject(stage, {"width": mainView.width, "height": mainView.height});
            stateMachineItem = stateMachineComponent.createObject(stage);//, {"target": targetState});
            stateMachineItem.zoomed = true;
            stateMachineItem.target = targetState;
            stateMachineItem.width = Qt.binding(function(){return mainView.width});
            stateMachineItem.height = Qt.binding(function(){return mainView.height});
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
    }

    MouseArea {
        id: mouseHelper
        anchors.fill: parent
        propagateComposedEvents: true

        hoverEnabled: true

        drag.target: null
        drag.axis: Drag.XAndYAxis

        property var focusedContent

        property var originContainer

        function getHit(x, y) {
            return hitTest(stage, x, y);
        }

        onClicked: {
            var hit = getHit(mouse.x, mouse.y);

            if (hit.objectName === "content") {
                updateCursor(mouse);
            }
        }

        onPressAndHold: {
            var hit = getHit(mouse.x, mouse.y);

            // ready to drag when hit hreaderRect
            if (hit.objectName === "headerRect") {
                var stateItem = hit.parent;
                console.log( stateItem.label + " has long tapped.");

                stateItem.state = "dragging";

                originContainer = stateItem.parent;
                focusedContent = stateItem.parent;

                // parenting to helper
                var pos = hit.mapToItem(mainView.helper, 0, 0);
                stateItem.parent = mainView.helper;
                stateItem.x = pos.x;
                stateItem.y = pos.y;

                drag.target = stateItem;
                console.log("drag: " + drag.active + "/ target: " + stateItem.label);

                cursor.state = "dragging";

                updateCursor(mouse);
            }
        }

        onReleased: {
            console.log("released");

            // drop to content if possible
            if (drag.active) {
                dropToContent(focusedContent);
                cursor.state = "";
            }

            updateCursor(mouse);
        }

        onPositionChanged: {
            if (drag.active) {
                updateCursor(mouse);
                focusedContent = cursor.currentContent;
            }
        }

        function updateCursor(mouse) {
            var hit = getHit(mouse.x, mouse.y);
            var stateItem = hit.parent;

            // update when hit content
            if (hit.objectName === "content") {
                var content = hit;

                cursor.visible = true;
                cursor.currentContent = content;

                // calculate cursor position
                var pos = mapToItem(content, mouse.x, mouse.y);
                var idx = content.calcIndex(pos.x);
                cursor.currentIndex = idx;
                cursor.updatePosition();
            }
        }

        function dropToContent(content) {
            var stateItem = drag.target;

            content.insertChild(stateItem);

            originContainer.updateLayout();

            content.state = "";
            stateItem.state = "";

            drag.target = null;
            focusedContent = null;
        }

        // return hitted content or headerRect
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

        Item {
            id: cursor

            visible: true

            property var currentContent
            property int currentIndex

            Component.onCompleted: {
                currentContent = mainView.stateMachineItem.content;
                currentIndex = 0;
                updatePosition();
            }

            function updatePosition() {
                var content = currentContent;
                var idx = currentIndex;
                var localX, localY;
                if (idx === 0) {
                    localX = 5;
                    localY = 5;
                } else {
                    localX = content.children[idx - 1].x + content.children[idx - 1].width;
                    localY = content.children[idx - 1].y + content.children[idx - 1].height;
                }

                var helperPos = mouseHelper.mapFromItem(content, localX, localY);

                cursor.x = helperPos.x;
                cursor.y = helperPos.y;
            }

            Rectangle {
                id: cursorShape

                x: -2
                y: -2

                color: "red"

                width: 5
                height: 5
            }

            SequentialAnimation {
                id: blinkAnim
                loops: Animation.Infinite
                running: cursor.state === ""
                NumberAnimation {
                    target: cursor
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: 150
                }

                PauseAnimation {
                    duration: 500
                }

                NumberAnimation {
                    target: cursor
                    property: "opacity"
                    from: 1.0
                    to: 0.0
                    duration: 150
                }

                PauseAnimation {
                    duration: 200
                }

                onStopped: {
                    cursor.opacity = 1.0;
                }
            }
        }
    }
}

