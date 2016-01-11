function typeName(obj) {
    return obj.toString().split("(")[0].split("_")[0];
}

function save(url, stateMachineItem) {
    console.log("save json to " + url);

    var text = JSON.stringify(writeState(stateMachineItem), null, 4);

    fileIo.write(url, text);
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
    var type = stateItem.type;
    var tab = 4;

    var stateJson = {
        'id': stateItem.label,
        'objectName': stateItem.label,
        'type': type
    };

    // add signal when StateMachine
    if (type === "StateMachine" && stateItem.signals.count > 0) {
        var signals = [];
        for (var i = 0; i < stateItem.signals.count; i++) {
            signals.push(stateItem.signals.get(i).name);
        }

        stateJson["signals"] = signals;
    }

    //write child states
    if (stateItem.content.children.length > 0) {
        var children = [];
        for (var i = 0; i < stateItem.content.children.length; i++) {
            var childStateItem = stateItem.content.children[i];
            var childJson = writeState(childStateItem, indent + 1);
            children.push(childJson);
        }

        stateJson["children"] = children;
    }

    //write transitions
    var transitionList = getTransitionList(stateItem);

    if (transitionList.length > 0) {
        stateJson["transitions"] = writeTransitionList(transitionList, indent + 1);
    }

    return stateJson;
}

function writeTransitionList(transitionList, indent) {
    var result = [];
    for (var i = 0; i < transitionList.length; i++) {
        var transition = transitionList[i];
        result.push(writeTransition(transition, indent));
    }

    return result;
}

function writeTransition(transition, indent) {
    var type = transition.type;

    var transitionJson = {
        'type': transition.type,
        'id': transition.objectName,
        'objectName': transition.objectName,
        'targetState': transition.to.label,
        'type': transition.type
    };

    if (transition.signalName) {
        transitionJson.signalName = transition.signalName;
    }

    return transitionJson;
}

