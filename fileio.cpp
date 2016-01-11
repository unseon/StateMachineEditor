#include "fileio.h"

#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QUrl>


FileIo::FileIo(QObject *parent) : QObject(parent)
{

}

void FileIo::write(const QString& fileUrl, const QString& data)
{
    QUrl url(fileUrl);
    QFile file(url.path());

    if (!file.open(QFile::WriteOnly | QFile::Truncate))
         return;

    QTextStream out(&file);
    out << data;
    file.close();
}

QString FileIo::read(const QString& fileUrl)
{
    QUrl url(fileUrl);
    QFile file(url.path());

    QString result;

    if (!file.open(QFile::ReadOnly))
         return result;

    QTextStream in(&file);
    result = in.readAll();
    file.close();

    return result;
}

