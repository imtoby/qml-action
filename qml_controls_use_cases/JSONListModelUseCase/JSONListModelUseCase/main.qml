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
import QtQuick.Window 2.12

import "qrc:/../../../qml_controls" as QC

Window {
    width: 480
    height: 270
    visible: true
    title: qsTr("Hello QC.JSONListModel")

    QC.JSONListModel {
        id: id_json_list_model

        onLoaded: {
            const obj = id_json_list_model.get(0)

            // traverse every data
            for (const key in obj) {
                console.log("id_json_list_model === name:", obj[key].name)
                console.log("id_json_list_model === type:", obj[key].type)
            }

            // get something
            id_test_txt.text = id_json_list_model.get(0).hamlet.name
        }

        Component.onCompleted: {
            loadLocalJsonFile("qrc:/plays.json")
        }
    }

    Text {
        id: id_test_txt
        anchors.centerIn: parent
    }
}
