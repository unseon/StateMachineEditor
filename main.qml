import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0
import QtQuick.Dialogs

ApplicationWindow {
    id: applicationWindow

    visible: true
    width: 1024
    height: 480
    title: fileUrl ? fileUrl : "(Empty)"

    property string fileUrl

    menuBar: MenuBar {
        id: basicMenuBar
        height: 20
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
                    mainView.exportToJson("C:\\workspace\\output.json");
                }
            }

        }
    }

    property var document: {}

    function newFile() {
        document = {
            id: "transition",
            type: "Transition",
            from: "",
            to: "",
            children: [
                {
                    type: "PropertyAnimation",
                    id: "propAnim",
                    target: "targetItem01",
                    properties: "x",
                    duration: "100"
                }
            ]
        }
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
            stateTransitionContainer.stateTransition = Qt.createQmlObject(text, stateTransitionContainer);
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
        visible: mainView.visible
        RowLayout {
            anchors.fill: parent

            ToolButton {
                //action: createGroupAction

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
                    createGroupAction.trigger();
                }
            }

            ToolButton {
                //action: createGroupAction

                Layout.fillWidth: false
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50

                Image {
                    anchors.fill: parent
                    source: "qrc:/images/images/icons/icon_create_single_animation.svg"
                    fillMode: Image.PreserveAspectFit

                    sourceSize.width: width
                    sourceSize.height: height
                }

                onClicked: {
                    createSingleAnimation.trigger();
                }
            }

            ToolButton {
                //action: removeAnimationAction
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
                    removeAnimationAction.trigger();
                }
            }

            Item { Layout.fillWidth: true }
        }
    }

    Action {
        id: createGroupAction
        text: qsTr("Insert Group Animation");
        onTriggered: mainView.createGroupAnimation();
    }

    Action {
        id: createSingleAnimation
        text: qsTr("Insert Single Animation")
        onTriggered: mainView.createSingleAnimation();
    }

    Action {
        id: removeAnimationAction
        text: qsTr("Remove Animation");
        icon.source: "qrc:/images/images/icons/icon_delete_state.svg"
        onTriggered: mainView.remove();
    }

    Menu {
        id: contextMenu
        title: "Edit"

        MenuItem {
            action: createGroupAction
            visible: mainView.selectedItem === null
        }

        MenuItem {
            text: "Rename"
            visible: mainView.selectedItem !== null
        }

        MenuItem {
            action: removeAnimationAction
            visible: mainView.selectedItem !== null
        }

        MenuItem {
            text: "Change Type"
        }
    }

    Item {
        id: stateTransitionContainer
        visible: false

        property var stateTransition

        onStateTransitionChanged: {
            mainView.targetTransition = stateTransition;
        }
    }

    Item {
        anchors.fill: parent

        StateTransitionMainView {
            id: mainView
            color: "lightgray"
            width: parent.width
            height: parent.height

            document: applicationWindow.document
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: !mainView.visible

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

