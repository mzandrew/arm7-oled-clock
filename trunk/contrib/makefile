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

default:
	$(MAKE) ../work/test-image-32x32.armasm
#	$(MAKE) ../work/image.2007-10-10.s45-19667-cropped-small.armasm
	$(MAKE) ../work/image.2007-12-11.s50-00165-cropped-enhanced-2-small.armasm
#	../src/bmp-to-oled.perl test-image-32x32.bmp test-image-32x32.oled
#	../src/bin-to-asm.perl test-image-32x32.oled ../work/test-image-32x32.armasm

%.bmp : %.png ;
	convert $< $@

%.bmp : %.jpeg ;
	convert $< $@

%.oled : %.bmp ;
	../src/bmp-to-oled.perl $< $@

../work/%.armasm : %.oled ;
	../src/bin-to-asm.perl $< $@

