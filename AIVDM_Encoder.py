#!/usr/bin/env python
#
# This script is part of the AIS BlackToolkit.
# AIVDM_Encoder.py allows you to generate arbitrary AIVDM payloads. The main AIS message types are supported.
#
# Copyright 2013-2014 -- Embyte & Pastus
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# Usage examples:
# $ ./AIVDM_Encoder.py --type=1 --vsize=30x10 | xargs -IA ./unpacker A 1 A
# $ ./AIVDM_Encoder.py --type=1 --vsize=30x10 | xargs -IX ./AiS_TX.py --payload=X --channel=A
#

import sys

# Adapted from gpsd-3.9's driver_ais.c
def encode_string(string):
	vocabolary = "@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^- !\"#$%&'()*+,-./0123456789:;<=>?"
	encoded_string = ""
	for c in string.upper():
		index = vocabolary.find(c)
		encoded_string += '{0:b}'.format(index).rjust(6,'0')
	return encoded_string

# NB. We add a mask to tell python how long is our rapresentation (overwise on negative integers, it cannot do the complement 2).
def compute_long_lat (__long, __lat):
	_long = '{0:b}'.format(int(round(__long*600000)) & 0b1111111111111111111111111111).rjust(28,'0')
	_lat =  '{0:b}'.format(int(round(__lat*600000))  & 0b111111111111111111111111111).rjust(27,'0')
	return (_long, _lat)

def compute_long_lat22 (__long, __lat):
	_long = '{0:b}'.format(int(round(__long*600)) & 0b111111111111111111).rjust(18,'0')
	_lat =  '{0:b}'.format(int(round(__lat*600))  & 0b11111111111111111).rjust(17,'0')
	return (_long, _lat)

def encode_1(__mmsi, __speed, __long, __lat, __course, __ts):
	_type = '{0:b}'.format(1).rjust(6,'0')				# 18
	_repeat = "00"										# repeat (directive to an AIS transceiver that this message should be rebroadcast.)
	_mmsi = '{0:b}'.format(__mmsi).rjust(30,'0')		# 30 bits (247320162)
	_status = '{0:b}'.format(15).rjust(4,'0')			# status not defined
	_rot = '{0:b}'.format(128).rjust(8,'0')				# rate of turn not defined

	_speed = '{0:b}'.format(int(round(__speed*10))).rjust(10,'0')	# Speed over ground is in 0.1-knot resolution from 0 to 102 knots. value 1023 indicates speed is not available, value 1022 indicates 102.2 knots or higher.
	_accurancy = '0'									# > 10m

	(_long, _lat) = compute_long_lat(__long, __lat)

	_course = '{0:b}'.format(int(round(__course*10))).rjust(12,'0')	# 0.1 resolution. Course over ground will be 3600 (0xE10) if that data is not available.
	_true_heading = '1'*9	# 511 (N/A)
	_ts = '{0:b}'.format(__ts).rjust(6,'0') # Second of UTC timestamp.

	_flags = '0'*6
	# '00': manufactor NaN
	# '000':  spare
	# '0': Raim flag

	_rstatus = '0'*19 # ??
	# '11100000000000000110' : Radio status

	return _type+_repeat+_mmsi+_status+_rot+_speed+_accurancy+_long+_lat+_course+_true_heading+_ts+_flags+_rstatus


def encode_4(__mmsi, __speed, __long, __lat, __course, __ts):
	_type = '{0:b}'.format(4).rjust(6,'0')				# 18
	_repeat = "00"										# repeat (directive to an AIS transceiver that this message should be rebroadcast.)
	_mmsi = '{0:b}'.format(__mmsi).rjust(30,'0')		# 30 bits (247320162)

	_hour = '{0:b}'.format(24).rjust(5,'0')
	_min = _sec = '{0:b}'.format(60).rjust(6,'0')


	_accurancy = '1'									# <= 10m
	(_long, _lat) = compute_long_lat(__long, __lat)

	_device = '0001'	# GPS
	_flags = '0'*12
	# '0': transmission control for packet 24
	# '000000000':  spare
	# '0': Raim flag

	_rstatus = '0'*19 # ??
	# '11100000000000000110' : Radio status

	return _type+_repeat+_mmsi+'0'*23+_hour+_min+_sec+_accurancy+_long+_lat+_device+'0'*11+_rstatus

