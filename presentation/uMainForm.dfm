object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Teste Citel - Pedido de Venda'
  ClientHeight = 560
  ClientWidth = 860
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 13
  object lblCustomerCode: TLabel
    Left = 16
    Top = 16
    Width = 63
    Height = 13
    Caption = 'Cod. Cliente'
  end
  object lblCustomerName: TLabel
    Left = 176
    Top = 16
    Width = 69
    Height = 13
    Caption = 'Nome Cliente'
  end
  object lblProductCode: TLabel
    Left = 16
    Top = 88
    Width = 69
    Height = 13
    Caption = 'Cod. Produto'
  end
  object lblProductDescription: TLabel
    Left = 176
    Top = 88
    Width = 49
    Height = 13
    Caption = 'Descricao'
  end
  object lblQuantity: TLabel
    Left = 520
    Top = 88
    Width = 61
    Height = 13
    Caption = 'Quantidade'
  end
  object lblUnitPrice: TLabel
    Left = 632
    Top = 88
    Width = 59
    Height = 13
    Caption = 'Vr. Unitario'
  end
  object lblOrderTotal: TLabel
    Left = 616
    Top = 520
    Width = 135
    Height = 21
    Caption = 'Total Pedido: 0,00'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblOrderNumber: TLabel
    Left = 16
    Top = 56
    Width = 83
    Height = 13
    Caption = 'Numero Pedido:'
  end
  object lblOrderNumberValue: TLabel
    Left = 112
    Top = 56
    Width = 6
    Height = 13
    Caption = '0'
  end
  object edtCustomerCode: TEdit
    Left = 16
    Top = 32
    Width = 121
    Height = 21
    TabOrder = 0
  end
  object btnLookupCustomer: TButton
    Left = 144
    Top = 31
    Width = 25
    Height = 23
    Caption = '...'
    TabOrder = 1
  end
  object edtCustomerName: TEdit
    Left = 176
    Top = 32
    Width = 393
    Height = 21
    TabOrder = 2
  end
  object edtProductCode: TEdit
    Left = 16
    Top = 104
    Width = 121
    Height = 21
    TabOrder = 3
  end
  object btnLookupProduct: TButton
    Left = 144
    Top = 103
    Width = 25
    Height = 23
    Caption = '...'
    TabOrder = 4
  end
  object edtProductDescription: TEdit
    Left = 176
    Top = 104
    Width = 329
    Height = 21
    TabOrder = 5
  end
  object edtQuantity: TEdit
    Left = 520
    Top = 104
    Width = 97
    Height = 21
    TabOrder = 6
    Text = '1'
  end
  object edtUnitPrice: TEdit
    Left = 632
    Top = 104
    Width = 97
    Height = 21
    TabOrder = 7
  end
  object btnAddOrUpdateItem: TButton
    Left = 744
    Top = 102
    Width = 97
    Height = 25
    Caption = 'Inserir'
    TabOrder = 8
  end
  object grdItems: TStringGrid
    Left = 16
    Top = 144
    Width = 825
    Height = 321
    TabOrder = 9
  end
  object btnSaveOrder: TButton
    Left = 576
    Top = 480
    Width = 129
    Height = 25
    Caption = 'Gravar Pedido'
    TabOrder = 13
  end
  object btnLoadOrder: TButton
    Left = 16
    Top = 480
    Width = 129
    Height = 25
    Caption = 'Carregar Pedido'
    TabOrder = 10
  end
  object btnDeleteOrder: TButton
    Left = 288
    Top = 480
    Width = 129
    Height = 25
    Caption = 'Excluir Pedido'
    TabOrder = 12
  end
  object btnNewOrder: TButton
    Left = 152
    Top = 480
    Width = 129
    Height = 25
    Caption = 'Novo Pedido'
    TabOrder = 11
  end
  object btnCancelOrder: TButton
    Left = 712
    Top = 480
    Width = 129
    Height = 25
    Caption = 'Cancelar'
    TabOrder = 14
  end
end
