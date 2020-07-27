unit TestActiveDirectory.View.Main;

interface

uses
  ActiveDirectory.Types,

  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ActnList,
  Vcl.Menus, Vcl.StdActns, System.Actions;

type
  TfrmMain = class(TForm)
    pnlPrinc: TPanel;
    edtLog: TMemo;
    btnGetCurrentInfo: TButton;
    pnlCustomAuth: TPanel;
    edtDomain: TLabeledEdit;
    edtUserName: TLabeledEdit;
    edtUserPass: TLabeledEdit;
    btnAuthenticate: TButton;
    pnlBtnsLog: TPanel;
    btnCopyLog: TButton;
    btnClearLog: TButton;
    btnGetUserInfo: TButton;
    PopupMenu: TPopupMenu;
    Copy1: TMenuItem;
    SelectAll1: TMenuItem;
    ActionList: TActionList;
    EditCopy1: TEditCopy;
    EditSelectAll1: TEditSelectAll;
    chkbxShowPassword: TCheckBox;
    procedure btnGetCurrentInfoClick(Sender: TObject);
    procedure btnAuthenticateClick(Sender: TObject);
    procedure edtUserPassChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnClearLogClick(Sender: TObject);
    procedure btnGetUserInfoClick(Sender: TObject);
    procedure btnCopyLogClick(Sender: TObject);
    procedure chkbxShowPasswordClick(Sender: TObject);
  private
    { Private declarations }
    procedure RefreshEnabledAuthenticate;
    procedure RefreshShowPassword;
    function GetMsgErrorLog(E: Exception): string;
    function GetPasswordLog: string;

  protected
    procedure AddLog(inMsg: string);
    procedure AddLogError(E: Exception);
    procedure AddLogUserInfo(inUserInfo: TADSIUserInfo);

    procedure AddLogSession(inSender: TObject; inMethod: TProc);
    function AddLogValueTry(inName: string; inMethodGetValue: TFunc<string>): Boolean;
    procedure AddLogValueAbortOnFail(inName: string; inMethodGetValue: TFunc<string>);

  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  ActiveDirectory.Client;

