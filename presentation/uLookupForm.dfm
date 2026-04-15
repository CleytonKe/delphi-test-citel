object LookupForm: TLookupForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Lookup'
  ClientHeight = 520
  ClientWidth = 760
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 13
  object lblFilter: TLabel
    Left = 16
    Top = 16
    Width = 27
    Height = 13
    Caption = 'Filtro'
  end
  object edtFilter: TEdit
    Left = 16
    Top = 34
    Width = 720
    Height = 21
    TabOrder = 0
    OnChange = edtFilterChange
    OnKeyDown = edtFilterKeyDown
  end
  object grdResults: TStringGrid
    Left = 16
    Top = 68
    Width = 720
    Height = 360
    ColCount = 2
    DefaultRowHeight = 21
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goDrawFocusSelected, goRowSelect]
    TabOrder = 1
    OnDblClick = grdResultsDblClick
    OnKeyDown = grdResultsKeyDown
  end
  object btnSelect: TButton
    Left = 576
    Top = 440
    Width = 75
    Height = 25
    Caption = 'Selecionar'
    TabOrder = 2
    OnClick = btnSelectClick
  end
  object btnCancel: TButton
    Left = 661
    Top = 440
    Width = 75
    Height = 25
    Caption = 'Cancelar'
    ModalResult = 2
    TabOrder = 3
  end
end
