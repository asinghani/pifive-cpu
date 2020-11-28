INCLUDE build/platform.ld
OUTPUT_ARCH("riscv")

SECTIONS
{
  /* Start of instruction addr space */
  . = PLATFORM_ADDR_IMEM; 
  .text : { *(.start); *(.text.init); *(.text) }
  _text_end = .;
  /*ASSERT ((_text_end >= PLATFORM_ADDR_IMEM_TOP), "Error: instruction section too small");*/
  /* Start of data addr space */
  . = PLATFORM_ADDR_DMEM; 
  .data : { *(.data) }
  .bss : { *(.bss) }
  _data_end = .;
  /*ASSERT ((_data_end >= PLATFORM_ADDR_DMEM_TOP), "Error: data section too small");*/
  _end = .;
}

