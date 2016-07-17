#ifndef TRANSITIONLINE_H
#define TRANSITIONLINE_H

#include <QQuickPaintedItem>
#include <QColor>

class TransitionLine : public QQuickPaintedItem
{
    Q_OBJECT

    Q_PROPERTY(int x0 MEMBER m_x0 NOTIFY x0Changed)
    Q_PROPERTY(int y0 MEMBER m_y0 NOTIFY x0Changed)

    Q_PROPERTY(int x1 MEMBER m_x1 NOTIFY x1Changed)
    Q_PROPERTY(int y1 MEMBER m_y1 NOTIFY x1Changed)

    Q_PROPERTY(int width MEMBER m_width NOTIFY widthChanged)
    Q_PROPERTY(QColor color MEMBER m_color NOTIFY colorChanged)



public:
    TransitionLine();
    void paint(QPainter *painter);

    enum StartDirection {
        Up,
        Down,
        Left,
        Right
    };

    Q_ENUMS(StartDirection)

signals:
    void x0Changed();
    void y0Changed();

    void x1Changed();
    void y1Changed();

    void widthChanged();
    void colorChanged();

public slots:

private:
    int m_x0;
    int m_y0;

    int m_x1;
    int m_y1;

    int m_width;
    QColor m_color;
};

#endif // TRANSITIONLINE_H
