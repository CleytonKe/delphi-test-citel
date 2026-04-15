program TesteCitel;

uses
  Vcl.Forms,
  uMainForm in 'presentation\uMainForm.pas' {frmMain},
  uLookupForm in 'presentation\uLookupForm.pas',
  uOrderService in 'application\uOrderService.pas',
  uCustomer in 'domain\uCustomer.pas',
  uOrder in 'domain\uOrder.pas',
  uOrderItem in 'domain\uOrderItem.pas',
  uProduct in 'domain\uProduct.pas',
  uRepositoryInterfaces in 'domain\uRepositoryInterfaces.pas',
  uConnectionFactory in 'infrastructure\uConnectionFactory.pas',
  uCustomerRepository in 'infrastructure\uCustomerRepository.pas',
  uDbConfig in 'infrastructure\uDbConfig.pas',
  uOrderRepository in 'infrastructure\uOrderRepository.pas',
  uProductRepository in 'infrastructure\uProductRepository.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
