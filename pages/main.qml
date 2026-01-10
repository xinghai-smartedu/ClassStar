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

    // 添加状态变量来跟踪是否已加载数据
    property bool dataLoaded: false

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

    ListModel {
        id: teamtModel
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
            text: qsTr("总数: " + (typeof teamModel !== 'undefined' ? teamModel.get_team_count() : 0))
        }
    }
}