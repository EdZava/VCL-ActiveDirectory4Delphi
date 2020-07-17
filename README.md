<p align="center">
  <img width="200" align="center" src="./resources/login.svg" alt="demo"/>
</p>

# ActiveDirectory4Delphi 

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg?cacheSeconds=2592000)
[![Twitter: ZavaDev](https://img.shields.io/twitter/follow/ZavaDev.svg?style=social)](https://twitter.com/ZavaDev)

Delphi library (Basic) for validation and authentication of LDAP users in Active Directory

> It also has an application to test the library with Active Directory.

## ✨ [App Demo](www.demo.com)


## Example Usage

```delphi
uses
  Common.ActiveDirectory.Utils;

...
// example authenticate current user
procedure Authenticate(UserPass: string);
var
  CurrentUserName: string;
  CurrentDomainName: string;
  CurrentLDAPDomainName: string;
begin
  if (not TActiveDirectoryUtils.GetActiveDirectoryEnabled) then
    Exit;

  CurrentUserName := TActiveDirectoryUtils.GetCurrentUserName;
  CurrentDomainName := TActiveDirectoryUtils.GetCurrentDomainName(CurrentUserName);  
  CurrentLDAPDomainName := TActiveDirectoryUtils.GetCurrentLDAPDomainName(CurrentDomainName);  

  if TActiveDirectoryUtils.AuthenticateUser(CurrentLDAPDomainName, CurrentUserName, UserPass) then
    ShowMessage('ok')
  else
    ShowMessage('Fail');
end;

// example validation user
procedure ValidationUserActive(DomainName, UserName: string);
begin
  if TActiveDirectoryUtils.GetUserActive(DomainName, UserName) then
    ShowMessage('ok')
  else
    ShowMessage('Fail');
end;
```

## Author

👤 **Zava**

* Twitter: [@ZavaDev](https://twitter.com/ZavaDev)

## Show your support

Give a ⭐️ if this project helped you!