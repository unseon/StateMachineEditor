import QtQuick 2.0

Rectangle {
    id: hierarchyView
    width: 200
    height: 500

    property var selected: null

    property var targetItem: null

    property var itemList: ListModel{}

    function typeName(obj) {
        return obj.toString().split("(")[0].split("_")[0];
    }

    function addItem(item, indent) {
        var indent = indent || 0;
        var entity = {target: item, indent: indent, stateMachines: []};

        for (var i = 0; i < item.resources.length; i++) {
            if (typeName(item.resources[i]) === "StateMachine") {
                //addState(item.resources[i], indent);
                entity.stateMachines.push({target: item.resources[i], indent: indent + 1});
            }
        }

        itemList.append(entity);


        for (var i = 0; i < item.children.length; i++) {
            addItem(item.children[i], indent + 1);
        }
    }


    function addState(state, indent) {
        var indent = indent || 0;

        var entity = {target: state, indent: indent + 1};
        itemList.append(entity);

        if (state.children) {
            for (var i = 0; i < state.children.length; i++) {
                var child = state.children[i];
                var childType = typeName(child);
                console.log("childtype: " + childType);
                if (childType === "SignalTransition" || childType === "TimeoutTransition") {
                    var transition = child;
                    console.log("transition type: " + childType);
                    itemList.append({target: transition, indent: indent + 1});
                } else if (childType === "State") {
                    addState(child, indent + 1);
                }
            }
        }
    }

    onTargetItemChanged: {
        itemList.clear();
        addItem(targetItem);

        console.log(itemList);
    }

    ListView {
        id: listView
        anchors.fill: parent
        model: hierarchyView.itemList
        delegate: Rectangle {
            id: delegateItem
            width: parent.width
            height: 20 + model.stateMachines.count * 20

            Rectangle {
                id: indentedItem
                height: parent.height
                anchors {
                    left: parent.left
                    leftMargin: model.indent * 10
                    right: parent.right
                }

                border {
                    color: "gray"
                    width: 1
                }

                color: "transparent"
                Text {
                    id: itemLabel
                    width: parent.width
                    height: 20
                    text: typeName(model.target) + ": " + model.target.objectName
                }

                Row {
                    id: stateRow
                    anchors {
                        left: parent.left
                        leftMargin: 10
                        right: parent.right
                        top: itemLabel.bottom
                        //bottom: parent.bottom
                    }

                    Repeater {
                        id: repeater
                        model: stateMachines.count
                        delegate:
                            Rectangle {
                                width: stateRow.width
                                height: 20

                                color: "#E0FFE0"

                                Text {
                                    anchors.fill: parent
                                    text: stateMachines.get(index).target.objectName
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        hierarchyView.selected = stateMachines.get(index).target;
                                    }
                                }
                            }
                    }
                }
            }
        }
    }
}

