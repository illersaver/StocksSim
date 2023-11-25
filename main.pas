unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, TAGraph, TASeries, TAPolygonSeries;

type

  { TForm1 }

  TForm1 = class(TForm)
    LabelMoney: TLabel;
    LabelPriceAll: TLabel;
    LabelStocks: TLabel;
    LabelPrice: TLabel;
    ProceedButton: TButton;
    ButtonConfirm: TButton;
    Chart1: TChart;
    Chart1LineSeries1: TLineSeries;
    EditSell: TEdit;
    EditBuy: TEdit;
    EditTickrate: TEdit;
    EditZoom: TEdit;
    LabelSell: TLabel;
    LabelBuy: TLabel;
    LabelTickrate: TLabel;
    LabelZoom: TLabel;
    Timer1: TTimer;
    procedure ButtonConfirmClick(Sender: TObject);
    procedure EconomicsTick();
    procedure EditTickrateChange(Sender: TObject);
    procedure EditZoomChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ProceedButtonClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  x : integer;            // graph x coordinate
  zoom : integer;         // graph zoom (Amount of poits that will be shown)
  Money : integer;        // money
  Stocks : integer;       // stocks
  y : extended;           // graph y coordinate(Also stock price)

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Initialising values
  x := 0;
  y := 10;
  zoom := StrToInt(EditZoom.Text);
  Money := 100;
  Stocks := 0;
end;

// One tick of the economy
procedure TForm1.EconomicsTick();
          var Ifor : integer;
begin

  Randomize;
  // x and y coordinate calculation
  x := x + 1;

  y := y + (Random() - 0.5);

  if y < 1 then
    y := 1;

  Chart1LineSeries1.AddXY(x, y);

  // Calculating prices of stocks
  LabelPrice.Caption := 'Price: ' + IntToStr(Round(Chart1LineSeries1.GetYValue(Chart1LineSeries1.Count() - 1))) + '$';
  if EditBuy.Text <> '' then
     LabelPriceAll.Caption := 'Price(All): ' + IntToStr(Round((Chart1LineSeries1.GetYValue(Chart1LineSeries1.Count() - 1) * StrToInt(EditBuy.Text)))) + '$';

  // if we have more than 1 point, checking if the line is dropping or rising
  if (Chart1LineSeries1.Count() > 1) and
     (Chart1LineSeries1.GetYValue(Chart1LineSeries1.Count() - 1) > Chart1LineSeries1.GetYValue(Chart1LineSeries1.Count() - 2))
  then
      Chart1LineSeries1.SeriesColor := clLime
  else
      Chart1LineSeries1.SeriesColor := clRed;

  // Deleting far away lines
  if Chart1LineSeries1.Count() >= zoom then
      for Ifor := 1 to Chart1LineSeries1.Count() - zoom do
      begin
           Chart1LineSeries1.Delete(0);
      end;

end;

procedure TForm1.EditTickrateChange(Sender: TObject);
begin
   ButtonConfirm.Visible := true;
end;

procedure TForm1.EditZoomChange(Sender: TObject);
begin
   ButtonConfirm.Visible := true;
end;

procedure TForm1.ButtonConfirmClick(Sender: TObject);
begin
  // Limiting tick rate
  if (StrToInt(EditTickrate.Text) >= 100) and (StrToInt(EditTickrate.Text) <= 2500) then
     Begin
         Timer1.Interval := StrToInt(EditTickrate.Text);
         ButtonConfirm.Visible := false;
     end
  else
     ShowMessage('Tick rate out of bounds');

  // setting zoom
  zoom := StrToInt(EditZoom.Text);

end;

procedure TForm1.ProceedButtonClick(Sender: TObject);
begin
  // We can't sell or buy negative stocks
  if (StrToInt(EditSell.Text) <= 0) and
     (StrToInt(EditBuy.Text) <= 0)
  then
     Exit;

  // Buying stocks
  if (Money - (Chart1LineSeries1.GetYValue(Chart1LineSeries1.Count() - 1) * StrToInt(EditBuy.Text))) > 0 then
     begin
          Money := Money - (Round(Chart1LineSeries1.GetYValue(Chart1LineSeries1.Count() - 1) * StrToInt(EditBuy.Text)));
          Stocks := Stocks + StrToInt(EditBuy.Text);
     end;

  // Selling stocks
  if (Stocks * Chart1LineSeries1.GetYValue(Chart1LineSeries1.Count() - 1)) -(Chart1LineSeries1.GetYValue(Chart1LineSeries1.Count() - 1) * StrToInt(EditSell.Text)) >= 0 then
     begin
          Money := Money + Round((Chart1LineSeries1.GetYValue(Chart1LineSeries1.Count() - 1) * StrToInt(EditSell.Text)));
          Stocks := Stocks - StrToInt(EditSell.Text);
     end;

  LabelMoney.Caption := 'Money: ' + IntToStr(Money) + '$';
  LabelStocks.Caption := 'Stocks: ' + IntToStr(Stocks);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  EconomicsTick();
end;

end.

