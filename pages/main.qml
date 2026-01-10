import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import RinUI


Window {
    width: 900
    height: 600
    visible: true
    title: qsTr("班级星")

    // 示例学生数据模型
    ListModel {
        id: studentModel
        ListElement { name: "第一组"; leader: "Tim Cook"; score: 85; }
        ListElement { name: "第二组"; leader: "Tim Cook"; score: 92; }
        ListElement { name: "第三组"; leader: "Tim Cook"; score: 78; }
        ListElement { name: "第四组"; leader: "Tim Cook"; score: 96; }
    }
 ListView {
    width: 350
    height: 300
    model: studentModel

    delegate: ListViewDelegate {
        // width is typically bound to ListView.view.width by the delegate itself
        // height is adaptive by default (contents.implicitHeight + 20)

        leftArea: Text { // leftArea is a Text item
            text: model.score // Main text from model
            font.pixelSize: 12
            color: Theme.currentTheme.colors.textSecondaryColor
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
        middleArea: [ // middleArea takes a list of items for its ColumnLayout
            Text {
                text: model.name // Main text from model
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            },
            Text {
                text: model.leader // Secondary text from model
                font.pixelSize: 12
                color: Theme.currentTheme.colors.textSecondaryColor
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        ]

        rightArea: ToolButton { // Example: a ToolButton on the right
            icon.name: "ic_fluent_chevron_right_20_regular"
            flat: true
            size: 16
            Layout.alignment: Qt.AlignVCenter // Aligns button within the RowLayout of rightArea
            onClicked: {
                console.log("More options for:", model.titleText);
            }
        }

        onClicked: {
            console.log("Clicked on item:", model.titleText);
            // ListView.view.currentIndex is automatically updated by the delegate's default onClicked handler
        }
    }
}
        // 底部按钮行
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4
            Button {
                highlighted: true
                text: qsTr("Click me!")
                onClicked: dialog.open()

                Dialog {
                    id: dialog
                    modal: true
                    title: qsTr("Dialog")
                    Text {
                        text: qsTr("This is a dialog.")
                    }
                    standardButtons: Dialog.Ok | Dialog.Cancel
                }
            }
            Button {
                text: qsTr("Button")
            }
        }
    }
