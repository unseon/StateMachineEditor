import QtQml.StateMachine 1.0 as DSM

DSM.SignalTransition{
    property string signalName
    signal: stateMachine["signalName"]

//    property bool isInternal

//    onIsInternalChanged: {
//        this.transitionType = isInternal;
//    }
}

