{*******************************************************}
{                                                       }
{         Delphi VCL Extensions (RX)                    }
{                                                       }
{         Copyright (c) 1995, 1996 AO ROSNO             }
{         Copyright (c) 1997 Master-Bank                }
{                                                       }
{*******************************************************}

unit RxSplit;

interface

{$I RX.INC}

uses Classes, {$IFNDEF VER80} Windows, {$ELSE} WinTypes, WinProcs, {$ENDIF}
  Controls, ExtCtrls, Forms, Graphics,
  {$IFDEF RX_D6}Types,{$ENDIF}
  RxVCLUtils;

type

{ TRxSplitter }

  TSplitterStyle = (spUnknown, spHorizontalFirst, spHorizontalSecond,
    spVerticalFirst, spVerticalSecond);
  TInverseMode = (imNew, imClear, imMove);
  TSplitterMoveEvent = procedure (Sender: TObject; X, Y: Integer;
    var AllowChange: Boolean) of object;

  {$IFDEF RX_D16}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
  {$ENDIF}
  TRxSplitter = class(TCustomPanel)
  private
    FControlFirst: TControl;
    FControlSecond: TControl;
    FSizing: Boolean;
    FStyle: TSplitterStyle;
    FPrevOrg: TPoint;
    FOffset: TPoint;
    FNoDropCursor: Boolean;
    FLimitRect: TRect;
    FTopLeftLimit: Integer;
    FBottomRightLimit: Integer;
    FForm: TCustomForm;
    FActiveControl: TWinControl;
    FAppShowHint: Boolean;
    FOldKeyDown: TKeyEvent;
    FOnPosChanged: TNotifyEvent;
    FOnPosChanging: TSplitterMoveEvent;
    function FindControl: TControl;
    procedure ControlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure StartInverseRect;
    procedure EndInverseRect(X, Y: Integer; AllowChange, Apply: Boolean);
    function GetAlign: TAlign;
    procedure MoveInverseRect(X, Y: Integer; AllowChange: Boolean);
    procedure ShowInverseRect(X, Y: Integer; Mode: TInverseMode);
    procedure DrawSizingLine(Split: TPoint);
    function GetStyle: TSplitterStyle;
    function GetCursor: TCursor;
    procedure SetControlFirst(Value: TControl);
    procedure SetControlSecond(Value: TControl);
    procedure SetAlign(Value: TAlign);
    procedure StopSizing(X, Y: Integer; Apply: Boolean);
    procedure CheckPosition(var X, Y: Integer);
    procedure ReadOffset(Reader: TReader);
    procedure WriteOffset(Writer: TWriter);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Changed; dynamic;
    procedure Changing(X, Y: Integer; var AllowChange: Boolean); dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    procedure UpdateState;
  published
    property ControlFirst: TControl read FControlFirst write SetControlFirst;
    property ControlSecond: TControl read FControlSecond write SetControlSecond;
    property Align: TAlign read GetAlign write SetAlign default alNone;
{$IFDEF RX_D4}
    property Constraints;
{$ENDIF}
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property BorderStyle;
    property Enabled;
    property Color;
    property Ctl3D {$IFNDEF VER80} default False {$ENDIF};
    property Cursor read GetCursor stored False;
    property TopLeftLimit: Integer read FTopLeftLimit write FTopLeftLimit default 20;
    property BottomRightLimit: Integer read FBottomRightLimit write FBottomRightLimit default 20;
    property ParentColor;
    property ParentCtl3D default False;
    property ParentShowHint;
    property ShowHint;
    property Visible;
    property OnPosChanged: TNotifyEvent read FOnPosChanged write FOnPosChanged;
    property OnPosChanging: TSplitterMoveEvent read FOnPosChanging write FOnPosChanging;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
{$IFDEF RX_D6}
    property AutoSize;
    property BevelEdges;
    property BevelKind;
    property Caption;
    property UseDockManager default True;
    property DockSite;
    property FullRepaint;
    property Locked;
    {$IFDEF RX_D7}
    property ParentBackground default False;
    {$ENDIF}
    {$IFDEF RX_D9}
    property VerticalAlignment;
    property OnAlignInsertBefore;
    property OnAlignPosition;
    {$ENDIF}
    property OnCanResize;
    property OnConstrainedResize;
    property OnDockDrop;
    property OnDockOver;
    property OnGetSiteInfo;
    {$IFDEF RX_D9}
    property OnMouseActivate;
    {$ENDIF}
    property OnUnDock;
{$ENDIF}
  end;

