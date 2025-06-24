import QtQuick
import QtCore
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors

Item {

    Settings {
        id: plasmaHubNightLightControl
        category: "NightLightControl"
        // property var files: []
    }

    property bool nightLight: plasmaHubNightLightControl.value("toggleInhibition") !== undefined ? typeof plasmaHubNightLightControl.value("toggleInhibition") !== "boolean" ? plasmaHubNightLightControl.value("toggleInhibition") === "true" ? true : (false) : plasmaHubNightLightControl.value("toggleInhibition") : false

    property string code: ""
    property var control

    property string sourceBrightnessPlasma64orPlusQml: `
    import QtQuick
    import "components" as Components
    Components.SourceBrightnessPlasma64orPlus {
        id: dynamic
    }
    `
    property string sourceBrightnessQML: `
    import QtQuick
    import "components" as Components
    Components.SourceBrightness {
        id: dynamic
    }
    `

    Sensors.SensorDataModel {
        id: plasmaVersionModel
        sensors: ["os/plasma/plasmaVersion"]
        enabled: true

        onDataChanged: {
            const value = data(index(0, 0), Sensors.SensorDataModel.Value);
            if (value !== undefined && value !== null) {
                if (value.indexOf("6.4") >= 0) {
                    console.log("version de plasma identificada, 6.4 o posterior")
                    code = sourceBrightnessPlasma64orPlusQml;
                } else {
                    console.log("version de plasma identificada, 6.4 o posterior")
                    code = sourceBrightnessQML;
                }

                // Crea el nuevo componente
                control = Qt.createQmlObject(code, root, "control");
            }
        }
    }
    Kirigami.Icon {
        id: iconOfRedshift
        height: parent.height*.54

        anchors.top: parent.top
        anchors.topMargin: parent.height*.03
        anchors.horizontalCenter: parent.horizontalCenter
        source: nightLight ? "redshift-status-on" : "redshift-status-off"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                control.nightMode()
                plasmaHubNightLightControl.setValue("toggleInhibition", !nightLight)
                nightLight = plasmaHubNightLightControl.value("toggleInhibition") !== undefined ? typeof plasmaHubNightLightControl.value("toggleInhibition") !== "boolean" ? plasmaHubNightLightControl.value("toggleInhibition") === "true" ? true : (false) : plasmaHubNightLightControl.value("toggleInhibition") : false
            }
        }
    }

    Kirigami.Heading {
        id: name
        text: nightLight ? "On" : "Off"
        //font.weight: Font.DemiBold
        width: parent.width
        level: 4
        horizontalAlignment: Text.AlignHCenter
        anchors.top: iconOfRedshift.bottom
    }
}
