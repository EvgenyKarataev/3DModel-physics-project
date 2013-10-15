program Fokusirovka;

uses
  Forms,
  uMain in 'uMain.pas' {fmMain},
  uConsts in '..\..\Фокусировка со старым гипером\Фокусировка фильм(с 50)стар\uConsts.pas',
  uParams in 'uParams.pas' {fmParams};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Фокусировка пучка заряженных частиц в электростатической системе зеркал цилиндрического и гиперболического типов';
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TfmParams, fmParams);
  Application.Run;
end.