implementation

uses SysUtils;

const
  InverseThickness = 2;
  DefWidth = 3;

function CToC(C1, C2: TControl; P: TPoint): TPoint;
begin
  Result := C1.ScreenToClient(C2.ClientToScreen(P));
end;

type
  THack = class(TWinControl);

{ TRxSplitter }

constructor TRxSplitter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
    csOpaque, csDoubleClicks];
  Width := 185;
  Height := DefWidth;
  FSizing := False;
  FTopLeftLimit := 20;
  FBottomRightLimit := 20;
  FControlFirst := nil;
  FControlSecond := nil;
  ParentCtl3D := False;
{$IFNDEF VER80}
  Ctl3D := False;
{$ENDIF}
{$IFDEF RX_D7}
  ParentBackground := False;
{$ENDIF}
end;

procedure TRxSplitter.Loaded;
begin
  inherited Loaded;
  UpdateState;
end;

procedure TRxSplitter.DefineProperties(Filer: TFiler); { for backward compatibility }
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('LimitOffset', ReadOffset, WriteOffset, False);
end;

procedure TRxSplitter.ReadOffset(Reader: TReader);
var
  I: Integer;
begin
  I := Reader.ReadInteger;
  FTopLeftLimit := I;
  FBottomRightLimit := I;
end;

procedure TRxSplitter.WriteOffset(Writer: TWriter);
begin
  Writer.WriteInteger(FTopLeftLimit);
end;

procedure TRxSplitter.UpdateState;
begin
  inherited Cursor := Cursor;
end;

function TRxSplitter.FindControl: TControl;
var
  P: TPoint;
  I: Integer;
begin
  Result := nil;
  P := Point(Left, Top);
  case Align of
    alLeft: Dec(P.X);
    alRight: Inc(P.X, Width);
    alTop: Dec(P.Y);
    alBottom: Inc(P.Y, Height);
    else Exit;
  end;
  for I := 0 to Parent.ControlCount - 1 do begin
    Result := Parent.Controls[I];
    if PtInRect(Result.BoundsRect, P) then Exit;
  end;
  Result := nil;
end;

procedure TRxSplitter.CheckPosition(var X, Y: Integer);
begin
  if X - FOffset.X < FLimitRect.Left then
    X := FLimitRect.Left + FOffset.X
  else if X - FOffset.X + Width > FLimitRect.Right then
    X := FLimitRect.Right - Width + FOffset.X;
  if Y - FOffset.Y < FLimitRect.Top then
    Y := FLimitRect.Top + FOffset.Y
  else if Y - FOffset.Y + Height > FLimitRect.Bottom then
    Y := FLimitRect.Bottom + FOffset.Y - Height;
end;

procedure TRxSplitter.StartInverseRect;
var
  R: TRect;
  W: Integer;
begin
  if Parent = nil then Exit;
  R := Parent.ClientRect;
  FLimitRect.TopLeft := CToC(Self, Parent, Point(R.Left + FTopLeftLimit,
    R.Top + FTopLeftLimit));
  FLimitRect.BottomRight := CToC(Self, Parent, Point(R.Right - R.Left -
    FBottomRightLimit, R.Bottom - R.Top - FBottomRightLimit));
  FNoDropCursor := False;
  FForm := ValidParentForm(Self);
  FForm.Canvas.Handle := GetDCEx(FForm.Handle, 0, DCX_CACHE or DCX_CLIPSIBLINGS
    or DCX_LOCKWINDOWUPDATE);
  with FForm.Canvas do begin
    Pen.Color := clWhite;
    if FStyle in [spHorizontalFirst, spHorizontalSecond] then W := Height
    else W := Width;
    if W > InverseThickness + 1 then W := W - InverseThickness
    else W := InverseThickness;
    Pen.Width := W;
    Pen.Mode := pmXOR;
  end;
  ShowInverseRect(Width div 2, Height div 2, imNew);
