unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpenGL, MMSystem, StdCtrls, Buttons, uConsts, ExtCtrls, DGLUT;

type
  TMas = record
    Coordin: GLFloat;
    Visible: Boolean;
  end;

  TShowState = (ssNull = 1, ssText, ssAxis, ssObras, ssDetector,
    ssEl1, ssEl2, ssEl3, ssGunDraw,
    ssConus, ssHyper, ssInnerCyl, ssOuterCyl, ssGun,
    ssKamera1, ssStartE1, ssStartE2, ssStartE3, ssStop1, ssTurned1, ssStop2,
    ssUtih, ssClipped, ssStop3, ssShowed, ssStop4,
    ssStart1EAll, ssStop41, ssTurned2,
    ssStop5, ssUtih2, ssBlended, ssShowed2, ssStop6,
    ssStart2E1, ssStart2E2, ssStart2E3, ssStop7, ssTurned3, ssStop8,
    ssUtih3, ssBlendedAndClipped, ssShowed3, ssStop9, ssRotate1, ssStart2EAll,
    ssStop10, ssRotateNazad, ssStop11, ssVesdNadRotate, ssStop12, ssTurned4, ssUdal,
    ssStop13, ssUtih4, ssStop14, ssShowed4);

  TDrawProc = procedure of object;

  TfmMain = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure Timer1Timer(Sender: TObject);
  private
    DC : HDC;
    hrc: HGLRC;

    aVertexP, aVertexP2, aVertexP3: Array [0..800, 0..1] of TMas;//Координаты пути
    aVertexG: Array [0..60,0..1] of GLFloat;           //Координаты гиперболоида

    StepPros: array[1..18] of Double;
    CountStepPros: Integer;

    quadObj: GLUquadricObj;
    r1, r12, r13, dl: Double;
    Count, CoordS, CoordS2, CoordS3: Integer;       //Сколько всего точек в пути и какая
    // Вращение и масштабирование
    ScaleF: GLFloat;
    VAngleX, VAngleY, VAngleZ, MouseX, MouseY: Integer;
    Clipped, Blended, GoElectrum, Pic, TextDraw: Boolean;

    PolygonMode, QuadricDrawStyle: GLenum;

    TimerId : uint;  // идентификатор таймера
    CurState: TShowState;

    // Расчетные функции
    procedure LineGO;
    procedure LineOA;         //Забивает в массив координаты ОА
    procedure LineAB;         //Забивает в массив координаты АВ
    procedure LineBC;         //Забивает в массив координаты ВС
    procedure LineCD;         //Забивает в массив координаты CD
    procedure LineDE;         //Забивает в массив координаты DE
    procedure LineEF;         //Забивает в массив координаты EF
    procedure LineFO;         //Забивает в массив координаты FO
    // Рисование
    procedure DrawAxis;       //Вызывает процедуру DrawOs
    procedure DrawConus;      //Вызывает процедуры DrawConusL и DrawConusR
    procedure DrawHyper;      //Вызывает процедуру DrawGiper
    procedure DrawOuterCyl;   //Рисует внешний цилиндр
    procedure DrawInnerCyl;   //Рисует внутренний цилиндр
    procedure DrawConusL;     //Рисует левый конус
    procedure DrawConusR;     //Рисует правый конус
    procedure DrawOs;         //Рисует ось
    procedure DrawObras;      //Исследуемый образец
    procedure DrawDetector;   //Рисует детектор
    procedure DrawGiper;      //Рисует гиперболоид
    procedure DrawPath;       //Рисует путь до электрона
    procedure DrawPath2;      //Рисует путь до электрона 2
    procedure DrawPath3;      //Рисует путь до электрона 3
    procedure DrawElectrum;   //Рисует электрон
    procedure DrawElectrum2;   //Рисует электрон 2
    procedure DrawElectrum3;   //Рисует электрон 3
    procedure DrawEl1;        //Вызывает процедуры DrawPath и DrawElectrum
    procedure DrawEl2;        //Вызывает процедуры DrawPath2 и DrawElectrum2
    procedure DrawEl3;        //Вызывает процедуры DrawPath3 и DrawElectrum3
    procedure DrawGun;        //Рисует пушку

    procedure DrawText;       //Пишет тему
    procedure DrawUtih;       //Все изображение постепенно исчезает
    procedure StepProsProc;
    procedure DrawNathing;
    end;

const
  ProjectTitle1 = 'The electrostatic energy-analyzer';
  ProjectTitle2 = 'of beam of charged particles';

  CountProcvet = 20;            //ДЛя процветания
  Alfa = 0.8 / (CountProcvet + 1);

  GLF_START_LIST = 1000;       //Для текста
  VAngleStep = 2;              //Поврот на этот угол
  //Для видио
  BlendStep = 0.005;           //+ к появлению конусов в прозрачности
  TimerDelay = 40;             //время на таймере
  TextDelay = 4000;
  NullDelay = 1000;            //время сколько держать пустой экран
  StopNaesd = 2.1000;          //Сколько наезжать (предел)
  StopRotate = - 16;           //Сколько поворачивать (предел)
  //****************************************************************************

  AlfaG = 40;                  //Угол входа в градусах
  AlfaR = AlfaG * Pi / 180;    //Угол входа в радианах
  U = 0.8;                     //Мю
  S = 0.3;                     //S
  Z1 = 0.3;                    //Z1
  Z2 = 0.3495;                 //Z2
  P = 0.6687785;               //Параметр отражения целиндрического зеркала до верт оси
  P1 =0.7795728;               //Параметр отражения целиндрического зеркала после верт оси
  Te = 0.912578;               //Тетта до верт оси
  Te1 = 1.193042;              //Тетта после верт оси

  Rc = 30;                     //Радиус внутреннего цилиндра
  HeightCZ = 272.6408;         //Полная длина
  L1 = 135.4109;               //Длина до верт оси
  L2 = HEightCZ - L1;          //Оставщаяся длина
  Ro = U * Rc;                 //Радиус гиперболоида

  O1A = 35.7526;               //Участок траектории О1А
  AB = 87.2811;                //Участок траектории АВ (парабола)
  BC = 3.3772;                 //Участок траектории ВС
  CO = 9;                      //Участок траектории CO
  OD = 10.491;                 //Участок траектории OD
  DE = 1.5771;                 //Участок траектории DE
  EF = 98.6459;                //Участок траектории EF (парабола)
  FO2 = 26.5159;               //Участок траектории FO2
  HeightG = 50;                //Длина гиперболоида

  HeightC1 = 33.3183;          //?

  //РАзмеры пушки
  RGun  = 4;                   //Радиус корпуса
  HeightGun = 14;               //Длина корпуса
  //Размер дула
  RGunMuzzle  = 2;             //Радиус дула
  HeightGunMuzzle = 3;         //Длина дула
  HGun = 30;                   //Расстояние от оси до пушки
  LGun = 20;                   //Расстояние от цилиднра до пушки
  GunAlfa = 45;                //Наклон пушки
  //****************************************************************************

  Detals = 50;                 //Детализация

  Mashtab = 1/100;             //Масштабирование

  //Далее следуют обьявленные выше константы но с учетом масштаба
  MRc = Rc * Mashtab;
  MHeightCZ = HeightCZ * Mashtab;
  ML1 = L1 * Mashtab;
  ML2 = L2 * Mashtab;
  MHeightCon = 0.3;
  MRo = Ro * Mashtab;

  //Размеры частей
  MO1A = O1A * Mashtab;
  MAB = AB * Mashtab;
  MBC = BC * Mashtab;
  MCO = CO * Mashtab;
  MmOD = OD * Mashtab;
  MDE = DE * Mashtab;
  MEF = EF * Mashtab;
  MFO2 = FO2 * Mashtab;
  // КОнец Размеры частей

  MHeightC1 = HeightC1 * Mashtab;

  MHeightG = HeightG * Mashtab;

  //РАзмеры пушки
  MRGun  = RGun * Mashtab;
  MHeightGun = HeightGun * Mashtab;
  //Размер дула
  MRGunMuzzle  = RGunMuzzle * Mashtab;
  MHeightGunMuzzle = HeightGunMuzzle * Mashtab;
  MHGun = HGun * Mashtab;
  MLGun = LGun * Mashtab;
  //****************************************************************************

  //********************************************************************

                              //Перечеслим тип всех размеров 
  ZnachRas: array[0..7] of GLFloat = (MO1A,MAB,MBC,MCO,MmOD,MDE,MEF,MFO2);
                              //Для обрезания полскостью
  Koef: Array[0..3] of GLFloat = (-1.0, -1.0, 0.0, 0.5);

var
  fmMain: TfmMain;
  orientation : (OUTSIDE, INSIDE) = OUTSIDE;
  normals : (NONE, FLAT, SMOOTH) = SMOOTH;
  Down : Boolean;
  wrkX, wrkY: Integer;

var         //МАссив процедур вызывающий нужное рисование
  DrawProcs: array[TShowState] of TDrawProc;

implementation

uses uParams;

{$R *.DFM}
procedure glVertexPointer (size: GLint; atype: GLenum;
          stride: GLsizei; data: pointer); stdcall; external OpenGL32;
procedure glColorPointer (size: GLint; atype: GLenum; stride: GLsizei;
          data: pointer); stdcall; external OpenGL32;
procedure glDrawArrays (mode: GLenum; first: GLint; count: GLsizei);
          stdcall; external OpenGL32;
procedure glEnableClientState (aarray: GLenum); stdcall; external OpenGL32;
procedure glDisableClientState (aarray: GLenum); stdcall; external OpenGL32;

const
 GL_VERTEX_ARRAY                    = $8074;
 GL_COLOR_ARRAY                     = $8076;

{=======================================================================
Вывод текста}
procedure OutText (Litera : PChar; ScaleF: Single);
begin
  glPushMatrix;
    glScalef(ScaleF, ScaleF, ScaleF);
    glListBase(GLF_START_LIST);
    glCallLists(Length (Litera), GL_UNSIGNED_BYTE, Litera);
  glPopMatrix;
end;

procedure TfmMain.DrawInnerCyl;
// Происходи рисования внутренного цилиндра
var
  l1, l2, l3, l4, l5, l6, l7, l8: Double;
begin
  glPushMatrix;                                        //Сохранение матриц
  glPushAttrib(GL_ALL_ATTRIB_BITS);                    //Сохранение всех атрибутов
  glRotatef(180, 0.0,1.0,0.0);
  //Далее идет разбиение по частям внутреннего цилиндра в зависимости от их отображения
  l1 := MO1A - 1.5 * dl;                                 //Цельный
  l2 := 2.5 * dl;                                        //Сетка
  l3 := MAB - 1.5 * dl;                                  //Цельный
  l4 := l2 + dl;                                            //Сетка
  l5 := MO1A + MAB + MBC + MCO - (l1 + 2 * l2 + l3) + (MmOD + MDE - dl) - dl;//Цельный
  l6 := 3 * l2;                                            //Сетка
  l7 := MEF - 7 * dl;                                  //Цельный
  l8 := 4.2 * l2;                                            //Сетка

    SetMaterial(GL_FRONT_AND_BACK, InnerCylMaterial);  //Установка материала
    glTranslatef (0.0, 0.0, -ML1);                     //Сдвиг влево
     //l1  Цельный
     gluQuadricDrawStyle(quadObj, GLU_FILL);
     gluCylinder(quadObj, MRc, MRc, l1, Detals, Detals);
     //l2  Сетка
     gluQuadricDrawStyle(quadObj, GLU_SILHOUETTE);
     glTranslatef (0.0, 0.0, l1);                     //Сдвиг в право
     gluCylinder(quadObj, MRc, MRc, l2, Detals, Detals);
     //l3  Цельный
     gluQuadricDrawStyle(quadObj, GLU_FILL);
     glTranslatef (0.0, 0.0, l2);                     //Сдвиг в право
     gluCylinder(quadObj, MRc, MRc, l3, Detals, Detals);
     //l4  Сетка
