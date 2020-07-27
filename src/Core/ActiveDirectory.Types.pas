unit ActiveDirectory.Types;

interface

type
  { Password by ADSI }
  TADSIPassword = record
    Expired: Boolean;
    NeverExpires: Boolean;
    CannotChange: Boolean;
  end;

  { User by ADSI }
  TADSIUserInfo = record
    UID: string;
    UserName: string;
    Description: string;
    Password: TADSIPassword;
    Disabled: Boolean;
    LockedOut: Boolean;
    Groups: string; // CSV (group1, group2, ...)
  end;

implementation

end.
