import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: window
    visible: true
    width: 800
    height: 600
    Component.onCompleted: {
        var names = []
        for (var i = 0; i < parameterDefs.length; i++) {
            names.push(parameterDefs[i].name)

            // Enum tipi parametreler için seçenek listesini de bildir
            if (parameterDefs[i].type === "enum") {
                packetBuilder.setEnumOptions(i, parameterDefs[i].options)
            }
        }
        paramModel.setParameterOrder(names)
    }

    // ---- Parametre tanım listesi (tek yerden yönetiliyor) ----
    property var parameterDefs: [
        { id: 0, name: "Parametre 1", type: "int",    unit: "birim", min: -1000, max: 1000, defaultValue: 0 },
        { id: 1, name: "Parametre 2", type: "enum",   unit: "birim", options: ["Choose..", "A", "B", "C"] },
        { id: 2, name: "Ölçek",       type: "slider", unit: "%",     min: 0, max: 500, defaultValue: 100 },
        { id: 3, name: "Parametre 4", type: "int",    unit: "birim", min: 0, max: 100, defaultValue: 10 },
        { id: 4, name: "Parametre 5", type: "enum",   unit: "birim", options: ["Choose..", "X", "Y", "Z"] }
    ]

    Rectangle {
        id: rightPanel
        width: 350
        color: "#4d4d4d"
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right

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

                CheckBox { checked: true }
                Text { text: "Temel"; color: "white" }
                Item { Layout.fillWidth: true }
                Text {
                    text: parent.parent.expanded ? "▲" : "▼"
                    color: "white"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var col = parent.parent.parent
                            col.expanded = !col.expanded
                        }
                    }
                }
            }

            // ---- Parametreler burada otomatik üretiliyor ----
            ColumnLayout {
                visible: parent.expanded
                Layout.fillWidth: true
                Layout.fillHeight: false
                Layout.alignment: Qt.AlignTop
                spacing: 12

                Repeater {
                    model: window.parameterDefs

                    delegate: RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: modelData.name + ":"
                            color: "white"
                            Layout.preferredWidth: 100
                        }

                        Loader {
                            id: widgetLoader
                            Layout.preferredWidth: modelData.type === "slider" ? 220 : 100
                            sourceComponent: {
                                if (modelData.type === "int") return intComponent
                                if (modelData.type === "enum") return enumComponent
                                if (modelData.type === "slider") return sliderComponent
                                return null
                            }
                        }

                        Text {
                            text: modelData.unit
                            color: "white"
                            visible: modelData.type !== "slider"
                        }

                        // --- Int tipi ---
                        Component {
                            id: intComponent
                            TextField {
                                text: modelData.defaultValue.toString()
                                validator: IntValidator {
                                    bottom: modelData.min
                                    top: modelData.max
                                }

                                Component.onCompleted: {
                                    paramModel.setValue(modelData.name, modelData.defaultValue)
                                }

                                onEditingFinished: {
                                    console.log(modelData.name, "=", text)
                                    paramModel.setValue(modelData.name, parseInt(text))
                                }
                            }
                        }

                        // --- Enum (dropdown) tipi ---
                        Component {
                            id: enumComponent
                            ComboBox {
                                model: modelData.options
                                currentIndex: 0

                                Component.onCompleted: {
                                    paramModel.setValue(modelData.name, currentText)
                                }

                                onCurrentTextChanged: {
                                    console.log(modelData.name, "=", currentText)
                                    paramModel.setValue(modelData.name, currentText)
                                }
                            }
                        }

                        // --- Slider tipi ---
                        Component {
                            id: sliderComponent
                            RowLayout {
                                spacing: 8
                                Text { text: modelData.min + modelData.unit; color: "gray" }
                                Slider {
                                    id: paramSlider
                                    from: modelData.min
                                    to: modelData.max
                                    value: modelData.defaultValue
                                    stepSize: 1
                                    Layout.preferredWidth: 100
                                    Component.onCompleted: {
                                        paramModel.setValue(modelData.name, Math.round(value))
                                    }
                                    onValueChanged: {
                                        var rounded = Math.round(value)
                                        sliderInput.text = rounded.toString()
                                        console.log(modelData.name, "=", rounded)
                                        paramModel.setValue(modelData.name, rounded)
                                    }
                                }
                                Text { text: modelData.max + modelData.unit; color: "gray" }
                                TextField {
                                    id: sliderInput
                                    text: Math.round(paramSlider.value).toString()
                                    Layout.preferredWidth: 50
                                    validator: IntValidator { bottom: modelData.min; top: modelData.max }
                                    onEditingFinished: {
                                        var num = parseInt(text)
                                        if (!isNaN(num)) {
                                            paramSlider.value = Math.max(paramSlider.from, Math.min(paramSlider.to, num))
                                        }
                                        text = Math.round(paramSlider.value).toString()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    // ApplicationWindow içinde, rightPanel'in yanına ekle
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: rightPanel.left
        color: "#2a2a2a"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 5

            Text {
                text: "DEBUG - Anlık Parametre Değerleri"
                color: "yellow"
                font.bold: true
            }

            Repeater {
                model: window.parameterDefs
                delegate: Text {
                    id: debugText
                    color: "lightgreen"
                    font.family: "Courier"

                    // İlk değeri göster
                    Component.onCompleted: updateText()

                    function updateText() {
                        var val = paramModel.getValue(modelData.name)
                        debugText.text = modelData.name + ": " + (val !== undefined ? val : "-")
                    }

                    Connections {
                        target: paramModel
                        function onValueChanged(name, value) {
                            if (name === modelData.name) {
                                debugText.updateText()
                            }
                        }
                    }
                }
            }

            Button {
                text: "Tüm Değerleri Yazdır (Console)"
                onClicked: {
                    var all = paramModel.getAllValues()
                    console.log("=== Tüm Parametreler ===")
                    for (var key in all) {
                        console.log(key, "=", all[key])
                    }
                }
            }
        }
    }
}