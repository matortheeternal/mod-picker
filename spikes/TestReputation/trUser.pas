unit trUser;

interface

uses
  Classes;

type
  TUser = Class(TObject)
  public
    id: Integer;
    BaseRep: Real;
    FlowRep: Real;
    ComputedRep: Real;
    TempRep: Real;
    Connections: TList;
    constructor Create(id: Integer; BaseRep, FlowRate: Real);
  End;

implementation

constructor TUser.Create(id: Integer; BaseRep: Real; FlowRate: Real);
begin
  self.id := id;
  self.BaseRep := BaseRep;
  self.FlowRep := FlowRate * BaseRep;
  Connections := TList.Create;
end;

end.
