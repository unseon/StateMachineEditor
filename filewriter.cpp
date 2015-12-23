#include "filewriter.h"

#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QUrl>


FileWriter::FileWriter(QObject *parent) : QObject(parent)
{

}

void FileWriter::write(const QString& fileUrl, const QString& data)
{
    QUrl url(fileUrl);
    QFile file(url.path());

    if (!file.open(QFile::WriteOnly | QFile::Truncate))
         return;

    QTextStream out(&file);
    out << data;
    file.close();
}

