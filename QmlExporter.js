function typeName(obj) {
    return obj.toString().split("(")[0].split("_")[0];
}

function save(stateMachineItem, url) {
    console.log("save qml");

    var a = [1];
    var b = [2];



    var textList = ["import QtQml.StateMachine 1.0"];
    textList = textList.concat(writeState(stateMachineItem));

    console.log(textList.join("\n"));
}

function writeStateMachine(stateMachineItem) {


    var result = ["StateMachine {"];

    var propertyIndentString = Array(4).join(" ");

    var properties = []

    properties.push(propertyIndentString + "id: " + stateMachineItem.label);
    properties.push(propertyIndentString + "objectName: \"" + stateMachineItem.label + "\"");

    result = result.concat(properties);

    for (var i = 0; i < stateMachineItem.content.children.length; i++) {
        var childStateItem = stateMachineItem.content.children[i];
        var childText = writeState(childStateItem, 1);
        result = result.concat(childText);
    }

    result = result.concat(["}"]);

    return result;
}

function writeState(stateItem, indent) {
    var indent = indent || 0;
    var type = typeName(stateItem);

    var indentString = Array(indent * 4).join(" ");
    var result = [indentString + type + " {"];

    var propertyIndentString = Array((indent + 1) * 4).join(" ");

    var properties = []

    properties.push(propertyIndentString + "id: " + stateItem.label);
    properties.push(propertyIndentString + "objectName: \"" + stateItem.label + "\"");

    result = result.concat(properties);

    for (var i = 0; i < stateItem.content.children.length; i++) {
        var childStateItem = stateItem.content.children[i];
        var childText = writeState(childStateItem, indent + 1);
        result = result.concat(childText);
    }

    result = result.concat([indentString + "}"]);

    return result;
}

