from PySide6.QtCore import QObject, Signal, Slot, Property
from PySide6.QtQml import QmlElement
from typing import List, Dict

# 注册QML元素
QmlElement = "TeamModel"

class TeamModel(QObject):
    def __init__(self):
        super().__init__()
        # 示例数据
        self._teams = [
            {"teamid": 1, "name": "第一组", "leader": "Tim Cook", "score": 85},
            {"teamid": 2, "name": "第二组", "leader": "Tim Cook", "score": 92},
            {"teamid": 3, "name": "第三组", "leader": "Tim Cook", "score": 78},
            {"teamid": 4, "name": "第四组", "leader": "Tim Cook", "score": 96}
        ]
        
    @Slot(result='QVariantList')
    def get_teams(self) -> List[Dict]:
        """获取所有团队数据"""
        return self._teams
    
    @Slot(int, result='QVariant')
    def get_team_by_id(self, team_id: int) -> Dict:
        """根据ID获取特定团队数据"""
        for team in self._teams:
            if team['teamid'] == team_id:
                return team
        return {}
    
    @Slot(result=int)
    def get_team_count(self) -> int:
        """获取团队总数"""
        return len(self._teams)