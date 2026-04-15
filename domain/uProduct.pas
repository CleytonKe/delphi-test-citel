unit uProduct;

interface

type
  TProduct = class
  strict private
    FCode: Integer;
    FDescription: string;
    FSalePrice: Double;
  public
    property Code: Integer read FCode write FCode;
    property Description: string read FDescription write FDescription;
    property SalePrice: Double read FSalePrice write FSalePrice;
  end;

implementation

end.
