program ModDump;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  mteHelpers,
  mdConfiguration in 'mdConfiguration.pas';

{$R *.res}
{$MAXSTACKSIZE 2097152}

const
  IMAGE_FILE_LARGE_ADDRESS_AWARE = $0020;

{$SetPEFlags IMAGE_FILE_LARGE_ADDRESS_AWARE}

var
  ProgramPath, ProgramVersion, TargetPlugin, TargetGame: string;

{ HELPER METHODS }

procedure Welcome;
begin
  ProgramVersion := GetVersionMem;
  Writeln('ModDump v', ProgramVersion);
end;

procedure LoadParams;
begin
  // get program path
  ProgramPath := ExtractFilePath(ParamStr(0));

  // get target plugin param
  TargetPlugin := ParamStr(1);
  Writeln('Dumping plugin: ', TargetPlugin);
  if not FileExists(TargetPlugin) then
    raise Exception.Create('Target plugin not found: "'+TargetPlugin+'"');

  // get target game param
  TargetGame := ParamStr(2);
  if not SetGameMode(TargetGame) then
    raise Exception.Create('Invalid GameMode "'+TargetGame+'"');
  Writeln('Game: ', ProgramStatus.GameMode.longName);
end;

{ MAIN PROGRAM EXECUTION }

begin
  try
    Welcome;
    LoadParams;
    //RunDump;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
