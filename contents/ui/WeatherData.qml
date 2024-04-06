import QtQuick 2.15
import org.kde.plasma.plasma5support as Plasma5Support
import QtQuick.Controls 2.15
import "lib" as Lib

Item {

    function obtener(texto, indice) {
        var palabras = texto.split(/\s+/); // Divide el texto en palabras utilizando el espacio como separador
        return palabras[indice - 1]; // El índice - 1 porque los índices comienzan desde 0 en JavaScript
    }

    function weatherCodeText(languageCode, code) {
    let descriptions = {
        en: {
            0: "Clear",
            1: "Mainly clear",
            2: "Partly cloudy",
            3: "Overcast",
            51: "Drizzle light intensity",
            53: "Drizzle moderate intensity",
            55: "Drizzle dense intensity",
            56: "Freezing Drizzle light intensity",
            57: "Freezing Drizzle dense intensity",
            61: "Rain slight intensity",
            63: "Rain moderate intensity",
            65: "Rain heavy intensity",
            66: "Freezing Rain light intensity",
            67: "Freezing Rain heavy intensity",
            71: "Snowfall slight intensity",
            73: "Snowfall moderate intensity",
            75: "Snowfall heavy intensity",
            77: "Snow grains",
            80: "Rain showers slight",
            81: "Rain showers moderate",
            82: "Rain showers violent",
            85: "Snow showers slight",
            86: "Snow showers heavy",
            95: "Thunderstorm",
            96: "Thunderstorm with slight hail",
            99: "Thunderstorm with heavy hail"
        },
        es: {
            0: "Despejado",
            1: "Mayormente despejado",
            2: "Parcialmente nublado",
            3: "Nublado",
            51: "Llovizna de baja intensidad",
            53: "Llovizna de intensidad moderada",
            55: "Llovizna de intensidad densa",
            56: "Llovizna helada de baja intensidad",
            57: "Llovizna helada de intensidad densa",
            61: "Lluvia de ligera intensidad",
            63: "Lluvia de intensidad moderada",
            65: "Lluvia de intensidad fuerte",
            66: "Lluvia helada de baja intensidad",
            67: "Lluvia helada de alta intensidad",
            71: "Nieve de ligera intensidad",
            73: "Nieve de intensidad moderada",
            75: "Nieve de intensidad fuerte",
            77: "Granizo",
            80: "Aguaceros de lluvia de ligera intensidad",
            81: "Aguaceros de lluvia de intensidad moderada",
            82: "Aguaceros de lluvia de intensidad violenta",
            85: "Aguaceros de nieve de ligera intensidad",
            86: "Aguaceros de nieve de intensidad fuerte",
            95: "Tormenta",
            96: "Tormenta con granizo ligero",
            99: "Tormenta con granizo fuerte"
        },
        fr: {
            0: "Clair",
            1: "Partiellement clair",
            2: "Partiellement nuageux",
            3: "Couvert",
            51: "Bruine légère",
            53: "Bruine modérée",
            55: "Bruine dense",
            56: "Bruine verglaçante légère",
            57: "Bruine verglaçante dense",
            61: "Pluie légère",
            63: "Pluie modérée",
            65: "Pluie forte",
            66: "Pluie verglaçante légère",
            67: "Pluie verglaçante forte",
            71: "Légère chute de neige",
            73: "Chute de neige modérée",
            75: "Chute de neige forte",
            77: "Grains de neige",
            80: "Averses de pluie légères",
            81: "Averses de pluie modérées",
            82: "Averses de pluie violentes",
            85: "Averses de neige légères",
            86: "Averses de neige fortes",
            95: "Orage",
            96: "Orage avec grêle légère",
            99: "Orage avec grêle forte"
        },
        de: {
            0: "Klar",
            1: "Überwiegend klar",
            2: "Teilweise bewölkt",
            3: "Bedeckt",
            51: "Leichter Nieselregen",
            53: "Mäßiger Nieselregen",
            55: "Dichter Nieselregen",
            56: "Leichter Gefrierender Nieselregen",
            57: "Dichter Gefrierender Nieselregen",
            61: "Leichter Regen",
            63: "Mäßiger Regen",
            65: "Starker Regen",
            66: "Leichter Gefrierender Regen",
            67: "Starker Gefrierender Regen",
            71: "Leichter Schneefall",
            73: "Mäßiger Schneefall",
            75: "Starker Schneefall",
            77: "Schneekörner",
            80: "Leichte Regenschauer",
            81: "Mäßige Regenschauer",
            82: "Starker Regenschauer",
            85: "Leichte Schneeschauer",
            86: "Starke Schneeschauer",
            95: "Gewitter",
            96: "Gewitter mit leichtem Hagel",
            99: "Gewitter mit starkem Hagel"
        },
        it: {
            0: "Sereno",
            1: "Prevalentemente sereno",
            2: "Parzialmente nuvoloso",
            3: "Nuvoloso",
            51: "Pioviggine debole",
            53: "Pioviggine moderata",
            55: "Pioviggine intensa",
            56: "Pioviggine ghiacciata debole",
            57: "Pioviggine ghiacciata intensa",
            61: "Pioggia debole",
            63: "Pioggia moderata",
            65: "Pioggia intensa",
            66: "Pioggia ghiacciata debole",
            67: "Pioggia ghiacciata intensa",
            71: "Nevicata debole",
            73: "Nevicata moderata",
             75: "Nevicata intensa",
            77: "Granuli di neve",
            80: "Pioggia debole con rovesci",
            81: "Pioggia moderata con rovesci",
            82: "Pioggia intensa con rovesci",
            85: "Nevicata debole con rovesci",
            86: "Nevicata intensa con rovesci",
            95: "Temporale",
            96: "Temporale con grandine leggera",
            99: "Temporale con grandine forte"
        },
        pt: {
            0: "Céu limpo",
            1: "Céu pouco nublado",
            2: "Parcialmente nublado",
            3: "Céu nublado",
            51: "Chuviscos de fraca intensidade",
            53: "Chuviscos de intensidade moderada",
            55: "Chuviscos de intensidade forte",
            56: "Chuviscos congelantes de fraca intensidade",
            57: "Chuviscos congelantes de intensidade forte",
            61: "Chuva de fraca intensidade",
            63: "Chuva de intensidade moderada",
            65: "Chuva de intensidade forte",
            66: "Chuva congelante de fraca intensidade",
            67: "Chuva congelante de intensidade forte",
            71: "Queda de neve de fraca intensidade",
            73: "Queda de neve de intensidade moderada",
            75: "Queda de neve de intensidade forte",
            77: "Granulado de neve",
            80: "Aguaceiros de chuva fracos",
            81: "Aguaceiros de chuva moderados",
            82: "Aguaceiros de chuva fortes",
            85: "Aguaceiros de neve fracos",
            86: "Aguaceiros de neve fortes",
            95: "Trovoada",
            96: "Trovoada com granizo fraco",
            99: "Trovoada com granizo forte"
        },
        ja: {
            0: "晴れ",
            1: "大部分晴れ",
            2: "一部曇り",
            3: "曇り",
            51: "わずかな霧雨",
            53: "穏やかな霧雨",
            55: "濃い霧雨",
            56: "軽い凍雨",
            57: "濃い凍雨",
            61: "弱い雨",
            63: "穏やかな雨",
            65: "激しい雨",
            66: "軽い着氷性の雨",
            67: "激しい着氷性の雨",
            71: "弱い雪",
            73: "穏やかな雪",
            75: "激しい雪",
            77: "雪の粒",
            80: "弱いにわか雨",
            81: "穏やかなにわか雨",
            82: "激しいにわか雨",
            85: "弱いにわか雪",
            86: "激しいにわか雪",
            95: "雷雨",
            96: "軽い雹を伴う雷雨",
            99: "激しい雹を伴う雷雨"
        },
        ru: {
            0: "Ясно",
            1: "В основном ясно",
            2: "Частично облачно",
            3: "Пасмурно",
            51: "Морось слабая интенсивность",
            53: "Морось умеренная интенсивность",
            55: "Морось плотная интенсивность",
            56: "Ледяной дождь слабой интенсивности",
            57: "Ледяной дождь сильной интенсивности",
            61: "Дождь слабой интенсивности",
            63: "Дождь умеренной интенсивности",
            65: "Дождь сильной интенсивности",
            66: "Ледяной дождь слабой интенсивности",
            67: "Ледяной дождь сильной интенсивности",
            71: "Снег слабой интенсивности",
            73: "Снег умеренной интенсивности",
            75: "Снег сильной интенсивности",
            77: "Снежные зерна",
            80: "Дождь с прояснениями слабый",
            81: "Дождь с прояснениями умеренный",
            82: "Дождь с прояснениями сильный",
            85: "Снег с прояснениями слабый",
            86: "Снег с прояснениями сильный",
            95: "Гроза",
            96: "Гроза с небольшим градом",
            99: "Гроза с сильным градом"
        },
        zh: {
            0: "晴",
            1: "晴间多云",
            2: "局部多云",
            3: "阴天",
            51: "小雨",
            53: "中雨",
            55: "大雨",
            56: "小冻雨",
            57: "大冻雨",
            61: "小雨夹雪",
            63: "中雨夹雪",
            65: "大雨夹雪",
            66: "小冰雨",
            67: "大冰雨",
            71: "小雪",
            73: "中雪",
            75: "大雪",
            77: "雪粒",
            80: "小雨 showers",
            81: "中雨 showers",
            82: "大雨 showers",
            85: "小雪 showers",
            86: "大雪 showers",
            95: "雷暴",
            96: "雷暴并伴有小冰雹",
            99: "雷暴并伴有大冰雹"
        },
        ko: {
            0: "맑음",
            1: "구름 조금",
            2: "부분적으로 흐림",
            3: "흐림",
            51: "약한 이슬비",
            53: "중간 강도의 이슬비",
            55: "짙은 이슬비",
            56: "약한 동결 이슬비",
            57: "강한 동결 이슬비",
            61: "약한 비",
            63: "중간 강도의 비",
            65: "강한 비",
            66: "약한 동결 비",
            67: "강한 동결 비",
            71: "약한 눈",
            73: "중간 강도의 눈",
            75: "강한 눈",
            77: "눈송이",
            80: "약한 비 샤워",
            81: "중간 강도의 비 샤워",
            82: "강한 비 샤워",
            85: "약한 눈 샤워",
            86: "강한 눈 샤워",
            95: "천둥 번개",
            96: "약한 우박을 동반한 천둥 번개",
            99: "강한 우박을 동반한 천둥 번개"
        },
        // Agrega más idiomas aquí según sea necesario
    };

    if (descriptions[languageCode]) {
        return descriptions[languageCode][code] || "Unknown";
    } else {
        return "Language not supported";
    }
}
    property string command: "bash $HOME/.local/share/plasma/plasmoids/Plasma.Control.Hub/contents/ui/lib/getDataWeather.sh"+" "+latitude+" "+longitud+" "+day+" "+therday
    property string useCoordinatesIp: plasmoid.configuration.useCoordinatesIp
    property string latitudeC: plasmoid.configuration.latitudeC
    property string longitudeC: plasmoid.configuration.longitudeC
    property string latitude: (useCoordinatesIp === "true") ? "null" : (latitudeC === "0") ? "null" : latitudeC
    property string longitud: (useCoordinatesIp === "true") ? "null" : (longitudeC === "0") ? "null" : longitudeC

    property string datosweather: "0 0 0 0 0 0 0 0 0 51 0 0 0"
    property string day: (Qt.formatDateTime(new Date(), "yyyy-MM-dd"))
    property string therday: Qt.formatDateTime(new Date(new Date().getTime() + (3 * 24 * 60 * 60 * 1000)), "yyyy-MM-dd")
    property int numberOfDays: 3
    property string temperaturaActual: obtener(datosweather, 1)
    property string codeleng: ((Qt.locale().name)[0]+(Qt.locale().name)[1])
    property string codeweather: obtener(datosweather, 10)
    property string minweatherCurrent: obtener(datosweather, 2)
    property string maxweatherCurrent: obtener(datosweather, 6)
    property string iconWeatherCurrent: asingicon()

    property string weathertext: weatherCodeText(codeleng, codeweather)




    Plasma5Support.DataSource {
      id: executable
      engine: "executable"
      connectedSources: []
      onNewData: {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName) // cmd finished
                  }
     function exec(cmd) {
            connectSource(cmd)
           }
     signal exited(int exitCode, int exitStatus, string stdout, string stderr)
       }

   Connections {
     target: executable
     onExited: {
                    datosweather = stdout
                }
          }
    function executeCommand() {
        executable.exec(command)
    }
    function asingicon(){
            let wmocodes = {
              0 : "clear",
              1 : "few-clouds",
              2 : "few-clouds",
              3 : "clouds",
              51 : "showers-scattered",
              53 : "showers-scattered",
              55 : "showers-scattered",
              56 : "showers-scattered",
              57 : "showers-scattered",
              61 : "showers",
              63 : "showers",
              65 : "showers",
              66 : "showers-scattered",
              67 : "showers",
              71 : "snow-scattered",
              73 : "snow",
              75 : "snow",
              77 : "hail",
              80 : "showers",
              81 : "showers",
              82 : "showers",
              85 : "snow-scattered",
              86 : "snow",
              95 : "storm",
              96 : "storm",
              99 : "storm",
                     }
            var cicloOfDay = isday()

            var iconName = "weather-" + (wmocodes[codeweather] || "unknown") + "-" + cicloOfDay

    return iconName
    }

  function isday() {
    var timeActual = Qt.formatDateTime(new Date(), "h")
    if (timeActual < "6") {
      if (timeActual > "19") {
        return "night"
      } else {
        return "day"
      }
    } else {
      if (timeActual > "19") {
        return "night"
      } else {
        return "day"
      }
    }
  }
}

