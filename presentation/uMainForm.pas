unit uMainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.Grids, FireDAC.Comp.Client, FireDAC.Comp.UI, uOrderService,
  uOrder, uOrderItem;

type
  TfrmMain = class(TForm)
    lblCustomerCode: TLabel;
    edtCustomerCode: TEdit;
    lblCustomerName: TLabel;
    edtCustomerName: TEdit;
    lblProductCode: TLabel;
    edtProductCode: TEdit;
    lblProductDescription: TLabel;
    edtProductDescription: TEdit;
    lblQuantity: TLabel;
    edtQuantity: TEdit;
    lblUnitPrice: TLabel;
    edtUnitPrice: TEdit;
    btnAddOrUpdateItem: TButton;
    grdItems: TStringGrid;
    lblOrderTotal: TLabel;
    btnSaveOrder: TButton;
    btnLoadOrder: TButton;
    btnDeleteOrder: TButton;
    lblOrderNumber: TLabel;
    lblOrderNumberValue: TLabel;
    btnNewOrder: TButton;
    btnCancelOrder: TButton;
    btnLookupCustomer: TButton;
    btnLookupProduct: TButton;
  private
    FConnection: TFDConnection;
    FOrderService: IOrderService;
    FOrder: TOrder;
    FEditingItem: TOrderItem;
    FHasPendingChanges: Boolean;

    procedure ConfiguraComponentes;
    procedure AtribuiEventoComponentes;
    procedure DoOnCustomerCodeChange(Sender: TObject);
    procedure DoOnCustomerCodeExit(Sender: TObject);
    procedure DoOnLookupCustomerClick(Sender: TObject);
    procedure DoOnProductCodeChange(Sender: TObject);
    procedure DoOnProductCodeExit(Sender: TObject);
    procedure DoOnLookupProductClick(Sender: TObject);
    procedure DoOnQuantityChange(Sender: TObject);
    procedure DoOnAddOrUpdateItemClick(Sender: TObject);
    procedure DoOnItemsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoOnSaveOrderClick(Sender: TObject);
    procedure DoOnLoadOrderClick(Sender: TObject);
    procedure DoOnDeleteOrderClick(Sender: TObject);
    procedure DoOnNewOrderClick(Sender: TObject);
    procedure DoOnCancelOrderClick(Sender: TObject);
    procedure ApplyCustomerFromInput;
    procedure RefreshScreen;
    procedure RefreshGrid;
    procedure RefreshHeader;
    procedure ControlaEnableComponentes;
    procedure ClearProductInputs;
    procedure StartItemEdit(AItem: TOrderItem);
    procedure LoadProductByCode(AProductCode: Integer);
    procedure ReloadOrder(AOrderNumber: Integer);
    procedure ClearCurrentOrder;
    function IsEditingItem: Boolean;
    function SelectedGridItem: TOrderItem;
    function ParseInteger(const AText, AFieldLabel: string): Integer;
    function ParseFloat(const AText, AFieldLabel: string): Double;
    function ParseDouble(const AText, AFieldLabel: string): Double;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  Winapi.Windows, System.SysUtils, System.UITypes, Vcl.Dialogs, FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Stan.Intf,
  uConnectionFactory, uCustomerRepository, uProductRepository, uOrderRepository, uRepositoryInterfaces,
  uProduct, uCustomer, uLookupForm;

constructor TfrmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  ConfiguraComponentes;

  AtribuiEventoComponentes;

  RefreshScreen;
end;

destructor TfrmMain.Destroy;
begin
  FOrder.Free;
  FConnection.Free;

  inherited Destroy;
end;

procedure TfrmMain.ConfiguraComponentes;
var
  LCustomerRepository: ICustomerRepository;
  LProductRepository: IProductRepository;
  LOrderRepository: IOrderRepository;
