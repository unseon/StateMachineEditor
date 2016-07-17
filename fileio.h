#ifndef FILEWRITER_H
#define FILEWRITER_H

#include <QObject>

class FileIo : public QObject
{
    Q_OBJECT
public:
    explicit FileIo(QObject *parent = 0);

signals:
public slots:
    void write(const QString& fileUrl, const QString& data);
public:
    Q_INVOKABLE QString read(const QString& fileUrl);
};

#endif // FILEWRITER_H
