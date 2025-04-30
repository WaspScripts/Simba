unit simba.import_datetime;

{$i simba.inc}

interface

uses
  Classes, SysUtils,
  simba.base, simba.script;

procedure ImportDateTime(Script: TSimbaScript);

implementation

uses
  DateUtils,
  lptypes,
  simba.datetime, simba.nativeinterface;

(*
DateTime
========
TDateTime type and timing methods.

The TDateTime is stored as a double with the integer part representing days and the fractional part being fraction of a day.

```
var
  d: TDateTime;

begin
  d := TDateTime.CreateFromSystem();
  WriteLn('The system date & time is: ', d.ToString());

  d := d.AddDays(1);
  WriteLn('Tomorrow at this moment it will be: ', d.ToString);

  // Create the date of 3rd of jan 2000 with time 8am
  d := TDateTime.Create(2000,1,2,3, 8,0,0,0);
  WriteLn('Year=', d.Year);
  WriteLn('Month=', d.Month);
  WriteLn('Day=', d.Day);
  WriteLn('Hour=', d.hour);

  // Change the year to 2020
  d.Year := 2020;

  WriteLn('Date: ', d.ToString('dd mm yyyy'));
  WriteLn('Time: ', d.ToString('hh ss'));
end;
```
*)

(*
TDateTime.Create
----------------
```
function TDateTime.Create(Year,Month,Week,Day: Integer; Hour,Min,Sec,MSec: Integer): TDateTime; static;
```
Create a TDateTime from scratch.
*)
procedure _LapeDateTime_Create(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Result)^ := TDateTime.Create(PInteger(Params^[0])^, PInteger(Params^[1])^, PInteger(Params^[2])^, PInteger(Params^[3])^, PInteger(Params^[4])^, PInteger(Params^[5])^,PInteger(Params^[6])^, PInteger(Params^[7])^);
end;

(*
TDateTime.Create
----------------
```
function TDateTime.CreateFromSystem(): TDateTime; static;
```
Creates from the current system time.
*)
procedure _LapeDateTime_CreateFromSystem(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Result)^ := TDateTime.CreateFromSystem();
end;

(*
TDateTime.CreateFromUnix
------------------------
```
function TDateTime.CreateFromUnix(): TDateTime; static;
```
Create from current unix timestamp.
*)
procedure _LapeDateTime_CreateFromUnix(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Result)^ := TDateTime.CreateFromUnix();
end;

(*
TDateTime.CreateFromISO
-----------------------
```
function TDateTime.CreateFromISO(Value: String): TDateTime; static;
```
Create from ISO 8601 string `YYYYMMDDThhmmss` and `YYYY-MM-DD hh:mm:ss` format

Examples:
 - `2022-08-30T13:45:38+0000`
 - `2022-08-30T13:45:38`
 - `20220830 134538`
*)
procedure _LapeDateTime_CreateFromISO(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Result)^ := TDateTime.CreateFromISO(PString(Params^[0])^);
end;

