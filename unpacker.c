/*

This source code is part of the AIS BlackToolkit.
Unpacker.c allows you to build a NMEA sentece out of its payload. Normally used in combination with AIVDM_Encoder.
 
Copyright 2013-2014 -- Embyte & Pastus

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

Usage example: 
$ ./AIVDM_Encoder.py --type=1 --vsize=30x10 | xargs -IA ./unpacker A 1 A

*/


#include <sstream>
#include <ctype.h>
#include <stdio.h>
#include <iostream>
#include <iomanip>
#include <string.h>

unsigned long unpack(char *buffer, int start, int length)
{
    unsigned long ret = 0;
    for(int i = start; i < (start+length); i++) {
	ret <<= 1;
	ret |= (buffer[i] & 0x01);
    }
    return ret;
}

char nmea_checksum(std::string buffer)
{
    unsigned int i = 0;
    char sum = 0x00;
    if(buffer[0] == '!') i++;
    for(; i < buffer.length(); i++) sum ^= buffer[i];
    return sum;
}


int main(int argc, char *argv[]) {


	if (argc<4) {
		std::cout << "\nUsage: ./unpacker binary_string enable_nmea channel\n";
		std::cout << "\nenable_nmea = 1 for full NMEA sentence, otherwise only payload is printed\n";
		std::cout << "channel = A/B\n\n";
		return 0; 
	}

	int i;
	char asciidata[255];

	int len = strlen(argv[1]);
	
	int enable_nmea = (int) *argv[2] - 48;
	char channel = *argv[3];
	std::ostringstream d_payload;
	d_payload.str("");
	
	for(i = 0; i < len/6; i++) {
		asciidata[i] = unpack(argv[1], i*6, 6);
		if(asciidata[i] > 39) asciidata[i] += 8;
			asciidata[i] += 48;
	}

	if (enable_nmea)
	    d_payload << "!AIVDM,1,1,," << channel << ",";

    for(int i = 0; i < len/6; i++) 
    	d_payload << asciidata[i];
    
    if (enable_nmea) {
		d_payload << ",0"; //number of bits to fill out 6-bit boundary
		char checksum = nmea_checksum(std::string(d_payload.str()));
		d_payload << "*" << std::setw(2) << std::setfill('0') << std::hex << std::uppercase << int(checksum);
    }

	std::cout << std::string(d_payload.str()) << std::endl;	
	return 1;
}
