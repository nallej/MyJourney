@echo off
echo\
echo I am logged on as: %UserName%.
echo My computer's name is %ComputerName%.
echo My IP settings:
ipconfig | find "." | find /i /v "suffix"
echo\
echo Press [Space bar] to close
pause > nul
