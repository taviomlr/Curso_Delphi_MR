{*******************************************************}
{                                                       }
{         Delphi VCL Extensions (RX)                    }
{                                                       }
{         Copyright (c) 1995, 1996 AO ROSNO             }
{         Copyright (c) 1997, 1998 Master-Bank          }
{                                                       }
{*******************************************************}

unit RxSlider;

interface

{$I RX.INC}

uses
  {$IFNDEF VER80}Windows, {$ELSE}WinTypes, WinProcs, {$ENDIF}
  Controls, ExtCtrls, Classes, Graphics, Messages, Menus
  {$IFDEF RX_D6}, Types{$ENDIF};

type
  TNumThumbStates = 1..2;
  TSliderOrientation = (soHorizontal, soVertical);
  TSliderOption = (soShowFocus, soShowPoints, soSmooth,
    soRulerOpaque, soThumbOpaque);
  TSliderOptions = set of TSliderOption;
  TSliderImage = (siHThumb, siHRuler, siVThumb, siVRuler);
  TSliderImages = set of TSliderImage;
  TSliderImageArray = array[TSliderImage] of TBitmap;
  TJumpMode = (jmNone, jmHome, jmEnd, jmNext, jmPrior);

{ TRxCustomSlider }

  {$IFDEF RX_D16}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
  {$ENDIF}
  TRxCustomSlider = class(TCustomControl)
  private
    FUserImages: TSliderImages;
    FImages: TSliderImageArray;
    FEdgeSize: Integer;
    FRuler: TBitmap;
    FPaintBuffered: Boolean;
    FRulerOrg: TPoint;
    FThumbRect: TRect;
    FThumbDown: Boolean;
    FNumThumbStates: TNumThumbStates;
    FPointsRect: TRect;
    FOrientation: TSliderOrientation;
    FOptions: TSliderOptions;
    FBevelStyle: TPanelBevel;
    FBevelWidth: Integer;
    FMinValue: LongInt;
    FMaxValue: LongInt;
    FIncrement: LongInt;
    FValue: LongInt;
    FHit: Integer;
    FFocused: Boolean;
    FSliding: Boolean;
    FTracking: Boolean;
    FTimerActive: Boolean;
    FMousePos: TPoint;
    FStartJump: TJumpMode;
    FReadOnly: Boolean;
    FOnChange: TNotifyEvent;
    FOnChanged: TNotifyEvent;
    FOnDrawPoints: TNotifyEvent;
    function GetImage(Index: Integer): TBitmap;
    procedure SetImage(Index: Integer; Value: TBitmap);
    procedure SliderImageChanged(Sender: TObject);
    procedure SetEdgeSize(Value: Integer);
    function GetNumThumbStates: TNumThumbStates;
    procedure SetNumThumbStates(Value: TNumThumbStates);
    procedure SetBevelStyle(Value: TPanelBevel);
    procedure SetOrientation(Value: TSliderOrientation);
    procedure SetOptions(Value: TSliderOptions);
    procedure SetMinValue(Value: LongInt);
    procedure SetMaxValue(Value: LongInt);
    procedure SetIncrement(Value: LongInt);
    procedure SetReadOnly(Value: Boolean);
    function GetThumbOffset: Integer;
    procedure SetThumbOffset(Value: Integer);
    procedure SetValue(Value: LongInt);
    procedure ThumbJump(Jump: TJumpMode);
    function GetThumbPosition(var Offset: Integer): TPoint;
    function JumpTo(X, Y: Integer): TJumpMode;
    procedure InvalidateThumb;
    procedure StopTracking;
    procedure TimerTrack;
    function StoreImage(Index: Integer): Boolean;
    procedure CreateElements;
    procedure BuildRuler(R: TRect);
    procedure AdjustElements;
    procedure ReadUserImages(Stream: TStream);
    procedure WriteUserImages(Stream: TStream);
    procedure InternalDrawPoints(ACanvas: TCanvas; PointsStep, PointsHeight,
      ExtremePointsHeight: LongInt);
    procedure DrawThumb(Canvas: TCanvas; Origin: TPoint; Highlight: Boolean);
    function GetValueByOffset(Offset: Integer): LongInt;
    function GetOffsetByValue(Value: LongInt): Integer;
    function GetRulerLength: Integer;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFocusChanged(var Message: TCMFocusChanged); message CM_FOCUSCHANGED;
    procedure WMGetDlgCode(var Msg: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMSetCursor(var Message: TWMSetCursor); message WM_SETCURSOR;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMTimer(var Message: TMessage); message WM_TIMER;
  protected
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Paint; override;
    function CanModify: Boolean; virtual;
    function GetSliderRect: TRect; virtual;
    function GetSliderValue: LongInt; virtual;
    procedure Change; dynamic;
    procedure Changed; dynamic;
    procedure Sized; virtual;
    procedure RangeChanged; virtual;
    procedure SetRange(Min, Max: LongInt);
    procedure ThumbMouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); virtual;
    procedure ThumbMouseMove(Shift: TShiftState; X, Y: Integer); virtual;
    procedure ThumbMouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); virtual;
    property ThumbOffset: Integer read GetThumbOffset write SetThumbOffset;
    property SliderRect: TRect read GetSliderRect;
    property BevelStyle: TPanelBevel read FBevelStyle write SetBevelStyle
      default bvNone;
    property ImageHThumb: TBitmap index Ord(siHThumb) read GetImage
      write SetImage stored StoreImage;
    property ImageHRuler: TBitmap index Ord(siHRuler) read GetImage
      write SetImage stored StoreImage;
    property ImageVThumb: TBitmap index Ord(siVThumb) read GetImage
      write SetImage stored StoreImage;
    property ImageVRuler: TBitmap index Ord(siVRuler) read GetImage
      write SetImage stored StoreImage;
    property NumThumbStates: TNumThumbStates read GetNumThumbStates
      write SetNumThumbStates default 2;
    property Orientation: TSliderOrientation read FOrientation
      write SetOrientation default soHorizontal;
    property EdgeSize: Integer read FEdgeSize write SetEdgeSize default 2;
    property Options: TSliderOptions read FOptions write SetOptions
      default [soShowFocus, soShowPoints, soSmooth];
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
    property OnDrawPoints: TNotifyEvent read FOnDrawPoints write FOnDrawPoints;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DefaultDrawPoints(PointsStep, PointsHeight,
      ExtremePointsHeight: LongInt); virtual;
    property Canvas;
    property Increment: LongInt read FIncrement write SetIncrement default 10;
    property MinValue: LongInt read FMinValue write SetMinValue default 0;
    property MaxValue: LongInt read FMaxValue write SetMaxValue default 100;
    property Value: LongInt read FValue write SetValue default 0;
  end;

