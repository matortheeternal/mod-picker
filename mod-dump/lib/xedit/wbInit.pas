{*******************************************************************************

     The contents of this file are subject to the Mozilla Public License
     Version 1.1 (the "License"); you may not use this file except in
     compliance with the License. You may obtain a copy of the License at
     http://www.mozilla.org/MPL/

     Software distributed under the License is distributed on an "AS IS"
     basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
     License for the specific language governing rights and limitations
     under the License.

*******************************************************************************}

unit wbInit;

{$I wbDefines.inc}

interface

uses
  Classes;

var
  wbApplicationTitle   : string;
  wbScriptsPath        : string;
  wbScriptToRun        : string;
  wbBackupPath         : string;
  wbTempPath           : string;
  wbMyGamesTheGamePath : string;
  wbPluginsFileName    : String;
  wbSettingsFileName   : string;
  wbModGroupFileName   : string;
  wbPluginToUse        : string;  // Passed a specific plugin as parameter
  wbLogFile            : string;  // Optional log file for this session

  wbMasterUpdateDone   : Boolean;
  wbDontSave           : Boolean;
  wbDontBackup         : Boolean = False;
  wbRemoveTempPath     : Boolean = True;
  wbQuickShowConflicts : Boolean;
  wbQuickClean         : Boolean;

  wbParamIndex         : integer = 1;     // First unused parameter
  wbPluginsToUse       : TStringList;

function wbFindNextValidCmdLineFileName(var startingIndex : integer; out aValue  : string; defaultPath : string = '') : Boolean;
function wbFindNextValidCmdLinePlugin(var startingIndex : integer; out aValue  : string; defaultPath : string) : Boolean;
function wbFindCmdLineParam(const aSwitch : string; out aValue : string): Boolean; overload;

function wbLoadMOHookFile: Boolean;

implementation

uses
  SysUtils,
  Windows,
  Registry,
  ShellApi,
  Dialogs,
  ShlObj,
  IOUtils,
  IniFiles,
  wbHelpers,
  wbInterface,
  wbImplementation,
  wbDefinitionsFNV,
  wbDefinitionsFO3,
  wbDefinitionsTES3,
  wbDefinitionsTES4,
  wbDefinitionsTES5;

function wbFindCmdLineParam(const aSwitch     : string;
                            const aChars      : TSysCharSet;
                                  aIgnoreCase : Boolean;
                              out aValue      : string)
                                              : Boolean; overload;
var
  i : Integer;
  s : string;
begin
  Result := False;
  aValue := '';
  for i := 1 to ParamCount do begin
    s := ParamStr(i);
    if (aChars = []) or (s[1] in aChars) then
      if aIgnoreCase then begin
        if AnsiCompareText(Copy(s, 2, Length(aSwitch)), aSwitch) = 0 then begin
          if (length(s)>(length(aSwitch)+2)) and (s[Length(aSwitch) + 2] = ':') then begin
            aValue := Copy(s, Length(aSwitch) + 3, MaxInt);
            Result := True;
          end;
          Exit;
        end;
      end else
        if AnsiCompareStr(Copy(s, 2, Length(aSwitch)), aSwitch) = 0 then begin
          if s[Length(aSwitch) + 2] = ':' then begin
            aValue := Copy(s, Length(aSwitch) + 3, MaxInt);
            Result := True;
          end;
          Exit;
        end;
  end;
end;

function wbFindCmdLineParam(var   startingIndex : integer;
                            const aChars        : TSysCharSet;
                              out aValue        : string)
                                                : Boolean; overload;
var
  i : integer;
  s : string;
begin
  Result := False;
  aValue := '';
  for i := startingIndex to ParamCount do begin
    s := ParamStr(i);
    if (aChars = []) or (s[1] in aChars) then // skipped
      Inc(startingIndex)
    else begin
      aValue := ParamStr(i);
      startingIndex := i+1;
      Result := True;
      break;
    end
  end;
end;

function wbFindCmdLineParam(const aSwitch : string;
                              out aValue  : string)
                                          : Boolean; overload;
begin
  Result := wbFindCmdLineParam(aSwitch, SwitchChars, True, aValue);
end;

function wbFindCmdLineParam(var startingIndex : integer; out aValue  : string) : Boolean; overload;
begin
  Result := wbFindCmdLineParam(startingIndex, SwitchChars, aValue);
end;

function wbCheckForValidExtension(aFilePath : string; const anExtension : string): Boolean; overload;
begin
  Result := UpperCase(ExtractFileExt(aFilePath)) = UpperCase(anExtension);
