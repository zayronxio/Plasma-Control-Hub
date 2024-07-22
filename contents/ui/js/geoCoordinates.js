function obtenerCoordenadas(callback) {
    let url = "http://ip-api.com/json/?fields=lat,lon";

    let req = new XMLHttpRequest();
    req.open("GET", url, true);

    req.onreadystatechange = function () {
        if (req.readyState === 4) {
            if (req.status === 200) {
                let datos = JSON.parse(req.responseText);
                let latitud = datos.lat
                let longitud = datos.lon
                let full = latitud + ", " + longitud
                console.log(`${full}`)
                callback(full);
            } else {
                console.error(`Error en la solicitud: ${req.status}`);
            }
        }
    };

    req.send();
}
