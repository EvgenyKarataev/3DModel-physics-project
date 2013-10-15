object fmParams: TfmParams
  Left = 497
  Top = 142
  Width = 253
  Height = 244
  BorderStyle = bsSizeToolWin
  BorderWidth = 4
  Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  ScreenSnap = True
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    237
    207)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 0
    Top = 36
    Width = 43
    Height = 13
    Caption = 'Ambient:'
  end
  object Label2: TLabel
    Left = 4
    Top = 64
    Width = 38
    Height = 13
    Caption = 'Diffuse:'
  end
  object Label3: TLabel
    Left = 0
    Top = 96
    Width = 45
    Height = 13
    Caption = 'Specular:'
  end
  object Label4: TLabel
    Left = 0
    Top = 128
    Width = 44
    Height = 13
    Caption = 'Emission:'
  end
  object Label5: TLabel
    Left = 0
    Top = 160
    Width = 48
    Height = 13
    Caption = 'Shininess:'
  end
  object SpeedButton1: TSpeedButton
    Left = 112
    Top = 187
    Width = 123
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = 'Copy to clipboard'
    OnClick = SpeedButton1Click
  end
  object cmbObject: TComboBox
    Left = 0
    Top = 0
    Width = 237
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
    OnChange = cmbObjectChange
  end
  object pAmbient: TPanel
    Left = 56
    Top = 32
    Width = 20
    Height = 20
    BevelOuter = bvLowered
    TabOrder = 1
    OnClick = pAmbientClick
  end
  object pDiffuse: TPanel
    Left = 56
    Top = 64
    Width = 20
    Height = 20
    BevelOuter = bvLowered
    TabOrder = 2
    OnClick = pDiffuseClick
  end
  object pSpecular: TPanel
    Left = 56
    Top = 96
    Width = 20
    Height = 20
    BevelOuter = bvLowered
    TabOrder = 3
    OnClick = pSpecularClick
  end
  object pEmission: TPanel
    Left = 56
    Top = 124
    Width = 20
    Height = 20
    BevelOuter = bvLowered
    TabOrder = 4
    OnClick = pEmissionClick
  end
  object edAmbient: TEdit
    Left = 84
    Top = 32
    Width = 153
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 5
  end
  object edDiffuse: TEdit
    Left = 84
    Top = 64
    Width = 153
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 6
  end
  object edSpecular: TEdit
    Left = 84
    Top = 96
    Width = 153
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 7
  end
  object edEmission: TEdit
    Left = 84
    Top = 124
    Width = 153
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 8
  end
  object seShininess: TSpinEdit
    Left = 84
    Top = 156
    Width = 153
    Height = 22
    Anchors = [akLeft, akTop, akRight]
    MaxValue = 0
    MinValue = 0
    TabOrder = 9
    Value = 0
    OnChange = seShininessChange
  end
  object ColorDialog: TColorDialog
    Left = 212
    Top = 8
  end
end
