unit uRepositoryInterfaces;

interface

uses
  uCustomer, uProduct, uOrder;

type
  ICustomerRepository = interface
    ['{F95A68AA-0D59-4D4A-B4CB-6587F5D0E47D}']
    function Get(ACode: Integer): TCustomer;
  end;

  IProductRepository = interface
    ['{BC16C2B8-B997-4103-925A-48566B7E94F0}']
    function Get(ACode: Integer): TProduct;
  end;

  IOrderRepository = interface
    ['{79D9D79D-4CE8-4F2E-99C3-BF7F46CB677F}']
    procedure Post(AOrderToPost: TOrder);
    function Get(AOrderNumber: Integer): TOrder;
    procedure Delete(AOrderNumber: Integer);
  end;

implementation

end.
