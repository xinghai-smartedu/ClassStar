"""
Example:
Group:
[
    { teamid: 1, name: "团队1", leader: "张三", score: 27 }
]

Student:
[
    { studentid: 1, name: "张三", teamid: 1, score: 27 },
    { studentid: 2, name: "李四", teamid: 1, score: 28 },
    { studentid: 3, name: "王五", teamid: 1, score: 29 },
    { studentid: 4, name: "赵六", teamid: 1, score: 30 },
]
"""

from PySide6.QtCore import QObject, Slot
from PySide6.QtQml import QmlElement
from typing import List, Dict
import json
import os
import pandas as pd  # 

# 定义QML元素
QML_IMPORT_NAME = "models"
QML_IMPORT_MAJOR_VERSION = 1

@QmlElement
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
            self._teams = [
                {
                    "teamid": 1,
                    "name": "请先导入数据",
                    "leader": "请先导入数据",
                    "score": 0
                }
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
    
    @Slot(str, result=bool)
    def import_from_excel(self, file_path: str) -> bool:
        """从Excel文件导入团队数据"""
        print("正在导入团队数据...")
        print(file_path)
        try:
            # 读取Excel文件
            df = pd.read_excel(file_path)
            
            # 清空现有数据
            self._teams = []
            
            # 遍历Excel数据并添加到团队列表
            for index, row in df.iterrows():
                team_data = {
                    "teamid": int(row.get('编号', index+1)),
                    "name": str(row.get('名称', f'第{index+1}组')),
                    "leader": str(row.get('队长', '暂无')),
                    "score": int(row.get('分数', 0))
                }
                self._teams.append(team_data)
            
            # 保存到JSON文件
            data_file = "data/group.json"
            with open(data_file, 'w', encoding='utf-8') as f:
                json.dump(self._teams, f, ensure_ascii=False, indent=2)
                
            print(f"成功从Excel导入 {len(self._teams)} 个团队")
            return True
        except Exception as e:
            print(f"导入Excel失败: {str(e)}")
            return False

@QmlElement
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
        """获取指定团队的学生数据"""
        students = []
        for student in self._students:
            if student['teamid'] == teamId:
                students.append(student)
        return students
    
    @Slot(str, result=bool)
    def import_students_from_excel(self, file_path: str) -> bool:
        """从Excel文件导入学生数据"""
        try:
            # 读取Excel文件
            df = pd.read_excel(file_path, sheet_name='students')
            
            # 清空现有数据
            self._students = []
            
            # 遍历Excel数据并添加到学生列表
            for index, row in df.iterrows():
                student_data = {
                    "studentid": int(row.get('studentid', index+1)),
                    "name": str(row.get('name', f'学生{index+1}')),
                    "teamid": int(row.get('teamid', 1)),
                    "score": int(row.get('score', 0))
                }
                self._students.append(student_data)
            
            # 保存到JSON文件
            data_file = "data/student.json"
            with open(data_file, 'w', encoding='utf-8') as f:
                json.dump(self._students, f, ensure_ascii=False, indent=2)
                
            print(f"成功从Excel导入 {len(self._students)} 个学生")
            return True
        except Exception as e:
            print(f"导入学生Excel失败: {str(e)}")
            return False