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

    toolBar: ToolBar {
        RowLayout {
            anchors.fill: parent
            ToolButton {
                action: createStateAction

                Layout.fillWidth: false
                Layout.preferredWidth: 50
            }

            ToolButton {
                action: removeStateAction
                Layout.fillWidth: false
                Layout.preferredWidth: 50
            }

            Item { Layout.fillWidth: true }
        }
    }

    Action {
        id: removeStateAction
        text: qsTr("Remove State");
        iconSource: "qrc:/images/images/icons/minus.png"
    }

    Action {
        id: createStateAction
        text: qsTr("Insert State");
        iconSource: "qrc:/images/images/icons/plus.png"
        onTriggered: mainView.createState();
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
            id: mainView
            targetState: sampleButton.stateMachine
            //Layout.fillWidth: true
            color: "lightgray"
        }
    }
}

