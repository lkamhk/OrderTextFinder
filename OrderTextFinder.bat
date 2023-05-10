@echo off
setlocal enabledelayedexpansion
chcp 65001> nul

title Order Text Finder
ECHO Prepare to Start
ECHO ^>Loading.
taskkill /F /FI "WINDOWTITLE eq temp*" /T > nul 
ping localhost -n 1 >nul
cls
ECHO Prepare to Start
ECHO ^>Loading..
for %%V IN (FO,IO,OO) DO (if exist "%%V.exe" del "%%V.exe" > nul)
ping localhost -n 1 >nul
cls
ECHO Prepare to Start
ECHO ^>Loading...
for %%P IN (FO,IO,OO) DO (FOR /F %%x IN ('tasklist /FI "IMAGENAME eq %%PNEW.exe"') DO (IF %%x == %%PNEW.exe taskkill /im "%%PNEW.exe" /t /f > nul))
for %%H IN (FO,IO,OO) DO (if exist "%%HNEW.exe" del "%%HNEW.exe" > nul)
ping localhost -n 1 >nul
cls
ECHO Prepare to Start
ECHO ^>Loading....

dir "%cd%\OrderLogFiles" /b /od /on >"%cd%\pexe\filelist.txt"
call :size "%cd%\pexe\filelist.txt"
if %size% equ 0 (ECHO Please check OrderLogFiles folder[empty]&echo ^>Terminate Now&PAUSE&&EXIT)
if exist "%cd%\pexe\filelist.txt" del "%cd%\pexe\filelist.txt" > nul
ping localhost -n 1 >nul
cls
ECHO Prepare to Start
ECHO ^>Loading.....
for %%M IN (FO,IO,OO) DO (FOR /F %%x IN ('tasklist /FI "IMAGENAME eq %%M.exe"') DO (IF %%x == %%M.exe taskkill /im "%%M.exe" /t /f > nul))
if exist "result.txt" del "result.txt" > nul
ping localhost -n 1 >nul
cls
ECHO Prepare to Start
ECHO ^>Loading.......
if exist "temp*.bat" del "temp*.bat" > nul
ping localhost -n 1 >nul
cls
ECHO Prepare to Start
ECHO ^>Loading.........
for %%B IN (FO,IO,OO) DO (if exist "%%B*.txt" del "%%B*.txt" > nul)

call :size orderID.txt
if %size% EQU 0 (ECHO Please check orderID file[empty]&echo ^>Terminate Now&PAUSE&&EXIT)




ECHO ^>OK
set /p tdate=Enter Date[yyyymmdd]:
set /a testdate=tdate

