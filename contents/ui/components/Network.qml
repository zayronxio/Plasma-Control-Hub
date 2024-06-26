import QtQml 2.0
import QtQuick 2.0
import org.kde.plasma.networkmanagement as PlasmaNM

Item {
    property var appletProxyModel: appletProxyModel
    property var netStatusText: netStatus.activeConnections
    property var activeConnectionIcon: activeConnectionIcon.connectionIcon
    property var enabledConnections: enabledConnections
    property var availableDevices: availableDevices
    property var handler: handler

    
    PlasmaNM.ConnectionIcon {
        id: activeConnectionIcon
        connectivity: netStatus.connectivity
    }
    PlasmaNM.Handler {
        id: handler
    }
    PlasmaNM.NetworkStatus {
        id: netStatus
    }
    PlasmaNM.AppletProxyModel {
        id: appletProxyModel
        sourceModel: PlasmaNM.NetworkModel{}
    }
    PlasmaNM.EnabledConnections {
        id: enabledConnections
    }
    PlasmaNM.AvailableDevices {
        id: availableDevices
    }


}
