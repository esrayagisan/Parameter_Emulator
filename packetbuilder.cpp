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

        if (val.type() == QVariant::Int) {
            appendInt16(packet, static_cast<qint16>(val.toInt()));
        } else if (val.type() == QVariant::Double) {
            appendFloat(packet, val.toFloat());
        } else if (val.type() == QVariant::String) {
            // Bu index bir enum parametresiyse, seçenek listesinde ara
            qint16 enumId = 0; // bulunamazsa güvenli varsayılan
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
            appendInt16(packet, 0);
        }
    }

    char checksum = 0;
    for (char byte : qAsConst(packet)) {
        checksum ^= byte;
    }
    packet.append(checksum);

    return packet;
}