{ TRxSlider }

  {$IFDEF RX_D16}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
  {$ENDIF}
  TRxSlider = class(TRxCustomSlider)
  published
    property Align;
    property BevelStyle;
    property Color;
    property Cursor;
    property DragMode;
    property DragCursor;
    property Enabled;
    property ImageHThumb;
    property ImageHRuler;
    property ImageVThumb;
    property ImageVRuler;
    property Increment;
    property MinValue;
    property MaxValue;
    property NumThumbStates;
    property Orientation;
    { ensure Orientation is published before EdgeSize }
    property EdgeSize;
    property Options;
    property ParentColor;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Value;
    property Visible;
    {$IFDEF RX_D4}
    property Anchors;
    property Constraints;
    property DragKind;
    {$ENDIF}
    property OnChange;
    property OnChanged;
    property OnDrawPoints;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnMouseMove;
    property OnMouseDown;
    property OnMouseUp;
    property OnKeyDown;
    property OnKeyUp;
    property OnKeyPress;
    property OnDragOver;
    property OnDragDrop;
    property OnEndDrag;
    {$IFNDEF VER80}
    property OnStartDrag;
    {$ENDIF}
    {$IFDEF RX_D5}
    property OnContextPopup;
    {$ENDIF}
    {$IFDEF RX_D4}
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnEndDock;
    property OnStartDock;
    {$ENDIF}
  end;

{ TRxCustomTrackBar }

  TRxSliderImages = class;

  TRxCustomTrackBar = class(TRxCustomSlider)
  private
    FImages: TRxSliderImages;
  protected
    property Images: TRxSliderImages read FImages write FImages;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TRxSliderImages = class(TPersistent)
  private
    FSlider: TRxCustomSlider;
    function GetNumThumbStates: TNumThumbStates;
    procedure SetNumThumbStates(Value: TNumThumbStates);
    function GetEdgeSize: Integer;
    procedure SetEdgeSize(Value: Integer);
    function GetImage(Index: Integer): TBitmap;
    procedure SetImage(Index: Integer; Value: TBitmap);
    function StoreImage(Index: Integer): Boolean;
  published
    property HorzThumb: TBitmap index Ord(siHThumb) read GetImage
      write SetImage stored StoreImage;
    property HorzRuler: TBitmap index Ord(siHRuler) read GetImage
      write SetImage stored StoreImage;
    property VertThumb: TBitmap index Ord(siVThumb) read GetImage
      write SetImage stored StoreImage;
    property VertRuler: TBitmap index Ord(siVRuler) read GetImage
      write SetImage stored StoreImage;
    property NumThumbStates: TNumThumbStates read GetNumThumbStates
      write SetNumThumbStates default 2;
    property EdgeSize: Integer read GetEdgeSize write SetEdgeSize default 2;
  end;

implementation

uses
  Consts, Forms, SysUtils, RxVCLUtils, RxMaxMin, RxConst;

{$R *.RES}

const
  ImagesResNames: array[TSliderImage] of PChar =
  ('W95_HTB', 'W95_HRL', 'W95_VTB', 'W95_VRL');
  Indent = 6;
  JumpInterval = 400;

{ TRxCustomSlider }