def encode_14(__mmsi, __msg):
	_type = '{0:b}'.format(14).rjust(6,'0')				# 14
	_repeat = "00"										# repeat (directive to an AIS transceiver that this message should be rebroadcast.)
	_mmsi = '{0:b}'.format(__mmsi).rjust(30,'0')		# 30 bits (247320162)
	_spare = "00"										# spare bit
	_msg = encode_string(__msg)
#	_padding = '0'*(168-6-2-30-2-len(_msg))
	return _type+_repeat+_mmsi+_spare+_msg


def encode_18(__mmsi, __speed, __long, __lat, __course, __ts):
	_type = '{0:b}'.format(18).rjust(6,'0')				# 18
	_repeat = "00"										# repeat (directive to an AIS transceiver that this message should be rebroadcast.)
	_mmsi = '{0:b}'.format(__mmsi).rjust(30,'0')		# 30 bits (247320162)
	_reserved = '0'*8
	_speed = '{0:b}'.format(int(round(__speed*10))).rjust(10,'0')	# Speed over ground is in 0.1-knot resolution from 0 to 102 knots. value 1023 indicates speed is not available, value 1022 indicates 102.2 knots or higher.
	_accurancy = '0'									# > 10m

	(_long, _lat) = compute_long_lat(__long, __lat)

	_course = '{0:b}'.format(int(round(__course*10))).rjust(12,'0')	# 0.1 resolution. Course over ground will be 3600 (0xE10) if that data is not available.
	_true_heading = '1'*9	# 511 (N/A)
	_ts = '{0:b}'.format(__ts).rjust(6,'0') # Second of UTC timestamp.

	_flags = '001011100'
	# '00': Regional reserved
	# '1':  CS mode (carrier sense Class B)
	# '0' Display flag
	# '1': DSC
	# '1': Band Flag
	# '1': M22 Flag
	# '0': Assigned 0 -> Autonomous mode
	# '0': Raim flag

	_rstatus = '11100000000000000110' # ??
	# '11100000000000000110' : Radio status

	return _type+_repeat+_mmsi+_reserved+_speed+_accurancy+_long+_lat+_course+_true_heading+_ts+_flags+_rstatus

def encode_20(__mmsi, __offset, __slots, __timeout, __increment):
	_type = '{0:b}'.format(20).rjust(6,'0')				#
	_repeat = '00'										# repeat (count of how many times this msg has been repeated)
	_mmsi = '{0:b}'.format(__mmsi).rjust(30,'0')		# 30 bits (247320162)

	_offset = '{0:b}'.format(__offset).rjust(12,'0')
	_slots =  '{0:b}'.format(__slots).rjust(4,'0')
	_timeout = '{0:b}'.format(__timeout).rjust(3,'0')
	_increment = '{0:b}'.format(__increment).rjust(11,'0')

	return 	_type+_repeat+_mmsi+'00'+_offset+_slots+_timeout+_increment+'00'

