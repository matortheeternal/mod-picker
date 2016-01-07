unit mdDump;

interface

uses
  SysUtils, Classes,
  // mte units
  mteHelpers, mteBase;

  function IsPlugin(filename: string): boolean;
  procedure DumpPlugin(filename: string);
  procedure DumpPluginsList(filename: string);

implementation

function IsPlugin(filename: string): boolean;
begin
  Result := StrEndsWith(filename, '.esp') or StrEndsWith(filename, '.esm');
end;

{
  1. Load plugin header
  2. See if masters are available
  3. If masters not available, create dummy files for them
  4. Masters that are available should cycle through 1-4
  4. Close files with wbFileForceClosed
  5. Load plugin and required masters, don't build references
  6. Get information from plugin and print to log and a dump file
  7. Terminate
}
procedure DumpPlugin(filename: string);
begin
  // ?
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