//     glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
     gluQuadricDrawStyle(quadObj, GLU_SILHOUETTE);
     glTranslatef (0.0, 0.0, l3);                     //Сдвиг в право
     gluCylinder(quadObj, MRc, MRc, l4, Detals, Detals);
     //l5  Цельный
     gluQuadricDrawStyle(quadObj, GLU_FILL);
     glTranslatef (0.0, 0.0, l4);                     //Сдвиг в право
     gluCylinder(quadObj, MRc, MRc, l5, Detals, Detals);
     //l6  Сетка
     gluQuadricDrawStyle(quadObj, GLU_SILHOUETTE);
     glTranslatef (0.0, 0.0, l5);                     //Сдвиг в право
     gluCylinder(quadObj, MRc, MRc, l6, Detals, Detals);
     //l7  Цельный
     gluQuadricDrawStyle(quadObj, GLU_FILL);
     glTranslatef (0.0, 0.0, l6);                     //Сдвиг в право
     gluCylinder(quadObj, MRc, MRc, l7, Detals, Detals);
     //l8  Сетка
     gluQuadricDrawStyle(quadObj, GLU_SILHOUETTE);
     glTranslatef (0.0, 0.0, l7);                     //Сдвиг в право
     gluCylinder(quadObj, MRc, MRc, l8, Detals, Detals);

  gluQuadricDrawStyle(quadObj, GLU_FILL);
  glPopAttrib;                                         //Загрузка атрибутов
  glPopMatrix;                                         //Загрузка матриц
end;

procedure TfmMain.DrawOuterCyl;
// Происходи рисования внешнего цилиндра
begin
  glPushMatrix;                                        //Сохранение матриц
  glPushAttrib(GL_ALL_ATTRIB_BITS);                    //Сохранение всех атрибутов

    SetMaterial(GL_FRONT_AND_BACK, OuterCylMaterial);  //Установка материала
    glTranslatef (0.0, 0.0, -ML2);                     //Сдвиг влево
    gluCylinder (quadObj, MRc * 2, MRc * 2, MHeightCZ, Detals, Detals);//Сам цилиндр

  glPopAttrib;                                         //Загрузка атрибутов
  glPopMatrix;                                         //Загрузка матриц
end;

procedure TfmMain.DrawConusL;
// Происходи рисования левого конуса
begin
  glPushMatrix;                                        //Сохранение матриц
  glPushAttrib(GL_ALL_ATTRIB_BITS);                    //Сохранение всех атрибутов
  
    SetMaterial(GL_FRONT_AND_BACK, ConusMaterial);      //Установка материала
    glTranslatef (0.0, 0.0, - MHeightCon);              //Сдвиг влево
    gluCylinder (quadObj, MRc - 0.05, 0.0, MHeightCon, Detals div 2, Detals div 2);

  glPopAttrib;                                          //Загрузка атрибутов
  glPopMatrix;                                          //Загрузка матриц
end;

procedure TfmMain.DrawConusR;
// Происходи рисования правого конуса
begin
  glPushMatrix;
  glPushAttrib(GL_ALL_ATTRIB_BITS);

    SetMaterial(GL_FRONT_AND_BACK, ConusMaterial);      //Установка материала
    gluCylinder (quadObj, 0.0, MRc - 0.05, MHeightCon, Detals div 2, Detals div 2);

  glPopAttrib;
  glPopMatrix;
end;

procedure TfmMain.DrawOs;
//Происходит рисование оси
begin
 glPushMatrix;
 glPushAttrib(GL_ALL_ATTRIB_BITS);
  SetMaterial(GL_FRONT_AND_BACK, AxesMaterial);      //Установка материала
  glRotatef(90, 0.0,1.0,0.0);                 //Поворот на 90 градусов во Y
  glTranslatef(0.0,0.0, - 0.005);             //Свиг по Z для обрезания
  glBegin(GL_LINES);
    glVertex2f(-ML1, 0.0);                    //Координата начала
    glVertex2f(ML2, 0.0);                     //Координата конца
  glEnd;
 glPopAttrib;
 glPopMatrix;
end;

procedure TfmMain.DrawGiper;
//ПРоисходит рисование гиперболоида
var
  i, di: Double;
  Count: Integer;                         //Количество элеменов в массиве
begin
 glPushMatrix;
 glPushAttrib(GL_ALL_ATTRIB_BITS);

  SetMaterial(GL_FRONT_AND_BACK, HyperbolMaterial);    //Установка материала
  Count := 0;
  i := MHeightG;                          //Записываем полную длину гиперболоида
  di := i / Detals; //Разбиваем на маленькие участи в зависимосьти от детализации
  glTranslatef (0.0, MRo + 0.013456489658, 0.0);           //ПОдинимаем вверх на Ro
  while Count <= Detals + 1 do
    begin
      if Count = 0 then                   //Первая координата
          i := - (i / 2)                  //Самая левая координата
      else if Count = ((Detals * 0.5) + 1) then  //Вершина
          i := 0;
      aVertexG[Count,0] :=  i;
      aVertexG[Count,1] :=  0.5 * i * i;
      i := i + di;
      Count := Count + 1;
    end;
  glRotatef(90, 0.0,1.0,0.0);
  glVertexPointer(2, GL_FLOAT, 0, @aVertexG);
  glEnableClientState(GL_VERTEX_ARRAY);
  for Count := 1 to 360 do                //Раскручиваем по окружности
    begin
     glDrawArrays(GL_LINES , 0, 52);      //Рисуем из массива
     glTranslatef (0.0, - MRo, 0.0);
     glRotatef(1.0,1.0,0.0,0.0);
     glTranslatef (0.0, MRo, 0.0);
    end;
  glDisableClientState(GL_VERTEX_ARRAY);

 glPopAttrib;
 glPopMatrix;
end;

procedure TfmMain.DrawGun;
begin
  glPushMatrix;                          //Запоминаем матрицы
  glPushAttrib(GL_ALL_ATTRIB_BITS);      //Запоминаем все артибуты

    SetMaterial(GL_FRONT_AND_BACK, GunMaterial);  //Установка материала

    gluQuadricDrawStyle (quadObj, GLU_FILL); //Рисуется полностью закрашенным

             // Z     Y      X
  glTranslatef (0.0, MHGun, ML2 + MLGun);
  glRotatef(- GunAlfa, 1.0,0.0,0.0);
  glPushMatrix;
    glTranslatef (0.0, 0.0, MHeightGun);
    gluDisk(quadObj, 0, MRGun, Detals div 2, Detals div 2);
  glPopMAtrix;
              //Корпус
    gluCylinder(quadObj, MRGun, MRGun, MheightGun, Detals div 2, Detals div 2);
              //Дуло      RGunMuzzle   HeightGunMuzzle
    glTranslatef (0.0, 0.0, -MHeightGunMuzzle);
    gluCylinder(quadObj, MRGunMuzzle, MRGun, MHeightGunMuzzle, Detals div 2, Detals div 2);

  glPopAttrib;                               //Восстанавливаем атрибуты
  glPopMatrix;                               //Восстанавливаем матрицы
end;

procedure TfmMain.DrawObras;
//Рисует образец
begin
  glPushMatrix;                          //Запоминаем матрицы
  glPushAttrib(GL_ALL_ATTRIB_BITS);      //Запоминаем все артибуты

    SetMaterial(GL_FRONT_AND_BACK, ObrasMaterial);  //Установка материала
    glTranslatef (0.0, -0.01, ML2);
    glScalef(1.0,0.5,1.0);
    glutSolidCube(0.1);

  glPopAttrib;                               //Восстанавливаем атрибуты
  glPopMatrix;                               //Восстанавливаем матрицы
end;

procedure TfmMain.DrawDetector;
begin
  glPushMatrix;                          //Запоминаем матрицы
  glPushAttrib(GL_ALL_ATTRIB_BITS);      //Запоминаем все артибуты

    SetMaterial(GL_FRONT_AND_BACK, DetectorMaterial);  //Установка материала
    glTranslatef (0.0, -0.01, -ML1 + 0.04);
    //        Z   Y   X
    glScalef(0.5, 0.1, 0.1);
    glutSolidCube(0.5);

    glTranslatef (0.0, 0.0, - 0.4);
    SetMaterial(GL_FRONT_AND_BACK, DetectorReacMaterial);  //Установка материала
    glutSolidCube(0.5);

    glScalef(1, 1, 3.2);
    glTranslatef (0.0, 0.0, - 0.2);
    SetMaterial(GL_FRONT_AND_BACK, DetectorMaterial);  //Установка материала
    glutSolidCube(0.5);

    glScalef(1, 1, 0.33);
    glTranslatef (0.0, 0.0, - 0.97);
    SetMaterial(GL_FRONT_AND_BACK, DetectorReac2Material);  //Установка материала
    glutSolidCube(0.5);

    glScalef(1, 1, 3);
    glTranslatef (0.0, 0.0, - 0.3);
    SetMaterial(GL_FRONT_AND_BACK, DetectorMaterial);  //Установка материала
    glutSolidCube(0.5);

    glScalef(1, 1, 0.33);
    glTranslatef (0.0, 0.0, - 0.97);
    SetMaterial(GL_FRONT_AND_BACK, DetectorReac3Material);  //Установка материала
    glutSolidCube(0.5);

    glScalef(1, 1, 1.5);
    glTranslatef (0.0, 0.0, - 0.3);
    SetMaterial(GL_FRONT_AND_BACK, DetectorMaterial);  //Установка материала
    glutSolidCube(0.5);

  glPopAttrib;                               //Восстанавливаем атрибуты
  glPopMatrix;                               //Восстанавливаем матрицы
end;

procedure TfmMain.DrawElectrum;
begin
  glPushMatrix;                          //Запоминаем матрицы
  glPushAttrib(GL_ALL_ATTRIB_BITS);      //Запоминаем все артибуты

    SetMaterial(GL_FRONT_AND_BACK, ElectrumMaterial);  //Установка материала

    glRotatef(90, 0.0,1.0,0.0);                        //Поврот на 90 градусов
    gluQuadricDrawStyle (quadObj, GLU_FILL); //Рисуется полностью закрашенным

    glTranslatef (aVertexP[CoordS, 0].Coordin, aVertexP[CoordS, 1].Coordin, 0.0);

    gluSphere (quadObj, 0.02, Detals, Detals);

  glPopAttrib;                               //Восстанавливаем атрибуты
  glPopMatrix;                               //Восстанавливаем матрицы
end;

procedure TfmMain.DrawElectrum2;
begin
  glPushMatrix;                          //Запоминаем матрицы
  glPushAttrib(GL_ALL_ATTRIB_BITS);      //Запоминаем все артибуты

    SetMaterial(GL_FRONT_AND_BACK, ElectrumMaterial2);  //Установка материала

    glRotatef(90, 0.0,1.0,0.0);                        //Поврот на 90 градусов
    gluQuadricDrawStyle (quadObj, GLU_FILL); //Рисуется полностью закрашенным

    glTranslatef (aVertexP2[CoordS2, 0].Coordin, aVertexP2[CoordS2, 1].Coordin, 0.0);

    gluSphere (quadObj, 0.02, Detals, Detals);

  glPopAttrib;                               //Восстанавливаем атрибуты
  glPopMatrix;                               //Восстанавливаем матрицы
