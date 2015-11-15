import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQml.StateMachine 1.0 as DSM

Rectangle {
    property var stateMachine: stateMachine

    DSM.StateMachine {
        id: stateMachine
        objectName: "stateMachine"
        initialState: state
        running: true

        property alias finalState: finalState

        DSM.State {
            id: state
            objectName: "state"
            initialState: state01
            DSM.State {
                id: state01
                objectName: "state01"
                DSM.SignalTransition {
                    targetState: finalState
                    signal: button.clicked
                }
            }
        }
        DSM.State {
            id: state1
            objectName: "state1"
            DSM.SignalTransition {
                targetState: finalState
                signal: button.clicked
            }
        }

        DSM.FinalState {
            id: finalState
            objectName: "finalState"
        }
        onFinished: Qt.quit()
    }

    Button {
        objectName: "Button"
        anchors.fill: parent
        id: button
        text: "Finish state"
    }
}
