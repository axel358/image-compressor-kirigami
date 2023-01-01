import sys
import os
from PySide2.QtWidgets import QApplication
from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtCore import QObject, Signal, Slot, QStandardPaths
from PIL import Image
from pathlib import Path


class MainWindow(QObject):

    def __init__(self):
        QObject.__init__(self)

    showToast = Signal(str)
    infoChanged = Signal(str)
    imageChanged = Signal(str)

    def formatSize(self, size, decimal_places=1):
        for unit in ['B', 'KiB', 'MiB', 'GiB', 'TiB']:
            if size < 1024:
                break
            size /= 1024.0
        return f'{size:.{decimal_places}f} {unit}'

    @Slot(str, float, float, str)
    def compressImage(self, path, quality, resolution, format):
        self.openFile = path.replace('file://', '')
        self.format = format
        tempDir = QStandardPaths.writableLocation(QStandardPaths.CacheLocation)

        if not os.path.exists(tempDir):
            os.makedirs(tempDir)

        self.tempFile = os.path.join(tempDir, 'temp.jpg')
        with Image.open(self.openFile) as image:
            scale_factor = resolution
            quality = int(quality * 100)
            resized_image = image.resize([
                int(image.width * scale_factor),
                int(image.height * scale_factor)
            ])
            resized_image.save(self.tempFile,
                               format=format,
                               quality=quality,
                               method=6,
                               optimize=True)

        with Image.open(self.tempFile) as image:
            self.infoChanged.emit(
                str(image.width) + 'x' + str(image.height) + ' ' +
                self.formatSize(Path(self.tempFile).stat().st_size))

            self.imageChanged.emit(self.tempFile)

    @Slot()
    def saveImage(self):
        name = os.path.basename(self.openFile)
        saveName = os.path.splitext(name)[0] + '.' + self.format.lower()
        saveFile = os.path.join(
            QStandardPaths.writableLocation(QStandardPaths.PicturesLocation),
            saveName)

        with open(self.tempFile, 'rb') as tmpFile:
            with open(saveFile, 'wb') as _saveFile:
                _saveFile.write(tmpFile.read())

        self.showToast.emit('Saved to Pictures')


if __name__ == '__main__':
    app = QApplication(sys.argv)
    app.setApplicationName("Image Compressor")
    engine = QQmlApplicationEngine()
    main = MainWindow()

    engine.rootContext().setContextProperty('backend', main)
    engine.load('main.qml')

    sys.exit(app.exec_())
