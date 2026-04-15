unit uConnectionFactory;

interface

uses
  FireDAC.Comp.Client;

function CreateConnection: TFDConnection;

implementation

uses
  System.SysUtils, FireDAC.Stan.Def, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Phys,
  FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef, uDbConfig;

function CreateConnection: TFDConnection;
var
  LDriverLink: TFDPhysMySQLDriverLink;
begin
  Result := TFDConnection.Create(nil);
  try
    LDriverLink := TFDPhysMySQLDriverLink.Create(Result);
    LDriverLink.VendorHome := DB_VENDOR_LIB_PATH;
    LDriverLink.VendorLib := DB_VENDOR_BIN_PATH;

    Result.LoginPrompt := False;
    Result.Params.Clear;
    Result.Params.Values['DriverID'] := 'MySQL';
    Result.Params.Values['Server'] := DB_SERVER;
    Result.Params.Values['Port'] := IntToStr(DB_PORT);
    Result.Params.Values['Database'] := DB_DATABASE;
    Result.Params.Values['User_Name'] := DB_USERNAME;
    Result.Params.Values['Password'] := DB_PASSWORD;
    Result.Params.Values['CharacterSet'] := 'utf8mb4';
    Result.Params.Values['Pooled'] := 'False';

    Result.Connected := True;
  except
    Result.Free;
    raise;
  end;
end;

end.
