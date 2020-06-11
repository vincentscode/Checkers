unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ActnList;

type

  { TCheckersForm }

  TCheckersForm = class(TForm)
    RestartAction: TAction;
    GameActions: TActionList;

    procedure RestartActionExecute(Sender: TObject);
    procedure boardPaintBoxPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ChangeBounds(ALeft, ATop, AWidth, AHeight: Integer; AKeepBase: Boolean); override;

    procedure CreateTokens();    
    procedure ValidateMove();

    procedure TokenOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure TokenOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure TokenOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private

  public

  end;

var
  CheckersForm: TCheckersForm;
  RectSize: Integer;
  MouseDownPos, MouseLastPos :TPoint;
  DraggingEnabled: Boolean;

const
  BoardSize = 8;

implementation

{$R *.lfm}

{ TCheckersForm }

procedure TCheckersForm.CreateTokens();
var
  x: Integer;
  y: Integer;
  clSwitch: Boolean;
  tokenShape: TShape;
begin
  // Generate black Tokens
  clSwitch := true;
  for x:= 0 to BoardSize-1 do begin
    for y := 0 to 2 do begin
      clSwitch := not clSwitch;
      if clSwitch then begin
        tokenShape := TShape.Create(CheckersForm);
        tokenShape.Parent := CheckersForm;
        tokenShape.Width := RectSize - 10;
        tokenShape.Height := RectSize - 10;
        tokenShape.Left := RectSize * x + 5;
        tokenShape.Top := RectSize * y + 5;
        tokenShape.Brush.Color := clBlack;
        tokenShape.Pen.Color := clWhite;
        tokenShape.Shape := stCircle;

        tokenShape.OnMouseDown := @TokenOnMouseDown;
        tokenShape.OnMouseMove := @TokenOnMouseMove;
        tokenShape.OnMouseUp := @TokenOnMouseUp;
      end;
    end;
  end;

  // Generate white Tokens
  clSwitch := false;
  for x:= 0 to BoardSize-1 do begin
    for y := 5 to 7 do begin
      clSwitch := not clSwitch;
      if clSwitch then begin
        tokenShape := TShape.Create(CheckersForm);
        tokenShape.Parent := CheckersForm;
        tokenShape.Width := RectSize - 10;
        tokenShape.Height := RectSize - 10;
        tokenShape.Left := RectSize * x + 5;
        tokenShape.Top := RectSize * y + 5;
        tokenShape.Brush.Color := clWhite;
        tokenShape.Pen.Color := clBlack;
        tokenShape.Shape := stCircle;

        tokenShape.OnMouseDown := @TokenOnMouseDown;
        tokenShape.OnMouseMove := @TokenOnMouseMove;
        tokenShape.OnMouseUp := @TokenOnMouseUp;
      end;
    end;
  end;
end;

procedure TCheckersForm.FormCreate(Sender: TObject);
begin
  // Get the initial Rect Size
  RectSize := round(CheckersForm.Width / BoardSize);

  // Prevent Form Flickering
  CheckersForm.DoubleBuffered := true;

  // Create Tokens
  CreateTokens();
end;

procedure TCheckersForm.TokenOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
    // Check if its the Players Turn
    // TODO

    // Save Mouse Location
    MouseDownPos.X := X;
    MouseDownPos.Y := Y;

    // Enable Dragging
    DraggingEnabled := True;

    // Show Options
  end else if Button = mbRight then begin
    // Delete (DEBUG)
    RemoveControl(TControl(Sender));
  end else if Button = mbMiddle then begin
    // Checker (DEBUG)
    if TShape(Sender).Pen.Color = clRed then begin
      if TShape(Sender).Brush.Color = clBlack then begin
        TShape(Sender).Pen.Color:= clWhite;
        TShape(Sender).Pen.Width:= 1;
      end else begin
        TShape(Sender).Pen.Color:= clBlack;
        TShape(Sender).Pen.Width:= 1;
      end;
    end else begin
      TShape(Sender).Pen.Color:= clRed;
      TShape(Sender).Pen.Width:= 4;
    end;
  end;
end;

procedure TCheckersForm.TokenOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  newLeft: Integer;
  newTop: Integer;
  fieldX: Integer;
  fieldY: Integer;
begin
  if DraggingEnabled then begin
    // Move
    newLeft := TShape(Sender).Left + (X - MouseDownPos.X);
    newTop := TShape(Sender).Top + (Y - MouseDownPos.Y);

    // Snap
    fieldX := round(newLeft / RectSize);
    fieldY := round(newTop / RectSize);

    newLeft := fieldX * RectSize + 5;
    newTop := fieldY * RectSize + 5;
    // WriteLn(newLeft, ' | ', newTop, ' -> ', fieldX, ' | ', fieldY, '(', RectSize, ')');

    // Validate
    ValidateMove();

    // Apply
    TShape(Sender).Left := newLeft;
    TShape(Sender).Top := newTop;

    // Remove Tokens
    // TODO
  end;
end;

procedure TCheckersForm.TokenOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  // Disable Dragging
  DraggingEnabled := False;

  // Hide Options
end;

procedure TCheckersForm.ValidateMove();
begin
  // TODO
end;

procedure TCheckersForm.ChangeBounds(ALeft, ATop, AWidth, AHeight: Integer; AKeepBase: Boolean);
begin
  RectSize := round(CheckersForm.Width / BoardSize);
  // TODO: Resize & Reposition Tokens
  if AWidth > AHeight then
     AHeight := AWidth
  else
    AWidth := AHeight;
  inherited ChangeBounds(ALeft, ATop, AWidth, AHeight, AKeepBase);
end;

procedure TCheckersForm.RestartActionExecute(Sender: TObject);
var
  i: Integer;
begin
   for i := (ControlCount - 1) downto 0 do begin
     RemoveControl(Controls[i]);
   end;
   CreateTokens();
end;

procedure TCheckersForm.boardPaintBoxPaint(Sender: TObject);
var
  x: Integer;
  y: Integer;
  clSwitch: Boolean;
begin
  // Generate the Board
  Canvas.Pen.Width := 0;
  clSwitch := true;
  for x:= 0 to BoardSize-1 do begin
      clSwitch := not clSwitch;
      for y := 0 to BoardSize-1 do begin
        clSwitch := not clSwitch;
        if clSwitch then
          Canvas.Brush.Color := clWhite
        else
          Canvas.Brush.Color := clBlack;

        Canvas.Rectangle(x * RectSize, y * RectSize, x * RectSize + RectSize, y * RectSize + RectSize);
    end;
  end;
end;

end.

