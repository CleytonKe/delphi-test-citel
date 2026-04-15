unit uOrderItem;

interface

uses
  System.Generics.Collections;

type
  TOrderItem = class
  strict private
    FId: Integer;
    FProductCode: Integer;
    FProductDescription: string;
    FQuantity: Double;
    FUnitPrice: Double;

    function GetTotal: Double;
  public
    property Id: Integer read FId write FId;
    property ProductCode: Integer read FProductCode write FProductCode;
    property ProductDescription: string read FProductDescription write FProductDescription;
    property Quantity: Double read FQuantity write FQuantity;
    property UnitPrice: Double read FUnitPrice write FUnitPrice;
    property Total: Double read GetTotal;
  end;

  TOrderItemList = class(TObjectList<TOrderItem>)
  public
    function GetTotal: Double;
    function GetNextTemporaryItemId: Integer;
  end;

implementation

{ TOrderItem }

function TOrderItem.GetTotal: Double;
begin
  Result := FQuantity * FUnitPrice;
end;

{ TOrderItemList }

function TOrderItemList.GetTotal: Double;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    Result := Result + Items[I].Total;
end;

function TOrderItemList.GetNextTemporaryItemId: Integer;
var
  LItem: TOrderItem;
  LItemIndex: Integer;
  LMinId: Integer;
begin
  LMinId := 0;
  for LItemIndex := 0 to Count - 1 do
  begin
    LItem := Items[LItemIndex];
    if LItem.Id < LMinId then
      LMinId := LItem.Id;
  end;

  if LMinId >= 0 then
    Result := -1
  else
    Result := LMinId - 1;
end;

end.
