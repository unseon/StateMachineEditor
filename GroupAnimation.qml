import QtQuick 2.5

Rectangle {
    id: stateItem

//    width: content.width
//    height: headerRect.height + content.height

    color: "#66666666"
    opacity: state === "dragging" ? 0.15 : 1.0

    state: "init" // '', 'init', 'dragging', 'rename'

    width: 300

    property int duration
    property int implicitNetDuration
    property bool explicit: true
    property var targetItem: null
    property var targetProperties: ""

    readonly property int normalHeaderHeight: 30
    readonly property int floatingHeaderHeight: 25
    //property int headerHeight: normalHeaderHeight
    property int headerHeight: floatingHeaderHeight

    property alias popup: popup
    NumberAnimation {
        id: popup
        target: stateItem
        property: "scale"
        from: 0
        to: 1.0
        duration: 250
        easing.type: Easing.OutBack
    }

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
    property string type: "group"

    property alias labelEdit: labelEdit

    property bool isGroup: true
    property bool selected: false
    property bool draggingFocused: mainView.mouseHelper.focusedContent === content

    property alias header: header
    property alias content: content

    property bool isInitialState: parent && parent.children[0] === this

    property var parentAnimation: (parent && parent.parent ) ? parent.parent : null

    Component.onCompleted: {
        state = "";
    }

    onContentUpdated: {
        //console.log(label + " onContentUpdated called / zoomed: " + zoomed);

        width = content.width
        height = headerRect.height + content.height
    }

    onIsGroupChanged: {
        console.log("isGroup changed")
    }

    function updateLayout() {
        content.updateLayout();

        width = content.width
        height = headerRect.height + content.height
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

    onTargetChanged: {
        if (target === null) {
            return;
        }

        state = "init";

        label = target.objectName;
        type = typeName(target);

        mainView.stateTable.push([target, stateItem]);

        console.log(label + ":" + type);

        // clear content's children
        for (var i = 0; i < content.children.length; i++) {
            var child = content.children[i];
            child.destroy();
        }

        var component = Qt.createComponent("GroupAnimation.qml");

        if (target.children) {
            for (var i = 0; i < target.children.length; i++) {
                var child = target.children[i];

                var item = component.createObject(content);
                item.target = target.children[i];
            }
        }

        state = "";
    }

    function typeName(obj) {
        return obj.toString().split("(")[0].split("_")[0];
    }

    Rectangle {
        id: shape
        x: parent.state === "dragging" ? -3 : 0
        y: parent.state === "dragging" ? -3 : 0

        width: parent.width
        height: parent.height

        //Behavior on width { enabled: stateItem.state === ""; NumberAnimation {} }

        //clip: true

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
                height: parent.height

                color: labelEdit.readOnly ? "#CCEEAA" : "white"
                border.width: stateItem.selected ? 3 : 1
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
                    anchors.leftMargin: 5
                    //horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: stateItem.label

                    onTextChanged: {
                        stateItem.label = text;
                    }

                    onEditingFinished: {
                        stateItem.forceActiveFocus();
                        stateItem.state = "";
                    }
                }
            }
        }

        Rectangle {
            id: body
            objectName: "body"
            visible: stateItem.isGroup

            y: header.height - 1
            width: stateItem.width
            height: parent.height - header.height + 1
            color: "transparent"

            Rectangle {
                id: bodyShape

                width: parent.width
                height: parent.height

                color: stateItem.draggingFocused ? "#e9ffe0" : ( stateItem.selected ? "#e9ffa0" : "#f9fff0")

                border.color: stateItem.draggingFocused ? "#c9dfa0" : ( stateItem.selected ? "#40af30" : "#9Ab29A" )
                border.width: 1
            }

        }
    }

    Rectangle {
        id: content
        objectName: "content"

        y: headerRect.height
        color: "transparent"

        width: parent.width
        height: stateItem.headerHeight

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

        function removeChild(child) {


            var c = [];
            for (var i = 0; i < children.length; i++) {
                c.push(children[i]);
            }

            var idx = c.indexOf(child);
            c.splice(idx, 1);

            children = c;
        }

        function updateLayout() {

            //console.log(stateItem.label + ' updateLayout called / child count:' + children.length + ' / zoomed: ' + zoomed);

            // update children's position and calculate size
            var topMargin = 10;
            var vSpace = 10;
            var childMargin = 20;
            var leftMargin = 20;
            var rightMargin = 20;

            var hSpace = 10;
            var posX;
            var posY = topMargin;

            let childWidth = 100


            if (children.length === 0) {

            } else {
                for (var i = 0; i < children.length; i++) {
                    var child = children[i];

                    child.x = leftMargin
                    child.y = posY;

                    child.width = width - leftMargin

                    child.updateLayout();

                    posY += child.height + vSpace;
                }
            }

            height = stateItem.isGroup ? Math.max(posY, 25) : 0;

            //console.log(width, height);

            //contentUpdated();
        }

        // function calcIndex(posX) {
        //    if (children.length === 0) {
        //        return 0;
        //    }

        //    for (var i = 0; i < children.length; i++) {
        //        var child = children[i];
        //        if (posX < child.x + child.width) {
        //            return i;
        //        }
        //    }

        //    return children.length;
        // }

        function calcIndex(posY) {
           if (children.length === 0) {
               return 0;
           }

           for (var i = 0; i < children.length; i++) {
               var child = children[i];
               if (posY < child.y + child.height) {
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
        height: stateItem.headerHeight

        color: "transparent"
    }

}

