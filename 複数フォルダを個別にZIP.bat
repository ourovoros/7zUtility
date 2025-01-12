@echo off
set exe="C:\Program Files\7-Zip\7z.exe"
for %%f in (%*) do (
  %exe% a -tzip %%f.zip %%f
)
 
pause