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

set /p start_of_designs=<.\Constants\NUM_OF_START.txt && set /p num_of_designs=<.\Constants\NUM_OF_DESIGNS.txt 
SET /A "index_1=%start_of_designs%+1"
SET /A "index_2=%start_of_designs%+2"
SET /A "count=%num_of_designs%-1"

SET p=".\Designs\design_"
SET ext=\xsim

:while 
if %count% geq 0 (
	
	if exist %p%%index_1%%ext% (cd %p%%index_1%%ext% && start top_function.sh && SET /A "index_1+=2")
	SET /A "count-=1"
	
	if exist %p%%index_2%%ext% (cd %p%%index_2%%ext% && start /wait top_function.sh && SET /A "index_2+=2")
	SET /A "count-=1"

	goto :while
)

if exist %p%%start_of_designs%%ext% (cd %p%%start_of_designs%%ext% && start /wait top_function.sh) && cd ..\..\..