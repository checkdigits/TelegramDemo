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
  FMX.Objects;

type
  TTelegramContact = class(TObject)
  public
    ContactName:string;
    Avatar : TBitmap;
end;

type
  THeaderFooterForm = class(TForm)
    Header: TToolBar;
    Footer: TToolBar;
    HeaderLabel: TLabel;
    TabControl1: TTabControl;
    TabItemContacts: TTabItem;
    TabItem2: TTabItem;
    lblHeaderContact: TLabel;
    ListViewContacts: TListView;
    DataGeneratorAdapterContact: TDataGeneratorAdapter;
    AdapterBindSourceContact: TAdapterBindSource;
    BindingsList1: TBindingsList;
    LinkFillControlToField1: TLinkFillControlToField;
    RoundRect1: TRoundRect;
    procedure AdapterBindSourceContactCreateAdapter(Sender: TObject;
      var ABindSourceAdapter: TBindSourceAdapter);
  private
    { Private declarations }
    FContactList : TList<TTelegramContact>;
    procedure InitContacts;
  public
    { Public declarations }
  end;

var
  HeaderFooterForm: THeaderFooterForm;

implementation

{$R *.fmx}

procedure THeaderFooterForm.AdapterBindSourceContactCreateAdapter(
  Sender: TObject; var ABindSourceAdapter: TBindSourceAdapter);
begin
  FContactList := TList<TTelegramContact>.Create;
  ABindSourceAdapter := TListBindSourceAdapter<TTelegramContact>.Create(Self,FContactList,True);
  InitContacts;
end;

procedure THeaderFooterForm.InitContacts;
var aContact: TTelegramContact;
begin
  aContact:= TTelegramContact.Create;
  aContact.ContactName := 'John Doe';
  FContactList.Add(aContact);

  aContact:= TTelegramContact.Create;
  aContact.ContactName := 'Lisa Parker';
  FContactList.Add(aContact);

  aContact:= TTelegramContact.Create;
  aContact.ContactName := 'Val Smith';
  FContactList.Add(aContact);
end;

end.