end;

procedure TfmMain.DrawElectrum3;
begin
  glPushMatrix;                          //Запоминаем матрицы
  glPushAttrib(GL_ALL_ATTRIB_BITS);      //Запоминаем все артибуты

    SetMaterial(GL_FRONT_AND_BACK, ElectrumMaterial3);  //Установка материала

    glRotatef(90, 0.0,1.0,0.0);                        //Поврот на 90 градусов
    gluQuadricDrawStyle (quadObj, GLU_FILL); //Рисуется полностью закрашенным

    glTranslatef (aVertexP3[CoordS3, 0].Coordin, aVertexP3[CoordS3, 1].Coordin, 0.0);

    gluSphere (quadObj, 0.02, Detals, Detals);

  glPopAttrib;                               //Восстанавливаем атрибуты
  glPopMatrix;                               //Восстанавливаем матрицы
end;

procedure TfmMain.DrawPath;
var
  i: Integer;
begin
  glPushMatrix;                         //Запоминаем матрицы
  glPushAttrib(GL_ALL_ATTRIB_BITS);     //Запоминаем все артибуты

  SetMaterial(GL_FRONT, PathMaterial);  //Установка материала

  glRotatef(90, 0.0,1.0,0.0);           //Поврот на 90 градусов
  glBegin(GL_LINES);
    for i := 1 to CoordS do  //Рисуем до электрона
      begin
        glVertex2f(aVertexP[i - 1, 0].Coordin, aVertexP[i - 1, 1].Coordin);
        glVertex2f(aVertexP[i, 0].Coordin, aVertexP[i, 1].Coordin);
      end;
  glEnd;

  glPopAttrib;                          //Восстанавливаем атрибуты
  glPopMatrix;                          //Восстанавливаем матрицы
end;

procedure TfmMain.DrawPath2;
var
  i: Integer;
begin
  glPushMatrix;                         //Запоминаем матрицы
  glPushAttrib(GL_ALL_ATTRIB_BITS);     //Запоминаем все артибуты

  SetMaterial(GL_FRONT, PathMaterial2);  //Установка материала

  glRotatef(90, 0.0,1.0,0.0);           //Поврот на 90 градусов
  glBegin(GL_LINES);
    for i := 1 to CoordS2 do  //Рисуем до электрона
      begin
        glVertex2f(aVertexP2[i - 1, 0].Coordin, aVertexP2[i - 1, 1].Coordin);
        glVertex2f(aVertexP2[i, 0].Coordin, aVertexP2[i, 1].Coordin);
      end;
  glEnd;

  glPopAttrib;                          //Восстанавливаем атрибуты
  glPopMatrix;                          //Восстанавливаем матрицы
end;

procedure TfmMain.DrawPath3;
var
  i: Integer;
begin
  glPushMatrix;                         //Запоминаем матрицы
  glPushAttrib(GL_ALL_ATTRIB_BITS);     //Запоминаем все артибуты

  SetMaterial(GL_FRONT, PathMaterial3);  //Установка материала

  glRotatef(90, 0.0,1.0,0.0);           //Поврот на 90 градусов
  glBegin(GL_LINES);
    for i := 1 to CoordS3 do  //Рисуем до электрона
      begin
        glVertex2f(aVertexP3[i - 1, 0].Coordin, aVertexP3[i - 1, 1].Coordin);
        glVertex2f(aVertexP3[i, 0].Coordin, aVertexP3[i, 1].Coordin);
      end;
  glEnd;

  glPopAttrib;                          //Восстанавливаем атрибуты
  glPopMatrix;                          //Восстанавливаем матрицы
end;

procedure DrawAxes;
//Происходит рсование осей координат
begin
  glPushMatrix;
  glPushAttrib(GL_ALL_ATTRIB_BITS);

  glScalef (0.75, 0.75, 0.75);

  glColor3f (0, 1, 0);
  SetMaterial(GL_FRONT_AND_BACK, AxesMaterial);  //Установка материала

  glBegin (GL_LINES);                   //Три оси
    glVertex3f (0, 0, 0);
    glVertex3f (3, 0, 0);

    glVertex3f (0, 0, 0);
    glVertex3f (0, 3, 0);

    glVertex3f (0, 0, 0);
    glVertex3f (0, 0, 3);
  glEnd;

  // буква X
  glBegin (GL_LINES);
    glVertex3f (3.1, -0.2, 0.5);
    glVertex3f (3.1, 0.2, 0.1);
    glVertex3f (3.1, -0.2, 0.1);
    glVertex3f (3.1, 0.2, 0.5);
  glEnd;

  // буква Y
  glBegin (GL_LINES);
    glVertex3f (0.0, 3.1, 0.0);
    glVertex3f (0.0, 3.1, -0.1);
    glVertex3f (0.0, 3.1, 0.0);
    glVertex3f (0.1, 3.1, 0.1);
    glVertex3f (0.0, 3.1, 0.0);
    glVertex3f (-0.1, 3.1, 0.1);
  glEnd;

  // буква Z
  glBegin (GL_LINES);
    glVertex3f (0.1, -0.1, 3.1);
    glVertex3f (-0.1, -0.1, 3.1);
    glVertex3f (0.1, 0.1, 3.1);
    glVertex3f (-0.1, 0.1, 3.1);
    glVertex3f (-0.1, -0.1, 3.1);
    glVertex3f (0.1, 0.1, 3.1);
  glEnd;

  glPopAttrib;
  glPopMatrix;
end;


{=======================================================================
Перерисовка окна}
procedure TfmMain.FormPaint(Sender: TObject);
var
  State: TShowState;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);   // очистка буфера цвета

  if Blended then                                       //Вкл прозрачности
    begin
      glEnable(GL_ALPHA_TEST);
      glEnable(GL_BLEND);
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    end
  else
    begin                                               //Выкл прозрачности
      glDisable(GL_BLEND);
      glDisable(GL_ALPHA_TEST);
    end;

  glPolygonMode(GL_FRONT_AND_BACK, PolygonMode);
  gluQuadricDrawStyle(quadObj, QuadricDrawStyle);

  glPushMatrix;

//  DrawAxes;                                      //Рисуются оси координат

  if Clipped then
  //Отрезание плоскостью
    begin
      glEnable(GL_CLIP_PLANE0);
      glClipPlane(GL_CLIP_PLANE0, @Koef);
    end;
 //Проходим все что уже можно ривовать и вызываем соответствующие процедуры
  for State := Low(TShowState) to CurState do
      DrawProcs[State];

  //Выключение отрезания
  if Clipped then glDisable(GL_CLIP_PLANE0);

  glPopMatrix;

 SwapBuffers(DC);   //Вывод всего на экран
end;

{=======================================================================
Формат пикселя}
procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPixelFormatDescriptor;
 nPixelFormat : Integer;
begin
 FillChar (pfd, SizeOf (pfd), 0);
 pfd.dwFlags  := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
 nPixelFormat := ChoosePixelFormat (hdc, @pfd);
 SetPixelFormat (hdc, nPixelFormat, @pfd);
end;

{=======================================================================
Создание формы}
procedure TfmMain.FormCreate(Sender: TObject);
var
  ctg:Double;
begin
  ShowCursor(False);                                  //Убирает курсор

  CountStepPros := 0;                                 //Для прозрачности в таймере
  Pic := True;
  TextDraw := True;

  // Инициализация --
  VAngleX := 15;
  VAngleY := - 10;
  VAngleZ := 0;

  ScaleF := 1.0;

  PolygonMode := GL_FILL; QuadricDrawStyle := GLU_FILL;

  // -- Инициализация

  DC := GetDC (Handle);
  SetDCPixelFormat(DC);
  hrc := wglCreateContext(DC);
  Self.WindowState := wsMaximized;
  wglMakeCurrent(DC, hrc);

  wglUseFontOutlines(Canvas.Handle, 0, 256, GLF_START_LIST, 0.0, 0.15,
    WGL_FONT_POLYGONS, nil);

  glClearColor(58/255, 110/255, 165/255, 1.0);

  glLightfv(GL_LIGHT0, GL_AMBIENT, @Light0Amb);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, @Light0Dif);
  glLightf(GL_LIGHT0, GL_SHININESS, 128.0);
//  glLightfv(GL_LIGHT0, GL_POSITION, @Light0Pos);
  glLightfv(GL_LIGHT1, GL_AMBIENT, @Light0Amb);
  glLightfv(GL_LIGHT1, GL_DIFFUSE, @Light0Dif);
  glLightf(GL_LIGHT1, GL_SHININESS, 128.0);
//  glLightfv(GL_LIGHT1, GL_POSITION, @Light1Pos);

  glEnable (GL_LIGHTING);    //РАзрешение освещенности
  glEnable (GL_LIGHT0);      //Включение лампы 0
  glEnable (GL_LIGHT1);      //Включение лампы 1
  glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, 1);  //Разрешение освещенности двух сторон

  glEnable(GL_DEPTH_TEST);
  glEnable(GL_AUTO_NORMAL);
  glEnable(GL_NORMALIZE);

  glLineWidth (0.01);         //Толщина линий

  quadObj := gluNewQuadric;

  //Забивается массив траектории
  ctg := cos(38 * Pi / 180) / sin(38 * Pi / 180);
  dl := MRc * ctg - MO1A;
  LineGO;
  LineOA;
  LineAB;
  LineBC;
  LineCD;
  LineDE;
  LineEF;
  LineFO;
  //КОнец забивания массива траектории

  GoElectrum := False;   //Для того чтобы электрон сначала стоял на месте

  // Создание дисплейных списков
  DrawProcs[ssNull] := DrawNathing;
  DrawProcs[ssText] := DrawText;
  DrawProcs[ssAxis] := DrawOs;
  DrawProcs[ssObras] := DrawObras;
  DrawProcs[ssDetector] := DrawDetector;
  DrawProcs[ssEl1] := DrawEl1;
  DrawProcs[ssEl2] := DrawEl2;
  DrawProcs[ssEl3] := DrawEl3;
  DrawProcs[ssGunDraw] := DrawGun;    
  DrawProcs[ssConus] := DrawConus;
  DrawProcs[ssHyper] := DrawHyper;
  DrawProcs[ssInnerCyl] := DrawInnerCyl;
  DrawProcs[ssOuterCyl] := DrawOuterCyl;
  DrawProcs[ssGun] := DrawNathing;;
  DrawProcs[ssKamera1] := DrawNathing;;
  DrawProcs[ssStartE1] := DrawNathing;;
  DrawProcs[ssStartE2] := DrawNathing;;
  DrawProcs[ssStartE3] := DrawNathing;;
  DrawProcs[ssStop1] := DrawNathing;;
  DrawProcs[ssTurned1] := DrawNathing;;
  DrawProcs[ssStop2] := DrawNathing;;
  DrawProcs[ssUtih] := DrawUtih;
  DrawProcs[ssClipped] := DrawNathing;;
  DrawProcs[ssStop3] := DrawNathing;;
  DrawProcs[ssShowed] := DrawNathing;;
  DrawProcs[ssStop4] := DrawNathing;;
  DrawProcs[ssStart1EAll] := DrawNathing;;
  DrawProcs[ssStop41] := DrawNathing;;
  DrawProcs[ssTurned2] := DrawNathing;;
  DrawProcs[ssStop5] := DrawNathing;;
  DrawProcs[ssUtih2] := DrawNathing;;
  DrawProcs[ssBlended] := DrawNathing;
  DrawProcs[ssShowed2] := DrawNathing;;
  DrawProcs[ssStop6] := DrawNathing;;
  DrawProcs[ssStart2E1] := DrawNathing;;
  DrawProcs[ssStart2E2] := DrawNathing;;
  DrawProcs[ssStart2E3] := DrawNathing;;
  DrawProcs[ssStop7] := DrawNathing;;
  DrawProcs[ssTurned3] := DrawNathing;;
  DrawProcs[ssStop8] := DrawNathing;;
  DrawProcs[ssUtih3] := DrawNathing;;
  DrawProcs[ssBlendedAndClipped] := DrawNathing;;
  DrawProcs[ssShowed3] := DrawNathing;;
  DrawProcs[ssStop9] := DrawNathing;;
  DrawProcs[ssRotate1] := DrawNathing;;
  DrawProcs[ssStart2EAll] := DrawNathing;;
  DrawProcs[ssStop10] := DrawNathing;;
  DrawProcs[ssRotateNazad] := DrawNathing;;
  DrawProcs[ssStop11] := DrawNathing;;
  DrawProcs[ssVesdNadRotate] := DrawNathing;;
  DrawProcs[ssStop12] := DrawNathing;;
  DrawProcs[ssTurned4] := DrawNathing;;
  DrawProcs[ssUdal] := DrawNathing;;
  DrawProcs[ssStop13] := DrawNathing;;
  DrawProcs[ssUtih4] := DrawNathing;;
  DrawProcs[ssStop14] := DrawNathing;;
  DrawProcs[ssShowed4] := DrawNathing;;
  // ----

  Blended := True;
  Self.Tag := 0;
  Self.CurState := ssNull;
