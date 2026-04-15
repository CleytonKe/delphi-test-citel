unit uLookupForm;

interface

uses
  System.Classes, FireDAC.Comp.Client, Vcl.Controls, Vcl.Forms, Vcl.Grids, Vcl.StdCtrls;

type
  TLookupForm = class(TForm)
    lblFilter: TLabel;
    edtFilter: TEdit;
    grdResults: TStringGrid;
    btnSelect: TButton;
    btnCancel: TButton;
    procedure edtFilterChange(Sender: TObject);
    procedure btnSelectClick(Sender: TObject);
    procedure grdResultsDblClick(Sender: TObject);
    procedure grdResultsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtFilterKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  strict private
    FConnection: TFDConnection;
    FBaseSql: string;
    FFilterField: string;
    FOrderField: string;
    FSelectedCode: Integer;
    FSelectedText: string;
    FQuery: TFDQuery;

    procedure LoadResults;
    function RowIsSelectable: Boolean;
    procedure SelectCurrentRow;
  public
    constructor CreateLookup(AOwner: TComponent; AConnection: TFDConnection;
      const ATitle, AFilterCaption, ABaseSql, AFilterField, AOrderField: string); reintroduce;
    destructor Destroy; override;
    class function Execute(AOwner: TComponent; AConnection: TFDConnection;
      const ATitle, AFilterCaption, ABaseSql, AFilterField, AOrderField: string;
      out ACode: Integer; out AText: string): Boolean;
  end;

implementation

uses
  System.SysUtils, Winapi.Windows, FireDAC.Stan.Param;

{$R *.dfm}

constructor TLookupForm.CreateLookup(AOwner: TComponent; AConnection: TFDConnection;
  const ATitle, AFilterCaption, ABaseSql, AFilterField, AOrderField: string);
begin
  inherited Create(AOwner);

  if AConnection = nil then
    raise Exception.Create('Conexao nao informada para o lookup.');

  FConnection := AConnection;
  FBaseSql := ABaseSql;
  FFilterField := AFilterField;
  FOrderField := AOrderField;
  Caption := ATitle;
  lblFilter.Caption := AFilterCaption;
  grdResults.Cells[0, 0] := 'Codigo';
  grdResults.Cells[1, 0] := 'Descricao';
  grdResults.ColWidths[0] := 100;
  grdResults.ColWidths[1] := 600;

  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnection;

  LoadResults;
end;

destructor TLookupForm.Destroy;
begin
  FQuery.Free;

  inherited Destroy;
end;

class function TLookupForm.Execute(AOwner: TComponent; AConnection: TFDConnection;
  const ATitle, AFilterCaption, ABaseSql, AFilterField, AOrderField: string;
  out ACode: Integer; out AText: string): Boolean;
var
  LForm: TLookupForm;
begin
  LForm := TLookupForm.CreateLookup(AOwner, AConnection, ATitle, AFilterCaption, ABaseSql,
    AFilterField, AOrderField);
  try
    Result := LForm.ShowModal = mrOk;
    if Result then
    begin
      ACode := LForm.FSelectedCode;
      AText := LForm.FSelectedText;
    end;
  finally
    LForm.Free;
  end;
end;

procedure TLookupForm.LoadResults;
var
  LRow: Integer;
begin
  FQuery.Close;
  FQuery.SQL.Text :=
    FBaseSql + sLineBreak +
    '   WHERE ' + FFilterField + ' LIKE :filtro' + sLineBreak +
    'ORDER BY ' + FOrderField + sLineBreak +
    '   LIMIT 200';
  FQuery.ParamByName('filtro').AsString := '%' + Trim(edtFilter.Text) + '%';
  FQuery.Open;

  grdResults.RowCount := 2;
  grdResults.Rows[1].Clear;

  LRow := 1;
  FQuery.First;
  while not FQuery.Eof do
  begin
    if LRow >= grdResults.RowCount then
      grdResults.RowCount := LRow + 1;

    grdResults.Cells[0, LRow] := FQuery.FieldByName('codigo').AsString;
    grdResults.Cells[1, LRow] := FQuery.FieldByName('descricao_lookup').AsString;
    Inc(LRow);
    FQuery.Next;
  end;

  if LRow = 1 then
    grdResults.RowCount := 2
  else
    grdResults.RowCount := LRow;

  if LRow > 1 then
    grdResults.Row := 1;
end;

function TLookupForm.RowIsSelectable: Boolean;
begin
  Result := (grdResults.Row > 0) and (Trim(grdResults.Cells[0, grdResults.Row]) <> '');
end;

procedure TLookupForm.SelectCurrentRow;
begin
  if not RowIsSelectable then
    Exit;

  FSelectedCode := StrToInt(Trim(grdResults.Cells[0, grdResults.Row]));
  FSelectedText := Trim(grdResults.Cells[1, grdResults.Row]);
  ModalResult := mrOk;
end;

procedure TLookupForm.edtFilterChange(Sender: TObject);
begin
  if FQuery = nil then
    Exit;

  LoadResults;
end;

procedure TLookupForm.btnSelectClick(Sender: TObject);
begin
  SelectCurrentRow;
end;

procedure TLookupForm.grdResultsDblClick(Sender: TObject);
begin
  SelectCurrentRow;
end;

procedure TLookupForm.grdResultsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    SelectCurrentRow;
    Key := 0;
  end;
end;

procedure TLookupForm.edtFilterKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    LoadResults;
    Key := 0;
  end;
end;

end.
