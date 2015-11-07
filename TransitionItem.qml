import QtQuick 2.0

Item {
    id: transitionItem

    property var model
    property var from
    property var to

    onModelChanged: {
        from = stateMachineItem.getItemFromModel(model.sourceState);
        to = stateMachineItem.getItemFromModel(model.targetState);

        var posFrom = mainView.transitionLayer.mapFromItem(from, 0, 0);
        var posTo = mainView.transitionLayer.mapFromItem(to, 0, 0);

        if (from.x < to.x) {
            x = posFrom.x + from.width;
            y = posFrom.y + 35;
            width = posTo.x + to.width * 1 / 3 - x;
            height = posTo.y - y;
        } else {
            x = posTo.x + to.width;
            y = posTo.y + 12;
            width = posFrom.x + from.width * 2 / 3 - x;
            height = posFrom.y - y;
        }
    }

//    Rectangle {
//        id: horizontalLine
//        height: 2
//        width: parent.width
//        border.width: 2
//        border.color: "black"
//    }

//    Rectangle {
//        id: verticalLine
//        x: parent.width - border.width - 10
//        width: 2
//        height: parent.height
//        border.width: 2
//    }

    Rectangle {

        width: parent.width + 1
        height: parent.height

        clip: true
        color: "transparent"

        Rectangle {
            x: - radius

            width: transitionItem.width + radius
            height: transitionItem.height + radius
            radius: 10

            color: "transparent"
            border.width: 2
        }
    }

    Image {
        x: parent.width - width / 2 - 2
        y: parent.height - height * 2 / 3

        width: 20
        height: 20
        source: "qrc:/images/images/triangle-down.png"

        fillMode: Image.PreserveAspectFit
    }
}