//  TimerID := timeSetEvent (TimerDelay, 0, @TimeProc, 0, TIME_PERIODIC); //Включение таймера
  Timer1.Enabled := Enabled;
end;

{=======================================================================
Конец работы приложения}
procedure TfmMain.FormDestroy(Sender: TObject);
begin
 if TimerID <> 0 then timeKillEvent(TimerID);
 
 gluDeleteQuadric (quadObj);
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 ReleaseDC (Handle, DC);
 DeleteDC (DC);
end;

procedure TfmMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
  VK_ESCAPE: Close;                                             //Закрытие окна
    VK_LEFT: if ssShift in Shift then
      begin
        VAngleZ := VAngleZ - VAngleStep;
        FormResize(Self);
      end
        else
      begin
        VAngleY := VAngleY - VAngleStep;
        FormResize(Self);
      end;
    VK_RIGHT: if ssShift in Shift then
      begin
        VAngleZ := VAngleZ + VAngleStep;
        FormResize(Self);
      end
        else
      begin
        VAngleY := VAngleY + VAngleStep;
        FormResize(Self);
      end;
    VK_UP:
      begin
        VAngleX := VAngleX - VAngleStep;
        FormResize(Self);
      end;
    VK_DOWN:
      begin
        VAngleX := VAngleX + VAngleStep;
        FormResize(Self);
      end;
    VK_ADD:                                      //Нажатие на клавишу Плюс
      begin
        ScaleF := ScaleF + 0.1;
        if ScaleF > 5.4 then
          TextDraw := False;
        FormResize(Self);
      end;
    VK_SUBTRACT	:                                //Нажатие на клавишу МИнус
      begin
        ScaleF := ScaleF - 0.1;
        if ScaleF < 5.4 then
          TextDraw := True;
        FormResize(Self);
      end;
    VK_HOME:                                     //Возвращает в первоначальное положение
      begin
        ScaleF := 1.0;
        VAngleX := 0; VAngleY := 0; VAngleZ := 0;
        FormResize(Self);
      end;
    Ord('C'):                                //Обрезание
      begin
        Clipped := not Clipped; // Вырезание
        InvalidateRect(Handle, nil, False);
      end;
    Ord('B'):                               //Прозрачность
      begin
        Blended := not Blended;
        InvalidateRect(Handle, nil, False);
      end;
    Ord('S'):
      begin
        fmParams.Show;                  //Показывается форма с параметрами
      end;
    Ord('P'):
      begin
        if Timer1.Enabled then
          Timer1.Enabled := False
        else
          begin
            Timer1.Enabled := True;
            InvalidateRect(Handle, nil, False);
          end;
      end;
  end;
end;

procedure TfmMain.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glLoadIdentity;

  glOrtho(-4, 4, -4, 4, -4, 4);

  // Поворот и масштабирование
  glRotatef(VAngleY, 0.0, 1.0, 0.0);
  glRotatef(VAngleX, 1.0, 0.0, 0.0);
  glRotatef(VAngleZ, 0.0, 0.0, 1.0);

  glScalef(ScaleF, ScaleF, ScaleF);

  glRotatef(-90, 0.0, 1.0, 0.0);              //Все поворачивается на 90 градусов

  glLightfv(GL_LIGHT0, GL_POSITION, @Light0Pos); //Установка позиции лампы 0
  glLightfv(GL_LIGHT1, GL_POSITION, @Light1Pos); //Установка позиции лампы 1

  FormPaint(Self);
//  InvalidateRect(Handle, nil, False);
end;


procedure TfmMain.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    begin
      MouseX := X;
      MouseY := Y;
    end;
end;

procedure TfmMain.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 if (ssLeft in Shift) or (ssMiddle in Shift) then
    begin
      VAngleX := VAngleX + Round(0.01 * (Y - MouseY));
      VAngleY := VAngleY + Round(0.01 * (X - MouseX));
      FormResize(Self);
    end;
end;

procedure TfmMain.LineGO;
//ПРоисходит забивание в массив линии от пушки до О
var
  dl, l: Double;
begin
  Count := - 1;
  l := MLGun;                               //Длина до пушки
  dl := 2 * MLGun / Detals;                 //Разбиваем на маленькие участки
  while l > 0 do
    begin
      Count := Count + 1;                   //Делаем следующий шаг
                        //Первая прямая
      aVertexP[Count,0].Coordin := - l - MO1A - MAB - MBC - MCO;
      aVertexP[Count,1].Coordin := 1.4 * l;
                        //Первая прямая
      aVertexP2[Count,0].Coordin := - l - MO1A - MAB - MBC - MCO;
      aVertexP2[Count,1].Coordin := 1.4 * l;
                        //Первая прямая
      aVertexP3[Count,0].Coordin := - l - MO1A - MAB - MBC - MCO;
      aVertexP3[Count,1].Coordin := 1.4 * l;

      l := l - dl;                          //Уменьшаем длину
    end;
end;

procedure TfmMain.LineOA;
//ПРоисходит забивание в массив линии ОА
var
  dl, l: Double;
begin
  l := 0;                                       //Переменная длина равна 0
  dl := 2 * MO1A / Detals;                      //Разбиваем на маленькие участки
  while l <= MO1A do
    begin
      Count := Count + 1;                       //Делаем следующий шаг
                        //Первая прямая
      aVertexP[Count,0].Coordin :=  l - MO1A - MAB - MBC - MCO;
      aVertexP[Count,1].Coordin := 0.835 * l;
                        //Первая прямая
      aVertexP2[Count,0].Coordin :=  l - MO1A - MAB - MBC - MCO;
      aVertexP2[Count,1].Coordin := 0.835 * l;
                        //Первая прямая
      aVertexP3[Count,0].Coordin :=  l - MO1A - MAB - MBC - MCO;
      aVertexP3[Count,1].Coordin := 0.835 * l;
      l := l + dl;                              //Увеличиваем длину
    end;
end;

procedure TfmMain.LineAB;
//ПРоисходит забивание в массив линии АВ (парабола)
var
  i, di, dh, dl, i2, di2, dh2, dl2, i3, di3, dh3, dl3 : Double;//Для трех путей
  PredCount: Integer;
begin
  PredCount := Count;
  dl := 0.026456489658;                      //Маленький участок сетчетых частей
  i := MCO + MBC + MAB;                      //Полная длина
  i2 := i;                                   //Полная длина
  i3 := i;                                   //Полная длина
  di := (i - (MCO + MBC + MAB / 2)) / (Detals * 0.5);// маленькие участки
  di2 := di;                                         // маленькие участки
  di3 := di + 0.001;                                         // маленькие участки
  while Count <= PredCount + Detals + 1 do
    begin
      if Count = PredCount then
        begin
          i := - (MAB / 2);                //самая левая точка
          i2 := - ((MAB + dl) / 2);        //самая левая точка
          i3 := - ((MAB + 2 * dl) / 2);    //самая левая точка
          dh := MRc - (i * i);             //максимальная высота подъема
          dh2 := MRc - (i2 * i2);          //максимальная высота подъема
          dh3 := MRc - (i3 * i3);          //максимальная высота подъема
          dl := (MCO + MBC + MAB) + i;     //Сдвиг по Х
          dl2 := (MCO + MBC + MAB) + i2;   //Сдвиг по Х
          dl3 := (MCO + MBC + MAB) + i3;   //Сдвиг по Х
        end
      else if Count = ((Detals * 0.5) + 1 + PredCount) then
        begin
          i := 0;                          //Когда прошли середину
          i2 := 0;                         //Когда прошли середину
          i3 := 0;                         //Когда прошли середину
        end;
      Count := Count + 1;                  //Делаем следующий шаг
                     //Первая траектори
      aVertexP[Count,0].Coordin :=  i - dl;
      aVertexP[Count,1].Coordin := - 1.2 * i * i + MRc + 2.05 * dh;
                     //Вторая траектори
      aVertexP2[Count,0].Coordin :=  i2 - dl2;
      aVertexP2[Count,1].Coordin := - i2 * i2 + MRc + 2 * dh2;
                     //Третия траектори
      aVertexP3[Count,0].Coordin :=  i3 - dl3;
      aVertexP3[Count,1].Coordin := - 0.8 * i3 * i3 + MRc + 2 * dh3;

      i := i + di;                       //Увеличиваем длину
      i2 := i2 + di2;                    //Увеличиваем длину
      i3 := i3 + di3;                    //Увеличиваем длину
    end;
end;

procedure TfmMain.LineBC;
//ПРоисходит забивание в массив линии ВС
var
  di, dl, l, z1, dl2, l2, z12, dl3, l3, z13: Double;
begin
 di := 0.026456489658;                      //Маленький участок сетчетых частей
 dl := 20 * MBC / Detals;                       //Разбиваем на маленькие участки
 dl2 := dl;
 dl3 := dl;
 l := MBC;                                      //Полная длина
 l2 := l;
 l3 := l;
 Z1 := 0.3;   //Надо для нахождения r1 (координату входа в гиперболическое зеркало)
 z12 := z1 - di;
 z13 := z1 - 2 * di;
 r1 := sqrt((2 * Z1 * Z1) + (u * u)); //подъем над осью
 r12 := sqrt((2 * Z12 * Z13) + (u * u)); //подъем над осью
 r13 := sqrt((2 * Z13 * Z13) + (u * u)); //подъем над осью
  while l >= 0 do
    begin
      Inc(Count);                    //Делаем следующий шаг

      aVertexP[Count,0].Coordin := - (l + MCO + 0.0015);
      aVertexP[Count,1].Coordin := 0.8 * l + r1 * MRc;

      aVertexP2[Count,0].Coordin := - (l2  + MCO - di - 0.004);
      aVertexP2[Count,1].Coordin := 0.8 * l2 + r12 * MRc;

      aVertexP3[Count,0].Coordin := - (l3  + MCO - 2 * di - 0.01);
      aVertexP3[Count,1].Coordin := 0.8 * l3 + r13 * MRc;

      l := l - dl;                   //Уменьшаем длину
      l2 := l2 - dl2;                   //Уменьшаем длину
      l3 := l3 - dl3;                   //Уменьшаем длину
    end;