if defined tdate (ECHO Date Entered:%tdate%) else (ECHO Date can't be empty^>Terminate Now&PAUSE&&EXIT)

if !testdate! EQU 0 (
  if !tdate! LSS 20100000 (ECHO Wrong Input^>Terminate Now&PAUSE&&EXIT)
  if !tdate! NEQ 0  (ECHO Wrong Input^>Terminate Now&PAUSE&&EXIT)
) 

if !testdate! NEQ 0 (
  if !tdate! LSS 20100000 (ECHO Wrong Input^>Terminate Now&PAUSE&&EXIT)
)

call :getsize %tdate%


if %counts% LSS 8 (ECHO Wrong Input^>Terminate Now&PAUSE&&EXIT)

if %counts% GTR 8 (ECHO Wrong Input^>Terminate Now&PAUSE&&EXIT)

if %tdate% LSS 20100000 (ECHO Wrong Input^>Terminate Now&PAUSE&&EXIT)

set todaydate=%date:~9,5%%date:~6,2%%date:~3,2%
set /a td=%todaydate%

if %tdate% GTR %td% (ECHO Wrong Input^>Terminate Now&PAUSE&&EXIT)

set /p OT=Enter FO/IO/OO:

call :getsize2 %OT%


if defined OT (ECHO Order Text Type:%OT%) else (ECHO Input can't be empty^>Terminate Now&PAUSE&&EXIT)

if %counts2% LSS 2 (ECHO Input error^>Terminate Now&PAUSE&&EXIT)

if %counts2% GTR 2 (ECHO Input error^>Terminate Now&PAUSE&&EXIT)

SET /a countCheck=0

for %%B IN (FO,Fo,fo,fO,IO,Io,io,iO,OO,Oo,oo,oO) DO (if %OT% EQU %%B set /a countCheck+=1&&echo Match)

if %countCheck% EQU 0 echo Please input FO/IO/OO&&PAUSE&&Exit



ECHO. .....................Start.....................

dir "%cd%\OrderLogFiles\" /b /od /on >%cd%\pexe\filelist.txt

if %tdate% GEQ 20210403 set exechoicer=%OT%NEW

if %tdate% LSS 20210403 set exechoicer=%OT%

xcopy "%cd%\pexe\%exechoicer%.exe" "%cd%"> nul&&ECHO Copying %exechoicer%.exe Success

FOR  /F %%G IN (pexe\filelist.txt) DO (

xcopy "%cd%\OrderLogFiles\%%G" "%cd%"> nul&&ECHO Copying %%G Success

timeout /t 1 > nul 
ren "%%G" "%OT%.txt"&&ECHO Name as %OT%.txt Success
for /F %%r in (orderID.txt) DO (

set orderNum=%%r

echo title temp%%r>> "temp%%r.bat" 
timeout /t 1 > nul 

echo|set /p="(echo %tdate% && echo %%r)|%exechoicer%">> "temp%%r.bat"
timeout /t 1 > nul 

start /min "" "temp%%r.bat"

echo. -----------Waiting to be written in-------------


call :waitGenResult
timeout /t 1 > nul 
call :size result.txt
timeout /t 1 > nul 
call :checkGenResult


type result.txt>>result_%%r.txt&&ECHO Successful write to result_%%r.txt

call :checkResult %orderNum%

timeout /t 2 > nul 
taskkill /im %OT%NEW.exe /t /f > nul 
timeout /t 1 > nul 
taskkill /F /FI "WINDOWTITLE eq temp%%r*" /T > nul 
timeout /t 1 > nul 
del temp%%r.bat
timeout /t 1 > nul 
del result.txt


)
del %OT%.txt

)
CLS
if exist "%exechoicer%.exe" del "%exechoicer%.exe" 
timeout /t 1 > nul 
del "%cd%\pexe\filelist.txt"
echo. All complete. You can close now.
PAUSE


:getsize
set counts=0
for /l %%n in (0,1,2000) do (

    set chars=

    set chars=!tdate:~%%n!

    if defined chars set /a counts+=1
)
goto :eof

:getsize2
set counts2=0
for /l %%n in (0,1,2000) do (

    set chars=

    set chars=!OT:~%%n!

    if defined chars set /a counts2+=1
)
goto :eof

:size
set SIZE=%~z1
goto :eof

:waitGenResult
timeout /t 1
if exist "result.txt" (ECHO result.txt generated&&SET FILE3=result.txt&&goto :eof) Else (goto :waitGenResult)
goto :eof

:checkGenResult
timeout /t 1
if %SIZE% NEQ 0 (ECHO found result&&goto :eof)
FOR /F %%p IN ('DIR/B/O:D %FILE3%') DO (SET NEWEST1=%%p)
if %NEWEST1% EQU %FILE3% (goto :eof) Else (goto :checkGenResult)
goto :eof

:checkResult
timeout /t 1
SET FILE1=result.txt
SET FILE2=result_%orderNum%.txt
FOR /F %%i IN ('DIR/B/O:D %FILE1% %FILE2%') DO (SET NEWEST=%%i)
if %NEWEST% EQU %FILE2% (goto :eof) Else (goto :checkResult)
goto :eof


