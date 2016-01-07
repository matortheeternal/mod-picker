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

unit wbHelpers;

{$I wbDefines.inc}

interface

uses
  Classes,
  Windows,
  SysUtils,
  Graphics,
  ShellAPI,
  ShlObj,
  IniFiles,
  Registry,
  wbInterface,
  Imaging,
  ImagingTypes;

function wbDistance(const a, b: TwbVector): Single; overload
function wbDistance(const a, b: IwbMainRecord): Single; overload;
function wbStringToSignatures(aSignatures: string): TwbSignatures;
function wbGetSiblingREFRsWithin(const aMainRecord: IwbMainRecord; aDistance: Single): TDynMainRecords;
function wbGetSiblingRecords(const aElement: IwbElement; aSignatures: TwbSignatures; aOverrides: Boolean): TDynMainRecords;
function FindMatchText(Strings: TStrings; const Str: string): Integer;
function IsFileESM(const aFileName: string): Boolean;
function IsFileESP(const aFileName: string): Boolean;
procedure DeleteDirectory(const DirName: string);
function FullPathToFilename(aString: string): string;
procedure wbFlipBitmap(aBitmap: TBitmap; MirrorType: Integer); // MirrorType: 1 - horizontal, 2 - vertical, 0 - both
function wbAlphaBlend(DestDC, X, Y, Width, Height,
  SrcDC, SrcX, SrcY, SrcWidth, SrcHeight, Alpha: integer): Boolean;
procedure SaveFont(aIni: TMemIniFile; aSection, aName: string; aFont: TFont);
procedure LoadFont(aIni: TMemIniFile; aSection, aName: string; aFont: TFont);
function wbDDSDataToBitmap(aData: TBytes; Bitmap: TBitmap): Boolean;
function wbDDSStreamToBitmap(aStream: TStream; Bitmap: TBitmap): Boolean;
function wbCRC32Data(aData: TBytes): Cardinal;
function wbCRC32File(aFileName: string): Cardinal;
function wbDecodeCRCList(const aList: string): TDynCardinalArray;
function wbSHA1Data(aData: TBytes): string;
function wbSHA1File(aFileName: string): string;
function wbMD5Data(aData: TBytes): string;
function wbMD5File(aFileName: string): string;
function wbIsAssociatedWithExtension(aExt: string): Boolean;
function wbAssociateWithExtension(aExt, aName, aDescr: string): Boolean;

type
  PnxLeveledListCheckCircularStack = ^TnxLeveledListCheckCircularStack;
  TnxLeveledListCheckCircularStack = record
    rllcLast       : PnxLeveledListCheckCircularStack;
    rllcMainRecord : IwbMainRecord;
  end;

procedure wbLeveledListCheckCircular(const aMainRecord: IwbMainRecord; aStack: PnxLeveledListCheckCircularStack);

type
  TnxFastStringList = class(TStringList)
  protected
    function CompareStrings(const S1, S2: string): Integer; override;
  public
    constructor CreateSorted(aDups : TDuplicates = dupError);

    procedure Clear(aFreeObjects: Boolean = False); reintroduce;
  end;

  TnxFastStringListCS = class(TnxFastStringList)
  public
    procedure AfterConstruction; override;
  end;

  TnxFastStringListIC = class(TnxFastStringList)
  end;

function wbExtractNameFromPath(aPathName: String): String;

function wbCounterAfterSet(aCounterName: String; const aElement: IwbElement): Boolean;
function wbCounterByPathAfterSet(aCounterName: String; const aElement: IwbElement): Boolean;
function wbCounterContainerAfterSet(aCounterName: String; anArrayName: String; const aElement: IwbElement; DeleteOnEmpty: Boolean = False): Boolean;
function wbCounterContainerByPathAfterSet(aCounterName: String; anArrayName: String; const aElement: IwbElement): Boolean;
function wbFormVerDecider(aBasePtr: Pointer; aEndPtr: Pointer; const aElement: IwbElement; aMinimum: Integer): Integer;
function wbFormVer78Decider(aBasePtr: Pointer; aEndPtr: Pointer; const aElement: IwbElement): Integer;

// BSA helper

function MakeDataFileName(FileName, DataPath: String): String;
function FindBSAs(IniName, DataPath: String; var bsaNames: TStringList; var bsaMissing: TStringList): Integer;
function HasBSAs(ModName, DataPath: String; Exact, modini: Boolean; var bsaNames: TStringList; var bsaMissing: TStringList): Integer;

implementation

uses
  wbSort;

procedure wbLeveledListCheckCircular(const aMainRecord: IwbMainRecord; aStack: PnxLeveledListCheckCircularStack);
var
  Stack    : TnxLeveledListCheckCircularStack;
  s          : string;
  CER        : IwbContainerElementRef;
  LLE        : IwbContainerElementRef;
  i          : Integer;
  LVLO       : IwbContainerElementRef;
  Reference  : IwbContainerElementRef;
  MainRecord : IwbMainRecord;
