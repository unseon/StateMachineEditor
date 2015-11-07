import QtQuick 2.0

Rectangle {
    id: mainView
    color: "#ececec"

    property var targetState
    property var stateMachineItem

    property alias helper: helper
    property alias mouseHelper: mouseHelper

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

//            onClicked: {
//                var hit = getHit(mouse.x, mouse.y);
//            }

            onPressAndHold: {
                var hit = getHit(mouse.x, mouse.y);
                if (hit.objectName === "headerRect") {
                    var stateItem = hit.parent;
                    console.log( stateItem.label + " has long tapped.");

                    stateItem.state = "dragging";

                    originContainer = stateItem.parent;
                    focusedContent = originContainer;

                    // parenting to helper
                    var pos = hit.mapToItem(mainView.helper, 0, 0);
                    stateItem.parent = mainView.helper;
                    stateItem.x = pos.x;
                    stateItem.y = pos.y;

                    drag.target = stateItem;
                    console.log("drag: " + drag.active + "/ target: " + stateItem.label);
                }
            }

            onReleased: {
                console.log("released");

                var hit = getHit(mouse.x, mouse.y);
                var stateItem = hit.parent;

                // drop to content if possible
                if (drag.active && hit.objectName === "content") {
                    var content = hit;
                    dropToContent(content);
                }
            }

            onPositionChanged: {
                var hit = getHit(mouse.x, mouse.y);
                var stateItem = hit.parent;

                if (hit.objectName === "content") {
                    var content = hit

                    var pos = mapToItem(content, mouse.x, mouse.y);

                    var idx = content.calcIndex(pos.x);

                    var posX, posY;

                    if (idx === 0) {
                        posX = 0;
                        posY = 0;
                    } else {
                        posX = content.children[idx - 1].x + content.children[idx - 1].width;
                        posY = content.children[idx - 1].y + content.children[idx - 1].height;
                    }

                    mainView.helper.showCursor(content, posX, posY);

                    //console.log(stateItem.label + ": " + content.calcIndex(pos.x) + " / content.y: " + content.y);

                    if (drag.active) {
                        focusedContent = content;
                    }
                }
            }

            function dropToContent(content) {
                var stateItem = drag.target;

                content.insertChild(drag.target);

                mainView.helper.cursor.visible = false;

                content.state = "";
                drag.target.state = "";

                drag.target = null;

                originContainer.updateLayout();

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

        }
    }
}