{$R *.dfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Self.RefreshEnabledAuthenticate;
  Self.RefreshShowPassword;
end;

procedure TfrmMain.btnCopyLogClick(Sender: TObject);
begin
  edtLog.SelectAll;
  edtLog.CopyToClipboard;
end;

procedure TfrmMain.btnClearLogClick(Sender: TObject);
begin
  edtLog.Lines.Clear;
end;

procedure TfrmMain.chkbxShowPasswordClick(Sender: TObject);
begin
  Self.RefreshShowPassword;
end;

procedure TfrmMain.edtUserPassChange(Sender: TObject);
begin
  Self.RefreshEnabledAuthenticate;
end;

procedure TfrmMain.RefreshEnabledAuthenticate;
var
  ValidN1, ValidN2: Boolean;
begin
  ValidN1 := (Trim(edtDomain.Text) <> '') and (Trim(edtUserName.Text) <> '');
  ValidN2 := (ValidN1) and (Trim(edtUserPass.Text) <> '');

  btnGetUserInfo.Enabled := ValidN1;
  btnAuthenticate.Enabled := ValidN2;
end;

procedure TfrmMain.RefreshShowPassword;
begin
  if chkbxShowPassword.Checked then
    edtUserPass.PasswordChar := #0
  else
    edtUserPass.PasswordChar := '*';
end;

function TfrmMain.GetMsgErrorLog(E: Exception): string;
begin
  Result := 'Error.Class: ' + Trim(E.ClassName) + ' | ' + 'Error.Message: ' + Trim(E.Message)
end;

function TfrmMain.GetPasswordLog: string;
begin
  if (chkbxShowPassword.Checked) then
    Result := edtUserPass.Text
  else
    Result := StringOfChar('*', Length(edtUserPass.Text));
end;

procedure TfrmMain.AddLog(inMsg: string);
begin
  edtLog.Lines.Add(inMsg);
end;

procedure TfrmMain.AddLogError(E: Exception);
begin
  Self.AddLog('ERROR = ' + Self.GetMsgErrorLog(E));
end;

procedure TfrmMain.AddLogUserInfo(inUserInfo: TADSIUserInfo);
begin
  Self.AddLog('UserInfo.UID = ' + inUserInfo.UID);
  Self.AddLog('UserInfo.UserName = ' + inUserInfo.UserName);
  Self.AddLog('UserInfo.Description = ' + inUserInfo.Description);
  Self.AddLog('UserInfo.Password.Expired = ' + BoolToStr(inUserInfo.Password.Expired, True));
  Self.AddLog('UserInfo.Password.NeverExpires = ' + BoolToStr(inUserInfo.Password.NeverExpires, True));
  Self.AddLog('UserInfo.Password.CannotChange = ' + BoolToStr(inUserInfo.Password.CannotChange, True));
  Self.AddLog('UserInfo.Disabled = ' + BoolToStr(inUserInfo.Disabled, True));
  Self.AddLog('UserInfo.LockedOut = ' + BoolToStr(inUserInfo.LockedOut, True));
  Self.AddLog('UserInfo.Groups = ' + inUserInfo.Groups);
end;

procedure TfrmMain.AddLogSession(inSender: TObject; inMethod: TProc);
var
  Button: TButton;
begin
  try
    Button := (inSender as TButton);

    Button.Enabled := False;
    try
      Self.AddLog('[ ' + Button.Caption + ' ]');

      if Assigned(inMethod) then
        inMethod;

      Self.AddLog('');
    finally
      Button.Enabled := True;
    end;
  except
    on E: Exception do
    begin
      if (not (E is EAbort)) then
        Self.AddLogError(E);
    end;
  end;
end;

function TfrmMain.AddLogValueTry(inName: string; inMethodGetValue: TFunc<string>): Boolean;
var
  Value: string;
begin
  Value := '';
  try
    try
      Value := inMethodGetValue;
      Result := True;
    except
      on E: Exception do
      begin
        Value := Self.GetMsgErrorLog(E);
        Result := False;
      end;
    end;
  finally
    Self.AddLog(inName + ' = ' + Value);
  end;
end;

procedure TfrmMain.AddLogValueAbortOnFail(inName: string; inMethodGetValue: TFunc<string>);
begin
  if (not Self.AddLogValueTry(inName, inMethodGetValue)) then
    Abort;
end;

procedure TfrmMain.btnGetCurrentInfoClick(Sender: TObject);
begin
  Self.AddLogSession(
    Sender,
    procedure
    var
      CurrentUserName: string;
      CurrentDomainName: string;
      CurrentLDAPDomainName: string;
      AllProviders: string;
    begin
      {$REGION 'AllProviders'}
      Self.AddLogValueTry(
        'AllProviders',
        function: string
        begin
          Result := ActiveDirectoryClient.GetAllProviders;
          AllProviders := Result;
        end
      );
      {$ENDREGION}

      {$REGION 'CurrentUserName'}
      Self.AddLogValueAbortOnFail(
        'CurrentUserName',
        function: string
        begin
          Result := ActiveDirectoryClient.GetCurrentUserName;
          CurrentUserName := Result;
        end
      );

      edtUserName.Text := CurrentUserName;
      {$ENDREGION}

      {$REGION 'CurrentDomainName'}
      Self.AddLogValueAbortOnFail(
        'CurrentDomainName',
        function: string
        begin
          Result := ActiveDirectoryClient.GetCurrentDomainName(CurrentUserName);
          CurrentDomainName := Result;
        end
      );

      edtDomain.Text := CurrentDomainName;
      {$ENDREGION}

      {$REGION 'CurrentLDAPDomainName'}
      Self.AddLogValueTry(
        'CurrentLDAPDomainName',
        function: string
        begin
          Result := ActiveDirectoryClient.GetCurrentLDAPDomainName(CurrentDomainName);
          CurrentLDAPDomainName := Result;
        end
      );
      {$ENDREGION}

      {$REGION 'ActiveDirectoryEnabled'}
      Self.AddLogValueTry(
        'ActiveDirectoryEnabled',
        function: string
        var
          Resultado: Boolean;
        begin
          Resultado := ActiveDirectoryClient.GetActiveDirectoryEnabled;
          Result := BoolToStr(Resultado, True);
          CurrentDomainName := Result;
        end
      );
      {$ENDREGION}
    end
  );
end;

procedure TfrmMain.btnGetUserInfoClick(Sender: TObject);
begin
  Self.AddLogSession(
    Sender,
    procedure
    var
      UserInfo: TADSIUserInfo;
    begin
      Self.AddLog('Param.Domain = ' + edtDomain.Text);
      Self.AddLog('Param.UserName = ' + edtUserName.Text);

      {$REGION 'UserFind'}
      Self.AddLogValueAbortOnFail(
        'UserFind',
        function: string
        var
          Resultado: Boolean;
        begin
          Resultado := ActiveDirectoryClient.GetUserInfo(edtDomain.Text, edtUserName.Text, UserInfo);
          Result := BoolToStr(Resultado, True);
        end
      );
      {$ENDREGION}

      {$REGION 'UserActive'}
      Self.AddLogValueTry(
        'UserActive',
        function: string
        var
          Resultado: Boolean;
        begin
          Resultado := ActiveDirectoryClient.GetUserActive(edtDomain.Text, edtUserName.Text);
          Result := BoolToStr(Resultado, True);
        end
      );
      {$ENDREGION}

      Self.AddLogUserInfo(UserInfo);
    end
  );
end;

procedure TfrmMain.btnAuthenticateClick(Sender: TObject);
begin
  Self.AddLogSession(
    Sender,
    procedure
    begin
      Self.AddLog('Param.Domain = ' + edtDomain.Text);
      Self.AddLog('Param.UserName = ' + edtUserName.Text);
      Self.AddLog('Param.UserPass = ' + Self.GetPasswordLog);

      {$REGION 'Authenticated'}
      Self.AddLogValueTry(
        'Authenticated',
        function: string
        var
          Resultado: Boolean;
        begin
          Resultado := ActiveDirectoryClient.AuthenticateUser(edtDomain.Text, edtUserName.Text, edtUserPass.Text);
          Result := BoolToStr(Resultado, True);
        end
      );
      {$ENDREGION}
    end
  );
end;

end.
