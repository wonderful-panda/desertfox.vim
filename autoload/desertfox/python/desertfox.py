# coding: utf-8
import os

_qtapp = None

try:
    from PySide import QtGui
    _qtapp = QtGui.QApplication([])
except ImportError:
    pass

def save_clipboard_image(path):
    if _qtapp is None:
        return -1, "PySide must be installed"
    format = os.path.splitext(path)[-1].lstrip('.').upper()
    if format not in ('JPG', 'JPEG', 'PNG', 'BMP'):
        return 1, 'Unsupported image format: ' + format

    image = _qtapp.clipboard().image()
    if image.width() == 0:
        return 2, 'Image data is not found in clipboard'
    if not image.save(path, format):
        return 3, 'Failed to save image: ' + path
    return 0, 'Created: ' + path
