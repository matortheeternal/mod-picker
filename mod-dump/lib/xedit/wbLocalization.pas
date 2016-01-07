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

unit wbLocalization;

{$I wbDefines.inc}

interface

uses
  Classes, SysUtils, StrUtils, Math,
  wbInterface, wbBSA;

const
  sStringID = 'STRINGID:';

type
  TwbLStringType = (
    lsDLString,
    lsILString,
    lsString
  );

  TwbLocalizationFile = class
  private
    fName        : string;
    fFileName    : string;
    fFileType    : TwbLStringType;
    fStrings     : TStrings;
    fModified    : boolean;
    fNextID      : Cardinal;

    procedure Init;
    function FileStringType(aFileName: string): TwbLStringType;
    function ReadZString(aStream: TMemoryStream): AnsiString;
    function ReadLenZString(aStream: TMemoryStream): AnsiString;
    procedure WriteZString(aStream: TMemoryStream; aString: AnsiString);
    procedure WriteLenZString(aStream: TMemoryStream; aString: AnsiString);
    procedure ReadDirectory(aStream: TMemoryStream);
  protected
    function Get(Index: Cardinal): string;
    procedure Put(Index: Cardinal; const S: string);
  public
    property Strings[Index: Cardinal]: string read Get write Put; default;
    property Items: TStrings read fStrings;
    property Name: string read fName;
    property FileName: string read fFileName;
    property Modified: boolean read fModified write fModified;
    property NextID: Cardinal read fNextID;
    constructor Create(const aFileName: string); overload;
    constructor Create(const aFileName: string; aData: TBytes); overload;
    destructor Destroy; override;
    function Count: Integer;
    function IndexToID(Index: Integer): Cardinal;
    function IDExists(ID: Cardinal): boolean;
    function AddString(ID: Integer; const S: string): boolean;
    procedure WriteToStream(const aStream: TStream);
    procedure ExportToFile(const aFileName: string);
  end;

  TwbLocalizationHandler = class
  private
    lFiles       : TStrings;
    fReuseDup    : boolean;
  protected
    function Get(Index: Integer): TwbLocalizationFile;
    function GetStringsPath: string;
  public
    NoTranslate: boolean;
    property _Files[Index: Integer]: TwbLocalizationFile read Get; default;
    property StringsPath: string read GetStringsPath;
    property ReuseDup: Boolean read fReuseDup write fReuseDup;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Count: Integer;
    function LocalizedValueDecider(aElement: IwbElement): TwbLStringType;
    function AvailableLanguages: TStringList;
    function AvailableLocalizationFiles: TStringList;
    procedure LoadForFile(aFileName: string);
    function AddLocalization(const aFileName: string): TwbLocalizationFile; overload;
    function AddLocalization(const aFileName: string; aData: TBytes): TwbLocalizationFile; overload;
    function GetValue(ID: Cardinal; aElement: IwbElement): string;
    function SetValue(ID: Cardinal; aElement: IwbElement; aValue: string): Cardinal;
    function AddValue(aValue: string; aElement: IwbElement): Cardinal;
    function GetLocalizationFileNameByElement(aElement: IwbElement): string;
    function GetLocalizationFileNameByType(aPluginFile: string; ls: TwbLStringType): string;
    procedure GetStringsFromFile(aFileName: string; const aList: TStrings);
  end;

const
  wbLocalizationExtension: array [TwbLStringType] of string = (
    '.DLSTRINGS',
    '.ILSTRINGS',
    '.STRINGS'
  );

var
  wbLocalizationHandler: TwbLocalizationHandler;

implementation

uses
  WideStrUtils;

constructor TwbLocalizationFile.Create(const aFileName: string);
var
  fs: TFileStream;
  fStream: TMemoryStream;
  Buffer: PByte;
