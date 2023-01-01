import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.19
import Qt.labs.platform 1.1
import QtMultimedia 5.15

ApplicationWindow
{
    id: root
    title: "Image Compressor"
    width: 400
    height: 580
    property string openFile

    Page {
        id: page
        anchors.fill: parent

        header: Controls.ToolBar {
            Layout.fillWidth: true
            id: toolbar
            contentItem: ActionToolBar{
                actions: [
                    Action {
                        text: "Open"
                        icon.name: "document-open-symbolic"
                        onTriggered: openDialog.open()
                    },
                    Action {
                        text: "Save"
                        icon.name: "document-save-symbolic"
                        displayHint: Action.DisplayHint.KeepVisible
                        onTriggered: backend.saveImage()
                    }
                    ,
                    Action {
                        text: "About"
                        icon.name: "help-about-symbolic"
                        displayHint: Action.DisplayHint.AlwaysHide
                        onTriggered: aboutDialog.open()
                    }
                ]
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            id: statusPage

            Icon {
                source: "viewimage"
                isMask: true
                Layout.fillHeight: true
                Layout.preferredHeight: Units.iconSizes.huge
                Layout.preferredWidth: Units.iconSizes.huge
                Layout.alignment: Qt.AlignHCenter
            }

            Heading {
                text: "Tap open to select an image"
                Layout.alignment: Qt.AlignHCenter
            }
        }

        ColumnLayout{
            visible: !statusPage.visible
            anchors.fill: parent

            Image {
                id: imageView
                fillMode: Image.PreserveAspectFit
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                cache: false

            }

            Controls.Label {
                id: infoLabel
                text: "1366x768 1.3Mb"
                padding: Units.largeSpacing
                Layout.topMargin: Units.largeSpacing
                Layout.alignment: Qt.AlignHCenter
                background: ShadowedRectangle {
                    color: Theme.backgroundColor
                    shadow.size: 2
                    shadow.color: Theme.textColor
                    radius: 10
                }

            }

            FormLayout {
                Layout.fillWidth: true

                Separator {
                    FormData.isSection: true
                    FormData.label: "Options"
                }

                RowLayout {
                    FormData.label: "Quality"

                    Controls.Slider {
                        value: 0.5
                        id: qualitySlider
                        Layout.fillWidth: true
                        stepSize: 0.05

                        onValueChanged: {
                            compressImage()
                        }

                    }
                    Controls.Label {
                        text: Math.round(qualitySlider.value * 100)  + "%"
                    }
                }

                RowLayout {
                    FormData.label: "Resolution"
                    Controls.Slider {
                        value: 0.5
                        stepSize: 0.05
                        id: resSlider

                        Layout.fillWidth: true
                        onValueChanged: {
                            compressImage()
                        }
                    }
                    Controls.Label {
                        text: resSlider.value.toFixed(2) + "x"
                    }

                }

                Controls.ButtonGroup {
                    id: formatsGroup
                    buttons: rl.children
                    onClicked: compressImage()
                }

                RowLayout {
                    id: rl
                    FormData.label: "Format"
                    Controls.RadioButton {
                        id: firstRadio
                        checked: true
                        text: "JPEG"
                    }

                    Controls.RadioButton {
                        text: "WebP"
                    }

                }
            }

        }
    }
    FileDialog {
        id: openDialog
        title: "Open Image"
        fileMode: FileDialog.OpenFile
        onAccepted: {
            statusPage.visible = false
            openFile = file
            compressImage()
        }
    }

    FileDialog {
        id: saveDialog
        title: "Save Dialog"
        //folder: myObjHasAPath? myObj.path: "file:///" //Here you can set your default folder
        fileMode: FileDialog.SaveFile
        onAccepted: {
            backend.downloadSub(languageCode, file, translateCode)
        }
    }

    AboutDialog {
        id: aboutDialog
        appName: "Image Compressor"
        description: "Image Compressor"
        icon: "gwenview"
        author: "Axel358"
        codeUrl: "https://github.com/axel358/image-compressor-kirigami"
    }


    PromptDialog {
        id: trimmingDialog
        showCloseButton: false
        title: "Trimming..."
        subtitle: "Please wait"
        standardButtons: Dialog.Ok
    }

    function compressImage() {
        if(openFile)
            backend.compressImage(openFile, qualitySlider.value, resSlider.value, formatsGroup.checkedButton.text)
    }

    Connections {
        target: backend

        function onShowToast(message) {
            showPassiveNotification(message)
        }

        function onInfoChanged(info) {
            infoLabel.text = info
        }

        function onImageChanged(path) {
            imageView.source = ""
            imageView.source = path
        }
    }
}