constructor TRxCustomSlider.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlState := ControlState + [csCreating];
  ControlStyle := [csClickEvents, csCaptureMouse, csAcceptsControls,
    csDoubleClicks, csOpaque];
  Width := 150;
  Height := 40;
  FNumThumbStates := 2;
  FBevelWidth := 1;
  FOrientation := soHorizontal;
  FOptions := [soShowFocus, soShowPoints, soSmooth];
  FEdgeSize := 2;
  FMinValue := 0;
  FMaxValue := 100;
  FIncrement := 10;
  TabStop := True;
  CreateElements;
  ControlState := ControlState - [csCreating];
end;

destructor TRxCustomSlider.Destroy;
var
  I: TSliderImage;
begin
  FOnChange := nil;
  FOnChanged := nil;
  FOnDrawPoints := nil;
  FRuler.Free;
  for I := Low(FImages) to High(FImages) do
  begin
    FImages[I].OnChange := nil;
    FImages[I].Free;
  end;
  inherited Destroy;
end;

procedure TRxCustomSlider.Loaded;
var
  I: TSliderImage;
begin
  inherited Loaded;
  for I := Low(FImages) to High(FImages) do
    if I in FUserImages then SetImage(Ord(I), FImages[I]);
end;

procedure TRxCustomSlider.AlignControls(AControl: TControl; var Rect: TRect);
var
  BevelSize: Integer;
begin
  BevelSize := 0;
  if BevelStyle <> bvNone then Inc(BevelSize, FBevelWidth);
  InflateRect(Rect, -BevelSize, -BevelSize);
  inherited AlignControls(AControl, Rect);
end;

procedure TRxCustomSlider.WMPaint(var Message: TWMPaint);
var
  DC, MemDC: HDC;
  MemBitmap, OldBitmap: HBITMAP;
  PS: TPaintStruct;
begin
  if FPaintBuffered then
    inherited
  else
  begin
    {$IFDEF RX_D3}
    Canvas.Lock;
    try
      {$ENDIF}
      MemDC := GetDC(0);
      MemBitmap := CreateCompatibleBitmap(MemDC, ClientWidth, ClientHeight);
      ReleaseDC(0, MemDC);
      MemDC := CreateCompatibleDC(0);
      OldBitmap := SelectObject(MemDC, MemBitmap);
      try
        DC := Message.DC;
        Perform(WM_ERASEBKGND, MemDC, MemDC);
        FPaintBuffered := True;
        Message.DC := MemDC;
        try
          WMPaint(Message);
        finally
          Message.DC := DC;
          FPaintBuffered := False;
        end;
        if DC = 0 then DC := BeginPaint(Handle, PS);
        BitBlt(DC, 0, 0, ClientWidth, ClientHeight, MemDC, 0, 0, SRCCOPY);
        if Message.DC = 0 then EndPaint(Handle, PS);
      finally
        SelectObject(MemDC, OldBitmap);
        DeleteDC(MemDC);
        DeleteObject(MemBitmap);
      end;
      {$IFDEF RX_D3}
    finally
      Canvas.Unlock;
    end;
    {$ENDIF}
  end;
end;

procedure TRxCustomSlider.Paint;
var
  R: TRect;
  TopColor, BottomColor, TransColor: TColor;
  HighlightThumb: Boolean;
  P: TPoint;
  {$IFNDEF VER80}
  Offset: Integer;
  {$ENDIF}
begin
  {$IFNDEF VER80}
  if csPaintCopy in ControlState then
  begin
    Offset := GetOffsetByValue(GetSliderValue);
    P := GetThumbPosition(Offset);
  end
  else
    {$ENDIF}
    P := Point(FThumbRect.Left, FThumbRect.Top);
  R := GetClientRect;
  if BevelStyle <> bvNone then
  begin
    TopColor := clBtnHighlight;
    if BevelStyle = bvLowered then TopColor := clBtnShadow;
    BottomColor := clBtnShadow;
    if BevelStyle = bvLowered then BottomColor := clBtnHighlight;
    Frame3D(Canvas, R, TopColor, BottomColor, FBevelWidth);
  end;
  if (csOpaque in ControlStyle) then
    with Canvas do
    begin
      Brush.Color := Color;
      FillRect(R);
    end;
  if FRuler.Width > 0 then
  begin
    if soRulerOpaque in Options then
      TransColor := clNone
    else
      TransColor := FRuler.TransparentColor;
    DrawBitmapTransparent(Canvas, FRulerOrg.X, FRulerOrg.Y, FRuler,
      TransColor);
  end;
  if (soShowFocus in Options) and FFocused and
    not (csDesigning in ComponentState) then
  begin
    R := SliderRect;
    InflateRect(R, -2, -2);
    Canvas.DrawFocusRect(R);
  end;
  if (soShowPoints in Options) then
  begin
    if Assigned(FOnDrawPoints) then
      FOnDrawPoints(Self)
    else
      InternalDrawPoints(Canvas, Increment, 3, 5);
  end;
  {$IFNDEF VER80}
  if csPaintCopy in ControlState then
    HighlightThumb := not Enabled
  else
    {$ENDIF}
    HighlightThumb := FThumbDown or not Enabled;
  DrawThumb(Canvas, P, HighlightThumb);
end;

