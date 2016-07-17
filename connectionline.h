#ifndef CONNECTIONLINE_H
#define CONNECTIONLINE_H

#include <QtQuick>

class ConnectionLine : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(QPointF startPoint READ startPoint WRITE setStartPoint NOTIFY startPointChanged)
    Q_PROPERTY(QPointF endPoint READ endPoint WRITE setEndPoint NOTIFY endPointChanged)
    Q_PROPERTY(StartDirection startDirection READ startDirection WRITE setStartDirection NOTIFY startDirectionChanged)
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(qreal thickness READ thickness WRITE setThickness NOTIFY thicknessChanged)
    Q_PROPERTY(qreal hitTolerance READ hitTolerance WRITE setHitTolerance NOTIFY hitToleranceChanged)
    Q_PROPERTY(qreal roundness READ roundness WRITE setRoundness NOTIFY roundnessChanged)

public:
    enum StartDirection {
        ToHorizontal,
        ToVertical
    };

    Q_ENUMS(StartDirection)

    ConnectionLine(QQuickItem * parent = 0);

    void paint(QPainter *painter);

    void setStartPoint(const QPointF& p);
    QPointF startPoint() const;

    void setEndPoint(const QPointF& p);
    QPointF endPoint() const;

    void setStartDirection(const StartDirection& dir);
    StartDirection startDirection() const;

    void setColor(const QColor& color);
    QColor color() const;

    void setThickness(const qreal& thickness);
    qreal thickness() const;

    void setHitTolerance(const qreal& tol);
    qreal hitTolerance() const;

    void setRoundness(const qreal& r);
    qreal roundness() const;

    Q_INVOKABLE bool hitTest(qreal x, qreal y) const;

signals:
    void startPointChanged();
    void endPointChanged();
    void startDirectionChanged();
    void colorChanged();
    void thicknessChanged();
    void hitToleranceChanged();
    void roundnessChanged();

public slots:

private:
    QPointF m_startPoint;
    QPointF m_endPoint;
    StartDirection m_startDirection;
    QColor m_color;
    qreal m_thickness;
    qreal m_hitTolerance;
    qreal m_roundness;

    QPainterPath path;
    QPainterPath arrow;

private:
    void updateRect();
};

#endif // CONNECTIONLINE_H
