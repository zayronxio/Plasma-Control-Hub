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
import org.kde.bluezqt 1.0 as BluezQt

PlasmoidItem {
    id: root

     // BLUETOOTH
    property QtObject btManager : BluezQt.Manager

    // Audio source
    property var sink: paSinkModel.preferredSink
    readonly property bool sinkAvailable: sink && !(sink && sink.name == "auto_null")
    readonly property Vol.SinkModel paSinkModel: Vol.SinkModel {
        id: paSinkModel
    }
    readonly property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

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
          implicitHeight: 200
        implicitWidth: 100

        Column {
            id: columnone
            anchors.verticalCenter: parent.verticalCenter
            width: menu.width
            height: menu.height

            Row {
                id: utilities
                width: parent.width
                height: parent.height*.4
                spacing: 5
                Column {
                    width: parent.width/2
                    height: parent.height
                    KSvg.FrameSvgItem {
                        id: backgrounNetBlueSettings
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
                                    id: network
                                    width: parent.width
                                    height: parent.height/3
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
                                                source: "bluetooth"
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
                                            PlasmaComponents3.Label {
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: parent.width*.9
                                                text: i18n("bluetooth")
                                            }
                                        }
                                }
                                Item {
                                    id: settings
                                    width: parent.width
                                    height: parent.height/3
                                }
                         }
                }

                }
                Column {
                    width: parent.width/2
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

                       }

                    }
                    Row {
                        width: parent.width -5
                        height: (parent.height/2) - 5
                        spacing: 5
                        Item {
                            width: (parent.width/2) - 2.5
                            height: parent.height
                            KSvg.FrameSvgItem {
                                imagePath: "translucent/dialogs/background"
                                clip: true
                                anchors.right: parent.right
                                anchors.left: parent.left
                                width: parent.width
                                height: parent.height
                            }
                        }
                        Item {
                            width: (parent.width/2) -2.5
                            height: parent.height
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
            }

            Item {
                id: brillo
                width: parent.width
                height: parent.height*.2
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
                height: parent.height*.2
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
                            width: columnSettingsVolume.width
                            height: columnSettingsVolume.height/2
                            anchors.bottom: columnSettingsVolume.bottom
                            Rectangle {
                                width: parent.height*.7
                                anchors.horizontalCenter: parent.horizontalCenter
                                height: width
                                color: "#26000000"
                                radius: height/2
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
                        width: backOfSlider.width-6
                        height: backOfSlider.height-6
                        anchors.centerIn: backOfSlider
                        color: kirigami.Theme.TextColor
                        radius: height/2

                        Kirigami.Icon {
                            id: maskvolumenicon
                            width: parent.height*.8
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
                   y: slider.topPadding + slider.availableHeight / 2 - bar.height*.77
                   implicitWidth: bar.height
                   implicitHeight: bar.height
                   radius: implicitHeight/2
                   color: kirigami.Theme.TextColor
                   border.color: "#bdbebf"
    }

}
                    }

                 }

            }
            Item {
                id: mutimedia
                width: parent.width
                height: parent.height*.2

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

