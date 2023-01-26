# VGM2LNX
Conversion tool for VGM files holding Lynx music to Lynx cartridge images with simple player.

## Compilation

Use CMake. Requires C++17

To recompile `vgmplay.asm` use [mads](https://github.com/tebe6502/Mad-Assembler) and [HAMLET](https://github.com/laoo/HAMLET) similarly to:

```
mads vgmplay.asm
HAMLET vgmplay.obx vgmplay.bin
xxd -i vgmplay.bin > vgmplay.h
```

## Usage
```
VGM2LNX input.vgm [output.lnx]
```
If output file is missing, input file is taken with replaced extension to .lnx

## Caveats
Tool does not check whether output file exceeds 512 kB. Generated image won't behave properly in such scenario.


