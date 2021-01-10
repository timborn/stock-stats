REM  *****  BASIC  *****

Sub Main

End Sub

function stock(ticker as string, datum as string)
  ' MsgBox("stock(ticker=" & ticker & ", datum=" & datum & ")"
  'mylookup = "hello world"
  dim document as object
  document = ThisComponent
  ' TODO: offer to make missing tabs
  if not document.Sheets.hasByName(ticker) then
    position = 0	' insert on the far left
    document.sheets.insertNewByName(ticker, position)
    populateSheet( ticker )
    ' MsgBox("The tab for " & ticker & " is missing.")
    ' stock = "no ticker found"
    exit function
  end if
  sheet = document.Sheets.getByName(ticker)
  row = 0 
  col = 0
  ' getCellByPosition(col, row)
  ' document.sheets("my macros").getCellByPosition(0, 22).String = "DEBUG"

  do while row <= 12
    do while col <= 10
    ' document.sheets("my macros").getCellByPosition(0, 22).String = "" & row & "," & col  ' DEBUG

      if sheet.getCellByPosition(col,row).String = datum then
        col = col + 1
        ' sometimes we want the number (value), sometimes the string
        stock = sheet.getCellByPosition(col,row).String
        exit function
      end if
      col = col + 2
    loop
    col = 0
    row = row + 1
  loop
  stock = "not found"

end function

' to populate sheets for each of the aristocrats, put your cursor
' in this subroutine and hit the run button
sub generateArisocrats
  ' _ underscore is the line continuation char in this version of BASIC
  names() = Array("ABBV", "ABM", "ABT", "ADM", "ADP", "AFL", _
            "ALB", "AMCR", "AOS", "APD", "ATO", "AWR", "BDX", _
            "BEN", "BF-B", "CAH", "CARR", "CAT", "CB", "CBSH", _
            "CL", "CLX", "CINF", "CTAS", "CVS", "CVX", "CWT", _
            "DOV", "ECL", "ED", "EMR", "EPD", "ESS", "EXPD", _
            "FRT", "FUL", "GD", "GPC", "GWW", "HRL", "ITW", _
            "JNJ", "KMB", "KO", "LANC", "LEG", "LIN", "LOW", _
            "MCD", "MCK", "MDT", "MMM", "MO", "NDSN", "NFG", _
            "NUE", "NWN", "O", "OTIS", "PBCT", "PEP", "PG", _
            "PH", "PNR", "PPG", "ROP", "RTX", "SCL", "SHW", _
            "SJW", "SPGI", "SWK", "SYY", "T", "TGT", "TR", _
            "TROW", "UVV", "VFC", "WBA", "WMT", "XOM")

  For n = lbound(names()) To ubound(names())
    sheets = ThisComponent.Sheets
    exists = sheets.hasByName( names(n) )
    if not exists then
      position = 999	' insert on the far right
      sheets.insertNewByName(names(n), position)
      ' populate each sheet
      ' sheet = document.Sheets.getByName(names(n))
      ' getCellByPosition(0, 0).String = names(n)
      ' getCellByPosition(0, 1).setFormula()   
      populateSheet( names(n) ) 
    end if
  next n
end sub


sub populateSheet(ticker as string)

  dim document   as object
  dim dispatcher as object
  document   = ThisComponent.CurrentController.Frame
  dispatcher = createUnoService("com.sun.star.frame.DispatchHelper")

  ' must get focus on correct sheet
  sheets = ThisComponent.Sheets
  sheet = sheets.getByName(ticker)
  sheet.getCellByPosition(0, 0).String = ticker
  ' must make this sheet the focus!
  ' getByName works for some commands, but as soon as we switch to 
  ' the uno stuff, it will scribble in some other sheet, so this
  ' is how we make the sheet active for uno
  Controller = ThisComponent.getcurrentController
  Controller.setActiveSheet(sheet)	' make active

      
rem ----------------------------------------------------------------------
'dim args1(0) as new com.sun.star.beans.PropertyValue
'args1(0).Name = "ToPoint"
'args1(0).Value = "$A$1"

'dispatcher.executeDispatch(document, ".uno:GoToCell", "", 0, args1())

rem ----------------------------------------------------------------------
'dim args2(0) as new com.sun.star.beans.PropertyValue
'args2(0).Name = "StringName"
'args2(0).Value = ticker

'dispatcher.executeDispatch(document, ".uno:EnterString", "", 0, args2())

rem ----------------------------------------------------------------------
' dispatcher.executeDispatch(document, ".uno:JumpToNextCell", "", 0, Array())
' all this just to put focus on cell A2
dim args1(0) as new com.sun.star.beans.PropertyValue
args1(0).Name = "ToPoint"
args1(0).Value = "$A$2"
dispatcher.executeDispatch(document, ".uno:GoToCell", "", 0, args1())

rem ----------------------------------------------------------------------
dim args4(3) as new com.sun.star.beans.PropertyValue
args4(0).Name = "FileName"
args4(0).Value = "https://finviz.com/quote.ashx?t=" & ticker
args4(1).Name = "FilterName"
args4(1).Value = "calc_HTML_WebQuery"
args4(2).Name = "Options"
args4(2).Value = "0 0"
args4(3).Name = "Source"
args4(3).Value = "HTML_8"

dispatcher.executeDispatch(document, ".uno:InsertExternalDataSource", "", 0, args4())

rem ----------------------------------------------------------------------
rem dispatcher.executeDispatch(document, ".uno:InsertExternalDataSource", "", 0, Array())


end sub
