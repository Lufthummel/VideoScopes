#include <iostream>
#include <QScreen>

#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow),
    imageSender(new ImageSender(this)),
    pointLocation(QPoint(0,0)),
    screenSize(QPoint(-1,-1))
{
    ui->setupUi(this);
    timer = new QTimer(this);
}

MainWindow::~MainWindow()
{
    delete ui;
}

void scanForPoint(QPoint& pointToModify, const QString& text) {
    QStringList list = text.split(QRegExp("(\\s*,\\s*|\\s+)"), QString::SkipEmptyParts);
    if (list.size() >= 2) {
        bool ok = true;
        int x = list[0].toInt(&ok);
        int y = list[1].toInt(&ok);
        if(ok) {
            pointToModify.setX(x);
            pointToModify.setY(y);
        }
    }
}

void MainWindow::captureShot() {
    QScreen *screen = QGuiApplication::primaryScreen();
    if (screen) {

        scanForPoint(pointLocation, ui->lineEdit->text());
        scanForPoint(screenSize, ui->lineEdit_2->text());

        //to do add constraints
        pixmap = screen->grabWindow(0,pointLocation.x(), pointLocation.y(),
                                    screenSize.x(), screenSize.y());
        ui->img_label->setPixmap(pixmap.scaled(ui->img_label->size(),
                                               Qt::KeepAspectRatio,
                                               Qt::SmoothTransformation));

        QImage img =  pixmap.scaled(QSize(800,600),
                                    Qt::KeepAspectRatio,
                                    Qt::SmoothTransformation).toImage();

        imageSender->sendMsg(img);
    }
}

void MainWindow::startStream()
{
    std::cout << "starting stream." << std::endl;

    connect(timer,SIGNAL(timeout()), this, SLOT(captureShot()));
    timer->start(2000);
}

void MainWindow::stopStream()
{
    timer->stop();
}