function TRxCustomSlider.CanModify: Boolean;
begin
  Result := True;
end;

function TRxCustomSlider.GetSliderValue: LongInt;
begin
  Result := FValue;
end;

function TRxCustomSlider.GetSliderRect: TRect;
begin
  Result := Bounds(0, 0, Width, Height);
  if BevelStyle <> bvNone then
    InflateRect(Result, -FBevelWidth, -FBevelWidth);
end;

procedure TRxCustomSlider.DrawThumb(Canvas: TCanvas; Origin: TPoint;
  Highlight: Boolean);
var
  R: TRect;
  Image: TBitmap;
  TransColor: TColor;
begin
  if Orientation = soHorizontal then
    Image := ImageHThumb
  else
    Image := ImageVThumb;
  R := Rect(0, 0, Image.Width, Image.Height);
  if NumThumbStates = 2 then
  begin
    if Highlight then
      R.Left := (R.Right - R.Left) div 2
    else
      R.Right := (R.Right - R.Left) div 2;
  end;
  if soThumbOpaque in Options then
    TransColor := clNone
  else
    TransColor := Image.TransparentColor;
  DrawBitmapRectTransparent(Canvas, Origin.X, Origin.Y, R, Image, TransColor);
end;

procedure TRxCustomSlider.InternalDrawPoints(ACanvas: TCanvas; PointsStep,
  PointsHeight, ExtremePointsHeight: LongInt);
const
  MinInterval = 3;
var
  RulerLength: Integer;
  Interval, Scale, PointsCnt, I, Val: LongInt;
  X, H, X1, X2, Y1, Y2: Integer;
  Range: Double;
begin
  RulerLength := GetRulerLength;
  ACanvas.Pen.Color := clWindowText;
  Scale := 0;
  Range := MaxValue - MinValue;
  repeat
    Inc(Scale);
    PointsCnt := Round(Range / (Scale * PointsStep)) + 1;
    if PointsCnt > 1 then
      Interval := RulerLength div (PointsCnt - 1)
    else
      Interval := RulerLength;
  until (Interval >= MinInterval + 1) or (Interval >= RulerLength);
  Val := MinValue;
  for I := 1 to PointsCnt do
  begin
    H := PointsHeight;
    if I = PointsCnt then Val := MaxValue;
    if (Val = MaxValue) or (Val = MinValue) then H := ExtremePointsHeight;
    X := GetOffsetByValue(Val);
    if Orientation = soHorizontal then
    begin
      X1 := X + (FImages[siHThumb].Width div NumThumbStates) div 2;
      Y1 := FPointsRect.Top;
      X2 := X1;
      Y2 := Y1 + H;
    end
    else
    begin
      X1 := FPointsRect.Left;
      Y1 := X + FImages[siVThumb].Height div 2;
      X2 := X1 + H;
      Y2 := Y1;
    end;
    with ACanvas do
    begin
      MoveTo(X1, Y1);
      LineTo(X2, Y2);
    end;
    Inc(Val, Scale * PointsStep);
  end;
end;

procedure TRxCustomSlider.DefaultDrawPoints(PointsStep, PointsHeight,
  ExtremePointsHeight: LongInt);
begin
  InternalDrawPoints(Canvas, PointsStep, PointsHeight, ExtremePointsHeight);
end;

procedure TRxCustomSlider.CreateElements;
var
  I: TSliderImage;
begin
  FRuler := TBitmap.Create;
  for I := Low(FImages) to High(FImages) do
    SetImage(Ord(I), nil);
  AdjustElements;
end;

procedure TRxCustomSlider.BuildRuler(R: TRect);
var
  DstR, BmpR: TRect;
  I, L, B, N, C, Offs, Len, RulerWidth: Integer;
  TmpBmp: TBitmap;
  Index: TSliderImage;
begin
  TmpBmp := TBitmap.Create;
  try
    if Orientation = soHorizontal then
      Index := siHRuler
    else
      Index := siVRuler;
    if Orientation = soHorizontal then
    begin
      L := R.Right - R.Left - 2 * Indent;
      if L < 0 then L := 0;
      TmpBmp.Width := L;
      TmpBmp.Height := FImages[Index].Height;
      L := TmpBmp.Width - 2 * FEdgeSize;
      B := FImages[Index].Width - 2 * FEdgeSize;
      RulerWidth := FImages[Index].Width;
    end
    else
    begin
      TmpBmp.Width := FImages[Index].Width;
      TmpBmp.Height := R.Bottom - R.Top - 2 * Indent;
      L := TmpBmp.Height - 2 * FEdgeSize;
      B := FImages[Index].Height - 2 * FEdgeSize;
      RulerWidth := FImages[Index].Height;
    end;
    N := (L div B) + 1;
    C := L mod B;
    for I := 0 to N - 1 do
    begin
      if I = 0 then
      begin
        Offs := 0;
        Len := RulerWidth - FEdgeSize;
      end
      else
      begin
        Offs := FEdgeSize + I * B;
        if I = N - 1 then
          Len := C + FEdgeSize
        else
          Len := B;
      end;
      if Orientation = soHorizontal then
        DstR := Rect(Offs, 0, Offs + Len, TmpBmp.Height)
      else
        DstR := Rect(0, Offs, TmpBmp.Width, Offs + Len);
      if I = 0 then
        Offs := 0
      else if I = N - 1 then
        Offs := FEdgeSize + B - C
      else
        Offs := FEdgeSize;
      if Orientation = soHorizontal then
        BmpR := Rect(Offs, 0, Offs + DstR.Right - DstR.Left, TmpBmp.Height)
      else
        BmpR := Rect(0, Offs, TmpBmp.Width, Offs + DstR.Bottom - DstR.Top);
      TmpBmp.Canvas.CopyRect(DstR, FImages[Index].Canvas, BmpR);
    end;
    FRuler.Assign(TmpBmp);
  finally
    TmpBmp.Free;
  end;
