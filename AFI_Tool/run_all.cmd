@echo off

rem Display GNU General Public License notice
echo This program is free software: you can redistribute it and/or modify
echo it under the terms of the GNU General Public License as published by
echo the Free Software Foundation, either version 3 of the License, or
echo (at your option) any later version.
echo.
echo This program is distributed in the hope that it will be useful,
echo but WITHOUT ANY WARRANTY; without even the implied warranty of
echo MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
echo GNU General Public License for more details.
echo.
echo You should have received a copy of the GNU General Public License
echo along with this program.  If not, see https://www.gnu.org/licenses/.
echo.

timeout 60

set log_file=log_file.txt
set log_time=%DATE% %TIME%


echo 1 > .\Constants\MODE.txt

echo run_all.cmd started at: %log_time% >> %log_file%

SET afi_root="C:\MyWork\AFI_Tool" && cd %afi_root% && vivado -mode tcl -source vivado_script.tcl && timeout 60 && batch_mode.cmd && matlab -nosplash -nodesktop -r "run ('fault_evaluation.m'); quit"



echo 2 > .\Constants\MODE.txt

echo run_all.cmd started at: %log_time% >> %log_file%

SET afi_root="C:\MyWork\AFI_Tool" && cd %afi_root% && vivado -mode tcl -source vivado_script.tcl && timeout 60 && batch_mode.cmd && matlab -nosplash -nodesktop -r "run ('fault_evaluation.m'); quit"




echo 3 > .\Constants\MODE.txt

echo run_all.cmd started at: %log_time% >> %log_file%

SET afi_root="C:\MyWork\AFI_Tool" && cd %afi_root% && vivado -mode tcl -source vivado_script.tcl && timeout 60 && batch_mode.cmd && matlab -nosplash -nodesktop -r "run ('fault_evaluation.m'); quit"




echo 4 > .\Constants\MODE.txt

echo run_all.cmd started at: %log_time% >> %log_file%

SET afi_root="C:\MyWork\AFI_Tool" && cd %afi_root% && vivado -mode tcl -source vivado_script.tcl && timeout 60 && batch_mode.cmd && matlab -nosplash -nodesktop -r "run ('fault_evaluation.m'); quit"




echo 5 > .\Constants\MODE.txt

echo run_all.cmd started at: %log_time% >> %log_file%

SET afi_root="C:\MyWork\AFI_Tool" && cd %afi_root% && vivado -mode tcl -source vivado_script.tcl && timeout 60 && batch_mode.cmd && matlab -nosplash -nodesktop -r "run ('fault_evaluation.m'); quit" && exit