begin
  TFDGUIxWaitCursor.Create(Self);

  FEditingItem := nil;
  FHasPendingChanges := False;

  grdItems.ColCount := 5;
  grdItems.FixedCols := 0;
  grdItems.RowCount := 2;
  grdItems.FixedRows := 1;
  grdItems.Options := grdItems.Options + [goRowSelect];
  grdItems.Cells[0, 0] := 'Cod. Produto';
  grdItems.Cells[1, 0] := 'Descricao';
  grdItems.Cells[2, 0] := 'Quantidade';
  grdItems.Cells[3, 0] := 'Vr. Unitario';
  grdItems.Cells[4, 0] := 'Vr. Total';
  grdItems.ColWidths[0] := 90;
  grdItems.ColWidths[1] := 250;
  grdItems.ColWidths[2] := 90;
  grdItems.ColWidths[3] := 95;
  grdItems.ColWidths[4] := 95;

  edtCustomerName.ReadOnly := True;
  edtProductDescription.ReadOnly := True;

  btnAddOrUpdateItem.Caption := 'Inserir';
  lblOrderTotal.Caption := 'Total Pedido: ' + FormatFloat('#,##0.00', 0);
  lblOrderNumberValue.Caption := '0';

  FConnection := CreateConnection;
  try
    LCustomerRepository := TCustomerRepository.Create(FConnection);
    LProductRepository := TProductRepository.Create(FConnection);
    LOrderRepository := TOrderRepository.Create(FConnection);

    FOrderService := TOrderService.Create(LCustomerRepository, LProductRepository, LOrderRepository);
  except
    FConnection.Free;
    FConnection := nil;
    raise;
  end;

  FOrder := TOrder.Create;
end;

function TfrmMain.IsEditingItem: Boolean;
begin
  if FOrderService = nil then
    Exit(False);

  Result := (FEditingItem <> nil) and (FOrder.Items.IndexOf(FEditingItem) >= 0);
end;

function TfrmMain.SelectedGridItem: TOrderItem;
var
  LItemIndex: Integer;
begin
  Result := nil;
  if FOrderService = nil then
    Exit;

  if grdItems.Row <= 0 then
    Exit;

  LItemIndex := grdItems.Row - 1;
  if (LItemIndex < 0) or (LItemIndex >= FOrder.Items.Count) then
    Exit;

  Result := FOrder.Items[LItemIndex];
end;

procedure TfrmMain.ApplyCustomerFromInput;
var
  LCustomerCode: Integer;
  LCustomer: TCustomer;
begin
  if Trim(edtCustomerCode.Text) = '' then
  begin
    FHasPendingChanges := (FOrder.CustomerCode <> 0) or (FOrder.CustomerName <> '');
    FOrder.CustomerCode := 0;
    FOrder.CustomerName := '';
    edtCustomerName.Clear;

    Exit;
  end;

  LCustomerCode := ParseInteger(edtCustomerCode.Text, 'Codigo do cliente');
  if FOrder.CustomerCode = LCustomerCode then
  begin
    edtCustomerName.Text := FOrder.CustomerName;
    Exit;
  end;

  LCustomer := FOrderService.GetCustomer(LCustomerCode);
  try
    FOrder.CustomerCode := LCustomer.Code;
    FOrder.CustomerName := Trim(LCustomer.Name);
  finally
    LCustomer.Free;
  end;

  edtCustomerCode.Text := FOrder.CustomerCode.ToString;
  edtCustomerName.Text := FOrder.CustomerName;
  FHasPendingChanges := True;
end;

procedure TfrmMain.RefreshScreen;
begin
  RefreshHeader;
  RefreshGrid;
  ControlaEnableComponentes;
end;

procedure TfrmMain.RefreshHeader;
begin
  if FOrder.CustomerCode > 0 then
    edtCustomerCode.Text := FOrder.CustomerCode.ToString
  else
    edtCustomerCode.Clear;

  edtCustomerName.Text := FOrder.CustomerName;

  if FOrder.OrderNumber > 0 then
    lblOrderNumberValue.Caption := FOrder.OrderNumber.ToString
  else
    lblOrderNumberValue.Caption := '0';

  lblOrderTotal.Caption := 'Total Pedido: ' + FormatFloat('#,##0.00', FOrder.Total);
