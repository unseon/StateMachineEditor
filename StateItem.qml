import QtQuick 2.5
import QtGraphicalEffects 1.0

Rectangle {
    id: stateItem

    radius: 10
//    width: content.width
//    height: headerRect.height + content.height

    //Behavior on x { enabled: stateItem.state === ""; NumberAnimation {} }
    //Behavior on y { enabled: stateItem.state === ""; NumberAnimation {} }

    color: "#66666666"
    opacity: state === "dragging" ? 0.15 : 1.0

    state: "init" // '', 'init', 'dragging', 'rename'

    states: [
        State {
            name: ""
            ParentChange { target: labelRect; parent: header}
            PropertyChanges { target: labelEdit; readOnly: true }
        },
        State {
            name: "rename"
            ParentChange { target: labelRect; parent: mainView.mouseHelper}
            PropertyChanges { target: labelEdit; readOnly: false }
        }
    ]

    signal contentUpdated

    property var target

    property string label: "untitled"
    property string type: "State"

    property alias labelEdit: labelEdit

    property bool isGroup
    property bool zoomed: false
    property bool selected: false
    property bool draggingFocused: mainView.mouseHelper.focusedContent === content

    property alias header: header
    property alias content: content

    property bool isInitialState: parent && parent.children[0] === this

    property var transitions: []

    property bool isStateItem: true

    Component.onCompleted: {
        //console.log(label + " completed / state: " + state);
        //content.updateLayout();
        state = "";
    }

    onContentUpdated: {
        //console.log(label + " onContentUpdated called / zoomed: " + zoomed);

        if (!zoomed) {
            width = content.width
            height = headerRect.height + content.height
       }

//        if (parent.updateLayout) {

//            parent.updateLayout();
//        }
    }

    function updateLayout() {
        content.updateLayout();

        if (!zoomed) {
            width = content.width
            height = headerRect.height + content.height
       }
    }

    function findByName(name) {
        if (label === name) {
            return this;
        } else {
            for (var i = 0; i < content.children.length; i++) {
                var child = content.children[i];
                if (child.findByName(name)) {
                    return child;
                }
            }

            return null;
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
        if (target === null) {
            return;
        }

        state = "init";

        label = target.objectName;
        type = typeName(target);

        transitions = [];

        mainView.stateTable.push([target, stateItem]);

        console.log(label + ":" + type);

        // clear content's children
        for (var i = 0; i < content.children.length; i++) {
            var child = content.children[i];
            child.destroy();
        }

        var component = Qt.createComponent("StateItem.qml");

        if (target.children) {
            for (var i = 0; i < target.children.length; i++) {
                var child = target.children[i];

                var childType = typeName(child);

                if (childType === "State" || childType === "FinalState") {
                    var item = component.createObject(content);
                    //item.anchors.verticalCenter = Qt.binding(function(){return content.verticalCenter;});
                    //item.height = Qt.binding(function(){return height * 0.5;});
                    item.target = target.children[i];
                    //item.widthChanged.connect(childContentUpdated);
                    //item.contentUpdated.connect(content.updateLayout);
                    isGroup = true;
                } else if (childType === "SignalTranstion" || childType === "TimeoutTransition") {
                    transitions.push(child);
                }
            }
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

        //Behavior on width { enabled: stateItem.state === ""; NumberAnimation {} }

        clip: true

        Rectangle {
            id: header
            objectName: "header"

            clip: true
            width: parent.width
            height: headerRect.height
            color: "transparent"

            Rectangle {
                id: headerBackground
                width: parent.width
                height: parent.height + radius + 2
                radius: stateItem.isInitialState ? 0 : 10

                color: "#CCEEAA"
                border.width: 2
                border.color: stateItem.draggingFocused ? "#c9dfa0" : ( stateItem.selected ? "#40af30" : "#9Ab29A" )
            }

            Rectangle {
                id: labelRect
                width: header.width
                height: header.height
                color: "transparent"

                TextInput {
                    id: labelEdit

                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: stateItem.label
                }
            }
        }

        Rectangle {
            id: body
            objectName: "body"

            visible: stateItem.type !== "FinalState"
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

                color: stateItem.draggingFocused ? "#e9ffe0" : ( stateItem.selected ? "#e9ffa0" : "#f9fff0")

                border.color: stateItem.draggingFocused ? "#c9dfa0" : ( stateItem.selected ? "#40af30" : "#9Ab29A" )
                border.width: 2
            }

            Rectangle {
                y: 0
                width: parent.width
                height: 2
                border.color: bodyShape.border.color
                border.width: 2
            }
        }

//        Rectangle {
//            id: borderLine

//            radius: parent.radius
//            width: parent.width
//            height: stateItem.type !== "FinalState" ? parent.height : parent.height + radius

//            color: "transparent"
//            border.color: stateItem.draggingFocused ? "#c9dfa0" : ( stateItem.selected ? "#40af30" : "#9Ab29A" )
//            border.width: 2

//            Rectangle {
//                y: header.height - 2
//                width: parent.width
//                height: 2
//                border.color: parent.border.color
//                border.width: 2
//            }
//        }


    }

    Rectangle {
        id: content
        objectName: "content"

        visible: stateItem.type !== "FinalState"

        y: headerRect.height
        color: "transparent"

        width: 100
        height: 25

        function insertChildAt(stateItem, idx) {
            // change the sequences by using js array
            // 1. copy the children list to array
            // 2. insert new item using splice function
            // 3. reassign the array to children

            var c = [];
            for (var i = 0; i < children.length; i++) {
                c.push(children[i]);
            }
            c.splice(idx, 0, stateItem);

            children = c;
        }

        function removeChild(childStateItem) {


            var c = [];
            for (var i = 0; i < children.length; i++) {
                c.push(children[i]);
            }

            var idx = c.indexOf(childStateItem);
            c.splice(idx, 1);

            children = c;
        }

        function updateLayout() {

            //console.log(stateItem.label + ' updateLayout called / child count:' + children.length + ' / zoomed: ' + zoomed);

            // update children's position and calculate size
            var topMargin = 10;
            var vSpace = 10;
            var leftMargin = 20;
            var rightMargin = 20;
            var hSpace = 10;
            var posX = leftMargin;
            var posY = topMargin;

            if (children.length === 0) {

                if (stateItem.type !== "FinalState") {
                    posY = 25;
                } else {
                    posY = 0;
                }

                posX = 100;
            } else {
                for (var i = 0; i < children.length; i++) {
                    var child = children[i];
                    child.updateLayout();

                    child.x = posX;
                    posX += child.width + hSpace;

                    child.y = posY;
                    posY += child.height + vSpace;
                }
            }

            if (!zoomed) {
                width = posX - hSpace + rightMargin;
                height = posY;
            }

            //console.log(width, height);

            //contentUpdated();
        }

        function calcIndex(posX) {
           if (children.length === 0) {
               return 0;
           }

           for (var i = 0; i < children.length; i++) {
               var child = children[i];
               if (posX < child.x + child.width) {
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
        height: stateItem.type !== "FinalState" ? 25 : 50

        color: "transparent"
    }

}