end;

procedure TRxSplitter.EndInverseRect(X, Y: Integer; AllowChange,
  Apply: Boolean);
const
  DecSize = 3;
var
  NewSize: Integer;
  Rect: TRect;
  W, H: Integer;
  DC: HDC;
  P: TPoint;
begin
  if FForm <> nil then begin
    ShowInverseRect(0, 0, imClear);
    with FForm do begin
      DC := Canvas.Handle;
      Canvas.Handle := 0;
      ReleaseDC(Handle, DC);
    end;
    FForm := nil;
  end;
  FNoDropCursor := False;
  if Parent = nil then Exit;
  Rect := Parent.ClientRect;
  H := Rect.Bottom - Rect.Top - Height;
  W := Rect.Right - Rect.Left - Width;
  if not AllowChange then begin
    P := ScreenToClient(FPrevOrg);
    X := P.X + FOffset.X - Width div 2;
    Y := P.Y + FOffset.Y - Height div 2
  end;
  if not Apply then Exit;
  CheckPosition(X, Y);
  if (ControlFirst.Align = alRight) or
    ((ControlSecond <> nil) and (ControlSecond.Align = alRight)) then
  begin
    X := -X;
    FOffset.X := -FOffset.X;
  end;
  if (ControlFirst.Align = alBottom) or
    ((ControlSecond <> nil) and (ControlSecond.Align = alBottom)) then
  begin
    Y := -Y;
    FOffset.Y := -FOffset.Y;
  end;
  Parent.DisableAlign;
  try
    if FStyle = spHorizontalFirst then begin
      NewSize := ControlFirst.Height + Y - FOffset.Y;
      if NewSize <= 0 then NewSize := 1;
      if NewSize >= H then NewSize := H - DecSize;
      ControlFirst.Height := NewSize;
    end
    else if FStyle = spHorizontalSecond then begin
      NewSize := ControlSecond.Height + Y - FOffset.Y;
      if NewSize <= 0 then NewSize := 1;
      if NewSize >= H then NewSize := H - DecSize;
      ControlSecond.Height := NewSize;
    end
    else if FStyle = spVerticalFirst then begin
      NewSize := ControlFirst.Width + X - FOffset.X;
      if NewSize <= 0 then NewSize := 1;
      if NewSize >= W then NewSize := W - DecSize;
      ControlFirst.Width := NewSize;
    end
    else if FStyle = spVerticalSecond then begin
      NewSize := ControlSecond.Width + X - FOffset.X;
      if NewSize <= 0 then NewSize := 1;
      if NewSize >= W then NewSize := W - DecSize;
      ControlSecond.Width := NewSize;
    end;
  finally
    Parent.EnableAlign;
  end;
end;

procedure TRxSplitter.MoveInverseRect(X, Y: Integer; AllowChange: Boolean);
var
  P: TPoint;
  NoDrop: Boolean;
begin
  if not AllowChange then begin
    SetCursor(Screen.Cursors[crNoDrop]);
    Exit;
  end;
  P := Point(X, Y);
  CheckPosition(X, Y);
  NoDrop := not AllowChange or (((X <> P.X) and (FStyle in [spVerticalFirst,
    spVerticalSecond])) or ((Y <> P.Y) and (FStyle in [spHorizontalFirst,
    spHorizontalSecond])));
  if NoDrop <> FNoDropCursor then begin
    FNoDropCursor := NoDrop;
    if NoDrop then SetCursor(Screen.Cursors[crNoDrop])
    else SetCursor(Screen.Cursors[Cursor]);
  end;
  ShowInverseRect(X - FOffset.X + Width div 2, Y - FOffset.Y + Height div 2,
    imMove);