begin
  fFileName := aFileName;
  Init;
  // cache file in mem
  fStream := TMemoryStream.Create;
  try
    fs := TFileStream.Create(aFileName, fmOpenRead or fmShareDenyNone);
    GetMem(Buffer, fs.Size);
    try
      fs.ReadBuffer(Buffer^, fs.Size);
      fStream.WriteBuffer(Buffer^, fs.Size);
      fStream.Position := 0;
      ReadDirectory(fStream);
    finally
      if Assigned(Buffer) then FreeMem(Buffer);
    end;
  finally
    FreeAndNil(fs);
    FreeAndNil(fStream);
  end;
end;

constructor TwbLocalizationFile.Create(const aFileName: string; aData: TBytes);
var
  fStream: TMemoryStream;
begin
  fFileName := aFileName;
  Init;
  fStream := TMemoryStream.Create;
  try
    fStream.WriteBuffer(aData[0], length(aData));
    fStream.Position := 0;
    ReadDirectory(fStream);
  finally
    FreeAndNil(fStream);
  end;
end;

destructor TwbLocalizationFile.Destroy;
begin
  FreeAndNil(fStrings);
  inherited;
end;

procedure TwbLocalizationFile.Init;
begin
  fModified := false;
  fName := ExtractFileName(fFileName);
  fFileType := FileStringType(fFileName);
  fStrings := TwbFastStringList.Create;
  fNextID := 1;
end;

function TwbLocalizationFile.FileStringType(aFileName: string): TwbLStringType;
var
  ext: string;
  i: TwbLStringType;
begin
  Result := lsString;
  ext := ExtractFileExt(aFileName);
  for i := Low(TwbLStringType) to High(TwbLStringType) do
    if SameText(ext, wbLocalizationExtension[i]) then
      Result := i;
end;

function TwbLocalizationFile.ReadZString(aStream: TMemoryStream): AnsiString;
var
  Position : Integer;
begin
  Position := aStream.Position;
  Result := PAnsiChar(@PByte(aStream.Memory)[Position]);
  aStream.Position := aStream.Position + Succ(Length(Result));
end;

function TwbLocalizationFile.ReadLenZString(aStream: TMemoryStream): AnsiString;
var
  Len: Cardinal;
begin
  aStream.ReadBuffer(Len, 4);
  Dec(Len); // trailing null
  SetLength(Result, Len);
  if Len > 0 then
    aStream.ReadBuffer(Result[1], Len);
end;

procedure TwbLocalizationFile.WriteZString(aStream: TMemoryStream; aString: AnsiString);
const
  z: Byte = 0;
begin
  aStream.WriteBuffer(aString[1], Length(aString));
  aStream.WriteBuffer(z, SizeOf(z));
end;

procedure TwbLocalizationFile.WriteLenZString(aStream: TMemoryStream; aString: AnsiString);
const
  z: Byte = 0;
var
  l: Cardinal;
begin
  l := Length(aString) + SizeOf(z);
  aStream.WriteBuffer(l, SizeOf(Cardinal));
  aStream.WriteBuffer(aString[1], Length(aString));
  aStream.WriteBuffer(z, SizeOf(z));
end;

procedure TwbLocalizationFile.ReadDirectory(aStream: TMemoryStream);
var
  i: integer;
  scount, id, offset: Cardinal;
  oldPos: int64;
  s: AnsiString;
begin
  if aStream.Size < 8 then
    Exit;

  aStream.Read(scount, 4); // number of strings
  aStream.Position := aStream.Position + 4; // skip dataSize
  if scount > 0 then
    for i := 0 to scount - 1 do begin
      aStream.Read(id, 4); // string ID
      aStream.Read(offset, 4); // offset of string relative to data (header + dirsize)
      oldPos := aStream.Position;
      aStream.Position := 8 + scount*8 + offset; // header + dirsize + offset
      if fFileType = lsString then
        s := ReadZString(aStream)
      else
        s := ReadLenZString(aStream);
      fStrings.AddObject(wbAnsiToString(s, nil), pointer(id));
      if Succ(id) > fNextID then
        fNextID := Succ(id);
      aStream.Position := oldPos;
    end;
