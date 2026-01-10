import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import Qt.labs.platform as Labs
import RinUI


Window {
    width: 900
    height: 600
    visible: true
    title: qsTr("班级星")

    // 添加状态变量来跟踪是否已加载数据
    property bool dataLoaded: false
    property string message: ""

    function updateTeamsFromBackend() {
        // 从Python后端获取数据
        if (typeof teamModel !== 'undefined') {
            var teams = teamModel.get_teams();
            teamtModel.clear();
            for (var i = 0; i < teams.length; i++) {
                teamtModel.append(teams[i]);
            }
            dataLoaded = true; // 标记数据已加载
        }
    }

    // 导入Excel数据
    function importFromExcel(filePath) {
        try {
            var success = teamModel.import_from_excel(filePath);
            
            if (success) {
                updateTeamsFromBackend();
                // 可以显示成功消息
                message = "Excel数据导入成功！";
                successMessage.open();
            } else {
                console.error("Failed to import Excel data");
                // 可以显示错误消息
                message = "Excel数据导入失败，请检查文件格式！";
                errorMessage.open();
            }
        } catch (error) {
            console.error("Error importing Excel data:", error);
            message = "导入过程中发生错误: " + error.message;
            errorMessage.open();
        }
    }

    // 隐藏成功消息的定时器
    Timer {
        id: hideSuccessMessageTimer
        interval: 3000
        onTriggered: {
            successMessage.visible = false;
        }
    }

    ListModel {
        id: teamtModel
    }

    // 文件对话框用于选择导入文件
    Labs.FileDialog {
        id: excelFileDialog
        title: qsTr("请选择要导入的Excel文件")
        nameFilters: ["Excel files (*.xlsx *.xls)", "All files (*)"]
        
        onAccepted: {
            importFromExcel(excelFileDialog.file);
        }
        
        onRejected: {
            console.log("File selection cancelled");
        }
    }

    // 显示"请获取数据"或ListView
    Item {
        width: 350
        height: 300
        
        // 显示数据列表
        ListView {
            id: listView
            width: 350
            height: 300
            model: teamtModel
            visible: dataLoaded
            
            delegate: ListViewDelegate {
                leftArea: Text {
                    text: model.score
                    font.pixelSize: 12
                    color: Theme.currentTheme.colors.textSecondaryColor
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                middleArea: [
                    Text {
                        text: model.name
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    },
                    Text {
                        text: model.leader
                        font.pixelSize: 12
                        color: Theme.currentTheme.colors.textSecondaryColor
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                ]

                rightArea: ToolButton {
                    icon.name: "ic_fluent_chevron_right_20_regular"
                    flat: true
                    size: 16
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: {
                        console.log("More options for:", model.name);
                    }
                }

                onClicked: {
                    console.log("Clicked on item:", model.teamid);
                }
            }
        }
        
        // 显示"请获取数据"按钮
        Text {
            id: loadingText
            text: qsTr("请点击下方刷新数据按钮获取数据")
            anchors.centerIn: parent
            visible: !dataLoaded  // 只有在未加载数据时才显示
        }
        
        // 成功消息
        Dialog {
            id: successMessage
            modal: true
            Text {
                text: qsTr(message)
            }
            standardButtons: Dialog.Ok | Dialog.Cancel
        }
        
        // 错误消息
        Dialog {
            id: errorMessage
            modal: true
            Text {
                text: qsTr(message)
            }
            standardButtons: Dialog.Ok | Dialog.Cancel
        }
    }

    // 底部按钮行
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 30
        spacing: 4
        Button {
            highlighted: true
            text: qsTr("刷新数据")
            onClicked: {
                updateTeamsFromBackend();
            }
        }
        Button {
            text: qsTr("导入Excel")
            onClicked: {
                excelFileDialog.open();
            }
        }
        Button {
            text: qsTr("总数: " + (typeof teamModel !== 'undefined' ? teamModel.get_team_count() : 0))
        }
    }
}