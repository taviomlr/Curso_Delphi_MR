{*******************************************************}
{                                                       }
{     Delphi VCL Extensions (RX) demo program           }
{                                                       }
{     Copyright (c) 1996 AO ROSNO                       }
{                                                       }
{*******************************************************}

unit FiltDlg;

interface

uses Messages, WinTypes, WinProcs, SysUtils, Classes, Graphics, Forms,
  Controls, StdCtrls, Buttons, ExtCtrls, RxPlacemnt, RxMRUList;

type
  TFilterDialog = class(TForm)
    Label1: TLabel;
    OkBtn: TButton;
    CancelBtn: TButton;
    Storage: TFormStorage;
    UpCaseBox: TCheckBox;
    FilterEdit: TComboBox;
    MRU: TMRUManager;
    procedure FormCreate(Sender: TObject);
    procedure UpCaseBoxClick(Sender: TObject);
    procedure FilterEditChange(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FUpdating: Boolean;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

function ShowFilterDialog(var Filter: string; X, Y: Integer): Boolean;

implementation

uses {$IFNDEF VER80} BDE, {$ELSE} DbiTypes, {$ENDIF} RxAppUtils;

{$R *.DFM}

function ShowFilterDialog(var Filter: string; X, Y: Integer): Boolean;
begin
  with TFilterDialog.Create(Application) do
  try
    Left := X;
    Top := Y;
    FilterEdit.Text := Filter;
    Result := ShowModal = mrOk;
    if Result then Filter := FilterEdit.Text;
  finally
    Free;
  end;
end;

{ TFilterDialog }

procedure TFilterDialog.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if Application.MainForm <> nil then
    Params.WndParent := Application.MainForm.Handle;
end;

procedure TFilterDialog.FormCreate(Sender: TObject);
begin
  FilterEdit.MaxLength := DBIMAXTBLNAMELEN;
{$IFNDEF VER80}
  UpCaseBox.Visible := True;
  BorderStyle := bsToolWindow;
{$ENDIF}
end;

procedure TFilterDialog.UpCaseBoxClick(Sender: TObject);
begin
  if UpCaseBox.Checked then FilterEdit.Text := AnsiUpperCase(FilterEdit.Text);
end;

procedure TFilterDialog.FilterEditChange(Sender: TObject);
var
  SelStart, SelEnd: Integer;
{$IFDEF VER80}
  Res: LongInt;
{$ENDIF}
begin
  if UpCaseBox.Checked and not FUpdating then begin
    FUpdating := True;
    try
      if FilterEdit.HandleAllocated then begin
{$IFNDEF VER80}
        SendMessage(FilterEdit.Handle, CB_GETEDITSEL, WPARAM(@SelStart),
          LPARAM(@SelEnd));
{$ELSE}
        Res := SendMessage(FilterEdit.Handle, CB_GETEDITSEL, 0, 0);
        SelStart := LoWord(Res);
        SelEnd := HiWord(Res);
{$ENDIF}
      end;
      FilterEdit.Text := AnsiUpperCase(FilterEdit.Text);
      if FilterEdit.HandleAllocated then begin
        SendMessage(FilterEdit.Handle, CB_SETEDITSEL, 0,
{$IFNDEF VER80}
          MakeLParam(SelStart, SelEnd));
{$ELSE}
          MakeLong(SelStart, SelEnd));
{$ENDIF}
      end;
    finally
      FUpdating := False;
    end;
  end;
end;

procedure TFilterDialog.OkBtnClick(Sender: TObject);
begin
  MRU.Add(FilterEdit.Text, 0);
end;

procedure TFilterDialog.FormShow(Sender: TObject);
begin
  FilterEdit.Items.Assign(MRU.Strings);
end;

end.