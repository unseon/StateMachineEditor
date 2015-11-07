import QtQuick 2.5
import QtGraphicalEffects 1.0

Rectangle {
    id: stateItem

    radius: 10
//    width: content.width
//    height: headerRect.height + content.height

    //Behavior on x { enabled: stateItem.state === ""; SpringAnimation { spring: 2; damping: 0.2 } }
    //Behavior on width { enabled: stateItem.state === ""; SpringAnimation { spring: 2; damping: 0.2 } }


    state: "init"

    signal contentUpdated
    onContentUpdated: {
        console.log(label + " onContentUpdated called / zoomed: " + zoomed);

        if (!zoomed) {
            width = content.width
            height = headerRect.height + content.height
       }

        if (parent.updateLayout) {

            parent.updateLayout();
        }
    }

    onZoomedChanged: {
        if (zoomed) {
            content.width = Qt.binding(function() { return width });
            content.height = Qt.binding(function() { return height - headerRect.height });
        } else {
            //width = Qt.binding(function() { return content.width});
            //height = Qt.binding(function() { return headerRect.height + content.height});
        }
    }

    property var target

    property string label: "untitled"
    property string type: "state"

    property alias header: header
    property alias content: content

    property bool isGroup
    property bool zoomed: false

    opacity: state === "dragging" ? 0.5 : 1.0

    function typeName(obj) {
        return obj.toString().split("(")[0];
    }

    Drag.active: headerRect.drag.active
    Drag.hotSpot.x: 10
    Drag.hotSpot.y: 10

    onTargetChanged: {
        state = "init";

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

        state = "";
    }

    Component.onCompleted: {

        console.log(label + " completed / state: " + state);
        state = "";
    }

    states: [
        State {
            name: "dragging"
        },
        State {
            name: "init"
        }
    ]

    Rectangle {
        id: shape
        x: parent.state === "dragging" ? -3 : 0
        y: parent.state === "dragging" ? -3 : 0

        width: parent.width
        height: parent.height
        radius: 10

        Rectangle {
            id: header
            objectName: "header"

            clip: true
            width: parent.width
            height: headerRect.height
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
            width: stateItem.width
            height: parent.height - header.height
            color: "transparent"

            Rectangle {
                id: bodyShape

                y: -radius
                width: parent.width
                height: parent.height + radius
                radius: 10

                color: content.isContainedOn ? "#d9efd0" : "#f9fff0"
            }
        }
    }

    signal headerLongTabbed(var sender, var mouse)


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

    DropArea {
        id: content
        objectName: "content"

        y: headerRect.height

        width: 100
        height: 25
        //height: parent.height

        property bool isContainedOn: false

        function updateLayout() {

            console.log(stateItem.label + ' updateLayout called / child count:' + children.length + ' / zoomed: ' + zoomed);

            // update children's position and calculate size
            var topMargin = 10;
            var vSpace = 10;
            var leftMargin = 20;
            var hSpace = 10;
            var posX = leftMargin;
            var posY = topMargin;

            if (children.length === 0) {
                posY = 25;
                posX = 100;
            } else {
                for (var i = 0; i < children.length; i++) {
                    var child = children[i];
                    child.x = posX;
                    posX += child.width + hSpace;

                    child.y = posY;
                    posY += child.height + vSpace;
                }
            }

            if (!zoomed) {
                width = posX;
                height = posY;
            }

            console.log(width, height);

            contentUpdated();
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

            mainView.helper.cursor.visible = false;

        }

        onPositionChanged: {
            //console.log( stateItem.label + " : contains children " + childrenContains(drag));
            isContainedOn = childAt(drag.x, drag.y) ? false : true;

            if (isContainedOn) {

                mainView.dropTarget = content;

                var idx = calcIndex(drag.x);

                var posX, posY;

                if (idx === 0) {
                    posX = 0;
                    posY = 0;
                } else {
                    posX = children[idx - 1].x + children[idx - 1].width;
                    posY = children[idx - 1].y + children[idx - 1].height;
                }

                mainView.helper.showCursor(content, posX, posY);

                console.log(stateItem.label + ": " + calcIndex(drag.x) + " / content.y: " + content.y);
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
            mainView.helper.cursor.visible = false;
        }
    }

    MouseArea {
        id: headerRect
        objectName: "headerRect"

        width: parent.width
        height: 25

        drag.target: null
        drag.axis: Drag.XAndYAxis

        property var originContent

        onPressAndHold: {
            console.log( stateItem.label + " has long tapped.");
            stateItem.state = "dragging";
            mainView.state = "dragging";

            mainView.dropTarget = stateItem.parent;
            stateItem.parent.isContainedOn = true;

            var pos = mapToItem(mainView.helper, 0, 0);


            originContent = stateItem.parent;
            stateItem.parent = mainView.helper;

            stateItem.x = pos.x;
            stateItem.y = pos.y;

            drag.target = parent;
        }

        onReleased: {
            if (drag.target) {
                console.log("onReleased on " + mainView.dropTarget);
                drag.target = null;

                mainView.dropTarget.dropItem(stateItem);
                stateItem.state = "";
                mainView.state = "";

                //if (originContent !== mainView.dropTarget) {
                    originContent.updateLayout();
                //}

                mainView.dropTarget.updateLayout();
            }
        }
    }

}

