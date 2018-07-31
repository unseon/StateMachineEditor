import QtQuick 2.0
import Qt.labs.folderlistmodel 2.11
import QtQuick.Controls 1.4

SplitView {

    orientation: Qt.Horizontal

    ListView {
        id: listView
        width: 200; height: 400

        FolderListModel {
            id: folderModel
            nameFilters: ["*.qml"]
            folder: "file:///Users/unseon/project/SampleQml"
        }

        Component {
            id: fileDelegate
            Text { text: fileName }
        }

        model: folderModel
        delegate: Rectangle {
            width: listView.width
            height: 20

            color: listView.currentIndex == index ? "#DDDDFF" : "transparent"

            Text {
                anchors.fill: parent
                text: fileName
            }

            MouseArea {
                anchors.fill: parent
                onPressed: {
                    listView.currentIndex = index;

                    console.log("folder list model select: " + fileURL);
                }
            }
        }
    }


    Rectangle {
        height: parent.height

        Image {
            anchors.fill: parent

            source: "image://colors//Users/unseon/project/SampleQml/SampleView01.qml"
            sourceSize: Qt.size(400, 300)
        }
    }
}
