program Fokusirovka;

uses
  Forms,
  uMain in 'uMain.pas' {fmMain},
  uConsts in '..\..\����������� �� ������ �������\����������� �����(� 50)����\uConsts.pas',
  uParams in 'uParams.pas' {fmParams};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := '����������� ����� ���������� ������ � ������������������ ������� ������ ��������������� � ���������������� �����';
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TfmParams, fmParams);
  Application.Run;
end.

