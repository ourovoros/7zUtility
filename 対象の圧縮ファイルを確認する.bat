@echo off 
for /R %%i in (*) do  (
  if /I "%%~xi"==".zip" call :再圧縮 "%%i"
  if /I "%%~xi"==".lzh" call :再圧縮 "%%i"
  if /I "%%~xi"==".rar" call :再圧縮 "%%i"
)

PAUSE
goto :EOF

:再圧縮
echo %1
goto :EOF