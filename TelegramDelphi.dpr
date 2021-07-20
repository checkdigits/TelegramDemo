program TelegramDelphi;

uses
  System.StartUpCopy,
  FMX.Forms,
  TelegramMain in 'TelegramMain.pas' {HeaderFooterForm},
  UChatFrame in 'UChatFrame.pas' {ChatFrame: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(THeaderFooterForm, HeaderFooterForm);
  Application.Run;
end.
