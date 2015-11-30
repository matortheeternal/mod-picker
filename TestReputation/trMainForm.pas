unit trMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  trUser;

type
  TMainForm = class(TForm)
    PageControl1: TPageControl;
    Options: TTabSheet;
    Button1: TButton;
    Button2: TButton;
    Log: TTabSheet;
    Label1: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Label2: TLabel;
    Edit3: TEdit;
    Label3: TLabel;
    Edit4: TEdit;
    Label4: TLabel;
    Memo1: TMemo;
    Label5: TLabel;
    Edit5: TEdit;
    procedure GenerateRandomUsers;
    procedure GenerateRandomConnections;
    procedure Iterate;
    procedure PrintUsers;
    procedure PerformIterations;
    procedure PrintReputations;
    procedure Run;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

const
  flowRate = 0.05;

var
  numUsers, maxConnections, maxRep, numIterations, numIslands,
  chanceOfDeadEnd: Integer;
  usersList, visitedUsers: TList;
  bLog: boolean;

function TimeDiff(start: TDateTime): Real;
begin
  Result := (Now - start) * 24 * 60 * 60;
end;

procedure TMainForm.GenerateRandomUsers;
var
  i: Integer;
  aUser: TUser;
  start: TDateTime;
begin
  start := Now;
  for i := 0 to Pred(numUsers) do begin
    aUser := TUser.Create(i + 1, random() * random() * maxRep, flowRate);
    usersList.Add(aUser);
  end;

  Memo1.Lines.Add(Format('Generated %d users in %0.3fs',
    [numUsers, TimeDiff(start)]));
end;

procedure TMainForm.GenerateRandomConnections;
var
  i, j, uIndex, numConnections: Integer;
  aUser: TUser;
  start: TDateTime;
begin
  start := Now;
  for i := 0 to Pred(usersList.Count) do begin
    aUser := TUser(usersList[i]);
    if random() < (chanceOfDeadEnd / 100.0) then
      continue;
    numConnections := Trunc(random() * maxConnections) + 1;
    for j := 0 to Pred(numConnections) do begin
      uIndex := Trunc(random() * usersList.Count);
      if uIndex = i then
        continue;
      if aUser.Connections.IndexOf(usersList[uIndex]) > -1 then
        continue;
      aUser.Connections.Add(usersList[uIndex]);
    end;
  end;

  Memo1.Lines.Add(Format('Generated connections in %0.3fs',
    [TimeDiff(start)]));
end;

procedure TMainForm.PrintUsers;
var
  i: Integer;
  aUser, cUser: TUser;
  s: string;
  j: Integer;
begin
  Memo1.Lines.Add('Users:');
  for i := 0 to Pred(usersList.Count) do begin
    aUser := TUser(usersList[i]);
    s := Format('[%d] : %0.1f :: ', [aUser.id, aUser.BaseRep]);
    for j := 0 to Pred(aUser.Connections.Count) do begin
      cUser := TUser(aUser.Connections[j]);
      s := s + Format('%d, ', [cUser.id]);
    end;
    Memo1.Lines.Add(s);
  end;
  Memo1.Lines.Add(' ');
end;

procedure TraverseFrom(user: TUser);
var
  i: Integer;
  cUser: TUser;
begin
  // traverse all connections from user
  for i := 0 to Pred(user.Connections.Count) do begin
    cUser := user.Connections[i];
    cUser.TempRep := cUser.TempRep + user.FlowRep;
    if visitedUsers.IndexOf(cUser) = -1 then begin
      visitedUsers.Add(cUser);
      TraverseFrom(cUser);
    end
    else
      visitedUsers.Add(cUser);
  end;
end;

procedure TMainForm.Iterate();
const
  bDebug = true;
var
  i: Integer;
  aUser: TUser;
begin
  // traverse each island
  numIslands := 0;
  for i := 0 to Pred(usersList.Count) do begin
    aUser := TUser(usersList[i]);
    if visitedUsers.IndexOf(aUser) = -1 then begin
      Inc(numIslands);
      TraverseFrom(aUser);
    end;
  end;

  // set computed rep, reset temprep
  for i := 0 to Pred(usersList.Count) do begin
    aUser := TUser(usersList[i]);
    aUser.ComputedRep := aUser.BaseRep + aUser.TempRep;
    aUser.FlowRep := aUser.ComputedRep * 0.05;
    aUser.TempRep := 0;
    if bDebug and bLog then
      Memo1.Lines.Add(Format('    [%d] New rep %0.1f', [i + 1, aUser.ComputedRep]));
  end;

  // clear visited users when done
  visitedUsers.Clear;
end;

procedure TMainForm.PerformIterations();
var
  i: Integer;
  start: TDateTime;
begin
  Memo1.Lines.Add('Performing iterations');
  for i := 1 to numIterations do begin
    start := Now;
    Memo1.Lines.Add(Format('  Iteration %d ... ', [i]));
    Iterate();
    Memo1.Lines.Add(Format('    %0.3fs', [TimeDiff(start)]));
  end;
  Memo1.Lines.Add('Number of islands: '+IntToStr(numIslands));
  Memo1.Lines.Add(' ');
end;

procedure TMainForm.PrintReputations();
var
  i: Integer;
  aUser: TUser;
begin
  Memo1.Lines.Add('Calculated Reputations:');
  for i := 0 to Pred(usersList.Count) do begin
    aUser := TUser(usersList[i]);
    Memo1.Lines.Add(Format('[%d] : %0.1f', [aUser.id, aUser.ComputedRep]));
  end;
end;

procedure TMainForm.Run();
begin
  // prepare
  usersList := TList.Create;
  visitedUsers := TList.Create;

  // do everything
  GenerateRandomUsers;
  GenerateRandomConnections;
  if bLog then PrintUsers;
  PerformIterations;
  if bLog then PrintReputations;

  // clean up
  usersList.Free;
  visitedUsers.Free;
end;

procedure TMainForm.Button1Click(Sender: TObject);
var
  start: TDateTime;
begin
  // print setup
  Memo1.Lines.Add('--------------------------------------');
  Memo1.Lines.Add('Running with');
  Memo1.Lines.Add('  numUsers = '+Edit1.Text);
  Memo1.Lines.Add('  maxConnections = '+Edit2.Text);
  Memo1.Lines.Add('  maxRep = '+Edit3.Text);
  Memo1.Lines.Add('  numIterations = '+Edit4.Text);
  Memo1.Lines.Add('  chanceOfDeadend = '+Edit5.Text);
  Memo1.Lines.Add('');

  // set vars
  numUsers := StrToInt(Edit1.Text);
  maxConnections := StrToInt(Edit2.Text);
  maxRep := StrToInt(Edit3.Text);
  numIterations := StrToInt(Edit4.Text);
  chanceOfDeadEnd := StrToInt(Edit5.Text);

  // run
  start := Now;
  bLog := numUsers < 100;
  Run();
  Memo1.Lines.Add(Format('Completed in %0.3fs', [TimeDiff(start)]));
  Memo1.Lines.Add(#13#10);
  PageControl1.ActivePageIndex := 1;
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  Close;
end;

end.
