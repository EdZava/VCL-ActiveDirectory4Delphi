program VCLActiveDirectory;

uses
  Vcl.Forms,
  ActiveDirectory.View.Main in '..\src\ActiveDirectory.View.Main.pas' {frmMain},
  Common.ActiveDirectory.Winapi.TLB in '..\src\Common\Common.ActiveDirectory.Winapi.TLB.pas',
  Common.ActiveDirectory.Winapi.DllMapper in '..\src\Common\Common.ActiveDirectory.Winapi.DllMapper.pas',
  Common.ActiveDirectory.Types in '..\src\Common\Common.ActiveDirectory.Types.pas',
  Common.ActiveDirectory.Utils in '..\src\Common\Common.ActiveDirectory.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Test Active Directory';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
