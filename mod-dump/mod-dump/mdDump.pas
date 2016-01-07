unit mdDump;

interface

uses
  SysUtils, Classes, Windows,
  // xedit units
  wbInterface, wbImplementation,
  // mte units
  mteHelpers, mteBase,
  // md units
  mdConfiguration;

  function IsPlugin(filename: string): boolean;
  procedure CreateEmptyPlugin(path: string);
  procedure DumpPlugin(filename: string);
  procedure DumpPluginsList(filename: string);

implementation

function IsPlugin(filename: string): boolean;
begin
  Result := StrEndsWith(filename, '.esp') or StrEndsWith(filename, '.esm');
end;

procedure CreateEmptyPlugin(path: string);
begin
  if not FileExists(settings.emptyPluginPath) then
    raise Exception.Create(Format('Empty plugin not found at "%s"',
      [settings.emptyPluginPath]));
  Writeln('Creating empty plugin ', path);
  CopyFile(PChar(settings.emptyPluginPath), PChar(path), true);
end;

{
  1. Load plugin header
  2. See if masters are available
  3. If masters not available, create dummy files for them
  4. Masters that are available should cycle through 1-4
  5. Close files with wbFileForceClosed
}
procedure BuildLoadOrder(filename: string; var sl: TStringList;
  bFirstFile: boolean = False);
var
  aFile: IwbFile;
  filePath, sMaster: string;
  slMasters: TStringList;
  i: Integer;
begin
  // add qualifying path if not first file
  if bFirstFile then
    filePath := filename
  else
    filePath := settings.pluginsPath + filename;

  // create empty plugin if plugin doesn't exist
  if not FileExists(filePath) then
    CreateEmptyPlugin(filePath);

  // load the file and recurse through its masters
  aFile := wbFile(filePath, -1, '', True, False);
  slMasters := TStringList.Create;
  try
    GetMasters(aFile, slMasters);
    for i := 0 to Pred(slMasters.Count) do begin
      sMaster := slMasters[i];
      if sl.IndexOf(sMaster) = -1 then
        BuildLoadOrder(sMaster, sl);
    end;

    // add file to load order
    sl.Add(filename);
  finally
    slMasters.Free;
  end;
end;

{
  1. Build load order
  2. Load plugins, don't build references
  3. Get information from plugin and print to log and a dump file
  4. Terminate
}
procedure DumpPlugin(filename: string);
var
  slLoadOrder: TStringList;
  i: Integer;
begin
  slLoadOrder := TStringList.Create;
  try
    BuildLoadOrder(filename, slLoadOrder, true);
    wbFileForceClosed;

    // print load order
    for i := 0 to Pred(slLoadOrder.Count) do
      Writeln(Format('[%s] %s', [IntToHex(i, 2), slLoadOrder[i]]));
  finally
    slLoadOrder.Free;
  end;
end;

{ TODO: Make it so we can process more than one plugin in a single session, so
  we don't have to reload base game ESMs into memory over and over again. }
procedure DumpPluginsList(filename: string);
var
  sl: TStringList;
  i: Integer;
  targetPath: string;
begin
  sl := TStringList.Create;
  try
    // load list of plugins to dump
    sl.LoadFromFile(filename);

    // dump plugins in the list
    for i := 0 to Pred(sl.Count) do begin
      targetPath := sl[i];
      try
        // raise exception if a file doesn't exist at targetPath
        if not FileExists(targetPath) then
          raise Exception.Create('File not found');

        // raise exception if targetPath doesn't point to a plugin
        if not IsPlugin(targetPath) then
          raise Exception.Create('Does not match *.esp or *.esm');

        // dump the plugin
        DumpPlugin(targetPath);
      except
        on x: Exception do
          Writeln(Format('%s: %s', [targetPath, x.Message]));
      end;
    end;
  finally
    sl.Free;
  end;
end;

end.
