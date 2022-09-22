import sys
from mywindow import *
from PyQt5 import QtCore

def main():
	QApplication.setAttribute(QtCore.Qt.AA_UseDesktopOpenGL) # Tive muitos problemas com o OpenGL que só foram resolvidos depois de adicionar essa linha no código
	app = QApplication(sys.argv)
	gui = MyWindow()
	gui.show()
	sys.exit(app.exec_())

if __name__ == '__main__':
	main()