end;

procedure TwbLocalizationFile.WriteToStream(const aStream: TStream);
var
  dir, data: TMemoryStream;
  i: integer;
  c: Cardinal;
begin
  dir := TMemoryStream.Create;
  data := TMemoryStream.Create;
  c := fStrings.Count;
  dir.WriteBuffer(c, SizeOf(c)); // number of strings
  dir.WriteBuffer(c, SizeOf(c)); // dataSize, will overwrite later
  try
    for i := 0 to Pred(fStrings.Count) do begin
      c := Cardinal(fStrings.Objects[i]);
      dir.WriteBuffer(c, SizeOf(c)); // ID
      c := data.Position;
      dir.WriteBuffer(c, SizeOf(c)); // relative position
      if fFileType = lsString then
        WriteZString(data, wbStringToAnsi(fStrings[i], nil))
      else
        WriteLenZString(data, wbStringToAnsi(fStrings[i], nil));
    end;
    c := data.Size;
    dir.Position := 4;
    dir.WriteBuffer(c, SizeOf(c)); // dataSize

    aStream.CopyFrom(dir, 0);
    aStream.CopyFrom(data, 0);
  finally
    FreeAndNil(dir);
    FreeAndNil(data);
  end;
end;

function TwbLocalizationFile.Count: Integer;
begin
  Result := fStrings.Count;
end;

function TwbLocalizationFile.IndexToID(Index: Integer): Cardinal;
begin
  if Index < Count then
    Result := Cardinal(fStrings.Objects[Index])
  else
    Result := 0;
end;

function TwbLocalizationFile.IDExists(ID: Cardinal): boolean;
begin
  Result := fStrings.IndexOfObject(Pointer(ID)) <> -1;
end;

function TwbLocalizationFile.Get(Index: Cardinal): string;
var
  idx: integer;
begin
  Result := '';
  idx := fStrings.IndexOfObject(Pointer(Index));
  if idx <> -1 then
    Result := fStrings[idx]
  else
    Result := '<Error: Unknown lstring ID ' + IntToHex(Index, 8) + '>';
end;

procedure TwbLocalizationFile.Put(Index: Cardinal; const S: string);
var
  idx: integer;
begin
  idx := fStrings.IndexOfObject(Pointer(Index));
  if idx <> -1 then
    if fStrings[idx] <> S then begin
      fStrings[idx] := S;
      fModified := true;
    end;
end;

function TwbLocalizationFile.AddString(ID: Integer; const S: string): boolean;
begin
  Result := false;
  if ID < NextID then
    Exit;

  fStrings.AddObject(S, Pointer(ID));
  fNextID := Succ(ID);
  fModified := true;

  Result := true;
end;

procedure TwbLocalizationFile.ExportToFile(const aFileName: string);
var
  i: integer;
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    for i := 0 to Pred(fStrings.Count) do begin
      sl.Add('[' + IntToHex(Integer(fStrings.Objects[i]), 8) + ']');
      sl.Add(fStrings[i]);
    end;
    sl.SaveToFile(aFileName);
  finally
    FreeAndNil(sl);
  end;
end;

constructor TwbLocalizationHandler.Create;
begin
  lFiles := TwbFastStringListCS.CreateSorted;
  fReuseDup := false;
  NoTranslate := false;
end;

destructor TwbLocalizationHandler.Destroy;
begin
  Clear;
  FreeAndNil(lFiles);
end;

function TwbLocalizationHandler.Count: Integer;
begin
  Result := lFiles.Count;
end;

procedure TwbLocalizationHandler.Clear;
var
  i: integer;
begin
  for i := 0 to Pred(Count) do
    _Files[i].Destroy;
  lFiles.Clear;
end;

function TwbLocalizationHandler.Get(Index: Integer): TwbLocalizationFile;
begin
  if Index < Count then
    Result := TwbLocalizationFile(lFiles.Objects[Index])
  else
    Result := nil;
