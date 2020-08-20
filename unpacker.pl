#!/usr/bin/perl -w

# ============= FROM UNPACKER.C ====================
# This source code is part of the AIS BlackToolkit.
# Unpacker.c allows you to build a NMEA sentece out of its payload. Normally used in combination with AIVDM_Encoder.
 
# Copyright 2013-2014 -- Embyte & Pastus

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# ==================================================

# This is a Perl version of the C code in the AIS BlackToolkit distribution
# (c) Gary C. Kessler, 2018
# Version -- 09/06/2018 (v0.1)

# Usage example: 
#   $ ./AIVDM_Encoder.py --type=1 --vsize=30x10 | xargs -IX ./unpacker.pl X 1 A

# The command above:
#  1) Runs AIVDM_encoder with whatever parameters and creates a binary string output
#  2) xargs takes the binary string and assigns it to "X"
#  3) Run unpacker with three arguments:
#      X is the binary string output from AIVDM_Encoder
#      1 is the enable_nmea value (1 = ON, else OFF)
#      A is the AIS channel (should be either A or B)

# Parse command line

if (parsecommandline ())
  { exit 1; };

$strlen = length ($in_string);

# Error checking. Ensure that string is a multiple of 6 bits and composed of 0s and 1s; NMEA value is 0 or 1; and
# Channel is A or B

if ($strlen % 6 != 0)
  {
  print "Input length not an even multiple of 6...\n";
  exit;
  }

for ($i=0; $i<$strlen; $i++)
  {
  $tyui = substr ($in_string, $i, 1);
  if ($tyui ne "0" && $tyui ne "1")
    {
    print "Input contains non-binary value... $tyui\n";
    exit;
    }
  }

if ($enable_nmea ne "0" && $enable_nmea ne "1")
  {
  print "Enable NMEA value not 0 or 1... $enable_nmea\n";
  exit;
  }

if ($channel ne "A" && $channel ne "B")
  {
  print "Channel must be A or B... $channel\n";
  exit;
  }


print "NMEA value: $enable_nmea Channel: $channel\n";
print "Input: $in_string\n";
print "Armored ASCII: ";

# Manipulate $in_string from binary to the NMEA 6-bit "armored" ASCII

for ($i=0; $i<$strlen/6; $i++)
  {

# One character = 6 bits, so get the 6-bit block

  $in_buffer [$i] = substr ($in_string, $i*6, 6);

# Convert the 6 binary bits to an integer value

  $in_buffer [$i] = convert ($in_buffer [$i], 6);

#  Now convert the value to an ASCII character

  if ($in_buffer [$i] > 39)
    { $in_buffer [$i] += 8; }
  $in_buffer [$i] += 48;

  $in_buffer [$i] = chr ($in_buffer [$i]);

  print $in_buffer [$i];
  }

print "\n\n";

# Prepare AIS Message
#  If enable_nmea = 1, then prepare NMEA header
#  Next part is the ASCII string
#  If enable_nmea=1, add compute and add checksum

$AIS_message = "";

if ($enable_nmea == 1)
  { $AIS_message = "!AIVDM,1,1,," . $channel . ","; }

for ($i=0; $i<$strlen/6; $i++)
  { $AIS_message = $AIS_message . $in_buffer [$i]; }

if ($enable_nmea == 1)
  {
  $AIS_message = $AIS_message . ",0";
  $checksum = nmea_checksum ($AIS_message);
  $AIS_message = $AIS_message . "*" . $checksum;
  }

print "AIS Message: $AIS_message\n\n";


# ********************************************************
# *****           SUBROUTINE BLOCKS                  *****
# ********************************************************

# ********************************************************
# nmea_checksum
# ********************************************************

sub nmea_checksum

# The NMEA checksum is computed on the entire sentence including the AIVDM/AIVDO tag but excluding the leading "!"
# The checksum is merely a bybe-by-byte XOR of the sentence

{
my ($sentence, $char, $i, $n, $len, $sum);

$sentence = $_[0];
$len = length ($sentence);
$sum = 0;

if (substr ($sentence,0,1) eq "!")
    { $n = 1; }
  else
    { $n = 0; }

for ($i=$n; $i<$len; $i++)
  { $sum ^= ord (substr ($sentence,$i,1)); }

# Ensure that $sum is two upper-case hex digits

  $sum = sprintf ("%02X", $sum);
  return $sum;
}

# ********************************************************
# convert
# ********************************************************

sub convert
{
my ($j, $sum);
my ($str, $n);

$str = $_[0]; $n = $_[1];
$sum=0;

for ($j=0; $j<$n; $j++)
  { 
  if (substr ($str,$j,1) == 1) { $sum += 2 ** ($n-$j-1); }
  }

return $sum;
}

# ********************************************************
# help_text
# ********************************************************

# Display the help file

sub help_text
{
print<< "EOT";
Program usage: unpacker S N C

 where: S is the input string (an even multiple of 6 bits in length
          composed of 0s and 1s)
        N is 1 to output an NMEA sentence or 0
        C is the broadcast channel (A or B)
EOT
return;
}

# ********************************************************
# parsecommandline
# ********************************************************

# Parse command line for file name, if present. Query
# user for any missing information

# Return $state = 1 to indicate that the program should stop
# immediately (switch -h)

sub parsecommandline
{
my $state = 0;

# Parse command line switches ($ARGV array of length $#ARGV)

if ($#ARGV == 2)
    {
    $in_string = $ARGV[0];
    $enable_nmea = $ARGV[1];
    $channel = $ARGV[2];
    }
  else
    {
    help_text();
    $state = 1;
    }

return $state;
}



