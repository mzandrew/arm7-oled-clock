# copyright 2007 mza (Matthew Andrew)
# started 2007-09-19 (talk like a pirate day)

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA
# or visit http://www.fsf.org/

assembler = arm-elf-as
c_compiler = arm-elf-gcc
elf_to_hex = arm-elf-objcopy
linker = arm-elf-ld

#objects := $(patsubst %.c,%.o,$(wildcard *.c))
# this list needs to have the assembly object with the interrupt vector table first
all_object_files_that_need_to_be_generated := work/exception-handler-vector-table.o \
	$(patsubst src/%.armasm,work/%.o,$(wildcard src/*.armasm)) \
	$(patsubst src/%.s,work/%.o,$(wildcard src/*.s)) \
	$(patsubst src/%.c,work/%.o,$(wildcard src/*.c))

# -a is for a listing output
# -k is to generate position independent code
# -mapcs-32 is for 32 bit addressing mode (instead of 26 bit)
# --fatal-warnings turns warnings into errors
assembly_flags = -ahlms -mcpu=arm7tdmi -mapcs-32 -k -Isrc/ -L
#--fatal-warnings

# -Winline warns if you declared an inline function and in any instance, it didn't get inlined
c_warnings = -Winline
# -fno-common "allocates even uninitialized global variables in the data section of the object file"
c_compiler_flags = -S -O0 $(c_warnings) -fno-common

linker_flags = -T scripts/linker-script.flash -Map work/arm7-oled-clock.map
#linker_flags = -T scripts/linker-script.sram-above-sam-ba-boot -Map work/arm7-oled-clock.map

elf_to_hex_flags = --output-target=ihex

list_of_assembly_language_files = $(list src/*.armasm) $(list src/*.s)
list_of_c_language_files = $(list src/*.c)

default :
	$(MAKE) -B all
	make program
	sleep 1
	make dump

all :
	@if [ ! -d "src" ]; then mkdir "src"; fi
	@if [ ! -d "work" ]; then mkdir "work"; fi
#	$(foreach each,$(list_of_assembly_language_files),$(MAKE) $(each:src/%.s=work/%.o);)
#	$(foreach each,$(list_of_c_language_files),$(MAKE) $(each:src/%.c=work/%.o);)
	$(MAKE) work/test.armasm
#	$(MAKE) work/interrupt-vector-table.o
	$(MAKE) work/arm7-oled-clock.hex
#	$(MAKE) work/test.hex
	@echo
	@echo "all targets up to date"
	@echo

dependencies = src/arm7-oled-clock.armasm, src/arm7-oled-clock.bss, src/arm7-oled-clock.data, src/arm7-oled-clock.equates, src/arm7-oled-clock.functions, src/arm7-oled-clock.macros, src/at91sam7s.equates, src/exception-handler-vector-table.armasm, src/font.functions, src/font.lookup-table, src/generic.equates, src/generic.macros, src/initialization.macros, src/io-pin.functions, src/io-pin.macros, src/math.functions, src/math.macros, src/oled-display.equates, src/oled-display.functions, src/oled-display.macros, src/spi-rtc.functions, src/test.c

work/%.o : src/%.armasm $(dependencies) ;
	$(assembler) $(assembly_flags) -a=$(@:work/%.o=work/%.listing) $< -o $@
	@echo "assembly stage complete"
	@echo

work/%.o : src/%.s ;
	$(assembler) $(assembly_flags) -a=$(@:work/%.o=work/%.listing)  $< -o $@
	@echo "assembly stage complete"
	@echo

work/%.o : work/%.armasm ;
	$(assembler) $(assembly_flags) -a=$(@:work/%.o=work/%.listing)  $< -o $@
	@echo "assembly stage complete"
	@echo

work/%.armasm : src/%.c ;
	$(c_compiler) $(c_compiler_flags) $< -o $@
	@echo "compiler stage complete"
	@echo

#work/blink-led.elf : work/blink-led.o work/test.o ;
#	$(linker) $(linker_flags) $< -o $@

work/arm7-oled-clock.elf : $(all_object_files_that_need_to_be_generated) ;
	$(linker) $(linker_flags) $^ -o $@
	@echo "linking stage complete"
	@echo

work/%.hex : work/%.elf ;
	$(elf_to_hex) $(elf_to_hex_flags) $< $@
	@echo "conversion to .hex stage complete"
	@echo

program : work/arm7-oled-clock.hex ;
	openocd --file=scripts/at91sam7s64-digilent-jtag3-upload-to-flash.openocd-config 

dump : ;
	openocd --file=scripts/at91sam7s64-digilent-jtag3-dump-ram-contents.openocd-config 

jtag : ;
	openocd --file=scripts/at91sam7s64-digilent-jtag3.openocd-config 2>/dev/null &
	sleep 1
	echo "use the shutdown command to kill the server and the telnet session"
	sleep 1
	telnet localhost 4444

nm : ;
	arm-elf-nm work/arm7-oled-clock.elf

