#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtQml>

#include "fileio.h"
#include "metadatautil.h"
#include "connectionline.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    FileIo fileIo;
    MetaDataUtil metaDataUtil;

    qmlRegisterType<ConnectionLine>("ConnectionLine", 1, 0, "ConnectionLine");

    engine.addImportPath("qrc:/");
    engine.rootContext()->setContextProperty("fileIo", &fileIo);
    engine.rootContext()->setContextProperty("metaDataUtil", &metaDataUtil);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

