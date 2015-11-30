program TestReputation;

uses
  Vcl.Forms,
  trMainForm in 'trMainForm.pas' {MainForm},
  trUser in 'trUser.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
