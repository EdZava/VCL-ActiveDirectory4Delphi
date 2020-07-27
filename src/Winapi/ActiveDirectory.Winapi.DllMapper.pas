unit ActiveDirectory.Winapi.DllMapper;

interface

uses
  System.SysUtils,
  System.Variants,
  Winapi.Windows,
  Winapi.ActiveX,

  ActiveDirectory.Winapi.TLB;

const
  S_ADS_NOMORE_ROWS  = $00005012;
  MAX_ADS_ENUM_COUNT = 100;

type
  { Helpers }

  TADsEnumCallBack = procedure(disp: IADs) of object;

  function GetObject(Path: string): IDispatch;
  procedure ADsEnumerateObjects(const Path: string; Func: TADsEnumCallBack); overload;
  procedure ADsEnumerateObjects(Container: IADsContainer; Func: TADsEnumCallBack); overload;
  procedure ADsEnumerateMembers(Members: IADsMembers; Func: TADsEnumCallBack);

  { Mapers API ADSI }

  function ADsGetObject(lpszPathName: WideString; const riid: TGUID; out ppObject): HRESULT; safecall;

  function ADsBuildEnumerator(const pADsContainer: IADsContainer; out ppEnumVariant: IEnumVARIANT): HRESULT; safecall;

  function ADsFreeEnumerator(pEnumVariant: IEnumVARIANT): HRESULT; safecall;
  function ADsEnumerateNext(pEnumVariant: IEnumVARIANT;
    cElements: ULONG;
    var pvar: OleVARIANT;
    var pcElementsFetched: ULONG): HRESULT; safecall;

  function ADsBuildVarArrayStr(lppPathNames: PWideChar;
    dwPathNames: DWORD;
    var pvar: VARIANT): HRESULT; safecall;

  function ADsBuildVarArrayInt(lpdwObjectTypes: LPDWORD;
    dwObjectTypes: DWORD;
    var pvar: VARIANT): HRESULT; safecall;

  function ADsOpenObject(lpszPathName: WideString;
    lpszUserName: WideString;
    lpszPassword: WideString;
    dwReserved: DWORD;
    const riid: TGUID;
    out ppObject): HRESULT; safecall;

  function ADsGetLastError(var pError: DWORD;
    lpErrorBuf: PWideChar;
    dwErrorBufLen: DWORD;
    lpNameBuf: PWideChar;
    dwNameBufLen: DWORD): HRESULT; stdcall;

  procedure ADsSetLastError(dwErr: DWORD; pszErro, pszProvider: LPWSTR); stdcall;

  procedure AllocADsMem(cb: DWORD); stdcall;

  function FreeADsMem(pMem: Pointer): BOOL; stdcall;

  function ReallocADsMem(pOldMem: Pointer; cbOld, cbNew: DWORD): Pointer; stdcall;

  function AllocADsStr(pStr: LPWSTR): LPWSTR; stdcall;

  function FreeADsStr(pStr: LPWSTR): BOOL; stdcall;

  function ReallocADsStr(ppStr: LPWSTR; pStr: LPWSTR): BOOL; stdcall;

  function ADsEncodeBinaryData(pbSrcData: PBYTE; dwSrcLen: DWORD; ppszDestData: LPWSTR): HRESULT; stdcall;

  function PropVariantToAdsType(pVariant: VARIANT;
    dwNumVariant: DWORD;
    ppAdsValues: Pointer;
    pdwNumValues: PDWORD
    ): HRESULT; stdcall;

  function AdsTypeToPropVariant(
    pAdsValues: Pointer;
    dwNumValues: DWORD;
    pVariant: VARIANT
    ): HRESULT; stdcall;

  procedure AdsFreeAdsValues(pAdsValues: Pointer; dwNumValues: DWORD); stdcall;

implementation

const
  ADSI    = 'activeds.dll';
  ADSLDPC = 'adsldpc.dll';

function GetObject(Path: string): IDispatch;
begin
  ADsGetObject(Path, IDispatch, Result);
end;

procedure ADsEnumerateObjects(Container: IADsContainer; Func: TADsEnumCallBack);
var
  e: IEnumVARIANT;
  varArr: OleVARIANT;
  lNumElements: ULONG;
  obj: IADs;
  hr: integer;
begin
  hr := ADsBuildEnumerator(Container, e);
  while (Succeeded(hr)) do
  begin
    hr := ADsEnumerateNext(e, 1,
      varArr, lNumElements);

    if (lNumElements = 0) then
      break;

    IDispatch(varArr).QueryInterface(IADs, obj);
    if obj <> nil then
    begin
      Func(obj);
    end;
    varArr := NULL;
  end;
end;

procedure ADsEnumerateObjects(const Path: string; Func: TADsEnumCallBack);
var
  x: IADsContainer;
begin
  try
    ADsGetObject(Path, IADsContainer, x);
  except
    raise Exception.Create('IADsContainer not supported');
  end;
  ADsEnumerateObjects(x, Func);
end;

procedure ADsEnumerateMembers(Members: IADsMembers; Func: TADsEnumCallBack);
var
  e: IEnumVARIANT;
  varArr: OleVARIANT;
  lNumElements: ULONG;
  obj: IADs;
  hr: integer;
begin
  hr := S_OK;
  e := Members._NewEnum as IEnumVARIANT;
  while (Succeeded(hr)) do
  begin
    hr := ADsEnumerateNext(e, 1,
      varArr, lNumElements);

    if (lNumElements = 0) then
      break;

    IDispatch(varArr).QueryInterface(IADs, obj);
    if obj <> nil then
    begin
      Func(obj);
    end;
    varArr := NULL;
  end;
end;

function ADsGetObject; external ADSI;
function ADsBuildEnumerator; external ADSI;
function ADsEnumerateNext; external ADSI;
function ADsFreeEnumerator; external ADSI;
function ADsBuildVarArrayStr; external ADSI;
function ADsBuildVarArrayInt; external ADSI;
function ADsOpenObject; external ADSI;
function PropVariantToAdsType; external ADSI;
function AdsTypeToPropVariant; external ADSI;
procedure AdsFreeAdsValues; external ADSI;

function ADsGetLastError; external ADSLDPC name 'ADsGetLastError';
procedure ADsSetLastError; external ADSLDPC name 'ADsSetLastError';
procedure AllocADsMem; external ADSLDPC name 'AllocADsMem';
function FreeADsMem; external ADSLDPC name 'FreeADsMem';
function ReallocADsMem; external ADSLDPC name 'ReallocADsMem';
function AllocADsStr; external ADSLDPC name 'AllocADsStr';
function FreeADsStr; external ADSLDPC name 'FreeADsStr';
function ReallocADsStr; external ADSLDPC name 'ReallocADsStr';
function ADsEncodeBinaryData; external ADSLDPC name 'ADsEncodeBinaryData';

end.
