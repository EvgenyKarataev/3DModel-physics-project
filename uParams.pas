unit uParams;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uConsts, Spin, Buttons, Clipbrd;

type
  TfmParams = class(TForm)
    cmbObject: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    pAmbient: TPanel;
    pDiffuse: TPanel;
    pSpecular: TPanel;
    pEmission: TPanel;
    ColorDialog: TColorDialog;
    edAmbient: TEdit;
    edDiffuse: TEdit;
    edSpecular: TEdit;
    edEmission: TEdit;
    seShininess: TSpinEdit;
    SpeedButton1: TSpeedButton;
    procedure pAmbientClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cmbObjectChange(Sender: TObject);
    procedure pDiffuseClick(Sender: TObject);
    procedure pSpecularClick(Sender: TObject);
    procedure pEmissionClick(Sender: TObject);
    procedure seShininessChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Busy: Boolean;
    CurMaterial: PGLMaterial;
  end;

var
  fmParams: TfmParams;

implementation

uses uMain;

{$R *.dfm}

procedure TfmParams.pAmbientClick(Sender: TObject);
begin
  ColorDialog.Color := pAmbient.Color;
  if ColorDialog.Execute then
    begin
      pAmbient.Color := ColorDialog.Color;
      CurMaterial^.Ambient := ColorToGLColor(ColorDialog.Color);
      edAmbient.Text := GLColorToStr(CurMaterial^.Ambient);
      InvalidateRect(fmMain.Handle, nil, False);
    end;
end;

procedure TfmParams.FormCreate(Sender: TObject);
begin
  cmbObject.Clear;

  cmbObject.AddItem('Внутренний цилиндр', @InnerCylMaterial);
  cmbObject.AddItem('Внешний цилиндр', @OuterCylMaterial);
  cmbObject.AddItem('Конус', @ConusMaterial);
  cmbObject.AddItem('Электрон', @ElectrumMaterial);
  cmbObject.AddItem('Гиперболоид', @HyperbolMaterial);
  cmbObject.AddItem('Траектория', @PathMaterial);
  cmbObject.AddItem('Оси координат', @AxesMaterial);

  cmbObject.ItemIndex := 0;

  cmbObjectChange(cmbObject);
end;

procedure TfmParams.cmbObjectChange(Sender: TObject);
begin
  Busy := True;

  if Self.Visible then edAmbient.SetFocus;

  CurMaterial := PGLMaterial(cmbObject.Items.Objects[cmbObject.ItemIndex]);
  if CurMaterial = nil then Exit;

  pAmbient.Color := GLColorToColor(CurMaterial^.Ambient);
  edAmbient.Text := GLColorToStr(CurMaterial^.Ambient);

  pDiffuse.Color := GLColorToColor(CurMaterial^.Diffuse);
  edDiffuse.Text := GLColorToStr(CurMaterial^.Diffuse);

  pSpecular.Color := GLColorToColor(CurMaterial^.Specular);
  edSpecular.Text := GLColorToStr(CurMaterial^.Specular);

  pEmission.Color := GLColorToColor(CurMaterial^.Emission);
  seShininess.Value := Round(CurMaterial^.Shininess);

  Busy := False;
end;

procedure TfmParams.pDiffuseClick(Sender: TObject);
begin
  ColorDialog.Color := pDiffuse.Color;
  if ColorDialog.Execute then
    begin
      pDiffuse.Color := ColorDialog.Color;
      CurMaterial^.Diffuse := ColorToGLColor(ColorDialog.Color);
      edDiffuse.Text := GLColorToStr(CurMaterial^.Diffuse);
      InvalidateRect(fmMain.Handle, nil, False);
    end;
end;

procedure TfmParams.pSpecularClick(Sender: TObject);
begin
  ColorDialog.Color := pSpecular.Color;
  if ColorDialog.Execute then
    begin
      pSpecular.Color := ColorDialog.Color;
      CurMaterial^.Specular := ColorToGLColor(ColorDialog.Color);
      edSpecular.Text := GLColorToStr(CurMaterial^.Specular);
      InvalidateRect(fmMain.Handle, nil, False);
    end;
end;

procedure TfmParams.pEmissionClick(Sender: TObject);
begin
  ColorDialog.Color := pEmission.Color;
  if ColorDialog.Execute then
    begin
      pEmission.Color := ColorDialog.Color;
      CurMaterial^.Emission := ColorToGLColor(ColorDialog.Color);
      edEmission.Text := GLColorToStr(CurMaterial^.Emission);
      InvalidateRect(fmMain.Handle, nil, False);
    end;
end;

procedure TfmParams.seShininessChange(Sender: TObject);
begin
  if Busy then Exit;

  CurMaterial^.Shininess := seShininess.Value;
  InvalidateRect(fmMain.Handle, nil, False);
end;

procedure TfmParams.FormShow(Sender: TObject);
begin
  Self.Left := Screen.Width - Self.Width;
  Self.Top := 0;
end;

procedure TfmParams.SpeedButton1Click(Sender: TObject);
var
  sl: TStringList;
  Buf: Char;
begin
  Buf := DecimalSeparator;
  DecimalSeparator := '.';
  sl := TStringList.Create;
  try
    sl.Add(Format('    (Ambient: (%f, %f, %f, %f);', [CurMaterial^.Ambient[0], CurMaterial^.Ambient[1],
      CurMaterial^.Ambient[2], CurMaterial^.Ambient[3]]));
    sl.Add(Format('    Diffuse: (%f, %f, %f, %f);', [CurMaterial^.Diffuse[0], CurMaterial^.Diffuse[1],
      CurMaterial^.Diffuse[2], CurMaterial^.Diffuse[3]]));
    sl.Add(Format('    Specular: (%f, %f, %f, %f);', [CurMaterial^.Specular[0], CurMaterial^.Specular[1],
      CurMaterial^.Specular[2], CurMaterial^.Specular[3]]));
    sl.Add(Format('    Emission: (%f, %f, %f, %f);', [CurMaterial^.Emission[0], CurMaterial^.Emission[1],
      CurMaterial^.Emission[2], CurMaterial^.Emission[3]]));
    sl.Add(Format('    Shininess: %f', [CurMaterial^.Shininess]));
    sl.Add('    );');

    Clipboard.AsText := sl.Text;
  finally
    DecimalSeparator := Buf;
    sl.Free;
  end;
end;

end.
