import sys
from PySide6.QtWidgets import QApplication
from models import TeamModel
import RinUI
from RinUI import RinUIWindow


if __name__ == '__main__':
    team_model = TeamModel()
    print(RinUI.__file__)
    app = QApplication(sys.argv)
    gallery = RinUIWindow("pages/main.qml")
    engine = gallery.engine
    engine.rootContext().setContextProperty("teamModel", team_model)
    app.exec()