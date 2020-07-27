program TestActiveDirectory;

uses
  Vcl.Forms,
  TestActiveDirectory.View.Main in '..\src\TestActiveDirectory.View.Main.pas' {frmMain};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Test Active Directory';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
