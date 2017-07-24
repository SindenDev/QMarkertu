import QtQuick 2.0
import QtQuick.Controls 1.4
Item {
    id: rootMarkerTypeSelecter
    width: 300
    height:  78
    property alias currentType : markerType.currentIndex
    property string currentTypeText:"未知属性"
    property string currentColor:"#ff0097"//borderData.getColorNames()[1]

    onCurrentTypeChanged: {
        markerType.currentItem.checked =  true
        currentTypeText = markerTypeModel.get(currentType).name.replace("\n","")
        currentColor = markerTypeModel.get(currentType).colorNme
    }

    GridView{
        id:markerType
        anchors.bottom: parent.bottom
        cellHeight : 48
        cellWidth : 48
        width: parent.width; height: 50
        clip: true
        model: MarkerTypeModel{id: markerTypeModel}
        ExclusiveGroup { id: typeGroup }


        delegate: Rectangle{
            id: selectionType
            width: 46; height: 46

            border.color:checked?"green":"white"
            border.width: 2
            color:colorNme //borderData.getColorNames()[index+1]
            property bool checked: false
            Component.onCompleted: {
                typeGroup.bindCheckable(selectionType)
            }           

            Text {
                anchors.fill: parent
                text: qsTr(name)
//                font.bold: true
                font.pointSize: 12
                color: "white"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    parent.checked = true
                    currentType = index
                    currentTypeText = name.replace("\n","")
                    currentColor = parent.color
                }
            }
        }
    }
    Text {
        width: parent.width
        font.pointSize: 18
        horizontalAlignment: Text.AlignHCenter
        text: qsTr(currentTypeText)

    }
}
