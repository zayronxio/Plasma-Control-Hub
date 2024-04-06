# Validación de entradas nulas
if [ $1 = "null" ]
  then if [ $2 = "null" ]
    then
      # Obteniendo las coordenadas geográficas
      cordeprev3=$(curl -s ipinfo.io)
      cordeprev2=$(echo "$cordeprev3" | grep "loc")
      textno=$(echo "$cordeprev3" | grep "textoquenoesta")

if [[ "$cordeprev2" = "$textno" ]];
  then
    contenidoIpBase=$(curl -s https://api.ipbase.com/v1/json/)
    contenidoIpBaseAjs=$(echo "$contenidoIpBase" | sed 's/,/\n/g')

    findLatitude=$(echo "$contenidoIpBaseAjs" | grep "latitude")
    findLatitude01=$(echo "$findLatitude" | sed 's/"latitude"://g')
    if [[ "$findLatitude01" = "$textno" ]]; then
         contenidoIpBase02=$(curl -s http://ip-api.com/json/?fields=lat,lon)
         contenidoIpBase02Ajs=$(echo "$contenidoIpBase02" | sed 's/,/\n/g')
         findLatitude02=$(echo "$contenidoIpBase02Ajs" | grep "lat")
         findLatitude03=$(echo "$findLatitude02" | sed 's/"lat"://g')
         latitude=$(echo "$findLatitude01" | sed 's/,//g')

         findLongitud=$(echo "$contenidoIpBase02Ajs" | grep "lon")
         findLongitud01=$(echo "$findLongitud" | sed 's/"lon"://g')
         longitud=$(echo "$findLongitud01" | sed 's/,//g')
         else
         latitude=$(echo "$findLatitude01" | sed 's/,//g')
         findLongitud=$(echo "$contenidoIpBaseAjs" | grep "longitude")
         findLongitud01=$(echo "$findLongitud" | sed 's/"longitude"://g')
         longitud=$(echo "$findLongitud01" | sed 's/,//g')
     fi
  else
    cordeprev1=$(echo "$cordeprev2" | sed 's/"loc": "//g')
    cordeprev0=$(echo "$cordeprev1" | sed 's/",//g')
    cordeprev=$(echo "$cordeprev1" | sed 's/,/\n/g')
    latitudeprev=$(echo "$cordeprev" | head -n 1)
    latitude=$(echo "$latitudeprev" | sed 's/ //g')

    longitudprev=$(echo "$cordeprev" | sed -n '2p')
    longitud=$(echo "$longitudprev" | sed 's/"//g')
fi
     fi
    else latitude=$1
     longitud=$2
fi

urlsimple="https://api.open-meteo.com/v1/forecast?"
primerComplementoUrl="latitude=$latitude&longitude=$longitud"
segundoComplementoUrl="&current=temperature_2m&daily=weather_code,temperature_2m_max,temperature_2m_min&&timezone=auto&start_date="
tercerComplementoUrl="$3&end_date=$4"
urlWeatherApi=$urlsimple$primerComplementoUrl$segundoComplementoUrl$tercerComplementoUrl

# Descargar datos JSON desde la API
dateApi=$(curl -s "$urlWeatherApi")
fillterDateApi=$(echo "$dateApi" | sed 's/,/,\n/g')

# estableciendo temperatura actual
 #filtrado
  #eliminadonArtefactos que obstaculizan la localizacion de la temperatura actual
   primerFiltrado=$(echo "$fillterDateApi" | sed 's/"temperature_2m":"°C"},//g' | sed 's/"temperature_2m_max":"°C"//g' | sed 's/"temperature_2m_min":"°C"//g' | sed 's/"temperature_2m_max"//g' | sed 's/"temperature_2m_min"//g')
   segundoFiltrado=$(echo "$primerFiltrado" | grep "temperature_2m")
   eliminandotexto=$(echo "$segundoFiltrado" | sed 's/"temperature_2m"://g')
   temperatura=$(echo "$eliminandotexto" | sed 's/,//g' | sed 's/}//g')

# opteniendo temperatura minima de hoy y los priximos 3 dias
 # Filtrado
   mintemp04=$(echo "$fillterDateApi" | sed 's/"temperature_2m_min":"°C"},//g')
   mintemp03=$(echo "$mintemp04" | grep -A 3 "temperature_2m_min")
   mintemp02=$(echo "$mintemp03" | sed 's/"temperature_2m_min"//g')
   mintemp01=$(echo "$mintemp02" | sed 's/,//g' )
   mintemp0=$(echo "$mintemp01" | tr '\n' ' ' )
   mintemp=$(echo "$mintemp0" | sed 's/:\[//g'| sed 's/]}}//g' | sed 's/]//g')

# opteniendo temperatura maxima de hoy y los priximos 3 dias
 # Filtrado
   maxtemp04=$(echo "$fillterDateApi" | sed 's/"temperature_2m_max":"°C"},//g' | sed 's/"temperature_2m_max":"°C",//g' | sed 's/"temperature_2m_min":"°C"},//g' | sed 's/"temperature_2m_min":"°C",//g')
   maxtemp03=$(echo "$maxtemp04" | grep -A 3 "temperature_2m_max")
   maxtemp02=$(echo "$maxtemp03" | sed 's/"temperature_2m_max"//g' )
   maxtemp01=$(echo "$maxtemp02" | sed 's/,//g')
   maxtemp0=$(echo "$maxtemp01" | tr '\n' ' ')
   maxtemp=$(echo "$maxtemp0" | sed 's/:\[//g'| sed 's/]}}//g' | sed 's/]//g')

# opteniendo el codigo del tiempo de hoy y los priximos 3 dias
 # Filtrado
   primerFiltradodelCode=$(echo "$fillterDateApi" | sed 's/"weather_code":"wmo code"//g')
   segundoFiltradodelCode=$(echo "$primerFiltradodelCode" | grep -A 3 "weather_code")
   eliminandotextDelCode=$(echo "$segundoFiltradodelCode" | sed 's/"weather_code"//g')
   codesOfWeather02=$(echo "$eliminandotextDelCode" | sed 's/,//g')
   codesOfWeather01=$(echo "$codesOfWeather02" | tr '\n' ' ')
   codesOfWeather=$(echo "$codesOfWeather01" | sed 's/:\[//g'| sed 's/]}}//g' | sed 's/]//g')

# 1=temperatura actual, 2=tempertura minima hoy, 3=temperatura minima de mañana, 4=temperatura minima de pasado mañana, 5=temeperatura minima de dentro de 3 dias, 6=tempetarura maxima de hoy, 7=temperatura maxima de mañana, 8=temperatura maxima de pasado mañana, 9=temperatura maxima dentro de 3 dias, 10=codigo del tiempo actual, 11=codigo del tiempo de mañana, 12=codigo del tiempo pasado mañana, 13=codigo del tiempo dentro de 3 dias.
echo "$temperatura $mintemp$maxtemp$codesOfWeather"
