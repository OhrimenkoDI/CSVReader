object Form2: TForm2
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'CSVReaderServer'
  ClientHeight = 504
  ClientWidth = 1276
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Courier New'
  Font.Style = [fsBold]
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 18
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 81
    Height = 34
    Caption = #1054#1090#1082#1088#1099#1090#1100
    TabOrder = 0
    OnClick = Button1Click
  end
  object TextFile: TMemo
    Left = 95
    Top = 0
    Width = 1181
    Height = 459
    Align = alRight
    Lines.Strings = (
      'TextFile')
    TabOrder = 1
  end
  object Time: TCheckBox
    Left = 8
    Top = 379
    Width = 73
    Height = 17
    Caption = 'Time'
    TabOrder = 2
  end
  object TrackBar1: TTrackBar
    Left = 0
    Top = 459
    Width = 1276
    Height = 45
    Align = alBottom
    Max = 10000
    TabOrder = 3
  end
  object HTTPServer: TIdHTTPServer
    Active = True
    Bindings = <
      item
        IP = '127.0.0.1'
        Port = 4000
      end>
    OnCommandGet = HTTPServerCommandGet
    Left = 184
    Top = 8
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'csv'
    Filter = '*.csv|*.csv'
    Left = 152
    Top = 24
  end
end