end;

procedure TfmMain.LineCD;
//ПРоисходит забивание в массив линии CD
var
  i, di, dH, i2, di2, dH2, i3, di3, dH3: Double;
  PredCount: Integer;
begin
  dl := 0.026456489658;
  PredCount := Count;
  i := MCO + MmOD;
  i2 := i + dl;
  i3 := i + 2 * dl;                              //Полная длина
  di := i / (Detals * 0.3);                     //Разбиваем на маленькие участки
  di2 := di + 0.002;
  di3 := di + 0.006;
  while Count < (Detals * 0.3) + PredCount  do
    begin
      if Count = PredCount then
        begin
          i := - (i / 2);                 //Самая левая точка прямой
          i2 := - (i2 / 2);
          i3 := - (i3 / 2);
          dH := i * i * 6;                //Максимальная высота подъема
          dH2 := i2 * i2 * 6;
          dH3 := i3 * i3 * 6;
        end
      else if Count = ((Detals * 0.3) +  PredCount) then
        begin
          i := 0;
          i2 := 0;
          i3 := 0;
        end;
      Inc(Count);                         //Делаем следующий шаг

      aVertexP[Count,0].Coordin :=  i + 0.007;
      aVertexP[Count,1].Coordin :=  6 * i * i + r1 * MRc - dH;

      aVertexP2[Count,0].Coordin :=  i2 + 0.62 * dH2;
      aVertexP2[Count,1].Coordin :=  4 * i2 * i2 + r12 * MRc - 0.6 * dH2;

      aVertexP3[Count,0].Coordin :=  i3 + dh3;
      aVertexP3[Count,1].Coordin :=  2.5 * i3 * i3 + r13 * MRc - 0.39 * dH3;

      i := i + di;                           //Увеличиваем длину
      i2 := i2 + di2;                        //Увеличиваем длину
      i3 := i3 + di3;                        //Увеличиваем длину
    end;
end;


procedure TfmMain.LineDE;
//ПРоисходит забивание в массив линии DE
var
  di, z2, r2, dl, l, z22, r22, dl2, l2, z23, r23, dl3, l3: Double;
begin
  di := 0.026456489658;
  dl := 40 * MDE / Detals;                      //Разбиваем на маленькие участки
  dl2 := dl + 0.008;
  dl3 := dl;
  l := 0;
  l2 := 0;
  l3 := 0;                                      //Переменная длина равна нулю
  Z2 := 0.3497;   //Нужно для нахождения r2(подъем над осью для координаты
  Z22 := 0.3497 + di;   //Нужно для нахождения r2(подъем над осью для координаты
  Z23 := 0.3497 + 2 * di;   //Нужно для нахождения r2(подъем над осью для координаты
  r2 := sqrt((2 * Z2 * Z2) + (u * u));  //выхода в гиперболическое зеркало
  r22 := sqrt((2 * Z22 * Z22) + (u * u));  //выхода в гиперболическое зеркало
  r23 := sqrt((2 * Z23 * Z23) + (u * u));  //выхода в гиперболическое зеркало
  while l <= MDE do
    begin
      Inc(Count);                       //Делаем следующый шаг

      aVertexP[Count,0].Coordin := l + MmOD;
      aVertexP[Count,1].Coordin := 1.62 * l + r2 * MRc - 0.008;

      aVertexP2[Count,0].Coordin := 2 * l2 + MmOD + 2 * di;
      aVertexP2[Count,1].Coordin := 1.62 * l2 + r22 * MRc - 0.02;

      aVertexP3[Count,0].Coordin := 2 * l3 + MmOD + 4.9 * di;
      aVertexP3[Count,1].Coordin := 1.62 * l3 + r23 * MRc - 0.018;

      l := l + dl;
      l2 := l2 + dl2;
      l3 := l3 + dl3;                      //Увеличиваем длину
    end;
end;

procedure TfmMain.LineEF;
//ПРоисходит забивание в массив линии EF
var
  i, di, dH, i2, di2, dH2, i3, di3, dH3: Double;
  PredCount: Integer;
begin
  dl := 0.026456489658;
  PredCount := Count;
  i := MmOD + MDE + MEF;
  i2 := i;
  i3 := i;
  di := (i - (MmOD + MDE + MEF / 2)) / (Detals * 0.5);       //маленькие участки
  di2 := di;
  di3 := di;
  while Count <= Detals + 1 + PredCount do
    begin
      if Count = PredCount then
        begin
          i := - (MEF / 2);                           //Самая левая точка кривой
          i2 := - (MEF / 2);
          i3 := - (MEF / 2);
          dH := i * i;                  //определяем максимальную высоту подьема
          dH2 := i2 * i2;
          dH3 := i3 * i3;
        end
      else if Count = ((Detals * 0.5) + 1 + PredCount) then
        begin
          i := 0;//Когда пройдена половина, то показываем что это половина, начинаем с нуля
          i2 := 0;
          i3 := 0;
        end;
                        //Координаты забиваются в массив
      aVertexP[Count,0].Coordin :=  i + MmOD + MDE + MEF / 2;
      aVertexP[Count,1].Coordin := - 0.9 * i * i + MRc + dH - dl;

      aVertexP2[Count,0].Coordin :=  1.005 * i2 + MmOD + MDE + MEF / 2 + 3.8 * dl;
      aVertexP2[Count,1].Coordin := - 0.7 * i2 * i2 + MRc + dH2 - 2.5 * dl;

      aVertexP3[Count,0].Coordin :=  1.1 * i3 + MmOD + MDE + MEF / 2 + 7 * dl;
      aVertexP3[Count,1].Coordin := - 0.5 * i3 * i3 + MRc + dH3 - 4.8 * dl;

      i := i + di;                                        //Увеличиваем длину
      i2 := i2 + di2;
      i3 := i3 + di3;

      Count := Count + 1;                                 //Делаем следующий шаг
    end;
end;

procedure TfmMain.LineFO;
//ПРоисходит забивание в массив линии FO
var
  di, dl, l, dl2, l2, dl3, l3: Double;
begin
  di := 0.026456489658;
  dl := 2 * MFO2 / Detals;                      //Разбиваем на маленькие участки
  dl2 := dl;
  dl3 := dl;
  l := MFO2;      //Переменной длины присваевается полная длина, которая будет уменьшаться
  l2 := l;
  l3 := l;
  while l > 0  do                               //Работает до конца длины
  begin                                         //Записываем координаты в массив
    aVertexP[Count,0].Coordin := - l  + MmOD + MDE + MEF + MFO2;
    aVertexP[Count,1].Coordin := 1.13 * l;

    aVertexP2[Count,0].Coordin := - 1.2 * l2  + MmOD + MDE + MEF + MFO2 + 6.5 * di;
    aVertexP2[Count,1].Coordin := 1.13 * l2;

    aVertexP3[Count,0].Coordin := - 1.5 * l3 + MmOD + MDE + MEF + MFO2 + 13.6 * di;
    aVertexP3[Count,1].Coordin := 1.13 * l3;
    
    Inc(Count);                                 //Делаем следующий шаг
    l := l - dl;                                //Уменьшаем длину
    l2 := l2 - dl2;
    l3 := l3 - dl3;
  end;
end;

procedure TfmMain.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  ScaleF := ScaleF - 0.1;        //Удаление колесиком
  FormResize(Self);              //Вызов перерисовки
end;

procedure TfmMain.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  ScaleF := ScaleF + 0.1;       //Приближение колесиком
  FormResize(Self);             //Вызов перерисовки
end;

procedure TfmMain.DrawAxis;
//Рисуется ось
begin
  DrawAxes;
end;

procedure TfmMain.DrawConus;
//Конические электроды
begin
  DrawConusL;
  DrawConusR;
end;

procedure TfmMain.DrawHyper;
//Рисуется гиперболоид
begin
  DrawGiper;
end;

procedure TfmMain.DrawEl1;
//Для первого электрона траектория и сам электрон
begin
  DrawPath;
  DrawElectrum;
end;

procedure TfmMain.DrawEl2;
//Для второго электрона траектория и сам электрон
begin
  DrawPath2;
  DrawElectrum2;
end;

procedure TfmMain.DrawEl3;
//Для третьего электрона траектория и сам электрон
begin
  DrawPath3;
  DrawElectrum3;
end;

