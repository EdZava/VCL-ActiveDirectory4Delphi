unit ActiveDirectory.Client.Intf;

interface

uses
  ActiveDirectory.Types;

type
  IActiveDirectoryClient = interface
    ['{9F8FCA96-35A7-4B36-8406-0CAD9CF6ADED}']
    function GetCurrentUserName: string;
    function GetCurrentDomainName(inUserName: string): string;
    function GetCurrentLDAPDomainName(inDomainName: string): string;
    function GetAllProviders: string; // CSV (LDAP, WinNT, ...)
    function GetActiveDirectoryEnabled: Boolean;

    function GetUserInfo(inDomainName, inUserName: string; out outUserInfo: TADSIUserInfo): Boolean;
    function GetUserActive(inDomainName, inUserName: string): Boolean;

    function AuthenticateUser(inDomainName, inUserName, inUserPass: string): Boolean;
  end;

implementation

end.
