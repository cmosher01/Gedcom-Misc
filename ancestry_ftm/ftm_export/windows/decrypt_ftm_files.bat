echo on
rem decrypt FTM files

set gs= ^
root.ftm ^
Joseph.ftm ^
Colvin.ftm ^
Disosway.ftm ^
Flandreau.ftm ^
Harrison.ftm ^
Justice.ftm ^
Lopez.ftm ^
Lovejoy.ftm ^
McLaughlin.ftm ^
Mosher.ftm ^
Pettit.ftm ^
Romero.ftm ^
Spohner.ftm ^
Taylorson.ftm ^
Tutankhamun.ftm ^
rapp_kansas.ftm ^
Roth.ftm ^
Murray_Lougheed_Wilson_Vandever.ftm ^
rollo_research.ftm ^
Sandys.ftm ^




rem build this from db.cs:
set dbexe=\\VBOXSVR\shared\crack_ftm\db.exe

set srcdir=c:\Users\vagrant\Documents\Family Tree Maker
set dstdir=\\VBOXSVR\shared

pushd "%dstdir%"
rmdir ftm_decrypted /s /q
mkdir ftm_decrypted
popd



pushd "%dstdir%\ftm_decrypted"

for %%f in (%gs%) do (
    "%dbexe%" /d "%srcdir%\%%f"
)

dir /o

popd



pause
