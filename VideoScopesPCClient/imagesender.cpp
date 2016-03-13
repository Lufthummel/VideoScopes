#include "imagesender.h"

ImageSender::ImageSender(QObject *parent) :
    QObject(parent),
    _tcpServer(new QTcpServer(this))
{
    _tcpServer->listen(QHostAddress::Any, 8000);
    _connections = std::vector<QTcpSocket*>();
}

void ImageSender::sendMsg(QImage& image)
{
    QByteArray byteArr;
    QBuffer buff(&byteArr);
    buff.open(QIODevice::WriteOnly);
    image.save(&buff, "PNG");

    checkForConnections();

    //max byte count is 2^32 bytes
    uint32_t byteCount = byteArr.length();

    qDebug() << "sending message byteCount:" << byteCount;

    for(auto socket : _connections) {
        socket->write((const char *)&byteCount, sizeof(byteCount));
        socket->write(byteArr.data(), byteCount);
        qDebug() << "sent!";
    }
}

//==================================================
//PRIVATE
//==================================================

void ImageSender::checkForConnections() {

    //check for any dead connections. There's a bug here.
    for(auto socket = _connections.begin(); socket != _connections.end(); socket++) {
        if (!_tcpServer->children().contains(*socket)) {
            _connections.erase(socket);
            qDebug("Removed socket.");
        }
    }


    //add new connections to _connections
    QTcpSocket * sock;
    while (sock = _tcpServer->nextPendingConnection()) {
        _connections.push_back(sock);
    }
}
