import QtQuick 2.0
import ConnectionLine 1.0

ConnectionLine {
    id: transitionItem

    property var model
    property var from
    property var to

    property bool isForward
    property bool selected : false

    property bool isTransitionItem: true

    property string type: "SignalTransition"

    property var signalModel

    z: selected ? 1 : 0

    roundness: 10
    thickness: 1.5
    color: "green"

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

        if (posFrom.x < posTo.x) {
            startPoint.x = posFrom.x + from.width - 33;
            startPoint.y = posFrom.y + from.height;

            endPoint.x = posTo.x
            endPoint.y = posTo.y + 15;

            startDirection = ConnectionLine.ToVertical;
        } else {
            startPoint.x = posFrom.x;
            startPoint.y = posFrom.y + 37;

            endPoint.x = posTo.x + 33;
            endPoint.y = posTo.y + to.height;

            startDirection = ConnectionLine.ToVertical;
        }
        //console.log('from: ', from.x, from.y, from.width, from.height);
        //console.log('to: ', to.x, to.y, to.width, to.height);
        //console.log(x, y, width, height, isForward);
    }
}

