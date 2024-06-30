import QtQuick 2.15
import QtQuick.Controls 2.15
import org.kde.coreaddons 1.0 as KCoreAddons
import Qt5Compat.GraphicalEffects

Item {

    property string codeleng: ((Qt.locale().name)[0]+(Qt.locale().name)[1])

    KCoreAddons.KUser {
        id: kuser
    }

    function capitalizeFirstLetter(string) {
        if (!string || string.length === 0) {
            return "";
        }
        return string.charAt(0).toUpperCase() + string.slice(1);
    }

    function hiText(languageCode) {
        const translations = {
            "es": "Hola",        // Spanish
            "en": "Hello",       // English
            "hi": "नमस्ते",      // Hindi
            "fr": "Salut",       // French
            "de": "Hallo",       // German
            "it": "Ciao",        // Italian
            "pt": "Olá",         // Portuguese
            "ru": "Привет",      // Russian
            "zh": "你好",        // Chinese (Mandarin)
            "ja": "こんにちは", // Japanese
            "ko": "안녕하세요",  // Korean
            "nl": "Hallo",       // Dutch
            "ny": "Moni",        // Chichewa
            "mk": "Здраво"       // Macedonian
        };

        // Return the translation for the language code or default to English if not found
        return translations[languageCode] || translations["en"];
    }

    property string name: hiText(codeleng) + " " + capitalizeFirstLetter(kuser.fullName)
    property string urlAvatar: kuser.faceIconUrl



}
