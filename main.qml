import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.0
import QtQml.StateMachine 1.0 as DSM

ApplicationWindow {
    id: applicationWindow

    visible: true
    width: 1024
    height: 480
    title: qsTr("Hello World")

    property string fileUrl

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")

            MenuItem {
                text: qsTr("&New File")
                onTriggered: {
                    newFile();
                }
            }

            MenuItem {
                text: qsTr("&Open")
                onTriggered: {
                    console.log("Open action triggered");
                    fileDialog.visible = true;
                }
            }

            MenuItem {
                text: qsTr("&Save")
                onTriggered: {
                    mainView.save(applicationWindow.fileUrl + "_output");
                }
            }
            MenuItem {
                text: qsTr("Exit")
                onTriggered: Qt.quit();
            }
        }
    }

    property Component stateMachineComponent: Component {
        DSM.StateMachine{
            id: stateMachine

            initialState: state1
            objectName: "stateMachine"

            signal machineTest

            DSM.State {
                id: state1
                objectName: "state1"
            }
        }
    }

    function newFile() {
        stateMachineContainer.stateMachine = stateMachineComponent.createObject(stateMachineContainer);
    }

    FileDialog {
        id: fileDialog
        title: "Please choose a file"
        folder: shortcuts.home

        onAccepted: {
            console.log("You chose: " + fileDialog.fileUrl)
            var component = Qt.createComponent(fileDialog.fileUrl);
            if (component.status === Component.Ready) {

                applicationWindow.fileUrl = fileDialog.fileUrl;
                stateMachineContainer.stateMachine = component.createObject(stateMachineContainer);
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

            ToolButton {
                action: createTransitionAction

                Layout.fillWidth: false
                Layout.preferredWidth: 50
            }

            ToolButton {
                action: removeTransitionAction

                Layout.fillWidth: false
                Layout.preferredWidth: 50
            }

            Item { Layout.fillWidth: true }
        }
    }

    Action {
        id: createStateAction
        text: qsTr("Insert State");
        iconSource: "qrc:/images/images/icons/plus.png"
        onTriggered: mainView.createState();
    }

    Action {
        id: removeStateAction
        text: qsTr("Remove State");
        iconSource: "qrc:/images/images/icons/minus.png"
        onTriggered: mainView.removeState();
    }

    Action {
        id: createTransitionAction
        text: qsTr("Create Transition");
        iconSource: "qrc:/images/images/icons/plus.png"
        onTriggered: mainView.createTransition();
    }

    Action {
        id: removeTransitionAction
        text: qsTr("Create Transition");
        iconSource: "qrc:/images/images/icons/minus.png"
        onTriggered: mainView.removeSelectedTransition();
    }


    Menu {
        id: contextMenu
        title: "Edit"

        MenuItem {
            action: createStateAction
            visible: mainView.selectedItem === null
        }

        MenuItem {
            text: "Rename"
            visible: mainView.selectedItem !== null
        }

        MenuItem {
            action: removeStateAction
            visible: mainView.selectedItem !== null
        }

        MenuItem {
            text: "Change Type"
        }
    }

    Item {
        id: stateMachineContainer
        visible: false

        property var stateMachine

        onStateMachineChanged: {
            mainView.targetStateMachine = stateMachine;
        }
    }

    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal

        SignalListView {
            id: signalView

            width: 100
            model: mainView.signals

        }

        StateMachineMainView {
            id: mainView
            //targetState: sampleButton.stateMachine
            //Layout.fillWidth: true
            color: "lightgray"

            Component.onCompleted: {
                //targetState = sampleButton.stateMachine;
            }
        }
    }
}