def encode_21(__mmsi, __aid_type, __aid_name, __long, __lat, __vsize, __virtual):
	_type = '{0:b}'.format(21).rjust(6,'0')
	_repeat = '00'										# repeat (directive to an AIS transceiver that this message should be rebroadcast.)
	_mmsi = '{0:b}'.format(__mmsi).rjust(30,'0')		# 30 bits (247320162)

	_aid_type = '{0:b}'.format(__aid_type).rjust(5,'0')
	if len(__aid_name) <= 20:
		_name = encode_string(__aid_name).rjust(120,'0')
		_name_ext = ''
	else:
		__aid_name = str.strip(__aid_name,'@')
		if len(__aid_name) <= 20:
			_name = encode_string(__aid_name).rjust(120,'0')
			_name_ext = ''
		else:
			_name = encode_string(__aid_name[:20])
			_name_ext =  encode_string(__aid_name[20:])
			_name_ext += ''.rjust(len(_name_ext) % 8, '0')
			print _name_ext

	_accurancy = '0'

	(_long, _lat) = compute_long_lat(__long, __lat)

	if not __virtual:
		_hl = int(__vsize[:__vsize.find("x")])/2		# AIS antenna in the middle
		_hw = int(__vsize[__vsize.find("x")+1:])/2
		_half_length = '{0:b}'.format(_hl).rjust(9,'0')
		_half_width = '{0:b}'.format(_hw).rjust(6,'0')
	else:
		_half_length = '000000000'
		_half_width = '000000'

	_fix = '0000'
	_time = '{0:b}'.format(60).rjust(6,'0')
	_virtual = '{0:b}'.format(int(__virtual))

	return _type + _repeat + _mmsi + _aid_type + _name + _accurancy + _long + _lat + _half_length + _half_length + _half_width + _half_width + _fix + _time + '1000000000' + _virtual + '00' + _name_ext


def encode_22(__mmsi, __channel_a, __channel_b, __ne_lon, __ne_lat, __sw_lon, __sw_lat):
	_type = '{0:b}'.format(22).rjust(6,'0')				#
	_repeat = '00'										# repeat (directive to an AIS transceiver that this message should be rebroadcast.)
	_mmsi = '{0:b}'.format(__mmsi).rjust(30,'0')		# 30 bits (247320162)

	_channel_a = '{0:b}'.format(__channel_a).rjust(12,'0')	# 2087
	_channel_b = '{0:b}'.format(__channel_b).rjust(12,'0')	# 2088

	_txrxmode = '0'*4	#'{0:b}'.format(__channel_b).rjust(4,'0')	# 0,1,2 (1 e 2 disable one tx)
	_power = '0'	# high ('1' = low)

	(_ne_lon, _ne_lat) = compute_long_lat22(__ne_lon, __ne_lat)
	(_sw_lon, _sw_lat) = compute_long_lat22(__sw_lon, __sw_lat)

	_zonesize = '{0:b}'.format(4).rjust(3,'0')	# default

	return 	_type+_repeat+_mmsi+'00'+_channel_a+_channel_b+_txrxmode+_power+_ne_lon+_ne_lat+_sw_lon+_sw_lat+'000'+_zonesize+'0'*23


def encode_23(__mmsi, __ne_lon, __ne_lat, __sw_lon, __sw_lat, __interval_time, __quiet_time):
	_type = '{0:b}'.format(23).rjust(6,'0')				#
	_repeat = '00'										# repeat (directive to an AIS transceiver that this message should be rebroadcast.)
	_mmsi = '{0:b}'.format(__mmsi).rjust(30,'0')		# 30 bits (247320162)

	(_ne_lon, _ne_lat) = compute_long_lat22(__ne_lon, __ne_lat)
	(_sw_lon, _sw_lat) = compute_long_lat22(__sw_lon, __sw_lat)

	_station_type = '0000'	# Target all stations (class A, B, ...)
	_ship_type = '0'*8		# Target all ships/cargos

	_txrxmode = '0'*2	#'{0:b}'.format(__channel_b).rjust(4,'0')	# 0,1,2 (1 e 2 disable one tx) - NB: 2bits in message 23, 4bits in message 22

	_interval = '{0:b}'.format(__interval_time).rjust(4,'0')
	_quiet = '{0:b}'.format(__quiet_time).rjust(4,'0')

	return 	_type+_repeat+_mmsi+'00'+_ne_lon+_ne_lat+_sw_lon+_sw_lat+_station_type+_ship_type+'0'*22+_txrxmode+_interval+_quiet+'0'*6



