import QtQuick 2.0

Rectangle {
    id: mainView
    color: "#ececec"

    property var targetState
    property var stateMachineItem

    property alias helper: helper
    property alias mouseHelper: mouseHelper
    property alias curosr: cursor
    property alias transitionLayer: transitionLayer

    property Component stateMachineComponent: Component {
        StateMachineItem{

        }
    }

    property Component stateItemComponent: Component {
        StateItem{

        }
    }

    property Component transitionComponent: Component {
        TransitionItem {

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

            stateMachineItem.buildTransitionTable();

            for (var i = 0; i < stateMachineItem.transitionTable.length; i++) {
                var transitionModel = stateMachineItem.transitionTable[i];
                var transitionItem = transitionComponent.createObject(transitionLayer);
                transitionItem.model = transitionModel;
            }

            updateLayout();
        }
    }

    function createState() {
        var stateItem = stateItemComponent.createObject(stage);
        stateItem.label = "new state";
        cursor.currentContent.insertChildAt(stateItem, cursor.currentIndex);

        updateLayout();
    }

    function updateLayout() {
        stateMachineItem.updateLayout();

        for (var i = 0; i < transitionLayer.children.length; i++) {
            var transitionItem = transitionLayer.children[i];
            transitionItem.update();
        }
    }

    Rectangle {
        id: stage
        color: "#FBFFFA"
        anchors.fill: parent
    }

    Rectangle {
        id: transitionLayer

        opacity: mainView.state === "dragging" ? 0.2 : 1.0
        color: "transparent"
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
                mainView.state = "dragging";

                updateCursor(mouse);
            }
        }

        onReleased: {
            console.log("released");

            // drop to content if possible
            if (drag.active) {
                dropToContent(focusedContent);
                updateLayout();
                cursor.state = "";
                mainView.state = "";
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

            if (hit) {
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
        }

        function dropToContent(content) {
            var stateItem = drag.target;

            cursor.currentContent.insertChildAt(stateItem, cursor.currentIndex);

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

//            Behavior on x {
//                NumberAnimation { duration: 100 }
//            }

//            Behavior on y {
//                NumberAnimation { duration: 100 }
//            }

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

