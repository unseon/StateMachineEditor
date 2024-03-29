import QtQuick 2.5
import QtQuick.Controls 2
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0
import QtQuick.Dialogs
//import QtQml.StateMachine 1.0 as DSM
import FFaniStateMachine 1.0 as FSM

ApplicationWindow {
    id: applicationWindow

    visible: true
    width: 1024
    height: 480
    title: fileUrl ? fileUrl : "(Empty)"

    property string fileUrl

    MenuBar {
        id: basicMenuBar
        Menu {
            title: qsTr("File")

            MenuItem {
                text: qsTr("&New File")
//                shortcut: "Ctrl+N"
                onTriggered: {
                    newFile();
                }
            }

            MenuItem {
                text: qsTr("&Open...")
//                shortcut: "Ctrl+O"
                onTriggered: {
                    console.log("Open action triggered");
                    fileDialog.visible = true;
                }
            }

            MenuItem {
                text: qsTr("&Save...")
//                shortcut: "Ctrl+S"
                onTriggered: {

                    if (applicationWindow.fileUrl) {
                        mainView.save(applicationWindow.fileUrl);
                    } else {
                        saveFileDialog.visible = true;
                    }
                }
            }

            MenuItem {
                text: qsTr("Save As...")
//                shortcut: "Shift+Ctrl+S"
                onTriggered: {
                    saveFileDialog.visible = true;
                }
            }

            MenuItem {
                text: qsTr("&Export to JSON...")
                onTriggered: {
                    mainView.exportToJson("/Users/unseon/output.json");
                }
            }

        }
    }

    property Component stateMachineComponent: Component {
        FSM.StateMachine{
            id: stateMachine

            initialState: state1
            objectName: "stateMachine"

            FSM.State {
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
        //currentFolder: shortcuts.home

        onAccepted: {
            console.log("You chose: " + fileDialog.fileUrl);
            var text = fileIo.read(fileDialog.fileUrl);
            console.log(text.length);

            applicationWindow.fileUrl = fileDialog.fileUrl;
            stateMachineContainer.stateMachine = Qt.createQmlObject(text, stateMachineContainer);
        }
    }

    FileDialog {
        id: saveFileDialog
        title: "Save File As"
        //currentFolder: shortcuts.home


        //selectExisting: false
        onAccepted: {
            console.log("You chose: " + fileUrl)
            mainView.save(fileUrl);

            applicationWindow.fileUrl = fileUrl;
        }
    }

    header: ToolBar {
        visible: mainView.targetStateMachine
        RowLayout {
            anchors.fill: parent

            ToolButton {
                //action: createStateAction

                Layout.fillWidth: false
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50

                Image {
                    anchors.fill: parent
                    source: "qrc:/images/images/icons/icon_create_state.svg"
                    fillMode: Image.PreserveAspectFit

                    sourceSize.width: width
                    sourceSize.height: height
                }

                onClicked: {
                    createStateAction.trigger();
                }
            }

            ToolButton {
                //action: removeStateAction
                Layout.fillWidth: false
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50

                Image {
                    anchors.fill: parent
                    source: "qrc:/images/images/icons/icon_delete_state.svg"
                    fillMode: Image.PreserveAspectFit

                    sourceSize.width: width
                    sourceSize.height: height
                }

                onClicked: {
                    removeStateAction.trigger();
                }
            }

            ToolButton {
                //action: createTransitionAction

                Layout.fillWidth: false
                Layout.preferredWidth: 50

                Image {
                    anchors.fill: parent
                    source: "qrc:/images/images/icons/icon_create_transition.svg"
                    fillMode: Image.PreserveAspectFit

                    sourceSize.width: width
                    sourceSize.height: height
                }

                onClicked: {
                    createTransitionAction.trigger();
                }
            }

            ToolButton {
                //action: removeTransitionAction

                Layout.fillWidth: false
                Layout.preferredWidth: 50

                Image {
                    anchors.fill: parent
                    source: "qrc:/images/images/icons/icon_delete_transition.svg"
                    fillMode: Image.PreserveAspectFit

                    sourceSize.width: width
                    sourceSize.height: height
                }

                onClicked: {
                    removeTransitionAction.trigger();
                }
            }

            Item { Layout.fillWidth: true }
        }
    }

    Action {
        id: createStateAction
        text: qsTr("Insert State");
        //iconSource: "qrc:/images/images/icons/icon_create_state.svg"
        onTriggered: mainView.createState();
    }

    Action {
        id: removeStateAction
        text: qsTr("Remove State");
        icon.source: "qrc:/images/images/icons/icon_delete_state.svg"
        onTriggered: mainView.removeState();
    }

    Action {
        id: createTransitionAction
        text: qsTr("Create Transition");
        icon.source: "qrc:/images/images/icons/plus.png"
        onTriggered: mainView.createTransition();
    }

    Action {
        id: removeTransitionAction
        text: qsTr("Create Transition");
        icon.source: "qrc:/images/images/icons/minus.png"
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

    Menu {
        id: transitionContextMenu
        title: "Transition Menu"

        MenuSeparator {

        }

        Menu {
            id: signalAssign
            title: "Assign Signal"

            Instantiator {
                model: mainView.signals

                MenuItem {
                    text: model.name
                    onTriggered: mainView.assignSignal(model)
                }

                onObjectAdded: signalAssign.insertItem(index, object)
                onObjectRemoved: signalAssign.removeItem(object)
            }
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

    Rectangle {
        anchors.fill: parent
        visible: !mainView.targetStateMachine

        Button {
            text: "New File"
            anchors.centerIn: parent
            onClicked: {
                newFile();
            }
        }
    }

    Window {
        id: headTap
        //x: applicationWindow.x + 100

        property int titleBarHeight: 22


        width: applicationWindow.width - 400
        height: titleBarHeight

        color: "#20DD0020"

        flags: Qt.SubWindow

        Component.onCompleted: {
            x = applicationWindow.x + 100;
            y = applicationWindow.y - titleBarHeight;
            visible = false;
        }

        MouseArea {
            anchors.fill: parent
            property point orgPos: "0, 0"

            onPressed: {
                orgPos.x = mouse.x;
                orgPos.y = mouse.y;
            }

            onPositionChanged: {
                headTap.x += mouse.x - orgPos.x;
                headTap.y += mouse.y - orgPos.y;
                applicationWindow.x = headTap.x - 100;
                applicationWindow.y = headTap.y + headTap.height;
            }
        }

        Item {
            anchors.fill: parent
            Row {
                anchors.fill: parent
                Rectangle {
                    width: 100
                    height: parent.height
                    color: "yellow"

                    radius: 4
                    border.width: 1
                }

                Rectangle {
                    width: 100
                    height: parent.height
                    color: "yellow"

                    radius: 4
                    border.width: 1

                }

                Rectangle {
                    width: 100
                    height: parent.height
                    color: "yellow"

                    radius: 4
                    border.width: 1

                }
            }
        }
    }
}