def encode_24(__mmsi, __part, __vname="NAN", __callsign="NAN", __vsize="90x14", __vtype=60):
	_type = '{0:b}'.format(24).rjust(6,'0')				# 24
	_repeat = "00"										# repeat (directive to an AIS transceiver that this message should be rebroadcast.)
	_mmsi = '{0:b}'.format(__mmsi).rjust(30,'0')		# 30 bits (247320162)
	if __part == "A":
		_part = "00"
		_vname = encode_string(__vname)
		_padding = '0'*(156-6-2-30-2-len(_vname))		# 160 bits per RFC -> 4 bits padding added in Build_Frame_imple.cc
		return _type+_repeat+_mmsi+_part+_vname+_padding

	else:
		_part = "01"
		_vtype = '{0:b}'.format(__vtype).rjust(8,'0')   # 60 = passengers
		_vendorID = "0"*42								# vendor ID

		_tmp = encode_string(__callsign)
		_callsign = _tmp + "0"*(42-len(_tmp))			# 7 six-bit characters

		_hl=int(__vsize[:__vsize.find("x")])/2		# AIS antenna in the middle of the boat
		_hw=int(__vsize[__vsize.find("x")+1:])/2
		_half_length='{0:b}'.format(_hl).rjust(9,'0')
		_half_width='{0:b}'.format(_hw).rjust(6,'0')

		return _type+_repeat+_mmsi+_part+_vtype+_vendorID+_callsign+_half_length+_half_length+_half_width+_half_width+"000000"



