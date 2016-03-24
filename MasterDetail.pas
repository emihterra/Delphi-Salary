unit MasterDetail;

interface

uses
  WinApi.Windows, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListView.Types, Data.Bind.GenData,
  Fmx.Bind.GenData, System.Rtti, System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt,
  Data.Bind.Components, Data.Bind.ObjectScope, FMX.Objects, FMX.StdCtrls, FMX.ListView, FMX.ListView.Appearances,
  FMX.Layouts, FMX.MultiView,FMX.Memo, Fmx.Bind.Navigator, System.Actions, FMX.ActnList,
  FMX.ListView.Adapters.Base, FMX.ScrollBox, FMX.Controls.Presentation,
  FMX.ListBox, FMX.TabControl, FMX.Edit, FMX.SearchBox, Xml.XMLDoc, Xml.XmlIntf,
  Data.Bind.DBScope, Data.DB, System.Math.Vectors, System.StrUtils,
  DMSQLite, FMX.Grid;

type
  TSignPoint = record
    X1, Y1: Single;
    X2, Y2: Single;
  end;

type
  TMasterDetailForm = class(TForm)
    MVEmployees: TMultiView;
    Layout1: TLayout;
    lstEmployees: TListView;
    MasterToolbar: TToolBar;
    MasterLabel: TLabel;
    MasterButton: TSpeedButton;
    lblName: TLabel;
    lblSigned: TLabel;
    BindingsList1: TBindingsList;
    Layout2: TLayout;
    Layout3: TLayout;
    ActionList1: TActionList;
    LiveBindingsBindNavigateNext1: TFMXBindNavigateNext;
    LiveBindingsBindNavigatePrior1: TFMXBindNavigatePrior;
    StyleBook1: TStyleBook;
    MVOptions: TMultiView;
    lstOptions: TListBox;
    ToolBar2: TToolBar;
    Label1: TLabel;
    TabControl1: TTabControl;
    tabEmployees: TTabItem;
    actionSelectEmployeesManager: TChangeTabAction;
    actionSelectEmployees: TChangeTabAction;
    tabEmployeesManager: TTabItem;
    liHeaderEmployees: TListBoxGroupHeader;
    liAllEmployees: TListBoxItem;
    liNotSigned: TListBoxItem;
    liSigned: TListBoxItem;
    liHeaderOptions: TListBoxGroupHeader;
    liEmployeesManager: TListBoxItem;
    Layout4: TLayout;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    btnLoadEmployees: TButton;
    Layout5: TLayout;
    Layout6: TLayout;
    Layout7: TLayout;
    Label2: TLabel;
    cboPeriods: TComboBox;
    Layout8: TLayout;
    Label3: TLabel;
    cboDepartments: TComboBox;
    OpenDialog1: TOpenDialog;
    LinkListControlToField1: TLinkListControlToField;
    DataSource1: TDataSource;
    BindSourceDB1: TBindSourceDB;
    LinkPropertyToField1: TLinkPropertyToField;
    grIncome: TStringGrid;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    StringColumn3: TStringColumn;
    SignPicture: TPaintBox;
    tabSignPicture: TTabItem;
    Layout9: TLayout;
    Button1: TButton;
    actionSelectSignPicture: TChangeTabAction;
    Layout10: TLayout;
    btnSaveSign: TButton;
    actionPreviousTab: TPreviousTabAction;
    actionSaveSign: TAction;
    actionShowSignPicture: TAction;
    SaveDialog1: TSaveDialog;
    actionExportSign: TAction;
    btnBack: TButton;
    Layout11: TLayout;
    Layout12: TLayout;
    Layout13: TLayout;
    Layout14: TLayout;
    btnDeleteList: TButton;
    actionDeleteList: TAction;
    procedure lstEmployeesItemClick(const Sender: TObject; const AItem: TListViewItem);
    procedure lstOptionsItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure FormCreate(Sender: TObject);
    procedure liAllEmployeesClick(Sender: TObject);
    procedure liEmployeesManagerClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnLoadEmployeesClick(Sender: TObject);
    procedure cboPeriodsChange(Sender: TObject);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure grIncomeDrawColumnCell(Sender: TObject; const Canvas: TCanvas;
      const Column: TColumn; const Bounds: TRectF; const Row: Integer;
      const Value: TValue; const State: TGridDrawStates);
    procedure grIncomeDrawColumnHeader(Sender: TObject; const Canvas: TCanvas;
      const Column: TColumn; const Bounds: TRectF);
    procedure SignPicturePaint(Sender: TObject; Canvas: TCanvas);
    procedure actionSaveSignExecute(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
    procedure SignPictureMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure SignPictureMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure SignPictureMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure actionShowSignPictureExecute(Sender: TObject);
    procedure actionExportSignExecute(Sender: TObject);
    procedure actionDeleteListExecute(Sender: TObject);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
  private
    { Private declarations }
    FDrawingNow: Boolean;
    FStartX, FStartY: Single;
    FEmployeesSignedFilter: TEmployeesSignedFilter;
    FSignArray: array of TSignPoint;
    procedure UncheckAllEmployeeListItems;
    procedure LoadFromXML(AFileName: String);
    procedure UpdateLists;
    procedure UpdateEmployeesList;
    procedure UpdateTitle;
    procedure UpdateEmployeeInfo;
    function GetBackColor(ARow: Integer): TAlphaColor;
    procedure DrawSignPicture(const Canvas: TCanvas);
    procedure LoadSignPictureFromStream(const Canvas: TCanvas);
    procedure SaveSignPicture;
    procedure ExportSignPicture;
    procedure DrawSign(const Canvas: TCanvas);
  public
    { Public declarations }
  end;

var
  MasterDetailForm: TMasterDetailForm;

implementation

{$R *.fmx}

procedure TMasterDetailForm.UpdateLists;
begin
  DM.GetDepartments(cboDepartments.Items);
  DM.GetPeriods(cboPeriods.Items);

  cboDepartments.Items.Insert(0, 'Все');
  cboDepartments.ItemIndex := 0;

  if cboPeriods.Items.Count > 0 then
  begin
     cboPeriods.ItemIndex := 0;
  end;
end;

procedure TMasterDetailForm.actionDeleteListExecute(Sender: TObject);
begin
  if cboPeriods.ItemIndex <> -1 then
  begin
    if MessageDlg(
         Format('Удалить список сотрудников за период "%s" ?', [cboPeriods.Items[cboPeriods.ItemIndex]]),
         TMsgDlgType.mtConfirmation,
         mbOKCancel, 0) = mrOK then
    begin
      DM.DeletePeriod(cboPeriods.Items[cboPeriods.ItemIndex]);
      DM.GetPeriods(cboPeriods.Items);
      if cboPeriods.Items.Count > 0 then
      begin
         cboPeriods.ItemIndex := 0;
      end;
    end;
  end;
end;

procedure TMasterDetailForm.actionExportSignExecute(Sender: TObject);
begin
  ExportSignPicture;
end;

procedure TMasterDetailForm.ActionList1Update(Action: TBasicAction;
  var Handled: Boolean);
begin
  actionDeleteList.Enabled := cboPeriods.ItemIndex <> -1;
end;

procedure TMasterDetailForm.actionSaveSignExecute(Sender: TObject);
begin
  SaveSignPicture;
  UpdateEmployeesList;
  actionSelectEmployees.ExecuteTarget(Sender);
end;

procedure TMasterDetailForm.actionShowSignPictureExecute(Sender: TObject);
begin
  SetLength(FSignArray, 0);
  actionSelectSignPicture.ExecuteTarget(Sender);
end;

procedure TMasterDetailForm.btnLoadEmployeesClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    LoadFromXML(OpenDialog1.FileName);
    UpdateLists;
  end;
end;

procedure TMasterDetailForm.UpdateEmployeesList;
var
  DepStr: String;
begin
  DepStr := '';

  if cboDepartments.ItemIndex > 0 then
  begin
    DepStr := cboDepartments.Items[cboDepartments.ItemIndex];
  end;

  if cboPeriods.ItemIndex > -1 then
  begin
    DM.OpenEmployeesQuery(cboPeriods.Items[cboPeriods.ItemIndex], FEmployeesSignedFilter, DepStr);
  end;

  UpdateTitle;
end;

procedure TMasterDetailForm.UpdateTitle;
var
  DepStr: String;
begin
  if cboPeriods.ItemIndex = -1 then
  begin
    Exit;
  end;

  MasterLabel.Text := '';

  case FEmployeesSignedFilter of
    empAll: MasterLabel.Text := 'Все сотрудники';
    empUnsigned: MasterLabel.Text := 'Сотрудники, не получившие зарплату';
    empSigned: MasterLabel.Text := 'Сотрудники, получившие зарплату';
  end;

  DepStr := '';

  if cboDepartments.ItemIndex > 0 then
  begin
    DepStr := cboDepartments.Items[cboDepartments.ItemIndex];
  end;

  MasterLabel.Text := MasterLabel.Text + Format(' за %s', [cboPeriods.Items[cboPeriods.ItemIndex]]);

  if DepStr <> '' then
  begin
    MasterLabel.Text := MasterLabel.Text + Format(', подразделение "%s"', [DepStr]);
  end;
end;

procedure TMasterDetailForm.cboPeriodsChange(Sender: TObject);
begin
  UpdateTitle;
end;

procedure DrawCellEx(
  ABackColor: TAlphaColor; AFontColor: TAlphaColor; AText: String;
  const Canvas: TCanvas; const Bounds: TRectF; AFontSize: Integer = 14);
begin
  Canvas.Fill.Color := ABackColor;
  Canvas.FillRect(Bounds, 0, 0, [], 1);
  Canvas.Font.Size := AFontSize;
  Canvas.Fill.Color := AFontColor;
  Canvas.FillText(Bounds, AText, False, 1, [] , TTextAlign.Leading);
end;

const
  ctTitle = '0';
  ctIncomesTitle = '51';
  ctIncome = '1';
  ctIncomeSum = '2';
  ctWithheldTitle = '53';
  ctWithheld = '3';
  ctWithheldSum = '4';
  ctMonthBegin = '5';
  ctPayAll = '6';
  ctPaymentsTitle = '57';
  ctPayment = '7';
  ctPaymentSum = '8';
  ctSalaryHand = '9';

  ctSignPictureWidth = 800;
  ctSignPictureHeight = 1200;
  ctLeftpos = 10;
  ctSignPictureRowHeight = 18;

function TMasterDetailForm.GetBackColor(ARow: Integer): TAlphaColor;
begin
  if (grIncome.Cells[2, ARow] = ctIncomesTitle) or
     (grIncome.Cells[2, ARow] = ctWithheldTitle) or
     (grIncome.Cells[2, ARow] = ctPaymentsTitle) then
  begin
    Result := $FF71B2EF;
  end
  else
  if (grIncome.Cells[2, ARow] = ctPayAll) or
     (grIncome.Cells[2, ARow] = ctPaymentSum) then
  begin
    Result := $FF8EC694;
  end
  else
  if (grIncome.Cells[2, ARow] = ctIncomeSum) or
     (grIncome.Cells[2, ARow] = ctWithheldSum) then
  begin
    Result := $FFCEC9E6;
  end
  else
  if (grIncome.Cells[2, ARow] = ctSalaryHand) then
  begin
    Result := $FFFBEB5C;
  end
  else
  if (grIncome.Cells[2, ARow] = ctTitle) then
  begin
    Result := $FFB9B9B9;
  end
  else
  begin
    Result := TAlphaColorRec.White;
  end;
end;

procedure TMasterDetailForm.SignPictureMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  FDrawingNow := not DM.QueryEmployees.FieldByName('signed').AsBoolean;
  FStartX := X;
  FStartY := Y;
end;

procedure TMasterDetailForm.SignPictureMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
var
  Point1, Point2: TPointF;
  Stroke: TStrokeBrush;
  aLen: Integer;
begin
  if not FDrawingNow then
  begin
    Exit;
  end;

  SignPicture.Canvas.BeginScene;
  try
    Stroke := TStrokeBrush.Create(TBrushKind.Solid, TAlphaColorRec.Black);

    SignPicture.Canvas.DrawLine(
      Point1.Create(FStartX, FStartY + TabControl1.Position.Y + 5),
      Point2.Create(X, Y + TabControl1.Position.Y + 5),
      1, Stroke);

    aLen := Length(FSignArray);
    SetLength(FSignArray, aLen + 1);
    FSignArray[aLen].X1 := FStartX;
    FSignArray[aLen].Y1 := FStartY;
    FSignArray[aLen].X2 := X;
    FSignArray[aLen].Y2 := Y;

  finally
    Stroke.Free;
    SignPicture.Canvas.EndScene;
  end;

  FStartX := X;
  FStartY := Y;
end;

procedure TMasterDetailForm.DrawSign(const Canvas: TCanvas);
var
  I: Integer;
  Point1, Point2: TPointF;
  Stroke: TStrokeBrush;
begin
  Stroke := TStrokeBrush.Create(TBrushKind.Solid, TAlphaColorRec.Black);
  Canvas.BeginScene;
  try
    for I := Low(FSignArray) to High(FSignArray) do
    begin
      Canvas.DrawLine(
        Point1.Create(FSignArray[I].X1, FSignArray[I].Y1),
        Point2.Create(FSignArray[I].X2, FSignArray[I].Y2),
        1, Stroke);
    end;
  finally
    Canvas.EndScene;
  end;
  SetLength(FSignArray, 0);
end;

procedure TMasterDetailForm.SignPictureMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  FDrawingNow := False;
end;

procedure TMasterDetailForm.DrawSignPicture(const Canvas: TCanvas);
var
  TopPos: Integer;
  I: Integer;
  BackColor: TAlphaColor;
  RectF: TRectF;
begin
  Canvas.BeginScene;
  try
    Canvas.Clear(TAlphaColorRec.White);
    if DM.QueryEmployees.Eof then
    begin
      Exit;
    end;

    TopPos := 10;

    RectF := TRectF.Create(ctLeftpos, TopPos, ctSignPictureWidth, TopPos + ctSignPictureRowHeight);
    DrawCellEx(
      $FFFBEB5C, TAlphaColorRec.Black,
      Format('Расчетный листок за %s %s г. по зарплате', [
        DM.QueryEmployees.FieldByName('month').AsString, DM.QueryEmployees.FieldByName('year').AsString]),
      Canvas, RectF, 12);

    // ФИО
    TopPos := TopPos + ctSignPictureRowHeight;
    DrawCellEx(
      $FFFBEB5C, TAlphaColorRec.Black,
      DM.QueryEmployees.FieldByName('name').AsString,
      Canvas,
      TRectF.Create(ctLeftpos, TopPos, ctSignPictureWidth, TopPos + ctSignPictureRowHeight), 14);

    if grIncome.RowCount < 2 then
    begin
      Exit;
    end;

    for I := 1 to grIncome.RowCount - 1 do
    begin
      if grIncome.Cells[0, I] <> '' then
      begin
        TopPos := TopPos + ctSignPictureRowHeight;

        DrawCellEx(
          GetBackColor(I), TAlphaColorRec.Black,
          grIncome.Cells[0, I],
          Canvas,
          TRectF.Create(ctLeftpos, TopPos, ctSignPictureWidth, TopPos + ctSignPictureRowHeight), 12);

        if grIncome.Cells[1, I] <> '' then
        begin
          DrawCellEx(
            GetBackColor(I), TAlphaColorRec.Black,
            grIncome.Cells[1, I] + ' руб.',
            Canvas,
            TRectF.Create(620, TopPos, ctSignPictureWidth, TopPos + ctSignPictureRowHeight), 12);
        end;
      end;
    end;

    TopPos := TopPos + 50;
    DrawCellEx(
      $FFF6F6F6, TAlphaColorRec.Black,
      'Подпись ______________________________________________',
      Canvas,
      TRectF.Create(ctLeftpos, TopPos, ctSignPictureWidth, TopPos + 50), 14);

  finally
    Canvas.EndScene;
  end;
end;

procedure TMasterDetailForm.LoadSignPictureFromStream(const Canvas: TCanvas);
var
  MS: TMemoryStream;
  Bitmap: FMX.Graphics.TBitMap;
begin
  MS := TMemoryStream.Create;
  Bitmap := FMX.Graphics.TBitMap.Create;
  Canvas.BeginScene;
  try
    DM.SignToStream(MS,
      DM.QueryEmployees.FieldByName('month').AsString,
      DM.QueryEmployees.FieldByName('year').AsString,
      DM.QueryEmployees.FieldByName('id_user').AsString);

    Bitmap.LoadFromStream(MS);

    Canvas.DrawBitmap(Bitmap, TRectF.Create(0, 0, Bitmap.Width, Bitmap.Height), TRectF.Create(0, 0, Bitmap.Width, Bitmap.Height), 1);
  finally
    Canvas.EndScene;
    Bitmap.Free;
    MS.Free;
  end;
end;

procedure TMasterDetailForm.SignPicturePaint(Sender: TObject; Canvas: TCanvas);
begin
  if DM.QueryEmployees.FieldByName('signed').AsBoolean then
  begin
    LoadSignPictureFromStream(Canvas);
  end
  else
  begin
    DrawSignPicture(Canvas);
  end;
end;

procedure TMasterDetailForm.TabControl1Change(Sender: TObject);
begin
  if TabControl1.ActiveTab = tabSignPicture then
  begin
    if DM.QueryEmployees.FieldByName('signed').AsBoolean then
    begin
      btnSaveSign.Action := actionExportSign;
      actionExportSign.Visible := True;
    end
    else
    begin
      btnSaveSign.Action := actionSaveSign;
      actionSaveSign.Visible := True;
    end;
    btnBack.Visible := True;
  end
  else
  begin
    actionSaveSign.Visible := False;
    actionExportSign.Visible := False;
    btnBack.Visible := False;
  end;
end;

procedure TMasterDetailForm.UpdateEmployeeInfo;

  procedure SetEmptyRow(ARow: Integer);
  begin
    grIncome.Cells[0, ARow] := '';
    grIncome.Cells[1, ARow] := '';
    grIncome.Cells[2, ARow] := '';
  end;

var
  I: Integer;
  SNames, SValues: TStringList;
  nRow: Integer;
begin
  SignPicture.Width := ctSignPictureWidth;
  SignPicture.Height := ctSignPictureHeight;

  if DM.QueryEmployees.Eof then
  begin
    lblSigned.Text := '';
  end
  else
  if DM.QueryEmployees.FieldByName('signed').AsBoolean then
  begin
    lblSigned.Text := 'Получил';
    lblSigned.TextSettings.FontColor := TAlphaColorRec.Green;
  end
  else
  if not DM.QueryEmployees.FieldByName('signed').AsBoolean then
  begin
    lblSigned.Text := 'Не получил';
    lblSigned.TextSettings.FontColor := TAlphaColorRec.Crimson;
  end;

  for I := 0 to grIncome.RowCount - 1 do
  begin
    SetEmptyRow(I);
  end;

  grIncome.RowCount := 100;

  nRow := 0;
  grIncome.Cells[0, nRow] := 'Вид';
  grIncome.Cells[1, nRow] := 'Сумма';
  grIncome.Cells[2, nRow] := ctTitle;

  Inc(nRow);
  grIncome.Cells[0, nRow] := 'Начислено';
  grIncome.Cells[1, nRow] := '';
  grIncome.Cells[2, nRow] := ctIncomesTitle;

  SNames := TStringList.Create;
  SValues := TStringList.Create;
  try
    SNames.StrictDelimiter := True;
    SValues.StrictDelimiter := True;
    SNames.Delimiter := ';';
    SValues.Delimiter := ';';

    SNames.DelimitedText := DM.QueryEmployees.FieldByName('income_fields').AsString;
    SValues.DelimitedText := DM.QueryEmployees.FieldByName('income_values').AsString;
    for I := 0 to SNames.Count - 1 do
    begin
      Inc(nRow);
      grIncome.Cells[0, nRow] := SNames.Strings[I];
      try
        grIncome.Cells[1, nRow] := SValues.Strings[I];
      except
        grIncome.Cells[1, nRow] := '';
      end;
      grIncome.Cells[2, nRow] := ctIncome;
    end;

    Inc(nRow);
    grIncome.Cells[0, nRow] := 'Всего начислено';
    grIncome.Cells[1, nRow] := DM.QueryEmployees.FieldByName('income_sum').AsString;
    grIncome.Cells[2, nRow] := ctIncomeSum;

    Inc(nRow);
    SetEmptyRow(nRow);
    Inc(nRow);
    grIncome.Cells[0, nRow] := 'Удержано';
    grIncome.Cells[1, nRow] := '';
    grIncome.Cells[2, nRow] := ctWithheldTitle;

    SNames.DelimitedText := DM.QueryEmployees.FieldByName('withheld_fields').AsString;
    SValues.DelimitedText := DM.QueryEmployees.FieldByName('withheld_values').AsString;
    for I := 0 to SNames.Count - 1 do
    begin
      Inc(nRow);
      grIncome.Cells[0, nRow] := SNames.Strings[I];
      try
        grIncome.Cells[1, nRow] := SValues.Strings[I];
      except
        grIncome.Cells[1, nRow] := '';
      end;
      grIncome.Cells[2, nRow] := ctWithheld;
    end;

    Inc(nRow);
    grIncome.Cells[0, nRow] := 'Всего удержано';
    grIncome.Cells[1, nRow] := DM.QueryEmployees.FieldByName('withheld_sum').AsString;
    grIncome.Cells[2, nRow] := ctWithheldSum;

    Inc(nRow);
    SetEmptyRow(nRow);
    Inc(nRow);
    grIncome.Cells[0, nRow] := 'Сальдо на начало месяца';
    grIncome.Cells[1, nRow] := DM.QueryEmployees.FieldByName('month_begin').AsString;
    grIncome.Cells[2, nRow] := ctMonthBegin;

    Inc(nRow);
    grIncome.Cells[0, nRow] := 'Итого к выплате';
    grIncome.Cells[1, nRow] := DM.QueryEmployees.FieldByName('pay_all').AsString;
    grIncome.Cells[2, nRow] := ctPayAll;

    Inc(nRow);
    SetEmptyRow(nRow);
    Inc(nRow);
    grIncome.Cells[0, nRow] := 'Ранее выполненные выплаты';
    grIncome.Cells[1, nRow] := '';
    grIncome.Cells[2, nRow] := ctPaymentsTitle;

    SNames.DelimitedText := DM.QueryEmployees.FieldByName('payments_fields').AsString;
    SValues.DelimitedText := DM.QueryEmployees.FieldByName('payments_values').AsString;
    for I := 0 to SNames.Count - 1 do
    begin
      Inc(nRow);
      grIncome.Cells[0, nRow] := SNames.Strings[I];
      try
        grIncome.Cells[1, nRow] := SValues.Strings[I];
      except
        grIncome.Cells[1, nRow] := '';
      end;
      grIncome.Cells[2, nRow] := ctPayment;
    end;

    Inc(nRow);
    grIncome.Cells[0, nRow] := 'Итого';
    grIncome.Cells[1, nRow] := DM.QueryEmployees.FieldByName('payments_sum').AsString;
    grIncome.Cells[2, nRow] := ctPaymentSum;

    Inc(nRow);
    SetEmptyRow(nRow);
    Inc(nRow);
    grIncome.Cells[0, nRow] := 'К выдаче на руки';
    grIncome.Cells[1, nRow] := DM.QueryEmployees.FieldByName('salary_hand').AsString;;
    grIncome.Cells[2, nRow] := ctSalaryHand;

    grIncome.RowCount := nRow + 1;
  finally
    SNames.Free;
  end;

end;

procedure TMasterDetailForm.grIncomeDrawColumnCell(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
  const Row: Integer; const Value: TValue; const State: TGridDrawStates);
begin
  if (grIncome.Cells[2, Row] = ctIncomesTitle) or
     (grIncome.Cells[2, Row] = ctWithheldTitle) or
     (grIncome.Cells[2, Row] = ctPaymentsTitle) or
     (grIncome.Cells[2, Row] = ctPayAll) or
     (grIncome.Cells[2, Row] = ctPaymentSum) or
     (grIncome.Cells[2, Row] = ctSalaryHand) or
     (grIncome.Cells[2, Row] = ctTitle) or
     (grIncome.Cells[2, Row] = ctIncomeSum) or
     (grIncome.Cells[2, Row] = ctWithheldSum) then
  begin
    DrawCellEx(
      GetBackColor(Row), TAlphaColorRec.Black,
      grIncome.Cells[Column.Index, Row], Canvas, Bounds);
  end
  else
  begin
    TGrid(Sender).DefaultDrawColumnCell(Canvas, Column, Bounds, Row, Value, State);
  end;
end;

procedure TMasterDetailForm.grIncomeDrawColumnHeader(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF);
begin
  DrawCellEx(
    $FFC1C1C1, TAlphaColorRec.Black,
    Column.Header, Canvas, Bounds);
end;

procedure TMasterDetailForm.DataSource1DataChange(Sender: TObject;
  Field: TField);
begin
  UpdateEmployeeInfo;
end;

procedure TMasterDetailForm.FormCreate(Sender: TObject);
begin
  FDrawingNow := False;
  grIncome.DefaultDrawing := False;
  FEmployeesSignedFilter := empAll;
  TabControl1.ActiveTab := tabEmployees;
  if DM.DBConnect(
    procedure (AMessage: String)
    begin
      ShowMessage(AMessage);
    end) then
  begin
    UpdateLists;
    UpdateEmployeesList;
  end;
end;

procedure TMasterDetailForm.UncheckAllEmployeeListItems;
begin
  liAllEmployees.ItemData.Accessory := FMX.ListBox.TListBoxItemData.TAccessory.aNone;
  liNotSigned.ItemData.Accessory := FMX.ListBox.TListBoxItemData.TAccessory.aNone;
  liSigned.ItemData.Accessory := FMX.ListBox.TListBoxItemData.TAccessory.aNone;
end;

procedure TMasterDetailForm.FormDestroy(Sender: TObject);
begin
  DM.DBDisconnect;
end;

procedure TMasterDetailForm.liAllEmployeesClick(Sender: TObject);
begin
  actionSelectEmployees.ExecuteTarget(Sender);
  UncheckAllEmployeeListItems;
  (Sender as TListBoxItem).ItemData.Accessory := FMX.ListBox.TListBoxItemData.TAccessory.aCheckmark;
  case (Sender as TListBoxItem).Tag of
    0: FEmployeesSignedFilter := empAll;
    1: FEmployeesSignedFilter := empUnsigned;
    2: FEmployeesSignedFilter := empSigned;
  end;
  UpdateEmployeesList;
end;

procedure TMasterDetailForm.liEmployeesManagerClick(Sender: TObject);
begin
  actionSelectEmployeesManager.ExecuteTarget(Sender);
end;

procedure TMasterDetailForm.lstEmployeesItemClick(const Sender: TObject; const AItem: TListViewItem);
begin
  MVEmployees.HideMaster;
end;

procedure TMasterDetailForm.lstOptionsItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  Item.IsSelected := False;
  MVOptions.HideMaster;
end;

procedure TMasterDetailForm.LoadFromXML(AFileName: String);
var
  lMonth, lYear: String;

  procedure AddToSalaryFieldsArray(AItem: TSalaryFieldsArray; AFieldName, AFieldValue: String);
  begin
    SetLength(AItem, Length(AItem) + 1);
    AItem[Length(AItem) - 1].Name := AFieldName;
    AItem[Length(AItem) - 1].Value := AFieldValue;
  end;

  procedure LoadEmployeeData(IEmployee: IXMLNode);
  var
    i, j: Integer;
    IFields, IField: IXMLNode;
    emplName: String;
    emplId: String;
    emplDepartment: String;
    fieldName: String;
    fieldType: Integer;
    fieldValue: String;
    unknownType: TSalaryFieldsArray;
    incomeFields: TSalaryFieldsArray;
    withheldFields: TSalaryFieldsArray;
    paymentsFields: TSalaryFieldsArray;
    incomeSum: TSalaryFieldData;
    withheldSum: TSalaryFieldData;
    monthBegin: TSalaryFieldData;
    payAll: TSalaryFieldData;
    paymentsSum: TSalaryFieldData;
    salaryHand: TSalaryFieldData;
    MonthToStr: String;
  begin
    if IEmployee.HasAttribute('name') then
    begin
      emplName := IEmployee.Attributes['name'];
    end;
    if IEmployee.HasAttribute('id') then
    begin
      emplId := IEmployee.Attributes['id'];
    end;
    if IEmployee.HasAttribute('department') then
    begin
      emplDepartment := IEmployee.Attributes['department'];
    end;

    if (trim(emplName) = '') or (trim(emplId) = '') then
    begin
      Exit;
    end;

    try
      if IEmployee.HasChildNodes then
      begin
        IFields := IEmployee.ChildNodes.Nodes['fields'];
        try
          if Assigned(IFields) and IFields.HasChildNodes then
          begin
            DM.FDTransaction1.Options.AutoCommit := False;
            DM.FDTransaction1.Options.AutoStart := False;
            DM.FDTransaction1.Options.AutoStop := False;
            DM.FDTransaction1.StartTransaction;
            try
              try
                for j := 0 to IFields.ChildNodes.Count - 1 do
                begin
                  fieldName := '';
                  fieldType := 0;

                  if IFields.ChildNodes[j].NodeName = 'field' then
                  begin
                    IField := IFields.ChildNodes[j];
                    try
                      if IField.HasAttribute('name') then
                      begin
                        fieldName := IField.Attributes['name'];
                      end;

                      if trim(fieldName) = '' then
                      begin
                        Continue;
                      end;

                      if IField.HasAttribute('type') then
                      begin
                        fieldType := StrToIntDef(IField.Attributes['type'], 0);
                      end;

                      fieldValue := IField.NodeValue;

                      case fieldType of
                        0: begin
                             SetLength(unknownType, Length(unknownType) + 1);
                             unknownType[Length(unknownType) - 1].Name := fieldName;
                             unknownType[Length(unknownType) - 1].Value := fieldValue;
                             //AddToSalaryFieldsArray(unknownType, fieldName, fieldValue);
                           end;
                        1: begin
                             SetLength(incomeFields, Length(incomeFields) + 1);
                             incomeFields[Length(incomeFields) - 1].Name := fieldName;
                             incomeFields[Length(incomeFields) - 1].Value := fieldValue;
                             //AddToSalaryFieldsArray(incomeFields, fieldName, fieldValue);
                           end;
                        2: begin
                             incomeSum.Name := fieldName;
                             incomeSum.Value := fieldValue;
                           end;
                        3: begin
                             SetLength(withheldFields, Length(withheldFields) + 1);
                             withheldFields[Length(withheldFields) - 1].Name := fieldName;
                             withheldFields[Length(withheldFields) - 1].Value := fieldValue;
                             //AddToSalaryFieldsArray(withheldFields, fieldName, fieldValue);
                           end;
                        4: begin
                             withheldSum.Name := fieldName;
                             withheldSum.Value := fieldValue;
                           end;
                        5: begin
                             monthBegin.Name := fieldName;
                             monthBegin.Value := fieldValue;
                           end;
                        6: begin
                             payAll.Name := fieldName;
                             payAll.Value := fieldValue;
                           end;
                        7: begin
                             SetLength(paymentsFields, Length(paymentsFields) + 1);
                             paymentsFields[Length(paymentsFields) - 1].Name := fieldName;
                             paymentsFields[Length(paymentsFields) - 1].Value := fieldValue;
                             //AddToSalaryFieldsArray(paymentsFields, fieldName, fieldValue);
                           end;
                        8: begin
                             paymentsSum.Name := fieldName;
                             paymentsSum.Value := fieldValue;
                           end;
                        9: begin
                             salaryHand.Name := fieldName;
                             salaryHand.Value := fieldValue;
                           end;
                      end;

                    finally
                      IField := nil;
                    end;

                    case StrToIntDef(lMonth, 0) of
                      1:  MonthToStr := 'Январь';
                      2:  MonthToStr := 'Февраль';
                      3:  MonthToStr := 'Март';
                      4:  MonthToStr := 'Апрель';
                      5:  MonthToStr := 'Май';
                      6:  MonthToStr := 'Июнь';
                      7:  MonthToStr := 'Июль';
                      8:  MonthToStr := 'Август';
                      9:  MonthToStr := 'Сентябрь';
                      10: MonthToStr := 'Октябрь';
                      11: MonthToStr := 'Ноябрь';
                      12: MonthToStr := 'Декабрь';
                    end;

                    DM.SaveEmployee(
                      MonthToStr, lYear, emplId, emplName, emplDepartment,
                      unknownType, incomeFields, withheldFields, paymentsFields,
                      incomeSum, withheldSum, monthBegin, payAll, paymentsSum, salaryHand);
                  end;
                end;
                DM.FDTransaction1.Commit;
              except
                on E: Exception do
                begin
                  DM.FDTransaction1.Rollback;
                  raise Exception.Create(E.Message);
                end;
              end;
            finally
              DM.FDTransaction1.Options.AutoCommit := True;
              DM.FDTransaction1.Options.AutoStart := True;
              DM.FDTransaction1.Options.AutoStop := True;
            end;
          end;
        finally
          IFields := nil;
        end;
      end;
    except
      on E: Exception do
      begin
        ShowMessage(Format('Ошибка в данных сотрудника "%s": %s', [emplName, E.Message]));
      end;
    end;
  end;

var
  XMLDocument: TXMLDocument;
  INode, IPeriod, IEmployees,
  IEmployee, ITmpNode: IXMLNode;
  i, j: Integer;
  Sl: TStringList;
begin
  XMLDocument := TXMLDocument.Create(Self);
  try
    lMonth := '';
    lYear := '';

    Sl := TStringList.Create;
    try
      SL.LoadFromFile(AFileName);
      SL.Text := ReplaceStr(SL.Text, '''', '"');
      SL.SaveToFile(AFileName, TEncoding.UTF8);
    finally
      SL.Free;
    end;

    XMLDocument.Active := True;
    XMLDocument.LoadFromFile(AFileName);

    if XMLDocument.IsEmptyDoc then
    begin
      ShowMessage('Документ пуст!');
      Exit;
    end;

    INode := XMLDocument.DocumentElement;

    if Assigned(INode) and INode.HasChildNodes then
    begin
      try
        IPeriod := INode.ChildNodes.FindNode('period');
        if Assigned(IPeriod) then
        begin
          ITmpNode := IPeriod.ChildNodes.FindNode('month');
          if Assigned(ITmpNode) then
          try
            lMonth := ITmpNode.NodeValue;
          finally
            ITmpNode := nil;
          end;

          ITmpNode := IPeriod.ChildNodes.FindNode('year');
          if Assigned(ITmpNode) then
          try
            lYear := ITmpNode.NodeValue;
          finally
            ITmpNode := nil;
          end;
        end;

        IEmployees := INode.ChildNodes.FindNode('employees');
        if Assigned(IEmployees) and IEmployees.HasChildNodes then
        begin
          IEmployee := IEmployees.ChildNodes.First;
          while Assigned(IEmployee) do
          begin
            LoadEmployeeData(IEmployee);
            IEmployee := IEmployees.ChildNodes.FindSibling(IEmployee, 1);
          end;

          for j := 0 to IEmployees.ChildNodes.Count - 1 do
          begin
            if IEmployees.ChildNodes[j].NodeName = 'employee' then
            begin
              LoadEmployeeData(IEmployees.ChildNodes[j]);
            end;
          end;
        end;
      finally
        IPeriod := nil;
        IEmployees := nil;
      end;
    end;
  finally
    INode := nil;
    XMLDocument.Free;
  end;
end;

procedure TMasterDetailForm.ExportSignPicture;
begin
  SaveDialog1.FileName :=
    DM.QueryEmployees.FieldByName('name').AsString + '.png';

  if SaveDialog1.Execute then
  begin
    DM.SignToFile(SaveDialog1.FileName,
        DM.QueryEmployees.FieldByName('month').AsString,
        DM.QueryEmployees.FieldByName('year').AsString,
        DM.QueryEmployees.FieldByName('id_user').AsString);
  end;
end;

procedure TMasterDetailForm.SaveSignPicture;
var
  lStream: TMemoryStream;
  Bitmap: TBitmap;
begin
  lStream := TMemoryStream.Create;
  Bitmap := TBitmap.Create;
  try
    Bitmap.Height := 1200;
    Bitmap.Width := 800;
    SignPicture.PaintTo(Bitmap.Canvas, TRectF.Create(0, 0, SignPicture.Width, SignPicture.Height));

    DrawSign(Bitmap.Canvas);

    Bitmap.SaveToStream(lStream);
    DM.SaveSign(
      lStream,
      DM.QueryEmployees.FieldByName('month').AsString,
      DM.QueryEmployees.FieldByName('year').AsString,
      DM.QueryEmployees.FieldByName('id_user').AsString);
  finally
    Bitmap.Free;
    lStream.Free;
  end;
end;

end.
