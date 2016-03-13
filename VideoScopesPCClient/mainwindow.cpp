#include <iostream>
#include <QScreen>

#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow),
    imageSender(new ImageSender(this))
{
    ui->setupUi(this);
    timer = new QTimer(this);
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::captureShot() {
    QScreen *screen = QGuiApplication::primaryScreen();
    if (screen) {
        pixmap = screen->grabWindow(0);
        ui->img_label->setPixmap(pixmap.scaled(ui->img_label->size(),
                                               Qt::KeepAspectRatio,
                                               Qt::SmoothTransformation));

        QImage img =  pixmap.scaled(QSize(1280,720),
                                    Qt::KeepAspectRatio,
                                    Qt::SmoothTransformation).toImage();

        imageSender->sendMsg(img);
    }
}

void MainWindow::startStream()
{
    std::cout << "starting stream." << std::endl;

    connect(timer,SIGNAL(timeout()), this, SLOT(captureShot()));
    timer->start(1000);
}

void MainWindow::stopStream()
{
    timer->stop();
}
