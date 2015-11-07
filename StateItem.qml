import QtQuick 2.5
import QtGraphicalEffects 1.0

Rectangle {
    id: stateItem

    radius: 10
//    width: content.width
//    height: headerRect.height + content.height

    //Behavior on x { enabled: stateItem.state === ""; SpringAnimation { spring: 2; damping: 0.2 } }
    //Behavior on width { enabled: stateItem.state === ""; SpringAnimation { spring: 2; damping: 0.2 } }

    color: "#66666666"
    opacity: state === "dragging" ? 0.35 : 1.0

    state: "init" // '', 'init', 'dragging'

    signal contentUpdated

    property var target

    property string label: "untitled"
    property string type: "state"

    property bool isGroup
    property bool zoomed: false

    property alias header: header
    property alias content: content

    Component.onCompleted: {
        console.log(label + " completed / state: " + state);
        state = "";
    }

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

    function typeName(obj) {
        return obj.toString().split("(")[0];
    }

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

                color: mainView.mouseHelper.focusedContent === content ? "#e9ffe0" : "#f9fff0"
            }
        }

        Rectangle {
            id: borderLine

            radius: parent.radius
            anchors.fill: parent

            color: "transparent"
            border.color: mainView.mouseHelper.focusedContent === content ? "#c9dfa0" : "#9Ab29A"
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

    Rectangle {
        id: content
        objectName: "content"

        y: headerRect.height
        color: "transparent"

        width: 100
        height: 25

        function insertChild(stateItem) {
            var pos = content.mapFromItem(stateItem, 0, 0);
            stateItem.x = pos.x;
            stateItem.y = pos.y;

            var idx = calcIndex(stateItem.x);

            // change the secuences by using js array
            // 1. copy the children list to array
            // 2. insert new item using splice function
            // 3. reassign the array to children
            var c = [];
            for (var i = 0; i < children.length; i++) {
                c.push(children[i]);
            }
            c.splice(idx, 0, stateItem);

            children = c;

            updateLayout();
        }

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
    }

    Rectangle {
        id: headerRect
        objectName: "headerRect"

        width: parent.width
        height: 25

        color: "transparent"
    }

}

