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
  CopyFile(settings.emptyPluginPath, path, true);
end;

{
  1. Load plugin header
  2. See if masters are available
  3. If masters not available, create dummy files for them
  4. Masters that are available should cycle through 1-4
  5. Close files with wbFileForceClosed
}
procedure BuildLoadOrder(filename: string; var sl: TStringList);
var
  aFile: IwbFile;
  plugin: TBasePlugin;
  filePath: string;
  slMasters: TStringList;
  i: Integer;
begin
  // add file to load order if it's missing
  if sl.IndexOf(filename) = -1 then
    sl.Add(filename);
  // create empty plugin if plugin doesn't exist
  filePath := wbDataPath + filename;
  if not FileExists(filePath) then
    CreateEmptyPlugin(filePath);

  // load the file and recurse through its masters
  aFile := wbFile(wbDataPath + filename, -1, '', True, False);
  slMasters := TStringList.Create;
  try
    GetMasters(aFile, slMasters);
    for i := 0 to Pred(slMasters.Count) do
      BuildLoadOrder(slMasters[i], sl);
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
    BuildLoadOrder(filename, slLoadOrder);
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
