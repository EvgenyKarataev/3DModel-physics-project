{ *********************************************************************** }
{                                                                         }
{ Типы, константы, процедуры, функции и т.п.                              }
{                                                                         }
{ *********************************************************************** }


unit uConsts;

interface

uses Windows, SysUtils, OpenGL, Graphics;

type
  PGLMaterial = ^TGLMaterial;
  TGLMaterial = record
    Ambient,
    Diffuse,
    Specular,
    Emission: TGLArrayf4;
    Shininess: GLFloat;
  end;

var
// Материалы --

  InnerCylMaterial: TGLMaterial =
    (Ambient: (0.05, 0.05, 0.05, 0.5);
    Diffuse: (0.91, 0.91, 0.91, 0.0);
    Specular: (0.00, 0.00, 0.00, 0.5);
    Emission: (0.04, 0.04, 1.00, 0.5);
    Shininess: 10.00
    );

  OuterCylMaterial: TGLMaterial =
  (Ambient: (0.75, 0.75, 0.75, 0.1);
    Diffuse: (1.00, 1.00, 1.00, 0.0);
    Specular: (0.00, 0.00, 0.00, 0.1);
    Emission: (0.00, 0.00, 0.00, 0.1);
    Shininess: 32
    );

  ConusMaterial: TGLMaterial =
    (Ambient: (1.00, 1.00, 1.00, 0.5);
    Diffuse: (0.71, 0.71, 0.71, 0.0);
    Specular: (0.00, 0.00, 0.00, 0.5);
    Emission: (0.00, 0.00, 0.00, 0.5);
    Shininess: 32.00
    );

  HyperbolMaterial: TGLMaterial =
    (Ambient: (1.00, 1.00, 1.00, 0.5);
    Diffuse: (0.71, 0.71, 0.71, 0.0);
    Specular: (0.00, 0.00, 0.00, 0.5);
    Emission: (0.00, 0.00, 0.00, 0.5);
    Shininess: 32.00
    );

  PathMaterial:  TGLMaterial =
    (Ambient: (0.10, 0.10, 0.10, 1.00);
    Diffuse: (0.00, 0.00, 0.00, 1.00);
    Specular: (1.00, 1.00, 1.00, 1.00);
    Emission: (1.00, 0.00, 0.00, 1.00);
    Shininess: 32.00
    );

  PathMaterial2:  TGLMaterial =
    (Ambient: (0.10, 0.10, 0.10, 1.00);
    Diffuse: (0.00, 0.00, 0.00, 1.00);
    Specular: (1.00, 1.00, 1.00, 1.00);
    Emission: (1.00, 0.00, 0.00, 1.00);
    Shininess: 32.00
    );

  PathMaterial3:  TGLMaterial =
    (Ambient: (0.10, 0.10, 0.10, 1.00);
    Diffuse: (0.00, 0.00, 0.00, 1.00);
    Specular: (1.00, 1.00, 1.00, 1.00);
    Emission: (1.00, 0.00, 0.00, 1.00);
    Shininess: 32.00
    );

  ElectrumMaterial:  TGLMaterial =
    (Ambient: (0.00, 0.00, 0.00, 0.5);
    Diffuse: (1.00, 1.00, 1.00, 0.0);
    Specular: (0.00, 0.00, 0.00, 0.5);
    Emission: (0.00, 0.00, 0.00, 0.5);
    Shininess: 32.00
    );

  ElectrumMaterial2:  TGLMaterial =
    (Ambient: (0.00, 0.00, 0.00, 0.5);
    Diffuse: (1.00, 1.00, 1.00, 0.0);
    Specular: (0.00, 0.00, 0.00, 0.5);
    Emission: (0.00, 0.00, 0.00, 0.5);
    Shininess: 32.00
    );

  ElectrumMaterial3:  TGLMaterial =
    (Ambient: (0.00, 0.00, 0.00, 0.5);
    Diffuse: (1.00, 1.00, 1.00, 0.0);
    Specular: (0.00, 0.00, 0.00, 0.5);
    Emission: (0.00, 0.00, 0.00, 0.5);
    Shininess: 32.00
    );

  AxesMaterial:  TGLMaterial =
    (Ambient: (0.00, 0.00, 0.00, 1.0);
    Diffuse: (1.00, 1.00, 1.00, 0.0);
    Specular: (0.00, 0.00, 0.00, 1.0);
    Emission: (0.00, 0.00, 0.00, 1.0);
    Shininess: 32.00
    );

  GunMaterial:  TGLMaterial =
    (Ambient: (0.00, 0.00, 0.00, 1.0);
    Diffuse: (1.00, 1.00, 1.00, 0.0);
    Specular: (0.00, 0.00, 0.00, 1.0);
    Emission: (0.00, 0.00, 0.00, 1.0);
    Shininess: 32.00
    );

  ObrasMaterial:  TGLMaterial =
    (Ambient: (0.00, 0.00, 0.00, 1.0);
    Diffuse: (1.00, 1.00, 1.00, 0.0);
    Specular: (0.00, 0.00, 0.00, 1.0);
    Emission: (0.00, 0.00, 0.00, 1.0);
    Shininess: 32.00
    );

  DetectorMaterial:  TGLMaterial =
    (Ambient: (1.00, 1.00, 1.00, 0.5);
    Diffuse: (0.71, 0.71, 0.71, 0.0);
    Specular: (0.00, 0.00, 0.00, 0.5);
    Emission: (0.00, 0.00, 0.00, 0.5);
    Shininess: 32.00
    );

  DetectorReacMaterial:  TGLMaterial =
    (Ambient: (1.00, 1.00, 1.00, 0.5);
    Diffuse: (0.71, 0.71, 0.71, 0.0);
    Specular: (0.00, 0.00, 0.00, 0.5);
    Emission: (0.00, 0.00, 0.00, 0.5);
    Shininess: 32.00
    );

  DetectorReac2Material:  TGLMaterial =
    (Ambient: (1.00, 1.00, 1.00, 0.5);
    Diffuse: (0.71, 0.71, 0.71, 0.0);
    Specular: (0.00, 0.00, 0.00, 0.5);
    Emission: (0.00, 0.00, 0.00, 0.5);
    Shininess: 32.00
    );

  DetectorReac3Material:  TGLMaterial =
    (Ambient: (1.00, 1.00, 1.00, 0.5);
    Diffuse: (0.71, 0.71, 0.71, 0.0);
    Specular: (0.00, 0.00, 0.00, 0.5);
    Emission: (0.00, 0.00, 0.00, 0.5);
    Shininess: 32.00
    );

  TextMaterial:  TGLMaterial =
    (Ambient: (0.00, 0.00, 0.00, 1.0);
    Diffuse: (0.00, 1.00, 0.00, 1.0);
    Specular: (0.00, 0.00, 0.00, 1.0);
    Emission: (1.00, 0.00, 0.00, 1.0);
    Shininess: 32.00
    );
    {(Ambient: (0.05, 0.05, 0.05, 0.5);
    Diffuse: (0.91, 0.91, 0.91, 0.5);
    Specular: (0.00, 0.00, 0.00, 0.5);
    Emission: (0.04, 0.04, 1.00, 0.5);
    Shininess: 10.00
    );}
