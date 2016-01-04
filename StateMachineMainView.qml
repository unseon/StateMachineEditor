import QtQuick 2.0
import QtQuick.Controls 1.4

import "QmlExporter.js" as QmlExporter
import "JsonExporter.js" as JsonExporter

Rectangle {
    id: mainView
    color: "#ececec"

    property var targetStateMachine: null
    property var stateMachineItem: null

    property var selectedItem: null
    property var selectedItems: []
    property string selectedType: ""

    property alias helper: helper
    property alias mouseHelper: mouseHelper
    property alias cursor: cursor
    property alias transitionLayer: transitionLayer

    property var stateTable: [] // [stateModel, stateItem]

    property int signalIndex: 28
    property var signals: ListModel{}


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
        QmlExporter.save(fileUrl, stateMachineItem);
    }

    function exportToJson(fileUrl) {
        JsonExporter.save(fileUrl, stateMachineItem);
    }

    function addSelectionItem(stateItem) {
        selectedItems.push(stateItem);
        stateItem.selected = true;
    }

    function unselectAll() {
        for (var i = 0; i < selectedItems.length; i++) {
            if (selectedItems[i].isStateItem) {
                //unselectStateItem(selectedItems[i]);
            } else if (selectedItems[i].isTransitionItem) {
                unselectTransitionItem(selectedItems[i]);
            }
        }

        unselectStateItem();
    }

    function unselectTransitionItem(transitionItem) {
        transitionItem.selected = false;
    }

    function unselectStateItem(stateItem) {

        // when root state
        if (!stateItem) {
            stateItem = mainView.stateMachineItem;
            selectedItem = null;
            selectedItems = [];
        }

        stateItem.selected = false;

        for (var i = 0; i < stateItem.content.children.length; i++) {
            var childItem = stateItem.content.children[i];
            unselectStateItem(childItem);
        }
    }

    function removeTransition(transitionItem) {
        var newTransitionList = [];

        for (var i = 0; i < transitionLayer.children.length; i++) {
            var transition = transitionLayer.children[i];
            if (transition === transitionItem) {
                continue;
            }

            newTransitionList.push(transitionLayer.children[i]);
        }

        transitionItem.destroy();
    }

    function removeSelectedTransition() {
        var selectedTransition = selectedItem;
        unselectAll();

        removeTransition(selectedTransition);
    }

    function removeTransitionsConnected(stateItem) {
        var newTransitionList = [];

        for (var i = 0; i < transitionLayer.children.length; i++) {
            var transition = transitionLayer.children[i];
            if (transition.to === stateItem || transition.from === stateItem)
                continue;

            newTransitionList.push(transitionLayer.children[i]);
        }

        transitionLayer.children = newTransitionList;

        for (var i = 0; i < stateItem.content.children.length; i++) {
            var child = stateItem.content.children[i];
            removeTransitionsConnected(child);
        }
    }

    function getTransitionList() {
        var transitionList = [];
        buildTransitionOnModel(targetStateMachine, transitionList);

        return transitionList;
    }

    function typeName(obj) {
        return obj.toString().split("(")[0];
    }

    function buildTransitionOnModel(model, list) {
        for (var i = 0; i < model.children.length; i++) {
            var child = model.children[i];
            var childType = typeName(child);

            if (childType === "SignalTransition" || childType === "TimeoutTransition") {
                var transition = child;
                var from = transition.sourceState;
                var to = transition.targetState;

                list.push(transition);
            } else if (childType === "State") {
                buildTransitionOnModel(child, list);
            }
        }
    }

    function getStateItemFromModel(stateModel) {
        for (var i = 0; i < stateTable.length; i++) {
            if (stateModel === stateTable[i][0]) {
                return stateTable[i][1];
            }
        }

        return null;
    }

    property Component stateMachineItemComponent: Component {
        StateMachineItem{

        }
    }

    property Component stateItemComponent: Component {
        StateItem{

        }
    }

    property Component transitionComponent: Component {
        TransitionItem {

        }
    }

    onTargetStateMachineChanged: {
        if (targetStateMachine) {
            //var topState = stateComponent.createObject(stage, {"width": mainView.width, "height": mainView.height});
            stateMachineItem = stateMachineItemComponent.createObject(stage);//, {"target": targetState});
            //stateMachineItem.zoomed = true;
            stateMachineItem.target = targetStateMachine;
            //stateMachineItem.width = Qt.binding(function(){return mainView.width});
            //stateMachineItem.height = Qt.binding(function(){return mainView.height});

            var transitionList = getTransitionList();

            for (var i = 0; i < transitionList.length; i++) {
                var transitionModel = transitionList[i];
                var transitionItem = transitionComponent.createObject(transitionLayer);
                transitionItem.model = transitionModel;
            }

            visible = true;

            // import signal list
            var properties = Object.keys(targetStateMachine)
            for (var i = signalIndex; i < properties.length; i++) {
                signals.append({"name": properties[i]});
            }

            stateMachineItem.signals = signals;

            updateLayout();
        } else {
            visible = false;
        }
    }

    function createUniqueStateName() {
        // state + {number}
        var prefix = "state";
        var name = prefix;
        if(findStateByName(name) !== null) {

            for (var i = 0; i < 1000; i++) {
                name = prefix + i;
                if (findStateByName(name) === null) {
                    break;
                }
            }
        }

        return name;
    }

    function findStateByName(name) {
        var item = stateMachineItem.findByName(name);
        console.log("found name: " + name);
        console.log("found name: " + (item?item.label:null));
        return item;
    }

    function createState() {
        var name = createUniqueStateName();

        var stateItem = stateItemComponent.createObject(stage);
        stateItem.label = name;
        cursor.currentContent.insertChildAt(stateItem, cursor.currentIndex);

        updateLayout();
    }

    function removeState() {
        //stateMachineItem.removeState(selectedItems.target);

        removeTransitionsConnected(selectedItem);
        selectedItem.parent.removeChild(selectedItem);

        updateLayout();
    }

    function createTransition() {
        var transitionItem = transitionComponent.createObject(transitionLayer);
        transitionItem.from = mainView.selectedItems[0];
        transitionItem.to = mainView.selectedItems[1];

        updateLayout();
    }

    function updateLayout() {
        stateMachineItem.updateLayout();

        for (var i = 0; i < transitionLayer.children.length; i++) {
            var transitionItem = transitionLayer.children[i];
            transitionItem.update();
        }

        cursor.update();
    }

    ScrollView {
        id: scrollFrame
        //color: "#FBFFFA"
        anchors.fill: parent

        flickableItem.rebound: null


        viewport.onWidthChanged: {
            console.log("Viewport width: " + viewport.width);
        }

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

            Rectangle {
                id: transitionLayer

                opacity: mainView.state === "dragging" ? 0.2 : 1.0
                color: "transparent"
                anchors.fill: parent
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
                property int currentIndex

                function update() {
                    currentContent = mainView.stateMachineItem.content;
                    currentIndex = 0;
                    updatePosition();
                }

                function updatePosition() {
                    var content = currentContent;
                    var idx = currentIndex;
                    var localX, localY;
                    if (idx === 0) {
                        localX = 5;
                        localY = 5;
                    } else {
                        localX = content.children[idx - 1].x + content.children[idx - 1].width;
                        localY = content.children[idx - 1].y + content.children[idx - 1].height;
                    }

                    var helperPos = parent.mapFromItem(content, localX, localY);

                    cursor.x = helperPos.x;
                    cursor.y = helperPos.y;
                }

                Rectangle {
                    id: cursorShape

                    x: -2
                    y: -2

                    color: "red"

                    width: 5
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

                onPressed: {
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
                            updateCursor(mouse);
                            mainView.unselectAll();
                            contextMenu.popup();
                        }
                    }
                }

                function transitionHitTest(mouseX, mouseY) {
                    for (var i = 0; i < transitionLayer.children.length; i++) {
                        var transitionItem = transitionLayer.children[i];
                        var pos = mapToItem(transitionItem, mouseX, mouseY);
                        console.log(pos);
                        var result = transitionItem.hitTest(pos.x, pos.y);
                        console.log("transtion hit : " + result);
                        if (result) {
                            return transitionItem;
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

                onClicked: {
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
                            var hitTransition = transitionHitTest(mouse.x, mouse.y);
                            if (hitTransition) {
                                console.log("transition hitted");
                                mainView.unselectAll();
                                mainView.selectedItem = hitTransition;
                            } else  {
                                updateCursor(mouse);
                                mainView.unselectAll();
                            }
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

                onPressAndHold: {
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

                onReleased: {
                    console.log("released");

                    // drop to content if possible
                    if (drag.active) {
                        dropToContent(focusedContent);
                        updateLayout();
                        cursor.state = "";
                        mainView.state = "";
                    }

                    updateCursor(mouse);
                }

                onPositionChanged: {
                    if (drag.active) {
                        updateCursor(mouse);
                        focusedContent = cursor.currentContent;
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
                            var idx = content.calcIndex(pos.x);
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

