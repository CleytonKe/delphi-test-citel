unit uCustomer;

interface

type
  TCustomer = class
  strict private
    FCode: Integer;
    FName: string;
    FCity: string;
    FState: string;
  public
    property Code: Integer read FCode write FCode;
    property Name: string read FName write FName;
    property City: string read FCity write FCity;
    property State: string read FState write FState;
  end;

implementation

end.
