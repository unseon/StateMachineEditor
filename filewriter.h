#ifndef FILEWRITER_H
#define FILEWRITER_H

#include <QObject>

class FileWriter : public QObject
{
    Q_OBJECT
public:
    explicit FileWriter(QObject *parent = 0);

signals:
public slots:
    void write(const QString& fileUrl, const QString& data);
};

#endif // FILEWRITER_H
