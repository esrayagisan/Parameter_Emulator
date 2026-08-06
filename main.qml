import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: 450
    height: 300
    title: "Hello World"

    GridLayout {
        anchors.centerIn: parent
        columns: 3
        columnSpacing: 15
        rowSpacing: 15

        // Satır 1 — Parametre 1 (Int)
        Text {
            text: "Parametre 1:"
            Layout.alignment: Qt.AlignLeft
        }
        TextField {
            id: param1Field
            placeholderText: "0"
            Layout.preferredWidth: 100
            Layout.alignment: Qt.AlignLeft
            validator: IntValidator {
                bottom: -2147483647
                top: 2147483647
            }
        }
        Text {
            Layout.alignment: Qt.AlignLeft
            text: "birim"
        }

        // Satır 2 — Parametre 2 (Dropdown, default "Choose..")
        Text {
            text: "Parametre 2:"
            Layout.alignment: Qt.AlignLeft
        }
        ComboBox {
            id: param2Field
            Layout.preferredWidth: 100
            Layout.alignment: Qt.AlignLeft
            model: ["Choose..", "A", "B", "C"]
            currentIndex: 0
        }
        Text {
            Layout.alignment: Qt.AlignRight
            text: "birim"
        }

        // Satır 3 — Parametre 3 (Ölçek: Slider + % Input, çift yönlü bağlı)
        Text {
            text: "Ölçek:"
            Layout.alignment: Qt.AlignLeft
        }
        RowLayout {
            spacing: 8
            Layout.preferredWidth: 220

            Slider {
                id: scaleSlider
                from: 0
                to: 500
                value: 100
                Layout.preferredWidth: 140

                onValueChanged: {
                    if (!scaleInput.activeFocus) {
                        scaleInput.text = Math.round(value) + "%"
                    }
                }
            }

            TextField {
                id: scaleInput
                text: "100%"
                Layout.preferredWidth: 70
                validator: RegularExpressionValidator {
                    regularExpression: /^[0-9]{1,3}%?$/
                }

                onEditingFinished: {
                    var num = parseInt(text.replace("%", ""))
                    if (!isNaN(num)) {
                        num = Math.max(scaleSlider.from, Math.min(scaleSlider.to, num))
                        scaleSlider.value = num
                        text = num + "%"
                    } else {
                        text = Math.round(scaleSlider.value) + "%"
                    }
                }
            }
        }
        Text {
            text: ""
        }
    }
}