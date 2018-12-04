#!/usr/bin/perl

# Program AIVDM_pre

# This is a preprocessor for the AIS BlackToolkit. It is designed to provide a simple
# user interface allowing users to automatically generate comamnds for use with the
# AIVDM_Encoder.py program

# AIVDM_Encoder prepares an output string that can be used by the unpacker.pl (or unpacker.c)
# program or transmitted using AiS_TX. This program, then, can create either form of the
# command lines below:

# ./AIVDM_Encoder.py --type=1 --vsize=30x10 | xargs -IA ./unpacker.pl A 1 A
# ./AIVDM_Encoder.py --type=1 --vsize=30x10 | xargs -IX ./AiS_TX.py --payload=X --channel=A

# See also "AIVDM/AIVDO protocol decoding" page at http://catb.org/gpsd/AIVDM.html

# (c) Gary C. Kessler, 2018

$build_date = "09/09/2018";
$version = "0.9";

$type = menu ();

if ($type eq "X")
  {
  print "Goodbye!\n\n";
  exit;
  };

# Initialize command string output. All commands include the --type parameter

$command = "./AIVDM_Encoder.py --type=" . $type . " ";

# Step through the supported parameters and ask for values for those parameters supported by the
# requested message type; provide default value. If default selected, do not add to command string output

print "\nSee The 'AIVDM/AIVDO protocol decoding' page at http://catb.org/gpsd/AIVDM.html\n";
print "for additional information on selecting parameter values.\n";

#####
# All messages contain an MMSI.
# The Maritime Mobile Service Identity (MMSI) is a 9 decimal digit number
# NOTE: The Encoder default value is not a real ship but indicates an Italian vessel

do
  {
  print "\nEnter MMSI (9 decimal digits); Encoder default = 247320162 (vessel)\nor 970010000 (SART device): ";
  chomp ($mmsi = <STDIN>);
  }
  until (verify_numeric_string ($mmsi,9) || $mmsi eq "");

if ($mmsi ne "")
  { $command .= "--mmsi=" . $mmsi . " "; }

#####
# The SART_MSG parameter is used only in message type 14
# The Search and Rescue Transponder (SART) message can be from 1-161 characters in length

if ($type == 14)
  {
  do
    {
    print "\nEnter SART message (1-161 characters); Encoder default = 'SART ACTIVE':\n";
    chomp ($sart_msg = <STDIN>);
    }
    until (length ($sart_msg) <= 161); 

  if ($sart_msg ne "")
    { $command .= "--sart_msg='" . $sart_msg . "' "; }
  }

#####
# Position parameters (latitude, longitude) are used in message types 1, 4, & 18
# The Encoder default value is on Via Pizzo Formico near Piazza Madonna delle Nevi, Seriate, Bergamo, Italy

if ($type == 1 || $type == 4 || $type == 18)
  {
  do
    {
    print "\nEnter latitude (-90 to 90); Encoder default = 45.6910166666667: ";
    chomp ($lat = <STDIN>);
    }
    until (($lat >= -90 && $lat <= 90) || $lat eq ""); 

  if ($lat ne "")
    { $command .= "--lat='" . $lat . "' "; }

  do
    {
    print "\nEnter longitude (-180 to 180); Encoder default = 9.72357833333333: ";
    chomp ($long = <STDIN>);
    }
    until (($long >= -180 && $long <= 180) || $long eq ""); 

  if ($long ne "")
    { $command .= "--long='" . $long . "' "; }
  }

#####
# Course, speed, and timestamp parameters are used in message types 1 & 18

