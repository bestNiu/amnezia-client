import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import SortFilterProxyModel 0.2

import PageEnum 1.0
import ContainerProps 1.0
import ProtocolProps 1.0

import "./"
import "../Controls2"
import "../Config"

PageType {
    id: root

    SortFilterProxyModel {
        id: proxyContainersModel
        sourceModel: ContainersModel
        filters: [
            ValueFilter {
                roleName: "isEasySetupContainer"
                value: true
            }
        ]
        sorters: RoleSorter {
            roleName: "dockerContainer"
            sortOrder: Qt.DescendingOrder
        }
    }

    BackButtonType {
        id: backButton

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.leftMargin: 16
        anchors.topMargin: 20
    }

    FlickableType {
        id: fl
        anchors.top: backButton.bottom
        anchors.bottom: root.bottom
        contentHeight: content.implicitHeight + continueButton.anchors.bottomMargin

        Column {
            id: content

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.leftMargin: 16

            spacing: 16

            HeaderType {
                id: header

                implicitWidth: parent.width

                headerText: qsTr("What is the level of internet control in your region?")
            }

            ListView {
                id: containers
                width: parent.width
                height: containers.contentItem.height
                spacing: 16

                currentIndex: 1
                clip: true
                interactive: false
                model: proxyContainersModel

                property int dockerContainer
                property int containerDefaultPort
                property int containerDefaultTransportProto

                delegate: Item {
                    implicitWidth: containers.width
                    implicitHeight: delegateContent.implicitHeight

                    ColumnLayout {
                        id: delegateContent

                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right

                        CardType {
                            id: card

                            Layout.fillWidth: true

                            headerText: easySetupHeader
                            bodyText: easySetupDescription

                            ButtonGroup.group: buttonGroup

                            onClicked: function() {
                                var defaultContainerProto =  ContainerProps.defaultProtocol(dockerContainer)

                                containers.dockerContainer = dockerContainer
                                containers.containerDefaultPort = ProtocolProps.defaultPort(defaultContainerProto)
                                containers.containerDefaultTransportProto = ProtocolProps.defaultTransportProto(defaultContainerProto)
                            }
                        }
                    }

                    Component.onCompleted: {
                        if (index === containers.currentIndex) {
                            card.checked = true
                            card.clicked()
                        }
                    }
                }

                ButtonGroup {
                    id: buttonGroup
                }
            }

            BasicButtonType {
                id: continueButton

                implicitWidth: parent.width
                anchors.bottomMargin: 24

                text: qsTr("Continue")

                onClicked: function() {
                    ContainersModel.setCurrentlyInstalledContainerIndex(containers.dockerContainer)
                    goToPage(PageEnum.PageSetupWizardInstalling);
                    InstallController.install(containers.dockerContainer,
                                              containers.containerDefaultPort,
                                              containers.containerDefaultTransportProto)
                }
            }
        }
    }
}
