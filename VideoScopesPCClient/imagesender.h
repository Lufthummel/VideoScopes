#ifndef IMAGESENDER_H
#define IMAGESENDER_H

#include <QObject>
#include <QtNetwork>
#include <QImage>
#include <vector>

class ImageSender : public QObject
{
    Q_OBJECT

    QTcpServer * _tcpServer;
    std::vector<QTcpSocket*> _connections;

    void checkForConnections();

public:
    explicit ImageSender(QObject *parent = 0);

    void sendMsg(QImage &image);

signals:

public slots:
};

#endif // IMAGESENDER_H
