unit MasterDetail;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListView.Types, Data.Bind.GenData,
  Fmx.Bind.GenData, System.Rtti, System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt,
  Data.Bind.Components, Data.Bind.ObjectScope, FMX.Objects, FMX.StdCtrls, FMX.ListView, FMX.ListView.Appearances,
  FMX.Layouts, FMX.MultiView,FMX.Memo, Fmx.Bind.Navigator, System.Actions, FMX.ActnList,
  FMX.ListView.Adapters.Base, FMX.ScrollBox, FMX.Controls.Presentation,
  FMX.ListBox, FMX.TabControl, FMX.Edit, FMX.SearchBox, Xml.XMLDoc, Xml.XmlIntf;

type
  TMasterDetailForm = class(TForm)
    MVEmployees: TMultiView;
    Layout1: TLayout;
    lstEmployees: TListView;
    MasterToolbar: TToolBar;
    MasterLabel: TLabel;
    MasterButton: TSpeedButton;
    imgContact: TImage;
    lblName: TLabel;
    lblTitle: TLabel;
    PrototypeBindSource1: TPrototypeBindSource;
    BindingsList1: TBindingsList;
    LinkPropertyToFieldBitmap: TLinkPropertyToField;
    LinkPropertyToFieldText: TLinkPropertyToField;
    LinkPropertyToFieldText2: TLinkPropertyToField;
    Layout2: TLayout;
    Layout3: TLayout;
    Memo1: TMemo;
    LinkControlToField1: TLinkControlToField;
    LinkListControlToField1: TLinkListControlToField;
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
    procedure lstEmployeesItemClick(const Sender: TObject; const AItem: TListViewItem);
    procedure lstOptionsItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure FormCreate(Sender: TObject);
    procedure liAllEmployeesClick(Sender: TObject);
    procedure liEmployeesManagerClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnLoadEmployeesClick(Sender: TObject);
  private
    { Private declarations }
    procedure UncheckAllEmployeeListItems;
    procedure LoadFromXML(AFileName: String);
    procedure UpdateLists;
  public
    { Public declarations }
  end;

var
  MasterDetailForm: TMasterDetailForm;

implementation

{$R *.fmx}

uses DMSQLite;

procedure TMasterDetailForm.UpdateLists;
begin
  DM.GetDepartments(cboDepartments.Items);
  DM.GetPeriods(cboPeriods.Items);

  if cboPeriods.Items.Count > 0 then
  begin
     cboPeriods.ItemIndex := 0;
  end;
  cboDepartments.Items.Insert(0, 'Все');
  cboDepartments.ItemIndex := 0;
end;

procedure TMasterDetailForm.btnLoadEmployeesClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    LoadFromXML(OpenDialog1.FileName);
    UpdateLists;
  end;
end;

procedure TMasterDetailForm.FormCreate(Sender: TObject);
begin
  TabControl1.ActiveTab := tabEmployees;
  if DM.DBConnect(
    procedure (AMessage: String)
    begin
      ShowMessage(AMessage);
    end) then
  begin
    UpdateLists;
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
                         AddToSalaryFieldsArray(unknownType, fieldName, fieldValue);
                       end;
                    1: begin
                         AddToSalaryFieldsArray(incomeFields, fieldName, fieldValue);
                       end;
                    2: begin
                         incomeSum.Name := fieldName;
                         incomeSum.Value := fieldValue;
                       end;
                    3: begin
                         AddToSalaryFieldsArray(withheldFields, fieldName, fieldValue);
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
                         AddToSalaryFieldsArray(paymentsFields, fieldName, fieldValue);
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

                DM.SaveEmployee(
                  lMonth, lYear, emplId, emplName, emplDepartment,
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
        ShowMessage(Format('Ошибка в данных сотрудника "%s": %s', [emplName, E.Message]));
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

end.
