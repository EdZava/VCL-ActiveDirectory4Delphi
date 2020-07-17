unit Common.ActiveDirectory.Utils;

interface

uses
  Common.ActiveDirectory.Types;

type
  { Class responsible for integration with Active Directory }
  TActiveDirectoryUtils = class
  private
    class var FUserInfoEmpty: TADSIUserInfo;
    class procedure ClearUserInfo(var inUserInfo: TADSIUserInfo);

  protected
    class function GetPathLDAP(inDomainName: string): string;
    class function GetPathWinNT(inDomainName: string): string;
    class function GetActiveLDAPDomainName: string;

  public
    class function GetCurrentUserName: string;
    class function GetCurrentDomainName(inUserName: string): string;
    class function GetCurrentLDAPDomainName(inDomainName: string): string;
    class function GetAllProviders: string; // CSV (LDAP, WinNT, ...)
    class function GetActiveDirectoryEnabled: Boolean;

    class function GetUserInfo(inDomainName, inUserName: string; out outUserInfo: TADSIUserInfo): Boolean;
    class function GetUserActive(inDomainName, inUserName: string): Boolean;

    class function AuthenticateUser(inDomainName, inUserName, inUserPass: string): Boolean;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.ActiveX,

  Common.ActiveDirectory.Winapi.DllMapper, // <-- Generate by mapping dlls ADSI
  Common.ActiveDirectory.Winapi.TLB;       // <-- Generate by "Import Type Library" from "c:\windows\system32\activeds.tlb" (Active DS Type Library)

const
  _ProviderAD_LDAP      = 'LDAP:';
  _ProviderAD_WinNT     = 'WinNT:';
  _ProviderAD_PathBegin = '//';
  _ProviderAD_PathDelim = '/';
  _CSV_Sep              = ',';

  { TActiveDirectoryUtils }

class procedure TActiveDirectoryUtils.ClearUserInfo(var inUserInfo: TADSIUserInfo);
begin
  inUserInfo := Self.FUserInfoEmpty;
end;

class function TActiveDirectoryUtils.GetPathLDAP(inDomainName: string): string;
begin
  Result := _ProviderAD_LDAP + _ProviderAD_PathBegin + Trim(inDomainName);
end;

class function TActiveDirectoryUtils.GetPathWinNT(inDomainName: string): string;
begin
  Result := _ProviderAD_WinNT + _ProviderAD_PathBegin + Trim(inDomainName);
end;

class function TActiveDirectoryUtils.GetActiveLDAPDomainName: string;
var
  UserName: string;
  DomainName: string;
begin
  UserName := Self.GetCurrentUserName;
  DomainName := Self.GetCurrentDomainName(UserName);
  Result := Self.GetCurrentLDAPDomainName(DomainName);
end;

class function TActiveDirectoryUtils.GetCurrentUserName: string;
const
  cnMaxUserNameLen = 254;
var
  UserName: string;
  dwUserNameLen: DWord;
begin
  dwUserNameLen := cnMaxUserNameLen - 1;
  SetLength(UserName, cnMaxUserNameLen);
  GetUserName(PChar(UserName), dwUserNameLen);
  SetLength(UserName, dwUserNameLen);
  Result := UserName;
end;

class function TActiveDirectoryUtils.GetCurrentDomainName(inUserName: string): string;
const
  DNLEN = 255;
var
  SId: PSID;
  SIdSize: DWord;
  SIdNameUse: DWord;
  DomainNameSize: DWord;
  DomainName: array [0 .. DNLEN] of char;
begin
  Result := '';

  SIdSize := 65536;
  GetMem(SId, SIdSize);
  try
    DomainNameSize := DNLEN + 1;
    SIdNameUse := SidTypeUser;

    if LookupAccountName(nil, PChar(inUserName), SId, SIdSize, DomainName, DomainNameSize, SIdNameUse) then
      Result := StrPas(DomainName);
  finally
    FreeMem(SId);
  end;
end;

class function TActiveDirectoryUtils.GetCurrentLDAPDomainName(inDomainName: string): string;
var
  Path: string;
  Resultado: HRESULT;
  AD: IADs;
begin
  Path := Self.GetPathLDAP(inDomainName);
  Resultado := ADsGetObject(Path, IADs, AD);

  if (Failed(Resultado)) then
  begin
    Result := '';
    Exit;
  end;

  Result := AD.Get('distinguishedName');
end;

class function TActiveDirectoryUtils.GetAllProviders: string;
var
  NSContainer: IADsContainer;
  Item: IADs;
  Enum: IEnumVariant;
  Resultado: HRESULT;
  varArray: OleVariant;
  NumElements: ULONG;
  Value: string;
  Lista: TStringList;
