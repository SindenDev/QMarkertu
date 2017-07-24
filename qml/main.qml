import QtQuick 2.8
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
Window {

    visible: true
    width: 640
    height: 480
    title: qsTr("ECar Matting Image")

    RowLayout{
        width: parent.width
        height: parent.height

        SelectionArea{
            id: mSelectionArea
            Layout.margins: 16
            Layout.fillHeight: true
            onCurrentFileChanged: {
                mWorkspace.image = currentFile
            }
            onOpenFilesAccepted: {
                mWorkspace.init()
            }
        }
        Workspace{
            id: mWorkspace
            Layout.margins: 16
        }
    }

}
