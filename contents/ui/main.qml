import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core  as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import Qt5Compat.GraphicalEffects
import org.kde.plasma.private.mpris as Mpris
import org.kde.plasma.private.volume 0.1 as Vol
import "js/funcs.js" as Funcs
import "lib" as Lib
import org.kde.bluezqt 1.0 as BluezQt
import org.kde.kcmutils // KCMLauncher
import org.kde.plasma.networkmanagement as PlasmaNM
import "components" as Components

import org.kde.plasma.private.brightnesscontrolplugin
import org.kde.notificationmanager as NotificationManager


PlasmoidItem {
    id: root

    // BLUETOOTH
    property QtObject btManager : BluezQt.Manager

    property var network: network

    property var monitor: monitor
    property var inhibitor: inhibitor

    // NOTIFICATION MANAGER
    property var notificationSettings: notificationSettings

    NotificationManager.Settings {
        id: notificationSettings
    }

    WeatherData {
		id: weatherData
	}
    // Audio source
    property var sink: paSinkModel.preferredSink
    readonly property bool sinkAvailable: sink && !(sink && sink.name == "auto_null")
    readonly property Vol.SinkModel paSinkModel: Vol.SinkModel {
        id: paSinkModel
    }
    readonly property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    property string iconNotifications: "notifications"

    property string tomorrow: Funcs.sumarDia(1)
    property string dayAftertomorrow: Funcs.sumarDia(2)
    property string twoDaysAfterTomorrow: Funcs.sumarDia(3)

    compactRepresentation: MouseArea {
        id: compactRoot

        // Taken from DigitalClock to ensure uniform sizing when next to each other
        readonly property bool tooSmall: Plasmoid.formFactor === PlasmaCore.Types.Horizontal && Math.round(2 * (compactRoot.height / 5)) <= PlasmaCore.Theme.smallestFont.pixelSize

        Layout.minimumWidth: isVertical ? 0 : compactRow.implicitWidth
        Layout.maximumWidth: isVertical ? Infinity : Layout.minimumWidth
        Layout.preferredWidth: isVertical ? undefined : Layout.minimumWidth

        Layout.minimumHeight: isVertical ? label.height : Kirigami.Theme.smallestFont.pixelSize
        Layout.maximumHeight: isVertical ? Layout.minimumHeight : Infinity
        Layout.preferredHeight: isVertical ? Layout.minimumHeight : Kirigami.Theme.mSize(Kirigami.Theme.defaultFont).height * 2

        property bool wasExpanded
        onPressed: wasExpanded = root.expanded
        onClicked: root.expanded = !wasExpanded

        Row {
            id: compactRow
            layoutDirection: iconPositionRight ? Qt.RightToLeft : Qt.LeftToRight
            anchors.centerIn: parent
            spacing: Kirigami.Units.smallSpacing
            Rectangle {
                width: root.height
                height: root.height
                color: "transparent"
                Kirigami.Icon {
                    width: parent.width
                    height: parent.height
                    source: "configure"
                }
            }
        }
    }

    fullRepresentation: Item {
        id: menu
        implicitHeight: brillo.visible ? 410 : 380
        implicitWidth: 335

        // Lists all available network connections
        Components.SectionNetworks{
            id: sectionNetworks
        }
        Components.Network {
            id: network
        }

        Column {
            id: wrapper
            anchors.verticalCenter: parent.verticalCenter
            width: menu.width
            height: menu.height

            Row {
                id: utilities // Primera mitad el widget
                width: parent.width
                height: brillo.visible ? parent.height*.4 : parent.height*.5
                spacing: 5
                Column {
                    width: parent.width/2
                    height: parent.height

                    KSvg.FrameSvgItem {
                        id: backgrounNetBlueSettings // seccion de botones de red, bluetooth y config
                        imagePath: "opaque/dialogs/background"
                        clip: true
                        anchors.right: parent.right
                        anchors.left: parent.left
                        width: parent.width - 5
                        height: parent.height - 5
                        Column {
                            width: parent.width
                            height: parent.height

                            Item {
                                id: networkItem
                                width: parent.width
                                height:  parent.height/3
                                Row {
                                    width: parent.width*.3
                                    height: parent.height
                                    Rectangle {
                                        id: bubbleButtonNet
                                        color: Kirigami.Theme.highlightColor
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.height*.7
                                        height: width
                                        radius: height/2
                                        Kirigami.Icon {
                                            id: networkIcon
                                            width: parent.width*.8
                                            height: width
                                            color: "white"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.verticalCenter: parent.verticalCenter
                                            source: network.activeConnectionIcon
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                sectionNetworks.toggleNetworkSection()
                                            }
                                        }
                                    }
                                }
                                Item {
                                    width: parent.width*.7
                                    height: parent.height
                                    anchors.right: parent.right
                                    PlasmaComponents3.Label {
                                        id: nameNetwork
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width*.9
                                        text: i18n("Network")
                                        font.pixelSize: networkItem.height*.22
                                        font.bold: true
                                    }

                                }
                            }
                            Item {
                                id: bluetooth
                                width: parent.width
                                height: parent.height/3
                                Row {
                                    width: parent.width*.3
                                    height: parent.height
                                    Rectangle {
                                        id: bubbleButtonBlue
                                        color: Kirigami.Theme.highlightColor
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.height*.7
                                        height: width
                                        radius: height/2
                                        Kirigami.Icon {
                                            id: bluetoothIcon
                                            width: parent.width*.8
                                            height: width
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: Kirigami.Theme.TextColor
                                            source: Funcs.getBtDevice() === "Disabled" ? Funcs.getBtDevice() === "Unavailable" ? "bluetooth-disabled-symbolic" : "bluetooth-active-symbolic" : "bluetooth-active-symbolic"
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                Funcs.toggleBluetooth()
                                            }
                                        }
                                    }
                                }
                                Item {
                                    width: parent.width*.7
                                    height: parent.height
                                    anchors.right: parent.right
                                    Column {
                                        width: parent.width
                                        height: nameBluetooth.height+subNameBluetooth.height
                                        anchors.verticalCenter: parent.verticalCenter
                                        PlasmaComponents3.Label {
                                            id: nameBluetooth
                                            width: parent.width*.9
                                            text: i18n("Bluetooth")
                                            font.pixelSize: bluetooth.height*.22
                                            font.bold: true
                                        }
                                        PlasmaComponents3.Label {
                                            id: subNameBluetooth
                                            width: parent.width*.9
                                            font.pixelSize: nameBluetooth.font.pixelSize*.8
                                            text: Funcs.getBtDevice()
                                        }
                                    }
                                }
                            }
                            Item {
                                id: settings
                                width: parent.width
                                height: parent.height/3
                                Row {
                                    width: parent.width*.3
                                    height: parent.height
                                    Rectangle {
                                        id: bubbleButtonSettings
                                        color: Kirigami.Theme.highlightColor
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.height*.7
                                        height: width
                                        radius: height/2

                                        Kirigami.Icon {
                                            id: settingsIcon
                                            width: parent.width*.8
                                            height: width
                                            color: "white"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.verticalCenter: parent.verticalCenter
                                            source: "configure"
                                        }
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                     KCMLauncher.openSystemSettings("")
                                                }
                                            }
                                        }

                                    }
                                    Item {
                                            width: parent.width*.7
                                            height: parent.height
                                            anchors.right: parent.right
                                            Column {
                                                width: parent.width
                                                height: nameSettigns.height+subNameSettigns.height
                                                anchors.verticalCenter: parent.verticalCenter

                                                PlasmaComponents3.Label {
                                                    id: nameSettigns
                                                    width: parent.width*.9
                                                    text: i18n("Settings")
                                                    font.pixelSize: setting.height*.22
                                                    font.bold: true
                                                }
                                                PlasmaComponents3.Label {
                                                    id: subNameSettigns
                                                    width: parent.width*.9
                                                    text: i18n("System Settings")
                                                    font.pixelSize: nameSettigns.font.pixelSize*.8
                                                }
                                            }
                                        }
                                }
                         }
                }

            }
                Column {
                    width:  parent.width/2
                    height: parent.height
                    Item {
                        width: parent.width -5
                        height: parent.height
                        visible: false
                    }
                    Column {
                        id: fullweather
                        width: parent.width -5
                        height: parent.height
                        visible: minimalweatherAndToggles.visible == true ? false : true

                        KSvg.FrameSvgItem {
                            imagePath: "opaque/dialogs/background"
                            clip: true
                            anchors.right: parent.right
                            anchors.left: parent.left
                            width: parent.width
                            height: parent.height - 5
                            Column {
                                width: parent.width
                                height: parent.height
                                Row {
                                    id: onefullweather
                                    width: parent.width
                                    height: parent.height*.16
                                    PlasmaComponents3.ToolButton {
                                        id: arrowbutton
                                        width: 22
                                        Layout.preferredHeight: parent.height
                                        icon.name: "arrow-left"
                                        onClicked: {
                                            minimalweatherAndToggles.visible = true
                                        }
                                }
                                 PlasmaComponents3.Label  {
                                        text:  "weather forecast"
                                        width: parent.width - arrowbutton.width
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.bold: true
                                        font.pixelSize: tomorrowDayText.font.pixelSize

                                    }
                                }
                                Row {
                                    id: twofullweather
                                    width: parent.width
                                    height: parent.height*.28
                                    Kirigami.Icon {
                                        id: tomorrowWeatherIcon
                                        width: parent.height*.7
                                        source: weatherData.asingicon(weatherData.codeweatherTomorrow)
                                        anchors.verticalCenter: twofullweather.verticalCenter // Centrar verticalmente

                                    }
                                    PlasmaComponents3.Label  {
                                        id: tomorrowDayText
                                        width: parent.width-maxAndMincTomorrow.width-tomorrowWeatherIcon.height-5
                                        height: parent.height
                                        text:  tomorrow.substring(0, 3)
                                        font.pixelSize: fullweather.width*.085
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    Row {
                                        id: maxAndMincTomorrow
                                        spacing: 2.5
                                        height: parent.height
                                        width: minTomorrow.width+separatorTomorrow.width+maxTomorrow.width+10
                                        PlasmaComponents3.Label  {
                                            id: minTomorrow
                                            height: parent.height
                                            font.pixelSize: tomorrowDayText.font.pixelSize
                                            text: weatherData.minweatherTomorrow+"°"
                                            verticalAlignment: Text.AlignVCenter

                                        }
                                    PlasmaComponents3.Label  {
                                        id: separatorTomorrow
                                        height: parent.height
                                        font.pixelSize: tomorrowDayText.font.pixelSize
                                        text:  "|"
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    PlasmaComponents3.Label  {
                                        id: maxTomorrow
                                        text:  weatherData.maxweatherTomorrow+"°"
                                        font.pixelSize: tomorrowDayText.font.pixelSize
                                        height: parent.height
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    }
                                }
                                Row {
                                    id: threefullweather
                                    width: parent.width
                                    height: parent.height*.28
                                    Kirigami.Icon {
                                        id: dayAftertomorrowWeatherIcon
                                        width: parent.height*.7
                                        source: weatherData.asingicon(weatherData.codeweatherDayAftertomorrow)
                                        anchors.verticalCenter: threefullweather.verticalCenter // Centrar verticalmente

                                    }
                                     PlasmaComponents3.Label  {
                                        width: parent.width-maxAndMincTomorrow.width-tomorrowWeatherIcon.height-5
                                        height: parent.height
                                        text: dayAftertomorrow.substring(0, 3)
                                        font.pixelSize: tomorrowDayText.font.pixelSize
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    Row {
                                        id: maxAndMinDayAftertomorrow
                                        spacing: 2.5
                                        height: parent.height
                                        width: minDayAftertomorrow.width+separatorDayAftertomorrow.width+maxDayAftertomorrow.width+10
                                        PlasmaComponents3.Label  {
                                            id: minDayAftertomorrow
                                            height: parent.height
                                            font.pixelSize: tomorrowDayText.font.pixelSize
                                            text: weatherData.minweatherDayAftertomorrow+"°"
                                            verticalAlignment: Text.AlignVCenter

                                        }
                                    PlasmaComponents3.Label  {
                                        id: separatorDayAftertomorrow
                                        height: parent.height
                                        font.pixelSize: tomorrowDayText.font.pixelSize
                                        text:  "|"
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    PlasmaComponents3.Label  {
                                        id: maxDayAftertomorrow
                                        text:  weatherData.maxweatherDayAftertomorrow+"°"
                                        font.pixelSize: tomorrowDayText.font.pixelSize
                                        height: parent.height
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    }
                                }
                                Row {
                                    id: fordfullweather
                                    width: parent.width
                                    height: parent.height*.28
                                    Kirigami.Icon {
                                        id: twoDaysAfterTomorrowWeatherIcon
                                        width: parent.height*.7
                                        source: weatherData.asingicon(weatherData.codeweatherTwoDaysAfterTomorrow)
                                        anchors.verticalCenter: threefullweather.verticalCenter // Centrar verticalmente

                                    }
                                     PlasmaComponents3.Label  {
                                        width: parent.width-maxAndMinTwoDaysAfterTomorrow.width-twoDaysAfterTomorrowWeatherIcon.height-5
                                        height: parent.height
                                        text:  twoDaysAfterTomorrow.substring(0, 3)
                                        font.pixelSize: tomorrowDayText.font.pixelSize
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    Row {
                                        id: maxAndMinTwoDaysAfterTomorrow
                                        spacing: 2.5
                                        height: parent.height
                                        width: minTwoDaysAfterTomorrow.width+separatorTwoDaysAfterTomorrow.width+maxTwoDaysAfterTomorrow.width+10
                                        PlasmaComponents3.Label  {
                                            id: minTwoDaysAfterTomorrow
                                            height: parent.height
                                            font.pixelSize: tomorrowDayText.font.pixelSize
                                            text: weatherData.minweatherTwoDaysAfterTomorrow+"°"
                                            verticalAlignment: Text.AlignVCenter

                                        }
                                    PlasmaComponents3.Label  {
                                        id: separatorTwoDaysAfterTomorrow
                                        height: parent.height
                                        font.pixelSize: tomorrowDayText.font.pixelSize
                                        text:  "|"
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    PlasmaComponents3.Label  {
                                        id: maxTwoDaysAfterTomorrow
                                        text:  weatherData.maxweatherTwoDaysAfterTomorrow+"°"
                                        font.pixelSize: tomorrowDayText.font.pixelSize
                                        height: parent.height
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    }

                                }
                            }
                        }
                    }
                    Column {
                        id: minimalweatherAndToggles
                        width: parent.width -5
                        height: parent.height/2
                        visible: true
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                minimalweatherAndToggles.visible = false
                            }
                        }
                        KSvg.FrameSvgItem {

                            imagePath: "opaque/dialogs/background"
                            clip: true
                            anchors.right: parent.right
                            anchors.left: parent.left
                            width: parent.width
                            height: parent.height - 5
                            Row {
                                width: parent.width
                                height: parent.height

                                Item {
                                    width: parent.width*.35
                                    height: parent.height
                                    Rectangle {
                                        id: propertyColorText
                                        color: Kirigami.Theme.TextColor
                                        width: 1
                                        height: 1
                                        visible: false
                                    }
                                    Rectangle {
                                        id: rectangleBackgroundTemperature
                                        width: parent.width < parent.height ? parent.width*.85 : parent.height*.85
                                        height: width
                                        color: ((propertyColorText.color).toString())[0]+"23"+((propertyColorText.color).toString())[1]+((propertyColorText.color).toString())[2]+((propertyColorText.color).toString())[3]+((propertyColorText.color).toString())[4]+((propertyColorText.color).toString())[5]+((propertyColorText.color).toString())[6]
                                        radius: width/2
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        Row {
                                                id: textTemWeather2
                                                width: tem2.width + numenclatura2.width
                                                height: tem2.implicitHeight-5
                                                anchors.leftMargin: (rectangleBackgroundTemperature.width-tem2.width)/2
                                                anchors.left: parent.left
                                                anchors.top: parent.top
                                                anchors.topMargin: (rectangleBackgroundTemperature.height-tem2.height)/2
                                                PlasmaComponents3.Label {
                                                    id: tem2
                                                    text: Math.round(Number(weatherData.temperaturaActual))
                                                    font.pixelSize: rectangleBackgroundTemperature.height*.3
                                                    font.bold: true
                                                }
                                                PlasmaComponents3.Label {
                                                    id: numenclatura2
                                                    text: "°C"
                                                    font.pixelSize: tem2.font.pixelSize*.7
                                                    anchors.top: tem.top
                                                    font.bold: true
                                                }
                                            }
                                    }
                                }
                                Item {
                                    id: twc
                                    width: parent.width*.65
                                    height: parent.height
                                    Column {
                                        width: parent.width
                                        height: weatherCurrent2.height
                                        anchors.verticalCenter: parent.verticalCenter
                                        PlasmaComponents3.Label {
                                            id: weatherCurrent2
                                            text: weatherData.weathertext
                                            font.pixelSize: weatherData.weathertext.length < 11 ? twc.height*.2 : twc.height*.16
                                            width: parent.width
                                            wrapMode: Text.WordWrap
                                            elide: Text.ElideRight
                                            maximumLineCount: 2
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }
                            }

                       }

                    }
                    Row {
                        width: parent.width -5
                        height: (parent.height/2) - 5
                        spacing: 5
                        visible: minimalweatherAndToggles.visible
                        Item {
                            width: weatherToggle.visible ? (parent.width/2) - 2.5 : parent.width
                            height: parent.height
                            KSvg.FrameSvgItem {
                                imagePath: "opaque/dialogs/background"
                                clip: true
                                anchors.right: parent.right
                                anchors.left: parent.left
                                width: parent.width
                                height: parent.height

                                Column {
                                    width: parent.width
                                    height: parent.height
                                    Item {
                                        width: parent.width
                                        height: parent.height*.6
                                        Kirigami.Icon {
                                            id: iconOfRedshift
                                            implicitHeight: parent.height*.9
                                            visible: true
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            source: {
                                                if (!monitor.enabled) {
                                                    return "redshift-status-off"; // not configured: show generic night light icon rather "manually turned off"icon
                                                    } else if (!monitor.running) {
                                                        return "redshift-status-on";

                                                    } else if (monitor.daylight && monitor.targetTemperature != 6500) { // show daylight icon only when temperature during the day is actually modified
                                                        return "redshift-status-day";

                                                    } else {
                                                        return "redshift-status-on";

                                                    }
                                                }
                                                MouseArea {
                                                    anchors.fill: parent
                                                    onClicked: toggleInhibition()
                                                    function toggleInhibition() {
                                                        if (!monitor.available) {
                                                            return;
                                                        }
                                                        switch (inhibitor.state) {
                                                            case NightColorInhibitor.Inhibiting:
                                                            case NightColorInhibitor.Inhibited:
                                                                inhibitor.uninhibit();
                                                                break;
                                                            case NightColorInhibitor.Uninhibiting:
                                                            case NightColorInhibitor.Uninhibited:
                                                                inhibitor.inhibit();
                                                                break;
                                                        }
                                                    }
                                                    NightColorInhibitor {
                                                        id: inhibitor
                                                    }
                                                    NightColorMonitor {
                                                        id: monitor
                                                        readonly property bool transitioning: monitor.currentTemperature != monitor.targetTemperature
                                                        readonly property bool hasSwitchingTimes: monitor.mode != 3
                                                    }
                                                }
                                        }
                                    }
                                    Item {
                                        id: labelredfish
                                        width: parent.width
                                        height: parent.height*.4
                                         Label {
                                             id: textOfNightLight
                                             width: parent.width
                                             text: {
                                                if (!monitor.enabled) {
                                                    return i18n("Off"); // not configured: show generic night light icon rather "manually turned off"icon
                                                    } else if (!monitor.running) {
                                                        return  i18n("On");

                                                    } else if (monitor.daylight && monitor.targetTemperature != 6500) { // show daylight icon only when temperature during the day is actually modified
                                                        return  i18n("Off");

                                                    } else {
                                                        return  i18n("On");

                                                    }

                                            }
                                            font.pixelSize: labelredfish.height*.35
                                            horizontalAlignment: Text.AlignHCenter
    }
                                    }



                                }
                            }
                        }
                        Item {
                            id: weatherToggle
                            width: (parent.width/2) -2.5
                            height: parent.height
                            visible: minimalweatherAndToggles.visible
                            KSvg.FrameSvgItem {
                                imagePath: "opaque/dialogs/background"
                                clip: true
                                anchors.right: parent.right
                                anchors.left: parent.left
                                width: parent.width
                                height: parent.height
                               Column {
                                width: parent.width
                                height: parent.height

                                Item {
                                    width: parent.width
                                    height: parent.height*.6
                                        Kirigami.Icon {
                                            implicitHeight: parent.height*.9
                                            color: Kirigami.Theme.TextColor
                                            source: Funcs.checkInhibition() ? "notifications-disabled" : "notifications"
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            MouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                onClicked: Funcs.toggleDnd();
                                            }
                                        }
                                }
                                Item {
                                    id: boxDontDisturb
                                    width: parent.width
                                    height: parent.height*.4

                                        PlasmaComponents3.Label {
                                            id: textdontDis
                                            text: i18n("Don't Disturb")
                                            width: parent.width*.9
                                            font.pixelSize: weatherToggle.height < weatherToggle.width ? weatherToggle.height*.14 : weatherToggle.width*.14
                                            wrapMode: Text.WordWrap
                                            elide: Text.ElideRight
                                            maximumLineCount: 2
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignHCenter
                                            anchors.verticalCenter: parent.verticalCenter
                                            //font.bold: true
                                        }
                                }
                            }
                            }
                        }
                    }
                }
            } // fin Primera mitad el widget
//****************************************************//

            Item {
                id: brillo
                width: parent.width
                height: parent.height*.2
                visible: false // en espera de actualizacion
                KSvg.FrameSvgItem {
                    imagePath: "opaque/dialogs/background"
                    clip: true
                    anchors.right: parent.right
                    anchors.left: parent.left
                    width: parent.width
                    height: parent.height - 5

                }
            }

            Item {
                id: volumen
                width: parent.width
                height: brillo.visible ? parent.height*.2 : parent.height*.25
                 KSvg.FrameSvgItem {
                     id: windowsvolumen

                    imagePath: "opaque/dialogs/background"
                    clip: true
                    anchors.right: parent.right
                    anchors.left: parent.left
                    width: parent.width
                    height: parent.height - 5
                    Column {
                        id: columnSettingsVolume
                        width: windowsvolumen.width/5
                        height: windowsvolumen.height
                        anchors.right: windowsvolumen.right
                        Item {
                            id: buttonsettingPulseAudio
                            width: columnSettingsVolume.width
                            height: columnSettingsVolume.height/2
                            anchors.bottom: columnSettingsVolume.bottom
                            Rectangle {
                                width: parent.height*.7
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: width
                                color: "#26000000"
                                radius: height/2
                                Kirigami.Icon {
                                    width: parent.width*.7
                                    height: width
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    source: "configure"
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        KCMLauncher.openSystemSettings("kcm_pulseaudio")
                                    }
                                }
                            }
                        }
                    }
                    Column {
                        width: windowsvolumen.width*.95
                        height: parent.height
                        anchors.right: parent.right
                        Item {
                            width: parent.width
                            height: parent.height/2
                            PlasmaComponents3.Label {
                                text: i18n("Volume")
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Slider {
                            id: slider
                            width: (parent.width*.81)-6
                            height: parent.height/2
                            anchors.bottom: parent.bottom
                            from: 1
                            value: (sink.volume / Vol.PulseAudio.NormalVolume * 100)
                            to: 100
                            snapMode: Slider.SnapAlways
                            onMoved: {
                                sink.volume = value * Vol.PulseAudio.NormalVolume / 100
                            }
                            background: Rectangle {
                                id: backOfSlider
                                width: parent.width
                                height: parent.height*.7
                                color: "#26000000"
                                radius: height/2
                                Rectangle {
                                    id: bar
                                    width: (slider.visualPosition * parent.width) + handleSlider.width*(1-slider.visualPosition)
                                    height: backOfSlider.height
                                    color: slider.value < 5 ? "transparent" : "white"
                                    border.color: slider.value < 5 ? "transparent" : "#bdbebf"
                                    radius: height/2
                                    Kirigami.Icon {
                                        id: maskvolumenicon
                                        width: parent.height*.9
                                        source: "volume-level-high-panel"
                                        anchors.verticalCenter: parent.verticalCenter

                                    }
                                    Rectangle {
                                        width: parent.height*.8
                                        height: width
                                        color: Kirigami.Theme.highlightColor
                                        layer.enabled: true
                                        layer.effect: OpacityMask {
                                            maskSource: maskvolumenicon

                                        }
                                        anchors.verticalCenter: parent.verticalCenter
                                        opacity: .4

                                    }

                                }

                            }
                            handle: Rectangle {
                                id: handleSlider
                                x: ((backOfSlider.width-width)*slider.visualPosition)
                                y: slider.topPadding + slider.availableHeight / 2 - bar.height*.73
                                implicitWidth: bar.height
                                implicitHeight: bar.height
                                radius: implicitHeight/2
                                color: "white"
                                border.color: "#bdbebf"

                            }
                        }
                    }

                 }

            }
            Item {
                id: mutimedia
                width: parent.width
                height: brillo.visible ? parent.height*.2 : parent.height*.25

                KSvg.FrameSvgItem {
                    id: rect

                    imagePath: "opaque/dialogs/background"
                    clip: true
                    anchors.right: parent.right
                    anchors.left: parent.left
                    width: parent.width
                    height: parent.height - 5
                    Row {
                        id: baseMultimedia
                        width: parent.width
                        height: parent.height
                        Rectangle {
                            id: margin
                            width: 8
                            height: parent.height
                            color: "transparent"
                        }
                        Rectangle {
                            id: maskalbum
                            color: "red"
                            width: height
                            height: mutimedia.height*.65
                            radius: height/8
                            visible: false
                        }
                        Image {
                            id: nocover
                            width: maskalbum.width
                            height: maskalbum.height
                            source: "img/nocover.svg"
                            sourceSize: Qt.size(width, width)
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
                            visible: !mpris2Model.currentPlayer?.artUrl
                            Kirigami.Icon {
                                source: "multimedia-audio-player"
                                width: parent.width *.6
                                height: width
                                anchors.centerIn: parent
                            }
                        }
                        Image {
                            anchors.verticalCenter: parent.verticalCenter
                            width: maskalbum.width
                            height: maskalbum.height
                            source: mpris2Model.currentPlayer?.artUrl
                            visible: !mpris2Model.currentPlayer?.artUrl ? false : true
                            layer.enabled: true
                                  layer.effect: OpacityMask {
                                  maskSource: maskalbum
                        }
                        }
                         Rectangle {
                            id: margin2
                            width: 8
                            height: parent.height
                            color: "transparent"
                        }
                        Rectangle {
                            id: contenedorInfoMusic
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - maskalbum.width - margin.width*3 - controlsMultimedia.width
                            height: artist2.text.length > 1 ? title2.height + artist2.height : title2.height
                            color: "transparent"
                            Column {
                            width: parent.width
                            height: parent.height
                            PlasmaComponents3.Label {
                                id: title2
                                width: (contenedorInfoMusic.width - controlsMultimedia.width)
                                text: mpris2Model.currentPlayer?.track
                                font.pixelSize: mutimedia.height*.15
                                font.bold: true
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                maximumLineCount: 2
                            }
                            PlasmaComponents3.Label {
                                width: (contenedorInfoMusic.width - controlsMultimedia.width)
                                id: artist2
                                text: mpris2Model.currentPlayer?.artist ?? ""
                                font.pixelSize: mutimedia.height*.14
                                elide: Text.ElideRight
                                visible: artist2.text.length > 1 ? true : false
                                opacity: .80
                            }
                        }

                        }
                        Row {
                            id: controlsMultimedia
                            width: 46
                            height: 22
                            spacing: 2
                            anchors.verticalCenter: parent.verticalCenter
                            function next() {
                                mpris2Model.currentPlayer.Next();

                            }

                             Kirigami.Icon {
                                 id: iconplay
                                 width: 22
                                 height: width
                                 source: (mpris2Model.currentPlayer?.playbackStatus ?? 0) === Mpris.PlaybackStatus.Playing ? "media-playback-pause" : "media-playback-start"
                                 roundToIconSize: false
                                 MouseArea {
                                     anchors.fill: parent
                                     onClicked: mpris2Model.currentPlayer.PlayPause();
                                }
                             }
                             Kirigami.Icon {
                                 id: nextplay
                                 width: 22
                                 height: width
                                 source: "media-skip-forward"
                                 roundToIconSize: false
                                 MouseArea {
                                     anchors.fill: parent
                                     onClicked:  mpris2Model.currentPlayer.Next();
                                }
                             }

                        }


                    }
                    }


            }

        }
    }

    Mpris.Mpris2Model {
        id: mpris2Model
    }
    Timer {
        id: weatherupdate
        interval: 900000
        running: true
        repeat: true
        onTriggered: {
            weatherData.executeCommand()
            tomorrow = Funcs.sumarDia(1)
            dayAftertomorrow = Funcs.sumarDia(2)
            twoDaysAfterTomorrow = Funcs.sumarDia(3)

        }
    }
     Timer {
        interval: 100 // Tiempo en milisegundos (en este caso, se ejecutará después de 1 segundo)
        repeat: false // No se repite
        running: true // Comienza a correr automáticamente cuando la aplicación inicia
        onTriggered: {
           weatherData.executeCommand()
        }
    }
}

