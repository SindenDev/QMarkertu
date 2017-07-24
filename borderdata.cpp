#include "borderdata.h"
#include <QFile>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QLibrary>
#include <QDebug>
//#include "fitHyperDll.h"
#define  FIT_SAMPLE_SIZE 100
//Qt库是MinGW版本，gcc编译器生成，与VC++编译器不是同个体系。所以工程不可以使用testdll.h头文件和testdll.lib引入库文件。
//对于调用DLL的方法，Qt本身就有相应的类来实现。
#ifdef MinGW_Compiler
typedef void (*func_FittingHyperbola)(const double* pointSet, int n, int h, float* hyperbola);
typedef void (*func_CreateHyperbola)(float* hyperbola, double finalY, int imgHeight, int sampledPointsNum, float* samplePoints);
func_FittingHyperbola  Fun_fittingHyperbola;
func_CreateHyperbola Fun_createHyperbola;
#endif
BorderData::BorderData(QObject *parent) : QObject(parent)
{
#ifdef MinGW_Compiler
    QLibrary fitHyperDll("fitHyperDll.dll");
    Fun_fittingHyperbola = (func_FittingHyperbola) fitHyperDll.resolve("?FittingHyperbola@@YAXPBNHHPAM@Z");
    Fun_createHyperbola = (func_CreateHyperbola) fitHyperDll.resolve("?createHyperbola@@YAXPAMNHH0@Z");
#endif
}
BorderData::~BorderData()
{

}
//曲线拟合
QString BorderData::fitHyper(int index ,int imgHeight,const QString &data ) const
{
	QString fit_data_json = "[]";
	QJsonParseError json_error;
	QJsonDocument parse_doucment = QJsonDocument::fromJson(data.toLatin1(), &json_error);
	
	if (json_error.error == QJsonParseError::NoError) 
	{
		if (parse_doucment.isObject()) 
		{
			QJsonObject obj = parse_doucment.object();
			double vanishing_point = (obj.take("roadLine")).toDouble();
			qDebug() << "vanishing_point:" << vanishing_point;
			if (obj.contains("markers")) 
			{			
				QJsonArray markers = (obj.take("markers")).toArray();
				
				//for (QJsonValue marker : markers)
				//{
					QJsonArray  points =  (markers[index].toObject().take("points")).toArray();

					qDebug() << "points.count():" << points.count();
					if (points.count() < 3) return fit_data_json;

					QVector<double> pointList;

					for (QJsonValue point : points)
					{
						pointList << point.toObject().take("x").toDouble() << point.toObject().take("y").toDouble();
						//qDebug() << point.toObject().take("x") << point.toObject().take("y");
					}
					
					float hyperbola[4] = { 0 }; float samplePoints[FIT_SAMPLE_SIZE] = { 0 };
                    Fun_fittingHyperbola(pointList.constData(), pointList.length(), vanishing_point, hyperbola);
					
					qDebug()<< pointList.at(0) << pointList.at(1) << pointList.at(pointList.length()-2) << " " << pointList.last();
                    Fun_createHyperbola(hyperbola, pointList.last(), imgHeight, FIT_SAMPLE_SIZE/2, samplePoints);
					fit_data_json.clear();
					fit_data_json += "[";
					for (int i = 0; i < FIT_SAMPLE_SIZE; i += 2)
					{
						qDebug() << "x:" << samplePoints[i]<<"y" << samplePoints[i + 1];
						/*if (samplePoints[i] < pointList.at(0)) {
							fit_data_json += QString("{\"x\":%1,\"y\":%2},").arg(pointList.at(0)).arg(pointList.at(1));
							break;
						}*/
						fit_data_json += QString("{\"x\":%1,\"y\":%2},").arg(samplePoints[i]).arg(samplePoints[i + 1]);
					}
					fit_data_json = fit_data_json.left(fit_data_json.length() - 1);
					fit_data_json += "]";

				//}
			}
		}
	}
	//qDebug() << "fitHyper" <<data.length();
	qDebug()<<"fit_data_json:" << fit_data_json;
	
	return fit_data_json;
}
void BorderData::writeData(const QString &name, const QVariant &data)
{
    QString file_path = name;
	qDebug() << "writeData:" << file_path;
    if(file_path.startsWith("file://"))
    {
#if Q_OS_UNIX
		file_path = name.mid(7);
#else
		file_path = name.mid(8);
#endif
    }else if (file_path.startsWith("qrc:/"))
    {
        file_path = "." + name.mid(7);
    }

    QFile file(file_path);

    if(!file.open(QIODevice::WriteOnly))
    {
        qDebug() << "File error " << file_path ;
        return ;
    }

    file.write(data.toByteArray());
    file.close();
}

QString BorderData::readData(const QString &name) const
{
    QString file_path = name;

    if(file_path.startsWith("file://"))
    {
#if Q_OS_UNIX
        file_path = name.mid(7);
#else
		file_path = name.mid(8);
#endif
    }
    else if (file_path.startsWith("qrc:/"))
    {
        file_path = "." + name.mid(7);
    }


    QFile file(file_path);

    if(!file.open(QIODevice::ReadOnly))
    {
        return QString("{\"roadLine\":0,\"markers\":[{\"type\":0,\"color\": \"#5f0f8a\", \"points\":[]}]}");
    }
    QByteArray data = file.readAll();
    file.close();

    return QString(data);
}
