#include "metadatautil.h"
#include <QMetaObject>
#include <QMetaMethod>

MetaDataUtil::MetaDataUtil(QObject *parent) : QObject(parent)
{

}

QList<QString> MetaDataUtil::signalList(QObject *obj)
{
    QList<QString> result;

    const QMetaObject* metaObject = obj->metaObject();
    int methodCount = metaObject->methodCount();

    for (int i = 0; i < methodCount; i++) {
        if (metaObject->method(i).methodType() == QMetaMethod::Slot) {
            result.append(metaObject->method(i).name());
        }
    }

    return result;
}