end;

procedure TRxSplitter.ShowInverseRect(X, Y: Integer; Mode: TInverseMode);
var
  P: TPoint;
  MaxRect: TRect;
  Horiz: Boolean;
begin
  P := Point(0, 0);
  if FStyle in [spHorizontalFirst, spHorizontalSecond] then begin
    P.Y := Y;
    Horiz := True;
  end
  else begin
    P.X := X;
    Horiz := False;
  end;
  MaxRect := Parent.ClientRect;
  P := ClientToScreen(P);
  with P, MaxRect do begin
    TopLeft := Parent.ClientToScreen(TopLeft);
    BottomRight := Parent.ClientToScreen(BottomRight);
    if X < Left then X := Left;
    if X > Right then X := Right;
    if Y < Top then Y := Top;
    if Y > Bottom then Y := Bottom;
  end;
  if (Mode = imMove) then
    if ((P.X = FPrevOrg.X) and not Horiz) or
      ((P.Y = FPrevOrg.Y) and Horiz) then Exit;
  if Mode in [imClear, imMove] then
    DrawSizingLine(FPrevOrg);
  if Mode in [imNew, imMove] then begin
    DrawSizingLine(P);
    FPrevOrg := P;
  end;
end;

procedure TRxSplitter.DrawSizingLine(Split: TPoint);
var
  P: TPoint;
begin
  if FForm <> nil then begin
    P := FForm.ScreenToClient(Split);
    with FForm.Canvas do begin
      MoveTo(P.X, P.Y);
      if FStyle in [spHorizontalFirst, spHorizontalSecond] then
        LineTo(CToC(FForm, Self, Point(Width, 0)).X, P.Y)
      else LineTo(P.X, CToC(FForm, Self, Point(0, Height)).Y);
    end;
  end;
end;

function TRxSplitter.GetStyle: TSplitterStyle;
begin
  Result := spUnknown;
  if ControlFirst <> nil then begin
    if ((ControlFirst.Align = alTop) and ((ControlSecond = nil) or
       (ControlSecond.Align = alClient))) or
       ((ControlFirst.Align = alBottom) and ((ControlSecond = nil) or
       (ControlSecond.Align = alClient))) then
      Result := spHorizontalFirst
    else if ((ControlFirst.Align = alClient) and (ControlSecond <> nil) and
       (ControlSecond.Align = alBottom)) or
       ((ControlFirst.Align = alClient) and (ControlSecond <> nil) and
       (ControlSecond.Align = alTop)) then
      Result := spHorizontalSecond
    else if ((ControlFirst.Align = alLeft) and ((ControlSecond = nil) or
       (ControlSecond.Align = alClient))) or
       ((ControlFirst.Align = alRight) and ((ControlSecond = nil) or
       (ControlSecond.Align = alClient))) then
      Result := spVerticalFirst
    else if ((ControlFirst.Align = alClient) and (ControlSecond <> nil) and
       (ControlSecond.Align = alRight)) or
       ((ControlFirst.Align = alClient) and (ControlSecond <> nil) and
       (ControlSecond.Align = alLeft)) then
      Result := spVerticalSecond;
    case Result of
      spHorizontalFirst, spVerticalFirst:
        if Align <> FControlFirst.Align then Result := spUnknown;
      spHorizontalSecond, spVerticalSecond:
        if Align <> FControlSecond.Align then Result := spUnknown;
    end;
  end;
end;

procedure TRxSplitter.SetAlign(Value: TAlign);
begin
  if not (Align in [alTop, alBottom, alLeft, alRight]) then begin
    inherited Align := Value;
    if not (csReading in ComponentState) then begin
      if Value in [alTop, alBottom] then Height := DefWidth
      else if Value in [alLeft, alRight] then Width := DefWidth;
    end;
  end
  else inherited Align := Value;
  if (ControlFirst = nil) and (ControlSecond = nil) then
    ControlFirst := FindControl;
