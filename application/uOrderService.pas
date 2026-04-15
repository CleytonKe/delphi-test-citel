unit uOrderService;

interface

uses
  uOrder, uProduct, uCustomer, uRepositoryInterfaces;

type
  IOrderService = interface
    ['{4A29309D-42E5-41DD-BE32-CFCB42064F63}']
    function GetCustomer(ACustomerCode: Integer): TCustomer;
    function GetProduct(AProductCode: Integer): TProduct;
    procedure Post(AOrder: TOrder);
    function Get(AOrderNumber: Integer): TOrder;
    procedure Delete(AOrderNumber: Integer);
  end;

  TOrderService = class(TInterfacedObject, IOrderService)
  private
    FCustomerRepository: ICustomerRepository;
    FProductRepository: IProductRepository;
    FOrderRepository: IOrderRepository;
  public
    constructor Create(const ACustomerRepository: ICustomerRepository;
      const AProductRepository: IProductRepository;
      const AOrderRepository: IOrderRepository);

    function GetCustomer(ACustomerCode: Integer): TCustomer;
    function GetProduct(AProductCode: Integer): TProduct;
    procedure Post(AOrder: TOrder);
    function Get(AOrderNumber: Integer): TOrder;
    procedure Delete(AOrderNumber: Integer);
  end;

implementation

uses
  System.SysUtils;

constructor TOrderService.Create(const ACustomerRepository: ICustomerRepository;
  const AProductRepository: IProductRepository; const AOrderRepository: IOrderRepository);
begin
  inherited Create;

  if ACustomerRepository = nil then
    raise Exception.Create('Repositorio de clientes nao informado.');

  if AProductRepository = nil then
    raise Exception.Create('Repositorio de produtos nao informado.');

  if AOrderRepository = nil then
    raise Exception.Create('Repositorio de pedidos nao informado.');

  FCustomerRepository := ACustomerRepository;
  FProductRepository := AProductRepository;
  FOrderRepository := AOrderRepository;
end;

function TOrderService.GetCustomer(ACustomerCode: Integer): TCustomer;
begin
  Result := FCustomerRepository.Get(ACustomerCode);

  if Result = nil then
    raise Exception.Create('Cliente nao encontrado.');

  if Result.Code <= 0 then
  begin
    Result.Free;
    raise Exception.Create('Cliente sem codigo valido.');
  end;
end;

function TOrderService.GetProduct(AProductCode: Integer): TProduct;
begin
  Result := FProductRepository.Get(AProductCode);
end;

procedure TOrderService.Post(AOrder: TOrder);
begin
  if AOrder = nil then
    raise Exception.Create('Pedido nao informado.');

  if AOrder.OrderNumber < 0 then
    raise Exception.Create('Numero do pedido invalido.');

  FOrderRepository.Post(AOrder);

  if AOrder.OrderNumber <= 0 then
    raise Exception.Create('Numero do pedido invalido apos gravacao.');
end;

function TOrderService.Get(AOrderNumber: Integer): TOrder;
begin
  Result := FOrderRepository.Get(AOrderNumber);
end;

procedure TOrderService.Delete(AOrderNumber: Integer);
begin
  FOrderRepository.Delete(AOrderNumber);
end;

end.
