import QtQuick 2.0
import QtQuick.Controls 2

import "JsonExporter.js" as JsonExporter

Rectangle {
    id: mainView
    color: "#ececec"

    property var targetTransition: null
    property var stateTransitionItem: null

    property var selectedItem: null
    property var selectedItems: []
    property string selectedType: ""

    property alias helper: helper
    property alias mouseHelper: mouseHelper
    property alias cursor: cursor

    property var stateTable: [] // [stateModel, stateItem]

    property var signals: ListModel{}
    property var trackView: null


    Component.onCompleted: {
        //console.log(JSON.stringify(this));

    }

    onSelectedItemChanged: {
        if (selectedItem === null) {
            selectedItems = [];
        } else {
            selectedItems = [];
            selectedItems.push(selectedItem);
            selectedItem.selected = true;
            selectedType = typeName(selectedItem);
        }
    }

    onSelectedItemsChanged: {
        console.log("onSelectedItemsChanged");
    }

    function save(fileUrl) {

    }

    function exportToJson(fileUrl) {
        JsonExporter.save(fileUrl, stateTransitionItem);
    }

    function addSelectionItem(stateItem) {
        selectedItems.push(stateItem);
        stateItem.selected = true;
    }

    function unselectAll() {
        unselectItem();
    }

    function unselectItem(item) {
        // when root state
        if (!item) {
            item = mainView.stateTransitionItem;
            selectedItem = null;
            selectedItems = [];
        }

        item.selected = false;

        for (var i = 0; i < item.content.children.length; i++) {
            var childItem = item.content.children[i];
            unselectItem(childItem);
        }
    }

    function typeName(obj) {
        return obj.toString().split("(")[0].split("_")[0];
    }

    property Component stateTransitionComponent: Component {
        StateTransitionItem{

        }
    }

    property Component groupAnimationComponent: Component {
        GroupAnimation{

        }
    }

    property Component singleAnimationComponent: Component {
        SingleAnimation{

        }
    }

    onTargetTransitionChanged: {
        if (targetTransition) {
            stateTransitionItem = stateTransitionComponent.createObject(stage);//, {"target": targetState});
            stateTransitionItem.model = targetTransition;
            visible = true;

            updateLayout();
        } else {
            visible = false;
        }
    }

    function createUniqueName() {
        // state + {number}
        var prefix = "anim";
        for (var i = 1; i < 1000; i++) {
            var name = prefix + i;
            if (findStateTransitionByName(name) === null) {
                break;
            }
        }

        return name;
    }

    function findStateTransitionByName(name) {
        var item = stateTransitionItem.findByName(name);
        console.log("found name: " + name);
        console.log("found name: " + (item?item.label:null));
        return item;
    }

    function createGroupAnimation() {
        var name = "Group";

        var stateItem = groupAnimationComponent.createObject(stage);
        stateItem.label = name;
        stateItem.type = "group";
        cursor.currentContent.insertChildAt(stateItem, cursor.currentIndex);
        cursor.currentIndex++;

        stateItem.popup.start()
        updateLayout();
    }

    function createSingleAnimation() {
        var name = createUniqueName();

        var stateItem = singleAnimationComponent.createObject(stage);
        stateItem.label = name;
        stateItem.type = "single";
        cursor.currentContent.insertChildAt(stateItem, cursor.currentIndex);
        cursor.currentIndex++;

        stateItem.popup.start()
        updateLayout();
    }

    function remove() {

        selectedItem.parent.removeChild(selectedItem);

        updateLayout();
    }

    function updateLayout() {
        stateTransitionItem.updateLayout();
        stateTransitionItem.track.update();

        cursor.update();
    }

    ScrollView {
        id: scrollFrame
        //color: "#FBFFFA"
        anchors.fill: parent

        Rectangle {
            id: contentFrame

            width: stage.width
            height: stage.height

            Rectangle {
                id: stage
                color: "#FBFFFA"
                width: scrollFrame.width
                height: scrollFrame.height

                onChildrenChanged: {
                    if (children[0]) {
                        width = Qt.binding(function(){return children[0].width});
                        height = Qt.binding(function(){return children[0].height});
                    } else {
                        width = Qt.binding(function(){return scrollFrame.width});
                        height = Qt.binding(function(){return scrollFrame.height});
                    }
                }
            }

            Item {
                id: cursor

                visible: true

    //            Behavior on x {
    //                NumberAnimation { duration: 100 }
    //            }

    //            Behavior on y {
    //                NumberAnimation { duration: 100 }
    //            }

                property var currentContent
                property int currentIndex: 0

                function update() {
                    currentContent = currentContent || mainView.stateTransitionItem.content;
                    //currentIndex = 0;
                    updatePosition();
                }

                function updatePosition() {
                    var content = currentContent;
                    var idx = currentIndex;
                    var localX, localY;

                    console.log("idx: ", idx, content.children.length);

                    if (content.children.length === 0) {
                        localX = 20;
                        localY = 3;
                    } else if (idx >= content.children.length) {
                        localX = 20;
                        localY = content.children[content.children.length - 1].y + content.children[content.children.length - 1].height + 2;
                    } else {
                        localX = 20;
                        localY = content.children[idx].y - 6;
                    }

                    var helperPos = parent.mapFromItem(content, localX, localY);

                    cursor.x = helperPos.x;
                    cursor.y = helperPos.y;
                }

                Rectangle {
                    id: cursorShape

                    color: "red"

                    width: 20
                    height: 5
                }

                SequentialAnimation {
                    id: blinkAnim
                    loops: Animation.Infinite
                    running: cursor.state === ""
                    NumberAnimation {
                        target: cursor
                        property: "opacity"
                        from: 0.0
                        to: 1.0
                        duration: 150
                    }

                    PauseAnimation {
                        duration: 500
                    }

                    NumberAnimation {
                        target: cursor
                        property: "opacity"
                        from: 1.0
                        to: 0.0
                        duration: 150
                    }

                    PauseAnimation {
                        duration: 200
                    }

                    onStopped: {
                        cursor.opacity = 1.0;
                    }
                }
            }

            Rectangle {
                id: helper

                anchors.fill: parent
                color: "transparent"
            }

            Rectangle {
                id: balloon

                color: "yellow"
                width: 150
                height: 60

                opacity: 0.5

                Text {
                    id: balloonText
                    anchors.fill: parent
                    anchors.margins: 5
                }

                visible: false
            }

            MouseArea {
                id: mouseHelper

                anchors.fill: parent
                propagateComposedEvents: true

                hoverEnabled: true

                drag.target: null
                drag.axis: Drag.XAndYAxis

                acceptedButtons: Qt.LeftButton | Qt.RightButton

                property var focusedContent

                property var originContainer

                function getHit(x, y) {
                    return hitTest(stage, x, y);
                }

                onPressed: (mouse) => {
                    if (mainView.state === "rename") {
                        mainView.state = "";
                        mainView.selectedItem.labelEdit.deselect();
                        mainView.selectedItem.state = "";
                        mainView.unselectStateItem();

                        updateCursor(mouse);
                        cursor.visible = false;

                        return;
                    }

                    if (mouse.button === Qt.RightButton) {
                        var hit = getHit(mouse.x, mouse.y);

                        if (hit.objectName === "headerRect") {
                           var stateItem = hit.parent;
                           mainView.unselectAll;
                           mainView.selectedItem = stateItem;
                           updateCursor(mouse);
                           cursor.visible = false;

                           contextMenu.popup();

                        } else if (hit.objectName === "content") {
                            var hitTransition = transitionHitTest(mouse.x, mouse.y);
                            if (hitTransition) {
                                cursor.visible = false;
                                mainView.selectedItem = hitTransition;
                                transitionContextMenu.popup();
                            } else {
                                updateCursor(mouse);
                                mainView.unselectAll();
                                contextMenu.popup();
                            }
                        }
                    }
                }

                onDoubleClicked: {


                    if (mouse.button === Qt.LeftButton) {
                        var hit = getHit(mouse.x, mouse.y);

                        if (hit.objectName === "content") {
                        } else if (hit.objectName === "headerRect") {
                            console.log("double clicked");

                            var stateItem = hit.parent;
                            mainView.selectedItem = stateItem;
                            mainView.state = "rename";
                            mainView.selectedItem.state = "rename";
                            stateItem.labelEdit.moveCursorSelection(0, TextInput.SelectCharacters);
                            stateItem.labelEdit.selectAll();
                            stateItem.labelEdit.focus = true;

                            updateCursor(mouse);
                            cursor.visible = false;

                            mouse.accepted = false;
                        }
                    } else if (mouse.button === Qt.RightButton) {
                    }
                }

                onClicked: (mouse) =>{
                    if (mouse.button === Qt.LeftButton && mouse.modifiers & Qt.ShiftModifier) {
                        var hit = getHit(mouse.x, mouse.y);

                        if (hit.objectName === "content") {
                            updateCursor(mouse);
                            //mainView.selectedItem = null;
                        } else if (hit.objectName === "headerRect") {
                            var stateItem = hit.parent;
                            if (mainView.selectedItem === null) {
                                mainView.unselectAll();
                                mainView.selectedItem = stateItem;
                            } else {
                                mainView.addSelectionItem(stateItem);

                                console.log(mainView.selectedItems);
                                console.log(mainView.selectedItems.indexOf(stateItem));
                            }

                            updateCursor(mouse);
                            cursor.visible = false;
                        }
                    } else if (mouse.button === Qt.LeftButton) {
                        var hit = getHit(mouse.x, mouse.y);

                        if (hit.objectName === "content") {
                            updateCursor(mouse);
                            mainView.unselectAll();
                        } else if (hit.objectName === "headerRect") {
                            var stateItem = hit.parent;
                            mainView.unselectAll();
                            mainView.selectedItem = stateItem;
                            updateCursor(mouse);
                            cursor.visible = false;
                        }
                    } else if (mouse.button === Qt.RightButton) {
                    }
                }

                onPressAndHold: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        return;
                    }

                    var hit = getHit(mouse.x, mouse.y);

                    // ready to drag when hit hreaderRect
                    if (hit.objectName === "headerRect") {
                        var stateItem = hit.parent;
                        console.log( stateItem.label + " has long tapped.");

                        stateItem.state = "dragging";

                        originContainer = stateItem.parent;
                        focusedContent = stateItem.parent;

                        // parenting to helper
                        var pos = hit.mapToItem(mainView.helper, 0, 0);
                        stateItem.parent = mainView.helper;
                        stateItem.x = pos.x;
                        stateItem.y = pos.y;

                        drag.target = stateItem;
                        console.log("drag: " + drag.active + "/ target: " + stateItem.label);

                        cursor.state = "dragging";
                        mainView.state = "dragging";

                        updateCursor(mouse);
                    }
                }

                onReleased: (mouse) => {
                    console.log("released");

                    // drop to content if possible
                    if (cursor.state == "dragging") {
                        dropToContent(focusedContent);
                        updateLayout();
                        cursor.state = "";
                        mainView.state = "";
                    }

                    updateCursor(mouse);
                }

                onPositionChanged: (mouse) => {
                    balloon.visible = false;

                    if (drag.active) {
                        updateCursor(mouse);
                        focusedContent = cursor.currentContent;
                    } else {
                        var hit = getHit(mouse.x, mouse.y);
                        if (hit && hit.objectName === "content") {
                        }
                    }
                }

                function updateCursor(mouse) {
                    var hit = getHit(mouse.x, mouse.y);

                    if (hit) {
                        var stateItem = hit.parent;

                        // update when hit content
                        if (hit.objectName === "content") {
                            var content = hit;

                            cursor.visible = true;
                            cursor.currentContent = content;

                            // calculate cursor position
                            var pos = mapToItem(content, mouse.x, mouse.y);
                            var idx = content.calcIndex(pos.y);
                            cursor.currentIndex = idx;
                            cursor.updatePosition();
                        }
                    }
                }

                function dropToContent(content) {
                    var stateItem = drag.target;

                    cursor.currentContent.insertChildAt(stateItem, cursor.currentIndex);

                    originContainer.updateLayout();

                    content.state = "";
                    stateItem.state = "";

                    drag.target = null;
                    focusedContent = null;
                }

                // return hitted content or headerRect
                function hitTest(target, x, y) {
                    var item = target.childAt(x, y);
                    if (item) {
                        var pos = item.mapFromItem(target, x, y);
                        var childItem = item.childAt(pos.x, pos.y);

                        if (childItem.objectName === "content") {
                            var contentPos = childItem.mapFromItem(target, x, y);

                            var hitItem = hitTest(childItem, contentPos.x, contentPos.y);

                            if (hitItem) {
                                return hitItem;
                            } else {
                                //console.log('hit content of ' + item.label);
                                return childItem;
                            }

                        } else {
                            //console.log('hit header of ' + item.label);
                            return childItem;
                        }
                    } else {
                        return null;
                    }
                }
            }


        }

    }

    Rectangle {
        id: contextMenuLayer

        anchors.fill: parent
        color: "transparent"

    }
}

