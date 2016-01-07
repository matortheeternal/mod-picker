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
  procedure DumpPlugin(filePath: string);
  procedure DumpPluginsList(filePath: string);

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

procedure PrintLoadOrder(var sl: TStringList);
var
  i: Integer;
begin
  // print load order
  Writeln(' ');
  Writeln('== LOAD ORDER ==');
  for i := 0 to Pred(sl.Count) do
    Writeln(Format('[%s] %s', [IntToHex(i, 2), sl[i]]));
end;

procedure LoadPlugins(baseFilePath: string; var sl: TStringList);
var
  i: Integer;
  plugin: TBasePlugin;
  aFile: IwbFile;
  sFilePath, sFilename: string;
begin
  // print log messages
  Writeln(' ');
  Writeln('== LOADING PLUGINS ==');

  // load the plugins
  for i := 0 to Pred(sl.Count) do begin
    // get file path to load
    if sl[i] = baseFilePath then
      sFilePath := sl[i]
    else
      sFilePath := settings.pluginsPath + sl[i];

    // print log message
    sFilename := ExtractFilename(sFilePath);
    Writeln('Loading ', sFilename, '...');

    // load plugin
    try
      plugin := TBasePlugin.Create;
      plugin.filename := sFilename;
      plugin._File := wbFile(sFilePath, i, '', false, false);
      plugin._File._AddRef;
      plugin.GetData(PluginsList);
      plugin.GetHash;
      PluginsList.Add(Pointer(plugin));
    except
      on x: Exception do begin
        Writeln('Exception loading '+sl[i]);
        Writeln(x.Message);
        raise x;
      end;
    end;

    // load hardcoded dat
    if i = 0 then try
      aFile := wbFile(settings.pluginsPath + wbGameName + wbHardcodedDat, 0);
      aFile._AddRef;
    except
      on x: Exception do begin
        Writeln('Exception loading ', wbGameName, wbHardcodedDat);
        raise x;
      end;
    end;
  end;
end;

procedure WritePair(name, value: string);
begin
  Writeln(Format('%s: %s', [name, value]));
end;

procedure WriteList(name: string; var sl: TStringList);
var
  i: Integer;
begin
  // write first item as pair
  if sl.Count > 0 then
    WritePair(name, sl[0]);

  // write the rest of the list
  for i := 1 to Pred(sl.Count) do
    Writeln(Format('%s  %s', [StringOfChar(' ', Length(name)), sl[i]]));
end;

procedure DumpInfo(plugin: TBasePlugin);
begin
  Writeln(' ');
  Writeln('== DUMP ==');

  // main attributes
  WritePair('Filename', plugin.filename);
  WritePair('File size', FormatByteSize(plugin.fileSize));
  WritePair('File hash', plugin.hash);
  WriteList('Masters', plugin.masters);
  WriteList('Description', plugin.description);
  WritePair('Number of records', plugin.numRecords);
  WritePair('Number of overrides', plugin.numOverrides);

  // TODO: record groups
  // TODO: errors
  // TODO: write to json
end;

{
  1. Build load order
  2. Load plugins, don't build references
  3. Get information from plugin and print to log and a dump file
  4. Terminate
}
procedure DumpPlugin(filePath: string);
var
  slLoadOrder: TStringList;
  sFileName: string;
  plugin: TBasePlugin;
begin
  slLoadOrder := TStringList.Create;
  try
    // build and print load order
    BuildLoadOrder(filePath, slLoadOrder, true);
    wbFileForceClosed;
    PrintLoadOrder(slLoadOrder);

    // load plugins
    LoadPlugins(filePath, slLoadOrder);

    // dump info on our plugin
    sFileName := ExtractFilename(filePath);
    plugin := TPluginHelpers.BasePluginByFilename(PluginsList, sFileName);
    DumpInfo(plugin);
  finally
    wbFileForceClosed;
    slLoadOrder.Free;
  end;
end;

{ TODO: Make it so we can process more than one plugin in a single session, so
  we don't have to reload base game ESMs into memory over and over again. }
procedure DumpPluginsList(filePath: string);
var
  sl: TStringList;
  i: Integer;
  targetPath: string;
begin
  sl := TStringList.Create;
  try
    // load list of plugins to dump
    sl.LoadFromFile(filePath);

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
