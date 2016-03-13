#-------------------------------------------------
#
# Project created by QtCreator 2016-03-10T22:29:39
#
#-------------------------------------------------

QT       += core gui network

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = VideoScopesPCClient
TEMPLATE = app


SOURCES += main.cpp\
        mainwindow.cpp \
    imagesender.cpp

HEADERS  += mainwindow.h \
    imagesender.h

FORMS    += mainwindow.ui

RESOURCES += \
    mainresources.qrc