end;

function TwbLocalizationHandler.AddLocalization(const aFileName: string): TwbLocalizationFile;
begin
  Result := TwbLocalizationFile.Create(aFileName);
  lFiles.AddObject(ExtractFileName(aFileName), Result);
end;

function TwbLocalizationHandler.AddLocalization(const aFileName: string; aData: TBytes): TwbLocalizationFile;
begin
  Result := TwbLocalizationFile.Create(aFileName, aData);
  lFiles.AddObject(ExtractFileName(aFileName), Result);
end;

function TwbLocalizationHandler.LocalizedValueDecider(aElement: IwbElement): TwbLStringType;
var
  sigElement, sigRecord: TwbSignature;
  aRecord: IwbSubRecord;
begin
  if Supports(aElement, IwbSubRecord, aRecord) then
    sigElement := aRecord.Signature
  else
    sigElement := '';

  sigRecord := aElement.ContainingMainRecord.Signature;

  if (sigRecord <> 'LSCR') and (sigElement = 'DESC') then Result := lsDLString else // DESC always from dlstrings except LSCR
  if (sigRecord = 'QUST') and (sigElement = 'CNAM') then Result := lsDLString else // quest log entry
  if (sigRecord = 'BOOK') and (sigElement = 'CNAM') then Result := lsDLString else // Book CNAM description
  if (sigRecord = 'INFO') and (sigElement <> 'RNAM') then Result := lsILString else // dialog, RNAM are lsString, others lsILString
    Result := lsString; // others
end;

function TwbLocalizationHandler.GetStringsPath: string;
begin
  Result := wbDataPath + 'Strings\';
end;

function TwbLocalizationHandler.AvailableLanguages: TStringList;
var
  F: TSearchRec;
  p: integer;
  s: string;
begin
  Result := TStringList.Create;
  if FindFirst(StringsPath + '*.*STRINGS', faAnyFile, F) = 0 then try
    repeat
      s := LowerCase(ChangeFileExt(F.Name, ''));
      p := LastDelimiter('_', s);
      if p > 0 then begin
        s := Copy(s, p + 1, length(s));
        if s = '' then Continue;
        s := AnsiUpperCase(s[1]) + Copy(s, 2, Length(s));
        if Result.IndexOf(s) = -1 then
          Result.Add(s);
      end;
    until FindNext(F) <> 0;
  finally
    FindClose(F);
  end;
end;

function TwbLocalizationHandler.AvailableLocalizationFiles: TStringList;
var
  F: TSearchRec;
begin
  Result := TStringList.Create;
  if FindFirst(StringsPath + '*.*STRINGS', faAnyFile, F) = 0 then try
    repeat
      Result.Add(F.Name);
    until FindNext(F) <> 0;
  finally
    FindClose(F);
  end;
end;

procedure TwbLocalizationHandler.LoadForFile(aFileName: string);
var
  ls: TwbLStringType;
  s: string;
  res: TDynResources;
begin
  if not Assigned(wbContainerHandler) then
    Exit;

  for ls := Low(TwbLStringType) to High(TwbLStringType) do begin
    s := wbLocalizationHandler.GetLocalizationFileNameByType(aFileName, ls);
    if lFiles.IndexOf(ExtractFileName(s)) = -1 then begin
      res := wbContainerHandler.OpenResource(s);
      if length(res) > 0 then begin
        //wbProgressCallback('[' + s + '] Loading Localization.');
        wbLocalizationHandler.AddLocalization(wbDataPath + s, res[High(res)].GetData);
      end;
    end;
  end;
end;

function TwbLocalizationHandler.GetLocalizationFileNameByType(aPluginFile: string; ls: TwbLStringType): string;
begin
  Result := Format('%s_%s%s', [
    ChangeFileExt(aPluginFile, ''),
    wbLanguage,
    wbLocalizationExtension[ls]
  ]);
  // relative path to Data folder
  Result := 'Strings\' + Result;
