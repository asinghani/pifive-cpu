OUTPUT_ARCH("riscv")
ENTRY(_start)

SECTIONS
{
  /* 0x1000_0000 is start of bootloader addr space */
  . = 0x10000000; 
  .text.init : { *(.text.init) }
  .text : { *(.text) }
  /* 0x4000_0000 is start of data addr space */
  . = 0x40000000; 
  .data : { *(.data) }
  .bss : { *(.bss) }
  _end = .;
}

