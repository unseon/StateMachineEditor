import QtQuick 2.0
import ConnectionLine 1.0

ConnectionLine {
    id: transitionItem

    property var model
    property var from
    property var to

    property bool isForward
    property bool selected : false

    onSelectedChanged: {
        console.log("selectedChanged");
    }

    property bool isTransitionItem: true

    property string type: "SignalTransition"

    property var signalModel

    z: selected ? 1 : 0

    roundness: 20
    thickness: 1.5
    color: selected ? "yellow" : "green"

    function typeName(obj) {
        return obj.toString().split("(")[0].split("_")[0];
    }

    onModelChanged: {
        from = mainView.getStateItemFromModel(model.sourceState);
        to = mainView.getStateItemFromModel(model.targetState);

        type = typeName(model);
        objectName = model.objectName;
    }

    function update() {

        var posFrom = mainView.transitionLayer.mapFromItem(from, 0, 0);
        var posTo = mainView.transitionLayer.mapFromItem(to, 0, 0);

        var commonAncestor = findCommonAncestor(from, to);

        if (commonAncestor === from) {
            //
            startPoint.x = posFrom.x + 40;
            startPoint.y = posFrom.y + from.content.y;

            endPoint.x = posTo.x;
            endPoint.y = posTo.y + 15;

            startDirection = ConnectionLine.ToVertical;

        } else if (commonAncestor === to){
            startPoint.x = posFrom.x;
            startPoint.y = posFrom.y + 33;

            endPoint.x = posTo.x + 20;
            endPoint.y = posTo.y + to.content.y;

            startDirection = ConnectionLine.ToHorizontal;

        } else if (posFrom.x < posTo.x) {
            startPoint.x = posFrom.x + from.width - 33;
            startPoint.y = posFrom.y + from.height;

            endPoint.x = posTo.x
            endPoint.y = posTo.y + 15;

            startDirection = ConnectionLine.ToVertical;
            console.log("forward: ", startPoint, endPoint, startDirection);
        } else {
            startPoint.x = posFrom.x;
            startPoint.y = posFrom.y + 33;

            endPoint.x = posTo.x + 33;
            endPoint.y = posTo.y + to.height;

            startDirection = ConnectionLine.ToHorizontal;

            console.log("backward: ", startPoint, endPoint, startDirection);
        }


        //console.log('from: ', from.x, from.y, from.width, from.height);
        //console.log('to: ', to.x, to.y, to.width, to.height);
        //console.log(x, y, width, height, isForward);
    }

    function findCommonAncestor(stateA, stateB) {
        // calculate level of state node

        var levelA = 0;
        var curStateA = stateA;
        while (curStateA) {
//            console.log(curStateA.label);
            curStateA = curStateA.parentStateItem;
            levelA++;
        }

        var levelB = 0;
        var curStateB = stateB;
        while (curStateB) {
//            console.log(curStateB.label);
            curStateB = curStateB.parentStateItem;
            levelB++;
        }

        // move deeper state to same level of the other

        curStateA = stateA;
        curStateB = stateB;

        if (levelA > levelB) {
            for (var i = 0; i < levelA - levelB; i++) {
                curStateA = curStateA.parentStateItem;
            }
        } else if (levelB > levelA) {
            for (var i = 0; i < levelB - levelA; i++) {
                curStateB = curStateB.parentStateItem;
            }
        }

        // find same ancestor by iterating

        while (curStateA !== curStateB) {

            curStateA = curStateA.parentStateItem;
            curStateB = curStateB.parentStateItem;
        }

        console.log("common ancester: ", curStateA.label);

        return curStateA;
    }
}

