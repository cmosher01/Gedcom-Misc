echo on
rem copy FTM media directories

set gs= ^
root ^
Joseph ^
Colvin ^
Disosway ^
Flandreau ^
Harrison ^
Justice ^
Lopez ^
Lovejoy ^
McLaughlin ^
Mosher ^
Pettit ^
Romero ^
Spohner ^
Taylorson ^
Tutankhamun ^
rapp_kansas ^
Roth ^
Murray_Lougheed_Wilson_Vandever ^
rollo_research ^
Sandys ^





set srcdir=c:/Users/vagrant/Documents/Family Tree Maker
set dstdir=\\VBOXSVR\shared



pushd "%dstdir%"

rmdir ftm /s /q
mkdir ftm
cd ftm

(for %%g in (%gs%) do ( 
   xcopy "%srcdir%/%%g Media" "%%g Media" /f /i
))

popd
pause
