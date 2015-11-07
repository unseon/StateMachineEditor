import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.4

StateItem {
    id: stateMachineItem

    width: 0
    height: 0

    onWidthChanged: {
        console.log("top level width changed: " + width );
    }

    onHeightChanged: {
        console.log("top level height changed: " + height );
    }

    property var transitionTable: []
    property var stateTable: [] // [state, stateItem]

    function buildTransitionTable() {
        buildTransitionOnModel(target);

        //console.log(transitionTable);
        //console.log(transitionTable.length);
    }

    function buildTransitionOnModel(model) {
        for (var i = 0; i < model.children.length; i++) {
            var child = model.children[i];
            var childType = typeName(child);

            if (childType === "SignalTransition" || childType === "TimeoutTransition") {
                var transition = child;
                var from = transition.sourceState;
                var to = transition.targetState;

                transitionTable.push(child);
            } else if (childType === "State") {
                buildTransitionOnModel(child);
            }
        }
    }

    function getItemFromModel(stateModel) {
        for (var i = 0; i < stateTable.length; i++) {
            if (stateModel === stateTable[i][0]) {
                return stateTable[i][1];
            }
        }

        return null;
    }
}

