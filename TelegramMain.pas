unit TelegramMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.TabControl, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  Fmx.Bind.GenData, Data.Bind.GenData, Data.Bind.Components,
  Data.Bind.ObjectScope,System.Generics.Collections, System.Rtti,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt,
  FMX.Objects, FMX.Layouts, FMX.ExtCtrls, sgcBase_Classes,
  sgcLib_Telegram_Client, sgcWebSocket_APIs, FMX.Edit, FMX.ScrollBox, FMX.Memo,UChatFrame;

type
  TTelegramContact = class(TObject)
  public
    ContactName:string;
    FirstName,LastName:string;
    UserName:string;
    UserID : Int64;
    UserIDstr : string;
    ProfilePhotoId:string;
    Avatar : TBitmap;
    constructor Create();
    function GetCivility:string;
end;

type
  THeaderFooterForm = class(TForm)
    Header: TToolBar;
    Footer: TToolBar;
    HeaderLabel: TLabel;
    TabControl1: TTabControl;
    TabItemContacts: TTabItem;
    lblHeaderContact: TLabel;
    ListViewContacts: TListView;
    DataGeneratorAdapterContact: TDataGeneratorAdapter;
    BindingsList1: TBindingsList;
    RoundRect1: TRoundRect;
    IconAddContact: TImage;
    sgcTelegram: TsgcTDLib_Telegram;
    lblStatus: TLabel;
    TabItemAddContact: TTabItem;
    Rectangle1: TRectangle;
    lblAddContactInfo: TLabel;
    edtPhone: TEdit;
    lblPlus: TLabel;
    TabDebug: TTabItem;
    MemoDebug: TMemo;
    AGeneratorAdapterContact: TAdapterBindSource;
    LinkListControlToField1: TLinkListControlToField;
    Button2: TButton;
    procedure RoundRect1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sgcTelegramAuthenticationCode(Sender: TObject; var Code: string);
    procedure sgcTelegramAuthorizationStatus(Sender: TObject;
      const Status: string);
    procedure sgcTelegramException(Sender: TObject; E: Exception);
    procedure TabItemAddContactClick(Sender: TObject);
    procedure edtPhoneExit(Sender: TObject);
    procedure sgcTelegramEvent(Sender: TObject; const Event, Text: string);
    procedure ListViewContactsDblClick(Sender: TObject);
    procedure AGeneratorAdapterContactCreateAdapter(Sender: TObject;
      var ABindSourceAdapter: TBindSourceAdapter);
    procedure sgcTelegramNewChat(Sender: TObject; Chat: TsgcTelegramChat);
    procedure sgcTelegramMessageText(Sender: TObject;
      MessageText: TsgcTelegramMessageText);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    FPendingUserID:string;
    FUserIDChatFrameDictionnary:TDictionary<string,TChatFrame>;
    FChatIDChatFrameDictionnary:TDictionary<string,TChatFrame>;
    FChatList:TList<TsgcTelegramChat>;
    FContactList : TList<TTelegramContact>;
    FFileIDFilePathDico : TDictionary<string,string>;
    procedure ParseUpdateFile(Text:string);
    procedure ParseFile(Text:string);
    procedure ImportContacts(aPhoneNumber:string);
    function ParseImportedContacts(aText: string):TStringList;
    procedure DownloadFile(fileId:string);
    procedure ImportUser(aText:string);
  public
    { Public declarations }
  end;

var
  HeaderFooterForm: THeaderFooterForm;

implementation

uses JSon;

{$R *.fmx}

function THeaderFooterForm.ParseImportedContacts(aText: string):TStringList;
var aJson:TJsonValue;
    userIdArray:TJsonArray;
    iter:integer;
begin
  Result := TStringList.Create;
  aJson := TJSONObject.ParseJSONValue(aText);
  userIdArray := aJson.P['user_ids'] as TJsonArray;
  for iter := 0 to userIdArray.Count-1 do
  begin
    Result.Add(userIdArray.Items[iter].ToJSON);
  end;
  aJson.Free;
end;

procedure THeaderFooterForm.ParseUpdateFile(Text: string);
var aJson,afile,aLocal : TJsonValue;
    fileid,apath:string;
    aTelegram:TTelegramContact;
begin
  aJson := TJSONObject.ParseJSONValue(Text);
  afile := aJson.FindValue('file');
  fileid := afile.P['id'].Value;
  aLocal :=  afile.FindValue('local');
  apath := aLocal.P['path'].Value;
  if aPath<>'' then
  begin
    for aTelegram in FContactList do
    begin
      if aTelegram.ProfilePhotoId=fileid then
      begin
        aTelegram.Avatar.LoadFromFile(apath);
      end;
    end;
  end;
  aJson.Free;
end;

procedure THeaderFooterForm.ParseFile(Text: string);
var aJson,afile,aLocal : TJsonValue;
    fileid,apath:string;
    aTelegram:TTelegramContact;
