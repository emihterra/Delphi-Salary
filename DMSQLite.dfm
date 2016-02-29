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
  object FDQuery1: TFDQuery
    Connection = SQLConnection
    Left = 136
    Top = 32
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
    Left = 136
    Top = 96
  end
end
