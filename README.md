# DXMTS_MutationBat

Requirement : 
https://github.com/palworld-save-pal/uesave-rs ( fork of https://github.com/trumank/uesave-rs updated with DXMTS fix )

Instalation :
PowerShell:
Invoke-WebRequest https://win.rustup.rs/x86_64 -OutFile rustup-init.exe
Start-Process .\rustup-init.exe -Wait

check with:
rustc --version
cargo --version

then:
cargo install --git https://github.com/palworld-save-pal/uesave-rs uesave_cli --force -v


Use :

Use in game save folder, will update the most recent save and create a new save on slot 10.
