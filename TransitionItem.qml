import QtQuick 2.0

Item {
    id: transitionItem

    property var model
    property var from
    property var to

    property bool isForward

    onModelChanged: {
        from = mainView.getStateItemFromModel(model.sourceState);
        to = mainView.getStateItemFromModel(model.targetState);
    }

    function update() {
        var posFrom = mainView.transitionLayer.mapFromItem(from, 0, 0);
        var posTo = mainView.transitionLayer.mapFromItem(to, 0, 0);

        if (from.x < to.x) {
            x = posFrom.x + from.width - 33;
            y = posFrom.y + from.height;
            width = posTo.x - x;
            height = posTo.y + 15 - y;

            isForward = true;
        } else {
            x = posTo.x + 33;
            y = posTo.y + to.height;
            width = posFrom.x - x;
            height = posFrom.y + 37 - y;
            isForward = false;
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
            y: - radius

            width: transitionItem.width + radius
            height: transitionItem.height + radius
            radius: 20

            color: "transparent"
            border.width: 2
            border.color: "#39a276"
        }
    }

    Image {
        id: triangleDown

        visible: parent.isForward

        x: parent.width - width / 2 - 2
        y: parent.height - height * 2 / 3 + 3

        width: 20
        height: 20
        source: "qrc:/images/images/triangle-right.png"

        fillMode: Image.PreserveAspectFit
    }

    Image {
        id: triangleUp

        visible: !parent.isForward

        x: -width / 2
        y: -height * 2 / 3 + 7

        width: 20
        height: 20
        source: "qrc:/images/images/triangle-up.png"

        fillMode: Image.PreserveAspectFit
    }
}

