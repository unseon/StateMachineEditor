import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.4

StateItem {
    width: 0
    height: 0

    onWidthChanged: {
        console.log("top level width changed: " + width );
    }

    onHeightChanged: {
        console.log("top level height changed: " + height );
    }
}