end;

procedure TfrmMain.RefreshGrid;
var
  LRow: Integer;
  LItem: TOrderItem;
begin
  grdItems.RowCount := FOrder.Items.Count + 1;
  if grdItems.RowCount < 2 then
    grdItems.RowCount := 2;

  for LRow := 1 to grdItems.RowCount - 1 do
    grdItems.Rows[LRow].Clear;

  for LRow := 0 to FOrder.Items.Count - 1 do
  begin
    LItem := FOrder.Items[LRow];
    grdItems.Cells[0, LRow + 1] := LItem.ProductCode.ToString;
    grdItems.Cells[1, LRow + 1] := LItem.ProductDescription;
    grdItems.Cells[2, LRow + 1] := FormatFloat('#,##0.###', LItem.Quantity);
    grdItems.Cells[3, LRow + 1] := FormatFloat('#,##0.00', LItem.UnitPrice);
    grdItems.Cells[4, LRow + 1] := FormatFloat('#,##0.00', LItem.Total);
  end;

  lblOrderTotal.Caption := 'Total Pedido: ' + FormatFloat('#,##0.00', FOrder.Total);
end;

procedure TfrmMain.ControlaEnableComponentes;
var
  LIsEditingItem: Boolean;
  LCustomerSelected: Boolean;
  LHasItems: Boolean;
  LHasProductCode: Boolean;
  LHasQuantity: Boolean;
  LHasLoadedOrder: Boolean;
  LCanSave: Boolean;
  LCanCancel: Boolean;
begin
  LIsEditingItem := IsEditingItem;
  LCustomerSelected := (FOrderService <> nil) and (FOrder.CustomerCode > 0);
  LHasItems := (FOrderService <> nil) and (FOrder.Items.Count > 0);
  LHasLoadedOrder := (FOrderService <> nil) and (FOrder.OrderNumber > 0);
  LHasProductCode := Trim(edtProductCode.Text) <> '';
  LHasQuantity := Trim(edtQuantity.Text) <> '';

  edtCustomerCode.Enabled := not LIsEditingItem;
  btnLookupCustomer.Enabled := not LIsEditingItem;

  edtProductCode.Enabled := LCustomerSelected and (not LIsEditingItem);
  btnLookupProduct.Enabled := edtProductCode.Enabled;
  edtProductDescription.Enabled := False;
  edtQuantity.Enabled := LCustomerSelected;
  edtUnitPrice.Enabled := LCustomerSelected;
  btnAddOrUpdateItem.Enabled := LCustomerSelected and LHasProductCode and LHasQuantity;

  grdItems.Enabled := LHasItems;

  LCanSave := (not LIsEditingItem) and LCustomerSelected and LHasItems and FHasPendingChanges;
  btnSaveOrder.Enabled := LCanSave;
  btnLoadOrder.Enabled := (not LIsEditingItem) and (not FHasPendingChanges);
  btnDeleteOrder.Enabled := (not LIsEditingItem) and (not FHasPendingChanges) and LHasLoadedOrder;
  btnNewOrder.Enabled := (not LIsEditingItem) and (not FHasPendingChanges);

  LCanCancel := (not LIsEditingItem) and FHasPendingChanges;
  btnCancelOrder.Enabled := LCanCancel;
end;

procedure TfrmMain.DoOnCustomerCodeChange(Sender: TObject);
begin
  ControlaEnableComponentes;
end;

procedure TfrmMain.DoOnProductCodeChange(Sender: TObject);
begin
  ControlaEnableComponentes;
end;

procedure TfrmMain.DoOnQuantityChange(Sender: TObject);
begin
  ControlaEnableComponentes;
end;

procedure TfrmMain.DoOnCustomerCodeExit(Sender: TObject);
begin
  ApplyCustomerFromInput;
  ControlaEnableComponentes;