begin
  aJson := TJSONObject.ParseJSONValue(Text);
  fileid := aJson.P['id'].Value;
  aLocal :=  aJson.FindValue('local');
  apath := aLocal.P['path'].Value;
  if aPath<>'' then
  begin
    for aTelegram in FContactList do
    begin
      if aTelegram.ProfilePhotoId=fileid then
      begin
        AGeneratorAdapterContact.Active := False;
        AGeneratorAdapterContact.Adapter.Active := False;
        aTelegram.Avatar.LoadFromFile(apath);
        AGeneratorAdapterContact.Active := True;
        AGeneratorAdapterContact.Adapter.Active := True;
      end;
    end;
  end;
  aJson.Free;
end;

procedure THeaderFooterForm.AGeneratorAdapterContactCreateAdapter(
  Sender: TObject; var ABindSourceAdapter: TBindSourceAdapter);
begin
  FContactList := TList<TTelegramContact>.Create;
  ABindSourceAdapter := TListBindSourceAdapter<TTelegramContact>.Create(Self,FContactList,True);
end;

procedure THeaderFooterForm.Button2Click(Sender: TObject);
begin
  TabControl1.ActiveTab := TabItemContacts;
end;

procedure THeaderFooterForm.DownloadFile(fileId: string);
var aDownload:string;
begin
  aDownload := '{"@type": "downloadFile","file_id":"'+fileId+'","priority":"1"}';
  MemoDebug.Lines.Add('Request:'+aDownload);
  sgcTelegram.TDLibSend(aDownload);
end;

procedure THeaderFooterForm.edtPhoneExit(Sender: TObject);
begin
  ImportContacts(edtPhone.Text);
end;

procedure THeaderFooterForm.FormCreate(Sender: TObject);
var aConfigFile:TStringList;
begin
  FFileIDFilePathDico := TDictionary<string,string>.Create;
  FUserIDChatFrameDictionnary:=TDictionary<string,TChatFrame>.Create;
  FChatIDChatFrameDictionnary:=TDictionary<string,TChatFrame>.Create;
  FChatList:=TList<TsgcTelegramChat>.Create;
  aConfigFile:= TStringList.Create;
  aConfigFile.LoadFromFile('config.ini');
  sgcTelegram.Telegram.API.ApiId := Trim(aConfigFile.Values['api_id']);
  sgcTelegram.Telegram.API.ApiHash :=  Trim(aConfigFile.Values['api_hash']);
  sgcTelegram.Telegram.PhoneNumber := Trim(aConfigFile.Values['phone']);
  sgcTelegram.Telegram.Parameters.ApplicationVersion := '1.0';
  sgcTelegram.Telegram.Parameters.DeviceModel := 'Desktop';
  sgcTelegram.Telegram.Parameters.LanguageCode := 'en';
  sgcTelegram.Telegram.Parameters.SystemVersion := 'Windows';
  if (sgcTelegram.Telegram.API.ApiId='') or
     (sgcTelegram.Telegram.API.ApiHash ='') or
     (sgcTelegram.Telegram.PhoneNumber ='')  then
  begin
    ShowMessage('Please fill the config.ini file');
  end
  else
  begin
    sgcTelegram.Active := True;
  end;
  aConfigFile.Free;
 // TabControl1.TabPosition := TTabPosition.None;
end;



procedure THeaderFooterForm.ImportContacts(aPhoneNumber:string);
begin
  sgcTelegram.TDLibSend('{"@type": "importContacts", "contacts": [{"phone_number": "'+aPhoneNumber+'"}]}');
end;

procedure THeaderFooterForm.ImportUser(aText: string);
var aJson,anUSer,profilePhoto,asmall:TJsonValue;
    aTelegramContact:TTelegramContact;
begin
  AGeneratorAdapterContact.Active := False;
  AGeneratorAdapterContact.Adapter.Active := False;
  aJson := TJSONObject.ParseJSONValue(aText);
  anUser := aJson.FindValue('user');  //.GetValue('user');
  aTelegramContact:=TTelegramContact.Create;
  aTelegramContact.UserID := StrToInt64(anUser.P['id'].Value);
  aTelegramContact.UserIDStr := anUser.P['id'].Value;
  aTelegramContact.UserName := anUser.P['username'].Value ;
  aTelegramContact.FirstName := anUser.P['first_name'].Value;
  aTelegramContact.LastName := anUser.P['last_name'].Value;
  profilePhoto :=  anUser.FindValue('profile_photo');
  if profilePhoto<>nil then
  begin
    asmall := profilePhoto.FindValue('small');
    if asmall<>nil then
    begin
      aTelegramContact.ProfilePhotoId := asmall.P['id'].Value;
      FFileIDFilePathDico.add(aTelegramContact.ProfilePhotoId,'');
      DownloadFile(aTelegramContact.ProfilePhotoId);
    end;
  end;
  aTelegramContact.ContactName := aTelegramContact.UserName;
  if aTelegramContact.ContactName<>'' then
  begin
    if Trim(aTelegramContact.GetCivility)<>'' then
      aTelegramContact.ContactName := aTelegramContact.ContactName +'( '+aTelegramContact.GetCivility+' )';
  end
  else
  begin
    aTelegramContact.ContactName := aTelegramContact.GetCivility;
  end;
  FContactList.Add(aTelegramContact);
  AGeneratorAdapterContact.Active := True;
  AGeneratorAdapterContact.Adapter.Active := True;
  TabControl1.ActiveTab := TabItemContacts;
