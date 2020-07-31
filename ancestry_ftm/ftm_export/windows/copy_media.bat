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
bryan_nc ^
rollo_research ^
Sandys ^





set srcdir=C:\Users\vagrant\FTM_DOCUMENTS
set dstdir=\\VBOXSVR\shared\FTM_DOCUMENTS

pushd "%dstdir%"

(for %%g in (%gs%) do (
    del /f /q /s "%%g Media\*.*" > nul
    rmdir /q /s "%%g Media"
    xcopy "%srcdir%\%%g Media" "%%g Media" /f /i
))

popd
pause
