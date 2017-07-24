import QtQuick 2.0
import Qt.labs.platform 1.0
import QtQuick.Controls 1.4
ListView {
    id: rootSelectionArea
    width: 160; height: 100
    clip: true
    property url currentFile: ""
    signal openFilesAccepted()
    ListModel{ id: selectionsModel }

    function appendSelections(path){
        var name = path.substr(path.lastIndexOf('/')+1)
        selectionsModel.append({"name":name, "path": path})
    }

    model:selectionsModel

    ExclusiveGroup { id: imageGroup }

    header: Button{
        id: selectButton
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        text: qsTr("Select")
        onClicked: {
            fileDialog.visible = true
        }
    }
    delegate: Item{

        width: rootSelectionArea.width
        height: width;

        Rectangle{
            id: selectionArea
            anchors.fill: parent
            anchors.margins: 8
            border.width: 2
            border.color: checked? "green" : "red"
            property bool checked: false
            Component.onCompleted: {
                imageGroup.bindCheckable(selectionArea)
            }
            Image {
                anchors.fill: parent
                anchors.margins: 12
                fillMode: Image.PreserveAspectFit
                source: path
            }
            Text {
                anchors.fill: parent

                text: qsTr(""+index)
                font.pointSize: 36
                color:parent.checked ?"blue" : "grey"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            MouseArea{
                anchors.fill: parent
                onClicked:{
                    currentFile =  path
                    parent.checked = true
                }
            }
        }
    }



    FileDialog {
         id: fileDialog
         title: "Please choose a file"
         nameFilters: ["Image files (*.png *.jpg)"]
         fileMode:FileDialog.OpenFiles
         onAccepted: {
             openFilesAccepted()
             for(var i in files)
             {
                 appendSelections(files[i])
             }
         }
     }
}
