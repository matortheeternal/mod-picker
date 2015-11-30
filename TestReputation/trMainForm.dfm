object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Test Reputation'
  ClientHeight = 330
  ClientWidth = 414
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 398
    Height = 283
    ActivePage = Options
    Align = alCustom
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    TabWidth = 100
    object Options: TTabSheet
      Caption = 'Options'
      object Label1: TLabel
        Left = 8
        Top = 11
        Width = 79
        Height = 13
        Margins.Left = 8
        Caption = 'Number of users'
      end
      object Label2: TLabel
        Left = 8
        Top = 38
        Width = 104
        Height = 13
        Caption = 'Maximum connections'
      end
      object Label3: TLabel
        Left = 8
        Top = 65
        Width = 97
        Height = 13
        Caption = 'Maximum reputation'
      end
      object Label4: TLabel
        Left = 8
        Top = 92
        Width = 98
        Height = 13
        Caption = 'Number of iterations'
      end
      object Label5: TLabel
        Left = 8
        Top = 119
        Width = 98
        Height = 13
        Caption = 'Chance of dead-end'
      end
      object Edit1: TEdit
        Left = 144
        Top = 8
        Width = 121
        Height = 21
        Margins.Left = 8
        Margins.Top = 8
        Margins.Right = 8
        Margins.Bottom = 8
        NumbersOnly = True
        TabOrder = 0
        Text = '10'
      end
      object Edit2: TEdit
        Left = 144
        Top = 35
        Width = 121
        Height = 21
        NumbersOnly = True
        TabOrder = 1
        Text = '3'
      end
      object Edit3: TEdit
        Left = 144
        Top = 62
        Width = 121
        Height = 21
        NumbersOnly = True
        TabOrder = 2
        Text = '5000'
      end
      object Edit4: TEdit
        Left = 144
        Top = 89
        Width = 121
        Height = 21
        NumbersOnly = True
        TabOrder = 3
        Text = '3'
      end
      object Edit5: TEdit
        Left = 144
        Top = 116
        Width = 121
        Height = 21
        NumbersOnly = True
        TabOrder = 4
        Text = '15'
      end
    end
    object Log: TTabSheet
      Caption = 'Log'
      ImageIndex = 1
      object Memo1: TMemo
        Left = 3
        Top = 3
        Width = 384
        Height = 249
        Align = alCustom
        Anchors = [akLeft, akTop, akRight, akBottom]
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
  end
  object Button1: TButton
    Left = 250
    Top = 297
    Width = 75
    Height = 25
    Align = alCustom
    Anchors = [akRight, akBottom]
    Caption = 'Run'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 331
    Top = 297
    Width = 75
    Height = 25
    Align = alCustom
    Anchors = [akRight, akBottom]
    Caption = 'Close'
    ModalResult = 2
    TabOrder = 2
    OnClick = Button2Click
  end
  object XPManifest1: TXPManifest
    Left = 376
    Top = 8
  end
end
