import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
ColumnLayout{
    id: rootWorkspace
    focus: true
    Layout.fillWidth: true
    Layout.fillHeight: true
    property alias roadLine:roadLineSlider.y
    property int currentIndex: 0
    property var pointsJSON:{"roadLine":0,"markers":[{"type":0,"color": "#5f0f8a", "points":[]}]}// [{"type": 1,"color":#00000, "points":[{"x":12,"y":12},{"x":15,"y":18},...]},...]

    property alias image: handleImage.source

    onRoadLineChanged: {
         pointsJSON.roadLine = Math.floor(roadLine)
    }

    function init(){
        if(canvas.context == null) return;
//        console.debug("init-->Canvas",borderData.getColorNames()[1])
        canvas.context.lineJoin = "round";
        canvas.context.miterLimit=5;
        canvas.context.lineWidth = 2.0
        canvas.context.globalAlpha = 0.8;
//        mMarkerTypeSelecter.currentColor =  "#5f0f8a"
//        mMarkerTypeSelecter.currentType = 0
    }

    function clearBlankMarkers(){
        for(var i in pointsJSON.markers){
            if(pointsJSON.markers[i].points.length < 1)
                pointsJSON.markers.splice(i,1);
        }
    }

    function fillBlankMarkers(){
        if(pointsJSON.markers.length < 1){
            var new_points_json =  {"type":mMarkerTypeSelecter.currentType,"color":mMarkerTypeSelecter.currentColor, "points":[]}
            pointsJSON.markers.push(new_points_json)
            currentIndex = pointsJSON.markers.length -1;
        }
    }

    function appendPointsJSON(){
        fillBlankMarkers()
        if(pointsJSON.markers[pointsJSON.markers.length -1].points.length < 1) return
        var new_points_json =  {"type":mMarkerTypeSelecter.currentType,"color":mMarkerTypeSelecter.currentColor, "points":[]}
        pointsJSON.markers.push(new_points_json)
        saveCurrentPen()
        currentIndex = pointsJSON.markers.length -1;
    }

    function saveCurrentPen(type, color){
        console.debug("saveCurrentPen")
        fillBlankMarkers()
        var data = pointsJSON.markers[currentIndex]
//        console.debug(pointsJSON.length, JSON.stringify(data))
        if(data.hasOwnProperty("type")){
            data.type = mMarkerTypeSelecter.currentType
        }
        if(data.hasOwnProperty("color")){
            var currentColor = mMarkerTypeSelecter.currentColor
            data.color = currentColor.toString()
        }
        pointsJSON.markers[currentIndex] = data
    }

    function pushPointJSON(x, y){
//        var json_data = JSON.parse(pointsJSON)
//        console.debug("pushPointJSON",JSON.stringify(pointsJSON))

        fillBlankMarkers();

        var data = pointsJSON.markers[currentIndex]

        data.type = mMarkerTypeSelecter.currentType
        data.color = mMarkerTypeSelecter.currentColor

        if(data.hasOwnProperty("points")){
            var points = data.points

            var point = {"x":x,"y":y};
            points.push(point)
            data.points = points
        }
        pointsJSON.markers[currentIndex] = data
    }

    function clearPointJSON(){
        fillBlankMarkers()
        var data = pointsJSON.markers[currentIndex]

        if(data.hasOwnProperty("points")){
            var points = data.points

            while(points.length){
                points.pop()
            }
            data.points = points
        }
        console.debug("clear a line")
        pointsJSON.markers[currentIndex] = data
        currentIndex = 0
    }

    function popPointJSON(){
        fillBlankMarkers()
        var data = pointsJSON.markers[currentIndex]
        console.debug(JSON.stringify(pointsJSON.markers[currentIndex]))
        if(data.hasOwnProperty("points")){
            var points = data.points
            points.pop()
            data.points = points
        }
        pointsJSON.markers[currentIndex] = data
    }

    MarkerTypeSelecter{
        id: mMarkerTypeSelecter
        Layout.fillWidth: true
        onCurrentColorChanged: {
            saveCurrentPen()
        }
    }

    ScrollView{
        id: handleImageScroll
        Layout.fillWidth: true
        Layout.fillHeight: true
//        frameVisible: true
        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        Image {
            id: handleImage


            onSourceSizeChanged: {
                if(pointsJSON.roadLine > 0)
                    roadLine = pointsJSON.roadLine
                else
                    roadLine = sourceSize.height / 2
            }

            Canvas{
                id: canvas
                anchors.fill: parent
//                anchors.centerIn: parent
//                width: handleImage.implicitWidth
//                height: handleImage.implicitHeight

                contextType: "2d"


                function drawUpdate(fill_path){
                    if(canvas.context == null) return;

                    context.clearRect(0,0,width,height);

//                    console.debug("pushPointJSON",JSON.stringify(pointsJSON))
                    if(pointsJSON.markers.length < 1) {
                        requestPaint()
                        return
                    };
                    if(!pointsJSON.markers[0].points.length) {
                        requestPaint()
                        return
                    }

                    for(var i in pointsJSON.markers){

//                        mMarkerTypeSelecter.currentType = pointsJSON.markers[i].type

                        context.strokeStyle = pointsJSON.markers[i].color
                        context.fillStyle = pointsJSON.markers[i].color
//                        console.debug("color:",i,pointsJSON[i].color)
                        var points = pointsJSON.markers[i].points
                        var fit_points = JSON.parse(borderData.fitHyper(i,handleImage.sourceSize.height,JSON.stringify(pointsJSON)))
                        console.debug("fit_points.length:",fit_points.length)
                        if(fit_points.length > 0){
console.debug("fit_points.length to fit")
                        for(var j in points){
                            var x = points[j].x
                            var y = points[j].y
                            //if(0 == j) {
                                context.beginPath()
                                context.arc(x,y,4,0,2*Math.PI);
                                context.moveTo(x, y);
                            /*}else{
                                context.lineTo(x, y)
                                context.moveTo(x, y);
                                context.stroke()
                                context.beginPath()
                                context.arc(x,y,4,0,2*Math.PI);
                                context.moveTo(x, y);
                            }*/
//                        }
                            if(i !=  currentIndex) {
                                context.fill()
                            }else /*if(fill_path)*/{
    //                            context.closePath()
                                context.stroke()
                            }
                        }
                        for(var k in fit_points){
                            var x = fit_points[k].x
                            var y = fit_points[k].y
                            if(0 == k){
                                context.beginPath()
                                context.moveTo(x, y);
                            }
                            context.lineTo(x, y)
                            context.stroke()
                        }
                    }else{
                            console.debug("fit_points.length not fit")
                            for(var j in points){
                                var x = points[j].x
                                var y = points[j].y
                                if(0 == j) {
                                    context.beginPath()
                                    context.arc(x,y,4,0,2*Math.PI);
                                    context.moveTo(x, y);
                                }else{
                                    context.lineTo(x, y)
                                    context.moveTo(x, y);
                                    context.stroke()
                                    context.beginPath()
                                    context.arc(x,y,4,0,2*Math.PI);
                                    context.moveTo(x, y);
                                }
    //                        }
                                if(i !=  currentIndex) {
                                    context.fill()
                                }else /*if(fill_path)*/{
        //                            context.closePath()
                                    context.stroke()
                                }
                            }
                        }
                    }
                    requestPaint()
                }
            }
            Text {
                id: currentPositionText
//                text: currentIndex+1
                font.pointSize: 16
            }

            MouseArea{
                id: area
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:Qt.CrossCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                drag.target: handleImage
                onClicked: {
                    area.hoverEnabled = true
                    if(mouse.button == Qt.RightButton){
                        popPointJSON()
                        canvas.drawUpdate()

                    }else if(mouse.button == Qt.LeftButton){
                        pushPointJSON(Math.floor(mouseX), Math.floor(mouseY))
                        canvas.drawUpdate()
                    }
                }


                onPositionChanged:{
                    currentPositionText.x = mouseX+4
                    currentPositionText.y = mouseY
                    currentPositionText.text = "["+(Math.floor(mouseX) + "," + Math.floor(mouseY))+"]"
//                    popPointJSON()
//                    pushPointJSON(mouseX, mouseY)
//                    canvas.drawUpdate()
                }

                onWheel: {
//                    console.debug("handleImageScroll:",handleImageScroll.contentItem.width, handleImageScroll.contentItem.height)
//                    console.debug("handleImage",handleImageScroll.flickableItem.contentY,handleImage.sourceSize, handleImage.scale)
                      if(wheel.angleDelta.y > 0){
                          if(handleImage.scale > 2.0) return;
                          handleImage.scale += 0.1;

                      }else{
                          if(handleImage.scale < 0.1) return;
                          handleImage.scale -= 0.1
                      }
//                      handleImageScroll.contentItem.width = handleImage.sourceSize.width*handleImage.scale;
//                      handleImageScroll.contentItem.height = handleImage.sourceSize.height*handleImage.scale;
                }
            }
            Rectangle{
                id: roadLineSlider
                y: height*.5
                width: 16; height: 16; color: "blue"
                MouseArea{
                    anchors.fill: parent
                    drag.target: parent
                    drag.axis: Drag.YAxis
                    drag.maximumY: rootWorkspace.height
                    drag.minimumY: 0
                }
            }
            Rectangle{
                id: m_RoadLine
                y:roadLine; width: parent.width; height: 1; color: "#ed1c24"
            }
            Rectangle{
                id: m_RoadLine_1_2
                y: (parent.height + roadLine)*0.5; width: parent.width; height: 1; color: "green"
                Text {
                    color: m_RoadLine.color
                    text: qsTr("1/2")
                    font.bold: true
                    font.pointSize: 12
                }
            }

            Rectangle{
                id: m_RoadLine_1_4
                y:(m_RoadLine.y +m_RoadLine_1_2.y)*0.5; width: parent.width; height: 1; color: "green"
                Text {
                    color:  m_RoadLine.color
                    text: qsTr("1/4")
                    font.bold: true
                    font.pointSize: 12
                }
            }

            Rectangle{
                id: m_RoadLine_1_8
                y:(m_RoadLine.y +m_RoadLine_1_4.y)*0.5; width: parent.width; height: 1; color: "green"
                Text {
                    color: m_RoadLine.color
                    text: qsTr("1/8")
                    font.bold: true
                    font.pointSize: 12
                }
            }

            Rectangle{
                y:(parent.height +m_RoadLine_1_2.y)*0.5; width: parent.width; height: 1; color: "green"
                Text {
                    color: m_RoadLine.color
                    text: qsTr("3/4")
                    font.bold: true
                    font.pointSize: 12
                }
            }
        }
    }


    onImageChanged: {
        restore(image)
        console.debug("onImageChanged",handleImage.progress,handleImage.sourceSize.width, " x ",handleImage.sourceSize.height)

        currentIndex = (pointsJSON.markers).length -1;

        mMarkerTypeSelecter.currentType = pointsJSON.markers[currentIndex].type
        canvas.drawUpdate(true)
    }

    function saveData(){
        clearBlankMarkers()
        borderData.writeData(image+".json",JSON.stringify(pointsJSON))
        area.hoverEnabled = false
    }


    function restore(name){
        var data_obj = borderData.readData(name+".json")
        pointsJSON  = JSON.parse(data_obj)
        area.hoverEnabled = false
    }

    Keys.onPressed: {
       // console.debug(event.key)
        switch(event.key){
        case Qt.Key_Escape:
            restore(image)
            break;
        case Qt.Key_Return:
            console.debug("Key_Backspace")

            saveData()
            appendPointsJSON()
            break;
        case Qt.Key_Up:

            if(currentIndex < pointsJSON.markers.length-1)
                currentIndex++;
            else
                currentIndex = 0
            restore(image)
            canvas.drawUpdate(true)
            area.hoverEnabled = true
            break
        case Qt.Key_Down:
            if(currentIndex > 0)
                currentIndex--
            else
                currentIndex = pointsJSON.markers.length-1
            restore(image)
            canvas.drawUpdate(true)
            area.hoverEnabled = true
            break
         case Qt.Key_Delete:
             clearPointJSON()
             canvas.drawUpdate(true)
             break
         case Qt.Key_Space:
             handleImage.height = rootWorkspace.height -  mMarkerTypeSelecter.height
             break
        }

        canvas.drawUpdate(true)
        event.accepted = true;
    }
}
