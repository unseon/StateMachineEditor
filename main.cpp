#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "filewriter.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    FileWriter fileWriter;

    engine.rootContext()->setContextProperty("fileWriter", &fileWriter);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