end;

function wbCheckForPluginExtension(aFilePath : string): Boolean;
begin
  Result := wbCheckForValidExtension(aFilePath, '.esp') or wbCheckForValidExtension(aFilePath, '.esm');
end;

function wbCheckForValidExtension(aFilePath : string): Boolean; overload;
begin
  Result := wbCheckForPluginExtension(aFilePath) or
            wbCheckForValidExtension(aFilePath, '.fos') or wbCheckForValidExtension(aFilePath, '.ess');
end;

function wbFindNextValidCmdLineFileName(var startingIndex : integer; out aValue  : string; defaultPath : string = '') : Boolean;
begin
  Result := wbFindCmdLineParam(startingIndex, SwitchChars, aValue);
  if Result and not FileExists(aValue) then
    if (defaultPath<>'') then
      if FileExists(defaultPath+'\'+aValue) then
        aValue := ExpandFileName(defaultPath+'\'+aValue)
      else
        Result := False
    else
      Result := False;
end;

function wbFindNextValidCmdLinePlugin(var startingIndex : integer; out aValue  : string; defaultPath : string) : Boolean;
begin
  repeat
    Result := wbFindNextValidCmdLineFileName(startingIndex, aValue, defaultPath);
  until not Result or wbCheckForPluginExtension(aValue);
  if Result  then
    if (AnsiCompareText(ExpandFileName(ExtractFilePath(aValue)), ExpandFileName(defaultPath)) = 0) then begin
      aValue := ExtractFileName(aValue);
      if not Assigned(wbPluginsToUse) then wbPluginsToUse := TStringList.Create;
      wbPluginsToUse.Add(aValue);
    end else
      Result := False;
end;

// several ini settings should be read before record definitions
// they may affect definitions like wbSimpleRecords
// and should be overridden by command line parameters
procedure ReadSettings;
var
  Settings: TMemIniFile;
begin
  try
    Settings := TMemIniFile.Create(wbSettingsFileName);
    try
      wbLoadBSAs := Settings.ReadBool('Options', 'LoadBSAs', wbLoadBSAs);
      wbSimpleRecords := Settings.ReadBool('Options', 'SimpleRecords', wbSimpleRecords);
      wbShowFlagEnumValue := Settings.ReadBool('Options', 'ShowFlagEnumValue', wbShowFlagEnumValue);
      wbTrackAllEditorID := Settings.ReadBool('Options', 'TrackAllEditorID', wbTrackAllEditorID);
    finally
      Settings.Free;
    end;
  finally
  end;
end;

function GetCSIDLShellFolder(CSIDLFolder: integer): string;
begin
  SetLength(Result, MAX_PATH);
  SHGetSpecialFolderPath(0, PChar(Result), CSIDLFolder, True);
  SetLength(Result, StrLen(PChar(Result)));
  if (Result <> '') then
    Result := IncludeTrailingBackslash(Result);
end;

function CheckAppPath: string;
const
  //gmFNV, gmFO3, gmTES3, gmTES4, gmTES5
  ExeName : array[TwbGameMode] of string =
    ('FalloutNV.exe', 'Fallout3.exe', 'Morrowind.exe', 'Oblivion.exe', 'TESV.exe');
var
  s: string;
begin
  Result := '';
  s := ExtractFilePath(ParamStr(0));
  while Length(s) > 3 do begin
    if FileExists(s + ExeName[wbGameMode]) and DirectoryExists(s + 'Data') then begin
      Result := s;
      Exit;
    end;
    s := ExtractFilePath(ExcludeTrailingPathDelimiter(s));
  end;
end;

{===SafeLoadLibrary============================================================}
function TestAndClearFPUExceptions(AExceptionMask: Word): Boolean;
asm
      PUSH    ECX
      MOV     CX, AX
      FSTSW   AX
      TEST    AX, CX
      JNE     @@bad
      XOR     EAX, EAX
      INC     EAX
      JMP     @@exit
@@bad:
      XOR     EAX, EAX
@@exit:
      POP     ECX
      FCLEX
      RET
end;
{------------------------------------------------------------------------------}
function SafeLoadLibrary(const Filename: string; ErrorMode: UINT): HMODULE;
var
  OldMode: UINT;
  FPUControlWord: Word;
begin
  OldMode := SetErrorMode(ErrorMode);
  try
    FPUControlWord := Get8087CW();
    Result := LoadLibrary(PChar(Filename));
    TestAndClearFPUExceptions(0);
    Set8087CW(FPUControlWord);
  finally
    SetErrorMode(OldMode);
  end;
end;
{==============================================================================}


function wbLoadMOHookFile: Boolean;
var
  HookDll : HMODULE;
  Init    : function(logLevel: Integer; profileName: LPCWSTR): BOOL; cdecl;
begin
  if not wbShouldLoadMOHookFile then
    Exit(True);
  Result := False;
  if not FileExists(wbMOHookFile) then
    Exit;

  HookDll := SafeLoadLibrary(wbMOHookFile, SEM_NOOPENFILEERRORBOX);
  if HookDll <> 0 then begin
    Pointer(@Init) := GetProcAddress(HookDll, 'Init');
    if Assigned(Pointer(@Init)) then
      Result := Init(0, PWideChar(UnicodeString(wbMOProfile)));
  end;
end;

procedure DoInitPath(const ParamIndex: Integer);
const
  sBethRegKey             = '\SOFTWARE\Bethesda Softworks\';
  sBethRegKey64           = '\SOFTWARE\Wow6432Node\Bethesda Softworks\';
var
  s : String;
begin
  wbModGroupFileName := wbProgramPath + wbAppName + wbToolName + '.modgroups';

  if not wbFindCmdLineParam('S', wbScriptsPath) then
    wbScriptsPath := wbProgramPath + 'Edit Scripts\';

  if not wbFindCmdLineParam('T', wbTempPath) then
    wbTempPath := IncludeTrailingPathDelimiter(TPath.GetTempPath + wbAppName + 'Edit')
  else
    wbRemoveTempPath := not DirectoryExists(wbTempPath);

  if not wbFindCmdLineParam('D', wbDataPath) then begin
    wbDataPath := CheckAppPath;

    if wbDataPath = '' then with TRegistry.Create do try
      RootKey := HKEY_LOCAL_MACHINE;

      if not OpenKeyReadOnly(sBethRegKey + wbGameName + '\') then
        if not OpenKeyReadOnly(sBethRegKey64 + wbGameName + '\') then begin
          s := 'Fatal: Could not open registry key: ' + sBethRegKey + wbGameName + '\';
          if wbGameMode = gmTES5 then
            ShowMessage(s+#13+#10+'This can happen after Steam updates, run game''s launcher to restore registry settings');
          wbDontSave := True;
          Exit;
        end;

      wbDataPath := ReadString('Installed Path');

      if wbDataPath = '' then begin
        s := 'Fatal: Could not determine '+wbGameName+' installation path, no "Installed Path" registry key';
        if wbGameMode = gmTES5 then
          ShowMessage(s+#13+#10+'This can happen after Steam updates, run game''s launcher to restore registry settings');
        wbDontSave := True;
      end;
    finally
      Free;
    end;
    if wbDataPath <>'' then
      wbDataPath := IncludeTrailingPathDelimiter(wbDataPath) + 'Data\';
  end else
    wbDataPath := IncludeTrailingPathDelimiter(wbDataPath);

  wbOutputPath := wbDataPath;
  if wbFindCmdLineParam('O', s) and (Length(s) > 0) then
    if s[1] = '.' then
      //assume relative path
      wbOutputPath := IncludeTrailingPathDelimiter(wbOutputPath + s)
    else
      //assume absolute path
      wbOutputPath := IncludeTrailingPathDelimiter(s);

  wbMOHookFile := wbDataPath + '..\Mod Organizer\hook.dll';

  if not wbFindCmdLineParam('I', wbTheGameIniFileName) then begin
    wbTheGameIniFileName := GetCSIDLShellFolder(CSIDL_PERSONAL);
    if wbTheGameIniFileName = '' then begin
      ShowMessage('Fatal: Could not determine my documents folder');
      Exit;
    end;
    wbMyGamesTheGamePath := wbTheGameIniFileName + 'My Games\'+ wbGameName +'\';

    if wbGameMode in [gmFO3, gmFNV] then
      wbTheGameIniFileName := wbMyGamesTheGamePath + 'Fallout.ini'
    else
      wbTheGameIniFileName := wbMyGamesTheGamePath + wbGameName + '.ini';
  end;

  wbParamIndex := ParamIndex;
  if not wbFindCmdLineParam('P', wbPluginsFileName) then
    if not (wbFindNextValidCmdLineFileName(wbParamIndex, wbPluginsFileName) and SameText(ExtractFileExt(wbPluginsFileName), '.txt'))
       or wbCheckForValidExtension(wbPluginsFileName)
    then begin
      wbParamIndex := ParamIndex;
      wbPluginsFileName := GetCSIDLShellFolder(CSIDL_LOCAL_APPDATA);
      if wbPluginsFileName = '' then begin
        ShowMessage('Fatal: Could not determine the local application data folder');
        Exit;
      end;

      wbPluginsFileName := wbPluginsFileName + wbGameName + '\Plugins.txt';
    end;

  // settings in the ini file next to app, or in the same folder with plugins.txt
  wbSettingsFileName := wbProgramPath + wbAppName + wbToolName + '.ini';
  if not FileExists(wbSettingsFileName) then
    wbSettingsFileName := ChangeFileExt(wbPluginsFileName, '.'+LowerCase(wbAppName)+'viewsettings');

  wbBackupPath := '';
  if not (wbDontSave or wbFindCmdLineParam('B', wbBackupPath)) then begin
    wbBackupPath := wbDataPath + wbAppName + 'Edit Backups\';
    if not DirectoryExists(wbBackupPath) then
      if not ForceDirectories(wbBackupPath) then
        wbBackupPath := wbDataPath;
  end;
  wbFindCmdLineParam('R', wbLogFile);
end;

var
  wbForcedModes: string;

function isMode(aMode: String): Boolean;
var
  s: string;
begin
  Result := (Pos(Uppercase(aMode), UpperCase(wbForcedModes)) <> 0) or
            FindCmdLineSwitch(aMode) or
            wbFindCmdLineParam(aMode, s) or
            (Pos(Uppercase(aMode), UpperCase(ExtractFileName(ParamStr(0)))) <> 0);
end;

// Force app modes
function CheckForcedMode: Boolean;
var
  s: string;
  i: integer;
begin
  Result := False;
  // there is a game specific script provided to execute
  i := 1;
  if wbFindCmdLineParam('script', s) or wbFindNextValidCmdLineFileName(i, s) then begin
    if not FileExists(s) then
      Exit;
    wbScriptToRun := s;
    s := ExtractFileExt(s);
    i := Pos(UpperCase('pas'), UpperCase(s));
    if (i > 0) and (i = Length(s) - 2) then begin
      wbForcedModes := Copy(s, 2, Length(s) - 4) + ',script';
      Result := True;
    end;
  end;
end;

procedure wbDoInit;
var
  s: string;
begin
  wbReportMode := False;

  if isMode('Saves') then begin
    wbToolSource := tsSaves;
    wbSourceName := 'Saves';
  end else begin // defaults to plugin
    wbToolSource := tsPlugins;
    wbSourceName := 'Plugins';
  end;

  wbEditAllowed := True;
  wbDontSave    := False;
  CheckForcedMode;
  if isMode('View') then begin
    wbToolMode    := tmView;
    wbToolName    := 'View';
    wbEditAllowed := False;
    wbDontSave    := True;
  end else if isMode('MasterUpdate') then begin
    wbToolMode    := tmMasterUpdate;
    wbToolName    := 'MasterUpdate';
  end else if isMode('MasterRestore') then begin
    wbToolMode    := tmMasterRestore;
    wbToolName    := 'MasterRestore';
  end else if isMode('LODGen') then begin
    wbToolMode    := tmLODgen;
    wbToolName    := 'LODGen';
    wbEditAllowed := False;
    wbDontSave    := True;
  end else if isMode('Script') then begin
    wbToolMode    := tmScript;
    wbToolName    := 'Script';
  end else if isMode('Translate') then begin
    wbToolMode    := tmTranslate;
    wbToolName    := 'Trans';
  end else if isMode('setESM') then begin
    wbToolMode    := tmESMify;
    wbToolName    := 'SettingESMflag';
  end else if isMode('clearESM') then begin
    wbToolMode    := tmESPify;
    wbToolName    := 'ClearingESMflag';
  end else if isMode('SortAndClean') then begin
    wbToolMode    := tmSortAndCleanMasters;
    wbToolName    := 'SortAndCleanMasters';
  end else if isMode('CheckForErrors') then begin
    wbToolMode    := tmCheckForErrors;
    wbToolName    := 'CheckForErrors';
  end else if isMode('CheckForITM') then begin
    wbToolMode    := tmCheckForITM;
    wbToolName    := 'CheckForITM';
  end else if isMode('CheckForDR') then begin
    wbToolMode    := tmCheckForDR;
    wbToolName    := 'CheckForDR';
  end else if isMode('Edit') then begin
    wbToolMode    := tmEdit;
    wbToolName    := 'Edit';
  end else begin
    ShowMessage('Application name must contain Edit, View, LODGen, MasterUpdate, MasterRestore, setESM, clearESM, sortAndCleanMasters, CheckForITM, CheckForDR or CheckForErrors to select mode.');
    Exit;
  end;

  if isMode('FNV') then begin
    wbGameMode := gmFNV;
    wbAppName := 'FNV';
    wbGameName := 'FalloutNV';
    if not (wbToolMode in wbAlwaysMode) and not (wbToolMode in [tmMasterUpdate, tmMasterRestore]) then begin
      ShowMessage('Application '+wbGameName+' does not currently support '+wbToolName);
      Exit;
    end;
    if not (wbToolSource in [tsPlugins]) then begin
      ShowMessage('Application '+wbGameName+' does not currently support '+wbSourceName);
      Exit;
    end;
  end else if isMode('FO3') then begin
    wbGameMode := gmFO3;
    wbAppName := 'FO3';
    wbGameName := 'Fallout3';
    if not (wbToolMode in wbAlwaysMode) and not (wbToolMode in [tmMasterUpdate, tmMasterRestore]) then begin
      ShowMessage('Application '+wbGameName+' does not currently support '+wbToolName);
      Exit;
    end;
    if not (wbToolSource in [tsPlugins]) then begin
      ShowMessage('Application '+wbGameName+' does not currently support '+wbSourceName);
      Exit;
    end;
  end else if isMode('TES3') then begin
    wbGameMode := gmTES3;
    wbAppName := 'TES3';
    wbGameName := 'Morrowind';
    if not (wbToolMode in []) then begin
      ShowMessage('Application '+wbGameName+' does not currently support '+wbToolName);
      Exit;
    end;
    if not (wbToolSource in []) then begin
      ShowMessage('Application '+wbGameName+' does not currently support '+wbSourceName);
      Exit;
    end;
  end else if isMode('TES4') then begin
    wbGameMode := gmTES4;
    wbAppName := 'TES4';
    wbGameName := 'Oblivion';
    if not (wbToolMode in wbAlwaysMode) and not (wbToolMode in []) then begin
      ShowMessage('Application '+wbGameName+' does not currently support '+wbToolName);
      Exit;
    end;
    if not (wbToolSource in [tsPlugins]) then begin
      ShowMessage('Application '+wbGameName+' does not currently support '+wbSourceName);
      Exit;
    end;
  end else if isMode('TES5') then begin
    wbGameMode := gmTES5;
    wbAppName := 'TES5';
    wbGameName := 'Skyrim';
    if not (wbToolMode in wbAlwaysMode) and not (wbToolMode in [tmTranslate]) then begin
      ShowMessage('Application '+wbGameName+' does not currently support '+wbToolName);
      Exit;
    end;
    if not (wbToolSource in [tsPlugins]) then begin
      ShowMessage('Application '+wbGameName+' does not currently support '+wbSourceName);
      Exit;
    end;
  end else begin
    ShowMessage('Application name must contain FNV, FO3, TES4 or TES5 to select game.');
    Exit;
  end;

  DoInitPath(wbParamIndex);

  if wbGameMode = gmFNV then begin
    wbVWDInTemporary := True;
    wbLoadBSAs := False;
    ReadSettings;
  end else if wbGameMode = gmFO3 then begin
    wbVWDInTemporary := True;
    wbLoadBSAs := False;
    ReadSettings;
  end else if wbGameMode = gmTES3 then begin
    wbLoadBSAs := False;
    wbAllowInternalEdit := false;
    ReadSettings;
  end else if wbGameMode = gmTES4 then begin
    wbLoadBSAs := True;
    wbAllowInternalEdit := false;
    ReadSettings;
  end else if wbGameMode = gmTES5 then begin
    wbVWDInTemporary := True;
    wbLoadBSAs := True; // localization won't work otherwise
    wbHideIgnored := False; // to show Form Version
    ReadSettings;
  end else begin
    Exit;
  end;

  if wbGameMode = gmFNV then
    DefineFNV
  else if wbGameMode = gmFO3 then
    DefineFO3
  else if wbGameMode = gmTES3 then
    DefineTES3
  else if wbGameMode = gmTES4 then
    DefineTES4
  else if wbGameMode = gmTES5 then
    case wbToolSource of
      tsPlugins: DefineTES5;
    end
  else begin
    ShowMessage('Application name must contain FNV, FO3, TES4 or TES5 to select game.');
    Exit;
  end;

  wbLanguage := 'English';
  if wbFindCmdLineParam('l', s) then
    wbLanguage := s;

  if FindCmdLineSwitch('speed') then
    wbSpeedOverMemory := True;
  if FindCmdLineSwitch('memory') then
    wbSpeedOverMemory := False;

  if FindCmdLineSwitch('report') then
    wbReportMode := (DebugHook <> 0);
  if FindCmdLineSwitch('MoreInfoForIndex') then
    wbMoreInfoForIndex := true;

  if FindCmdLineSwitch('fixup') then
    wbAllowInternalEdit := True
  else if FindCmdLineSwitch('nofixup') then
    wbAllowInternalEdit := False;

  if FindCmdLineSwitch('skipbsa') then
    wbLoadBSAs := False
  else if FindCmdLineSwitch('forcebsa') then
    wbLoadBSAs := True;

  if FindCmdLineSwitch('skipInternalEditing') then
    wbAllowInternalEdit := False
  else if FindCmdLineSwitch('forceInternalEditing') then
    wbAllowInternalEdit := True;

  if FindCmdLineSwitch('showfixup') then
    wbShowInternalEdit := True
  else if FindCmdLineSwitch('hidefixup') then
    wbShowInternalEdit := False;

  if FindCmdLineSwitch('quickshowconflicts') then
    wbQuickShowConflicts := True;

  if FindCmdLineSwitch('IKnowWhatImDoing') then
    wbIKnowWhatImDoing := True;

  if FindCmdLineSwitch('quickclean') then
    wbQuickClean := wbIKnowWhatImDoing;

  if FindCmdLineSwitch('TrackAllEditorID') then
    wbTrackAllEditorID := True;

  if wbToolMode in wbPluginModes then // look for the file name
    if not wbFindNextValidCmdLinePlugin(wbParamIndex, wbPluginToUse, wbDataPath) then begin
      ShowMessage(wbToolName+' mode requires a valid plugin name!');
      Exit;
    end;

  if wbToolMode = tmLODgen then begin
    wbIKnowWhatImDoing := True;
    wbAllowInternalEdit := False;
    wbShowInternalEdit := False;
    wbLoadBSAs := True;
    wbBuildRefs := False;
  end else if wbToolMode = tmScript then begin
    wbIKnowWhatImDoing := True;
    wbLoadBSAs := True;
    wbBuildRefs := True;
  end else if wbToolMode in [tmMasterUpdate, tmESMify] then begin
    wbIKnowWhatImDoing := True;
    wbAllowInternalEdit := False;
    wbShowInternalEdit := False;
    wbLoadBSAs := False;
    wbBuildRefs := False;
    wbMasterUpdateFilterONAM := wbToolMode in [tmESMify];
    if FindCmdLineSwitch('filteronam') then
      wbMasterUpdateFilterONAM := True
    else if FindCmdLineSwitch('noFilteronam') then
      wbMasterUpdateFilterONAM := True;
    if FindCmdLineSwitch('FixPersistence') then
      wbMasterUpdateFixPersistence := True
    else if FindCmdLineSwitch('NoFixPersistence') then
      wbMasterUpdateFixPersistence := False;
  end else if wbToolMode in [tmMasterRestore, tmESPify, tmCheckForDR, tmCheckForITM, tmCheckForErrors] then begin
    wbIKnowWhatImDoing := True;
    wbAllowInternalEdit := False;
    wbShowInternalEdit := False;
    wbLoadBSAs := False;
    wbBuildRefs := False;
  end else if wbToolMode = tmTranslate then begin
    wbTranslationMode := True;
  end;

  wbApplicationTitle := wbAppName + wbToolName + ' ' + VersionString;
  {$IFDEF LiteVersion}
  wbApplicationTitle := wbApplicationTitle + ' Lite';
  {$ENDIF}

  if FindCmdLineSwitch('fixuppgrd') then
    wbFixupPGRD := True;

  wbShouldLoadMOHookFile := wbFindCmdLineParam('moprofile', wbMOProfile);

  if (wbToolMode = tmEdit) and not wbIsAssociatedWithExtension('.' + wbAppName + 'pas') then try
    wbAssociateWithExtension('.' + wbAppName + 'pas', wbAppName + 'Script', wbAppName + wbToolName + ' script');
  except end;

end;

initialization
  wbDoInit;

end.
