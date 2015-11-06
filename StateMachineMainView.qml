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
    }

    onStateItemLongTabbed: {
        console.log("signal received");
        //sender.parent = draggingLayer;
    }

    onTargetStateChanged: {
        if (targetState) {
            //var topState = stateComponent.createObject(stage, {"width": mainView.width, "height": mainView.height});
            var topState = topLevelStateComponent.createObject(stage);//, {"target": targetState});
            topState.target = targetState;
            topState.width = Qt.binding(function(){return mainView.width});
            topState.height = Qt.binding(function(){return mainView.height});
        }
    }
}

