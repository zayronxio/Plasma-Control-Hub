import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core  as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import Qt5Compat.GraphicalEffects
import org.kde.plasma.private.mediacontroller 1.0
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
import org.kde.plasma.plasma5support as Plasma5Support

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
    // Audio source
    property var sink: paSinkModel.preferredSink
    readonly property bool sinkAvailable: sink && !(sink && sink.name == "auto_null")
    readonly property Vol.SinkModel paSinkModel: Vol.SinkModel {
        id: paSinkModel
    }
    readonly property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    property string iconNotifications: "notifications"

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
        implicitHeight: brillo.visible ? 410 : 350
        implicitWidth: 300

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
                        imagePath: "translucent/dialogs/background"
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
                                            text: i18n("bluetooth")
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

                    Column {
                        width: parent.width -5
                        height: parent.height/2
                        KSvg.FrameSvgItem {

                            imagePath: "translucent/dialogs/background"
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
                                        width: parent.width < parent.height ? parent.width*.85 : parent.height*.85
                                        height: width
                                        color: "#26000000"
                                        radius: width/2
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        Kirigami.Icon {
                                            width: parent.width*.8
                                            height: width
                                            color: Kirigima.Theme.TextColor
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
                                }
                                Item {
                                    id: boxDontDisturb
                                    width: parent.width*.65
                                    height: parent.height
                                    Column {
                                        width: parent.width
                                        height: textdontDis.height+subTextdontDis.height
                                        anchors.verticalCenter: parent.verticalCenter
                                        Label {
                                            id: textdontDis
                                            text: i18n("Don't Disturb")
                                            font.pixelSize: boxDontDisturb.width*.11
                                            font.bold: true
                                        }
                                        Label {
                                            id: subTextdontDis
                                            text: Funcs.checkInhibition() ? i18n("Off") : i18n("On")
                                            font.pixelSize: boxDontDisturb.width*.09
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
                        Item {
                            width: doggledarktheme.visible ? (parent.width/2) - 2.5 : parent.width
                            height: parent.height
                            KSvg.FrameSvgItem {
                                imagePath: "translucent/dialogs/background"
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
                                            width: parent.height
                                            height: width
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
                                            font.pixelSize: labelredfish.height*.4
                                            horizontalAlignment: Text.AlignHCenter
    }
                                    }



                                }
                            }
                        }
                        Item {
                            id: doggledarktheme
                            width: (parent.width/2) -2.5
                            height: parent.height
                            visible: false // en espera de actualizacion
                            KSvg.FrameSvgItem {
                                imagePath: "translucent/dialogs/background"
                                clip: true
                                anchors.right: parent.right
                                anchors.left: parent.left
                                width: parent.width
                                height: parent.height
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
                    imagePath: "translucent/dialogs/background"
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

                    imagePath: "translucent/dialogs/background"
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
                        width: slider.value < 75 ? backOfSlider.width/28 + slider.visualPosition * parent.width :  slider.value < 50 ? backOfSlider.width/15 + slider.visualPosition * parent.width : slider.value < 35 ? backOfSlider.width/5 + slider.visualPosition * parent.width : slider.value < 20 ?  backOfSlider.width/2 - slider.visualPosition * parent.width/4 : slider.value < 10 ?  backOfSlider.width*1.5 + slider.visualPosition * parent.width : slider.value < 5 ?  backOfSlider.width/1 + slider.visualPosition * parent.width : slider.visualPosition * parent.width
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
                   x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
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

                    imagePath: "translucent/dialogs/background"
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
                            anchors.verticalCenter: parent.verticalCenter
                            width: maskalbum.width
                            height: maskalbum.height
                            source: mpris2Model.currentPlayer?.artUrl
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
                            height: title2.height + artist2.height
                            color: "transparent"
                            Column {
                            width: parent.width
                            height: parent.height
                            PlasmaComponents3.Label {
                                id: title2
                                text: mpris2Model.currentPlayer?.track
                                font.pixelSize: mutimedia.height*.15
                                font.bold: true
                            }
                            PlasmaComponents3.Label {
                                id: artist2
                                text: mpris2Model.currentPlayer?.artist ?? ""
                                font.pixelSize: mutimedia.height*.14
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
                                 source: "player-play"
                                 roundToIconSize: false
                             }
                             Kirigami.Icon {
                                 id: nextplay
                                 width: 22
                                 height: width
                                 source: "media-skip-forward"
                                 roundToIconSize: false
                                 MouseArea {
                                     anchors.fill: parent
                                     onClicked: next()
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
}

