/********************************************************************
Copyright 2021 DongshuangZhao <imtoby@126.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
THE USE OR OTHER DEALINGS IN THE SOFTWARE.
********************************************************************/
import QtQuick 2.12

PathView {
    id: id_stepper
    objectName: "qml-action-stepper"

    property bool isUserClicked: false
    property int normalPixelSize: 36
    property int currentPixelSize: 48
    property int textHorizontalAlignment: Text.AlignHCenter
    property int textVerticalAlignment: Text.AlignVCenter
    property int maxWidth: 112

    readonly property int currentItemHeight: currentPixelSize * 2

    function setCurrentIndex(index) {
        positionViewAtIndex(index, PathView.Center)
    }

    implicitWidth: 240
    implicitHeight: 480
    flickDeceleration: 500
    pathItemCount: 5
    preferredHighlightBegin: 0.5
    preferredHighlightEnd: 0.5
    highlightRangeMode: PathView.StrictlyEnforceRange
    snapMode: PathView.SnapToItem

    path: Path {
        startX: id_stepper.width/2
        startY: 0
        PathLine {
            x: id_stepper.width/2
            y: id_stepper.height
        }
    }

    delegate: Text {
        id: id_show_content
        width: id_stepper.width
        height: font.pixelSize * 2
        horizontalAlignment: textHorizontalAlignment
        verticalAlignment: textVerticalAlignment
        text: model.modelData
        font.pixelSize: id_show_content.PathView.isCurrentItem
                        ? currentPixelSize : normalPixelSize
        color: id_show_content.PathView.isCurrentItem
               ? Colors.qaGray33 : Colors.qaGray99

        MouseArea {
            anchors.fill: parent
            onPressed: {
                isUserClicked = true
            }
            onReleased: {
                if (containsMouse) {
                    setCurrentIndex(id_show_content.PathView.isCurrentItem
                                    ? (index + 1) : index)
                }
            }
        }
    }
}

