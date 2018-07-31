#include "qmlthumbnailprovider.h"
#include <QDebug>
#include <QQuickItem>

#include <qqmlengine.h>
#include <qquickimageprovider.h>
#include <QImage>
#include <QQuickItemGrabResult>

#include <QQuickView>

class QmlThumbnailResponse : public QQuickImageResponse
{
    public:
        QmlThumbnailResponse(const QString &id, const QSize &requestedSize)
         : m_id(id), m_requestedSize(requestedSize)
        {

        }

        QQuickTextureFactory *textureFactory() const override
        {
            return QQuickTextureFactory::textureFactoryForImage(m_image);
        }

        void grab() {
            //QQmlEngine engine;
            //QQmlComponent component(&engine, m_id);
            //m_item = qobject_cast<QQuickItem*>(component.create());

            auto grabResult = m_item->grabToImage(m_requestedSize);

            connect(grabResult.data(), &QQuickItemGrabResult::ready,
                [=](){
                    m_image = grabResult->image();
                    delete m_item;
                    emit finished();
            });
        }

        QQuickItem* m_item;
        QString m_id;
        QSize m_requestedSize;
        QImage m_image;
};

QQuickImageResponse *QmlThumbnailProvider::requestImageResponse(const QString &id, const QSize &requestedSize)
{
    auto response = new QmlThumbnailResponse(id, requestedSize);
    response->grab();
    return response;
}
