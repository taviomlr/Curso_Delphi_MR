inherited frmCadProdutos: TfrmCadProdutos
  Caption = 'Cadastro de Produtos'
  ClientHeight = 352
  ClientWidth = 904
  ExplicitWidth = 916
  ExplicitHeight = 390
  TextHeight = 13
  inherited pgcPrincipal: TPageControl
    Width = 904
    Height = 310
    ExplicitWidth = 900
    ExplicitHeight = 345
    inherited tabListagem: TTabSheet
      ExplicitWidth = 896
      ExplicitHeight = 282
      inherited pnlListagemTopo: TPanel
        Width = 896
        ExplicitWidth = 896
      end
      inherited grdListagem: TDBGrid
        Width = 896
        Height = 225
        Columns = <
          item
            Expanded = False
            FieldName = 'produtoId'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'nome'
            Width = 372
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'valor'
            Width = 70
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'quantidade'
            Width = 71
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'DescricaoCategoria'
            Width = 374
            Visible = True
          end>
      end
    end
    inherited tabManutencao: TTabSheet
      ExplicitWidth = 896
      ExplicitHeight = 282
      object Label1: TLabel
        Left = 16
        Top = 102
        Width = 46
        Height = 13
        Caption = 'Descri'#231#227'o'
      end
      object Label2: TLabel
        Left = 16
        Top = 219
        Width = 24
        Height = 13
        Caption = 'Valor'
      end
      object Label3: TLabel
        Left = 162
        Top = 219
        Width = 56
        Height = 13
        Caption = 'Quantidade'
      end
      object Label4: TLabel
        Left = 472
        Top = 56
        Width = 47
        Height = 13
        Caption = 'Categoria'
      end
      object edtNome: TLabeledEdit
        Tag = 2
        Left = 16
        Top = 75
        Width = 441
        Height = 21
        TabStop = False
        EditLabel.Width = 27
        EditLabel.Height = 13
        EditLabel.Caption = 'Nome'
        MaxLength = 60
        TabOrder = 1
        Text = ''
      end
      object edtProdutoId: TLabeledEdit
        Tag = 1
        Left = 16
        Top = 35
        Width = 121
        Height = 21
        TabStop = False
        EditLabel.Width = 33
        EditLabel.Height = 13
        EditLabel.Caption = 'C'#243'digo'
        MaxLength = 10
        NumbersOnly = True
        TabOrder = 0
        Text = ''
      end
      object edtDescricao: TMemo
        Left = 16
        Top = 120
        Width = 825
        Height = 89
        Lines.Strings = (
          'edtDescricao')
        MaxLength = 255
        TabOrder = 3
      end
      object edtValor: TCurrencyEdit
        Left = 16
        Top = 238
        Width = 121
        Height = 21
        TabOrder = 4
      end
      object edtQuantidade: TCurrencyEdit
        Left = 162
        Top = 238
        Width = 121
        Height = 21
        DisplayFormat = ',0.00;- ,0.00'
        TabOrder = 5
      end
      object lkpCategoria: TDBLookupComboBox
        Left = 472
        Top = 75
        Width = 369
        Height = 21
        KeyField = 'categoriaId'
        ListField = 'descricao'
        ListSource = dtsCategoria
        TabOrder = 2
      end
    end
  end
  inherited pnlRodape: TPanel
    Top = 310
    Width = 904
    ExplicitTop = 345
    ExplicitWidth = 900
    inherited btnFechar: TBitBtn
      Left = 774
      ExplicitLeft = 770
    end
    inherited btnNavigator: TDBNavigator
      Hints.Strings = ()
    end
  end
  inherited qryListagem: TZQuery
    SQL.Strings = (
      'SELECT p.produtoId'
      '      ,p.nome'
      '      ,p.descricao'
      '      ,p.valor'
      '      ,p.quantidade'
      '      ,p.categoriaId'
      '      ,c.descricao AS DescricaoCategoria'
      'FROM  produtos AS p'
      'LEFT JOIN categorias AS c ON c.categoriaId = p.categoriaId')
    Left = 516
    Top = 24
    object qryListagemprodutoId: TIntegerField
      DisplayLabel = 'C'#243'digo'
      FieldName = 'produtoId'
      ReadOnly = True
    end
    object qryListagemnome: TWideStringField
      DisplayLabel = 'Nome'
      FieldName = 'nome'
      Size = 60
    end
    object qryListagemdescricao: TWideStringField
      DisplayLabel = 'Descri'#231#227'o'
      FieldName = 'descricao'
      Size = 255
    end
    object qryListagemvalor: TFloatField
      DisplayLabel = 'Valor'
      FieldName = 'valor'
    end
    object qryListagemquantidade: TFloatField
      DisplayLabel = 'Quantidade'
      FieldName = 'quantidade'
    end
    object qryListagemcategoriaId: TIntegerField
      DisplayLabel = 'Cod. Categoria'
      FieldName = 'categoriaId'
    end
    object qryListagemDescricaCategoria: TWideStringField
      DisplayLabel = 'Descri'#231#227'o da Categoria'
      FieldName = 'DescricaoCategoria'
      Size = 30
    end
  end
  inherited dtsListagem: TDataSource
    Left = 580
  end
  object QryCategoria: TZQuery
    Connection = dtmPrincipal.ConexaoDB
    Active = True
    SQL.Strings = (
      'SELECT categoriaId'
      '       ,descricao'
      '  FROM categorias')
    Params = <>
    Left = 620
    Top = 104
    object QryCategoriacategoriaId: TIntegerField
      DisplayLabel = 'C'#243'digo'
      FieldName = 'categoriaId'
      ReadOnly = True
    end
    object QryCategoriadescricao: TWideStringField
      DisplayLabel = 'Descri'#231#227'o'
      FieldName = 'descricao'
      Size = 30
    end
  end
  object dtsCategoria: TDataSource
    DataSet = QryCategoria
    Left = 684
    Top = 104
  end
end
