#include <QGuiApplication>
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include "borderdata.h"
int main(int argc, char *argv[])
{
	QGuiApplication app(argc, argv);

	QQmlApplicationEngine engine;

	engine.rootContext()->setContextProperty("borderData", new BorderData);
	engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
	if (engine.rootObjects().isEmpty())
		return -1;

	return app.exec();
}
