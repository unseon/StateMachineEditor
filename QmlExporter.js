function typeName(obj) {
    return obj.toString().split("(")[0].split("_")[0];
}

function save(url, stateMachineItem) {
    console.log("save qml to " + url);

    var textList = ["import QtQml.StateMachine 1.0"];
    textList = textList.concat(writeState(stateMachineItem));

    var text = textList.join("\n");
    //console.log(text);

    fileWriter.write(url, text);
}

function getTransitionList(fromState) {
    var result = [];

    for (var i = 0; i < mainView.transitionLayer.children.length; i++) {
        var transition = mainView.transitionLayer.children[i];
        if (transition.from === fromState) {
            result.push(transition);
        }
    }

    return result;
}

function writeState(stateItem, indent) {
    var indent = indent || 0;
    //var type = indent === 0 ? "StateMachine" : "State"
    var type = stateItem.type;

    var indentString = Array(indent * 4).join(" ");
    var result = [indentString + type + " {"];

    var propertyIndentString = Array((indent + 1) * 4).join(" ");

    var properties = [];
    properties.push(propertyIndentString + "id: " + stateItem.label);
    properties.push(propertyIndentString + "objectName: \"" + stateItem.label + "\"");
    result = result.concat(properties);

    //write states
    for (var i = 0; i < stateItem.content.children.length; i++) {
        var childStateItem = stateItem.content.children[i];
        var childText = writeState(childStateItem, indent + 1);
        result = result.concat(childText);
    }

    //write transitions
    var transitionList = getTransitionList(stateItem);

    if (transitionList.length > 0) {
        result = result.concat(writeTransitionList(transitionList, indent + 1));
    }

    result.push(indentString + "}");

    return result;
}

function writeTransitionList(transitionList, indent) {
    var result = [];
    for (var i = 0; i < transitionList.length; i++) {
        var transition = transitionList[i];
        result = result.concat(writeTransition(transition, indent));
    }

    return result;
}

function writeTransition(transition, indent) {
    var type = transition.type;

    var indentString = Array(indent * 4).join(" ");
    var result = [indentString + type + " {"];

    var properties = [];
    var propertyIndentString = Array((indent + 1) * 4).join(" ");
    properties.push(propertyIndentString + "id: " + transition.objectName);
    properties.push(propertyIndentString + "objectName: \"" + transition.objectName + "\"");
    properties.push(propertyIndentString + "targetState: " + transition.to.label);
    result = result.concat(properties);

    result.push(indentString + "}");

    return result;
}

