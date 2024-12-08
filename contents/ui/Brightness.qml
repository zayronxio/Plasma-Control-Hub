import org.kde.plasma.private.brightnesscontrolplugin
import QtQuick
import QtQuick.Controls
import org.kde.kitemmodels as KItemModels

Item {


    ScreenBrightnessControl {
        id: sbControl
        isSilent: false
    }
    Connections {
        id: displayModelConnections
        target: sbControl.displays
        property var screenBrightnessInfo: []

        function update() {
            const [labelRole, brightnessRole, maxBrightnessRole, displayNameRole] = ["label", "brightness", "maxBrightness", "displayName"].map(
                (roleName) => target.KItemModels.KRoleNames.role(roleName));

            screenBrightnessInfo = [...Array(target.rowCount()).keys()].map((i) => { // for each display index
                const modelIndex = target.index(i, 0);
                return {
                    displayName: target.data(modelIndex, displayNameRole),
                    label: target.data(modelIndex, labelRole),
                    brightness: target.data(modelIndex, brightnessRole),
                    maxBrightness: target.data(modelIndex, maxBrightnessRole),
                };
            });
            brightnessControl.mainScreen = screenBrightnessInfo[0];
        }
        function onDataChanged() { update(); }
        function onModelReset() { update(); }
        function onRowsInserted() { update(); }
        function onRowsMoved() { update(); }
        function onRowsRemoved() { update(); }
    }

    // Other properties
    property var mainScreen: displayModelConnections.screenBrightnessInfo[0]
    property bool disableBrightnessUpdate: true

    readonly property int brightnessMin: (mainScreen.maxBrightness > 100 ? 1 : 0)

    Slider {
        id: sli
        width: parent.width * 0.8
        height: 24

        from: 0
        to: mainScreen.maxBrightness
        value: mainScreen.brightness
        snapMode: Slider.SnapAlways
        onMoved: {
            sbControl.setBrightness(mainScreen.displayName, Math.max(brightnessMin, Math.min(mainScreen.maxBrightness, value))) ;
        }
    }

    Text {
        text: sbControl.isBrightnessAvailable
    }
    Connections {
        target: sbControl
    }
}
