unit uOrderRepository;

interface

uses
  FireDAC.Comp.Client, uOrder, uOrderItem, uRepositoryInterfaces;

type
  TOrderRepository = class(TInterfacedObject, IOrderRepository)
  strict private
    FConnection: TFDConnection;

    procedure SaveOrderHeader(AOrder: TOrder);
    procedure SaveOrderItems(AOrder: TOrder);
  public
    constructor Create(AConnection: TFDConnection);

    procedure Post(AOrderToPost: TOrder);
    function Get(AOrderNumber: Integer): TOrder;
    procedure Delete(AOrderNumber: Integer);
  end;

implementation

uses
  System.SysUtils, FireDAC.Stan.Param, Data.DB;

constructor TOrderRepository.Create(AConnection: TFDConnection);
begin
  inherited Create;

  if AConnection = nil then
    raise Exception.Create('Conexao nao informada para o repositorio de pedidos.');

  FConnection := AConnection;
end;

procedure TOrderRepository.Post(AOrderToPost: TOrder);
begin
  if AOrderToPost = nil then
    raise Exception.Create('Pedido nao informado para gravacao.');

  FConnection.StartTransaction;
  try
    SaveOrderHeader(AOrderToPost);
    SaveOrderItems(AOrderToPost);

    FConnection.Commit;
  except
    FConnection.Rollback;
    raise;
  end;
end;

procedure TOrderRepository.SaveOrderHeader(AOrder: TOrder);
var
  LQuery: TFDQuery;
begin
  if AOrder.OrderNumber < 0 then
    raise Exception.Create('Numero do pedido invalido para gravacao.');

  if AOrder.EmissionDate <= 0 then
    raise Exception.Create('Data de emissao invalida para gravacao.');

  if AOrder.CustomerCode <= 0 then
    raise Exception.Create('Codigo do cliente invalido para gravacao.');

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;

    if AOrder.OrderNumber > 0 then
      LQuery.SQL.Text :=
        'UPDATE pedidos ' +
        '   SET data_emissao = :data_emissao, ' +
        '       codigo_cliente = :codigo_cliente, ' +
        '       valor_total = :valor_total ' +
        ' WHERE numero_pedido = :numero_pedido'
    else
      LQuery.SQL.Text :=
        'INSERT INTO pedidos (data_emissao, codigo_cliente, valor_total) ' +
        '     VALUES (:data_emissao, :codigo_cliente, :valor_total)';

    LQuery.ParamByName('data_emissao').AsDateTime := AOrder.EmissionDate;
    LQuery.ParamByName('codigo_cliente').AsInteger := AOrder.CustomerCode;
    LQuery.ParamByName('valor_total').AsFloat := AOrder.Total;

    if AOrder.OrderNumber > 0 then
      LQuery.ParamByName('numero_pedido').AsInteger := AOrder.OrderNumber;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;

  if AOrder.OrderNumber <= 0 then
  begin
    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := FConnection;
      LQuery.SQL.Text := 'SELECT LAST_INSERT_ID() AS numero_pedido';
      LQuery.Open;
      try
        AOrder.OrderNumber := LQuery.FieldByName('numero_pedido').AsInteger;
        if AOrder.OrderNumber <= 0 then
          raise Exception.Create('Numero do pedido invalido apos insercao.');
      finally
        LQuery.Close;
      end;
    finally
      LQuery.Free;
    end;
  end;
end;

procedure TOrderRepository.SaveOrderItems(AOrder: TOrder);
var
  LQuery: TFDQuery;
  LItem: TOrderItem;
  LExistingCount: Integer;
  LExistingIndex: Integer;
  LExistingIdsSql: string;
  LItemIndex: Integer;
  LLastIdQuery: TFDQuery;