if ($type == 1 || $type == 18)
  {
  do
    {
    print "\nEnter speed, in knots in 0.1 kn resolution (0-102; 1022 = 102.2 kn or higher;\n1023 = speed not available); Encoder default = 0.1: ";
    chomp ($speed = <STDIN>);
    }
    until (($speed >= 0 && $speed <= 102) || $speed == 1022 || $speed == 1023 || $speed eq ""); 

  if ($speed ne "")
    { $command .= "--speed=" . $speed . " "; }

  do
    {
    print "\nEnter course (1 to 360; 3600 = data not available); Encoder default = 83.4: ";
    chomp ($course = <STDIN>);
    }
    until (($course >= 1 && $course <= 360) || $course == 3600 || $course eq ""); 

  if ($course ne "")
    { $command .= "--course=" . $course . " "; }

  do
    {
    print "\nEnter UTC timestamp, in seconds (0-59; 60 = time stamp not available;\n";
    print "61 = positioning system is in manual input mode;\n62 = positioning system operates in estimated (dead reckoning) mode,\n";
    print "63 = positioning system is inoperative); Encoder default = 38: ";
    chomp ($ts = <STDIN>);
    }
    until (($ts >= 0 && $ts <= 63) || $ts eq ""); 

  if ($ts ne "")
    { $command .= "--ts=" . int($ts+0.5) . " "; }
  }

#####
# Fixed Access Time Division Multiple Access (FATDMA) parameters are used in message type 20
# It has been difficult to get exact meaning and values, but I am allowing values based upon the field sizes.
# See also https://fccid.io/UYW-4230002/User-Manual/User-manual-2545256.html

if ($type == 20)
  {
  do
    {
    print "\nEnter FATDMA reserved offset number (0-4095); Encoder default = 0: ";
    chomp ($fatdmaoffset = <STDIN>);
    }
    until (($fatdmaoffset >= 0 && $fatdmaoffset <= 4095) || $fatdmaoffset eq ""); 

  if ($fatdmaoffset ne "")
    { $command .= "--fatdmaoffset=" . int($fatdmaoffset) . " "; }

  do
    {
    print "\nEnter FATDMA number of reserved slots (0-15); Encoder default = 0: ";
    chomp ($fatdmaslots = <STDIN>);
    }
    until (($fatdmaslots >= 0 && $fatdmaslots <= 15) || $fatdmaslots eq ""); 

  if ($fatdmaslots ne "")
    { $command .= "--fatdmaslots=" . int($fatdmaslots) . " "; }

  do
    {
    print "\nEnter FATDMA timeout, in minutes (0-7); Encoder default = 0: ";
    chomp ($fatdmatimeout = <STDIN>);
    }
    until (($fatdmatimeout >= 0 && $fatdmatimeout <= 7) || $fatdmatimeouts eq ""); 

  if ($fatdmatimeout ne "")
    { $command .= "--fatdmatimeout=" . int($fatdmatimeout) . " "; }

  do
    {
    print "\nEnter FATDMA repeat increment (0-2047); Encoder default = 0: ";
    chomp ($fatdmaincrement = <STDIN>);
    }
    until (($fatdmaincrement >= 0 && $fatdmaincrement <= 2047) || $fatdmaincrement eq ""); 

  if ($fatdmaincrement ne "")
    { $command .= "--fatdmaincrement=" . int($fatdmaincrement) . " "; }
  }

#####
# Aids-to-Navigation (AtoN) parameters are used in message 21.

if ($type == 21)
  {
  do
    {
    print "\nEnter 0 if this is a real AtoN at indicated position; 1 if this is a\nvirtual AtoN simulated by nearby AIS station; Encoder default = 0: ";
    chomp ($v_AtoN = <STDIN>);
    }
    until ($v_AtoN == 0 || $v_AtoN == 1 || $v_AtoN eq ""); 

  if ($v_AtoN)
    { $command .= "--v_AtoN" . " "; }

  do
    {
    print "\nEnter type of navigational aid (0-31) from the following list:\n";
    print "  0. AIS Default; type of AtoN not specified\n";
    print "  1. Reference point\n";
    print "  2. RACON (radar transponder marking a navigation hazard)\n";
    print "  3. Fixed structure off shore, such as oil platforms, wind farms, rigs.\n";
    print "  4. Spare, Reserved for future use     5. Light, without sectors\n";
    print "  6. Light, with sectors                7. Leading Light Front\n";
    print "  8. Leading Light Rear                 9. Beacon, Cardinal N\n";
    print " 10. Beacon, Cardinal E                11. Beacon, Cardinal S\n";
    print " 12. Beacon, Cardinal W                13. Beacon, Port hand\n";
    print " 14. Beacon, Starboard hand\n";
    print " 15. Beacon, Preferred Channel port hand\n";
    print " 16. Beacon, Preferred Channel starboard hand\n";
    print " 17. Beacon, Isolated danger           18. Beacon, Safe water\n";
    print " 19. Beacon, Special mark              20. Cardinal Mark N\n";
    print " 21. Cardinal Mark E                   22. Cardinal Mark S\n";
    print " 23. Cardinal Mark W                   24. Port hand Mark\n";
    print " 25. Starboard hand Mark               26. Preferred Channel Port hand\n";
    print " 27. Preferred Channel Starboard hand\n";
    print " 28. Isolated danger                   29. Safe Water\n";
    print " 30. Special Mark                      31. Light Vessel / LANBY / Rigs\n";
    print " Encoder default = 1: ";
    chomp ($aid_type = <STDIN>);
    }
    until (($aid_type >= 0 && $aid_type <= 31) || $aid_type eq ""); 

  if ($aid_type ne "")
    { $command .= "--aid_type=" . int($aid_type) . " "; }

  do
    {
    print "\nEnter AtoN name  (1-20 characters); Encoder default = '@@@@@@@@@@@@@@@@@@@@':\n";
    chomp ($aid_name = <STDIN>);
    $aid_name = uc($aid_name)
    }
    until (length ($aid_name) <= 20); 

  if ($aid_name ne "")
    { $command .= "--aid_name='" . $aid_name . "' "; }
  }

