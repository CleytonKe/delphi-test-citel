unit uCustomerRepository;

interface

uses
  FireDAC.Comp.Client, uCustomer, uRepositoryInterfaces;

type
  TCustomerRepository = class(TInterfacedObject, ICustomerRepository)
  strict private
    FConnection: TFDConnection;
  public
    constructor Create(AConnection: TFDConnection);

    function Get(ACode: Integer): TCustomer;
  end;

implementation

uses
  System.SysUtils, FireDAC.Stan.Param, Data.DB;

constructor TCustomerRepository.Create(AConnection: TFDConnection);
begin
  inherited Create;
  if AConnection = nil then
    raise Exception.Create('Conexao nao informada para o repositorio de clientes.');

  FConnection := AConnection;
end;

function TCustomerRepository.Get(ACode: Integer): TCustomer;
var
  LQuery: TFDQuery;
  LCode: Integer;
begin
  if ACode <= 0 then
    raise Exception.Create('Codigo do cliente invalido.');

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'SELECT codigo, ' +
      '       nome, ' +
      '       cidade, ' +
      '       uf ' +
      '  FROM clientes ' +
      ' WHERE codigo = :codigo';
    LQuery.ParamByName('codigo').AsInteger := ACode;
    LQuery.Open;

    if LQuery.IsEmpty then
      raise Exception.CreateFmt('Cliente %d nao encontrado.', [ACode]);

    LCode := LQuery.FieldByName('codigo').AsInteger;
    if LCode <= 0 then
      raise Exception.Create('Codigo do cliente invalido.');

    Result := TCustomer.Create;
    try
      Result.Code := LCode;
      Result.Name := Trim(LQuery.FieldByName('nome').AsString);
      Result.City := Trim(LQuery.FieldByName('cidade').AsString);
      Result.State := UpperCase(Trim(LQuery.FieldByName('uf').AsString));
    except
      Result.Free;
      raise;
    end;
  finally
    LQuery.Free;
  end;
end;

end.
