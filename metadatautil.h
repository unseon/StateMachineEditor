#ifndef METADATAUTIL_H
#define METADATAUTIL_H

#include <QObject>
#include <QList>
#include <QString>

class MetaDataUtil : public QObject
{
    Q_OBJECT
public:
    explicit MetaDataUtil(QObject *parent = 0);


    Q_INVOKABLE QList<QString> signalList(QObject* obj);

};

#endif // METADATAUTIL_H
