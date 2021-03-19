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

import "." as QA

/*!
    \qmltype TimeSelector
    \inqmlmodule qml-action
    \since 1.0
    \ingroup controls
    \brief a time selector like mobile phone
    \image TimeSelector.png
*/

Item {
    id: id_time_selector
    objectName: "qml-action-time-selector"
    implicitWidth: 580
    implicitHeight: 520

    enum HourFormat {
        QA_24Hours = 0,
        QA_12Hours
    }

    property int hourFormat: TimeSelector.HourFormat.QA_24Hours

    readonly property bool is24HourFormat:
        TimeSelector.HourFormat.QA_24Hours === hourFormat

    property int hour: id_private_data.currentSystemHours()
    property alias hourEnabled: id_hour_selector.visible

    property int minute: id_private_data.currentSystemMinutes()

    property int second: id_private_data.currentSystemSeconds()
    property alias secondEnabled: id_second_selector.visible

    readonly property alias hourUnitItem: id_unit_hour
    readonly property alias minuteUnitItem: id_unit_minute
    readonly property alias secondUnitItem: id_unit_second

    readonly property bool adjusting: id_noon_selector.moving
                                      || id_hour_selector.moving
                                      || id_minute_selector.moving
                                      || id_second_selector.moving

    function time(separate) {
        let t = ""
        if (id_hour_selector.visible) {
            t += id_private_data.addZero(hour)
            t += separate.toString()
        }
        t += id_private_data.addZero(minute)
        if (id_second_selector.visible) {
            t += separate.toString()
            t += id_private_data.addZero(second)
        }
        return t
    }

    function setTime(hh, mm, ss) {
        hour = id_private_data.bound(0, hh, 23)
        minute = id_private_data.bound(0, mm, 59)
        second = id_private_data.bound(0, ss, 59)
    }

    Row {
        anchors.fill: parent
        spacing: 0

        QA.NoonSelector {
            id: id_noon_selector
            property int maxWidth: 120
            visible: !is24HourFormat
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: - normalPixelSize / 2
            height: id_hour_selector.currentItemHeight
            onCurrentIndexChanged: {
                if (!is24HourFormat && (12 === id_hour_selector.count)) {
                        hour = ((id_hour_selector.currentIndex + 1) % 12)
                        + ((0 === id_noon_selector.currentIndex) ? 0 : 12)
                }
            }
        }

        Column {
            id: id_hour_selector_column
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: id_hour_selector.width
            spacing: id_unit_hour.visible ? 6 : 0
            QA.Stepper {
                id: id_hour_selector
                onVisibleChanged: id_private_data.doLayout()
                onCurrentIndexChanged:{
                    if(dragging || flicking || isUserClicked){
                        id_private_data.updateHour()
                        isUserClicked = false
                    }
                }
            }

            QA.UnitText {
                id: id_unit_hour
            }
        }

        Column {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: id_minute_selector.width
            spacing: id_unit_minute.visible ? 6 : 0
            QA.Stepper {
                id: id_minute_selector
                onCurrentIndexChanged:{
                    if(dragging || flicking || isUserClicked){
                        id_private_data.updateMinute()
                        isUserClicked = false
                    }
                }
            }

            QA.UnitText {
                id: id_unit_minute
            }
        }

        Column {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: id_second_selector.width
            spacing: id_unit_second.visible ? 6 : 0

            QA.Stepper {
                id: id_second_selector
                onVisibleChanged: id_private_data.doLayout()
                onCurrentIndexChanged:{
                    if(dragging || flicking || isUserClicked){
                        id_private_data.updateSecond()
                        isUserClicked = false
                    }
                }
            }

            QA.UnitText {
                id: id_unit_second
            }
        }
    }

    Component.onCompleted: {
        id_private_data.updateTimeHour()
        id_private_data.updateTimeMinute()
        id_private_data.updateTimeSecond()
        id_private_data.doLayout()
    }

    onHourChanged: {
        if (!id_private_data.isUserOperated){
            id_private_data.setHours(hour)
        }
    }

    onIs24HourFormatChanged: {
        id_private_data.doLayout()
        id_private_data.updateTimeHour()
    }

    onMinuteChanged: {
        if (!id_private_data.isUserOperated) {
            id_private_data.setMinutes(minute)
        }
    }

    onSecondChanged: {
        if (!id_private_data.isUserOperated){
            id_private_data.setSeconds(second)
        }
    }

    onVisibleChanged: {
        if (visible && (typeof id_private_data !== "undefined")) {
            id_private_data.doLayout()
        }
    }

    onWidthChanged: {
        id_private_data.doLayout()
    }

    QtObject{
        id: id_private_data

        property bool isUserOperated: false
        property var arrayHours: new Array
        property var arrayMinutes: new Array
        property var arraySeconds: new Array
        property var currentSystemDate: new Date

        function updateTimeHour() {
            let index = hour
            if (!is24HourFormat) {
                if (arrayHours.length > 12) {
                    id_noon_selector.currentIndex
                            = (id_hour_selector.currentIndex > 11) ? 1 : 0
                    index = (index + 11) % 12
                }

                if (arrayHours.length > 0 && arrayHours.length <= 12 ) {
                    if (id_noon_selector.currentIndex === 0) {
                        index = (index + 1) % 12
                    } else {
                        index = (index + 1) % 12 + 12
                    }
                }

                if (0 === arrayHours.length) {
                    index = (index + 11) % 12
                }
            }

            if (arrayHours.length > 0) {
                arrayHours = []
            }

            let i = 0

            if (is24HourFormat) {
                for (i=0; i<=23; ++i) {
                    arrayHours.push(addZero(i))
                }
            } else {
                for (i=1; i<=12; ++i) {
                    arrayHours.push(addZero(i))
                }
            }
            id_hour_selector.model = undefined
            id_hour_selector.model = arrayHours
            id_hour_selector.setCurrentIndex(index)
        }

        function updateTimeMinute() {
            arrayMinutes = []
            for (let i=0; i<=59; ++i) {
                arrayMinutes.push(addZero(i))
            }
            id_minute_selector.model = undefined
            id_minute_selector.model = arrayMinutes
            id_minute_selector.setCurrentIndex( bound(0, minute, 59) )
        }

        function updateTimeSecond() {
            arraySeconds = []
            for (let i=0; i<=59; ++i) {
                arraySeconds.push(addZero(i))
            }
            id_second_selector.model = undefined
            id_second_selector.model = arraySeconds
            id_second_selector.setCurrentIndex( bound(0, second, 59) )
        }

        function doLayout() {
            let n = 0
            if (!is24HourFormat) {
                n += 1
            }
            if (id_hour_selector.visible) {
                n += 1
            }
            if (id_minute_selector.visible) {
                n += 1
            }
            if (id_second_selector.visible) {
                n += 1
            }
            if (n > 0) {
                let w = width/n
                if(w > id_noon_selector.maxWidth) {
                    if (!is24HourFormat) {
                        id_noon_selector.width = w
                    }
                    if (id_hour_selector.visible) {
                        id_hour_selector.width = w
                    }
                    if (id_minute_selector.visible) {
                        id_minute_selector.width = w
                    }
                    if (id_second_selector.visible) {
                        id_second_selector.width = w
                    }
                } else {
                    if (!is24HourFormat) {
                        id_noon_selector.width = id_noon_selector.maxWidth
                    }
                    w = (width - id_noon_selector.maxWidth)/(n-1)
                    if (w > id_hour_selector.maxWidth) {
                        if (id_hour_selector.visible){
                            id_hour_selector.width = w
                        }
                        if (id_minute_selector.visible) {
                            id_minute_selector.width = w
                        }
                        if (id_second_selector.visible) {
                            id_second_selector.width = w
                        }
                    } else {
                        if (id_hour_selector.visible) {
                            id_hour_selector.width = id_hour_selector.maxWidth
                        }
                        if (id_minute_selector.visible) {
                            id_minute_selector.width
                                    = id_minute_selector.maxWidth
                        }
                        if (id_second_selector.visible) {
                            id_second_selector.width
                                    = id_second_selector.maxWidth
                        }
                    }
                }
            }
        }

        function bound(min, value, max) {
            return Math.max(min, Math.min(value, max))
        }

        function addZero(num) {
            if( num <= 9 ){
                num = "0" + num
            }
            return num.toString()
        }

        function updateHour() {
            isUserOperated = true
            if (!is24HourFormat) {
                hour = ((id_hour_selector.currentIndex + 1)% 12)
                        + ((0 === id_noon_selector.currentIndex) ? 0 : 12)
            }else{
                hour = id_hour_selector.currentIndex
            }
            isUserOperated = false
        }

        function updateMinute() {
            isUserOperated = true
            minute = id_minute_selector.currentIndex
            isUserOperated = false
        }

        function updateSecond() {
            isUserOperated = true
            second = id_second_selector.currentIndex
            isUserOperated = false
        }

        function setHours(hours) {
            let h = bound(0, hours, 23)
            if (!is24HourFormat) {
                id_noon_selector.currentIndex = (h > 11 ? 1: 0)
            }
            if(!is24HourFormat) {
                h = (h + 11) % 12
            }
            id_hour_selector.setCurrentIndex( h )
        }

        function setMinutes(minutes) {
            id_minute_selector.setCurrentIndex( bound(0, minutes, 59) )
        }

        function setSeconds(seconds) {
            id_second_selector.setCurrentIndex( bound(0, seconds, 59) )
        }

        function currentSystemHours() {
            return currentSystemDate.getHours()
        }

        function currentSystemMinutes() {
            return currentSystemDate.getMinutes()
        }

        function currentSystemSeconds() {
            return currentSystemDate.getSeconds()
        }

    }

}
