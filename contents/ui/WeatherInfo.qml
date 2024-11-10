import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import "components" as Components

Item {

    property color logoColor: "white"
    property string nameLogo: ""
    property string city: ""

    Components.WeatherData {
        id: weatherData
    }

    Item {
        id: wrapperWeatherMinimal
        width: parent.width
        height: parent.height
        //spacing: 5
        visible: true
        Kirigami.Icon {
            id: logo
            source: weatherData.iconWeatherCurrent
            color: Kirigami.Theme.textColor
            width: parent.height *.65
            height: width
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            id: currentTemp
            width: textTempCurrent.implicitWidth
            height: textTempCurrent.implicitHeight
            anchors.left: parent.left
            anchors.leftMargin: logo.width + 5
            anchors.verticalCenter: parent.verticalCenter
            Text {
                id: textTempCurrent
                width: parent.width
                text: weatherData.currentTemperature === "failed" ? "?" : weatherData.currentTemperature + "°"
                font.pixelSize: wrapperWeatherMinimal.height*.5
                color: Kirigami.Theme.textColor
                font.bold: true
                verticalAlignment: Text.AlignVCenter
            }
        }
        Item {
            width: parent.width - logo.width - currentTemp.width - 20
            height: (weatherData.city !== "unk") ? textWeather.implicitHeight + textCity.implicitHeight + 3 : textWeather.implicitHeight
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
            Row {
                width: parent.width
                height: parent.height
                spacing: 3
                Text {
                    id: textWeather
                    width: parent.width
                    height: (weatherData.city !== "unk") ? parent.height - textCity.implicitHeight :  parent.height
                    text: weatherData.weatherShottext
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    font.pixelSize: wrapperWeatherMinimal.height*.2
                    color: Kirigami.Theme.textColor
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                }
                Text {
                    id: textCity
                    height: parent.height -  textWeather.height
                    width: parent.width
                    text:  weatherData.city
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    font.pixelSize: wrapperWeatherMinimal.height*.15
                    visible: (weatherData.city !== "unk")
                    color: Kirigami.Theme.textColor
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                }
            }

        }
        MouseArea {
            height: parent.height
            width: parent.width
            anchors.centerIn: parent
            onClicked: {
                wrapperWeatherMinimal.visible = !wrapperWeatherMinimal.visible
            }
        }
    }

    ListModel {
        id: forecastModel
    }

    function agregarUnDia(x) {
        var fechaActual = new Date();
        fechaActual.setDate(fechaActual.getDate() + x); // Sumar días
        return fechaActual.getDate().toString(); // Obtener solo el día como número
    }


    function updateForecastModel() {

        let icons = {
            0: weatherData.oneIcon,
            1: weatherData.twoIcon,
            2: weatherData.threeIcon,
            3: weatherData.fourIcon,
            4: weatherData.fiveIcon,
            5: weatherData.sixIcon,
            6: weatherData.sevenIcon
        }
        let Maxs = {
            0: weatherData.oneMax,
            1: weatherData.twoMax,
            2: weatherData.threeMax,
            3: weatherData.fourMax,
            4: weatherData.fiveMax,
            5: weatherData.sixMax,
            6: weatherData.sevenMax
        }
        let Mins = {
            0: weatherData.oneMin,
            1: weatherData.twoMin,
            2: weatherData.threeMin,
            3: weatherData.fourMin,
            4: weatherData.fiveMin,
            5: weatherData.sixMin,
            6: weatherData.sevenMin
        }
        forecastModel.clear();
        for (var i = 0; i < 7; i++) {
            var icon = icons[i]
            var maxTemp = Maxs[i]
            var minTemp = Mins[i]
            var date = agregarUnDia(i)

            forecastModel.append({
                date: date,
                icon: icon,
                maxTemp: maxTemp,
                minTemp: minTemp
            });


        }
    }

    Component.onCompleted: {
        weatherData.dataChanged.connect(updateForecastModel); // Conectar el signal dataChanged a la función updateForecastModel
    }

    ListView {
        width: parent.width
        height: parent.height
        model: forecastModel
        orientation: Qt.Horizontal
        layoutDirection : Qt.LeftToRight
        visible: !wrapperWeatherMinimal.visible

        delegate: Item {
            height: listView.height
            width: max.implicitWidth*2

            Column {
                id: column
                width: max.implicitWidth
                height: listView.height
                Text {
                    width: parent.width
                    //height: parent.height/4
                    text: model.date
                    horizontalAlignment: Text.AlignHCenter
                    color: Kirigami.Theme.textColor
                    //anchors.horizontalCenter: parent.horizontalCenter

                }

                Kirigami.Icon {
                    id: forecastLogo
                    width: 24
                    height: 24
                    source: model.icon
                    color: Kirigami.Theme.textColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    id: max
                    width: parent.width
                    //height: parent.height/4
                    text: model.maxTemp + "°"
                    color: Kirigami.Theme.textColor
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    id: min
                    width: parent.width
                    //height: parent.height/4
                    text: model.minTemp + "°"
                    color: Kirigami.Theme.textColor
                    horizontalAlignment: Text.AlignHCenter
                    opacity: 0.8
                }
            }

        }
        MouseArea {
            height: parent.height
            width: parent.width
            anchors.centerIn: parent
            onClicked: {
                wrapperWeatherMinimal.visible = !wrapperWeatherMinimal.visible
            }
        }
    }


}