#####
# Channel management parameters apply only to message type 22
# These parameters specify the frequency for AIS channels A and B based upon the
# ITU frequency designators

if ($type == 22)
  {
  do
    {
    print "\nEnter AIS Channel A channel number, from ITU-R Rec. M.1084;\nEncoder default = 2087 (87B = 161.975 MHz): ";
    chomp ($channel_a = <STDIN>);
    }
    until ($channel_a >= 0 || $channel_a eq ""); 

  if ($channel_a ne "")
    { $command .= "--channel_a=" . int($channel_a) . " "; }

  do
    {
    print "\nEnter AIS Channel B channel number, from ITU-R Rec. M.1084;\nEncoder default = 2088 (88B = 162.025 MHz): ";
    chomp ($channel_b = <STDIN>);
    }
    until ($channel_b >= 0 || $channel_b eq ""); 

  if ($channel_b ne "")
    { $command .= "--channel_b=" . int($channel_b) . " "; }
  }

#####
# AIS coverage region parameters are used in message types 22 & 23
# These parameters define the rectagular AIS jurisdication area by specifying the northeast corner lat and long,
# and the southwest corner lat and long.

if ($type == 22 || $type == 23)
  {
  do
    {
    print "\nEnter northeast corner's latitude of AIS rectangular jurisdiction (-90 to 90);\nEncoder default = 45.8: ";
    chomp ($ne_lat = <STDIN>);
    }
    until (($ne_lat >= -90 && $ne_lat <= 90) || $ne_lat eq ""); 

  if ($ne_lat ne "")
    { $command .= "--ne_lat='" . $ne_lat . "' "; }

  do
    {
    print "\nEnter northeast corner's longitude (-180 to 180); Encoder default = 9.9: ";
    chomp ($ne_lon = <STDIN>);
    }
    until (($ne_lon >= -180 && $ne_lon <= 180) || $ne_lon eq ""); 

  if ($ne_lon ne "")
    { $command .= "--ne_lon='" . $ne_lon . "' "; }

  do
    {
    print "\nEnter southwest corner's latitude of AIS rectangular jurisdiction (-90 to 90);\nEncoder default = 45.5: ";
    chomp ($sw_lat = <STDIN>);
    }
    until (($sw_lat >= -90 && $sw_lat <= 90) || $sw_lat eq ""); 

  if ($sw_lat ne "")
    { $command .= "--sw_lat='" . $sw_lat . "' "; }

  do
    {
    print "\nEnter southwest corner's longitude (-180 to 180); Encoder default = 9.5: ";
    chomp ($sw_lon = <STDIN>);
    }
    until (($sw_lon >= -180 && $sw_lon <= 180) || $sw_lon eq ""); 

  if ($sw_lon ne "")
    { $command .= "--sw_lon='" . $sw_lon . "' "; }
  }

#####
# The report interval and quiet time parameters are only used in message type 23

