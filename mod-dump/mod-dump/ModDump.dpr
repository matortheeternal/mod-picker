program ModDump;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  mteHelpers,
  mdConfiguration in 'mdConfiguration.pas',
  mdDump in 'mdDump.pas',
  mdCore in 'mdCore.pas';

{$R *.res}
{$MAXSTACKSIZE 2097152}

const
  IMAGE_FILE_LARGE_ADDRESS_AWARE = $0020;

{$SetPEFlags IMAGE_FILE_LARGE_ADDRESS_AWARE}

var
  TargetFile, TargetGame: string;
  bIsPlugin, bIsText: boolean;

{ HELPER METHODS }

procedure Welcome;
begin
  // print program version
  Writeln('ModDump v', ProgramStatus.ProgramVersion);

  // load and save settings
  LoadSettings;
  SaveSettings;
end;

procedure LoadParams;
begin
  // get program path
  PathList.Values['ProgramPath'] := ExtractFilePath(ParamStr(0));

  // get target file param
  TargetFile := ParamStr(1);
  if not FileExists(TargetFile) then
    raise Exception.Create('Target file not found');

  // raise exception if target file is not a plugin file or a text file
  bIsPlugin := IsPlugin(TargetFile);
  bIsText := StrEndsWith(TargetFile, '.txt');
  if bIsPlugin then
    Writeln('Dumping plugin: ', ExtractFileName(TargetFile))
  else if bIsText then
    Writeln('Dumping plugins in list: ', ExtractFileName(TargetFile))
  else
    raise Exception.Create('Target file does not match *.esp, *.esm, or *.txt');

  // get target game param
  TargetGame := ParamStr(2);
  if not SetGameParam(TargetGame) then
    raise Exception.Create(Format('Invalid GameMode "%s"', [TargetGame]));
  Writeln('Game: ', ProgramStatus.GameMode.longName);
  Writeln(' ');
end;

{ MAIN PROGRAM EXECUTION }

begin
  try
    Welcome;
    LoadParams;
    if bIsPlugin then
      DumpPlugin(TargetFile)
    else if bIsText then
      DumpPluginsList(TargetFile);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
