import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem {
                text: qsTr("&Open")
                onTriggered: console.log("Open action triggered");
            }
            MenuItem {
                text: qsTr("Exit")
                onTriggered: Qt.quit();
            }
        }
    }

    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal

        Rectangle{
            id: stage
            width: 200
            Layout.maximumWidth: 400


            StateSampleButton {
                id: sampleButton
                anchors.centerIn: parent
                width: 150
                height: 50
            }
        }

        StateMachineMainView {
            targetState: sampleButton.stateMachine
            //Layout.fillWidth: true
            color: "lightgray"
        }
    }
}

