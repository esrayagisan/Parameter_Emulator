#ifndef PACKETBUILDER_H
#define PACKETBUILDER_H

#include <QObject>
#include <QByteArray>
#include <QVariantList>
#include <QMap>
#include <QStringList>

class PacketBuilder : public QObject
{
    Q_OBJECT

public:
    explicit PacketBuilder(QObject *parent = nullptr);

    QByteArray buildPacket(const QVariantList &orderedValues);

    // Yeni: her parametre index'i için enum seçenek listesini kaydet
    // key: parametre sırasındaki index (0,1,2...), value: seçenek listesi
    Q_INVOKABLE void setEnumOptions(int paramIndex, const QStringList &options);


private:
    void appendInt16(QByteArray &packet, qint16 value);
    void appendFloat(QByteArray &packet, float value);

    QMap<int, QStringList> m_enumOptions;
    QMap<int, double> m_stepSizes;
};

#endif // PACKETBUILDER_H