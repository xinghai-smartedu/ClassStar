import sys
from PySide6.QtWidgets import QApplication
from models import TeamModel, StudentModel
import RinUI
from RinUI import RinUIWindow


if __name__ == '__main__':
    team_model = TeamModel()
    student_model = StudentModel()  # 创建学生模型实例
    print(RinUI.__file__)
    app = QApplication(sys.argv)
    mainWindow = RinUIWindow("pages/main.qml")
    engine = mainWindow.engine
    engine.rootContext().setContextProperty("teamModel", team_model)
    engine.rootContext().setContextProperty("studentModelBackend", student_model)  # 注册学生模型
    app.exec()