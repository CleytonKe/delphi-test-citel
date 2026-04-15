unit uOrder;

interface

uses
  uOrderItem;

type
  TOrder = class
  strict private
    FOrderNumber: Integer;
    FEmissionDate: TDateTime;
    FCustomerCode: Integer;
    FCustomerName: string;
    FItems: TOrderItemList;

    function GetTotal: Double;
  public
    constructor Create;
    destructor Destroy; override;

    property OrderNumber: Integer read FOrderNumber write FOrderNumber;
    property EmissionDate: TDateTime read FEmissionDate write FEmissionDate;
    property CustomerCode: Integer read FCustomerCode write FCustomerCode;
    property CustomerName: string read FCustomerName write FCustomerName;
    property Total: Double read GetTotal;
    property Items: TOrderItemList read FItems;
  end;

implementation

uses
  System.SysUtils;

constructor TOrder.Create;
begin
  inherited Create;

  FEmissionDate := Now;
  FItems := TOrderItemList.Create;
end;

destructor TOrder.Destroy;
begin
  FItems.Free;

  inherited Destroy;
end;

function TOrder.GetTotal: Double;
begin
  Result := FItems.GetTotal;
end;

end.
