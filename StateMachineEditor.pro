TEMPLATE = app

QT += qml quick widgets

SOURCES += main.cpp \
    metadatautil.cpp \
    fileio.cpp \
    transitionline.cpp \
    connectionline.cpp \
    qmlthumbnailprovider.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    metadatautil.h \
    fileio.h \
    transitionline.h \
    connectionline.h \
    qmlthumbnailprovider.h

