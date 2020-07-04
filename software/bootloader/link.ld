OUTPUT_ARCH("riscv")

SECTIONS
{
  /* 0x1000_0000 is start of bootloader addr space */
  . = 0x10000000; 
  .text : { *(.start); *(.text.init); *(.text) }
  /* 0x4000_0000 is start of data addr space */
  . = 0x40000000; 
  .data : { *(.data) }
  .bss : { *(.bss) }
  _end = .;
}

