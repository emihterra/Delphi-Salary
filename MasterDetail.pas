unit MasterDetail;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListView.Types, Data.Bind.GenData,
  Fmx.Bind.GenData, System.Rtti, System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt,
  Data.Bind.Components, Data.Bind.ObjectScope, FMX.Objects, FMX.StdCtrls, FMX.ListView, FMX.ListView.Appearances,
  FMX.Layouts, FMX.MultiView,FMX.Memo, Fmx.Bind.Navigator, System.Actions, FMX.ActnList,
  FMX.ListView.Adapters.Base, FMX.ScrollBox, FMX.Controls.Presentation,
  FMX.ListBox, FMX.TabControl, FMX.Edit, FMX.SearchBox, Xml.XMLDoc, Xml.XmlIntf,
  Data.Bind.DBScope, Data.DB,
  DMSQLite, FMX.Grid;

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
  private
    { Private declarations }
    FEmployeesSignedFilter: TEmployeesSignedFilter;
    procedure UncheckAllEmployeeListItems;
    procedure LoadFromXML(AFileName: String);
    procedure UpdateLists;
    procedure UpdateEmployeesList;
    procedure UpdateTitle;
    procedure UpdateEmployeeInfo;
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

  cboDepartments.Items.Insert(0, '���');
  cboDepartments.ItemIndex := 0;

  if cboPeriods.Items.Count > 0 then
  begin
     cboPeriods.ItemIndex := 0;
  end;
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
    empAll: MasterLabel.Text := '��� ����������';
    empUnsigned: MasterLabel.Text := '����������, �� ���������� ��������';
    empSigned: MasterLabel.Text := '����������, ���������� ��������';
  end;

  DepStr := '';

  if cboDepartments.ItemIndex > 0 then
  begin
    DepStr := cboDepartments.Items[cboDepartments.ItemIndex];
  end;

  MasterLabel.Text := MasterLabel.Text + Format(' �� %s', [cboPeriods.Items[cboPeriods.ItemIndex]]);

  if DepStr <> '' then
  begin
    MasterLabel.Text := MasterLabel.Text + Format(', ������������� "%s"', [DepStr]);
  end;
end;

procedure TMasterDetailForm.cboPeriodsChange(Sender: TObject);
begin
  UpdateTitle;
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
  if DM.QueryEmployees.Eof then
  begin
    lblSigned.Text := '';
  end
  else
  if DM.QueryEmployees.FieldByName('signed').AsBoolean then
  begin
    lblSigned.Text := '�������';
    lblSigned.TextSettings.FontColor := TAlphaColorRec.Green;
  end
  else
  if not DM.QueryEmployees.FieldByName('signed').AsBoolean then
  begin
    lblSigned.Text := '�� �������';
    lblSigned.TextSettings.FontColor := TAlphaColorRec.Crimson;
  end;

  for I := 0 to grIncome.RowCount - 1 do
  begin
    SetEmptyRow(I);
  end;

  grIncome.RowCount := 100;

  nRow := 0;
  grIncome.Cells[0, nRow] := '���';
  grIncome.Cells[1, nRow] := '�����';
  grIncome.Cells[2, nRow] := ctTitle;

  Inc(nRow);
  grIncome.Cells[0, nRow] := '���������';
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
    grIncome.Cells[0, nRow] := '����� ���������';
    grIncome.Cells[1, nRow] := DM.QueryEmployees.FieldByName('income_sum').AsString;
    grIncome.Cells[2, nRow] := ctIncomeSum;

    Inc(nRow);
    SetEmptyRow(nRow);
    Inc(nRow);
    grIncome.Cells[0, nRow] := '��������';
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
    grIncome.Cells[0, nRow] := '����� ��������';
    grIncome.Cells[1, nRow] := DM.QueryEmployees.FieldByName('withheld_sum').AsString;
    grIncome.Cells[2, nRow] := ctWithheldSum;

    Inc(nRow);
    SetEmptyRow(nRow);
    Inc(nRow);
    grIncome.Cells[0, nRow] := '������ �� ������ ������';
    grIncome.Cells[1, nRow] := DM.QueryEmployees.FieldByName('month_begin').AsString;
    grIncome.Cells[2, nRow] := ctMonthBegin;

    Inc(nRow);
    grIncome.Cells[0, nRow] := '����� � �������';
    grIncome.Cells[1, nRow] := DM.QueryEmployees.FieldByName('pay_all').AsString;
    grIncome.Cells[2, nRow] := ctPayAll;

    Inc(nRow);
    SetEmptyRow(nRow);
    Inc(nRow);
    grIncome.Cells[0, nRow] := '����� ����������� �������';
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
    grIncome.Cells[0, nRow] := '�����';
    grIncome.Cells[1, nRow] := DM.QueryEmployees.FieldByName('payments_sum').AsString;
    grIncome.Cells[2, nRow] := ctPaymentSum;

    Inc(nRow);
    SetEmptyRow(nRow);
    Inc(nRow);
    grIncome.Cells[0, nRow] := '� ������ �� ����';
    grIncome.Cells[1, nRow] := DM.QueryEmployees.FieldByName('salary_hand').AsString;;
    grIncome.Cells[2, nRow] := ctSalaryHand;

    grIncome.RowCount := nRow + 1;
  finally
    SNames.Free;
  end;

