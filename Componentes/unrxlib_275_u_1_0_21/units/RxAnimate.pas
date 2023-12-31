{*******************************************************}
{                                                       }
{         Delphi VCL Extensions (RX)                    }
{                                                       }
{         Copyright (c) 1995, 1996 AO ROSNO             }
{         Copyright (c) 1997, 1998 Master-Bank          }
{                                                       }
{*******************************************************}

unit RxAnimate;

interface

{$I RX.INC}

uses
  Messages, {$IFNDEF VER80}Windows, {$ELSE}WinTypes, WinProcs, {$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, StdCtrls, Menus, RxTimer;

type

{ TRxImageControl }

  {$IFDEF RX_D16}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
  {$ENDIF}
  TRxImageControl = class(TGraphicControl)
  private
    FDrawing: Boolean;
    FPaintBuffered: Boolean;
    {$IFDEF RX_D3}
    FLock: TRTLCriticalSection;
    {$ENDIF}
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
  protected
    FGraphic: TGraphic;
    function DoPaletteChange: Boolean;
    {$IFNDEF RX_D4}
    procedure AdjustSize; virtual; abstract;
    {$ENDIF}
    procedure DoPaintImage; virtual; abstract;
    procedure DoPaintControl;
    procedure PaintDesignRect;
    procedure PaintImage;
    procedure PictureChanged;
    procedure Lock;
    procedure Unlock;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

{ TAnimatedImage }

  TGlyphOrientation = (goHorizontal, goVertical);

  {$IFDEF RX_D16}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
  {$ENDIF}
  TAnimatedImage = class(TRxImageControl)
  private
    FActive: Boolean;
    FGlyph: TBitmap;
    FImageWidth: Integer;
    FImageHeight: Integer;
    FInactiveGlyph: Integer;
    FOrientation: TGlyphOrientation;
    FTimer: TRxTimer;
    FNumGlyphs: Integer;
    FGlyphNum: Integer;
    FCenter: Boolean;
    FStretch: Boolean;
    FTransparentColor: TColor;
    FOpaque: Boolean;
    FTimerRepaint: Boolean;
    FOnFrameChanged: TNotifyEvent;
    FOnStart: TNotifyEvent;
    FOnStop: TNotifyEvent;
    {$IFNDEF RX_D10}
    FOnMouseExit: TNotifyEvent;
    FOnMouseEnter: TNotifyEvent;
    {$ENDIF}
    {$IFDEF RX_D3}
    FAsyncDrawing: Boolean;
    {$ENDIF}
    {$IFNDEF RX_D4}
    FAutoSize: Boolean;
    procedure SetAutoSize(Value: Boolean);
    {$ENDIF}
    procedure DefineBitmapSize;
    procedure ResetImageBounds;
    function GetInterval: Cardinal;
    procedure SetInterval(Value: Cardinal);
    procedure SetActive(Value: Boolean);
    {$IFDEF RX_D3}
    procedure SetAsyncDrawing(Value: Boolean);
    {$ENDIF}
    procedure SetCenter(Value: Boolean);
    procedure SetOrientation(Value: TGlyphOrientation);
    procedure SetGlyph(Value: TBitmap);
    procedure SetGlyphNum(Value: Integer);
    procedure SetInactiveGlyph(Value: Integer);
    procedure SetNumGlyphs(Value: Integer);
    procedure SetStretch(Value: Boolean);
    procedure SetTransparentColor(Value: TColor);
    procedure SetOpaque(Value: Boolean);
    procedure ImageChanged(Sender: TObject);
    procedure UpdateInactive;
    procedure TimerExpired(Sender: TObject);
    function TransparentStored: Boolean;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    {$IFNDEF RX_D10}
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    {$ENDIF}
  protected
    {$IFDEF RX_D4}
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    {$ENDIF}
    function GetPalette: HPALETTE; override;
    procedure AdjustSize; override;
    procedure Loaded; override;
    procedure Paint; override;
    procedure DoPaintImage; override;
    procedure FrameChanged; dynamic;
    procedure Start; dynamic;
    procedure Stop; dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure PaintImageOn(Mycanvas: TCanvas; x, y: Integer); virtual;
  published
    property Align;
    {$IFDEF RX_D4}
    property Anchors;
    property Constraints;
    property DragKind;
    property AutoSize default True;
    {$ELSE}
    property AutoSize: Boolean read FAutoSize write SetAutoSize default True;
    {$ENDIF}
    {$IFDEF RX_D3}
    property AsyncDrawing: Boolean read FAsyncDrawing write SetAsyncDrawing default False;
    {$ENDIF}
    property Active: Boolean read FActive write SetActive default False;
    property Center: Boolean read FCenter write SetCenter default False;
    property Orientation: TGlyphOrientation read FOrientation write SetOrientation
      default goHorizontal;
    property Glyph: TBitmap read FGlyph write SetGlyph;
    property GlyphNum: Integer read FGlyphNum write SetGlyphNum default 0;
    property Interval: Cardinal read GetInterval write SetInterval default 100;
    property NumGlyphs: Integer read FNumGlyphs write SetNumGlyphs default 1;
    property InactiveGlyph: Integer read FInactiveGlyph write SetInactiveGlyph default -1;
    property TransparentColor: TColor read FTransparentColor write SetTransparentColor
      stored TransparentStored;
    property Opaque: Boolean read FOpaque write SetOpaque default False;
    property Color;
    property Cursor;
    property DragCursor;
    property DragMode;
    property ParentColor default True;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Stretch: Boolean read FStretch write SetStretch default True;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnMouseMove;
    property OnMouseDown;
    property OnMouseUp;
    property OnDragOver;
    property OnDragDrop;
    property OnEndDrag;
    {$IFNDEF VER80}
    property OnStartDrag;
    {$ENDIF}
    {$IFDEF RX_D4}
    property OnEndDock;
    property OnStartDock;
    {$ENDIF}
    {$IFDEF RX_D5}
    property OnContextPopup;
    {$ENDIF}
    property OnFrameChanged: TNotifyEvent read FOnFrameChanged write FOnFrameChanged;
    property OnStart: TNotifyEvent read FOnStart write FOnStart;
    property OnStop: TNotifyEvent read FOnStop write FOnStop;
    {$IFDEF RX_D9}
    property OnMouseActivate;
    {$ENDIF}
    {$IFNDEF RX_D10}
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseExit write FOnMouseExit;
    {$ELSE}
    property OnMouseEnter;
    property OnMouseLeave;
    {$ENDIF}
  end;

  {$IFDEF RX_D3}
procedure HookBitmap;
{$ENDIF}

implementation

uses RxConst, {$IFDEF RX_D3}RxHook, {$ENDIF}RxVCLUtils;

{$IFDEF RX_D3}

{ THackBitmap }

type
  THackBitmap = class(TBitmap)
  protected
    procedure Draw(ACanvas: TCanvas; const Rect: TRect); override;
  end;

procedure THackBitmap.Draw(ACanvas: TCanvas; const Rect: TRect);
begin
  if not Empty then Canvas.Lock;
  try
    inherited Draw(ACanvas, Rect);
  finally
    if not Empty then Canvas.Unlock;
  end;
end;

type
  THack = class(TBitmap);

var
  Hooked: Boolean = False;

procedure HookBitmap;
var
  Index: Integer;
begin
  if Hooked then Exit;
  Index := FindVirtualMethodIndex(THack, @THack.Draw);
  SetVirtualMethodAddress(TBitmap, Index, @THackBitmap.Draw);
  Hooked := True;
end;

{$ENDIF RX_D3}

{ TRxImageControl }

constructor TRxImageControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  {$IFDEF RX_D3}
  InitializeCriticalSection(FLock);
  {$ENDIF}
  ControlStyle := ControlStyle + [csClickEvents, csCaptureMouse, csOpaque,
    {$IFNDEF VER80}csReplicatable, {$ENDIF}csDoubleClicks];
  Height := 105;
  Width := 105;
  ParentColor := True;
end;

destructor TRxImageControl.Destroy;
begin
  {$IFDEF RX_D3}
  DeleteCriticalSection(FLock);
  {$ENDIF}
  inherited Destroy;
end;

procedure TRxImageControl.Lock;
begin
  {$IFDEF RX_D3}
  EnterCriticalSection(FLock);
  {$ENDIF}
end;

procedure TRxImageControl.Unlock;
begin
  {$IFDEF RX_D3}
  LeaveCriticalSection(FLock);
  {$ENDIF}
end;

procedure TRxImageControl.PaintImage;
var
  Save: Boolean;
begin
  with Canvas do
  begin
    Brush.Color := Color;
    FillRect(Bounds(0, 0, ClientWidth, ClientHeight));
  end;
  Save := FDrawing;
  FDrawing := True;
  try
    DoPaintImage;
  finally
    FDrawing := Save;
  end;
end;

procedure TRxImageControl.WMPaint(var Message: TWMPaint);
var
  DC, MemDC: HDC;
  MemBitmap, OldBitmap: HBITMAP;
begin
  if FPaintBuffered then
    inherited
  else if Message.DC <> 0 then
  begin
    {$IFDEF RX_D3}
    Canvas.Lock;
    try
    {$ENDIF}
      DC := Message.DC;
      MemDC := GetDC(0);
      MemBitmap := CreateCompatibleBitmap(MemDC, ClientWidth, ClientHeight);
      ReleaseDC(0, MemDC);
      MemDC := CreateCompatibleDC(0);
      OldBitmap := SelectObject(MemDC, MemBitmap);
      try
        FPaintBuffered := True;
        try
          Message.DC := MemDC;
          WMPaint(Message);
          Message.DC := 0;
        finally
          FPaintBuffered := False;
        end;
        BitBlt(DC, 0, 0, ClientWidth, ClientHeight, MemDC, 0, 0, SRCCOPY);
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

procedure TRxImageControl.PaintDesignRect;
begin
  if csDesigning in ComponentState then
    with Canvas do
    begin
      Pen.Style := psDash;
      Brush.Style := bsClear;
      Rectangle(0, 0, Width, Height);
    end;
end;

procedure TRxImageControl.DoPaintControl;
var
  DC: HDC;
begin
  {$IFDEF RX_D3}
  if GetCurrentThreadID = MainThreadID then
  begin
    Repaint;
    Exit;
  end;
  {$ENDIF}
  DC := GetDC(Parent.Handle);
  try
    IntersectClipRect(DC, Left, Top, Left + Width, Top + Height);
    MoveWindowOrg(DC, Left, Top);
    Perform(WM_PAINT, DC, 0);
  finally
    ReleaseDC(Parent.Handle, DC);
  end;
end;

function TRxImageControl.DoPaletteChange: Boolean;
var
  ParentForm: TCustomForm;
  Tmp: TGraphic;
begin
  Result := False;
  Tmp := FGraphic;
  if Visible and (not (csLoading in ComponentState)) and (Tmp <> nil)
    {$IFDEF RX_D3} and (Tmp.PaletteModified){$ENDIF} then
  begin
    if (GetPalette <> 0) then
    begin
      ParentForm := GetParentForm(Self);
      if Assigned(ParentForm) and ParentForm.Active and ParentForm.HandleAllocated then
      begin
        if FDrawing then
          ParentForm.Perform(WM_QUERYNEWPALETTE, 0, 0)
        else
          PostMessage(ParentForm.Handle, WM_QUERYNEWPALETTE, 0, 0);
        Result := True;
        {$IFDEF RX_D3}
        Tmp.PaletteModified := False;
        {$ENDIF}
      end;
    end
      {$IFDEF RX_D3}
    else
    begin
      Tmp.PaletteModified := False;
    end;
    {$ENDIF}
  end;
end;

procedure TRxImageControl.PictureChanged;
begin
  if not (csDestroying in ComponentState) then
  begin
    AdjustSize;
    if (FGraphic <> nil) then
      if DoPaletteChange and FDrawing then Update;
    if not FDrawing then Invalidate;
  end;
end;

{ TAnimatedImage }

constructor TAnimatedImage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTimer := TRxTimer.Create(Self);
  with FTimer do
  begin
    Enabled := False;
    Interval := 100;
  end;
  AutoSize := True;
  FGlyph := TBitmap.Create;
  FGraphic := FGlyph;
  FGlyph.OnChange := ImageChanged;
  FNumGlyphs := 1;
  FInactiveGlyph := -1;
  FTransparentColor := clNone;
  FOrientation := goHorizontal;
  FStretch := True;
end;

destructor TAnimatedImage.Destroy;
begin
  Destroying;
  FOnFrameChanged := nil;
  FOnStart := nil;
  FOnStop := nil;
  FGlyph.OnChange := nil;
  Active := False;
  FGlyph.Free;
  inherited Destroy;
end;

procedure TAnimatedImage.Loaded;
begin
  inherited Loaded;
  ResetImageBounds;
  UpdateInactive;
end;

function TAnimatedImage.GetPalette: HPALETTE;
begin
  Result := 0;
  if not FGlyph.Empty then Result := FGlyph.Palette;
end;

procedure TAnimatedImage.ImageChanged(Sender: TObject);
begin
  Lock;
  try
    FTransparentColor := FGlyph.TransparentColor and not PaletteMask;
  finally
    Unlock;
  end;
  DefineBitmapSize;
  PictureChanged;
end;

procedure TAnimatedImage.UpdateInactive;
begin
  if (not Active) and (FInactiveGlyph >= 0) and (FInactiveGlyph < FNumGlyphs)
    and (FGlyphNum <> FInactiveGlyph) then
  begin
    Lock;
    try
      FGlyphNum := FInactiveGlyph;
    finally
      Unlock;
    end;
  end;
end;

function TAnimatedImage.TransparentStored: Boolean;
begin
  Result := (FGlyph.Empty and (FTransparentColor <> clNone)) or
    ((FGlyph.TransparentColor and not PaletteMask) <>
    FTransparentColor);
end;

procedure TAnimatedImage.SetOpaque(Value: Boolean);
begin
  if Value <> FOpaque then
  begin
    Lock;
    try
      FOpaque := Value;
    finally
      Unlock;
    end;
    PictureChanged;
  end;
end;

procedure TAnimatedImage.SetTransparentColor(Value: TColor);
begin
  if Value <> TransparentColor then
  begin
    Lock;
    try
      FTransparentColor := Value;
    finally
      Unlock;
    end;
    PictureChanged;
  end;
end;

procedure TAnimatedImage.SetOrientation(Value: TGlyphOrientation);
begin
  if FOrientation <> Value then
  begin
    Lock;
    try
      FOrientation := Value;
    finally
      Unlock;
    end;
    ImageChanged(FGlyph);
  end;
end;

procedure TAnimatedImage.SetGlyph(Value: TBitmap);
begin
  Lock;
  try
    FGlyph.Assign(Value);
  finally
    Unlock;
  end;
end;

procedure TAnimatedImage.SetStretch(Value: Boolean);
begin
  if Value <> FStretch then
  begin
    Lock;
    try
      FStretch := Value;
    finally
      Unlock;
    end;
    PictureChanged;
    if Active then Repaint;
  end;
end;

procedure TAnimatedImage.SetCenter(Value: Boolean);
begin
  if Value <> FCenter then
  begin
    Lock;
    try
      FCenter := Value;
    finally
      Unlock;
    end;
    PictureChanged;
    if Active then Repaint;
  end;
end;

procedure TAnimatedImage.SetGlyphNum(Value: Integer);
begin
  if Value <> FGlyphNum then
  begin
    if (Value < FNumGlyphs) and (Value >= 0) then
    begin
      Lock;
      try
        FGlyphNum := Value;
      finally
        Unlock;
      end;
      UpdateInactive;
      FrameChanged;
      PictureChanged;
    end;
  end;
end;

procedure TAnimatedImage.SetInactiveGlyph(Value: Integer);
begin
  if Value < 0 then Value := -1;
  if Value <> FInactiveGlyph then
  begin
    if (Value < FNumGlyphs) or (csLoading in ComponentState) then
    begin
      Lock;
      try
        FInactiveGlyph := Value;
        UpdateInactive;
      finally
        Unlock;
      end;
      FrameChanged;
      PictureChanged;
    end;
  end;
end;

procedure TAnimatedImage.SetNumGlyphs(Value: Integer);
begin
  Lock;
  try
    FNumGlyphs := Value;
    if FInactiveGlyph >= FNumGlyphs then
    begin
      FInactiveGlyph := -1;
      FGlyphNum := 0;
    end
    else
      UpdateInactive;
    ResetImageBounds;
  finally
    Unlock;
  end;
  FrameChanged;
  PictureChanged;
end;

procedure TAnimatedImage.DefineBitmapSize;
begin
  Lock;
  try
    FNumGlyphs := 1;
    FGlyphNum := 0;
    FImageWidth := 0;
    FImageHeight := 0;
    if (FOrientation = goHorizontal) and (FGlyph.Height > 0) and
      (FGlyph.Width mod FGlyph.Height = 0) then
      FNumGlyphs := FGlyph.Width div FGlyph.Height
    else if (FOrientation = goVertical) and (FGlyph.Width > 0) and
      (FGlyph.Height mod FGlyph.Width = 0) then
      FNumGlyphs := FGlyph.Height div FGlyph.Width;
    ResetImageBounds;
  finally
    Unlock;
  end;
end;

procedure TAnimatedImage.ResetImageBounds;
begin
  if FNumGlyphs < 1 then FNumGlyphs := 1;
  if FOrientation = goHorizontal then
  begin
    FImageHeight := FGlyph.Height;
    FImageWidth := FGlyph.Width div FNumGlyphs;
  end
  else {if Orientation = goVertical then}
  begin
    FImageWidth := FGlyph.Width;
    FImageHeight := FGlyph.Height div FNumGlyphs;
  end;
end;

procedure TAnimatedImage.AdjustSize;
begin
  if not (csReading in ComponentState) then
  begin
    if AutoSize and (FImageWidth > 0) and (FImageHeight > 0) then
      SetBounds(Left, Top, FImageWidth, FImageHeight);
  end;
end;

type
  TParentControl = class(TWinControl);

procedure TAnimatedImage.PaintImageOn(Mycanvas: TCanvas; x, y: Integer);
var
  BmpIndex: Integer;
  SrcRect: TRect;
begin
  if (not Active) and (FInactiveGlyph >= 0) and (FInactiveGlyph < FNumGlyphs) then
    BmpIndex := FInactiveGlyph
  else
    BmpIndex := FGlyphNum;
  { copy image from parent and back-level controls }

  if (FImageWidth > 0) and (FImageHeight > 0) then
  begin
    if Orientation = goHorizontal then
      SrcRect := Bounds(BmpIndex * FImageWidth, 0, FImageWidth, FImageHeight)
    else {if Orientation = goVertical then}
      SrcRect := Bounds(0, BmpIndex * FImageHeight, FImageWidth, FImageHeight);
    if FStretch then
      StretchBitmapRectTransparent(MyCanvas, x, y, Width, Height, SrcRect, FGlyph, FTransparentColor)
    else
      DrawBitmapRectTransparent(MyCanvas, x, y, SrcRect, FGlyph, FTransparentColor);
  end;
end;

procedure TAnimatedImage.DoPaintImage;
var
  BmpIndex: Integer;
  SrcRect, DstRect: TRect;
  {Origin: TPoint;}
begin
  if (not Active) and (FInactiveGlyph >= 0) and (FInactiveGlyph < FNumGlyphs) then
    BmpIndex := FInactiveGlyph
  else
    BmpIndex := FGlyphNum;
  { copy image from parent and back-level controls }
  if not FOpaque then CopyParentImage(Self, Canvas);
  if (FImageWidth > 0) and (FImageHeight > 0) then
  begin
    if Orientation = goHorizontal then
      SrcRect := Bounds(BmpIndex * FImageWidth, 0, FImageWidth, FImageHeight)
    else {if Orientation = goVertical then}
      SrcRect := Bounds(0, BmpIndex * FImageHeight, FImageWidth, FImageHeight);
    if Stretch then
      DstRect := ClientRect
    else if Center then
      DstRect := Bounds((ClientWidth - FImageWidth) div 2,
        (ClientHeight - FImageHeight) div 2, FImageWidth, FImageHeight)
    else
      DstRect := Rect(0, 0, FImageWidth, FImageHeight);
    with DstRect do
      StretchBitmapRectTransparent(Canvas, Left, Top, Right - Left,
        Bottom - Top, SrcRect, FGlyph, FTransparentColor);
  end;
end;

procedure TAnimatedImage.Paint;
begin
  PaintImage;
  if (not Opaque) or FGlyph.Empty then
    PaintDesignRect;
end;

procedure TAnimatedImage.TimerExpired(Sender: TObject);
begin
  {$IFDEF RX_D3}
  if csPaintCopy in ControlState then Exit;
  {$ENDIF}
  if Visible and (FNumGlyphs > 1) and (Parent <> nil) and
    Parent.HandleAllocated then
  begin
    Lock;
    try
      if FGlyphNum < FNumGlyphs - 1 then
        Inc(FGlyphNum)
      else
        FGlyphNum := 0;
      if (FGlyphNum = FInactiveGlyph) and (FNumGlyphs > 1) then
      begin
        if FGlyphNum < FNumGlyphs - 1 then
          Inc(FGlyphNum)
        else
          FGlyphNum := 0;
      end;
      {$IFDEF RX_D3}
      Canvas.Lock;
      try
        FTimerRepaint := True;
        if AsyncDrawing and Assigned(FOnFrameChanged) then
          FTimer.Synchronize(FrameChanged)
        else
          FrameChanged;
        DoPaintControl;
      finally
        FTimerRepaint := False;
        Canvas.Unlock;
      end;
      {$ELSE}
      FTimerRepaint := True;
      try
        FrameChanged;
        Repaint;
      finally
        FTimerRepaint := False;
      end;
      {$ENDIF}
    finally
      Unlock;
    end;
  end;
end;

procedure TAnimatedImage.FrameChanged;
begin
  if Assigned(FOnFrameChanged) then FOnFrameChanged(Self);
end;

procedure TAnimatedImage.Stop;
begin
  if not (csReading in ComponentState) then
    if Assigned(FOnStop) then FOnStop(Self);
end;

procedure TAnimatedImage.Start;
begin
  if not (csReading in ComponentState) then
    if Assigned(FOnStart) then FOnStart(Self);
end;

{$IFNDEF RX_D4}
procedure TAnimatedImage.SetAutoSize(Value: Boolean);
begin
  if Value <> FAutoSize then
  begin
    FAutoSize := Value;
    PictureChanged;
  end;
end;
{$ENDIF}

{$IFDEF RX_D4}
function TAnimatedImage.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
begin
  Result := True;
  if not (csDesigning in ComponentState) and (FImageWidth > 0) and
    (FImageHeight > 0) then
  begin
    if Align in [alNone, alLeft, alRight] then
      NewWidth := FImageWidth;
    if Align in [alNone, alTop, alBottom] then
      NewHeight := FImageHeight;
  end;
end;
{$ENDIF}

procedure TAnimatedImage.SetInterval(Value: Cardinal);
begin
  FTimer.Interval := Value;
end;

function TAnimatedImage.GetInterval: Cardinal;
begin
  Result := FTimer.Interval;
end;

procedure TAnimatedImage.SetActive(Value: Boolean);
begin
  if FActive <> Value then
  begin
    if Value then
    begin
      FTimer.OnTimer := TimerExpired;
      FTimer.Enabled := True;
      FActive := FTimer.Enabled;
      Start;
    end
    else
    begin
      FTimer.Enabled := False;
      FTimer.OnTimer := nil;
      FActive := False;
      UpdateInactive;
      FrameChanged;
      Stop;
      PictureChanged;
    end;
  end;
end;

{$IFDEF RX_D3}
procedure TAnimatedImage.SetAsyncDrawing(Value: Boolean);
begin
  if FAsyncDrawing <> Value then
  begin
    Lock;
    try
      if Value then HookBitmap;
      if Assigned(FTimer) then FTimer.SyncEvent := not Value;
      FAsyncDrawing := Value;
    finally
      Unlock;
    end;
  end;
end;
{$ENDIF}

procedure TAnimatedImage.WMSize(var Message: TWMSize);
begin
  inherited;
  {$IFNDEF RX_D4}
  AdjustSize;
  {$ENDIF}
end;

{$IFNDEF RX_D10}
procedure TAnimatedImage.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if Assigned(FOnMouseEnter) then FOnMouseEnter(Self);
end;

procedure TAnimatedImage.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if Assigned(FOnMouseExit) then FOnMouseExit(Self);
end;
{$ENDIF}

end.
