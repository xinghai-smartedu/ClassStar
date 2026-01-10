from PySide6.QtCore import QObject, Signal, Slot, Property
from PySide6.QtQml import QmlElement
from typing import List, Dict
import json
import os

# 注册QML元素
QmlElement = "TeamModel"

class TeamModel(QObject):
    def __init__(self):
        super().__init__()
        # 检查并加载数据
        data_file = "data/group.json"
        if os.path.exists(data_file):
            with open(data_file, 'r', encoding='utf-8') as f:
                self._teams = json.load(f)
        else:
            os.makedirs(os.path.dirname(data_file), exist_ok=True)
            self._teams = []
            with open(data_file, 'w', encoding='utf-8') as f:
                json.dump(self._teams, f, ensure_ascii=False, indent=2) 
        
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
    
class StudentModel(QObject):
    def __init__(self):
        super().__init__()
        # 检查并加载数据
        data_file = "data/student.json"
        if os.path.exists(data_file):
            with open(data_file, 'r', encoding='utf-8') as f:
                self._students = json.load(f)
        else:
            os.makedirs(os.path.dirname(data_file), exist_ok=True)
            self._students = []
            with open(data_file, 'w', encoding='utf-8') as f:
                json.dump(self._students, f, ensure_ascii=False, indent=2)
    
    @Slot(result='QVariantList')
    def get_students_in_group(self, teamId) -> List[Dict]:
        """获取所有学生数据"""
        students = []
        for student in self._students:
            if student['teamid'] == teamId:
                students.append(student)
        return students
