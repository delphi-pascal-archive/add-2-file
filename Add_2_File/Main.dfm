object MainForm: TMainForm
  Left = 227
  Top = 126
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Add 2 File'
  ClientHeight = 257
  ClientWidth = 366
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 120
  TextHeight = 16
  object FileLbl: TLabel
    Left = 138
    Top = 17
    Width = 218
    Height = 16
    AutoSize = False
    Caption = '[Aucun fichier selectionne]'
  end
  object SepBevel: TBevel
    Left = 10
    Top = 49
    Width = 346
    Height = 3
  end
  object BrowseBtn: TButton
    Left = 10
    Top = 10
    Width = 119
    Height = 31
    Caption = 'Choose file'
    TabOrder = 0
    OnClick = BrowseBtnClick
  end
  object DataMemo: TMemo
    Left = 10
    Top = 59
    Width = 346
    Height = 110
    Enabled = False
    Lines.Strings = (
      'Selectionnez un fichier.')
    TabOrder = 1
  end
  object WriteBtn: TButton
    Left = 10
    Top = 177
    Width = 198
    Height = 31
    Caption = 'Add this data'
    Enabled = False
    TabOrder = 2
    OnClick = WriteBtnClick
  end
  object DeleteBtn: TButton
    Left = 10
    Top = 217
    Width = 198
    Height = 30
    Caption = 'Clear all data'
    Enabled = False
    TabOrder = 3
    OnClick = DeleteBtnClick
  end
  object QuitBtn: TButton
    Left = 217
    Top = 217
    Width = 139
    Height = 30
    Caption = 'Exit'
    TabOrder = 4
    OnClick = QuitBtnClick
  end
  object ToReadBtn: TButton
    Left = 217
    Top = 177
    Width = 139
    Height = 31
    Caption = 'About'
    TabOrder = 5
    OnClick = ToReadBtnClick
  end
  object OpenDlg: TOpenDialog
    Filter = 'Tous les fichiers|*.*'
    Title = 'Choisir un fichier'
    Left = 256
    Top = 8
  end
end