end;

function TRxSplitter.GetAlign: TAlign;
begin
  Result := inherited Align;
end;

function TRxSplitter.GetCursor: TCursor;
begin
  Result := crDefault;
  case GetStyle of
    spHorizontalFirst, spHorizontalSecond: Result := crVSplit;
    spVerticalFirst, spVerticalSecond: Result := crHSplit;
  end;
end;

procedure TRxSplitter.SetControlFirst(Value: TControl);
begin
  if Value <> FControlFirst then begin
    if (Value = Self) or (Value is TForm) then FControlFirst := nil
    else begin
      FControlFirst := Value;
{$IFNDEF VER80}
      if Value <> nil then Value.FreeNotification(Self);
{$ENDIF}
    end;
    UpdateState;
  end;
end;

procedure TRxSplitter.SetControlSecond(Value: TControl);
begin
  if Value <> FControlSecond then begin
    if (Value = Self) or (Value is TForm) then FControlSecond := nil
    else begin
      FControlSecond := Value;
{$IFNDEF VER80}
      if Value <> nil then Value.FreeNotification(Self);
{$ENDIF}
    end;
    UpdateState;
  end;
end;

procedure TRxSplitter.Notification(AComponent: TComponent; AOperation: TOperation);
begin
  inherited Notification(AComponent, AOperation);
  if AOperation = opRemove then begin
    if AComponent = ControlFirst then ControlFirst := nil
    else if AComponent = ControlSecond then ControlSecond := nil;
  end;
end;

procedure TRxSplitter.Changed;
begin
  if Assigned(FOnPosChanged) then FOnPosChanged(Self);
end;

procedure TRxSplitter.Changing(X, Y: Integer; var AllowChange: Boolean);
begin
  if Assigned(FOnPosChanging) then FOnPosChanging(Self, X, Y, AllowChange);
end;

procedure TRxSplitter.StopSizing(X, Y: Integer; Apply: Boolean);
var
  AllowChange: Boolean;
begin
  if FSizing then begin
    ReleaseCapture;
    AllowChange := Apply;
    if Apply then Changing(X, Y, AllowChange);
    EndInverseRect(X, Y, AllowChange, Apply);
    FSizing := False;
    Application.ShowHint := FAppShowHint;
    if Assigned(FActiveControl) then begin
      THack(FActiveControl).OnKeyDown := FOldKeyDown;
      FActiveControl := nil;
    end;
    if Apply then Changed;
  end;
end;

procedure TRxSplitter.ControlKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then StopSizing(0, 0, False)
  else if Assigned(FOldKeyDown) then FOldKeyDown(Sender, Key, Shift);
end;

procedure TRxSplitter.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if not (csDesigning in ComponentState) and (Button = mbLeft) then begin
    FStyle := GetStyle;
    if FStyle <> spUnknown then begin
      FSizing := True;
      FAppShowHint := Application.ShowHint;
      SetCapture(Handle);
      with ValidParentForm(Self) do begin
        if ActiveControl <> nil then FActiveControl := ActiveControl
        else FActiveControl := GetParentForm(Self);
        FOldKeyDown := THack(FActiveControl).OnKeyDown;
        THack(FActiveControl).OnKeyDown := ControlKeyDown;
      end;
      Application.ShowHint := False;
      FOffset := Point(X, Y);
      StartInverseRect;
    end;
  end;
end;

procedure TRxSplitter.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  AllowChange: Boolean;
begin
  inherited MouseMove(Shift, X, Y);
  if (GetCapture = Handle) and FSizing then begin
    AllowChange := True;
    Changing(X, Y, AllowChange);
    MoveInverseRect(X, Y, AllowChange);
  end;
end;

procedure TRxSplitter.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  StopSizing(X, Y, True);
  inherited MouseUp(Button, Shift, X, Y);
end;

end.