if ($type == 23)
  {
  do
    {
    print "\nEnter station reporting interval (0-15) from the following list:\n";
    print "  0. As given by the autonomous mode     1. 10 Minutes\n";
    print "  2. 6 Minutes      3. 3 Minutes         4. 1 minute\n";
    print "  5. 30 seconds     6. 15 Seconds        7. 10 Seconds\n";
    print "  8. 5 Seconds      9. Next Shorter Reporting Interval\n";
    print " 10. Next Longer Reporting Interval\n";
    print " 11-15. Reserved for future use\n";
    print " Encoder default = 1: ";
    chomp ($interval = <STDIN>);
    }
    until (($interval >= 0 && $interval <= 15) || $interval eq ""); 

  if ($interval ne "")
    { $command .= "--interval=" . int($interval) . " "; }

do
    {
    print "\nEnter station quiet time, in minutes  (1-15; 0 = none); Encoder default = 15:\n";
    chomp ($quiet = <STDIN>);
    }
    until (($quiet >= 0 && $quiet <= 15) || $quiet eq ""); 

  if ($quiet ne "")
    { $command .= "--quiet=" . int($quiet) . " "; }
  }
   
#####
# Message type 24 has a Part A format and Part B format. First find the part...

if ($type == 24)
  {
  do
    {
    print "\nEnter Static Data Report part number (A or B); Encoder default = A: ";
    chomp ($part = <STDIN>);
    $part = uc($part);
    }
    until ($part eq "A" || $part eq "B" || $part eq ""); 

  $part24 = $part;
  if ($part eq "")
      { $part24 = "A"; }
    else
      { $command .= "--part=" . $part . " "; }
  }

#####
# Message type 24, Part A format...

if ($type == 24 && $part24 eq "A")
  {
  do
    {
    print "\nEnter vessel name  (1-20 characters); Encoder default = NaN:\n";
    chomp ($vname = <STDIN>);
    $vname = uc($vname)
    }
    until (length ($vname) <= 20); 

  if ($vname ne "")
    { $command .= "--vname='" . $vname . "' "; }
  }

#####
# Vessel callsign and type are part of message type 24, Part B format...

if ($type == 24 && $part24 eq "B")
  {
  do
    {
    print "\nEnter vessel call sign  (1-7 characters); Encoder default = KC9CAF:\n";
    chomp ($callsign = <STDIN>);
    $callsign = uc($callsign)
    }
    until (length ($callsign) <= 7); 

  if ($callsign ne "")
    { $command .= "--callsign=" . $callsign . " "; }
  }

  do
    {
    print "\nEnter vessel type (0-99) from the following list:\n";
    print "  0. Not available, AIS default    1-19. Reserved\n";
    print " 20-29. Wing in ground (WIG)\n";
    print " 30. Fishing                       31. Towing\n";
    print " 32. Towing: length exceeds 200m or breadth exceeds 25m\n";
    print " 33. Dredging or underwater ops    34. Diving ops\n";
    print " 35. Military ops                  36. Sailing\n";
    print " 37. Pleasure Craft                38-39. reserved\n";
    print " 40-49. High speed craft (HSC)     50. Pilot Vessel\n";
    print " 51. Search and Rescue vessel      52. Tug\n";
    print " 53. Port Tender                   54. Anti-pollution equipment\n";
    print " 55. Law Enforcement               56-57. spare\n";
    print " 58. Medical Transport             59. Noncombatant ship\n";
    print " 60-69. Passenger ship             70-79. Cargo\n";
    print " 80-89. Tanker                     90-99. Other ship type\n";
    print " Encoder default = 60: ";
    chomp ($vtype = <STDIN>);
    }
    until (($vtype >= 0 && $vtype <= 99) || $vtype eq ""); 

  if ($vtype ne "")
    { $command .= "--vtype=" . int($vtype) . " "; }

#####
# Vessel size are part of message type 21 or type 24, Part B format...

