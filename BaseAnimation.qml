import QtQuick 2.5
import QtQuick.Controls

Rectangle {
    id: root

//    width: content.width
//    height: headerRect.height + content.height

    color: "#66666666"
    opacity: state === "dragging" ? 0.15 : 1.0

    state: "init" // '', 'init', 'dragging', 'rename'

    width: 100

    objectName: "BaseAnimation"

    property int duration
    property var targetItem: null
    property var targetProperties: ""

    property int implicitNetDuration
    property bool explicit: true

    readonly property int normalHeaderHeight: 30
    readonly property int floatingHeaderHeight: 25
    //property int headerHeight: normalHeaderHeight
    property int headerHeight: floatingHeaderHeight

    property alias popup: popup

    property alias track: track
    property bool isParallel: false
    property alias editArea: editArea
    property alias headerRect: headerRect
    property bool isRoot: false
    property var childAnimations: content.children

    NumberAnimation {
        id: popup
        target: root
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

    property string label: "untitled"
    property string type: "group"

    property alias labelEdit: labelEdit

    property bool isGroup: true
    property bool selected: false
    property bool draggingFocused: mainView.mouseHelper.focusedContent === content

    property alias header: header
    property alias content: content

    property bool isInitialState: parent && parent.children[0] === this

    property var parentAnimation: (parent && parent.parent && parent.parent instanceof BaseAnimation) ? parent.parent : null

    Component.onCompleted: {
        state = "";
    }

    onContentUpdated: {
        //console.log(label + " onContentUpdated called / zoomed: " + zoomed);

        width = content.width
        height = headerRect.height + content.height
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

    function rootAnimation() {
        var iter = root

        while(iter.parentAnimation) {
            iter = iter.parentAnimation
        }

        return iter
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

                color: root.isGroup ? "#DDFFCC" : "#CCEEAA"
                border.width: root.selected ? 3 : 1
                border.color: root.draggingFocused ? "#c9dfa0" : ( root.selected ? "#40af30" : "#9Ab29A" )
            }

            Rectangle {
                id: labelRect
                width: 100
                height: header.height
                color: labelEdit.readOnly ? "transparent" : "white"

                TextInput {
                    id: labelEdit

                    anchors.fill: parent
                    anchors.leftMargin: 5
                    verticalAlignment: Text.AlignVCenter
                    text: root.label

                    onTextChanged: {
                        root.label = text;
                    }

                    onEditingFinished: {
                        root.forceActiveFocus();
                        root.state = "";
                    }
                }
            }


        }

        Rectangle {
            id: body
            objectName: "body"
            visible: root.isGroup

            y: header.height - 1
            width: root.width
            height: parent.height - header.height + 1
            color: "transparent"

            Rectangle {
                id: bodyShape

                width: parent.width
                height: parent.height

                color: root.draggingFocused ? "#e9ffe0" : ( root.selected ? "#e9ffa0" : "#f9fff0")

                border.color: root.draggingFocused ? "#c9dfa0" : ( root.selected ? "#40af30" : "#9Ab29A" )
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
        height: root.headerHeight

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

            height = root.isGroup ? Math.max(posY, 25) : 0;
        }

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

        width: labelRect.width
        height: root.headerHeight

        color: "transparent"
    }

    Rectangle {
        id: editArea
        y: 2
        height: header.height - 4
        anchors.left: parent.right
        width: 200
    }

    AnimationTrack {
        id: track
        width: 5000
        height: parent.header.height
        anchors.left: editArea.right

        isParallel: root.isParallel
        duration: root.duration


        anim: root
    }

    onDurationChanged: {
        track.duration = duration
    }

}

