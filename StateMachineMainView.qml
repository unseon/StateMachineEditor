import QtQuick 2.0

Rectangle {
    id: mainView
    color: "#ececec"

    property var targetState

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

    MouseArea {
        id: mouseController

        visible: false
        anchors.fill: parent

        onPressAndHold: {
            var item = stage.childAt(mouse.x, mouse.y);
            if (item) {
                console.log(item.label);

                var pnt = item.mapFromItem(mouseController, mouse.x, mouse.y);

                var obj = item.childAt(pnt.x, pnt.y);
                if (obj) {
                    console.log(obj.objectName);
                    if (obj.objectName === "headerRect") {
                        item.parent = mouseController;
                        item.state = "dragging";
                        drag.target = item;
                    }
                }
            }
        }
    }

    onTargetStateChanged: {
        if (targetState) {
            //var topState = stateComponent.createObject(stage, {"width": mainView.width, "height": mainView.height});
            var topState = topLevelStateComponent.createObject(stage, {"target": targetState});
            topState.width = Qt.binding(function(){return mainView.width});
            topState.height = Qt.binding(function(){return mainView.height});

        }
    }
}

