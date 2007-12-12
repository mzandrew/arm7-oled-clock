// copyright 2007 mza (Matthew Andrew)
// started 2007-09-19 (talk like a pirate day)

// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA
// or visit http://www.fsf.org/

//extern "ASM" {
//	extern void turn_on_led_func(void);
//}

void delay__c(long int count) {
//	int total=0;
	register int i;

	for (i=count; i>=0; i--) {
//		total += i;
	}
}

void nop__c(void) {

}

void turn_on_led_c(void) {
	turn_on_led__asm();
//	nop__c();
	delay__c(100);
//	turn_off_led__asm();
}

