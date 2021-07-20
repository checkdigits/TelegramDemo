unit UChatFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.Objects, FMX.Layouts,FMX.TabControl,
  sgcWebSocket_APIs,sgcBase_Classes,sgcLib_Telegram_Client;

type
  TChatFrame = class(TFrame)
    VertScrollBox1: TVertScrollBox;
    Rectangle1: TRectangle;
    edtSendMessage: TEdit;
    lblChatTitle: TLabel;
    procedure edtSendMessageExit(Sender: TObject);
  private
    { Déclarations privées }
    FCurrentHeight:Single;
    FChatID:string;
    FTabItemParent:TTabItem;
    FsgcTelegram: TsgcTDLib_Telegram;
  public
    { Déclarations publiques }
    procedure AddMessage(aMessage,Sender:string);
    constructor Create(aTelegramClient:TsgcTDLib_Telegram;aTabItemParent:TTabItem;title:string;ChatID:string);reintroduce;
    property TabItemParent : TTabItem read FTabItemParent;
  end;

implementation

{$R *.fmx}

{ TFrame1 }

procedure TChatFrame.AddMessage(aMessage,Sender: string);
var aLabel:TLabel;
begin
  aLabel:=TLabel.Create(VertScrollBox1);
  aLabel.AutoSize := True;
  aLabel.Margins.Left :=15;
  aLabel.Margins.Right :=15;
  aLabel.Parent := VertScrollBox1;
  if Sender='' then
  begin
    aLabel.TextAlign := TTextAlign.Leading;
    aLabel.Text := aMessage;
  end
  else
  begin
    aLabel.TextAlign := TTextAlign.Trailing;
    aLabel.Text := Sender +' : '+aMessage;
  end;
  aLabel.Align := TAlignlayout.Top;
  aLabel.Position.Y :=  FCurrentHeight+2;
  FCurrentHeight := FCurrentHeight+aLabel.Height;
end;

constructor TChatFrame.Create(aTelegramClient:TsgcTDLib_Telegram;aTabItemParent: TTabItem; title: string;ChatID:string);
begin
  inherited Create(nil);
  FChatID:= ChatID;
  FTabItemParent := aTabItemParent;
  FsgcTelegram := aTelegramClient;
  lblChatTitle.Text := title;
end;

procedure TChatFrame.edtSendMessageExit(Sender: TObject);
begin
  if edtSendMessage.text<>'' then
  begin
    FsgcTelegram.SendTextMessage(FChatID,edtSendMessage.text);
    edtSendMessage.text := '';
  end;
end;

end.
