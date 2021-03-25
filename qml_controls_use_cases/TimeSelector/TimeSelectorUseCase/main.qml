import QtQuick 2.12
import QtQuick.Window 2.12

import "qrc:/../../../qml_controls"

Window {
    width: 640
    height: 560
    visible: true
    title: qsTr("Time Selector")

    TimeSelector {
        id: id_time_selector
        anchors.centerIn: parent

        // test case 12 or 24
//        hourFormat: TimeSelector.HourFormat.QA_12Hours

        // test case unit
//        hourUnitItem.text: "时"
//        minuteUnitItem.text: "分"
//        secondUnitItem.text: "秒"
    }
}