begin
  Stack.rllcLast := aStack;
  Stack.rllcMainRecord := aMainRecord;

  while Assigned(aStack) do begin
    if aStack.rllcMainRecord.LoadOrderFormID = aMainRecord.LoadOrderFormID then begin
      s := aMainRecord.Name;
      aStack := Stack.rllcLast;
      while Assigned(aStack) do begin
        s := ' -> ' + s;
        s := aStack.rllcMainRecord.Name + s;
        if aStack.rllcMainRecord.LoadOrderFormID = aMainRecord.LoadOrderFormID then
          Break;
        aStack := aStack.rllcLast;
      end;
      s := 'Circular Leveled List found: ' + s;
      raise Exception.Create(s);
    end;
    aStack := aStack.rllcLast;
  end;

  if aMainRecord.IsTagged then
    Exit;
  aMainRecord.Tag;

  if Supports(aMainRecord, IwbContainerElementRef, CER) then begin
    if Supports(CER.ElementByName['Leveled List Entries'], IwbContainerElementRef, LLE) then begin
      for i := 0 to Pred(LLE.ElementCount) do
        if Supports(LLE.Elements[i], IwbContainerElementRef, LVLO) then begin
          if Supports(LVLO.ElementByName['Reference'], IwbContainerElementRef, Reference) then begin
            if Supports(Reference.LinksTo, IwbMainRecord, MainRecord) then begin
              if (MainRecord.Signature = aMainRecord.Signature) then begin
                MainRecord := MainRecord.WinningOverride;
                wbLeveledListCheckCircular(MainRecord, @Stack);
              end;
            end;
          end;
        end;
    end;
  end;
end;

function Vec3Subtract(out vOut: TwbVector; const v1, v2: TwbVector): TwbVector;
begin
  with vOut do
  begin
    x:= v1.x - v2.x;
    y:= v1.y - v2.y;
    z:= v1.z - v2.z;
  end;
  Result := vOut;
end;

function Vec3Length(const v: TwbVector): Single;
begin
  with v do Result:= Sqrt(x*x + y*y + z*z);
end;

function wbDistance(const a, b: TwbVector): Single;
var
  t: TwbVector;
begin
  Result := Vec3Length(Vec3Subtract(t,a,b));
end;

function wbDistance(const a, b: IwbMainRecord): Single; overload;
var
  PosA, PosB: TwbVector;
begin
  if not a.GetPosition(PosA) then
    raise Exception.Create('GetPosition failed');
  if not b.GetPosition(PosB) then
    raise Exception.Create('GetPosition failed');
  Result := wbDistance(PosA, PosB);
end;

function wbStringToSignatures(aSignatures: string): TwbSignatures;
var
  i: integer;
  s: AnsiString;
begin
  with TStringList.Create do try
    if Pos(',', aSignatures) <> 0 then Delimiter := ',' else Delimiter := ' ';
    StrictDelimiter := True;
    DelimitedText := aSignatures;
    for i := 0 to Pred(Count) do begin
      s := AnsiString(Strings[i]);
      if Length(s) >= SizeOf(TwbSignature) then begin
        SetLength(Result, Succ(Length(Result)));
        System.Move(s[1], Result[Pred(Length(Result))][0], SizeOf(TwbSignature));
      end;
    end;
  finally
    Free;
  end;
end;

function wbGetSiblingREFRsWithin(const aMainRecord: IwbMainRecord; aDistance: Single): TDynMainRecords;
var
  Count       : Integer;
  Position    : TwbVector;
  MaxLoadOrder: Integer;

  procedure FindREFRs(const aElement: IwbElement);
  var
    MainRecord : IwbMainRecord;
    Container  : IwbContainerElementRef;
    i          : Integer;
    Temp       : TwbVector;
  begin
    if Supports(aElement, IwbMainRecord, MainRecord) then begin
      if not (aMainRecord.LoadOrderFormID = MainRecord.LoadOrderFormID) and
        MainRecord.GetPosition(Temp) and
        (wbDistance(Temp,Position) <= aDistance) then begin

        if High(Result) < Count then
          SetLength(Result, Length(Result) * 2);
        Result[Count] := MainRecord.HighestOverrideOrSelf[MaxLoadOrder];
        Inc(Count);

      end;
    end else
      if Supports(aElement, IwbContainerElementRef, Container) then
        for i := 0 to Pred(Container.ElementCount) do
          FindREFRs(Container.Elements[i]);
  end;

var
  GroupRecord : IwbGroupRecord;
  CellMaster  : IwbMainRecord;
  i, j        : Integer;