end;

procedure TRxCustomSlider.AdjustElements;
var
  SaveValue: LongInt;
  R: TRect;
begin
  SaveValue := Value;
  R := SliderRect;
  BuildRuler(R);
  if Orientation = soHorizontal then
  begin
    if FImages[siHThumb].Height > FRuler.Height then
    begin
      FThumbRect := Bounds(R.Left + Indent, R.Top + Indent,
        FImages[siHThumb].Width div NumThumbStates, FImages[siHThumb].Height);
      FRulerOrg := Point(R.Left + Indent, R.Top + Indent +
        (FImages[siHThumb].Height - FRuler.Height) div 2);
      FPointsRect := Rect(FRulerOrg.X, R.Top + Indent +
        FImages[siHThumb].Height + 1,
        FRulerOrg.X + FRuler.Width, R.Bottom - R.Top - 1);
    end
    else
    begin
      FThumbRect := Bounds(R.Left + Indent, R.Top + Indent +
        (FRuler.Height - FImages[siHThumb].Height) div 2,
        FImages[siHThumb].Width div NumThumbStates, FImages[siHThumb].Height);
      FRulerOrg := Point(R.Left + Indent, R.Top + Indent);
      FPointsRect := Rect(FRulerOrg.X, R.Top + Indent + FRuler.Height + 1,
        FRulerOrg.X + FRuler.Width, R.Bottom - R.Top - 1);
    end;
  end
  else
  begin { soVertical }
    if FImages[siVThumb].Width div NumThumbStates > FRuler.Width then
    begin
      FThumbRect := Bounds(R.Left + Indent, R.Top + Indent,
        FImages[siVThumb].Width div NumThumbStates, FImages[siVThumb].Height);
      FRulerOrg := Point(R.Left + Indent + (FImages[siVThumb].Width div NumThumbStates -
        FRuler.Width) div 2, R.Top + Indent);
      FPointsRect := Rect(R.Left + Indent + FImages[siVThumb].Width div NumThumbStates + 1,
        FRulerOrg.Y, R.Right - R.Left - 1, FRulerOrg.Y + FRuler.Height);
    end
    else
    begin
      FThumbRect := Bounds(R.Left + Indent + (FRuler.Width -
        FImages[siVThumb].Width div NumThumbStates) div 2, R.Top + Indent,
        FImages[siVThumb].Width div NumThumbStates, FImages[siVThumb].Height);
      FRulerOrg := Point(R.Left + Indent, R.Top + Indent);
      FPointsRect := Rect(R.Left + Indent + FRuler.Width + 1, FRulerOrg.Y,
        R.Right - R.Left - 1, FRulerOrg.Y + FRuler.Height);
    end;
  end;
  Value := SaveValue;
  Invalidate;
end;

procedure TRxCustomSlider.Sized;
begin
  AdjustElements;
end;

procedure TRxCustomSlider.Change;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TRxCustomSlider.Changed;
begin
  if Assigned(FOnChanged) then FOnChanged(Self);
end;

procedure TRxCustomSlider.RangeChanged;
begin
end;

procedure TRxCustomSlider.DefineProperties(Filer: TFiler);

{$IFNDEF VER80}

function DoWrite: Boolean;
  begin
    if Assigned(Filer.Ancestor) then
      Result := FUserImages <> TRxCustomSlider(Filer.Ancestor).FUserImages
    else
      Result := FUserImages <> [];
  end;
  {$ENDIF}

begin
  if Filer is TReader then inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('UserImages', ReadUserImages, WriteUserImages,
    {$IFNDEF VER80}DoWrite{$ELSE}FUserImages <> []{$ENDIF});
end;

procedure TRxCustomSlider.ReadUserImages(Stream: TStream);
begin
  Stream.ReadBuffer(FUserImages, SizeOf(FUserImages));
end;

procedure TRxCustomSlider.WriteUserImages(Stream: TStream);
begin
  Stream.WriteBuffer(FUserImages, SizeOf(FUserImages));
end;

function TRxCustomSlider.StoreImage(Index: Integer): Boolean;
begin
  Result := TSliderImage(Index) in FUserImages;
end;

function TRxCustomSlider.GetImage(Index: Integer): TBitmap;
begin
  Result := FImages[TSliderImage(Index)];
