program Add2File;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  Add2FileUtils in 'Add2FileUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Add 2 File';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