end;

procedure TfrmMain.DoOnProductCodeExit(Sender: TObject);
var
  LProductCode: Integer;
begin
  if Trim(edtProductCode.Text) = '' then
  begin
    edtProductDescription.Clear;
    Exit;
  end;

  LProductCode := ParseInteger(edtProductCode.Text, 'Codigo do produto');
  LoadProductByCode(LProductCode);
end;

procedure TfrmMain.LoadProductByCode(AProductCode: Integer);
var
  LProduct: TProduct;
begin
  LProduct := FOrderService.GetProduct(AProductCode);
  try
    edtProductCode.Text := AProductCode.ToString;
    edtProductDescription.Text := LProduct.Description;
    edtUnitPrice.Text := FormatFloat('#,##0.00', LProduct.SalePrice);
  finally
    LProduct.Free;
  end;
end;

procedure TfrmMain.AtribuiEventoComponentes;
begin
  edtCustomerCode.OnChange := DoOnCustomerCodeChange;
  edtCustomerCode.OnExit := DoOnCustomerCodeExit;
  btnLookupCustomer.OnClick := DoOnLookupCustomerClick;
  edtProductCode.OnChange := DoOnProductCodeChange;
  edtProductCode.OnExit := DoOnProductCodeExit;
  btnLookupProduct.OnClick := DoOnLookupProductClick;
  edtQuantity.OnChange := DoOnQuantityChange;
  btnAddOrUpdateItem.OnClick := DoOnAddOrUpdateItemClick;
  grdItems.OnKeyDown := DoOnItemsKeyDown;
  btnSaveOrder.OnClick := DoOnSaveOrderClick;
  btnLoadOrder.OnClick := DoOnLoadOrderClick;
  btnDeleteOrder.OnClick := DoOnDeleteOrderClick;
  btnNewOrder.OnClick := DoOnNewOrderClick;
  btnCancelOrder.OnClick := DoOnCancelOrderClick;
end;

procedure TfrmMain.DoOnAddOrUpdateItemClick(Sender: TObject);
var
  LProductCode: Integer;
  LQuantity: Double;
  LUnitPrice: Double;
  LProduct: TProduct;
  LItem: TOrderItem;
begin
  LProductCode := ParseInteger(edtProductCode.Text, 'Codigo do produto');
  LQuantity := ParseFloat(edtQuantity.Text, 'Quantidade');
  if Trim(edtUnitPrice.Text) = '' then
    LUnitPrice := 0
  else
    LUnitPrice := ParseDouble(edtUnitPrice.Text, 'Valor unitario');

  if LQuantity <= 0 then
    raise Exception.Create('Quantidade invalida.');

  if IsEditingItem then
  begin
    if LUnitPrice <= 0 then
      raise Exception.Create('Valor unitario invalido.');

    FEditingItem.Quantity := LQuantity;
    FEditingItem.UnitPrice := LUnitPrice;
    FEditingItem := nil;

    btnAddOrUpdateItem.Caption := 'Inserir';
  end
  else
  begin
    LProduct := FOrderService.GetProduct(LProductCode);
    try
      if LUnitPrice <= 0 then
        LUnitPrice := LProduct.SalePrice;

      if LUnitPrice <= 0 then
        raise Exception.Create('Valor unitario invalido.');

      LItem := TOrderItem.Create;
      try
        LItem.Id := FOrder.Items.GetNextTemporaryItemId;
        LItem.ProductCode := LProduct.Code;
        LItem.ProductDescription := Trim(LProduct.Description);
        LItem.Quantity := LQuantity;
        LItem.UnitPrice := LUnitPrice;

        FOrder.Items.Add(LItem);
      except
        LItem.Free;
        raise;
      end;
    finally
      LProduct.Free;
    end;
  end;

  RefreshGrid;
  ClearProductInputs;
  FHasPendingChanges := True;
  ControlaEnableComponentes;
end;

