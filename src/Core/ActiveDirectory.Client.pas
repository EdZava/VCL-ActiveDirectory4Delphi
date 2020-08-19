unit ActiveDirectory.Client;

interface

uses
  ActiveDirectory.Client.Intf;

  { Singleton }
  function ActiveDirectoryClient: IActiveDirectoryClient;

implementation

uses
  ActiveDirectory.Client.Winapi;

var
  FActiveDirectoryClient: IActiveDirectoryClient = nil;

function ActiveDirectoryClient: IActiveDirectoryClient;
begin
  if (not Assigned(FActiveDirectoryClient)) then
    FActiveDirectoryClient := TActiveDirectoryClientWinapi.New;

  Result := FActiveDirectoryClient;
end;

end.
