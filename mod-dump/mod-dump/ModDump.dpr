program ModDump;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  mteHelpers,
  mdConfiguration in 'mdConfiguration.pas';

var
  ProgramPath, ProgramVersion, TargetPlugin, TargetGame: string;

{ HELPER METHODS }

procedure Welcome;
begin
  ProgramVersion := GetVersionMem;
  Writeln('ModDump v', ProgramVersion);
end;

procedure LoadParams;
var
  sParam: string;
  i: Integer;
begin
  // get program path
  ProgramPath := ExtractFilePath(ParamStr(0));

  // get target plugin param
  TargetPlugin := ParamStr(1);
  Writeln('Dumping plugin: ', TargetPlugin);

  // get target game param
  TargetGame := ParamStr(2);
  Writeln('Game: ', TargetGame);
end;

{ MAIN PROGRAM EXECUTION }

begin
  try
    Welcome;
    LoadParams;
    RunDump;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