end;

procedure TRxCustomSlider.SliderImageChanged(Sender: TObject);
begin
  if not (csCreating in ControlState) then Sized;
end;

procedure TRxCustomSlider.SetImage(Index: Integer; Value: TBitmap);
var
  Idx: TSliderImage;
begin
  Idx := TSliderImage(Index);
  if FImages[Idx] = nil then
  begin
    FImages[Idx] := TBitmap.Create;
    FImages[Idx].OnChange := SliderImageChanged;
  end;
  if Value = nil then
  begin
    FImages[Idx].Handle := LoadBitmap(HInstance, ImagesResNames[Idx]);
    Exclude(FUserImages, Idx);
    if not (csReading in ComponentState) then
    begin
      if Idx in [siHThumb, siVThumb] then
        Exclude(FOptions, soThumbOpaque)
      else
        Exclude(FOptions, soRulerOpaque);
      Invalidate;
    end;
  end
  else
  begin
    FImages[Idx].Assign(Value);
    Include(FUserImages, Idx);
  end;
end;

procedure TRxCustomSlider.SetEdgeSize(Value: Integer);
var
  MaxSize: Integer;
begin
  if Orientation = soHorizontal then
    MaxSize := FImages[siHRuler].Width
  else
    MaxSize := FImages[siVRuler].Height;
  if Value * 2 < MaxSize then
    if Value <> FEdgeSize then
    begin
      FEdgeSize := Value;
      Sized;
    end;
end;

function TRxCustomSlider.GetNumThumbStates: TNumThumbStates;
begin
  Result := FNumThumbStates;
end;

procedure TRxCustomSlider.SetNumThumbStates(Value: TNumThumbStates);
begin
  if FNumThumbStates <> Value then
  begin
    FNumThumbStates := Value;
    AdjustElements;
  end;
end;

procedure TRxCustomSlider.SetBevelStyle(Value: TPanelBevel);
begin
  if Value <> FBevelStyle then
  begin
    FBevelStyle := Value;
    Sized;
    Update;
  end;
end;

procedure TRxCustomSlider.SetOrientation(Value: TSliderOrientation);
begin
  if Orientation <> Value then
  begin
    FOrientation := Value;
    Sized;
    if ComponentState * [csLoading{$IFNDEF VER80}, csUpdating{$ENDIF}] = [] then
      SetBounds(Left, Top, Height, Width);
  end;
end;

procedure TRxCustomSlider.SetOptions(Value: TSliderOptions);
begin
  if Value <> FOptions then
  begin
    FOptions := Value;
    Invalidate;
  end;
end;

procedure TRxCustomSlider.SetRange(Min, Max: LongInt);
begin
  if (Min < Max) or (csReading in ComponentState) then
  begin
    FMinValue := Min;
    FMaxValue := Max;
    if not (csReading in ComponentState) then
      if Min + Increment > Max then FIncrement := Max - Min;
    if (soShowPoints in Options) then Invalidate;
    Self.Value := FValue;
    RangeChanged;
  end;
end;

procedure TRxCustomSlider.SetMinValue(Value: LongInt);
begin
  if FMinValue <> Value then SetRange(Value, MaxValue);
end;

procedure TRxCustomSlider.SetMaxValue(Value: LongInt);
begin
  if FMaxValue <> Value then SetRange(MinValue, Value);
end;

procedure TRxCustomSlider.SetIncrement(Value: LongInt);
begin
  if not (csReading in ComponentState) and ((Value > MaxValue - MinValue) or
    (Value < 1)) then
    raise Exception.CreateFmt(ResStr(SOutOfRange), [1, MaxValue - MinValue]);
  if (Value > 0) and (FIncrement <> Value) then
  begin
    FIncrement := Value;
    Self.Value := FValue;
    Invalidate;
  end;
end;

function TRxCustomSlider.GetValueByOffset(Offset: Integer): LongInt;
var
  Range: Double;
  R: TRect;
begin
  R := SliderRect;
  if Orientation = soVertical then
    Offset := ClientHeight - Offset - FImages[siVThumb].Height;
  Range := MaxValue - MinValue;
  Result := Round((Offset - R.Left - Indent) * Range / GetRulerLength);
  if not (soSmooth in Options) then
    Result := Round(Result / Increment) * Increment;
  Result := Min(MinValue + Max(Result, 0), MaxValue);
end;

function TRxCustomSlider.GetOffsetByValue(Value: LongInt): Integer;
var
  Range: Double;
  R: TRect;
  MinIndent: Integer;
begin
  R := SliderRect;
  Range := MaxValue - MinValue;
  if Orientation = soHorizontal then
    MinIndent := R.Left + Indent
  else
    MinIndent := R.Top + Indent;
  Result := Round((Value - MinValue) / Range * GetRulerLength) + MinIndent;
  if Orientation = soVertical then
    Result := R.Top + R.Bottom - Result - FImages[siVThumb].Height;
  Result := Max(Result, MinIndent);
end;