begin
  Result := nil;
  if not aMainRecord.GetPosition(Position) then
    Exit;
  if not Supports(aMainRecord.Container, IwbGroupRecord, GroupRecord) then
    Exit;
  if not (GroupRecord.GroupType in [8..10]) then
    Exit;
  CellMaster := GroupRecord.ChildrenOf;
  if not Assigned(CellMaster) then
    Exit;
  CellMaster := CellMaster.MasterOrSelf;
  MaxLoadOrder := aMainRecord._File.LoadOrder;

  Count := 0;
  SetLength(Result, 1024);
  FindREFRs(CellMaster.ChildGroup);
  for i := 0 to Pred(CellMaster.OverrideCount) do
    if CellMaster.Overrides[i]._File.LoadOrder <= aMainRecord._File.LoadOrder then
      FindREFRs(CellMaster.Overrides[i])
    else
      Break;
  SetLength(Result, Count);


  if Length(Result) > 1 then begin
    wbMergeSort(@Result[0], Length(Result), CompareElementsFormIDAndLoadOrder);

    j := 0;
    for i := Succ(Low(Result)) to High(Result) do begin
      if (Result[j].LoadOrderFormID <> Result[i].LoadOrderFormID) and not (Result[j].IsDeleted) then
        Inc(j);
      if j <> i then
        Result[j] := Result[i];
    end;
    SetLength(Result, Succ(j));
  end;
end;

function wbGetSiblingRecords(const aElement: IwbElement; aSignatures: TwbSignatures; aOverrides: Boolean): TDynMainRecords;

  procedure FindRecords(const aElement: IwbElement; var aSignatures: TwbSignatures; var Records: TDynMainRecords; var Count: Integer);
  var
    MainRecord : IwbMainRecord;
    Container  : IwbContainerElementRef;
    i          : Integer;
  begin
    if Supports(aElement, IwbMainRecord, MainRecord) then begin
      for i := Low(aSignatures) to High(aSignatures) do
        if MainRecord.Signature = aSignatures[i] then begin
          if High(Records) < Count then
            SetLength(Records, Length(Records) * 2);
          Records[Count] := MainRecord;
          Inc(Count);
          Break;
        end;
    end else if Supports(aElement, IwbContainerElementRef, Container) then
      for i := 0 to Pred(Container.ElementCount) do
        FindRecords(Container.Elements[i], aSignatures, Records, Count);
  end;

var
  MainRecord, Master  : IwbMainRecord;
  i, j, Count         : Integer;
begin
  Count := 0;
  SetLength(Result, 4096);
  if Supports(aElement, IwbMainRecord, MainRecord) then begin
    FindRecords(MainRecord.ChildGroup, aSignatures, Result, Count);
    // include overrides from plugins loaded later for that record
    if aOverrides then begin
      Master := MainRecord.MasterOrSelf;
      for i := 0 to Pred(Master.OverrideCount) do
        if Master.Overrides[i]._File.LoadOrder > MainRecord._File.LoadOrder then
          FindRecords(Master.Overrides[i].ChildGroup, aSignatures, Result, Count);
    end;
  end else
    // if Group or File object is passed, no overrides
    FindRecords(aElement, aSignatures, Result, Count);

  SetLength(Result, Count);
  // removing duplicates (overridden records)
  if aOverrides and (Length(Result) > 1) then begin
    wbMergeSort(@Result[0], Length(Result), CompareElementsFormIDAndLoadOrder);
    j := 0;
    for i := Succ(Low(Result)) to High(Result) do begin
      if Result[j].LoadOrderFormID <> Result[i].LoadOrderFormID then
        Inc(j);
      if j <> i then
        Result[j] := Result[i];
    end;
    SetLength(Result, Succ(j));
  end;
end;

function FindMatchText(Strings: TStrings; const Str: string): Integer;
begin
  for Result := 0 to Strings.Count-1 do
    if SameText(Strings[Result], Str) then
      Exit;
  Result := -1;
end;

function IsFileESM(const aFileName: string): Boolean;
const
  ghostesm = '.esm.ghost';
begin
  Result := SameText(ExtractFileExt(aFileName), '.esm') or
    SameText(Copy(aFileName, Length(aFileName) - Length(ghostesm) + 1, Length(ghostesm)), ghostesm)
end;

function IsFileESP(const aFileName: string): Boolean;
const
  ghostesp = '.esp.ghost';
begin
  Result := SameText(ExtractFileExt(aFileName), '.esp') or
    SameText(Copy(aFileName, Length(aFileName) - Length(ghostesp) + 1, Length(ghostesp)), ghostesp)
end;

procedure DeleteDirectory(const DirName: string);
var
  FileOp: TSHFileOpStruct;
