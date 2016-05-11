object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 321
  Width = 222
  object SQLConnection: TFDConnection
    Params.Strings = (
      'DriverID=SQLite')
    Transaction = FDTransaction1
    UpdateTransaction = FDTransaction1
    Left = 40
    Top = 32
  end
  object QueryEmployees: TFDQuery
    Connection = SQLConnection
    FetchOptions.AssignedValues = [evCursorKind]
    FetchOptions.CursorKind = ckDynamic
    SQL.Strings = (
      'select * from employee')
    Left = 136
    Top = 32
    object QueryEmployeesid: TFDAutoIncField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = True
    end
    object QueryEmployeesid_department: TIntegerField
      FieldName = 'id_department'
      Origin = 'id_department'
    end
    object QueryEmployeesname: TStringField
      FieldName = 'name'
      Origin = 'name'
      Size = 50
    end
    object QueryEmployeesid_user: TStringField
      FieldName = 'id_user'
      Origin = 'id_user'
      Size = 10
    end
    object QueryEmployeesmonth: TStringField
      FieldName = 'month'
      Origin = 'month'
      Size = 8
    end
    object QueryEmployeesyear: TStringField
      FieldName = 'year'
      Origin = 'year'
      Size = 4
    end
    object QueryEmployeesincome_fields: TWideMemoField
      FieldName = 'income_fields'
      Origin = 'income_fields'
      BlobType = ftWideMemo
    end
    object QueryEmployeesincome_values: TWideMemoField
      FieldName = 'income_values'
      Origin = 'income_values'
      BlobType = ftWideMemo
    end
    object QueryEmployeesincome_sum: TStringField
      FieldName = 'income_sum'
      Origin = 'income_sum'
      Size = 15
    end
    object QueryEmployeeswithheld_fields: TWideMemoField
      FieldName = 'withheld_fields'
      Origin = 'withheld_fields'
      BlobType = ftWideMemo
    end
    object QueryEmployeeswithheld_values: TWideMemoField
      FieldName = 'withheld_values'
      Origin = 'withheld_values'
      BlobType = ftWideMemo
    end
    object QueryEmployeeswithheld_sum: TStringField
      FieldName = 'withheld_sum'
      Origin = 'withheld_sum'
      Size = 15
    end
    object QueryEmployeesmonth_begin: TStringField
      FieldName = 'month_begin'
      Origin = 'month_begin'
      Size = 15
    end
    object QueryEmployeespay_all: TStringField
      FieldName = 'pay_all'
      Origin = 'pay_all'
      Size = 15
    end
    object QueryEmployeespayments_fields: TWideMemoField
      FieldName = 'payments_fields'
      Origin = 'payments_fields'
      BlobType = ftWideMemo
    end
    object QueryEmployeespayments_values: TWideMemoField
      FieldName = 'payments_values'
      Origin = 'payments_values'
      BlobType = ftWideMemo
    end
    object QueryEmployeespayments_sum: TStringField
      FieldName = 'payments_sum'
      Origin = 'payments_sum'
      Size = 15
    end
    object QueryEmployeessalary_hand: TStringField
      FieldName = 'salary_hand'
      Origin = 'salary_hand'
      Size = 15
    end
    object QueryEmployeessigned: TBooleanField
      FieldName = 'signed'
      Origin = 'signed'
    end
    object QueryEmployeessign_time: TSQLTimeStampField
      FieldName = 'sign_time'
      Origin = 'sign_time'
    end
    object QueryEmployeessign_pic: TBlobField
      FieldName = 'sign_pic'
      Origin = 'sign_pic'
    end
  end
  object FDTransaction1: TFDTransaction
    Connection = SQLConnection
    Left = 40
    Top = 96
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'FMX'
    Left = 40
    Top = 168
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    VendorLib = 'sqlite3.dll'
    Left = 136
    Top = 96
  end
  object FDSQLiteBackup1: TFDSQLiteBackup
    DriverLink = FDPhysSQLiteDriverLink1
    Catalog = 'MAIN'
    DestCatalog = 'MAIN'
    Left = 144
    Top = 168
  end
end
