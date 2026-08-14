#include "packetbuilder.h"
#include <QDataStream>
#include <QDebug>

PacketBuilder::PacketBuilder(QObject *parent)
    : QObject(parent)
{
}

void PacketBuilder::appendInt16(QByteArray &packet, qint16 value)
{
    QDataStream stream(&packet, QIODevice::Append);
    stream.setByteOrder(QDataStream::LittleEndian);
    stream << value;
}

void PacketBuilder::appendFloat(QByteArray &packet, float value)
{
    QDataStream stream(&packet, QIODevice::Append);
    stream.setByteOrder(QDataStream::LittleEndian);
    stream << value;
}

void PacketBuilder::setEnumOptions(int paramIndex, const QStringList &options)
{
    m_enumOptions[paramIndex] = options;
}

QByteArray PacketBuilder::buildPacket(const QVariantList &orderedValues)
{
    QByteArray packet;

    packet.append(static_cast<char>(0xAA));
    packet.append(static_cast<char>(0x55));

    for (int i = 0; i < orderedValues.size(); ++i) {
        const QVariant &val = orderedValues[i];

        double stepSize = m_stepSizes.value(i, 1.0);  // tanımlı değilse varsayılan: int davranışı

        if (stepSize < 1.0) {
            // Ondalıklı adım -> her zaman float olarak kodla.
            // val.toDouble(): val int gelse de (örn. 2.0) sorunsuz double'a çevirir,
            // bu yüzden değerin O AN'ki tipine değil, parametrenin stepSize
            // TANIMINA göre karar veriyoruz.
            appendFloat(packet, val.toDouble());
        } else if (val.type() == QVariant::String) {
            // Enum parametresi
            qint16 enumId = 0;
            if (m_enumOptions.contains(i)) {
                int idx = m_enumOptions[i].indexOf(val.toString());
                if (idx >= 0) {
                    enumId = static_cast<qint16>(idx);
                } else {
                    qWarning() << "Bilinmeyen enum değeri:" << val.toString() << "index:" << i;
                }
            }
            appendInt16(packet, enumId);
        } else {
            // Normal int parametre
            appendInt16(packet, static_cast<qint16>(val.toInt()));
        }
    }

    char checksum = 0;
    for (char byte : qAsConst(packet)) {
        checksum ^= byte;
    }
    packet.append(checksum);

    return packet;
}