procedure TfrmMain.ClearProductInputs;
begin
  edtProductCode.Clear;
  edtProductDescription.Clear;
  edtQuantity.Text := '1';
  edtUnitPrice.Clear;
  if edtProductCode.CanFocus then
    edtProductCode.SetFocus;
end;

procedure TfrmMain.StartItemEdit(AItem: TOrderItem);
begin
  if AItem = nil then
    Exit;

  if FOrder.Items.IndexOf(AItem) < 0 then
    Exit;

  edtProductCode.Text := AItem.ProductCode.ToString;
  edtProductDescription.Text := AItem.ProductDescription;
  edtQuantity.Text := FormatFloat('#,##0.###', AItem.Quantity);
  edtUnitPrice.Text := FormatFloat('#,##0.00', AItem.UnitPrice);

  FEditingItem := AItem;
  btnAddOrUpdateItem.Caption := 'Atualizar';
  ControlaEnableComponentes;
  edtQuantity.SetFocus;
end;

procedure TfrmMain.DoOnItemsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  LSelectedItem: TOrderItem;
begin
  LSelectedItem := SelectedGridItem;
  if LSelectedItem = nil then
    Exit;

  if Key = VK_RETURN then
  begin
    StartItemEdit(LSelectedItem);
    Key := 0;
  end
  else if Key = VK_DELETE then
  begin
    if MessageDlg('Deseja realmente excluir o item selecionado?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      FOrder.Items.Extract(LSelectedItem).Free;
      FEditingItem := nil;
      btnAddOrUpdateItem.Caption := 'Inserir';
      FHasPendingChanges := True;
      RefreshGrid;
      ControlaEnableComponentes;
    end;
    Key := 0;
  end;
end;

procedure TfrmMain.DoOnSaveOrderClick(Sender: TObject);
begin
  ApplyCustomerFromInput;
  FOrderService.Post(FOrder);
  FHasPendingChanges := False;
  RefreshScreen;
  MessageDlg('Pedido gravado com sucesso.', mtInformation, [mbOK], 0);
end;

procedure TfrmMain.DoOnLoadOrderClick(Sender: TObject);
var
  LOrderNumber: Integer;
  LOrderDescription: string;
begin
  LOrderNumber := 0;
  LOrderDescription := '';
  if not TLookupForm.Execute(Self, FConnection, 'Buscar Pedido',
    'Cliente, numero ou data',
    '    SELECT p.numero_pedido AS codigo, ' +
    '           CONCAT(''Pedido '', p.numero_pedido, '' - '', c.nome, '' - '', DATE_FORMAT(p.data_emissao, ''%d/%m/%Y'')) AS descricao_lookup ' +
    '      FROM pedidos p ' +
    'INNER JOIN clientes c ' +
    '        ON c.codigo = p.codigo_cliente',
    'CONCAT(c.nome, '' '', p.numero_pedido, '' '', DATE_FORMAT(p.data_emissao, ''%d/%m/%Y''))',
    'c.nome, p.numero_pedido DESC',
    LOrderNumber, LOrderDescription) then
    Exit;

  ReloadOrder(LOrderNumber);

  FEditingItem := nil;
  btnAddOrUpdateItem.Caption := 'Inserir';
  FHasPendingChanges := False;
  RefreshScreen;
end;

procedure TfrmMain.DoOnDeleteOrderClick(Sender: TObject);
var
  LOrderNumber: Integer;
begin
  LOrderNumber := FOrder.OrderNumber;
  if LOrderNumber <= 0 then
    Exit;

  if MessageDlg(Format('Deseja realmente excluir o pedido %d?', [LOrderNumber]),
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    FOrderService.Delete(LOrderNumber);
    ClearCurrentOrder;
    FEditingItem := nil;
    btnAddOrUpdateItem.Caption := 'Inserir';
    FHasPendingChanges := False;
    RefreshScreen;
  end;
end;

procedure TfrmMain.DoOnNewOrderClick(Sender: TObject);
begin
  ClearCurrentOrder;
  FEditingItem := nil;
  btnAddOrUpdateItem.Caption := 'Inserir';
  ClearProductInputs;
  FHasPendingChanges := False;
  RefreshScreen;
end;

procedure TfrmMain.DoOnCancelOrderClick(Sender: TObject);
var
  LOrderNumber: Integer;
begin
  LOrderNumber := FOrder.OrderNumber;

  if LOrderNumber > 0 then
  begin
    try
      ReloadOrder(LOrderNumber);
    except
      ClearCurrentOrder;
    end;
  end
  else
    ClearCurrentOrder;

  FEditingItem := nil;
  btnAddOrUpdateItem.Caption := 'Inserir';
  ClearProductInputs;
  FHasPendingChanges := False;
  RefreshScreen;
end;

procedure TfrmMain.ReloadOrder(AOrderNumber: Integer);
begin
  if AOrderNumber <= 0 then
    raise Exception.Create('Numero do pedido invalido.');

  FOrder.Free;
  try
    FOrder := FOrderService.Get(AOrderNumber);
  except
    FOrder := TOrder.Create;
    raise;
  end;
end;

procedure TfrmMain.ClearCurrentOrder;
begin
  FOrder.Free;
  FOrder := TOrder.Create;
end;

procedure TfrmMain.DoOnLookupCustomerClick(Sender: TObject);
var
  LCustomerCode: Integer;
  LCustomerName: string;
begin
  LCustomerCode := 0;
  LCustomerName := '';

  if not TLookupForm.Execute(Self, FConnection, 'Buscar Cliente', 'Nome do cliente',
    'SELECT codigo, ' +
    '       nome AS descricao_lookup ' +
    '  FROM clientes',
    'nome', 'nome', LCustomerCode, LCustomerName) then
    Exit;

  edtCustomerCode.Text := LCustomerCode.ToString;
  edtCustomerName.Text := LCustomerName;
  ApplyCustomerFromInput;
  ControlaEnableComponentes;
end;

procedure TfrmMain.DoOnLookupProductClick(Sender: TObject);
var
  LProductCode: Integer;
  LProductDescription: string;
begin
  LProductCode := 0;
  LProductDescription := '';

  if not TLookupForm.Execute(Self, FConnection, 'Buscar Produto', 'Descricao do produto',
    'SELECT codigo, ' +
    '       descricao AS descricao_lookup ' +
    '  FROM produtos',
    'descricao', 'descricao', LProductCode, LProductDescription) then
    Exit;

  edtProductCode.Text := LProductCode.ToString;
  edtProductDescription.Text := LProductDescription;
  LoadProductByCode(LProductCode);
  ControlaEnableComponentes;
  edtQuantity.SetFocus;
end;

function TfrmMain.ParseInteger(const AText, AFieldLabel: string): Integer;
begin
  if not TryStrToInt(Trim(AText), Result) then
    raise Exception.CreateFmt('%s invalido.', [AFieldLabel]);
end;

function TfrmMain.ParseFloat(const AText, AFieldLabel: string): Double;
var
  LText: string;
  LFormatSettings: TFormatSettings;
begin
  LText := Trim(AText);
  if TryStrToFloat(LText, Result) then
    Exit;

  LFormatSettings := TFormatSettings.Create;
  LFormatSettings.DecimalSeparator := ',';
  LFormatSettings.ThousandSeparator := '.';
  if TryStrToFloat(LText, Result, LFormatSettings) then
    Exit;

  LFormatSettings.DecimalSeparator := '.';
  LFormatSettings.ThousandSeparator := ',';
  if TryStrToFloat(LText, Result, LFormatSettings) then
    Exit;

  raise Exception.CreateFmt('%s invalida.', [AFieldLabel]);
end;

function TfrmMain.ParseDouble(const AText, AFieldLabel: string): Double;
begin
  Result := ParseFloat(AText, AFieldLabel);
end;

end.