end;


procedure THeaderFooterForm.ListViewContactsDblClick(Sender: TObject);
var anItem:TListViewItem;
    contactName:string;
    UserID:InT64;
    aFrame:TChatFrame;
begin
  if FPendingUserID='' then
  begin
    anItem := ListViewContacts.Selected as TListViewItem;
    UserID := StrTOInt64DEf(anItem.Detail,0);
    if FUserIDChatFrameDictionnary.TryGetValue(anItem.Detail,aFrame) then
    begin
      if aFrame<>nil then
      begin
        TabControl1.ActiveTab := aFrame.TabItemParent;
      end;
    end
    else
    begin
      contactName := anItem.Text;
      if UserID>0 then
      begin
        FPendingUserID := UserID.ToString;
        sgcTelegram.CreateNewBasicGroupChat([UserID],contactName);
      end;
    end;
  end;
end;

procedure THeaderFooterForm.RoundRect1Click(Sender: TObject);
begin
  TabControl1.ActiveTab := TabItemAddContact;
end;

procedure THeaderFooterForm.sgcTelegramAuthenticationCode(Sender: TObject;
  var Code: string);
begin
  Code := InputBox('Telegram Delphi','Please enter code','');
end;

procedure THeaderFooterForm.sgcTelegramAuthorizationStatus(Sender: TObject;
  const Status: string);
begin
  lblStatus.Text := Status;
  if Status = 'authorizationStateReady' then
  begin
    ImportContacts(''); //start the get of contcats
  end;
end;

procedure THeaderFooterForm.sgcTelegramEvent(Sender: TObject; const Event,
  Text: string);
var aUserList:TStringList;
    anuserId:integer;
begin
  MemoDebug.Lines.Add(Text);
  if Event ='importedContacts' then
  begin
     aUserList := ParseImportedContacts(Text);
     anuserId := strtointDef(aUserList[0],0);
     if anuserId>0 then
       sgcTelegram.GetUser(anuserId); //this method will raise a TDLib event updateUser
  end;

  if (Event = 'updateUser')  then
  begin
    ImportUser(Text);
  end;

  if (Event = 'updateFile')  then
  begin
    ParseUpdateFile(Text);
  end;

  if (Event ='file') then
  begin
    ParseFile(Text);
  end;

end;

procedure THeaderFooterForm.sgcTelegramException(Sender: TObject; E: Exception);
begin
  ShowMessage(E.Message);
end;

procedure THeaderFooterForm.sgcTelegramMessageText(Sender: TObject;
  MessageText: TsgcTelegramMessageText);
var achatFrame:TChatFrame;
    senderText:string;
begin
  FChatIDChatFrameDictionnary.TryGetValue(MessageText.ChatId,achatFrame);
  if achatFrame<>nil then
  begin
    senderText := '';
    if sgcTelegram.MyId <> MessageText.SenderUserId then
      senderText := inttostr(MessageText.SenderUserId);
    achatFrame.AddMessage(MessageText.Text,senderText);
  end;
end;

procedure THeaderFooterForm.sgcTelegramNewChat(Sender: TObject;
  Chat: TsgcTelegramChat);
var aTabItem:TTabItem;
    aChatFrame:TChatFrame;
begin
  aTabItem := TabControl1.Add;
  aTabItem.Text := Chat.Title;
  aChatFrame:=TChatFrame.Create(sgcTelegram, aTabItem,Chat.Title,Chat.ChatId);
  aChatFrame.Parent := aTabItem;
  if FPendingUserID<>'' then
    FUserIDChatFrameDictionnary.TryAdd(FPendingUserID,aChatFrame);
  FChatIDChatFrameDictionnary.TryAdd(Chat.ChatId,aChatFrame);
  FPendingUserID :='';
  TabControl1.ActiveTab := aTabItem;
end;

procedure THeaderFooterForm.TabItemAddContactClick(Sender: TObject);
begin

end;

{ TTelegramContact }

constructor TTelegramContact.Create;
begin
  Avatar := TBitmap.Create;
end;

function TTelegramContact.GetCivility: string;
begin
  Result := FirstName +' '+LastName;
end;

end.
