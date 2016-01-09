unit mdDump;

interface

uses
  SysUtils, Classes, Windows,
  // third party libraries
  superobject,
  // xedit units
  wbInterface, wbImplementation,
  // mte units
  mteHelpers, mteBase,
  // md units
  mdConfiguration, mdCore;

  function IsPlugin(filename: string): boolean;
  procedure DumpPlugin(filePath: string);
  procedure DumpPluginsList(filePath: string);

implementation

function IsPlugin(filename: string): boolean;
begin
  Result := StrEndsWith(filename, '.esp') or StrEndsWith(filename, '.esm');
end;

procedure CreateDummyPlugin(path: string);
begin
  if not FileExists(settings.dummyPluginPath) then
    raise Exception.Create(Format('Empty plugin not found at "%s"',
      [settings.dummyPluginPath]));
  Writeln('Creating empty plugin ', path);
  CopyFile(PChar(settings.dummyPluginPath), PChar(path), true);
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
    CreateDummyPlugin(filePath);

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

procedure LoadPlugins(dumpFilePath: string; var sl: TStringList);
var
  i: Integer;
  bIsDumpFile: boolean;
  plugin: TPlugin;
  aFile: IwbFile;
  sFilePath, sFilename: string;
begin
  // print log messages
  Writeln(' ');
  Writeln('== LOADING PLUGINS ==');

  // print empty plugin hash
  if settings.bPrintHashes then
    Writeln('Empty plugin hash: ', dummyPluginHash);

  // load the plugins
  for i := 0 to Pred(sl.Count) do begin
    bIsDumpFile := sl[i] = dumpFilePath;
    // get file path to load
    if bIsDumpFile then
      sFilePath := sl[i]
    else
      sFilePath := settings.pluginsPath + sl[i];

    // print log message
    sFilename := ExtractFilename(sFilePath);
    Writeln('Loading ', sFilename, '...');

    // load plugin
    try
      plugin := TPlugin.Create;
      plugin.filename := sFilename;
      plugin._File := wbFile(sFilePath, i, '', false, false);
      plugin._File._AddRef;
      plugin.GetMdData(bIsDumpFile);
      PluginsList.Add(Pointer(plugin));

      // print the hash if the bPrintHashes setting is true
      if settings.bPrintHashes then
        Writeln('  Hash = ', plugin.hash);
      // update bUsedEmptyPlugins
      if plugin.hash = dummyPluginHash then
        ProgramStatus.bUsedDummyPlugins := true;
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

procedure WriteList(name: string; var sl: TStringList);
var
  i: Integer;
begin
  // write the name
  Writeln(name, ':');

  // write the list indented by one space
  for i := 0 to Pred(sl.Count) do
    Writeln(' ', sl[i]);
end;

procedure WriteDump(plugin: TPlugin);
var
  i: Integer;
  group: TRecordGroup;
  error: TRecordError;
begin
  Writeln(' ');
  Writeln('== DUMP ==');

  // write main attributes
  Writeln('Filename: ', plugin.filename);
  Writeln('File size: ', FormatByteSize(plugin.fileSize));
  Writeln('Hash: ', plugin.hash);
  WriteList('Masters', plugin.masters);
  WriteList('Description', plugin.description);
  Writeln('Number of records: ', plugin.numRecords);
  Writeln('Number of overrides: ', plugin.numOverrides);

  // write record groups
  Writeln('Record groups:');
  for i := 0 to Pred(plugin.groups.Count) do begin
    group := TRecordGroup(plugin.groups[i]);
    Writeln(Format(' [%s]  Records:%5d, Overrides:%5d',
      [string(group.signature), group.numRecords, group.numOverrides]));
  end;
  if plugin.groups.Count = 0 then
    Writeln(' No records');

  // write errors
  Writeln('Errors:');
  for i := 0 to Pred(plugin.errors.Count) do begin
    error := TRecordError(plugin.errors[i]);
    if error.path <> '' then
      Writeln(Format(' [%s:%s] %s at %s', [string(error.signature),
        error.formID, error.&type.shortName, error.path]))
    else
      Writeln(Format(' [%s:%s] %s', [string(error.signature),
        error.formID, error.&type.shortName]))
  end;
  if ProgramStatus.bUsedDummyPlugins then
    Writeln(' Unknown')
  else if (plugin.errors.Count = 0) then
    Writeln(' No errors');
end;

procedure JsonDump(plugin: TPlugin);
var
  obj, childObj: ISuperObject;
  i, j: Integer;
  group: TRecordGroup;
  error: TRecordError;
  sl: TStringList;
begin
  obj := SO;
  obj.S['filename'] := plugin.filename;
  obj.I['fileSize'] := plugin.fileSize;
  obj.S['hash'] := plugin.hash;
  obj.I['numRecords'] := plugin.numRecords;
  obj.I['numOverrides'] := plugin.numOverrides;
  obj.S['description'] := plugin.description.Text;

  // dump masters
  obj.O['masters'] := SA([]);
  for i := 0 to Pred(plugin.masters.Count) do
    obj.A['masters'].S[i] := plugin.masters[i];

  // dump dummy masters
  obj.O['dummyMasters'] := SA([]);
  j := 0;
  for i := 0 to Pred(plugin.masters.Count) do begin
    if PluginByFilename(plugin.masters[i]).hash = dummyPluginHash then begin
      obj.A['dummyMasters'].S[j] := plugin.masters[i];
      Inc(j);
    end;
  end;

  // dump record groups
  obj.O['records'] := SO;
  for i := 0 to Pred(plugin.groups.Count) do begin
    group := TRecordGroup(plugin.groups[i]);
    childObj := SO;
    childObj.I['numRecords'] := group.numRecords;
    childObj.I['numOverrides'] := group.numOverrides;
    obj.O['records'].O[string(group.signature)] := childObj;
  end;

  // dump errors
  obj.O['errors'] := SA([]);
  for i := 0 to Pred(plugin.errors.Count) do begin
    error := TRecordError(plugin.errors[i]);
    childObj := SO;
    childObj.I['type'] := Ord(error.&type.id);
    childObj.S['signature'] := string(error.signature);
    childObj.S['formID'] := error.formID;
    childObj.S['name'] := error.name;
    if error.path <> '' then
      childObj.S['path'] := error.path;
    if error.data <> '' then
      childObj.S['data'] := error.data;
    obj.A['errors'].Add(childObj);
  end;

  // dump overrides
  obj.O['overrides'] := SA([]);
  for i := 0 to Pred(plugin.overrides.Count) do
    obj.A['overrides'].S[i] := plugin.overrides[i];

  // save to disk
  sl := TStringList.Create;
  try
    sl.Text := obj.AsJSon;
    sl.SaveToFile(settings.dumpPath + plugin.filename + '.json');
  finally
    sl.Free;
  end;
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
  plugin: TPlugin;
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
    plugin := PluginByFilename(sFileName);
    WriteDump(plugin);
    JsonDump(plugin);
  finally
    wbFileForceClosed;
    slLoadOrder.Free;
  end;
end;

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