begin
  LExistingCount := 0;
  LExistingIdsSql := '';
  for LItemIndex := 0 to AOrder.Items.Count - 1 do
  begin
    LItem := AOrder.Items[LItemIndex];
    if LItem.Id = 0 then
      raise Exception.Create('Id do item do pedido invalido.');

    if LItem.Id > 0 then
    begin
      if LExistingIdsSql <> '' then
        LExistingIdsSql := LExistingIdsSql + ',';
      LExistingIdsSql := LExistingIdsSql + LItem.Id.ToString;

      Inc(LExistingCount);
    end;
  end;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'DELETE FROM pedidos_itens WHERE numero_pedido = :numero_pedido';
    if LExistingIdsSql <> '' then
      LQuery.SQL.Text := LQuery.SQL.Text + ' AND id NOT IN (' + LExistingIdsSql + ')';

    LQuery.ParamByName('numero_pedido').AsInteger := AOrder.OrderNumber;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;

  if LExistingCount > 0 then
  begin
    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := FConnection;
      LQuery.SQL.Text :=
        'UPDATE pedidos_itens ' +
        '   SET codigo_produto = :codigo_produto, ' +
        '       quantidade = :quantidade, ' +
        '       valor_unitario = :valor_unitario, ' +
        '       valor_total = :valor_total ' +
        ' WHERE numero_pedido = :numero_pedido ' +
        '   AND id = :id';

      LQuery.Params.ArraySize := LExistingCount;
      LExistingIndex := 0;
      for LItemIndex := 0 to AOrder.Items.Count - 1 do
      begin
        LItem := AOrder.Items[LItemIndex];
        if LItem.Id > 0 then
        begin
          LQuery.ParamByName('numero_pedido').Values[LExistingIndex] := AOrder.OrderNumber;
          LQuery.ParamByName('id').Values[LExistingIndex] := LItem.Id;
          LQuery.ParamByName('codigo_produto').Values[LExistingIndex] := LItem.ProductCode;
          LQuery.ParamByName('quantidade').Values[LExistingIndex] := LItem.Quantity;
          LQuery.ParamByName('valor_unitario').Values[LExistingIndex] := LItem.UnitPrice;
          LQuery.ParamByName('valor_total').Values[LExistingIndex] := LItem.Total;
          Inc(LExistingIndex);
        end;
      end;

      LQuery.Execute(LExistingCount, 0);
    finally
      LQuery.Free;
    end;
  end;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'INSERT INTO pedidos_itens ' +
      '            (numero_pedido, codigo_produto, quantidade, valor_unitario, valor_total) ' +
      '     VALUES (:numero_pedido, :codigo_produto, :quantidade, :valor_unitario, :valor_total)';

    LLastIdQuery := TFDQuery.Create(nil);
    try
      LLastIdQuery.Connection := FConnection;
      LLastIdQuery.SQL.Text := 'SELECT LAST_INSERT_ID() AS id';

      for LItemIndex := 0 to AOrder.Items.Count - 1 do
      begin
        LItem := AOrder.Items[LItemIndex];
        if LItem.Id < 0 then
        begin
          LQuery.ParamByName('numero_pedido').AsInteger := AOrder.OrderNumber;
          LQuery.ParamByName('codigo_produto').AsInteger := LItem.ProductCode;
          LQuery.ParamByName('quantidade').AsFloat := LItem.Quantity;
          LQuery.ParamByName('valor_unitario').AsFloat := LItem.UnitPrice;
          LQuery.ParamByName('valor_total').AsFloat := LItem.Total;
          LQuery.ExecSQL;

          LLastIdQuery.Open;
          try
            LItem.Id := LLastIdQuery.FieldByName('id').AsInteger;
            if LItem.Id <= 0 then
              raise Exception.Create('Id do item do pedido invalido apos insercao.');
          finally
            LLastIdQuery.Close;
          end;
        end;
      end;
    finally
      LLastIdQuery.Free;
    end;
  finally
    LQuery.Free;
  end;
end;

function TOrderRepository.Get(AOrderNumber: Integer): TOrder;
var
  LQuery: TFDQuery;
  LItem: TOrderItem;
  LOrderNumber: Integer;
  LEmissionDate: TDateTime;
  LCustomerCode: Integer;
  LProductCode: Integer;
  LQuantity: Double;
  LUnitPrice: Double;