procedure TfmMain.Timer1Timer(Sender: TObject);
begin
  case CurState of                        //что должно происходить
  ssNull:                                 //пустой экран
    begin
      Tag := Tag + TimerDelay;            //сколько прошло вермени
      if Tag >= NullDelay then            //сколько нужно чтобы перейти на след
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
    end;
  ssText:
    begin
      Tag := 0;                       //обнуляем сколько прошло
      CurState := Succ(CurState);     //выбираем следующюю прорисовку
    end;
  ssAxis:                                 //будут оси координат
    begin
      AxesMaterial.Diffuse[3] := AxesMaterial.Diffuse[3] + BlendStep;
      if AxesMaterial.Diffuse[3] >= 0.8 then
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssObras:
    begin
      ObrasMaterial.Diffuse[3] := ObrasMaterial.Diffuse[3] + BlendStep;
      if ObrasMaterial.Diffuse[3] >= 0.8 then
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssDetector:
    begin
      DetectorMaterial.Diffuse[3] := DetectorMaterial.Diffuse[3] + BlendStep;
      DetectorReacMaterial.Diffuse[3] := DetectorReacMaterial.Diffuse[3] + BlendStep;
      DetectorReac2Material.Diffuse[3] := DetectorReac2Material.Diffuse[3] + BlendStep;
      DetectorReac3Material.Diffuse[3] := DetectorReac3Material.Diffuse[3] + BlendStep;
      if DetectorMaterial.Diffuse[3] >= 0.8 then
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
          DetectorMaterial.Diffuse[3] := 1;
          {DetectorReacMaterial.Diffuse[3] := 1;
          DetectorReac2Material.Diffuse[3] := 1;
          DetectorReac3Material.Diffuse[3] := 1}
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssEl1:                                  //будет первая трпектория и электрон
    begin
      CoordS := 0;
      CurState := Succ(CurState);         //выбираем следующюю прорисовку
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssEl2:                                  //будет вторая трпектория и электрон
    begin
      CoordS2 := 0;
      CurState := Succ(CurState);         //выбираем следующюю прорисовку
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssEl3:                                  //будет третия трпектория и электрон
    begin
      CoordS3 := 0;
      CurState := Succ(CurState);         //выбираем следующюю прорисовку
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssGunDraw:
    begin
      Tag := 0;                       //обнуляем сколько прошло
      CurState := Succ(CurState);     //выбираем следующюю прорисовку
    end;
  ssConus:                                //будут конусы
    begin     //КОнец рисования определятся степенью прозрачности
      ConusMaterial.Diffuse[3] := ConusMaterial.Diffuse[3] + BlendStep;
      if ConusMaterial.Diffuse[3] >= 0.6 then
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssHyper:                                //будет гиперболоид
    begin
      HyperbolMaterial.Diffuse[3] := HyperbolMaterial.Diffuse[3] + BlendStep;
      if HyperbolMaterial.Diffuse[3] >= 0.6 then
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssInnerCyl:                             //будет внутренний цилиндр
    begin
      InnerCylMaterial.Diffuse[3] := InnerCylMaterial.Diffuse[3] + BlendStep;
      if InnerCylMaterial.Diffuse[3] >= 0.5 then
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssOuterCyl:                             //будет внешний цилиндр
    begin
      OuterCylMaterial.Diffuse[3] := OuterCylMaterial.Diffuse[3] + BlendStep;
      if OuterCylMaterial.Diffuse[3] >= 0.1 then
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssGun:
    begin
      GunMaterial.Diffuse[3] := GunMaterial.Diffuse[3] + BlendStep;
      if GunMaterial.Diffuse[3] >= 0.8 then
        begin
          Tag := 0;
          CurState := Succ(CurState);
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssKamera1:
    begin   //  ScaleF       VAngleY   VAngleStep    StopRotate
      if ScaleF < StopNaesd then
        ScaleF := ScaleF + 0.02;
      if VAngleY >= StopRotate then
        VAngleY := VAngleY - 1;
      if (ScaleF >= StopNaesd) and (VAngleY <= StopRotate) then
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      FormResize(fmMain);
    end;
  ssStartE1:
    begin
      ElectrumMaterial.Diffuse[3] := 0.5;
      CoordS := CoordS + 1;               //Делаем следующий шаг по траектории
      if CoordS = Count - 1 then
        begin
          DetectorReacMaterial.Emission[0] := 1;
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssStartE2:
    begin
      ElectrumMaterial2.Diffuse[3] := 0.5;
      CoordS2 := CoordS2 + 1;               //Делаем следующий шаг по траектории
      if CoordS2 = Count - 1 then
        begin
          DetectorReac2Material.Emission[0] := 1;
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssStartE3:
    begin
      ElectrumMaterial3.Diffuse[3] := 0.5;
      CoordS3 := CoordS3 + 1;               //Делаем следующий шаг по траектории
      if CoordS3 = Count - 1 then
        begin
          DetectorReac3Material.Emission[0] := 1;
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssStop1:
    begin
      Tag := Tag + TimerDelay;            //сколько прошло вермени
      if Tag >= NullDelay then            //сколько нужно чтобы перейти на след
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
    end;
  ssTurned1:
    begin
      VAngleY := VAngleY - 1;
      if VAngleY <= StopRotate - 360 then
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
          VAngleY := -16;
        end;
      FormResize(fmMain);
    end;
  ssStop2:
    begin
      Tag := Tag + TimerDelay;            //сколько прошло вермени
      if Tag >= NullDelay then            //сколько нужно чтобы перейти на след
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
          StepProsProc;
        end;
    end;
  ssUtih:
    begin
      Inc(CountStepPros);
      if CountStepPros < CountProcvet + 1 then
      begin
        AxesMaterial.Diffuse[3] := AxesMaterial.Diffuse[3] - StepPros[1];
        ObrasMaterial.Diffuse[3] := ObrasMaterial.Diffuse[3] - StepPros[2];
        DetectorMaterial.Diffuse[3] := DetectorMaterial.Diffuse[3] - StepPros[3];
        ConusMaterial.Diffuse[3] := ConusMaterial.Diffuse[3] - StepPros[4];
        HyperbolMaterial.Diffuse[3] := HyperbolMaterial.Diffuse[3] - StepPros[5];
        InnerCylMaterial.Diffuse[3] := InnerCylMaterial.Diffuse[3] - StepPros[6];
        OuterCylMaterial.Diffuse[3] := OuterCylMaterial.Diffuse[3] - StepPros[7];
        ElectrumMaterial.Diffuse[3] := ElectrumMaterial.Diffuse[3] - StepPros[8];
        ElectrumMaterial2.Diffuse[3] := ElectrumMaterial2.Diffuse[3] - StepPros[9];
        ElectrumMaterial3.Diffuse[3] := ElectrumMaterial3.Diffuse[3] - StepPros[10];
        PathMaterial.Diffuse[3] :=  PathMaterial.Diffuse[3] - StepPros[11];
        PathMaterial2.Diffuse[3] :=  PathMaterial2.Diffuse[3] - StepPros[12];
        PathMaterial3.Diffuse[3] :=  PathMaterial3.Diffuse[3] - StepPros[13];
        TextMaterial.Diffuse[3] := TextMaterial.Diffuse[3] - StepPros[14];
        GunMaterial.Diffuse[3] := GunMaterial.Diffuse[3] - StepPros[15];
        DetectorReacMaterial.Diffuse[3] := DetectorReacMaterial.Diffuse[3] - StepPros[16];
       DetectorReac2Material.Diffuse[3] := DetectorReac2Material.Diffuse[3] - StepPros[17];
       DetectorReac3Material.Diffuse[3] := DetectorReac3Material.Diffuse[3] - StepPros[18];
      end
      else
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssClipped:
    begin
      CurState := Succ(CurState);     //выбираем следующюю прорисовку
      CoordS := 0;
      CoordS2 := 0;
      CoordS3 := 0;
      DetectorReacMaterial.Emission[0] := 0;
      DetectorReac2Material.Emission[0] := 0;
      DetectorReac3Material.Emission[0] := 0;
      Clipped := not Clipped;
    end;
  ssStop3:
    begin
      Tag := Tag + TimerDelay;            //сколько прошло вермени
      if Tag >= NullDelay then            //сколько нужно чтобы перейти на след
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
          CountStepPros := 0;
        end;
    end;
  ssShowed:
    begin
      Inc(CountStepPros);
      if CountStepPros < CountProcvet + 1 then
      begin
        AxesMaterial.Diffuse[3] := AxesMaterial.Diffuse[3] + StepPros[1];
        ObrasMaterial.Diffuse[3] := ObrasMaterial.Diffuse[3] + StepPros[2];
        DetectorMaterial.Diffuse[3] := DetectorMaterial.Diffuse[3] + StepPros[3];
        ConusMaterial.Diffuse[3] := ConusMaterial.Diffuse[3] + StepPros[4];
        HyperbolMaterial.Diffuse[3] := HyperbolMaterial.Diffuse[3] + StepPros[5];
        InnerCylMaterial.Diffuse[3] := InnerCylMaterial.Diffuse[3] + StepPros[6];
        OuterCylMaterial.Diffuse[3] := OuterCylMaterial.Diffuse[3] + StepPros[7];
        ElectrumMaterial.Diffuse[3] := ElectrumMaterial.Diffuse[3] + StepPros[8];
        ElectrumMaterial2.Diffuse[3] := ElectrumMaterial2.Diffuse[3] + StepPros[9];
        ElectrumMaterial3.Diffuse[3] := ElectrumMaterial3.Diffuse[3] + StepPros[10];
        PathMaterial.Diffuse[3] :=  PathMaterial.Diffuse[3] + StepPros[11];
        PathMaterial2.Diffuse[3] :=  PathMaterial2.Diffuse[3] + StepPros[12];
        PathMaterial3.Diffuse[3] :=  PathMaterial3.Diffuse[3] + StepPros[13];
        TextMaterial.Diffuse[3] := TextMaterial.Diffuse[3] + StepPros[14];
        GunMaterial.Diffuse[3] := GunMaterial.Diffuse[3] + StepPros[15];
        DetectorReacMaterial.Diffuse[3] := DetectorReacMaterial.Diffuse[3] + StepPros[16];
       DetectorReac2Material.Diffuse[3] := DetectorReac2Material.Diffuse[3] + StepPros[17];
       DetectorReac3Material.Diffuse[3] := DetectorReac3Material.Diffuse[3] + StepPros[18];
      end
      else
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssStop4:
    begin
      Tag := Tag + TimerDelay;            //сколько прошло вермени
      if Tag >= NullDelay then            //сколько нужно чтобы перейти на след
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
    end;
  ssStart1EAll:
    begin
      Inc(CoordS);
      Inc(CoordS2);
      Inc(CoordS3);
      if CoordS = Count - 1 then
        begin
           DetectorReacMaterial.Emission[0] := 1;
           DetectorReac2Material.Emission[0] := 1;
           DetectorReac3Material.Emission[0] := 1;
           Tag := 0;                       //обнуляем сколько прошло
           CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssStop41:
    begin
      Tag := Tag + TimerDelay;            //сколько прошло вермени
      if Tag >= NullDelay then            //сколько нужно чтобы перейти на след
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
    end;
  ssTurned2:
    begin
      VAngleY := VAngleY + 1;
      if VAngleY >= StopRotate + 360 + 41 then
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      FormResize(fmMain);
    end;
  ssStop5:
    begin
      Tag := Tag + TimerDelay;            //сколько прошло вермени
      if Tag >= NullDelay then            //сколько нужно чтобы перейти на след
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
          CountStepPros := 0;
        end;
    end;
  ssUtih2:
    begin
      Inc(CountStepPros);
      if CountStepPros < CountProcvet + 1 then
      begin
        AxesMaterial.Diffuse[3] := AxesMaterial.Diffuse[3] - StepPros[1];
        ObrasMaterial.Diffuse[3] := ObrasMaterial.Diffuse[3] - StepPros[2];
        DetectorMaterial.Diffuse[3] := DetectorMaterial.Diffuse[3] - StepPros[3];
        ConusMaterial.Diffuse[3] := ConusMaterial.Diffuse[3] - StepPros[4];
        HyperbolMaterial.Diffuse[3] := HyperbolMaterial.Diffuse[3] - StepPros[5];
        InnerCylMaterial.Diffuse[3] := InnerCylMaterial.Diffuse[3] - StepPros[6];
        OuterCylMaterial.Diffuse[3] := OuterCylMaterial.Diffuse[3] - StepPros[7];
        ElectrumMaterial.Diffuse[3] := ElectrumMaterial.Diffuse[3] - StepPros[8];
        ElectrumMaterial2.Diffuse[3] := ElectrumMaterial2.Diffuse[3] - StepPros[9];
        ElectrumMaterial3.Diffuse[3] := ElectrumMaterial3.Diffuse[3] - StepPros[10];
        PathMaterial.Diffuse[3] :=  PathMaterial.Diffuse[3] - StepPros[11];
        PathMaterial2.Diffuse[3] :=  PathMaterial2.Diffuse[3] - StepPros[12];
        PathMaterial3.Diffuse[3] :=  PathMaterial3.Diffuse[3] - StepPros[13];
        TextMaterial.Diffuse[3] := TextMaterial.Diffuse[3] - StepPros[14];
        GunMaterial.Diffuse[3] := GunMaterial.Diffuse[3] - StepPros[15];
        DetectorReacMaterial.Diffuse[3] := DetectorReacMaterial.Diffuse[3] - StepPros[16];
       DetectorReac2Material.Diffuse[3] := DetectorReac2Material.Diffuse[3] - StepPros[17];
       DetectorReac3Material.Diffuse[3] := DetectorReac3Material.Diffuse[3] - StepPros[18];
      end
      else
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssBlended:
    begin
      Tag := Tag + TimerDelay;            //сколько прошло вермени
      if Tag >= NullDelay then            //сколько нужно чтобы перейти на след
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
          CountStepPros := 0;
          CoordS := 0;
          CoordS2 := 0;
          CoordS3 := 0;
          DetectorReacMaterial.Emission[0] := 0;
          DetectorReac2Material.Emission[0] := 0;
          DetectorReac3Material.Emission[0] := 0;
        end;
    end;
  ssShowed2:
    begin
      Inc(CountStepPros);
      if CountStepPros < (CountProcvet + 1) then
      begin
        AxesMaterial.Diffuse[3] := AxesMaterial.Diffuse[3] + Alfa;
        ObrasMaterial.Diffuse[3] := ObrasMaterial.Diffuse[3] + Alfa;
        DetectorMaterial.Diffuse[3] := DetectorMaterial.Diffuse[3] + Alfa;
        ConusMaterial.Diffuse[3] := ConusMaterial.Diffuse[3] + Alfa;
        HyperbolMaterial.Diffuse[3] := HyperbolMaterial.Diffuse[3] + Alfa;
        InnerCylMaterial.Diffuse[3] := InnerCylMaterial.Diffuse[3] + Alfa;
        OuterCylMaterial.Diffuse[3] := OuterCylMaterial.Diffuse[3] + Alfa;
        ElectrumMaterial.Diffuse[3] := ElectrumMaterial.Diffuse[3] + Alfa;
        ElectrumMaterial2.Diffuse[3] := ElectrumMaterial2.Diffuse[3] + Alfa;
        ElectrumMaterial3.Diffuse[3] := ElectrumMaterial3.Diffuse[3] + Alfa;
        PathMaterial.Diffuse[3] :=  PathMaterial.Diffuse[3] + Alfa;
        PathMaterial2.Diffuse[3] :=  PathMaterial2.Diffuse[3] + Alfa;
        PathMaterial3.Diffuse[3] :=  PathMaterial3.Diffuse[3] + Alfa;
        TextMaterial.Diffuse[3] := TextMaterial.Diffuse[3] + Alfa;
        GunMaterial.Diffuse[3] := GunMaterial.Diffuse[3] + Alfa;
        DetectorReacMaterial.Diffuse[3] := DetectorReacMaterial.Diffuse[3] + Alfa;
        DetectorReac2Material.Diffuse[3] := DetectorReac2Material.Diffuse[3] + Alfa;
        DetectorReac3Material.Diffuse[3] := DetectorReac3Material.Diffuse[3] + Alfa;
      end
      else
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssStop6:
    begin
      Tag := Tag + TimerDelay;            //сколько прошло вермени
      if Tag >= NullDelay then            //сколько нужно чтобы перейти на след
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
    end;
  ssStart2E1:
    begin
      Inc(CoordS);
      if CoordS = Count - 1 then
        begin
           Tag := 0;                       //обнуляем сколько прошло
           CurState := Succ(CurState);     //выбираем следующюю прорисовку
           DetectorReacMaterial.Emission[0] := 1;
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssStart2E2:
    begin
      Inc(CoordS2);
      if CoordS2 = Count - 1 then
        begin
           Tag := 0;                       //обнуляем сколько прошло
           CurState := Succ(CurState);     //выбираем следующюю прорисовку
           DetectorReac2Material.Emission[0] := 1;
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssStart2E3:
    begin
      Inc(CoordS3);
      if CoordS3 = Count - 1 then
        begin
           Tag := 0;                       //обнуляем сколько прошло
           CurState := Succ(CurState);     //выбираем следующюю прорисовку
           DetectorReac3Material.Emission[0] := 1;
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssStop7:
    begin
      Tag := Tag + TimerDelay;            //сколько прошло вермени
      if Tag >= NullDelay then            //сколько нужно чтобы перейти на след
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
    end;
  ssTurned3:
    begin
      VAngleY := VAngleY - 1;
      if VAngleY <= StopRotate then
        begin
          Tag := 0;
          VAngleY := StopRotate;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      FormResize(fmMain);
    end;
  ssStop8:
    begin
      Tag := Tag + TimerDelay;            //сколько прошло вермени
      if Tag >= NullDelay then            //сколько нужно чтобы перейти на след
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CountStepPros := 0;
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
    end;
  ssUtih3:
    begin
      Inc(CountStepPros);
      if CountStepPros < (CountProcvet + 1) then
      begin
        AxesMaterial.Diffuse[3] := AxesMaterial.Diffuse[3] - Alfa;
        ObrasMaterial.Diffuse[3] := ObrasMaterial.Diffuse[3] - Alfa;
        DetectorMaterial.Diffuse[3] := DetectorMaterial.Diffuse[3] - Alfa;
        ConusMaterial.Diffuse[3] := ConusMaterial.Diffuse[3] - Alfa;
        HyperbolMaterial.Diffuse[3] := HyperbolMaterial.Diffuse[3] - Alfa;
        InnerCylMaterial.Diffuse[3] := InnerCylMaterial.Diffuse[3] - Alfa;
        OuterCylMaterial.Diffuse[3] := OuterCylMaterial.Diffuse[3] - Alfa;
        ElectrumMaterial.Diffuse[3] := ElectrumMaterial.Diffuse[3] - Alfa;
        ElectrumMaterial2.Diffuse[3] := ElectrumMaterial2.Diffuse[3] - Alfa;
        ElectrumMaterial3.Diffuse[3] := ElectrumMaterial3.Diffuse[3] - Alfa;
        PathMaterial.Diffuse[3] :=  PathMaterial.Diffuse[3] - Alfa;
        PathMaterial2.Diffuse[3] :=  PathMaterial2.Diffuse[3] - Alfa;
        PathMaterial3.Diffuse[3] :=  PathMaterial3.Diffuse[3] - Alfa;
        TextMaterial.Diffuse[3] := TextMaterial.Diffuse[3] - Alfa;
        GunMaterial.Diffuse[3] := GunMaterial.Diffuse[3] - Alfa;
        DetectorReacMaterial.Diffuse[3] := DetectorReacMaterial.Diffuse[3] - Alfa;
       DetectorReac2Material.Diffuse[3] := DetectorReac2Material.Diffuse[3] - Alfa;
       DetectorReac3Material.Diffuse[3] := DetectorReac3Material.Diffuse[3] - Alfa;
      end
      else
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssBlendedAndClipped:
    begin
      Tag := Tag + TimerDelay;            //сколько прошло вермени
      if Tag >= NullDelay then            //сколько нужно чтобы перейти на след
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
          CountStepPros := 0;
          CoordS := 0;
          CoordS2 := 0;
          CoordS3 := 0;
          DetectorReacMaterial.Emission[0] := 0;
          DetectorReac2Material.Emission[0] := 0;
          DetectorReac3Material.Emission[0] := 0;
          Clipped := not Clipped;
        end;
    end;
  ssShowed3:
    begin
      Inc(CountStepPros);
      if AxesMaterial.Diffuse[3] <= 1 then
      begin
        AxesMaterial.Diffuse[3] := AxesMaterial.Diffuse[3] + Alfa;
        ObrasMaterial.Diffuse[3] := ObrasMaterial.Diffuse[3] + Alfa;
        DetectorMaterial.Diffuse[3] := DetectorMaterial.Diffuse[3] + Alfa;
        ConusMaterial.Diffuse[3] := ConusMaterial.Diffuse[3] + Alfa;
        HyperbolMaterial.Diffuse[3] := HyperbolMaterial.Diffuse[3] + Alfa;
        InnerCylMaterial.Diffuse[3] := InnerCylMaterial.Diffuse[3] + Alfa;
        OuterCylMaterial.Diffuse[3] := OuterCylMaterial.Diffuse[3] + Alfa;
        ElectrumMaterial.Diffuse[3] := ElectrumMaterial.Diffuse[3] + Alfa;
        ElectrumMaterial2.Diffuse[3] := ElectrumMaterial2.Diffuse[3] + Alfa;
        ElectrumMaterial3.Diffuse[3] := ElectrumMaterial3.Diffuse[3] + Alfa;
        PathMaterial.Diffuse[3] :=  PathMaterial.Diffuse[3] + Alfa;
        PathMaterial2.Diffuse[3] :=  PathMaterial2.Diffuse[3] + Alfa;
        PathMaterial3.Diffuse[3] :=  PathMaterial3.Diffuse[3] + Alfa;
        TextMaterial.Diffuse[3] := TextMaterial.Diffuse[3] + Alfa;
        GunMaterial.Diffuse[3] := GunMaterial.Diffuse[3] + Alfa;
        DetectorReacMaterial.Diffuse[3] := DetectorReacMaterial.Diffuse[3] + Alfa;
       DetectorReac2Material.Diffuse[3] := DetectorReac2Material.Diffuse[3] + Alfa;
       DetectorReac3Material.Diffuse[3] := DetectorReac3Material.Diffuse[3] + Alfa;
      end
      else
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssStop9:
    begin
      Tag := Tag + TimerDelay;            //сколько прошло вермени
      if Tag >= NullDelay then            //сколько нужно чтобы перейти на след
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CountStepPros := 0;
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
    end;
  ssRotate1:
    begin
      VAngleY := VAngleY - 1;
      if VAngleY <= StopRotate - 62 then
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      FormResize(fmMain);
    end;
  ssStart2EAll:
    begin
      Inc(CoordS);
      Inc(CoordS2);
      Inc(CoordS3);
      if CoordS = Count - 1 then
        begin
           Tag := 0;                       //обнуляем сколько прошло
           CurState := Succ(CurState);     //выбираем следующюю прорисовку
           DetectorReacMaterial.Emission[0] := 1;
           DetectorReac2Material.Emission[0] := 1;
           DetectorReac3Material.Emission[0] := 1;
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssStop10:
    begin
      Tag := 0;                       //обнуляем сколько прошло
      CurState := Succ(CurState);     //выбираем следующюю прорисовку
    end;
  ssRotateNazad:
    begin
      VAngleY := VAngleY + 1;
      if VAngleY >= StopRotate then
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      FormResize(fmMain);
    end;
  ssStop11:
    begin
      Tag := Tag + TimerDelay;            //сколько прошло вермени
      if Tag >= NullDelay then            //сколько нужно чтобы перейти на след
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CountStepPros := 0;
          VAngleY := StopRotate;
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
    end;
  ssVesdNadRotate:
    begin
      if ScaleF < StopNaesd + 9 then
        ScaleF := ScaleF + 0.02;
      if VAngleY >= StopRotate - 45 then
        VAngleY := VAngleY - 1;
      if (ScaleF >= StopNaesd + 9) and (VAngleY <= StopRotate - 45) then
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
          CountStepPros := 0;
        end;
      TextDraw := False;
      FormResize(fmMain);
    end;
  ssStop12:
    begin
      Inc(CountStepPros);
      if AxesMaterial.Diffuse[3] >= 0.8 then
      begin
        AxesMaterial.Diffuse[3] := AxesMaterial.Diffuse[3] - Alfa;
        ObrasMaterial.Diffuse[3] := ObrasMaterial.Diffuse[3] - Alfa;
        DetectorMaterial.Diffuse[3] := DetectorMaterial.Diffuse[3] - Alfa;
        ConusMaterial.Diffuse[3] := ConusMaterial.Diffuse[3] - Alfa;
        HyperbolMaterial.Diffuse[3] := HyperbolMaterial.Diffuse[3] - Alfa;
        InnerCylMaterial.Diffuse[3] := InnerCylMaterial.Diffuse[3] - Alfa;
        OuterCylMaterial.Diffuse[3] := OuterCylMaterial.Diffuse[3] - Alfa;
        ElectrumMaterial.Diffuse[3] := ElectrumMaterial.Diffuse[3] - Alfa;
        ElectrumMaterial2.Diffuse[3] := ElectrumMaterial2.Diffuse[3] - Alfa;
        ElectrumMaterial3.Diffuse[3] := ElectrumMaterial3.Diffuse[3] - Alfa;
        PathMaterial.Diffuse[3] :=  PathMaterial.Diffuse[3] - Alfa;
        PathMaterial2.Diffuse[3] :=  PathMaterial2.Diffuse[3] - Alfa;
        PathMaterial3.Diffuse[3] :=  PathMaterial3.Diffuse[3] - Alfa;
        TextMaterial.Diffuse[3] := TextMaterial.Diffuse[3] - Alfa;
        GunMaterial.Diffuse[3] := GunMaterial.Diffuse[3] - Alfa;
        DetectorReacMaterial.Diffuse[3] := DetectorReacMaterial.Diffuse[3] - Alfa;
       DetectorReac2Material.Diffuse[3] := DetectorReac2Material.Diffuse[3] - Alfa;
       DetectorReac3Material.Diffuse[3] := DetectorReac3Material.Diffuse[3] - Alfa;
      end
      else
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
          CountStepPros := 0;
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssTurned4:
    begin
      Inc(CountStepPros);
      VAngleY := VAngleY - 1;
      if CountStepPros = 360 then
        begin
          Tag := 0;
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
      FormResize(fmMain);
    end;
  ssUdal:
    begin
      if ScaleF > StopNaesd then
        ScaleF := ScaleF - 0.02;
      if VAngleY <= StopRotate then
        VAngleY := VAngleY + 1;
      if (ScaleF <= StopNaesd) and (VAngleY >= StopRotate) then
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
          TextDraw := True;
        end;
      FormResize(fmMain);
    end;
  ssStop13:
    begin
      Tag := Tag + TimerDelay;            //сколько прошло вермени
      if Tag >= 3 * NullDelay then            //сколько нужно чтобы перейти на след
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CountStepPros := 0;
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
        end;
    end;
  ssUtih4:
    begin
      if AxesMaterial.Diffuse[3] >= 0 then
      begin
        AxesMaterial.Diffuse[3] := AxesMaterial.Diffuse[3] - Alfa;
        ObrasMaterial.Diffuse[3] := ObrasMaterial.Diffuse[3] - Alfa;
        DetectorMaterial.Diffuse[3] := DetectorMaterial.Diffuse[3] - Alfa;
        ConusMaterial.Diffuse[3] := ConusMaterial.Diffuse[3] - Alfa;
        HyperbolMaterial.Diffuse[3] := HyperbolMaterial.Diffuse[3] - Alfa;
        InnerCylMaterial.Diffuse[3] := InnerCylMaterial.Diffuse[3] - Alfa;
        OuterCylMaterial.Diffuse[3] := OuterCylMaterial.Diffuse[3] - Alfa;
        ElectrumMaterial.Diffuse[3] := ElectrumMaterial.Diffuse[3] - Alfa;
        ElectrumMaterial2.Diffuse[3] := ElectrumMaterial2.Diffuse[3] - Alfa;
        ElectrumMaterial3.Diffuse[3] := ElectrumMaterial3.Diffuse[3] - Alfa;
        PathMaterial.Diffuse[3] :=  PathMaterial.Diffuse[3] - Alfa;
        PathMaterial2.Diffuse[3] :=  PathMaterial2.Diffuse[3] - Alfa;
        PathMaterial3.Diffuse[3] :=  PathMaterial3.Diffuse[3] - Alfa;
        TextMaterial.Diffuse[3] := TextMaterial.Diffuse[3] - Alfa;
        GunMaterial.Diffuse[3] := GunMaterial.Diffuse[3] - Alfa;
        DetectorReacMaterial.Diffuse[3] := DetectorReacMaterial.Diffuse[3] - Alfa;
        DetectorReac2Material.Diffuse[3] := DetectorReac2Material.Diffuse[3] - Alfa;
        DetectorReac3Material.Diffuse[3] := DetectorReac3Material.Diffuse[3] - Alfa;
      end
      else
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := Succ(CurState);     //выбираем следующюю прорисовку

          AxesMaterial.Diffuse[3] := 0;
          ObrasMaterial.Diffuse[3] := 0;
          DetectorMaterial.Diffuse[3] := 0;
          ConusMaterial.Diffuse[3] := 0;
          HyperbolMaterial.Diffuse[3] := 0;
          InnerCylMaterial.Diffuse[3] := 0;
          OuterCylMaterial.Diffuse[3] := 0;
          ElectrumMaterial.Diffuse[3] := 0;
          ElectrumMaterial2.Diffuse[3] := 0;
          ElectrumMaterial3.Diffuse[3] := 0;
          PathMaterial.Diffuse[3] :=  0;
          PathMaterial2.Diffuse[3] :=  0;
          PathMaterial3.Diffuse[3] :=  0;
          TextMaterial.Diffuse[3] := 0;
          GunMaterial.Diffuse[3] := 0;
          DetectorReacMaterial.Diffuse[3] := 0;
          DetectorReac2Material.Diffuse[3] := 0;
          DetectorReac3Material.Diffuse[3] := 0;
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  ssStop14:
    begin
      Tag := Tag + TimerDelay;            //сколько прошло вермени
      if Tag >= NullDelay then            //сколько нужно чтобы перейти на след
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CountStepPros := 0;
          CurState := Succ(CurState);     //выбираем следующюю прорисовку
          CoordS := 0;
          CoordS2 := 0;
          CoordS3 := 0;
          DetectorReacMaterial.Emission[0] := 0;
          DetectorReac2Material.Emission[0] := 0;
          DetectorReac3Material.Emission[0] := 0;
        end;
    end;
  ssShowed4:
    begin
      Inc(CountStepPros);
      if CountStepPros < CountProcvet + 1 then
      begin
        AxesMaterial.Diffuse[3] := AxesMaterial.Diffuse[3] + StepPros[1];
        ObrasMaterial.Diffuse[3] := ObrasMaterial.Diffuse[3] + StepPros[2];
        DetectorMaterial.Diffuse[3] := DetectorMaterial.Diffuse[3] + StepPros[3];
        ConusMaterial.Diffuse[3] := ConusMaterial.Diffuse[3] + StepPros[4];
        HyperbolMaterial.Diffuse[3] := HyperbolMaterial.Diffuse[3] + StepPros[5];
        InnerCylMaterial.Diffuse[3] := InnerCylMaterial.Diffuse[3] + StepPros[6];
        OuterCylMaterial.Diffuse[3] := OuterCylMaterial.Diffuse[3] + StepPros[7];
        ElectrumMaterial.Diffuse[3] := ElectrumMaterial.Diffuse[3] + StepPros[8];
        ElectrumMaterial2.Diffuse[3] := ElectrumMaterial2.Diffuse[3] + StepPros[9];
        ElectrumMaterial3.Diffuse[3] := ElectrumMaterial3.Diffuse[3] + StepPros[10];
        PathMaterial.Diffuse[3] :=  PathMaterial.Diffuse[3] + StepPros[11];
        PathMaterial2.Diffuse[3] :=  PathMaterial2.Diffuse[3] + StepPros[12];
        PathMaterial3.Diffuse[3] :=  PathMaterial3.Diffuse[3] + StepPros[13];
        TextMaterial.Diffuse[3] := TextMaterial.Diffuse[3] + StepPros[14];
        GunMaterial.Diffuse[3] := GunMaterial.Diffuse[3] + StepPros[15];
       DetectorReacMaterial.Diffuse[3] := DetectorReacMaterial.Diffuse[3] + StepPros[16];
       DetectorReac2Material.Diffuse[3] := DetectorReac2Material.Diffuse[3] + StepPros[17];
       DetectorReac3Material.Diffuse[3] := DetectorReac3Material.Diffuse[3] + StepPros[18];
      end
      else
        begin
          Tag := 0;                       //обнуляем сколько прошло
          CurState := ssStartE1;     //выбираем следующюю прорисовку
          CountStepPros := 0;
        end;
      InvalidateRect(Handle, nil, False); //Перерисовка
    end;
  end;
