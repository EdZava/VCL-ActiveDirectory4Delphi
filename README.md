<p align="center">
  <img width="200" align="center" src="./resources/login.svg" alt="demo"/>
</p>

# ActiveDirectory4Delphi

Delphi basic library for validation and authentication of LDAP users in Active Directory.

![release](https://img.shields.io/github/v/release/EdZava/VCL-ActiveDirectory4Delphi?style=flat-square)
![Delphi Supported Versions](https://img.shields.io/badge/Delphi%20Supported%20Versions-XE7%20and%20ever-blue.svg)
![Platforms](https://img.shields.io/badge/Supported%20platforms-Win32%20and%20Win64-red.svg)
[![Twitter: ZavaDev](https://img.shields.io/twitter/follow/ZavaDev.svg?style=social)](https://twitter.com/ZavaDev)

## ⚙️ Installation

* **Manual installation**: Add the following folders to your project, in *Project > Options > Resource Compiler > Directories and Conditionals > Include file search path*

```
../VCL-ActiveDirectory4Delphi/src/Core
../VCL-ActiveDirectory4Delphi/src/Interfaces
../VCL-ActiveDirectory4Delphi/src/Winapi
```

## ⚡️ Quickstart

You need to use **ActiveDirectory.Client**

```pascal
uses ActiveDirectory.Client;
```

* **Authenticate current user**

```pascal
procedure Authenticate(UserPass: string);
var
  CurrentUserName: string;
  CurrentDomainName: string;
  CurrentLDAPDomainName: string;
begin
  if (not ActiveDirectoryClient.GetActiveDirectoryEnabled) then
    Exit;

  CurrentUserName := ActiveDirectoryClient.GetCurrentUserName;
  CurrentDomainName := ActiveDirectoryClient.GetCurrentDomainName(CurrentUserName);  
  CurrentLDAPDomainName := ActiveDirectoryClient.GetCurrentLDAPDomainName(CurrentDomainName);  

  if ActiveDirectoryClient.AuthenticateUser(CurrentLDAPDomainName, CurrentUserName, UserPass) then
    ShowMessage('ok')
  else
    ShowMessage('Fail');
end;
```

* **Validation user active**

```pascal
procedure ValidationUserActive(DomainName, UserName: string);
begin
  if ActiveDirectoryClient.GetUserActive(DomainName, UserName) then
    ShowMessage('ok')
  else
    ShowMessage('Fail');
end;
```

more information look at the unit [ActiveDirectory.Client](./src/Core/ActiveDirectory.Client.pas)

## ✨ App demo using library

![Download](https://img.shields.io/github/downloads/EdZava/VCL-ActiveDirectory4Delphi/latest/total)
![Release](https://img.shields.io/github/v/release/EdZava/VCL-ActiveDirectory4Delphi)

Application of example of using the library and information that could be recovered.

<p align="center">
  <img width="900" align="center" src="./resources/screen-main.png" alt="demo"/>
</p>

### Get Current Info 

Retrieve the information of the current section.

```log
AllProviders = WinNT:,LDAP:
CurrentUserName = usuario1
CurrentDomainName = MYDOMAIN
CurrentLDAPDomainName = DC=MYDOMAIN,DC=TEST
ActiveDirectoryEnabled = True
```

### Get User Info

Retrieve user information using the domain and user indicated in the text boxes.

```log
Param.Domain = MYDOMAIN
Param.UserName = usuario1
UserFind = True
UserActive = True
UserInfo.UID = usuario1
UserInfo.UserName = usuario1
UserInfo.Description = Descripcion del usuario 1
UserInfo.Password.Expired = False
UserInfo.Password.NeverExpires = False
UserInfo.Password.CannotChange = False
UserInfo.Disabled = False
UserInfo.LockedOut = False
UserInfo.Groups = gusuarios,Usuarios del dominio
```

### Authenticate

Authenticate using the domain and user indicated in the text boxes.

```log
Param.Domain = MYDOMAIN
Param.UserName = usuario1
Param.UserPass = *********
Authenticated = True
```

## Author

👤 **Zava**

* Twitter: [@ZavaDev](https://twitter.com/ZavaDev)

## Show your support

Give a ⭐️ if this project helped you!
