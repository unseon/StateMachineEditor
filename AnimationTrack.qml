import QtQuick 2.5

Rectangle {
    id: track
    color: "white"
    border.width: 1
    border.color: "#AAAAAA"

    property alias durationBar: durationBar
    property int duration: 100
    property int start: 50
    property bool isParallel: false
    property var anim

    onIsParallelChanged: {
        track.anim.rootAnimation().track.update(0)
    }

    onStartChanged: {
        barTail.x = track.start + track.duration
    }

    onDurationChanged: {
        durationBar.width = duration
        track.anim.rootAnimation().track.update(0)
    }

    Rectangle {
        id: durationBar
        x: track.start
        width: track.duration
        height: parent.height
        color: track.anim.isGroup ? "#DDEEDD" : "#88DD88"
        border.width: 1
        border.color: "#AAAAAA"

        Behavior on x {
            id: smoothAnim
            enabled: false
            SmoothedAnimation {
                duration: 200
            }
        }

        Timer {
            running: true
            interval: 0
            onTriggered: {
                smoothAnim.enabled = true
            }
        }


        Rectangle {
            anchors.right: parent.right
            width: 2
            height: parent.height
            color: "#AAFFAA"
            visible: tailHandler.containsMouse || tailHandler.pressed
        }
    }

    Item {
        id: barTail
        x: track.start + track.duration
        height: parent.height
        MouseArea {
            id: tailHandler
            visible: !track.anim.isGroup
            x: -5
            width: 15
            height: parent.height
            drag.axis: Drag.XAxis
            drag.target: barTail
            drag.minimumX: durationBar.x
            hoverEnabled: true

            onReleased: {
                barTail.x = track.start + track.duration
                track.anim.rootAnimation().track.update(0)
            }
        }
        onXChanged: {
            track.duration = Math.floor((barTail.x - track.start) / 10) * 10
        }
    }

    function update(startTime: int):int {
        start = startTime
        var endTime = startTime

        if (!anim.isGroup) {
            endTime += duration
        } else {

            if (track.isParallel) {
                for (var i = 0; i < anim.content.children.length; i++) {
                    var childTrack = anim.content.children[i].track
                    //console.log("childTrack", childTrack, anim.content.children[i])
                    endTime = Math.max(childTrack.update(startTime), endTime)
                }

            } else {
                for (var i = 0; i < anim.content.children.length; i++) {
                    var childTrack = anim.content.children[i].track
                    //console.log("childTrack", childTrack, anim.content.children[i])
                    endTime = childTrack.update(endTime)
                }
            }
        }
        duration = endTime - startTime

        return endTime
    }
}
