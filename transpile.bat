REM TODO: create a .ts file that references all objects so every script gets called.
"C:\Program Files (x86)\Microsoft SDKs\TypeScript\1.7\tsc.exe" "C:\TfsData\Build\_work\b03e695e\FLUX\develop\Flux\flux.engine.src\utils\Queue.ts" -target ES5
"C:\Program Files (x86)\Microsoft SDKs\TypeScript\1.7\tsc.exe" "C:\TfsData\Build\_work\b03e695e\FLUX\develop\Jasmine\tests\flux.engine.src\utils\" -target ES5 

"C:\Utilities\packages\Chutzpah.4.2.1\tools\chutzpah.console.exe" "C:\TfsData\Build\_work\b03e695e\FLUX\develop\Jasmine\tests\flux.engine.src\utils\chutzpah.json" /debug