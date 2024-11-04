# VGM2LNX

This is a fork which changes:
- Switch between standalone or normal version
- fix Xcode compile errors
- lower case exe name

Conversion tool for VGM files holding Lynx music to Lynx cartridge images with simple player.

## Compilation

Use CMake. Requires C++17

Pass -DSTANDALONE=1 to build vgm2lnx (direct executable). Else vgm2v2l will be build which only converts the VGM.

To recompile `vgmplay.asm` use [mads](https://github.com/tebe6502/Mad-Assembler) and [HAMLET](https://github.com/laoo/HAMLET) similarly to:

```
mads vgmplay.asm
HAMLET vgmplay.obx vgmplay.bin
xxd -i vgmplay.bin > vgmplay.h
```

## Usage
```
vga2lnx input.vgm [output.lnx]
```

or

```
vga2v2l input.vgm [output.v2l]
```

If output file is missing, input file is taken with replaced extension to .lnx

## Caveats
Tool does not check whether output file exceeds 512 kB. Generated image won't behave properly in such scenario.
