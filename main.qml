import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: window
    visible: true
    width: 800
    height: 600

    Rectangle {
        id: rightPanel
        width: 320
        color: "#4d4d4d"
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        // Sürüklenebilir kenar tutamacı
        Rectangle {
            id: resizeHandle
            width: 5
            color: "transparent"
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.SizeHorCursor
                drag.target: parent
                drag.axis: Drag.XAxis

                onMouseXChanged: {
                    if (drag.active) {
                        var newWidth = rightPanel.width - mouseX
                        rightPanel.width = Math.max(200, Math.min(500, newWidth))
                    }
                }
            }
        }

        ColumnLayout {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            spacing: 15

            property bool expanded: true

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: false
                Layout.alignment: Qt.AlignTop

                CheckBox { id: temelCheck; checked: true }
                Text { text: "Temel"; color: "white" }
                Item { Layout.fillWidth: true }
                Text {
                    text: expanded ? "▲" : "▼"
                    color: "white"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: expanded = !expanded
                    }
                }
            }

            ColumnLayout {
                visible: expanded
                Layout.fillWidth: true
                Layout.fillHeight: false     // ← kritik satır
                Layout.alignment: Qt.AlignTop

                RowLayout {
                    Text { text: "Parametre 1:"; color: "white" }
                    TextField {
                        id: param1Field
                        placeholderText: "0"
                        Layout.preferredWidth: 100
                        validator: IntValidator { bottom: -2147483647; top: 2147483647 }
                    }
                    Text { text: "birim"; color: "white" }
                }

                RowLayout {
                    Text { text: "Parametre 2:"; color: "white" }
                    ComboBox {
                        id: param2Field
                        Layout.preferredWidth: 100
                        model: ["Choose..", "A", "B", "C"]
                        currentIndex: 0
                    }
                    Text { text: "birim"; color: "white" }
                }

                RowLayout {
                    Text { text: "Level"; color: "white" }
                }

                RowLayout {
                    Text { text: scaleSlider.from + "%"; color: "gray" }
                    Slider {
                        id: scaleSlider
                        from: 0
                        to: 500
                        value: 100
                        Layout.preferredWidth: 140
                        onValueChanged: scaleInput.text = Math.round(value) + "%"
                    }
                    Text { text: scaleSlider.to + "%"; color: "gray" }
                    TextField {
                        id: scaleInput
                        text: Math.round(scaleSlider.value)
                        Layout.preferredWidth: 70
                        validator: RegularExpressionValidator { regularExpression: /^[0-9]{1,3}%?$/ }
                        onEditingFinished: {
                            var num = parseInt(text.replace("%", ""))
                            if (!isNaN(num)) {
                                num = Math.max(scaleSlider.from, Math.min(scaleSlider.to, num))
                                scaleSlider.value = num
                            }
                            text = Math.round(scaleSlider.value) + "%"
                        }
                    }
                }
            }

            // Kalan boş alanı burada topla, içeriği yukarıda sıkıştırılmış tutar
            Item {
                Layout.fillHeight: true
            }
        }
    }

}


