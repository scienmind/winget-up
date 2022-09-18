@echo off
set location="%cd%\run-winget-up.bat"
cmd /V /C "set "run_as_admin=-Verb RunAs" && %location%"