// -- Материалы

// Цвета --

  PathColor: TGLArrayf4 = (0.0, 1.0, 0.0, 0.5);

// -- Цвета


// Свет --

  Light0Pos: TGLArrayf4 = (4.0, 4.0, 4.0, 0.0);
  Light1Pos: TGLArrayf4 = (0.0, 0.0, -10.0, 0.0);
  Light0Amb: TGLArrayf4 = (0.0, 0.0, 0.0, 1.0);
  Light0Dif: TGLArrayf4 = (1.0, 1.0, 1.0, 1.0);

  ElLightPos: TGLArrayf4 = (0.0, 0.0, 0.0, 1.0);
  ElLightDir: TGLArrayf3 = (0.0, 0.0, 0.0);


// -- Свет

procedure SetMaterial(Face: Cardinal; const Material: TGLMaterial);

function GLColorToColor(const Color: TGLArrayf4): TColor;

function GLColorToStr(const Color: TGLArrayf4): string;

function ColorToGLColor(const Color: TColor): TGLArrayf4;

implementation

procedure SetMaterial(Face: Cardinal; const Material: TGLMaterial);
// Устанавливает текущий материал
begin
  glMaterialfv(Face, GL_AMBIENT, @Material.Ambient);
  glMaterialfv(Face, GL_DIFFUSE, @Material.Diffuse);
  glMaterialfv(Face, GL_SPECULAR, @Material.Specular);
  glMaterialfv(Face, GL_EMISSION, @Material.Emission);
  glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, Material.Shininess);
end;

function GLColorToColor(const Color: TGLArrayf4): TColor;
begin
  Result := RGB(Round(Color[0] * 255), Round(Color[1] * 255), Round(Color[2] * 255));
end;

function GLColorToStr(const Color: TGLArrayf4): string;
var
  Buf: Char;
begin
  Buf := DecimalSeparator;
  DecimalSeparator := '.';
  Result := Format('%f, %f, %f, %f', [Color[0], Color[1], Color[2], Color[3]]);
  DecimalSeparator := Buf;
end;

function ColorToGLColor(const Color: TColor): TGLArrayf4;
begin
  Result[0] := GetRValue(Color) / 255;
  Result[1] := GetGValue(Color) / 255;
  Result[2] := GetBValue(Color) / 255;
  Result[3] := 1.0;
end;

end.
