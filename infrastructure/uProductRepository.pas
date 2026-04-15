unit uProductRepository;

interface

uses
  FireDAC.Comp.Client, uProduct, uRepositoryInterfaces;

type
  TProductRepository = class(TInterfacedObject, IProductRepository)
  strict private
    FConnection: TFDConnection;
  public
    constructor Create(AConnection: TFDConnection);

    function Get(ACode: Integer): TProduct;
  end;

implementation

uses
  System.SysUtils, FireDAC.Stan.Param, Data.DB;

constructor TProductRepository.Create(AConnection: TFDConnection);
begin
  inherited Create;

  if AConnection = nil then
    raise Exception.Create('Conexao nao informada para o repositorio de produtos.');

  FConnection := AConnection;
end;

function TProductRepository.Get(ACode: Integer): TProduct;
var
  LQuery: TFDQuery;
  LCode: Integer;
  LSalePrice: Double;
begin
  if ACode <= 0 then
    raise Exception.Create('Codigo do produto invalido.');

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT codigo, ' +
      '       descricao, ' +
      '       preco_venda ' +
      '  FROM produtos ' +
      ' WHERE codigo = :codigo';
    LQuery.ParamByName('codigo').AsInteger := ACode;
    LQuery.Open;

    if LQuery.IsEmpty then
      raise Exception.CreateFmt('Produto %d nao encontrado.', [ACode]);

    LCode := LQuery.FieldByName('codigo').AsInteger;
    if LCode <= 0 then
      raise Exception.Create('Codigo do produto invalido.');

    LSalePrice := LQuery.FieldByName('preco_venda').AsFloat;
    if LSalePrice <= 0 then
      raise Exception.Create('Preco de venda invalido.');

    Result := TProduct.Create;
    try
      Result.Code := LCode;
      Result.Description := Trim(LQuery.FieldByName('descricao').AsString);
      Result.SalePrice := LSalePrice;
    except
      Result.Free;
      raise;
    end;
  finally
    LQuery.Free;
  end;
end;

end.