begin
  FillChar(FileOp, SizeOf(FileOp), 0);
  FileOp.wFunc := FO_DELETE;
  FileOp.pFrom := PChar(DirName+#0);//double zero-terminated
  FileOp.fFlags := FOF_SILENT or FOF_NOERRORUI or FOF_NOCONFIRMATION;
  SHFileOperation(FileOp);
end;

function FullPathToFilename(aString: string): string;
var
  i: Integer;
  s: string;
begin
  s := aString;
  for i := Length(s) downto 1 do
    if Copy(s, i, 3) = ' \ ' then begin
      Delete(s, i, 1);
      Delete(s, i+1, 1);
    end else if Copy(s, i, 2) = ' \' then begin
      Delete(s, i, 1);
  	end else if s[i] = '"' then
      s[i] := ''''
  	else if s[i] = ':' then
      s[i] := '-'
  	else if s[i] = '/' then
      s[i] := ' ';
  while (Length(s)>0) and (s[Length(s)]=' ') do
    Delete(s, Length(s), 1);
  Result := s;
end;

procedure wbFlipBitmap(aBitmap: TBitmap; MirrorType: Integer);
var
  MemBmp: TBitmap;
  Dest: TRect;
begin
  if not Assigned(aBitmap) then
    Exit;

  MemBmp := TBitmap.Create;
  try
    MemBmp.Assign(aBitmap);
    case MirrorType of
      1:
        begin
          Dest.Left := MemBmp.Width;
          Dest.Top := 0;
          Dest.Right := -MemBmp.Width;
          Dest.Bottom := MemBmp.Height
        end;
      2:
        begin
          Dest.Left := 0;
          Dest.Top := MemBmp.Height;
          Dest.Right := MemBmp.Width;
          Dest.Bottom := -MemBmp.Height
        end;
      0:
        begin
          Dest.Left := MemBmp.Width;
          Dest.Top := MemBmp.Height;
          Dest.Right := -MemBmp.Width;
          Dest.Bottom := -MemBmp.Height
        end;
    end;
    StretchBlt(MemBmp.Canvas.Handle, Dest.Left, Dest.Top, Dest.Right, Dest.Bottom,
               MemBmp.Canvas.Handle, 0, 0, MemBmp.Width, MemBmp.Height,
               SRCCOPY);
    aBitmap.Assign(MemBmp);
  finally
    FreeAndNil(MemBmp);
  end;
end;

function wbAlphaBlend(DestDC, X, Y, Width, Height,
  SrcDC, SrcX, SrcY, SrcWidth, SrcHeight, Alpha: integer): Boolean;
var
  BlendFunc: TBlendFunction;
begin
  BlendFunc.BlendOp := AC_SRC_OVER;
  BlendFunc.BlendFlags := 0;
  BlendFunc.SourceConstantAlpha := Alpha;
  if Alpha = 255 then
    BlendFunc.AlphaFormat := AC_SRC_ALPHA
  else
    BlendFunc.AlphaFormat := 0;
  Result := Windows.AlphaBlend(DestDC, X, Y, Width, Height, SrcDC, SrcX, SrcY, SrcWidth, SrcHeight, BlendFunc);
end;

procedure SaveFont(aIni: TMemIniFile; aSection, aName: string; aFont: TFont);
begin
  aIni.WriteString(aSection, aName + 'Name', aFont.Name);
  aIni.WriteInteger(aSection, aName + 'CharSet', aFont.CharSet);
  aIni.WriteInteger(aSection, aName + 'Color', aFont.Color);
  aIni.WriteInteger(aSection, aName + 'Size', aFont.Size);
  aIni.WriteInteger(aSection, aName + 'Style', Byte(aFont.Style));
end;

procedure LoadFont(aIni: TMemIniFile; aSection, aName: string; aFont: TFont);
begin
  aFont.Name    := aIni.ReadString(aSection, aName + 'Name', aFont.Name);
  aFont.CharSet := TFontCharSet(aIni.ReadInteger(aSection, aName + 'CharSet', aFont.CharSet));
  aFont.Color   := TColor(aIni.ReadInteger(aSection, aName + 'Color', aFont.Color));
  aFont.Size    := aIni.ReadInteger(aSection, aName + 'Size', aFont.Size);
  aFont.Style   := TFontStyles(Byte(aIni.ReadInteger(aSection, aName + 'Style', Byte(aFont.Style))));
end;

var
  crctbl: array[0..7] of array[0..255] of cardinal;

procedure CRCInit;
var
  c: cardinal;
  i, j: integer;
begin;
  for i:=0 to 255 do begin;
    c:=i;
    for j:=1 to 8 do if odd(c)
                     then c:=(c shr 1) xor $EDB88320
                     else c:=(c shr 1);
    crctbl[0][i]:=c;
    end;

  for i:=0 to 255 do begin;
    c:=crctbl[0][i];
    for j:=1 to 7 do begin;
      c:=(c shr 8) xor crctbl[0][byte(c)];
      crctbl[j][i]:=c;
      end;
    end;
end;

function ShaCrcRefresh(OldCRC: cardinal; BufPtr: pointer; BufLen: integer): cardinal;
// Fast CRC32 calculator
// (c) Aleksandr Sharahov 2009
// Free for any use
asm
  test edx, edx
  jz   @ret
  neg  ecx
  jz   @ret
  push ebx
@head:
  test dl, 3
  jz   @bodyinit
  movzx ebx, byte [edx]
  inc  edx
  xor  bl, al
  shr  eax, 8
  xor  eax, [ebx*4 + crctbl]
  inc  ecx
  jnz  @head
  pop  ebx
@ret:
  ret
@bodyinit:
  sub  edx, ecx
  add  ecx, 8
  jg   @bodydone
  push esi
  push edi
  mov  edi, edx
  mov  edx, eax
@bodyloop:
  mov ebx, [edi + ecx - 4]
  xor edx, [edi + ecx - 8]
  movzx esi, bl
  mov eax, [esi*4 + crctbl + 1024*3]
  movzx esi, bh
  xor eax, [esi*4 + crctbl + 1024*2]
  shr ebx, 16
  movzx esi, bl
  xor eax, [esi*4 + crctbl + 1024*1]
  movzx esi, bh
  xor eax, [esi*4 + crctbl + 1024*0]

  movzx esi, dl
  xor eax, [esi*4 + crctbl + 1024*7]
  movzx esi, dh
  xor eax, [esi*4 + crctbl + 1024*6]
  shr edx, 16
  movzx esi, dl
  xor eax, [esi*4 + crctbl + 1024*5]
  movzx esi, dh
  xor eax, [esi*4 + crctbl + 1024*4]

  add ecx, 8
  jg  @done

  mov ebx, [edi + ecx - 4]
  xor eax, [edi + ecx - 8]
  movzx esi, bl
  mov edx, [esi*4 + crctbl + 1024*3]
  movzx esi, bh
  xor edx, [esi*4 + crctbl + 1024*2]
  shr ebx, 16
  movzx esi, bl
  xor edx, [esi*4 + crctbl + 1024*1]
  movzx esi, bh
  xor edx, [esi*4 + crctbl + 1024*0]

  movzx esi, al
  xor edx, [esi*4 + crctbl + 1024*7]
  movzx esi, ah
  xor edx, [esi*4 + crctbl + 1024*6]
  shr eax, 16
  movzx esi, al
  xor edx, [esi*4 + crctbl + 1024*5]
  movzx esi, ah
  xor edx, [esi*4 + crctbl + 1024*4]

  add ecx, 8
  jle @bodyloop
  mov eax, edx
@done:
  mov edx, edi
  pop edi
  pop esi
@bodydone:
  sub ecx, 8
  jl @tail
  pop ebx
  ret
@tail:
  movzx ebx, byte [edx + ecx];
  xor bl,al;
  shr eax,8;
  xor eax, [ebx*4 + crctbl];
  inc ecx;
  jnz @tail;
  pop ebx
  ret
end;

function wbCRC32Data(aData: TBytes): Cardinal;
begin
  Result := not ShaCrcRefresh($FFFFFFFF, @aData[0], Length(aData));
end;

function wbCRC32File(aFileName: string): Cardinal;
var
  Data: TBytes;
begin
  Result := 0;
  if FileExists(aFileName) then
    with TFileStream.Create(aFileName, fmOpenRead + fmShareDenyNone) do try
      SetLength(Data, Size);
      ReadBuffer(Data[0], Length(Data));
      Result := wbCRC32Data(Data);
    finally
      Free;
    end;
end;

function wbDecodeCRCList(const aList: string): TDynCardinalArray;
var
  i: Integer;
  s: string;
  j: Int64;
begin
  Result := nil;
  try
    with TStringList.Create do try
      CommaText := aList;
      for i := 0 to Pred(Count) do begin
        s := Trim(Strings[i]);
        if Length(s) <> 8 then
          Abort;
        j := StrToInt64('$'+s);
        if (j < Low(Cardinal)) or (j > High(Cardinal)) then
          Abort;
        SetLength(Result, Succ(Length(Result)));
        Result[High(Result)] := j;
      end;
    finally
      Free;
    end;
  except
    SetLength(Result, 1);
    Result[0] := $FFFFFFFF;
  end;
end;

function CryptAcquireContext(var phProv: DWORD;
  pszContainer, pszProvider: LPCSTR; dwProvType, dwFlags: DWORD): BOOL;
  stdcall; external advapi32 name 'CryptAcquireContextA';
function CryptCreateHash(hProv,Algid,hKey,dwFlags: DWORD;
  var phHash: DWORD): BOOL; stdcall; external advapi32;
function CryptHashData(hHash: DWORD; pbData: PBYTE; dwDataLen,
  dwFlags: DWORD): BOOL; stdcall; external advapi32;
function CryptGetHashParam(hHash, dwParam: DWORD; pbData: PBYTE;
  var pdwDataLen: DWORD; dwFlags: DWORD): BOOL; stdcall; external advapi32;
function CryptDestroyHash(hHash: DWORD): BOOL; stdcall; external advapi32;
function CryptReleaseContext(hProv: DWORD; dwFlags: DWORD): BOOL; stdcall; external advapi32;

function CryptoAPIGetHash(Data: Pointer; nSize: Cardinal; HashType: Cardinal): TBytes;
const
  HP_HASHVAL           = $0002; {hash value}
  PROV_RSA_FULL        = 1;
  CRYPT_VERIFYCONTEXT  = $F0000000;
var
  hProv, hHash: Cardinal;
begin
  if CryptAcquireContext(hProv, nil, nil, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT) then try
    if CryptCreateHash(hProv, HashType, 0, 0, hHash) then try
      if CryptHashData(hHash, Data, nSize, 0) then begin
        if CryptGetHashParam(hHash, HP_HASHVAL, nil, nSize, 0) then begin
          SetLength(Result, nSize);
          if not CryptGetHashParam(hHash, HP_HASHVAL, @Result[0], nSize, 0) then
            SetLength(Result, 0);
        end;
      end;
    finally
      CryptDestroyHash(hHash);
    end;
  finally
    CryptReleaseContext(hProv, 0);
  end;
end;

const
  ALG_CRC32 = $0001;
  ALG_MD2 = $8001;
  ALG_MD4 = $8002;
  ALG_MD5 = $8003;
  ALG_SHA = $8004;

function wbCryptoApiHashData(aData: TBytes; aALG: Cardinal): string;
  function BytesToHexStr(aBytes: TBytes): string;
  var
    i: Cardinal;
    bt: Byte;
  const
    Hex = '0123456789abcdef';
  begin
    Result:= '';
    for i:= Low(aBytes) to High(aBytes) do begin
      bt := aBytes[i];
      Result:= Result + Hex[bt shr $4 + 1] + Hex[bt and $0f + 1]
    end;
  end;
begin
  Result := BytesToHexStr(CryptoAPIGetHash(@aData[0], Length(aData), aALG));
end;

function wbSHA1Data(aData: TBytes): string;
begin
  Result := wbCryptoApiHashData(aData, ALG_SHA);
end;

function wbSHA1File(aFileName: string): string;
var
  Data: TBytes;
begin
  Result := '';
  if FileExists(aFileName) then
    with TFileStream.Create(aFileName, fmOpenRead + fmShareDenyNone) do try
      SetLength(Data, Size);
      ReadBuffer(Data[0], Length(Data));
      Result := wbSHA1Data(Data);
    finally
      Free;
    end;
end;

function wbMD5Data(aData: TBytes): string;
begin
  Result := wbCryptoApiHashData(aData, ALG_MD5);
end;

function wbMD5File(aFileName: string): string;
var
  Data: TBytes;
begin
  Result := '';
  if FileExists(aFileName) then
    with TFileStream.Create(aFileName, fmOpenRead + fmShareDenyNone) do try
      SetLength(Data, Size);
      ReadBuffer(Data[0], Length(Data));
      Result := wbMD5Data(Data);
    finally
      Free;
    end;
end;


{ TnxFastStringList }

procedure TnxFastStringList.Clear(aFreeObjects: Boolean);
var
  i: Integer;
begin
  if aFreeObjects then
    for i := 0 to Pred(Count) do
      Objects[i].Free;
  inherited Clear;
end;

function TnxFastStringList.CompareStrings(const S1, S2: string): Integer;
begin
  {x$IFDEF DCC6OrLater}
  if CaseSensitive then
    Result := CompareStr(S1, S2)
  else
  {x$ENDIF}
    Result := CompareText(S1, S2);
end;

constructor TnxFastStringList.CreateSorted(aDups: TDuplicates);
begin
  Create;
  Duplicates := aDups;
  Sorted := True;
end;

{ TnxFastStringListCS }

procedure TnxFastStringListCS.AfterConstruction;
begin
  inherited;
  {x$IFDEF DCC6OrLater}
  CaseSensitive := True;
  {x$ENDIF}
end;

function wbExtractNameFromPath(aPathName: String): String;
begin
  Result := aPathName;
  while Pos('\', Result)>0 do
    Delete(Result, 1, Pos('\', Result))
end;

function wbCounterAfterSet(aCounterName: String; const aElement: IwbElement): Boolean;
var
  Element         : IwbElement;
  Container       : IwbContainer;
  SelfAsContainer : IwbContainer;
begin
  Result := False;
  if wbBeginInternalEdit then try
    if (Length(aCounterName)>=4) and Supports(aElement.Container, IwbContainer, Container) and
       Supports(aElement, IwbContainer, SelfAsContainer) then begin
      Element := Container.ElementByName[aCounterName];
      if not Assigned(Element) then  // Signatures not listed in mrDef cannot be added
        Element := Container.Add(Copy(aCounterName, 1, 4));
      if Assigned(Element) and (SameText(Element.Name, aCounterName)) then try
        if (Element.GetNativeValue<>SelfAsContainer.GetElementCount) then
          Element.SetNativeValue(SelfAsContainer.GetElementCount);
        Result := True;
      except
        // No exception if the value cannot be set, expected non value
      end;
    end;
  finally
    wbEndInternalEdit;
  end;
end;

function wbCounterByPathAfterSet(aCounterName: String; const aElement: IwbElement): Boolean;
var
  Element         : IwbElement;
  Container       : IwbContainer;
  SelfAsContainer : IwbContainer;
begin
  Result := False;
  if wbBeginInternalEdit then try
    if (Length(aCounterName)>=4) and Supports(aElement.Container, IwbContainer, Container) and
       Supports(aElement, IwbContainer, SelfAsContainer) then begin
      Element := Container.ElementByPath[aCounterName];
//      if not Assigned(Element) then  // Signatures not listed in mrDef cannot be added
//        Element := Container.Add(Copy(aCounterName, 1, 4));
      if Assigned(Element) and (SameText(Element.Name, wbExtractNameFromPath(aCounterName))) then try
        if (Element.GetNativeValue<>SelfAsContainer.GetElementCount) then
          Element.SetNativeValue(SelfAsContainer.GetElementCount);
        Result := True;
      except
        // No exception if the value cannot be set, expected non value
      end;
    end;
  finally
    wbEndInternalEdit;
  end;
end;

function wbCounterContainerAfterSet(aCounterName: String; anArrayName: String; const aElement: IwbElement; DeleteOnEmpty: Boolean = False): Boolean;
var
  Element         : IwbElement;
  Elems           : IwbElement;
  Container       : IwbContainer;
begin
  Result := False;  // You may need to check alterative counter name
  if wbBeginInternalEdit then try
    if Supports(aElement, IwbContainer, Container) then begin
      Element := Container.ElementByName[aCounterName];
      Elems   := Container.ElementByName[anArrayName];
      if Assigned(Element) then begin
        if not Assigned(Elems) then
          if Element.GetNativeValue<>0 then
            Element.SetNativeValue(0)
          else if DeleteOnEmpty then
            Container.RemoveElement(aCounterName);
        Result := True; // Counter member exists
      end;
    end;
  finally
    wbEndInternalEdit;
  end;
end;

function wbCounterContainerByPathAfterSet(aCounterName: String; anArrayName: String; const aElement: IwbElement): Boolean;
var
  Element         : IwbElement;
  Elems           : IwbElement;
  Container       : IwbContainer;
begin
  Result := False;  // You may need to check alterative counter name
  if wbBeginInternalEdit then try
    if Supports(aElement, IwbContainer, Container) then begin
      Element := Container.ElementByPath[aCounterName];
      Elems   := Container.ElementByName[anArrayName];
      if Assigned(Element) then begin
        if not Assigned(Elems) then
          if Element.GetNativeValue<>0 then
            Element.SetNativeValue(0);
        Result := True; // Counter member exists
      end;
    end;
  finally
    wbEndInternalEdit;
  end;
end;

// BSA helper

function MakeDataFileName(FileName, DataPath: String): String;
begin
  // MO uses 3 chars aliases
  if Length(FileName) < 3 then
    Result := ''
  else if not ((FileName[1] = '\') or (FileName[2] = ':')) then
    Result := DataPath + FileName
  else
    Result := FileName;
end;

function FindBSAs(IniName, DataPath: String; var bsaNames: TStringList; var bsaMissing: TStringList): Integer;
var
  i: Integer;
  j: Integer;
  s: String;
  t: String;
begin
  Result := 0;
  j := 0;
  if Assigned(bsaNames) then
    j := bsaNames.Count;
  if Assigned(bsaMissing) then
    j := j + bsaMissing.Count;

  if Assigned(bsaNames) then
    // TIniFile uses GetPrivateProfileString() to read data, it is virtualized by MO
    // TMemIniFile reads from string list directly, not supported by MO
    with TIniFile.Create(iniName) do try
      with TStringList.Create do try
        if wbGameMode in [gmTES4, gmFO3, gmFNV] then
          Text := StringReplace(ReadString('Archive', 'sArchiveList', ''), ',' ,#10, [rfReplaceAll])
        else if wbGameMode = gmTES5 then
          Text := StringReplace(
            ReadString('Archive', 'sResourceArchiveList', '') + ',' +
            ReadString('Archive', 'sResourceArchiveList2', ''),
            ',', #10, [rfReplaceAll]
          )
        else if wbGameMode = gmFO4 then
          Text := StringReplace(
            ReadString('Archive', 'sResourceIndexFileList', '') + ',' +
            ReadString('Archive', 'sResourceStartUpArchiveList', '') + ',' +
            ReadString('Archive', 'sResourceArchiveList', '') + ',' +
            ReadString('Archive', 'sResourceArchiveList2', ''),
            ',', #10, [rfReplaceAll]
          );
        for i := 0 to Pred(Count) do begin
          s := Trim(Strings[i]);
          t := MakeDataFileName(s, DataPath);
          if (Length(t)>0) then
            if FileExists(t) then begin
              if wbContainerHandler.ContainerExists(t) then
                Continue;
              bsaNames.Add(s);
            end else
              if Assigned(bsaMissing) then
                bsaMissing.Add(s);
        end;
        Result := bsaNames.Count  + bsaMissing.Count - j; // How many were added
      finally
        Free;
      end;
    finally
      Free;
    end;
end;

function HasBSAs(ModName, DataPath: String; Exact, modini: Boolean; var bsaNames: TStringList; var bsaMissing: TStringList): Integer;
var
  j: Integer;
  t: String;
  F: TSearchRec;
begin
  Result := 0;
  j := 0;
  if Assigned(bsaNames) then
    j := bsaNames.Count;
  if Assigned(bsaMissing) then
    j := j + bsaMissing.Count;
  // All games prior to Skyrim load BSA files with partial matching, Skyrim requires exact name match and
  //   can use a private ini to specify the bsa to use.
  if not exact then
    ModName := ModName + '*';
  if FindFirst(DataPath + ModName + wbArchiveExtension, faAnyFile, F) = 0 then try
    repeat
      if wbContainerHandler.ContainerExists(DataPath + F.Name) then
        Continue;
      t := MakeDataFileName(F.Name, DataPath);
      if (Length(t)>0) and FileExists(t) then begin
        if not wbContainerHandler.ContainerExists(t) then
          if Assigned(bsaNames) then
            bsaNames.Add(F.Name);
      end else
        if Assigned(bsaMissing) then
          bsaMissing.Add(F.Name);
    until FindNext(F) <> 0;
    Result := bsaNames.Count  + bsaMissing.Count - j;
  finally
    FindClose(F);
  end;

  if modIni then
    Result := Result + FindBSAs(DataPath+ChangeFileExt(ModName, '.ini'), DataPath, bsaNames, bsaMissing);
end;

function wbDDSDataToBitmap(aData: TBytes; Bitmap: TBitmap): Boolean;
var
  img: TImageData;
  ms: TMemoryStream;
begin
  Result := False;
  if not LoadImageFromMemory(@aData[0], Length(aData), img) then
    Exit;
  ms := TMemoryStream.Create;
  try
    if SaveImageToStream('BMP', ms, img) then begin
      ms.Position := 0;
      Bitmap.LoadFromStream(ms);
      Result := True;
    end;
  finally
    FreeImage(img);
    ms.Free;
  end;
end;

function wbDDSStreamToBitmap(aStream: TStream; Bitmap: TBitmap): Boolean;
var
  img: TImageData;
  ms: TMemoryStream;
begin
  Result := False;
  if not LoadImageFromStream(aStream, img) then
    Exit;
  ms := TMemoryStream.Create;
  try
    if SaveImageToStream('BMP', ms, img) then begin
      ms.Position := 0;
      Bitmap.LoadFromStream(ms);
      Result := True;
    end;
  finally
    FreeImage(img);
    ms.Free;
  end;
end;

function wbIsAssociatedWithExtension(aExt: string): Boolean;
var
  Name: string;
begin
  Result := False;
  with TRegistry.Create do try
    RootKey := HKEY_CURRENT_USER;
    if OpenKey('\Software\Classes\' + LowerCase(aExt), False) then begin
      Name := ReadString('');
      if OpenKey('\Software\Classes\' + Name + '\DefaultIcon', False) then
        if SameText(ReadString(''), ParamStr(0)) then
          Result := True;
    end;
  finally
    Free;
  end;
end;

function wbAssociateWithExtension(aExt, aName, aDescr: string): Boolean;
begin
  Result := False;

  if aExt = '' then
    Exit
  else
    aExt := LowerCase(aExt);

  if aExt[1] <> '.' then
    aExt := '.' + aExt;

  with TRegistry.Create do try
    RootKey := HKEY_CURRENT_USER;

    if OpenKey('\Software\Classes\' + aExt, True) then
      WriteString('', aName)
    else
      raise Exception.Create('Not enough rights to modify the registry');

    if OpenKey('\Software\Classes\' + aName, True) then
      WriteString('', aDescr);

    if OpenKey('\Software\Classes\' + aName + '\DefaultIcon', True) then
      WriteString('', ParamStr(0));

    if OpenKey('\Software\Classes\' + aName + '\shell\open\command', True) then
      WriteString('', ParamStr(0) + ' "%1"');

    Result := True;
  finally
    Free;
  end;

  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
end;

function wbFormVerDecider(aBasePtr: Pointer; aEndPtr: Pointer; const aElement: IwbElement; aMinimum: Integer): Integer;
var
  FormVer    : Integer;
  MainRecord : IwbMainRecord;
  Element    : IwbElement;
begin
  Result := 1;
  if not Assigned(aElement) then Exit;
  MainRecord := aElement.GetContainingMainRecord;
  if not Assigned(MainRecord) then Exit;

  Element := MainRecord.ElementByPath['Record Header\Form Version'];
  if Assigned(Element) then begin
    FormVer := Element.NativeValue;
    if FormVer<aMinimum then
      Result := 0;
  end;
end;

function wbFormVer78Decider(aBasePtr: Pointer; aEndPtr: Pointer; const aElement: IwbElement): Integer;
begin
  Result := wbFormVerDecider(aBasePtr, aEndPtr, aElement, 78);
end;

initialization
  CRCInit;

end.
