#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QLabel>
#include <QTimer>

#include "imagesender.h"

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

private:
    Ui::MainWindow *ui;
    QPixmap pixmap;
    QTimer * timer;
    ImageSender * imageSender;
    QPoint pointLocation, screenSize;

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

public slots:
    void startStream();
    void stopStream();
    void captureShot();
};

#endif // MAINWINDOW_H
