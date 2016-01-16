#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "fileio.h"
#include "metadatautil.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    FileIo fileIo;
    MetaDataUtil metaDataUtil;

    engine.addImportPath("qrc:/");
    engine.rootContext()->setContextProperty("fileIo", &fileIo);
    engine.rootContext()->setContextProperty("metaDataUtil", &metaDataUtil);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

