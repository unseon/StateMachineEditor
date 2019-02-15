#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtQml>

#include "fileio.h"
#include "metadatautil.h"
#include "connectionline.h"
#include "qmlthumbnailprovider.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    FileIo fileIo;
    MetaDataUtil metaDataUtil;

    qmlRegisterType<ConnectionLine>("ConnectionLine", 1, 0, "ConnectionLine");

    engine.addImportPath("qrc:/");
    engine.rootContext()->setContextProperty("fileIo", &fileIo);
    engine.rootContext()->setContextProperty("metaDataUtil", &metaDataUtil);

    //engine.addImageProvider(QLatin1String("colors"), new QmlThumbnailProvider);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