end;

function TwbLocalizationHandler.GetLocalizationFileNameByElement(aElement: IwbElement): string;
begin
  Result := '';

  if not Assigned(aElement) then
    Exit;

  Result := GetLocalizationFileNameByType(aElement._File.FileName, LocalizedValueDecider(aElement));
end;

// create a new lstring from aValue for aElement
function TwbLocalizationHandler.AddValue(aValue: string; aElement: IwbElement): Cardinal;
var
  ls: TwbLStringType;
  FileName: string;
  wblf: array [TwbLStringType] of TwbLocalizationFile;
  idx: integer;
  data: TBytes;
  ID: Cardinal;
begin
  Result := 0;

  if not Assigned(aElement) then
    Exit;

  if aValue = '' then
    Exit;

  // create localization files if absent
  try
    ID := 1;
    for ls := Low(TwbLStringType) to High(TwbLStringType) do begin
      FileName := GetLocalizationFileNameByType(aElement._File.FileName, ls);
      idx := lFiles.IndexOf(ExtractFileName(FileName));
      if idx = -1 then begin
        wblf[ls] := AddLocalization(wbDataPath + FileName, data);
        wblf[ls].Modified := true;
      end else
        wblf[ls] := _Files[idx];

      if wblf[ls].NextID > ID then
        ID := wblf[ls].NextID;
    end;

    ls := LocalizedValueDecider(aElement);

    // detect a duplicate string
    if ReuseDup then begin
      idx := wblf[ls].fStrings.IndexOf(aValue);
      if idx <> -1 then ID := Cardinal(wblf[ls].fStrings.Objects[idx]) else
        wblf[ls].AddString(ID, aValue);
    end else
      wblf[ls].AddString(ID, aValue);

    Result := ID;
  finally

  end;
end;

function TwbLocalizationHandler.SetValue(ID: Cardinal; aElement: IwbElement; aValue: string): Cardinal;
var
  idx: integer;
  FileName: string;
begin
  Result := ID;

  if not Assigned(aElement) then
    Exit;

  FileName := GetLocalizationFileNameByElement(aElement);
  idx := lFiles.IndexOf(ExtractFileName(FileName));

  if (idx = -1) or (ID = 0) then begin
    // new string
    Result := AddValue(aValue, aElement);
    Exit;
  end;

  if not _Files[idx].IDExists(ID) then
    // string doesn't exist, create new
    Result := AddValue(aValue, aElement)
  else
    // modify existing
    _Files[idx][ID] := aValue;
end;


function TwbLocalizationHandler.GetValue(ID: Cardinal; aElement: IwbElement): string;
var
  lFileName: string;
  idx: integer;
begin
  Result := '';

  if NoTranslate then begin
    Result := IntToHex(ID, 8);
    Exit;
  end;

  if ID = 0 then
    Exit;

  lFileName := ExtractFileName(GetLocalizationFileNameByElement(aElement));

  if lFileName = '' then
    Exit;

  idx := lFiles.IndexOf(lFileName);

  // load strings files if absent
  if idx = - 1 then
    LoadForFile(aElement._File.FileName);

  // get file again
  idx := lFiles.IndexOf(lFileName);
  if idx = - 1 then begin
    Result := '<Error: No strings file for lstring ID ' + IntToHex(ID, 8) + '>';
    Exit;
  end;

  Result := _Files[idx][ID];
end;

procedure TwbLocalizationHandler.GetStringsFromFile(aFileName: string; const aList: TStrings);
var
  i: integer;
begin
  if not Assigned(aList) then
    Exit;

  for i := 0 to Pred(lFiles.Count) do
    if SameText(lFiles[i], aFileName) then begin
      aList.Assign(_Files[i].fStrings);
      Break;
    end;
end;


initialization
  wbLocalizationHandler := TwbLocalizationHandler.Create;
finalization
  FreeAndNil(wbLocalizationHandler);
end.