function TRxCustomSlider.GetThumbPosition(var Offset: Integer): TPoint;
var
  R: TRect;
  MinIndent: Integer;
begin
  R := SliderRect;
  if Orientation = soHorizontal then
    MinIndent := R.Left + Indent
  else
    MinIndent := R.Top + Indent;
  Offset := Min(GetOffsetByValue(GetValueByOffset(Min(Max(Offset, MinIndent),
    MinIndent + GetRulerLength))), MinIndent + GetRulerLength);
  if Orientation = soHorizontal then
  begin
    Result.X := Offset;
    Result.Y := FThumbRect.Top;
  end
  else
  begin
    Result.Y := Offset;
    Result.X := FThumbRect.Left;
  end;
end;

function TRxCustomSlider.GetThumbOffset: Integer;
begin
  if Orientation = soHorizontal then
    Result := FThumbRect.Left
  else
    Result := FThumbRect.Top;
end;

procedure TRxCustomSlider.InvalidateThumb;
begin
  if HandleAllocated then
    InvalidateRect(Handle, @FThumbRect, not (csOpaque in ControlStyle));
end;

procedure TRxCustomSlider.SetThumbOffset(Value: Integer);
var
  ValueBefore: LongInt;
  P: TPoint;
begin
  ValueBefore := FValue;
  P := GetThumbPosition(Value);
  InvalidateThumb;
  FThumbRect := Bounds(P.X, P.Y, WidthOf(FThumbRect), HeightOf(FThumbRect));
  InvalidateThumb;
  if FSliding then
  begin
    FValue := GetValueByOffset(Value);
    if ValueBefore <> FValue then Change;
  end;
end;

function TRxCustomSlider.GetRulerLength: Integer;
begin
  if Orientation = soHorizontal then
  begin
    Result := FRuler.Width;
    Dec(Result, FImages[siHThumb].Width div NumThumbStates);
  end
  else
  begin
    Result := FRuler.Height;
    Dec(Result, FImages[siVThumb].Height);
  end;
end;

procedure TRxCustomSlider.SetValue(Value: LongInt);
var
  ValueChanged: Boolean;
begin
  if Value > MaxValue then Value := MaxValue;
  if Value < MinValue then Value := MinValue;
  ValueChanged := FValue <> Value;
  FValue := Value;
  ThumbOffset := GetOffsetByValue(Value);
  if ValueChanged then Change;
end;

procedure TRxCustomSlider.SetReadOnly(Value: Boolean);
begin
  if FReadOnly <> Value then
  begin
    if Value then
    begin
      StopTracking;
      if FSliding then ThumbMouseUp(mbLeft, [], 0, 0);
    end;
    FReadOnly := Value;
  end;
end;

procedure TRxCustomSlider.ThumbJump(Jump: TJumpMode);
var
  NewValue: LongInt;
begin
  if Jump <> jmNone then
  begin
    case Jump of
      jmHome: NewValue := MinValue;
      jmPrior:
        NewValue := (Round(Value / Increment) * Increment) - Increment;
      jmNext:
        NewValue := (Round(Value / Increment) * Increment) + Increment;
      jmEnd: NewValue := MaxValue;
    else
      Exit;
    end;
    if NewValue >= MaxValue then
      NewValue := MaxValue
    else if NewValue <= MinValue then
      NewValue := MinValue;
    if (NewValue <> Value) then Value := NewValue;
  end;
end;

function TRxCustomSlider.JumpTo(X, Y: Integer): TJumpMode;
begin
  Result := jmNone;
  if Orientation = soHorizontal then
  begin
    if FThumbRect.Left > X then
      Result := jmPrior
    else if FThumbRect.Right < X then
      Result := jmNext;
  end
  else if Orientation = soVertical then
  begin
    if FThumbRect.Top > Y then
      Result := jmNext
    else if FThumbRect.Bottom < Y then
      Result := jmPrior;
  end;
end;

procedure TRxCustomSlider.WMTimer(var Message: TMessage);
begin
  TimerTrack;
end;

procedure TRxCustomSlider.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  InvalidateThumb;
end;

procedure TRxCustomSlider.CMFocusChanged(var Message: TCMFocusChanged);
var
  Active: Boolean;
begin
  with Message do
    Active := (Sender = Self);
  if Active <> FFocused then
  begin
    FFocused := Active;
    if (soShowFocus in Options) then Invalidate;
  end;
  inherited;
end;

procedure TRxCustomSlider.WMGetDlgCode(var Msg: TWMGetDlgCode);
begin
  Msg.Result := DLGC_WANTARROWS;
end;

procedure TRxCustomSlider.WMSize(var Message: TWMSize);
begin
  inherited;
  if not (csReading in ComponentState) then Sized;
end;

procedure TRxCustomSlider.WMSetCursor(var Message: TWMSetCursor);
var
  P: TPoint;
begin
  GetCursorPos(P);
  if not (csDesigning in ComponentState) and PtInRect(FThumbRect,
    ScreenToClient(P)) then
  begin
    {$IFNDEF VER80}
    Windows.SetCursor(Screen.Cursors[crHand]);
    {$ELSE}
    WinProcs.SetCursor(Screen.Cursors[crHand]);
    {$ENDIF}
  end
  else
    inherited;
