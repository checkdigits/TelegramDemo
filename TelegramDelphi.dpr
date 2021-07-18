program TelegramDelphi;

uses
  System.StartUpCopy,
  FMX.Forms,
  TelegramMain in 'TelegramMain.pas' {HeaderFooterForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(THeaderFooterForm, HeaderFooterForm);
  Application.Run;
end.