begin
  Lista := TStringList.Create;
  try
    NSContainer := nil;
    ADsGetObject('ADs:', IADsContainer, NSContainer);

    Enum := nil;
    Resultado := ADsBuildEnumerator(NSContainer, Enum);

    while SUCCEEDED(Resultado) do
    begin
      Resultado := ADsEnumerateNext(Enum, 1, varArray, NumElements);

      if (NumElements <= 0) then
        Break;

      IDispatch(varArray).QueryInterface(IADs, Item);
      Value := Item.ADsPath;

      // Add
      Lista.Add(Value);
    end;

    Lista.Delimiter := _CSV_Sep;
    Result := Lista.DelimitedText;
  finally
    FreeAndNil(Lista);
  end;
end;

class function TActiveDirectoryUtils.GetActiveDirectoryEnabled: Boolean;
var
  LDAPDomain: string;
  Providers: string;
begin
  try
    LDAPDomain := Self.GetActiveLDAPDomainName;
    Providers := Self.GetAllProviders;

    if (Trim(LDAPDomain) <> '') and (Pos(_ProviderAD_LDAP, Providers) > -1) then
      Result := True
    else
      Result := False;
  except
    Result := False;
  end;
end;

class function TActiveDirectoryUtils.GetUserInfo(inDomainName, inUserName: string; out outUserInfo: TADSIUserInfo): Boolean;
var
  Path: string;
  Resultado: HRESULT;
  User: IAdsUser;
  Groups: IAdsMembers;
  Group: IAdsGroup;
  Enum: IEnumVariant;
  varGroup: OleVariant;
  UserFlags: Integer;
  Temp: LongWord;
begin
  Result := False;
  Self.ClearUserInfo(outUserInfo);

  if (Trim(inDomainName) = '') then
    Exit;

  if (Trim(inUserName) = '') then
    Exit;

  Path := Self.GetPathWinNT(inDomainName) + _ProviderAD_PathDelim + inUserName;
  Resultado := ADsGetObject(Path, IAdsUser, User);

  if (Failed(Resultado)) or (User = nil) then
    Exit;

  // Get user info
  UserFlags := User.Get('userFlags');

  outUserInfo.UID := inUserName;
  outUserInfo.UserName := User.FullName;
  outUserInfo.Description := User.Description;
  outUserInfo.Password.Expired := User.Get('PasswordExpired');
  outUserInfo.Password.CannotChange := (UserFlags and ADS_UF_PASSWD_CANT_CHANGE) <> 0;
  outUserInfo.Password.NeverExpires := (UserFlags and ADS_UF_DONT_EXPIRE_PASSWD) <> 0;
  outUserInfo.Disabled := User.AccountDisabled;
  outUserInfo.LockedOut := User.IsAccountLocked;

  // Get all groups by user in CSV (group1, group2, ...)
  outUserInfo.Groups := '';

  Groups := User.Groups;
  Enum := (Groups._NewEnum as IEnumVariant);

  if (Enum <> nil) then
  begin
    while (Enum.Next(1, varGroup, Temp) = S_OK) do
    begin
      Group := (IDispatch(varGroup) as IAdsGroup);

      if (outUserInfo.Groups <> '') then
        outUserInfo.Groups := outUserInfo.Groups + _CSV_Sep;

      outUserInfo.Groups := outUserInfo.Groups + Group.Name;

      VariantClear(varGroup);
    end;
  end;

  User := nil;
  Result := True;
end;

class function TActiveDirectoryUtils.GetUserActive(inDomainName, inUserName: string): Boolean;
var
  UserInfo: TADSIUserInfo;
  UserFind: Boolean;
begin
  Result := False;

  UserFind := Self.GetUserInfo(inDomainName, inUserName, UserInfo);

  if (not UserFind) then // User not found
    Exit;

  if (UserInfo.Disabled) then // User disabled
    Exit;

  if (UserInfo.LockedOut) then // User lockedout
    Exit;

  Result := True;
end;

class function TActiveDirectoryUtils.AuthenticateUser(inDomainName, inUserName, inUserPass: string): Boolean;
var
  Path: string;
  Resultado: HRESULT;
  Obj: IADs;
begin
  Result := False;

  if (Trim(inDomainName) = '') then
    Exit;

  if (Trim(inUserName) = '') then
    Exit;

  Path := Self.GetPathLDAP(inDomainName);
  Resultado := ADsOpenObject(Path, inUserName, inUserPass, ADS_SECURE_AUTHENTICATION, IADs, Obj);

  if (Failed(Resultado)) or (Obj = nil) then
    Exit;

  Obj := nil;
  Result := True;
end;

end.