begin
  if AOrderNumber <= 0 then
    raise Exception.Create('Numero do pedido invalido.');

  Result := TOrder.Create;
  try
    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := FConnection;
      LQuery.SQL.Text :=
        '    SELECT p.numero_pedido, ' +
        '           p.data_emissao, ' +
        '           p.codigo_cliente, ' +
        '           c.nome AS nome_cliente ' +
        '      FROM pedidos p ' +
        'INNER JOIN clientes c ' +
        '        ON c.codigo = p.codigo_cliente ' +
        '     WHERE p.numero_pedido = :numero_pedido';
      LQuery.ParamByName('numero_pedido').AsInteger := AOrderNumber;
      LQuery.Open;

      if LQuery.IsEmpty then
        raise Exception.CreateFmt('Pedido %d nao encontrado.', [AOrderNumber]);

      LOrderNumber := LQuery.FieldByName('numero_pedido').AsInteger;
      if LOrderNumber <= 0 then
        raise Exception.Create('Numero do pedido invalido.');

      LEmissionDate := LQuery.FieldByName('data_emissao').AsDateTime;
      if LEmissionDate <= 0 then
        raise Exception.Create('Data de emissao invalida.');

      LCustomerCode := LQuery.FieldByName('codigo_cliente').AsInteger;
      if LCustomerCode <= 0 then
        raise Exception.Create('Codigo do cliente invalido.');

      Result.OrderNumber := LOrderNumber;
      Result.EmissionDate := LEmissionDate;
      Result.CustomerCode := LCustomerCode;
      Result.CustomerName := Trim(LQuery.FieldByName('nome_cliente').AsString);
    finally
      LQuery.Free;
    end;

    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := FConnection;
      LQuery.SQL.Text :=
        '    SELECT i.id, ' +
        '           i.codigo_produto, ' +
        '           pr.descricao, ' +
        '           i.quantidade, ' +
        '           i.valor_unitario ' +
        '      FROM pedidos_itens i ' +
        'INNER JOIN produtos pr ' +
        '        ON pr.codigo = i.codigo_produto ' +
        '     WHERE i.numero_pedido = :numero_pedido ' +
        '  ORDER BY i.id';
      LQuery.ParamByName('numero_pedido').AsInteger := AOrderNumber;
      LQuery.Open;

      while not LQuery.Eof do
      begin
        LProductCode := LQuery.FieldByName('codigo_produto').AsInteger;
        if LProductCode <= 0 then
          raise Exception.Create('Codigo do produto invalido no item.');

        LQuantity := LQuery.FieldByName('quantidade').AsFloat;
        if LQuantity <= 0 then
          raise Exception.Create('Quantidade invalida no item.');

        LUnitPrice := LQuery.FieldByName('valor_unitario').AsFloat;
        if LUnitPrice <= 0 then
          raise Exception.Create('Valor unitario invalido no item.');

        LItem := TOrderItem.Create;
        try
          LItem.Id := LQuery.FieldByName('id').AsInteger;
          if LItem.Id <= 0 then
            raise Exception.Create('Id do item do pedido invalido.');

          LItem.ProductCode := LProductCode;
          LItem.ProductDescription := Trim(LQuery.FieldByName('descricao').AsString);
          LItem.Quantity := LQuantity;
          LItem.UnitPrice := LUnitPrice;

          Result.Items.Add(LItem);
        except
          LItem.Free;
          raise;
        end;

        LQuery.Next;
      end;
    finally
      LQuery.Free;
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure TOrderRepository.Delete(AOrderNumber: Integer);
var
  LQuery: TFDQuery;
begin
  if AOrderNumber <= 0 then
    raise Exception.Create('Numero do pedido invalido.');

  FConnection.StartTransaction;
  try
    LQuery := TFDQuery.Create(nil);
    try
      LQuery.Connection := FConnection;
      LQuery.SQL.Text := 'DELETE FROM pedidos_itens WHERE numero_pedido = :numero_pedido';
      LQuery.ParamByName('numero_pedido').AsInteger := AOrderNumber;
      LQuery.ExecSQL;

      LQuery.SQL.Text := 'DELETE FROM pedidos WHERE numero_pedido = :numero_pedido';
      LQuery.ParamByName('numero_pedido').AsInteger := AOrderNumber;
      LQuery.ExecSQL;

      if LQuery.RowsAffected = 0 then
        raise Exception.CreateFmt('Pedido %d nao encontrado para exclusao.', [AOrderNumber]);
    finally
      LQuery.Free;
    end;

    FConnection.Commit;
  except
    FConnection.Rollback;
    raise;
  end;
end;

end.