end;

procedure TRxCustomSlider.StopTracking;
begin
  if FTracking then
  begin
    if FTimerActive then
    begin
      KillTimer(Handle, 1);
      FTimerActive := False;
    end;
    FTracking := False;
    MouseCapture := False;
    Changed;
  end;
end;

procedure TRxCustomSlider.TimerTrack;
var
  Jump: TJumpMode;
begin
  Jump := JumpTo(FMousePos.X, FMousePos.Y);
  if Jump = FStartJump then
  begin
    ThumbJump(Jump);
    if not FTimerActive then
    begin
      SetTimer(Handle, 1, JumpInterval, nil);
      FTimerActive := True;
    end;
  end;
end;

procedure TRxCustomSlider.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  Rect: TRect;
  P: TPoint;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and not (ssDouble in Shift) then
  begin
    if CanFocus then SetFocus;
    P := Point(X, Y);
    if PointInRect(P, FThumbRect) then
      ThumbMouseDown(Button, Shift, X, Y)
    else
    begin
      with FRulerOrg, FRuler do
        Rect := Bounds(X, Y, Width, Height);
      InflateRect(Rect, Ord(Orientation = soVertical) * 3,
        Ord(Orientation = soHorizontal) * 3);
      if PointInRect(P, Rect) and CanModify and not ReadOnly then
      begin
        MouseCapture := True;
        FTracking := True;
        FMousePos := P;
        FStartJump := JumpTo(X, Y);
        TimerTrack;
      end;
    end;
  end;
end;

procedure TRxCustomSlider.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if (csLButtonDown in ControlState) and FSliding then
    ThumbMouseMove(Shift, X, Y)
  else if FTracking then
    FMousePos := Point(X, Y);
  inherited MouseMove(Shift, X, Y);
end;

procedure TRxCustomSlider.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  StopTracking;
  if FSliding then ThumbMouseUp(Button, Shift, X, Y);
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TRxCustomSlider.KeyDown(var Key: Word; Shift: TShiftState);
var
  Jump: TJumpMode;
begin
  Jump := jmNone;
  if Shift = [] then
  begin
    if Key = VK_HOME then
      Jump := jmHome
    else if Key = VK_END then
      Jump := jmEnd;
    if Orientation = soHorizontal then
    begin
      if Key = VK_LEFT then
        Jump := jmPrior
      else if Key = VK_RIGHT then
        Jump := jmNext;
    end
    else
    begin
      if Key = VK_UP then
        Jump := jmNext
      else if Key = VK_DOWN then
        Jump := jmPrior;
    end;
  end;
  if (Jump <> jmNone) and CanModify and not ReadOnly then
  begin
    Key := 0;
    ThumbJump(Jump);
    Changed;
  end;
  inherited KeyDown(Key, Shift);
end;

procedure TRxCustomSlider.ThumbMouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if CanFocus then SetFocus;
  if (Button = mbLeft) and CanModify and not ReadOnly then
  begin
    FSliding := True;
    FThumbDown := True;
    if Orientation = soHorizontal then
      FHit := X - FThumbRect.Left
    else
      FHit := Y - FThumbRect.Top;
    InvalidateThumb;
    Update;
  end;
end;

procedure TRxCustomSlider.ThumbMouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if (csLButtonDown in ControlState) and CanModify and not ReadOnly then
  begin
    if Orientation = soHorizontal then
      ThumbOffset := X - FHit
    else
      ThumbOffset := Y - FHit;
  end;
end;

procedure TRxCustomSlider.ThumbMouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) then
  begin
    FSliding := False;
    FThumbDown := False;
    InvalidateThumb;
    Update;
    if CanModify and not ReadOnly then Changed;
  end;
end;

{ TRxCustomTrackBar }

constructor TRxCustomTrackBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FImages := TRxSliderImages.Create;
  FImages.FSlider := Self;
end;

destructor TRxCustomTrackBar.Destroy;
begin
  FImages.Free;
  inherited Destroy;
end;

{ TRxSliderImages }

function TRxSliderImages.GetImage(Index: Integer): TBitmap;
begin
  Result := FSlider.GetImage(Index);
end;

procedure TRxSliderImages.SetImage(Index: Integer; Value: TBitmap);
begin
  FSlider.SetImage(Index, Value);
end;

function TRxSliderImages.StoreImage(Index: Integer): Boolean;
begin
  Result := FSlider.StoreImage(Index);
end;

function TRxSliderImages.GetNumThumbStates: TNumThumbStates;
begin
  Result := FSlider.NumThumbStates;
end;

procedure TRxSliderImages.SetNumThumbStates(Value: TNumThumbStates);
begin
  FSlider.NumThumbStates := Value;
end;

function TRxSliderImages.GetEdgeSize: Integer;
begin
  Result := FSlider.EdgeSize;
end;

procedure TRxSliderImages.SetEdgeSize(Value: Integer);
begin
  FSlider.EdgeSize := Value;
end;

end.