if ($type == 21 || ($type == 24 && $part24 eq "B"))
  {
  do
    {
    print "\nEnter vessel length, in meters (even number, 0-1022); Encoder default = 90:\n";
    chomp ($vsize_len = <STDIN>);
    $vsize_len = int($vsize_len);
    }
    until (($vsize_len >= 0 && $vsize_len <= 1022 & $vsize_len % 2 == 0) || $vsize_len eq "");

  do
    {
    print "\nEnter vessel beam, in meters (even number, 0-126); Encoder default = 14:\n";
    chomp ($vsize_beam = <STDIN>);
    $vsize_beam = int($vsize_beam);
    }
    until (($vsize_beam >= 0 && $vsize_beam <= 126 && $vsize_beam % 2 == 0) || $vsize_beam eq "");

  if ($vsize_len ne "" || $vsize_beam ne "")
    { $command .= "--vsize=" . $vsize_len . "x" . $vsize_beam . " "; }
  }

# Now get parameters for the final part of the command string to output
# First determine whether to output as a comamnd to run the Unpacker or for AiS_TX

do
  {
  print "\nSet command for unpacker (U) or AiS_TX (A) [default = U]: ";
  chomp ($out = <STDIN>);
  $out = uc ($out);
  }
  until ($out eq "U" || $out eq "A" || $out eq "");
if ($out eq "") { $out = "U"; }

# If directing string to the Unpacker, indicate whether we want to create a complete NMEA sentence

if ($out eq "U")
  {
  do
    {
    print "\nCreate NMEA sentance? (Y/N) [default = Y]: ";
    chomp ($nmea = <STDIN>);
    $nmea = uc ($nmea);
    }
    until ($nmea eq "Y" || $nmea eq "N" || $nmea eq "");
  if ($nmea eq "") { $nmea = "Y"; }

  if ($nmea eq "Y")
      { $nmea_enable = 1; }
    else
      { $nmea_enable = 0; }
  }

# Select AIS channel A or B

do
  {
  print "\nEnter AIS channel (A/B) [default = A]: ";
  chomp ($channel = <STDIN>);
  $channel = uc ($channel);
  }
  until ($channel eq "A" || $channel eq "B" || $channel eq "");
if ($channel eq "") { $channel = "A"; }

if ($out eq "U")
    { $command .= "| xargs -IX ./unpacker.pl X " . $nmea_enable . " " . $channel; }
  else
    { $command .= "| xargs -IX ./AiS_TX.py --payload=X --channel=" . $channel;}

print "\n$command\n\n";

# ********************************************************
# *****           SUBROUTINE BLOCKS                  *****
# ********************************************************

# ********************************************************
# menu
# ********************************************************

# Main menu subroutine. Determine message type.

sub menu # ()
  {
  my $opt;

# Show the main menu options...

  do
    {
    print "\033[2J";    # Clear the screen
    print "\033[0;0H";  # Place cursor at 0,0 (upper left-hand corner)
    print "                AIVDM Preprocessor (Build: $build_date Version: $version)\n\n";
    print "                                   MENU\n\n";
    print "  Type 1: Position Report Class A\n";
    print "  Type 4: Base Station Report\n";
    print "  Type 14: Safety-Related Broadcast Message\n";
    print "  Type 18: Standard Class B CS Position Report\n";
    print "  Type 20: Data Link Management Message\n";
    print "  Type 21: Aid-to-Navigation Report\n";
    print "  Type 22: Channel Management\n";
    print "  Type 23: Group Assignment Command\n";
    print "  Type 24: Static Data Report\n";
    print "\n";
    print "  X. Exit\n\n";
    print "Enter message type (1, 4, 14, 18, 20-24) or 'X' to halt: ";
    chomp ($opt = <STDIN>);
    $opt = uc ($opt);
    }
    until ($opt == 1 || $opt == 4 || $opt == 14 || $opt == 18 || ($opt >= 20 && $opt <= 24) || $opt eq "X");

  return ($opt);
  }

# ********************************************************
# verify_numeric_string
# ********************************************************

# Verify that a numeric string of len $len is the proper length and actually all digits

sub verify_numeric_string # ($num_str, $str_len)
  {
  my ($i,$ok,$tyui);
  my ($num_str, $str_len); $num_str = $_[0]; $str_len = $_[1];

  if (length ($num_str) != $str_len)
    { return 0; }

  for ($i=0; $i<$str_len; $i++)
    {
    $tyui = substr ($num_str,$i,1);
    if ($tyui lt "0" || $tyui gt "9")
      {  return 0; }
    }   

  return 1;
  }