(*
TDateTime.ToUnix
----------------
```
function TDateTime.ToUnix(IsUTC: Boolean = True): Int64;
```

Convert to unix time. `IsUTC` determines if `Self` is already UTC otherwise it will need to be converted.
*)
procedure _LapeDateTime_ToUnix(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PInt64(Result)^ := PDateTime(Params^[0])^.ToUnix(PBoolean(Params^[1])^);
end;

(*
TDateTime.ToISO
---------------
```
function TDateTime.ToISO(IsUTC: Boolean = True): String;
```

Convert to ISO 8601 string. `IsUTC` determines if `Self` is already UTC otherwise it will need to be converted.
*)
procedure _LapeDateTime_ToISO(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PString(Result)^ := PDateTime(Params^[0])^.ToISO(PBoolean(Params^[1])^);
end;

(*
TDateTime.ToString
------------------
```
function TDateTime.ToString(Fmt: String = 'c'): String;
```
Convert to a human like string.
If fmt is unspecified `c` is used which will produce `YYYY-MM-DD hh:mm:ss`

```{code-block} text
  y      = Year last 2 digits
  yy     = Year last 2 digits
  yyyy   = Year as 4 digits
  m      = Month number no-leading 0
  mm     = Month number as 2 digits
  mmm    = Month using ShortDayNames (Jan)
  mmmm   = Month using LongDayNames (January)
  d      = Day number no-leading 0
  dd     = Day number as 2 digits
  ddd    = Day using ShortDayNames (Sun)
  dddd   = Day using LongDayNames  (Sunday)
  ddddd  = Day in ShortDateFormat
  dddddd = Day in LongDateFormat

  c     = Use ShortDateFormat + LongTimeFormat
  h     = Hour number no-leading 0
  hh    = Hour number as 2 digits
  n     = Minute number no-leading 0
  nn    = Minute number as 2 digits
  s     = Second number no-leading 0
  ss    = Second number as 2 digits
  z     = Milli-sec number no-leading 0s
  zzz   = Milli-sec number as 3 digits
  t     = Use ShortTimeFormat
  tt    = Use LongTimeFormat

  am/pm = use 12 hour clock and display am and pm accordingly
  a/p   = use 12 hour clock and display a and p accordingly

  /     = insert date separator
  :     = insert time separator
  "xx"  = literal text
  'xx'  = literal text
  [h]   = hours including the hours of the full days (i.e. can be > 24).
  [hh]  = hours with leading zero, including the hours of the full days (i.e. can be > 24)
  [n]   = minutes including the minutes of the full hours and days
  [nn]  = minutes with leading zero, including the minutes of the full hours and days
  [s]   = seconds including the seconds of the full minutes, hours and days.
  [ss]  = seconds with leading zero, including the seconds of the full minutes, hours and days.
```
*)
procedure _LapeDateTime_ToString(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PString(Result)^ := PDateTime(Params^[0])^.ToString(PString(Params^[1])^);
end;

(*
TDateTime.AddYears
------------------
```
function TDateTime.AddYears(Amount: Integer = 1): TDateTime;
```
*)
procedure _LapeDateTime_AddYears(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Result)^ := PDateTime(Params^[0])^.AddYears(PInteger(Params^[1])^);
end;

(*
TDateTime.AddMonths
-------------------
```
function TDateTime.AddMonths(Amount: Integer = 1): TDateTime;
```
*)
procedure _LapeDateTime_AddMonths(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Result)^ := PDateTime(Params^[0])^.AddMonths(PInteger(Params^[1])^);
end;

(*
TDateTime.AddDays
-----------------
```
function TDateTime.AddDays(Amount: Integer = 1): TDateTime;
```
*)
procedure _LapeDateTime_AddDays(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Result)^ := PDateTime(Params^[0])^.AddDays(PInteger(Params^[1])^);
end;

(*
TDateTime.AddHours
------------------
```
function TDateTime.AddHours(Amount: Int64 = 1): TDateTime;
```
*)
procedure _LapeDateTime_AddHours(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Result)^ := PDateTime(Params^[0])^.AddHours(PInteger(Params^[1])^);
end;

(*
TDateTime.AddMinutes
--------------------
```
function TDateTime.AddMinutes(Amount: Int64 = 1): TDateTime;
```
*)
procedure _LapeDateTime_AddMinutes(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Result)^ := PDateTime(Params^[0])^.AddMinutes(PInteger(Params^[1])^);
end;

(*
TDateTime.AddSeconds
--------------------
```
function TDateTime.AddSeconds(Amount: Int64 = 1): TDateTime;
```
*)
procedure _LapeDateTime_AddSeconds(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Result)^ := PDateTime(Params^[0])^.AddSeconds(PInteger(Params^[1])^);
end;

(*
TDateTime.AddMilliseconds
-------------------------
```
function TDateTime.AddMilliseconds(Amount: Int64 = 1): TDateTime;
```
*)
procedure _LapeDateTime_AddMilliseconds(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Result)^ := PDateTime(Params^[0])^.AddMilliseconds(PInteger(Params^[1])^);
end;

(*
TDateTime.YearsBetween
----------------------
```
function TDateTime.YearsBetween(Other: TDateTime): Integer;
```
*)
procedure _LapeDateTime_YearsBetween(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PInteger(Result)^ := PDateTime(Params^[0])^.YearsBetween(PDateTime(Params^[1])^);
end;

(*
TDateTime.MonthsBetween
-----------------------
```
function TDateTime.MonthsBetween(Other: TDateTime): Integer;
```
*)
procedure _LapeDateTime_MonthsBetween(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PInteger(Result)^ := PDateTime(Params^[0])^.MonthsBetween(PDateTime(Params^[1])^);
end;

(*
TDateTime.WeeksBetween
----------------------
```
function TDateTime.WeeksBetween(Other: TDateTime): Integer;
```
*)
procedure _LapeDateTime_WeeksBetween(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PInteger(Result)^ := PDateTime(Params^[0])^.WeeksBetween(PDateTime(Params^[1])^);
end;

(*
TDateTime.DaysBetween
---------------------
```
function TDateTime.DaysBetween(Other: TDateTime): Integer;
```
*)
procedure _LapeDateTime_DaysBetween(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PInteger(Result)^ := PDateTime(Params^[0])^.DaysBetween(PDateTime(Params^[1])^);
end;

(*
TDateTime.HoursBetween
----------------------
```
function TDateTime.HoursBetween(Other: TDateTime): Int64;
```
*)
procedure _LapeDateTime_HoursBetween(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PInt64(Result)^ := PDateTime(Params^[0])^.HoursBetween(PDateTime(Params^[1])^);
end;

(*
TDateTime.MinutesBetween
------------------------
```
function TDateTime.MinutesBetween(Other: TDateTime): Int64;
```
*)
procedure _LapeDateTime_MinutesBetween(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PInt64(Result)^ := PDateTime(Params^[0])^.MinutesBetween(PDateTime(Params^[1])^);
end;

(*
TDateTime.SecondsBetween
------------------------
```
function TDateTime.SecondsBetween(Other: TDateTime): Int64;
```
*)
procedure _LapeDateTime_SecondsBetween(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PInt64(Result)^ := PDateTime(Params^[0])^.SecondsBetween(PDateTime(Params^[1])^);
end;

(*
TDateTime.MilliSecondsBetween
-----------------------------
```
function TDateTime.MilliSecondsBetween(Other: TDateTime): Int64;
```
*)
procedure _LapeDateTime_MilliSecondsBetween(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PInt64(Result)^ := PDateTime(Params^[0])^.MilliSecondsBetween(PDateTime(Params^[1])^);
end;

(*
TDateTime.Date
--------------
```
property TDateTime.Date: TDateTime
property TDateTime.Date(NewValue: TDateTime)
```

Read or write just the date part.
*)
procedure _LapeDateTime_Date_Read(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Result)^ := PDateTime(Params^[0])^.Date;
end;

procedure _LapeDateTime_Date_Write(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Params^[0])^.Date := PDateTime(Params^[1])^;
end;

(*
TDateTime.Time
--------------
```
property TDateTime.Time: TDateTime
property TDateTime.Time(NewValue: TDateTime)
```

Read or write just the time part.
*)
procedure _LapeDateTime_Time_Read(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Result)^ := PDateTime(Params^[0])^.Time;
end;

procedure _LapeDateTime_Time_Write(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Params^[0])^.Time := PDateTime(Params^[1])^;
end;

(*
TDateTime.Year
--------------
```
property TDateTime.Year: Integer
property TDateTime.Year(NewValue: Integer)
```
*)
procedure _LapeDateTime_Year_Read(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PInteger(Result)^ := PDateTime(Params^[0])^.Year;
end;

procedure _LapeDateTime_Year_Write(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Params^[0])^.Year := PInteger(Params^[1])^;
end;

(*
TDateTime.Month
--------------
```
property TDateTime.Month: Integer
property TDateTime.Month(NewValue: Integer)
```
*)
procedure _LapeDateTime_Month_Read(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PInteger(Result)^ := PDateTime(Params^[0])^.Month;
end;

procedure _LapeDateTime_Month_Write(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Params^[0])^.Month := PInteger(Params^[1])^;
end;

(*
TDateTime.Day
--------------
```
property TDateTime.Day: Integer
property TDateTime.Day(NewValue: Integer)
```
*)
procedure _LapeDateTime_Day_Read(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PInteger(Result)^ := PDateTime(Params^[0])^.Day;
end;

procedure _LapeDateTime_Day_Write(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Params^[0])^.Day := PInteger(Params^[1])^;
end;

(*
TDateTime.Hour
--------------
```
property TDateTime.Hour: Integer
property TDateTime.Hour(NewValue: Integer)
```
*)
procedure _LapeDateTime_Hour_Read(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PInteger(Result)^ := PDateTime(Params^[0])^.Hour;
end;

procedure _LapeDateTime_Hour_Write(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Params^[0])^.Hour := PInteger(Params^[1])^;
end;

(*
TDateTime.Minute
----------------
```
property TDateTime.Minute: Integer
property TDateTime.Minute(NewValue: Integer)
```
*)
procedure _LapeDateTime_Minute_Read(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PInteger(Result)^ := PDateTime(Params^[0])^.Minute;
end;

procedure _LapeDateTime_Minute_Write(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Params^[0])^.Minute := PInteger(Params^[1])^;
end;

(*
TDateTime.Second
----------------
```
property TDateTime.Second: Integer
property TDateTime.Second(NewValue: Integer)
```
*)
procedure _LapeDateTime_Second_Read(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PInteger(Result)^ := PDateTime(Params^[0])^.Second;
end;

procedure _LapeDateTime_Second_Write(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Params^[0])^.Second := PInteger(Params^[1])^;
end;

(*
TDateTime.Millisecond
---------------------
```
property TDateTime.Millisecond: Integer
property TDateTime.Millisecond(NewValue: Integer)
```
*)
procedure _LapeDateTime_Millisecond_Read(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PInteger(Result)^ := PDateTime(Params^[0])^.Millisecond;
end;

procedure _LapeDateTime_Millisecond_Write(const Params: PParamArray); LAPE_WRAPPER_CALLING_CONV
begin
  PDateTime(Params^[0])^.Millisecond := PInteger(Params^[1])^;
end;

(*
TDateTime.SystemTimeOffset
--------------------------
```
function TDateTime.SystemTimeOffset: Integer; static;
```
Returns the systems timezone offset in minutes. This is the difference between UTC time and local time.
*)
procedure _LapeDateTime_SystemTimeOffset(const Params: PParamArray; const Result: Pointer); LAPE_WRAPPER_CALLING_CONV
begin
  PInteger(Result)^ := GetLocalTimeOffset();
end;

procedure ImportDateTime(Script: TSimbaScript);
begin
  with Script.Compiler do
  begin
    DumpSection := 'DateTime';

    addGlobalFunc('function TDateTime.Create(Year,Month,Week,Day: Integer; Hour,Min,Sec,MSec: Integer): TDateTime; static;', @_LapeDateTime_Create);
    addGlobalFunc('function TDateTime.CreateFromSystem: TDateTime; static;', @_LapeDateTime_CreateFromSystem);
    addGlobalFunc('function TDateTime.CreateFromUnix: TDateTime; static;', @_LapeDateTime_CreateFromUnix);
    addGlobalFunc('function TDateTime.CreateFromISO(Value: String): TDateTime; static; overload;', @_LapeDateTime_CreateFromISO);

    addGlobalFunc('function TDateTime.SystemTimeOffset: Integer; static', @_LapeDateTime_SystemTimeOffset);

    addGlobalFunc('function TDateTime.ToUnix(IsUTC: Boolean = True): Int64', @_LapeDateTime_ToUnix);
    addGlobalFunc('function TDateTime.ToISO(IsUTC: Boolean = True): String', @_LapeDateTime_ToISO);
    addGlobalFunc('function TDateTime.ToString(Fmt: String = "c"): String', @_LapeDateTime_ToString);

    addGlobalFunc('function TDateTime.AddYears(Amount: Integer = 1): TDateTime;', @_LapeDateTime_AddYears);
    addGlobalFunc('function TDateTime.AddMonths(Amount: Integer = 1): TDateTime;', @_LapeDateTime_AddMonths);
    addGlobalFunc('function TDateTime.AddDays(Amount: Integer = 1): TDateTime;', @_LapeDateTime_AddDays);
    addGlobalFunc('function TDateTime.AddHours(Amount: Int64 = 1): TDateTime;', @_LapeDateTime_AddHours);
    addGlobalFunc('function TDateTime.AddMinutes(Amount: Int64 = 1): TDateTime;', @_LapeDateTime_AddMinutes);
    addGlobalFunc('function TDateTime.AddSeconds(Amount: Int64 = 1): TDateTime;', @_LapeDateTime_AddSeconds);
    addGlobalFunc('function TDateTime.AddMilliseconds(Amount: Int64 = 1): TDateTime;', @_LapeDateTime_AddMilliseconds);

    addGlobalFunc('function TDateTime.YearsBetween(Other: TDateTime): Integer;', @_LapeDateTime_YearsBetween);
    addGlobalFunc('function TDateTime.MonthsBetween(Other: TDateTime): Integer;', @_LapeDateTime_MonthsBetween);
    addGlobalFunc('function TDateTime.WeeksBetween(Other: TDateTime): Integer;', @_LapeDateTime_WeeksBetween);
    addGlobalFunc('function TDateTime.DaysBetween(Other: TDateTime): Integer;', @_LapeDateTime_DaysBetween);
    addGlobalFunc('function TDateTime.HoursBetween(Other: TDateTime): Int64;', @_LapeDateTime_HoursBetween);
    addGlobalFunc('function TDateTime.MinutesBetween(Other: TDateTime): Int64;', @_LapeDateTime_MinutesBetween);
    addGlobalFunc('function TDateTime.SecondsBetween(Other: TDateTime): Int64;', @_LapeDateTime_SecondsBetween);
    addGlobalFunc('function TDateTime.MilliSecondsBetween(Other: TDateTime): Int64;', @_LapeDateTime_MilliSecondsBetween);

    addProperty('TDateTime', 'Date', 'TDateTime', @_LapeDateTime_Date_Read, @_LapeDateTime_Date_Write);
    addProperty('TDateTime', 'Time', 'TDateTime', @_LapeDateTime_Time_Read, @_LapeDateTime_Time_Write);
    addProperty('TDateTime', 'Year', 'Integer', @_LapeDateTime_Year_Read, @_LapeDateTime_Year_Write);
    addProperty('TDateTime', 'Month', 'Integer', @_LapeDateTime_Month_Read, @_LapeDateTime_Month_Write);
    addProperty('TDateTime', 'Day', 'Integer', @_LapeDateTime_Day_Read, @_LapeDateTime_Day_Write);
    addProperty('TDateTime', 'Hour', 'Integer', @_LapeDateTime_Hour_Read, @_LapeDateTime_Hour_Write);
    addProperty('TDateTime', 'Minute', 'Integer', @_LapeDateTime_Minute_Read, @_LapeDateTime_Minute_Write);
    addProperty('TDateTime', 'Second', 'Integer', @_LapeDateTime_Second_Read, @_LapeDateTime_Second_Write);
    addProperty('TDateTime', 'Millisecond', 'Integer', @_LapeDateTime_Millisecond_Read, @_LapeDateTime_Millisecond_Write);

    DumpSection := '';
  end;
end;

end.

