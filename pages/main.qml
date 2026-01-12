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
    property int currentTeamId: -1  // 当前选中的团队ID

    // 创建一个学生模型
    ListModel {
        id: studentModel
    }

    function updateTeamsFromBackend() {
        // 从Python后端获取数据
        var teams = teamModel.get_teams();
        teamtModel.clear();
        for (var i = 0; i < teams.length; i++) {
            teamtModel.append(teams[i]);
        }
        dataLoaded = true; // 标记数据已加载
    }

    // 从后端获取指定团队的学生信息
    function updateStudentsForTeam(teamId) {
        console.log("Attempting to load students for teamId:", teamId);
        try {
            // 检查学生模型是否存在
            if (typeof studentModelBackend !== 'undefined') {
                console.log("studentModelBackend found, calling get_students_in_group");
                var students = studentModelBackend.get_students_in_group(teamId);
                console.log("Received students data:", students);
                
                studentModel.clear();
                for (var i = 0; i < students.length; i++) {
                    console.log("Adding student:", students[i]);
                    studentModel.append(students[i]);
                }
                currentTeamId = teamId;  // 记录当前查看的团队ID
                console.log("Updated student model with", studentModel.count, "students");
            } else {
                console.error("studentModelBackend is undefined!");
            }
        } catch (error) {
            console.error("Error getting students for team:", error);
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

    // 主要内容区域
    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal

        // 团队列表区域
        Item {
            width: 350
            height: 300
            SplitView.minimumWidth: 250
            SplitView.preferredWidth: 350
            
            // 显示数据列表
            ListView {
                id: listView
                anchors.fill: parent
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
                        updateStudentsForTeam(model.teamid);  // 加载该团队的学生信息
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

        // 学生信息展示区域
        Item {
            id: studentInfoPanel
            implicitWidth: 550
            SplitView.minimumWidth: 300
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10
                
                Text {
                    id: teamTitle
                    text: currentTeamId !== -1 ? 
                         ("第" + currentTeamId + "组 / 共" +teamModel.get_team_count() + "组") : 
                         "请选择一个小组查看学生信息"
                    font.pointSize: 32
                    font.bold: true
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }
                
                // 学生列表
                ListView {
                    id: studentListView
                    model: studentModel
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ScrollBar.vertical: ScrollBar {}
                    
                    delegate: SettingCard {
                        Layout.fillWidth: true
                        title: model.name
                        description: "学号: " + model.studentid + " | 分数: " + model.score
                        
                        // 右侧可以放置一些操作按钮
                        content: Row {
                            spacing: 10
                            
                            Text {
                                text: "分数: " + model.score
                                font.bold: true
                            }

                            Button { 
                                text: "+1"
                                onClicked: {
                                    studentModelBackend.addScore(model.studentid, 1);
                                    updateStudentsForTeam(currentTeamId); // 更新后重新加载数据
                                }
                            }
                            Button { 
                                text: "-1"
                                onClicked: {
                                    studentModelBackend.addScore(model.studentid, -1);
                                    updateStudentsForTeam(currentTeamId); // 更新后重新加载数据
                                }
                            }
                        }
                    }
                }
                
                // 如果没有选择团队，显示提示信息
                Text {
                    text: currentTeamId === -1 ? 
                          "请在左侧选择一个团队以查看其学生信息" : 
                          ""
                    visible: currentTeamId === -1
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    font.italic: true
                    color: Theme.currentTheme.colors.textSecondaryColor
                }
            }
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
    }
}