#include "connectionline.h"

ConnectionLine::ConnectionLine(QQuickItem *parent)
    : QQuickPaintedItem(parent),
      m_startPoint(0.0f, 0.0f),
      m_endPoint(0.0f, 0.0f),
      m_startDirection(ToVertical),
      m_color("#000000"),
      m_thickness(1.0f),
      m_hitTolerance(7.0f),
      m_roundness(40.0f)
{

}

void ConnectionLine::paint(QPainter *painter)
{
    QPen pen(m_color);
    pen.setWidthF(m_thickness);

    painter->setPen(pen);
    painter->setRenderHint(QPainter::Antialiasing);

    painter->drawPath(path);
    painter->drawPath(arrow);
}

void ConnectionLine::updateRect()
{
    setX(qMin(m_startPoint.x(), m_endPoint.x()) - m_hitTolerance);
    setY(qMin(m_startPoint.y(), m_endPoint.y()) - m_hitTolerance);
    setWidth(qMax(m_startPoint.x(), m_endPoint.x()) - x() + m_hitTolerance);
    setHeight(qMax(m_startPoint.y(), m_endPoint.y()) - y() + m_hitTolerance);

    QPointF startPoint;
    QPointF endPoint;
    QPointF midPoint;

    path = QPainterPath();
    arrow = QPainterPath();

    qDebug() << "Test" << m_startDirection;

    if (m_startPoint.y() == m_endPoint.y() && m_startPoint.x() < m_endPoint.x()) {
        // draw horizontal straight right line
        startPoint = m_startPoint - QPointF(x(), y());
        endPoint = m_endPoint - QPointF(x(), y());

        path.moveTo(startPoint);
        path.lineTo(endPoint);

        arrow.moveTo(endPoint.x() - m_thickness * 5, endPoint.y() - m_thickness * 3);
        arrow.lineTo(endPoint);
        arrow.lineTo(endPoint.x() - m_thickness * 5, endPoint.y() + m_thickness * 3);
    } else if (m_startPoint.x() == m_endPoint.x() && m_startPoint.y() < m_endPoint.y()) {
        // draw vertical straight down line
        startPoint = m_startPoint - QPointF(x(), y() - m_thickness / 2);
        endPoint = m_endPoint - QPointF(x(), y() + m_thickness / 2);

        path.moveTo(startPoint);
        path.lineTo(endPoint);

        arrow.moveTo(endPoint.x() - m_thickness * 3, endPoint.y() - m_thickness * 5);
        arrow.lineTo(endPoint);
        arrow.lineTo(endPoint.x() + m_thickness * 3, endPoint.y() - m_thickness * 5);

    } else if (m_startPoint.x() == m_endPoint.x() && m_startPoint.y() > m_endPoint.y()) {
        // draw vertical straight upper line
        startPoint = m_startPoint - QPointF(x(), y() + m_thickness / 2);
        endPoint = m_endPoint - QPointF(x(), y() - m_thickness / 2);

        path.moveTo(startPoint);
        path.lineTo(endPoint);

        arrow.moveTo(endPoint.x() - m_thickness * 3, endPoint.y() + m_thickness * 5);
        arrow.lineTo(endPoint);
        arrow.lineTo(endPoint.x() + m_thickness * 3, endPoint.y() + m_thickness * 5);

    } else if (m_startDirection == ToHorizontal && m_startPoint.x() > m_endPoint.x()) {
        startPoint = m_startPoint - QPointF(x() + m_thickness / 2, y());
        endPoint = m_endPoint - QPointF(x(), y() - m_thickness / 2);
        midPoint = QPointF(endPoint.x(), startPoint.y());

        path.moveTo(startPoint);
        path.lineTo(midPoint.x() + m_roundness, midPoint.y());
        path.cubicTo(QPointF(midPoint.x() + m_roundness / 2, midPoint.y()),
                     QPointF(midPoint.x(), midPoint.y() - m_roundness /  2),
                     QPointF(midPoint.x(), midPoint.y() - m_roundness));
        path.lineTo(endPoint);

        arrow.moveTo(endPoint.x() - m_thickness * 3, endPoint.y() + m_thickness * 5);
        arrow.lineTo(endPoint);
        arrow.lineTo(endPoint.x() + m_thickness * 3, endPoint.y() + m_thickness * 5);
    } else if (m_startDirection == ToVertical && m_startPoint.x() < m_endPoint.x()) {
        startPoint = m_startPoint - QPointF(x(), y() - m_thickness / 2);
        endPoint = m_endPoint - QPointF(x() + m_thickness / 2, y());
        midPoint = QPointF(startPoint.x(), endPoint.y());

        path.moveTo(startPoint);
        path.lineTo(midPoint.x(), midPoint.y() - m_roundness);
        path.cubicTo(QPointF(midPoint.x(), midPoint.y() - m_roundness / 2),
                     QPointF(midPoint.x() + m_roundness /  2, midPoint.y()),
                     QPointF(midPoint.x() + m_roundness, midPoint.y()));
        path.lineTo(endPoint);

        arrow.moveTo(endPoint.x() - m_thickness * 5, endPoint.y() - m_thickness * 3);
        arrow.lineTo(endPoint);
        arrow.lineTo(endPoint.x() - m_thickness * 5, endPoint.y() + m_thickness * 3);
    }
}

void ConnectionLine::setStartPoint(const QPointF &p)
{
    if (m_startPoint != p) {
        m_startPoint = p;
        emit startPointChanged();

        updateRect();
    }
}

QPointF ConnectionLine::startPoint() const
{
    return m_startPoint;
}

void ConnectionLine::setEndPoint(const QPointF &p)
{
    if (m_endPoint != p) {
        m_endPoint = p;
        emit endPointChanged();

        updateRect();
    }
}

QPointF ConnectionLine::endPoint() const
{
    return m_endPoint;
}

void ConnectionLine::setStartDirection(const StartDirection &dir)
{
    if (m_startDirection != dir) {
        m_startDirection = dir;
        qDebug() << "startDirectionChanged: " << m_startDirection;
        emit startDirectionChanged();

        updateRect();
    }
}

ConnectionLine::StartDirection ConnectionLine::startDirection() const
{
    return m_startDirection;
}

void ConnectionLine::setThickness(const qreal &thickness)
{
    if (m_thickness != thickness) {
        m_thickness = thickness;
        emit thicknessChanged();
    }
}

qreal ConnectionLine::thickness() const
{
    return m_thickness;
}

void ConnectionLine::setColor(const QColor &color)
{
    if (m_color != color) {
        m_color = color;
        emit colorChanged();
        update();
    }
}

QColor ConnectionLine::color() const
{
    return m_color;
}

void ConnectionLine::setHitTolerance(const qreal& tol)
{
    if (m_hitTolerance != tol) {
        m_hitTolerance = tol;
        emit hitToleranceChanged();
    }
}

qreal ConnectionLine::hitTolerance() const
{
    return m_hitTolerance;
}

void ConnectionLine::setRoundness(const qreal &r)
{
    if (m_roundness != r) {
        m_roundness = r;
        emit roundnessChanged();
    }
}

qreal ConnectionLine::roundness() const
{
    return m_roundness;
}

bool ConnectionLine::hitTest(qreal x, qreal y) const
{
    QPainterPath hitPath(path);

    QPainterPath reversePath = hitPath.toReversed();

    hitPath.connectPath(reversePath);

    QPainterPath circle;
    circle.addEllipse(QPointF(x, y),  m_hitTolerance, m_hitTolerance);

    qDebug() << x << y;

    if (circle.intersects(hitPath)) {
        return true;
    } else {
        return false;
    }
}
