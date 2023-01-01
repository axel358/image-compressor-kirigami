import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.19

PromptDialog {

    property string appName
    property string description
    property string version
    property string author
    property url codeUrl
    property url donateUrl
    property string icon

    title: "About"
    standardButtons: Dialog.NoButton

    ColumnLayout{

        Icon {
            source: icon
            Layout.alignment: Qt.AlignHCenter
        }

        Heading {
            text: appName
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: description
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: author
            Layout.alignment: Qt.AlignHCenter
        }
    }

    customFooterActions: [
        Action {
            text: qsTr("Source code...")
            visible: codeUrl != ""
            onTriggered: Qt.openUrlExternally(codeUrl)
        },
        Action {
            text: qsTr("Donate...")
            visible: donateUrl != ""
            onTriggered: Qt.openUrlExternally(donateUrl)
        }
    ]

}
