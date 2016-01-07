unit mdConfiguration;

interface

uses
  Classes, wbInterface,
  // mte units
  mteHelpers, RttiIni;

type
  TGameMode = Record
    longName: string;
    gameName: string;
    gameMode: TwbGameMode;
    appName: string;
    exeName: string;
    appIDs: string;
    abbrName: string;
  end;
  TProgramStatus = class(TObject)
  public
    ProgramVersion: string;
    GameMode: TGameMode;
  end;

  function SetGameMode(param: string): boolean;

var
  ProgramStatus: TProgramStatus;
  PathList: TStringList;

const
  // GAME MODES
  GameArray: array[1..5] of TGameMode = (
    ( longName: 'Skyrim'; gameName: 'Skyrim'; gameMode: gmTES5;
      appName: 'TES5'; exeName: 'TESV.exe'; appIDs: '72850';
      abbrName: 'sk'; ),
    ( longName: 'Oblivion'; gameName: 'Oblivion'; gameMode: gmTES4;
      appName: 'TES4'; exeName: 'Oblivion.exe'; appIDs: '22330,900883';
      abbrName: 'ob'; ),
    ( longName: 'Fallout New Vegas'; gameName: 'FalloutNV'; gameMode: gmFNV;
      appName: 'FNV'; exeName: 'FalloutNV.exe'; appIDs: '22380,2028016';
      abbrName: 'fnv'; ),
    ( longName: 'Fallout 3'; gameName: 'Fallout3'; gameMode: gmFO3;
      appName: 'FO3'; exeName: 'Fallout3.exe'; appIDs: '22300,22370';
      abbrName: 'fo3'; ),
    ( longName: 'Fallout 4'; gameName: 'Fallout4'; gameMode: gmFO4;
      appName: 'FO4'; exeName: 'Fallout4.exe'; appIDs: '';
      abbrName: 'fo4'; )
  );

implementation

function SetGameMode(param: string): boolean;
var
  abbrName: string;
  i: Integer;
begin
  Result := false;
  abbrName := Copy(param, 2, Length(param));
  for i := Low(GameArray) to High(GameArray) do
    if GameArray[i].abbrName = abbrName then begin
      ProgramStatus.GameMode := GameArray[i];
      Result := true;
      exit;
    end;
end;

initialization
begin
  ProgramStatus := TProgramStatus.Create;
  PathList := TStringList.Create;
end;

finalization
begin
  ProgramStatus.Free;
  PathList.Free;
end;

end.
