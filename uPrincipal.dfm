object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  Caption = 'Menu Principal'
  ClientHeight = 229
  ClientWidth = 534
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mainPrincipal
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 13
  object mainPrincipal: TMainMenu
    Left = 472
    Top = 16
    object CADASTRO1: TMenuItem
      Caption = 'Cadastro'
      object Cliente1: TMenuItem
        Caption = 'Clientes'
        OnClick = Cliente1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Categoria1: TMenuItem
        Caption = 'Categorias'
        OnClick = Categoria1Click
      end
      object Produto1: TMenuItem
        Caption = 'Produtos'
        OnClick = Produto1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object mnuFechar: TMenuItem
        Caption = 'Fechar'
        OnClick = mnuFecharClick
      end
    end
    object MOVIMENTAO1: TMenuItem
      Caption = 'Movimenta'#231#227'o'
      object Vendas1: TMenuItem
        Caption = 'Vendas'
      end
    end
    object RELATRORIO1: TMenuItem
      Caption = 'Relat'#243'rio'
      object Clientes1: TMenuItem
        Caption = 'Clientes'
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object Produtos1: TMenuItem
        Caption = 'Produtos'
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object VendasPorData1: TMenuItem
        Caption = 'Vendas Por Data'
      end
    end
  end
end
