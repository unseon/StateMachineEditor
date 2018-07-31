#ifndef QMLTHUMBNAILPROVIDER_H
#define QMLTHUMBNAILPROVIDER_H

#include <QQuickImageProvider>

class QmlThumbnailProvider : public QQuickAsyncImageProvider
{
public:
    QQuickImageResponse *requestImageResponse(const QString &id, const QSize &requestedSize) override;
};

#endif // QMLTHUMBNAILPROVIDER_H
