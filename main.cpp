#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "filewriter.h"
#include "metadatautil.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    FileWriter fileWriter;
    MetaDataUtil metaDataUtil;

    engine.rootContext()->setContextProperty("fileWriter", &fileWriter);
    engine.rootContext()->setContextProperty("metaDataUtil", &metaDataUtil);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

