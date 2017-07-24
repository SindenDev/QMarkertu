#ifndef BORDERDATA_H
#define BORDERDATA_H

#include <QObject>
#include <QColor>
#include <QVariant>
class BorderData : public QObject
{
    Q_OBJECT
public:
    explicit BorderData(QObject *parent = nullptr);
    ~BorderData();
signals:

public slots:
   inline  QStringList getColorNames() const { return QColor::colorNames();}
// 
   QString fitHyper(int index,int imgHeight, const QString &data) const;
   void writeData(const QString &name, const QVariant &data);
   QString readData(const QString &name)const;
};

#endif // BORDERDATA_H
