import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.11
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: configRoot


    signal configurationChanged


    property alias cfg_latitudeC: latitude.text
    property alias cfg_longitudeC: longitude.text
    property alias cfg_useCoordinatesIp: autamateCoorde.checked

    property alias cfg_userAndAvaAveilable: usrCheck.checked

    ColumnLayout {
        spacing: units.smallSpacing * 2



RowLayout{
             CheckBox {
            id: autamateCoorde
            text: i18n('use geographic coordinates established by IP address')
            Layout.columnSpan: 2
        }
}
ColumnLayout {
    Item{
        width: configRoot.width
        height: instructions.height*2.5
        Label {
            id: instructions
           visible: (autamateCoorde.checked === true) ? false : true
           wrapMode: Text.WordWrap
           width: parent.width
           text:  i18n("To know your geographic coordinates, I recommend using the following website https://open-meteo.com/en/docs")
       }
    }
  RowLayout{
            visible: (autamateCoorde.checked === true) ? false : true
            Label {
                text: i18n("latitude")
            }
             TextField {
            id: latitude
            width: 200
              }

        }
        RowLayout{
            visible: (autamateCoorde.checked === true) ? false : true
            Label {
                text: i18n("longitude")
            }
             TextField {
            id: longitude
            width: 200
              }

        }
   }
   GridLayout {
       columns: 2
       Label {
           width: configRoot.width/2
           text: "Avatar And Name User"
    }
    CheckBox {
        id: usrCheck

    }
}

}

}
