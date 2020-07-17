object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Test Active Directory'
  ClientHeight = 669
  ClientWidth = 792
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlPrinc: TPanel
    Left = 0
    Top = 0
    Width = 792
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    object btnGetCurrentInfo: TButton
      AlignWithMargins = True
      Left = 8
      Top = 5
      Width = 124
      Height = 31
      Margins.Left = 8
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alLeft
      Caption = 'Get Current Info'
      TabOrder = 0
      OnClick = btnGetCurrentInfoClick
    end
  end
  object edtLog: TMemo
    Left = 0
    Top = 106
    Width = 792
    Height = 522
    Hint = 'Log'
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    PopupMenu = PopupMenu
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object pnlCustomAuth: TPanel
    Left = 0
    Top = 41
    Width = 792
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 1
    object edtDomain: TLabeledEdit
      Left = 9
      Top = 32
      Width = 124
      Height = 21
      EditLabel.Width = 40
      EditLabel.Height = 13
      EditLabel.Caption = 'Domain'
      TabOrder = 0
      OnChange = edtUserPassChange
    end
    object edtUserName: TLabeledEdit
      Left = 138
      Top = 32
      Width = 124
      Height = 21
      EditLabel.Width = 52
      EditLabel.Height = 13
      EditLabel.Caption = 'UserName'
      TabOrder = 1
      OnChange = edtUserPassChange
    end
    object edtUserPass: TLabeledEdit
      Left = 267
      Top = 32
      Width = 124
      Height = 21
      EditLabel.Width = 49
      EditLabel.Height = 13
      EditLabel.Caption = 'Password'
      TabOrder = 2
      OnChange = edtUserPassChange
    end
    object btnAuthenticate: TButton
      Left = 595
      Top = 30
      Width = 85
      Height = 25
      Caption = 'Authenticate'
      TabOrder = 5
      OnClick = btnAuthenticateClick
    end
    object btnGetUserInfo: TButton
      Left = 505
      Top = 30
      Width = 85
      Height = 25
      Caption = 'Get User Info'
      TabOrder = 4
      OnClick = btnGetUserInfoClick
    end
    object chkbxShowPassword: TCheckBox
      Left = 396
      Top = 34
      Width = 97
      Height = 17
      Caption = 'Show Password'
      TabOrder = 3
      OnClick = chkbxShowPasswordClick
    end
  end
  object pnlBtnsLog: TPanel
    Left = 0
    Top = 628
    Width = 792
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 3
    object btnCopyLog: TButton
      AlignWithMargins = True
      Left = 8
      Top = 5
      Width = 75
      Height = 31
      Hint = 'Copy Log To Clipboard'
      Margins.Left = 8
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alLeft
      Caption = 'Copy'
      TabOrder = 0
      OnClick = btnCopyLogClick
    end
    object btnClearLog: TButton
      AlignWithMargins = True
      Left = 88
      Top = 5
      Width = 75
      Height = 31
      Hint = 'Clear Log'
      Margins.Left = 0
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alLeft
      Caption = 'Clear'
      TabOrder = 1
      OnClick = btnClearLogClick
    end
  end
  object PopupMenu: TPopupMenu
    Left = 472
    Top = 320
    object Copy1: TMenuItem
      Action = EditCopy1
    end
    object SelectAll1: TMenuItem
      Action = EditSelectAll1
    end
  end
  object ActionList: TActionList
    Left = 400
    Top = 320
    object EditCopy1: TEditCopy
      Category = 'Edit'
      Caption = '&Copy'
      Hint = 'Copy|Copies the selection and puts it on the Clipboard'
      ImageIndex = 1
      ShortCut = 16451
    end
    object EditSelectAll1: TEditSelectAll
      Category = 'Edit'
      Caption = 'Select &All'
      Hint = 'Select All|Selects the entire document'
      ShortCut = 16449
    end
  end
end