end;

procedure DrawCellEx(
  ABackColor: TAlphaColor; AFontColor: TAlphaColor; AText: String;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF);
begin
  Canvas.Fill.Color := ABackColor;
  Canvas.FillRect(Bounds, 0, 0, [], 1);
  Canvas.Font.Size := 14;
  Canvas.Fill.Color := AFontColor;
  Canvas.FillText(Bounds, AText, False, 1, [] , TTextAlign.Leading);
end;

procedure TMasterDetailForm.grIncomeDrawColumnCell(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
  const Row: Integer; const Value: TValue; const State: TGridDrawStates);
begin
  if (grIncome.Cells[2, Row] = ctIncomesTitle) or
     (grIncome.Cells[2, Row] = ctWithheldTitle) or
     (grIncome.Cells[2, Row] = ctPaymentsTitle) then
  begin
    DrawCellEx(
      $FF71B2EF, TAlphaColorRec.Black,
      grIncome.Cells[Column.Index, Row], Canvas, Column, Bounds);
  end
  else
  if (grIncome.Cells[2, Row] = ctPayAll) or
     (grIncome.Cells[2, Row] = ctPaymentSum) then
  begin
    DrawCellEx(
      $FF8EC694, TAlphaColorRec.Black,
      grIncome.Cells[Column.Index, Row], Canvas, Column, Bounds);
  end
  else
  if (grIncome.Cells[2, Row] = ctSalaryHand) then
  begin
    DrawCellEx(
      $FFFBEB5C, TAlphaColorRec.Black,
      grIncome.Cells[Column.Index, Row], Canvas, Column, Bounds);
  end
  else
  if (grIncome.Cells[2, Row] = ctTitle) then
  begin
    DrawCellEx(
      $FFB9B9B9, TAlphaColorRec.Black,
      grIncome.Cells[Column.Index, Row], Canvas, Column, Bounds);
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
    Column.Header, Canvas, Column, Bounds);
end;

procedure TMasterDetailForm.DataSource1DataChange(Sender: TObject;
  Field: TField);
begin
  UpdateEmployeeInfo;
end;

procedure TMasterDetailForm.FormCreate(Sender: TObject);
begin
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
                  1:  MonthToStr := '������';
                  2:  MonthToStr := '�������';
                  3:  MonthToStr := '����';
                  4:  MonthToStr := '������';
                  5:  MonthToStr := '���';
                  6:  MonthToStr := '����';
                  7:  MonthToStr := '����';
                  8:  MonthToStr := '������';
                  9:  MonthToStr := '��������';
                  10: MonthToStr := '�������';
                  11: MonthToStr := '������';
                  12: MonthToStr := '�������';
                end;

                DM.SaveEmployee(
                  MonthToStr, lYear, emplId, emplName, emplDepartment,
                  unknownType, incomeFields, withheldFields, paymentsFields,
                  incomeSum, withheldSum, monthBegin, payAll, paymentsSum, salaryHand);
              end;
            end;
          end;
        finally
          IFields := nil;
        end;
      end;
    except
      on E: Exception do
      begin
        ShowMessage(Format('������ � ������ ���������� "%s": %s', [emplName, E.Message]));
      end;
    end;
  end;

var
  XMLDocument: TXMLDocument;
  INode, IPeriod, IEmployees,
  IEmployee, ITmpNode: IXMLNode;
  i, j: Integer;
begin
  XMLDocument := TXMLDocument.Create(Self);
  try
    lMonth := '';
    lYear := '';

    XMLDocument.LoadFromFile(AFileName);
    XMLDocument.Active := True;

    if XMLDocument.IsEmptyDoc then
    begin
      ShowMessage('�������� ����!');
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

end.