end;

procedure TfmMain.DrawText;
begin
  if TextDraw then
    begin
      glPushMatrix;                         //Запоминаем матрицы
      glPushAttrib(GL_ALL_ATTRIB_BITS);     //Запоминаем все артибуты

      glLoadIdentity;

      glOrtho(-4, 4, -4, 4, -4, 4);

      glRotatef(-90, 0.0, 1.0, 0.0);              //Все поворачивается на 90 градусов

      SetMaterial(GL_FRONT_AND_BACK, TextMaterial);  //Установка материала

      glRotatef(80, 0.0, 1.0, 0.0);           //Поврот на 80 градусов
      glTranslatef(0, 0, -1);

      glTranslatef(-2.36, 3.6, 0);
        OutText(ProjectTitle1, 0.3);
      glTranslatef(2.36, 0, 0);

      glTranslatef(-2, - 0.3, 0);
        OutText(ProjectTitle2, 0.3);
      glTranslatef(2.4, 0.0, 0);

      glPopAttrib;                          //Восстанавливаем атрибуты
      glPopMatrix;                          //Восстанавливаем матрицы
    end;
end;

procedure TfmMain.StepProsProc;
begin
  StepPros[1] := AxesMaterial.Diffuse[3] / CountProcvet;
  StepPros[2] := ObrasMaterial.Diffuse[3] / CountProcvet;
  StepPros[3] := DetectorMaterial.Diffuse[3] / CountProcvet;
  StepPros[4] := ConusMaterial.Diffuse[3] / CountProcvet;
  StepPros[5] := HyperbolMaterial.Diffuse[3] / CountProcvet ;
  StepPros[6] := InnerCylMaterial.Diffuse[3] / CountProcvet ;
  StepPros[7] := OuterCylMaterial.Diffuse[3] / CountProcvet ;
  StepPros[8] := ElectrumMaterial.Diffuse[3] / CountProcvet ;
  StepPros[9] := ElectrumMaterial2.Diffuse[3] / CountProcvet ;
  StepPros[10] := ElectrumMaterial3.Diffuse[3] / CountProcvet ;
  StepPros[11] := PathMaterial.Diffuse[3] / CountProcvet ;
  StepPros[12] := PathMaterial2.Diffuse[3] / CountProcvet ;
  StepPros[13] := PathMaterial3.Diffuse[3] / CountProcvet ;
  StepPros[14] := TextMaterial.Diffuse[3] / CountProcvet ;
  StepPros[15] := GunMaterial.Diffuse[3] / CountProcvet ;
  StepPros[16] := DetectorReacMaterial.Diffuse[3] / CountProcvet ;
  StepPros[17] := DetectorReac2Material.Diffuse[3] / CountProcvet ;
  StepPros[18] := DetectorReac3Material.Diffuse[3] / CountProcvet ;
end;

procedure TfmMain.DrawUtih;
begin
  if Pic then
    begin
      DrawOs;
      DrawObras;
      DrawDetector;
      DrawConus;
      DrawHyper;
      DrawInnerCyl;
      DrawOuterCyl;
      DrawElectrum;
      DrawElectrum2;
      DrawElectrum3;
      Pic := False;
    end;
end;

procedure TfmMain.DrawNathing;
begin
end;

end.