def main():
	from optparse import OptionParser

	desc="""Use this tool to generate the binary payload of an AIVDM sentence."""

	parser = OptionParser(description=desc)

	parser.add_option("--type",   help="""Type:
												1  = Position Report Class A;
												4 = Base Station Report;
												14 = Safety-Related Broadcast Message;
												18 = Standard Class B CS Position Report;
												20 = Data Link Management Message (ref. RFC);
												21 = Aid-to-Navigation Report;
												22 = Channel Management;
												23 = Group Assignment Command;
												24 = Static Data Report)""")

	parser.add_option("--sart_msg",help="14. SART alarm message, default = SART ACTIVE", default="SART ACTIVE")

	parser.add_option("--mmsi",   help="""MMSI, default = 247320162.
	                                                970010000 for SART device""",
	                                                default=247320162)
	parser.add_option("--speed",  help="18. Speed (knot), default = 0.1", default=0.1)
	parser.add_option("--long",   help="18. Longitude, default = 9.72357833333333", default=9.72357833333333)
	parser.add_option("--lat",    help="18. Latitude, default = 45.6910166666667", default=45.6910166666667)
	parser.add_option("--course", help="18. Course, default = 83.4", default=83.4)
	parser.add_option("--ts",     help="18. Timestamp (sec), default = 38", default=38)
	parser.add_option("--fatdmaoffset",     help="20. Offset, default = 0", default=0)
	parser.add_option("--fatdmaslots",      help="20. Slot, default = 0", default=0)
	parser.add_option("--fatdmatimeout",    help="20. Timeout, default = 0", default=0)
	parser.add_option("--fatdmaincrement",  help="20. Increment, default = 0", default=0)

	parser.add_option("--v_AtoN",help="21. Specify that the AtoN is virtual, default = real.", action="store_true")
	parser.add_option("--aid_type", help="21. Type of AtoN (light, bouye)", default=0)
	parser.add_option("--aid_name", help="21. Name of AtoN", default="@@@@@@@@@@@@@@@@@@@@")

	parser.add_option("--channel_a", help="22. Specify channel frequency for A, default = 2087 (87B = 161.975 MHz). Ref ITU-R M.1084", default=2087)
	parser.add_option("--channel_b", help="22. Specify channel frequency for B, default = 2088 (88B = 162.025 MHz). Ref ITU-R M.1084", default=2088)
	parser.add_option("--ne_lon", help="22/23. Specify NE corner's longitude of rectangular jurisdiction area, default = 9.9", default=9.9)
	parser.add_option("--ne_lat", help="22/23. Specify NE corner's latitude  of rectangular jurisdiction area, default = 45.8", default=45.8)
	parser.add_option("--sw_lon", help="22/23. Specify SW corner's longitude of rectangular jurisdiction area, default = 9.5", default=9.5)
	parser.add_option("--sw_lat", help="22/23. Specify SW corner's latitude  of rectangular jurisdiction area, default = 45.5", default=45.5)

	parser.add_option("--interval", help="23. Commands the respective stations to the reporting interval, default = 1 (10 minutes)", default=1)
	parser.add_option("--quiet", help="23. Force the respective stations to quiet interval, default = 15 minutes)", default=15)

	parser.add_option("--part",   help="24. Message part (A/B), default = A", default="A")
	parser.add_option("--vname",  help="24A. Vessel Name (UPPER CASE), default = NaN", default="NAN")
	parser.add_option("--callsign", help="24B. Call Sign (UPPER CASE, max 7 chars.), default = KC9CAF", default="KC9CAF")
	parser.add_option("--vtype", help="""24B. Type of ship and cargo type: 60 Passenger, 70 Cargo, 80 Tanker, 3x Special, 5x Carrying dangerous goods, harmful substances or marine pollutants:
									- 35 Engaged in military operations ;-)
									- 51 Search and rescue vessels
									- 55 Law enforcement vessels
									""", default=60)
	parser.add_option("--vsize",   help="24B/21. Vessel Size (multiple of 2), default = 90x14", default="90x14")


	(options, args) = parser.parse_args()
	if not options.type:
		parser.error("Sentence type not specified: -h for help.")

	payload = ""

	if options.type == "1":
		payload = encode_1(int(options.mmsi), float(options.speed), float(options.long), float(options.lat), float(options.course), int(options.ts))

	elif options.type == "4":
		payload = encode_4(int(options.mmsi), float(options.speed), float(options.long), float(options.lat), float(options.course), int(options.ts))

	elif options.type == "14":
		payload = encode_14(int(options.mmsi), options.sart_msg)

	elif options.type == "20":
		payload = encode_20(int(options.mmsi), int(options.fatdmaoffset), int(options.fatdmaslots), int(options.fatdmatimeout), int(options.fatdmaincrement))

	elif options.type == "18":
		payload = encode_18(int(options.mmsi), float(options.speed), float(options.long), float(options.lat), float(options.course), int(options.ts))

	elif options.type == "21":
		if options.v_AtoN == True: __virtual = '1'
		else: __virtual = '0'
		payload = encode_21(int(options.mmsi), int(options.aid_type), options.aid_name, float(options.long), float(options.lat), options.vsize, __virtual)

	elif options.type == "22":
		payload = encode_22(int(options.mmsi), int(options.channel_a), int(options.channel_b), float(options.ne_lon), float(options.ne_lat), float(options.sw_lon), float(options.sw_lat))

	elif options.type == "23":
			payload = encode_23(int(options.mmsi), float(options.ne_lon), float(options.ne_lat), float(options.sw_lon), float(options.sw_lat), int(options.interval), int(options.quiet))

	elif options.type == "24":
		if options.part=="A":
			payload = encode_24(int(options.mmsi), "A", __vname=options.vname.upper())
		else:
			payload = encode_24(int(options.mmsi), "B", __callsign=options.callsign.upper(), __vsize=options.vsize, __vtype=int(options.vtype))

	else:
		parser.error("Sentence type not supported: -h for help.")

	print payload


if __name__ == "__main__":
    main()
