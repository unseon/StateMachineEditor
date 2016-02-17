import QtQuick 2.0
import QtQuick.Controls 1.4

Rectangle {
    id: signalListMain

    signal closed

    property alias model: listView.model

    Rectangle {
        id: header
        width: parent.width
        height: 50

        color: "yellow"

        Button {
            id: btnclose

            anchors.centerIn: parent
            text: "close"

            onClicked: {
                closed();
            }
        }
    }

    Rectangle {
        id: body
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        color: "gray"

        ListView {
            id: listView

            anchors.fill: parent
            clip: true

            delegate: Rectangle {
                width: listView.width
                height: 40

                border.color: "gray"

                color: listView.currentIndex === model.index ? "yellow" : "white"

                TextInput {
                    anchors.fill: parent
                    anchors.margins: 5

                    text: model.name

                    verticalAlignment: Text.AlignVCenter

                    onTextChanged: {
                        listView.model.get(index).name = text;
                    }

                    onFocusChanged: {
                        if (focus) {
                            listView.currentIndex = model.index;
                        }
                    }
                }
            }

            footer: Rectangle {
                width: listView.width
                height: 40

                Button {
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                    }

                    width: parent.width / 2

                    text: "+"

                    onClicked: {
                        listView.model.append({name:"signal"});
                    }
                }

                Button {
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                    }

                    x: parent.width / 2
                    width: parent.width / 2

                    text: "-"

                    onClicked: {
                        listView.model.remove(listView.currentIndex);
                    }
                }
            }
        }
    }
}

