import QtQuick 2.5
import QtGraphicalEffects 1.0

Rectangle {
    id: stateItem

    radius: 10
    width: frame.width
    height: frame.height

    signal contentUpdated
    onContentUpdated: {
        if (parent.updateLayout) {

            parent.updateLayout();
        }
    }

    property var target

    property string label: "untitled"
    property string type: "state"

    property alias header: header
    property alias content: content

    property bool isGroup

    opacity: state === "dragging" ? 0.5 : 1.0

    function typeName(obj) {
        return obj.toString().split("(")[0];
    }

    Drag.active: headerRect.drag.active
    Drag.hotSpot.x: 10
    Drag.hotSpot.y: 10

    onTargetChanged: {
        label = target.objectName;
        console.log(label + " onTargetChanged ");

        // clear content's children
        for (var i = 0; i < content.children.length; i++) {
            var child = content.children[i];
            child.destroy();
        }

        var component = Qt.createComponent("StateItem.qml");

        if (target.children) {
            for (var i = 0; i < target.children.length; i++) {
                var child = target.children[i];

                if (typeName(child) === "State" || typeName(child) === "FinalState") {
                    var item = component.createObject(content);
                    //item.anchors.verticalCenter = Qt.binding(function(){return content.verticalCenter;});
                    //item.height = Qt.binding(function(){return height * 0.5;});
                    item.target = target.children[i];
                    //item.widthChanged.connect(childContentUpdated);
                    //item.contentUpdated.connect(content.updateLayout);
                    isGroup = true;
                }
            }

            content.updateLayout();
        }
    }

    Component.onCompleted: {
        console.log(label + " completed");
    }

    states: [
        State {
            name: "dragging"
        }
    ]

    Rectangle {
        id: frame
        x: parent.state === "dragging" ? -3 : 0
        y: parent.state === "dragging" ? -3 : 0

        width: content.width
        height: header.height + content.height

        radius: 10

        Rectangle {
            id: header
            objectName: "header"

            clip: true
            width: content.width
            height: 25
            color: "transparent"

            Rectangle {
                width: parent.width
                height: parent.height + radius
                radius: 10

                color: "#CCEEAA"

                Rectangle {
                    id: labelRect
                    width: parent.width
                    height: parent.height - parent.radius
                    color: "transparent"

                    Text {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: stateItem.label
                    }
                }
            }
        }

        Rectangle {
            id: body
            objectName: "body"

            clip: true
            y: header.height
            width: content.width
            height: parent.height - header.height
            color: "transparent"

            Rectangle {
                y: -radius
                width: parent.width
                height: parent.height + radius
                radius: 10

                color: content.isContainedOn ? "green" : "#f9fff0"
            }

            DropArea {
                id: content
                objectName: "content"

                height: parent.height

                property bool isContainedOn: false

                function updateLayout() {

                    console.log(stateItem.label + ' updateLayout called / child count:' + children.length);

                    if (children.length === 0) {
                        content.height = 25;
                        content.width = 100;
                        return;
                    }

                    // update children's x position and calculate width
                    var topMargin = 10;
                    var vSpace = 10;
                    var leftMargin = 20;
                    var hSpace = 20;
                    var posX = leftMargin;

                    for (var i = 0; i < children.length; i++) {
                        var child = children[i];
                        child.x = posX;
                        posX += child.width + hSpace;
                    }

                    content.width = posX;

                    // update children's y position and calculate height
                    var posY = topMargin;

                    for (var i = 0; i < children.length; i++) {
                        var child = children[i];
                        child.y = posY;
                        posY += child.height + vSpace;
                    }

                    content.height = posY;

                    console.log(width, height);

                    contentUpdated();
                }

                function childrenContains(drag) {
                    for (var i = 0; i < children.length; i++) {
                        var child = children[i];
                        var pos = mapToItem(child, drag.x, drag.y);
                        if (child.contains(pos)) {
                            return true;
                        }
                    }

                    return false;
                }

                function calcIndex(posX) {
                   if (children.length === 0) {
                       return 0;
                   }

                   for (var i = 0; i < children.length; i++) {
                       var child = children[i];
                       if (posX < child.x) {
                           return i;
                       }
                   }

                   return children.length;
                }

                function dropItem(item) {
                    var pos = mapFromItem(item, 0, 0);
                    item.x = pos.x;
                    item.y = pos.y;
                    //item.parent = this;

                    var idx = calcIndex(item.x);

                    // change the secuences by using js array
                    // 1. copy the children list to array
                    // 2. insert new item using splice function
                    // 3. reassign the array to children
                    var c = [];
                    for (var i = 0; i < children.length; i++) {
                        c.push(children[i]);
                    }
                    c.splice(idx, 0, item);

                    children = c;

                    updateLayout();

//                    c = [];
//                    for (var i = 0; i < children.length; i++) {
//                        c.push(children[i].label);
//                    }
//                    console.log(c.join());


                    //console.log(children.join());

                    //children.splice(idx, 0, "Lene");

                }

                onPositionChanged: {
                    //console.log( stateItem.label + " : contains children " + childrenContains(drag));
                    isContainedOn = !childrenContains(drag);

                    if (isContainedOn) {
                        mainView.dropTarget = content;

                        console.log(calcIndex(drag.x));
                    }
                }

                onEntered: {
                    console.log( stateItem.label + " mouse entered content.");
                }

                onDropped: {
                    console.log( stateItem.label + " mouse dropped.");
                }

                onExited: {
                    console.log( stateItem.label + " mouse exited content.");

                    isContainedOn = false;
                }
            }

        }

        Rectangle {
            id: borderLine

            radius: parent.radius
            anchors.fill: parent

            color: "transparent"
            border.color: "#9Ab29A"
            border.width: 2

            Rectangle {
                y: header.height
                width: parent.width
                height: 2
                border.color: parent.border.color
                border.width: 2
            }
        }
    }

    signal headerLongTabbed(var sender, var mouse)

    MouseArea {
        id: headerRect
        objectName: "headerRect"

        width: header.width
        height: header.height

        drag.target: null
        drag.axis: Drag.XAndYAxis

        property var originContent

        onPressAndHold: {
            console.log( stateItem.label + " has long tapped.");
            mainView.dropTarget = stateItem.parent;
            stateItem.parent.isContainedOn = true;

            var pos = mapToItem(mainView.draggingLayer, 0, 0);


            originContent = stateItem.parent;
            stateItem.parent = mainView.draggingLayer;

            stateItem.x = pos.x;
            stateItem.y = pos.y;

            drag.target = parent;

            stateItem.state = "dragging";

        }

        onReleased: {
            if (drag.target) {
                console.log("onReleased on " + stateItem.dropTarget);
                drag.target = null;

                mainView.dropTarget.dropItem(stateItem);

                if (originContent !== mainView.dropTarget) {
                    originContent.updateLayout();
                }

                mainView.dropTarget.updateLayout();

                stateItem.state = "";
            }
        }
    }
}

