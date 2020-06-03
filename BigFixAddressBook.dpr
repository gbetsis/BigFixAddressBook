program BigFixAddressBook;

uses
  Vcl.Forms,
  untMain in 'untMain.pas' {frmMain},
  untAddWorkstation in 'untAddWorkstation.pas' {frmAddWorkstation},
  untAddDepartment in 'untAddDepartment.pas' {frmAddDepartment},
  untPing in 'untPing.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
