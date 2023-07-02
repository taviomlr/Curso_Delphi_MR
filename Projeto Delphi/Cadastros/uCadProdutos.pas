unit uCadProdutos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTelaHeranca, Data.DB,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, Vcl.DBCtrls, Vcl.Grids,
  Vcl.DBGrids, Vcl.StdCtrls, Vcl.Buttons, Vcl.Mask, Vcl.ExtCtrls, Vcl.ComCtrls,
  RxToolEdit, RxCurrEdit, cCadProdutos, uEnum, uDTMConexao;

type
  TfrmCadProdutos = class(TfrmTelaHeranca)
    qryListagemprodutoId: TIntegerField;
    qryListagemnome: TWideStringField;
    qryListagemdescricao: TWideStringField;
    qryListagemvalor: TFloatField;
    qryListagemquantidade: TFloatField;
    qryListagemcategoriaId: TIntegerField;
    qryListagemDescricaCategoria: TWideStringField;
    edtNome: TLabeledEdit;
    edtProdutoId: TLabeledEdit;
    edtDescricao: TMemo;
    Label1: TLabel;
    edtValor: TCurrencyEdit;
    edtQuantidade: TCurrencyEdit;
    Label2: TLabel;
    Label3: TLabel;
    lkpCategoria: TDBLookupComboBox;
    QryCategoria: TZQuery;
    dtsCategoria: TDataSource;
    QryCategoriacategoriaId: TIntegerField;
    QryCategoriadescricao: TWideStringField;
    Label4: TLabel;
    procedure btnAlterarClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    oProduto:Tproduto;
    function Apagar:boolean; override;
    function Gravar(EstadoDoCadastro:TEstadoDoCadastro):boolean; override;
  public
    { Public declarations }
  end;

var
  frmCadProdutos: TfrmCadProdutos;

implementation

{$R *.dfm}


{$region 'Override'}
function TfrmCadProdutos.Apagar: boolean;
begin
  if oProduto.Selecionar(qryListagem.FieldByName('produtoId').AsInteger) then
    begin
      Result := oProduto.Apagar;
    end;
end;

function TfrmCadProdutos.Gravar(EstadoDoCadastro: TEstadoDoCadastro): boolean;
begin
  if edtProdutoId.Text <> EmptyStr then
    oProduto.codigo := StrToInt(edtProdutoId.Text)
  else
    oProduto.codigo := 0;

  oProduto.nome          := edtNome.Text;
  oProduto.descricao     := edtDescricao.Text;
  oProduto.categoriaId   := lkpCategoria.KeyValue;
  oProduto.valor         := edtValor.Value;
  oProduto.quantidade    := edtQuantidade.Value;

  if (EstadoDoCadastro=ecInserir) then
    Result := oProduto.Inserir
  else if (EstadoDoCadastro=ecAlterar) then
    Result := oProduto.Atualizar;
end;
{$endregion}

procedure TfrmCadProdutos.btnAlterarClick(Sender: TObject);
begin
  if oProduto.Selecionar(qryListagem.FieldByName('produtoId').AsInteger) then
  begin
    edtProdutoId.Text     :=  IntToStr(oProduto.codigo);
    edtNome.Text          :=  oProduto.nome;
    edtDescricao.Text     :=  oProduto.descricao;
    lkpCategoria.KeyValue :=  oProduto.categoriaId;
    edtValor.Value        :=  oProduto.valor;
    edtQuantidade.Value   :=  oProduto.quantidade;
  end
  else
  begin
    btnCancelar.Click;
    Abort;
  end;

  inherited;
  edtNome.SetFocus;
end;

procedure TfrmCadProdutos.btnNovoClick(Sender: TObject);
begin
  inherited;
  edtNome.SetFocus;
end;

procedure TfrmCadProdutos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if Assigned(oProduto) then
    FreeAndNil(oProduto);
end;

procedure TfrmCadProdutos.FormCreate(Sender: TObject);
begin
  inherited;
  oProduto := Tproduto.Create(dtmPrincipal.ConexaoDB);
  IndiceAtual := 'nome';
end;

procedure TfrmCadProdutos.FormShow(Sender: TObject);
begin
  inherited;
  QryCategoria.Open;
end;

end.
