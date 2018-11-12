ml /c main.asm
ml /c 32.asm
ml /c 4.asm
link16 main.obj 32.obj 4.obj;
cd ..
start C:\"Program Files (x86)"\DOSBox-0.74\DOSBox.exe t.txt
cd 3lab