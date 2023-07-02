inherited frmCadCategorias: TfrmCadCategorias
  Caption = 'Cadastro de Categorias'
  ClientWidth = 838
  ExplicitLeft = 2
  ExplicitTop = -49
  ExplicitWidth = 850
  TextHeight = 13
  inherited pgcPrincipal: TPageControl
    Width = 838
    ExplicitWidth = 735
    inherited tabListagem: TTabSheet
      ExplicitWidth = 830
      inherited pnlListagemTopo: TPanel
        Width = 830
        ExplicitWidth = 731
      end
      inherited grdListagem: TDBGrid
        Width = 830
        Columns = <
          item
            Expanded = False
            FieldName = 'categoriaId'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'descricao'
            Width = 377
            Visible = True
          end>
      end
    end
    inherited tabManutencao: TTabSheet
      ExplicitWidth = 830
      object edtCategoriaId: TLabeledEdit
        Tag = 1
        Left = 16
        Top = 24
        Width = 121
        Height = 21
        EditLabel.Width = 33
        EditLabel.Height = 13
        EditLabel.Caption = 'C'#243'digo'
        MaxLength = 10
        NumbersOnly = True
        TabOrder = 0
        Text = ''
      end
      object edtDescricao: TLabeledEdit
        Tag = 2
        Left = 16
        Top = 72
        Width = 441
        Height = 21
        TabStop = False
        EditLabel.Width = 46
        EditLabel.Height = 13
        EditLabel.Caption = 'Descri'#231#227'o'
        MaxLength = 30
        TabOrder = 1
        Text = ''
      end
    end
  end
  inherited pnlRodape: TPanel
    Width = 838
    ExplicitWidth = 735
    inherited btnFechar: TBitBtn
      Left = 708
      ExplicitLeft = 605
    end
    inherited btnNavigator: TDBNavigator
      Hints.Strings = ()
    end
  end
  inherited qryListagem: TZQuery
    SQL.Strings = (
      'SELECT categoriaId ,descricao FROM categorias')
    object qryListagemcategoriaId: TIntegerField
      DisplayLabel = 'C'#243'digo'
      FieldName = 'categoriaId'
      ReadOnly = True
    end
    object qryListagemdescricao: TWideStringField
      DisplayLabel = 'Descri'#231#227'o'
      FieldName = 'descricao'
      Size = 30
    end
  end
end
