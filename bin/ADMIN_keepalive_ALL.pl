#!/usr/bin/perl
#
# ADMIN_keepalive_ALL.pl   version  2.14
#
# Designed to keep the astGUIclient processes alive and check every minute
# Replaces all other ADMIN_keepalive scripts
# Uses /etc/astguiclient.conf file to know which processes to keepalive
#
# Other functions of this program:
#  - Launches the timeclock auto-logout process
#  - clear out non-used vicidial_conferences sessions
#  - Generates Asterisk conf files and reloads Asterisk
#  - Synchronizes the audio store files
#  - Runs trigger processes at defined times
#  - Auto reset lists at defined times
#  - Auto restarts Asterisk process if enabled in servers settings
#
# Copyright (C) 2017  Matt Florell <vicidial@gmail.com>    LICENSE: AGPLv2
#
# CHANGES
# 61011-1348 - First build
# 61120-2011 - Added option 7 for AST_VDauto_dial_FILL.pl
# 80227-1526 - Added option 8 for ip_relay
# 80526-1350 - Added option 9 for timeclock auto-logout
# 90211-1236 - Added auto-generation of conf files functions
# 90213-0625 - Separated the reloading of Asterisk into 4 separate steps
# 90325-2239 - Rewrote sending of reload commands to Asterisk
# 90327-1421 - Removed [globals] tag from auto-generated extensions file
# 90409-1251 - Fixed voicemail conf file issue
# 90506-1155 - Added Call Menu functionality
# 90513-0449 - Added audio store sync functionality
# 90519-1018 - Added upload file trigger for prompt recording if defined as voicemail server and voicemail/prompt recording extensions auto-generated
# 90529-0652 - Added phone_context and fixed calledid and voicemail for phones entries
# 90614-0753 - Added in-group routing to call menu feature
# 90617-0821 - Added phone ring timeout and call menu custom dialplan entry
# 90621-0823 - Added phones conf file secret field use
# 90621-1425 - Added tracking group for call menus
# 90622-2146 - Added 83047777777777 for dynamic agent alert extension
# 90630-2259 - Added vicidial_process_triggers functionality
# 90713-0140 - Changed direct dial phone extensions to failover to voicemail forwarder
# 90722-1102 - Added list reset by time option
# 90812-0053 - Added clear out non-used vicidial_conferences sessions
# 90821-1246 - Fixed central voicemail server conf file, changed voicemail to use phone password
# 90903-1626 - Added musiconhold and meetme conf file generation
# 90919-1516 - Added generation of standalone voicemail boxes in voicemail conf file
# 91028-1023 - Added clearing of daily-reset tables at the timeclock reset time
# 91031-1258 - Added carrier description comments
# 91109-1205 - Added requirecalltoken=no as IAX setting for newer Asterisk 1.4 versions
# 91125-0709 - Added conf_secret to servers conf
# 91205-2315 - Added delete_vm_after_email option to voicemail conf generation
# 100220-1410 - Added System Settings and Servers custom dialplan entries
# 100225-2020 - Change voicemail configuration to use voicemail.conf
# 100312-1012 - Changed TIMEOUT Call Menu function to work with AGI routes
# 100424-2121 - Added codecs options for phones
# 100616-2245 - Added VIDPROMPT options for call menus, changed INGROUP TIMECHECK routes to special extension like AGI
# 100703-2137 - Added memory table reset nightly
# 100811-2221 - Added --cu3way flag for new optional leave3way cleaning script
# 100812-0515 - Added --cu3way-delay= flag for setting delay in the leave3way cleaning script
# 100814-2206 - Added clearing and optimization for vicidial_xfer_stats table
# 101022-1655 - Added new variables to be cleared from vicidial_cacmpaign_stats table
# 101107-2257 - Added cross-server phone dialplan extensions
# 101214-1507 - Changed list auto-reset to work with inactive lists
# 110512-2112 - Added vicidial_campaign_stats_debug to table cleaning
# 110525-2334 - Added cm.agi optional logging to call menus
# 110705-2023 - Added agents_calls_reset option
# 110725-2356 - Added new voicemail time zone option and menu gather
# 110829-1601 - Added multiple invalid option to Call Menus
# 110911-1452 - Added resets for extension groups and areacode cid tables
# 110922-2148 - Added reset for vicidial_did_ra_extensions
# 111004-2333 - Added Call Menu option for update of fields
# 111221-1454 - Added resetting of max stats records at timeclock end of day
# 120124-1032 - Added Answer to all call menus at the top
# 120209-1525 - Separated all vicidial-auto dialplan contexts into their own contexts to allow for more control of dialing access through phones
# 120213-1405 - Added vicidial_daily_ra_stats rolling
# 120512-2332 - Added loopback dialaround for ringing of calls
# 120706-1325 - Added Call Menu qualify SQL option
# 120820-1026 - Added clearing of vicidial_session_data table at end of day
# 121019-1021 - Added voicemail greeting option
# 121124-1440 - Added holiday expiration function
# 121215-2036 - Added email inbound script keepalive, option E
# 130103-0808 - Added CLI options for delay to be used with auto-dial and FILL processes
# 130108-1657 - Changes for Asterisk 1.8 compatibility
# 130227-1605 - Added --fill-staggered option for the AST_VDauto_dialFILL script
# 130326-1754 - Added ability to use .agi scripts as part of Call Menu Prompt
# 130402-2148 - Changes to allow for native IAX bridging to other servers
# 130424-1607 - Added NOINT prefix option for call menu prompts to do Playback() instead of Background()
# 130508-1009 - Small fix for INVALID_2ND and 3RD
# 130624-0733 - Added optimize for vicidial_users due to logging IP and auth timestamp
# 130716-1441 - Clear out vicidial_monitor_calls records older than 1 day old
# 130921-1044 - Small change to triggers allowing for them to be launched in a screen session if SCREEN is in the name
# 131022-1746 - Added uptime gathering and asterisk auto-restart feature
# 140112-1910 - Fixed issue with MoH in Astrisk 1.8
# 140126-1153 - Added VMAIL_NO_INST option dialplan generation
# 140126-2252 - Added voicemail_instructions option for phones
# 140214-1519 - Added reload_timestamp value to conf files
# 140619-1001 - Added new ASTplay loop IAX trunk
# 141113-1555 - Changed FILL process screen from ASTVDautoFILL to ASTVDadFILL for easier admin
# 141125-1710 - Added gather_stats_flag for audio sync script launch on voicemail server
# 141227-0957 - Changed to clear out old unavail voicemail greetings before copying custom greeting
# 150112-2018 - Added flag to delete voicemail greeting when changed from an audio file to empty
# 150307-1738 - Added custom meetme enter sounds(only works with Asterisk 1.8)
# 150724-0835 - Added purge of vicidial_ajax_log records older than 7 days to end of day process
# 150804-0919 - Added whisper extensions
# 151031-0931 - Added usacan_phone_dialcode_fix feature at timeclock-end-of-day, added -lstn-buffer option
# 151204-0639 - Added phones-unavail_dialplan_fwd_exten options
# 151211-1509 - Added launching of the AST_chat_timeout_cron.pl process on the voicemail server
# 151226-1024 - Fix for double-write of extension in conf files for IAX and SIP, Issue #908
# 151229-1623 - Added asterisk output logger launching, tied to server setting, runs every 5 minutes if active
# 160305-2253 - Added --teod flag to log Timeclock End of Day processes to log file
#               Limited max-stats process to only run on voicemail server, also added alt-logging flags to cm.agi calls
# 160306-1040 - Added option for carriers to be defined for all active asterisk servers
# 160324-1655 - Added callback_useronly_move_minutes option
# 161014-0839 - Added vicidial_user_list_new_lead daily reset
# 161116-0658 - Added purge of vicidial_ajax_log records older than 7 days to end of day process
# 161226-2218 - Added conf_qualify option
# 170113-1645 - Added call menu in-group option DYNAMIC_INGROUP_VAR for use with cm_phonesearch.agi
# 170304-2039 - Added automated reports triggering code
# 170320-1338 - Added conf_qualify phones option for IAX
# 170327-0847 - Added drop list triggering code
# 170513-1728 - Added alternative uptime counter in seconds
# 170609-1601 - If phone entry fullname and cidnumber are empty, don't populate a callerid conf line
# 170711-0824 - Fixed help documentation for delay seconds, issue #1025
# 170725-0017 - Added vicidial_campaign_hour_counts and vicidial_carrier_hour_counts rolling
# 170816-2323 - Added In-Group Ask-Post-Call Survey AGI dialplan entries
# 170916-1009 - Added Asterisk 13 'h' exten for dialplan generation and triggering of AMI2 scripts
# 170920-2214 - Added expired_lists_inactive option, checks once per hour
#

$build = '170920-2214';

$DB=0; # Debug flag
$teodDB=0; # flag to log Timeclock End of Day processes to log file

# define blank variables
$MT[0]='';   $MT[1]='';
@psline=@MT;
$cu3way=0;
$cu3way_delay='';
$autodial_delay='';
$adfill_delay='';
$fill_staggered='';

# time variable definitions
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year = ($year + 1900);
$mon++;
$wtoday = $wday;
if ($mon < 10) {$mon = "0$mon";}
if ($mday < 10) {$mday = "0$mday";}
if ($hour < 10) {$hour = "0$hour";}
if ($min < 10) {$min = "0$min";}
if ($sec < 10) {$sec = "0$sec";}
$now_date = "$year-$mon-$mday $hour:$min:$sec";
$today_start = "$year-$mon-$mday 00:00:00";
$today_date = "$year-$mon-$mday";
$reset_test = "$hour$min";

### calculate the date and time for slightly less than 24 hours ago
$secX = time();
$TDtarget = ($secX - 86000);	# almost one day old
($Tsec,$Tmin,$Thour,$Tmday,$Tmon,$Tyear,$Twday,$Tyday,$Tisdst) = localtime($TDtarget);
$Tyear = ($Tyear + 1900);
$Tmon++;
if ($Tmon < 10) {$Tmon = "0$Tmon";}
if ($Tmday < 10) {$Tmday = "0$Tmday";}
if ($Thour < 10) {$Thour = "0$Thour";}
if ($Tmin < 10) {$Tmin = "0$Tmin";}
if ($Tsec < 10) {$Tsec = "0$Tsec";}
$TDSQLdate = "$Tyear-$Tmon-$Tmday $Thour:$Tmin:$Tsec";

### calculate the date and time for 24 hours ago
$secX = time();
$RMtarget = ($secX - 86400);	# 24 hours ago
($RMsec,$RMmin,$RMhour,$RMmday,$RMmon,$RMyear,$RMwday,$RMyday,$RMisdst) = localtime($RMtarget);
$RMyear = ($RMyear + 1900);
$RMmon++;
if ($RMmon < 10) {$RMmon = "0$RMmon";}
if ($RMmday < 10) {$RMmday = "0$RMmday";}
if ($RMhour < 10) {$RMhour = "0$RMhour";}
if ($RMmin < 10) {$RMmin = "0$RMmin";}
if ($RMsec < 10) {$RMsec = "0$RMsec";}
$RMSQLdate = "$RMyear-$RMmon-$RMmday $RMhour:$RMmin:$RMsec";
$yesterday_start = "$RMyear-$RMmon-$RMmday 00:00:00";
$RMdate = "$RMyear-$RMmon-$RMmday";

### calculate the date and time for 7 days ago
$secX = time();
$SDtarget = ($secX - 604800);	# 7 days ago
($SDsec,$SDmin,$SDhour,$SDmday,$SDmon,$SDyear,$SDwday,$SDyday,$SDisdst) = localtime($SDtarget);
$SDyear = ($SDyear + 1900);
$SDmon++;
if ($SDmon < 10) {$SDmon = "0$SDmon";}
if ($SDmday < 10) {$SDmday = "0$SDmday";}
if ($SDhour < 10) {$SDhour = "0$SDhour";}
if ($SDmin < 10) {$SDmin = "0$SDmin";}
if ($SDsec < 10) {$SDsec = "0$SDsec";}
$SDSQLdate = "$SDyear-$SDmon-$SDmday $SDhour:$SDmin:$SDsec";
$SDdate = "$SDyear-$SDmon-$SDmday";


### begin parsing run-time options ###
if (length($ARGV[0])>1)
	{
	$i=0;
	while ($#ARGV >= $i)
		{
		$args = "$args $ARGV[$i]";
		$i++;
		}

	if ($args =~ /--help/i)
		{
		print "allowed run time options:\n";
		print "  [-test] = test\n";
		print "  [--version] = print version of this script, then exit\n";
		print "  [-autodial-delay=X] = setting delay seconds on local auto-dial process\n";
		print "  [-adfill-delay=X] = setting delay seconds on auto-dial FILL process\n";
		print "  [-fill-staggered] = enable experimental staggered auto-dial FILL process\n";
		print "  [-cu3way] = keepalive for the optional 3way conference checker\n";
		print "  [-lstn-buffer] = use special enhanced telnet buffer listen process\n";
		print "  [-cu3way-delay=X] = setting delay seconds on 3way conference checker\n";
		print "  [-debug] = verbose debug messages\n";
		print "  [-debugX] = Extra-verbose debug messages\n";
		print "  [-debugXXX] = Triple-Extra-verbose debug messages\n";
		print "  [--teod] = log Timeclock End of Day processes to log file\n";
		print "\n";
		exit;
		}
	else
		{
		if ($args =~ /--version/i)
			{
			print "version: $build\n";
			exit;
			}
		if ($args =~ /-debug/i)
			{
			$DB=1; # Debug flag
			}
		if ($args =~ /-debugX/i)
			{
			$DBX=1;
			print "\n----- SUPER-DUPER DEBUGGING -----\n\n";
			}
		if ($args =~ /-debugXXX/i)
			{
			$DBXXX=1;
			print "\n----- TRIPLE DEBUGGING -----\n\n";
			}
		if ($args =~ /-teod/i)
			{
			$teodDB=1;
			if ($DB > 0) {print "\n----- Timeclock end of day logfile logging -----\n\n";}
			}
		if ($args =~ /-autodial-delay=/i) # CLI defined delay
			{
			@CLIvarADARY = split(/-autodial-delay=/,$args);
			@CLIvarADARX = split(/ /,$CLIvarADARY[1]);
			if (length($CLIvarADARX[0])>0)
				{
				$CLIautodialdelay = $CLIvarADARX[0];
				$CLIautodialdelay =~ s/\/$| |\r|\n|\t//gi;
				$CLIautodialdelay =~ s/\D//gi;
				if ( ($CLIautodialdelay > 0) && (length($CLIautodialdelay)> 0) )	
					{$autodial_delay = "--delay=$CLIautodialdelay";}
				if ($DB > 0) {print "AD Delay set to $CLIautodialdelay $autodial_delay\n";}
				}
			@CLIvarADARY=@MT;   @CLIvarADARY=@MT;
			}
		if ($args =~ /-adfill-delay=/i) # CLI defined delay
			{
			@CLIvarADFARY = split(/-autodial-delay=/,$args);
			@CLIvarADFARX = split(/ /,$CLIvarADFARY[1]);
			if (length($CLIvarADFARX[0])>0)
				{
				$CLIadfilldelay = $CLIvarADFARX[0];
				$CLIadfilldelay =~ s/\/$| |\r|\n|\t//gi;
				$CLIadfilldelay =~ s/\D//gi;
				if ( ($CLIadfilldelay > 0) && (length($CLIadfilldelay)> 0) )	
					{$adfill_delay = "--delay=$CLIadfilldelay";}
				if ($DB > 0) {print "ADFILL Delay set to $CLIadfilldelay $adfill_delay\n";}
				}
			@CLIvarADFARY=@MT;   @CLIvarADFARY=@MT;
			}
		if ($args =~ /-fill-staggered/i)
			{
			$fill_staggered='--staggered';
			if ($DB > 0) {print "\n----- FILL STAGGERED ENABLED -----\n\n";}
			}
		if ($args =~ /-cu3way/i)
			{
			$cu3way=1;
			if ($DB > 0) {print "\n----- cu3way ENABLED -----\n\n";}
			}
		if ($args =~ /-lstn-buffer/i)
			{
			$lstn_buffer=1;
			if ($DB > 0) {print "\n----- lstn_buffer ENABLED -----\n\n";}
			}
		if ($args =~ /-cu3way-delay=/i) # CLI defined delay
			{
			@CLIvarARY = split(/-cu3way-delay=/,$args);
			@CLIvarARX = split(/ /,$CLIvarARY[1]);
			if (length($CLIvarARX[0])>0)
				{
				$CLIdelay = $CLIvarARX[0];
				$CLIdelay =~ s/\/$| |\r|\n|\t//gi;
				$CLIdelay =~ s/\D//gi;
				if ( ($CLIdelay > 0) && (length($CLIdelay)> 0) )	
					{$cu3way_delay = "--delay=$CLIdelay";}
				if ($DB > 0) {print "CU3 Delay set to $CLIdelay $cu3way_delay\n";}
				}
			@CLIvarARY=@MT;   @CLIvarARY=@MT;
			}
		if ($args =~ /-test/i)
			{
			$TEST=1;
			$T=1;
			}
		}
	}
else
	{
	#	print "no command line options set\n";
	}
### end parsing run-time options ###

# default path to astguiclient configuration file:
$PATHconf =		'/etc/astguiclient.conf';

open(conf, "$PATHconf") || die "can't open $PATHconf: $!\n";
@conf = <conf>;
close(conf);
$i=0;
foreach(@conf)
	{
	$line = $conf[$i];
	$line =~ s/ |>|\n|\r|\t|\#.*|;.*//gi;
	if ( ($line =~ /^PATHhome/) && ($CLIhome < 1) )
		{$PATHhome = $line;   $PATHhome =~ s/.*=//gi;}
	if ( ($line =~ /^PATHlogs/) && ($CLIlogs < 1) )
		{$PATHlogs = $line;   $PATHlogs =~ s/.*=//gi;}
	if ( ($line =~ /^PATHsounds/) && ($CLIsounds < 1) )
		{$PATHsounds = $line;   $PATHsounds =~ s/.*=//gi;}
	if ( ($line =~ /^VARactive_keepalives/) && ($CLIactive_keepalives < 1) )
		{$VARactive_keepalives = $line;   $VARactive_keepalives =~ s/.*=//gi;}
	if ( ($line =~ /^VARserver_ip/) && ($CLIserver_ip < 1) )
		{$VARserver_ip = $line;   $VARserver_ip =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_server/) && ($CLIDB_server < 1) )
		{$VARDB_server = $line;   $VARDB_server =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_database/) && ($CLIDB_database < 1) )
		{$VARDB_database = $line;   $VARDB_database =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_user/) && ($CLIDB_user < 1) )
		{$VARDB_user = $line;   $VARDB_user =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_pass/) && ($CLIDB_pass < 1) )
		{$VARDB_pass = $line;   $VARDB_pass =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_custom_user/) && ($CLIDB_custom_user < 1) )
		{$VARDB_custom_user = $line;   $VARDB_custom_user =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_custom_pass/) && ($CLIDB_custom_pass < 1) )
		{$VARDB_custom_pass = $line;   $VARDB_custom_pass =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_port/) && ($CLIDB_port < 1) )
		{$VARDB_port = $line;   $VARDB_port =~ s/.*=//gi;}
	$i++;
	}

##### list of codes for active_keepalives and what processes they correspond to
#	X - NO KEEPALIVE PROCESSES (use only if you want none to be keepalive)\n";
#	1 - AST_update\n";
#	2 - AST_send_listen\n";
#	3 - AST_VDauto_dial\n";
#	4 - AST_VDremote_agents\n";
#	5 - AST_VDadapt (If multi-server system, this must only be on one server)\n";
#	6 - FastAGI_log\n";
#	7 - AST_VDauto_dial_FILL\n";
#	8 - ip_relay for blind monitoring\n";
#	9 - Timeclock auto logout\n";
#	E - Email parser script
#     - Other setting are set by configuring them in the database

# Customized Variables
$server_ip = $VARserver_ip;		# Asterisk server IP
$THISserver_voicemail=0;
$voicemail_server_id='';
if (!$VARDB_port) {$VARDB_port='3306';}

use DBI;	  

$dbhA = DBI->connect("DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port", "$VARDB_user", "$VARDB_pass")
 or die "Couldn't connect to database: " . DBI->errstr;


##### Get the settings from system_settings #####
$stmtA = "SELECT sounds_central_control_active,active_voicemail_server,custom_dialplan_entry,default_codecs,generate_cross_server_exten,voicemail_timezones,default_voicemail_timezone,call_menu_qualify_enabled,allow_voicemail_greeting,reload_timestamp,meetme_enter_login_filename,meetme_enter_leave3way_filename,allow_chats,enable_auto_reports,enable_drop_lists,expired_lists_inactive FROM system_settings;";
#	print "$stmtA\n";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArows=$sthA->rows;
if ($sthArows > 0)
	{
	@aryA = $sthA->fetchrow_array;
	$sounds_central_control_active =	$aryA[0];
	$active_voicemail_server =			$aryA[1];
	$SScustom_dialplan_entry =			$aryA[2];
	$SSdefault_codecs =					$aryA[3];
	$SSgenerate_cross_server_exten =	$aryA[4];
	$SSvoicemail_timezones =			$aryA[5];
	$SSdefault_voicemail_timezone =		$aryA[6];
	$SScall_menu_qualify_enabled =		$aryA[7];
	$SSallow_voicemail_greeting =		$aryA[8];
	$SSreload_timestamp =				$aryA[9];
	$meetme_enter_login_filename =		$aryA[10];
	$meetme_enter_leave3way_filename =	$aryA[11];
	$SSallow_chats =					$aryA[12];
	$SSenable_auto_reports =			$aryA[13];
	$SSenable_drop_lists =				$aryA[14];
	$SSexpired_lists_inactive =			$aryA[15];
	}
$sthA->finish();
if ($DBXXX > 0) {print "SYSTEM SETTINGS:     $sounds_central_control_active|$active_voicemail_server|$SScustom_dialplan_entry|$SSdefault_codecs\n";}

##### Get the settings for this server's server_ip #####
$stmtA = "SELECT active_asterisk_server,generate_vicidial_conf,rebuild_conf_files,asterisk_version,sounds_update,conf_secret,custom_dialplan_entry,auto_restart_asterisk,asterisk_temp_no_restart,gather_asterisk_output,conf_qualify FROM servers where server_ip='$server_ip';";
#	print "$stmtA\n";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArows=$sthA->rows;
if ($sthArows > 0)
	{
	@aryA = $sthA->fetchrow_array;
	$active_asterisk_server	=		$aryA[0];
	$generate_vicidial_conf	=		$aryA[1];
	$rebuild_conf_files	=			$aryA[2];
	$asterisk_version =				$aryA[3];
	$sounds_update =				$aryA[4];
	$self_conf_secret =				$aryA[5];
	$SERVERcustom_dialplan_entry =	$aryA[6];
	$auto_restart_asterisk =		$aryA[7];
	$asterisk_temp_no_restart =		$aryA[8];
	$gather_asterisk_output =		$aryA[9];
	$conf_qualify =					$aryA[10];
	}
$sthA->finish();

%ast_ver_str = parse_asterisk_version($asterisk_version);
if ($DBX) {print "Asterisk version: $ast_ver_str{major} $ast_ver_str{minor}\n";}

if ($VARactive_keepalives =~ /X/)
	{
	if ($DB) {print "X in active_keepalives, skipping this section...\n";}
	}
else
	{
	$AST_update=0;
	$AST_send_listen=0;
	$AST_VDauto_dial=0;
	$AST_VDremote_agents=0;
	$AST_VDadapt=0;
	$FastAGI_log=0;
	$email_inbound=0;
	$AST_VDauto_dial_FILL=0;
	$ip_relay=0;
	$timeclock_auto_logout=0;
	$runningAST_update=0;
	$runningAST_send=0;
	$runningAST_listen=0;
	$runningAST_VDauto_dial=0;
	$runningAST_VDremote_agents=0;
	$runningAST_VDadapt=0;
	$runningFastAGI_log=0;
	$runningAST_VDauto_dial_FILL=0;
	$runningip_relay=0;
	$runningAST_conf_3way=0;
	$runningemail_inbound=0;
	$runningASTERISK=0;
	$AST_conf_3way=0;

	if ($VARactive_keepalives =~ /1/) 
		{
		$AST_update=1;
		if ($DB) {print "AST_update set to keepalive\n";}
		}
	if ($VARactive_keepalives =~ /2/) 
		{
		$AST_send_listen=1;
		if ($DB) {print "AST_send_listen set to keepalive\n";}
		}
	if ($VARactive_keepalives =~ /3/) 
		{
		$AST_VDauto_dial=1;
		if ($DB) {print "AST_VDauto_dial set to keepalive\n";}
		}
	if ($VARactive_keepalives =~ /4/) 
		{
		$AST_VDremote_agents=1;
		if ($DB) {print "AST_VDremote_agents set to keepalive\n";}
		}
	if ($VARactive_keepalives =~ /5/) 
		{
		$AST_VDadapt=1;
		if ($DB) {print "AST_VDadapt set to keepalive\n";}
		}
	if ($VARactive_keepalives =~ /6/) 
		{
		$FastAGI_log=1;
		if ($DB) {print "FastAGI_log set to keepalive\n";}
		}
	if ($VARactive_keepalives =~ /7/) 
		{
		$AST_VDauto_dial_FILL=1;
		if ($DB) {print "AST_VDauto_dial_FILL set to keepalive\n";}
		}
	if ($VARactive_keepalives =~ /8/) 
		{
		$ip_relay=1;
		if ($DB) {print "ip_relay set to keepalive\n";}
		}
	if ($VARactive_keepalives =~ /9/) 
		{
		$timeclock_auto_logout=1;
		if ($DB) {print "Check to see if Timeclock auto logout should run\n";}
		}
	if ($VARactive_keepalives =~ /E/) 
		{
		$email_inbound=1;
		if ($DB) {print "Check to see if email parser should run\n";}
		}
	if ($cu3way > 0) 
		{
		$AST_conf_3way=1;
		if ($DB) {print "AST_conf_3way set to keepalive\n";}
		}


	$REGhome = $PATHhome;
	$REGhome =~ s/\//\\\//gi;






	##### First, check and see which processes are running #####

	### you may have to use a different ps command if you're not using Slackware Linux
	#	@psoutput = `ps -f -C AST_update --no-headers`;
	#	@psoutput = `ps -f -C AST_updat* --no-headers`;
	#	@psoutput = `/bin/ps -f --no-headers -A`;
	#	@psoutput = `/bin/ps -o pid,args -A`; ### use this one for FreeBSD
	@psoutput = `/bin/ps -o "%p %a" --no-headers -A`;

	$i=0;
	foreach (@psoutput)
		{
		chomp($psoutput[$i]);
		if ($DBX) {print "$i|$psoutput[$i]|     \n";}
		@psline = split(/\/usr\/bin\/perl /,$psoutput[$i]);

		if ($psoutput[$i] =~ /bin\/asterisk/) 
			{
			$runningASTERISK++;
			if ($DB) {print "asterisk RUNNING:              |$psoutput[$i]|\n";}
			}
		if ($psline[1] =~ /$REGhome\/AST_update/) 
			{
			$runningAST_update++;
			if ($DB) {print "AST_update RUNNING:              |$psline[1]|\n";}
			}
		if ($psline[1] =~ /AST_manager_se/) 
			{
			$runningAST_send++;
			if ($DB) {print "AST_send RUNNING:                |$psline[1]|\n";}
			}
		if ($psline[1] =~ /AST_manager_li/) 
			{
			$psoutput[$i] =~ s/ .*|\n|\r|\t| //gi;
			$listen_pid[$runningAST_listen] = $psoutput[$i];
			$runningAST_listen++;
			if ($DB) {print "AST_listen RUNNING:              |$psline[1]|\n";}
			}
		if ($psline[1] =~ /$REGhome\/AST_VDauto_dial\.pl/) 
			{
			$runningAST_VDauto_dial++;
			if ($DB) {print "AST_VDauto_dial RUNNING:         |$psline[1]|\n";}
			}
		if ($psline[1] =~ /$REGhome\/AST_VDremote_agents\.pl/) 
			{
			$runningAST_VDremote_agents++;
			if ($DB) {print "AST_VDremote_agents RUNNING:     |$psline[1]|\n";}
			}
		if ($psline[1] =~ /$REGhome\/AST_VDadapt\.pl/) 
			{
			$runningAST_VDadapt++;
			if ($DB) {print "AST_VDadapt RUNNING:             |$psline[1]|\n";}
			}
		if ($psline[1] =~ /$REGhome\/FastAGI_log\.pl/) 
			{
			$runningFastAGI_log++;
			if ($DB) {print "FastAGI_log RUNNING:             |$psline[1]|\n";}
			}
		if ($psline[1] =~ /$REGhome\/AST_VDauto_dial_FILL\.pl/) 
			{
			$runningAST_VDauto_dial_FILL++;
			if ($DB) {print "AST_VDauto_dial_FILL RUNNING:    |$psline[1]|\n";}
			}
		if ($psline[1] =~ /$REGhome\/VD_email_inbound\.pl/) 
			{
			$runningemail_inbound++;
			if ($DB) {print "VD_email_inbound RUNNING:|$psline[1]|\n";}
			}
		if ($psoutput[$i] =~ / ip_relay /) 
			{
			$runningip_relay++;
			if ($DB) {print "ip_relay RUNNING:                |$psoutput[$i]|\n";}
			}
		if ($psline[1] =~ /$REGhome\/AST_conf_update_3way\.pl/) 
			{
			$runningAST_conf_3way++;
			if ($DB) {print "AST_conf_3way RUNNING:           |$psline[1]|\n";}
			}

		$i++;
		}





	##### Second, IF MORE THAN ONE LISTEN INSTANCE IS RUNNING, KILL THE SECOND ONE #####
	@psline=@MT;
	@psoutput=@MT;
	@listen_pid=@MT;
	if ($runningAST_listen > 1)
		{
		$runningAST_listen=0;

			sleep(1);

		### you may have to use a different ps command if you're not using Slackware Linux
		#	@psoutput = `ps -f -C AST_update --no-headers`;
		#	@psoutput = `ps -f -C AST_updat* --no-headers`;
		#	@psoutput = `/bin/ps -f --no-headers -A`;
		#	@psoutput = `/bin/ps -o pid,args -A`; ### use this one for FreeBSD
		@psoutput = `/bin/ps -o "%p %a" --no-headers -A`;

		$i=0;
		foreach (@psoutput)
			{
				chomp($psoutput[$i]);
			if ($DBX) {print "$i|$psoutput[$i]|     \n";}
			@psline = split(/\/usr\/bin\/perl /,$psoutput[$i]);
			$psoutput[$i] =~ s/^ *//gi;
			$psoutput[$i] =~ s/ .*|\n|\r|\t| //gi;

			if ($psline[1] =~ /AST_manager_li/) 
				{
				$listen_pid[$runningAST_listen] = $psoutput[$i];
				if ($DB) {print "AST_listen RUNNING:              |$psline[1]|$listen_pid[$runningAST_listen]|\n";}
				$runningAST_listen++;
				}

			$i++;
			}

		if ($runningAST_listen > 1)
			{
			if ($DB) {print "Killing AST_manager_listen... |$listen_pid[1]|\n";}
			`/bin/kill -s 9 $listen_pid[1]`;
			}
		}







	##### Third, double-check that non-running scripts are not running #####
	@psline=@MT;
	@psoutput=@MT;

	if ( 
		( ($AST_update > 0) && ($runningAST_update < 1) ) ||
		( ($AST_send_listen > 0) && ($runningAST_send < 1) ) ||
		( ($AST_send_listen > 0) && ($runningAST_listen < 1) ) ||
		( ($AST_VDauto_dial > 0) && ($runningAST_VDauto_dial < 1) ) ||
		( ($AST_VDremote_agents > 0) && ($runningAST_VDremote_agents < 1) ) ||
		( ($AST_VDadapt > 0) && ($runningAST_VDadapt < 1) ) ||
		( ($FastAGI_log > 0) && ($runningFastAGI_log < 1) ) ||
		( ($AST_VDauto_dial_FILL > 0) && ($runningAST_VDauto_dial_FILL < 1) ) ||
		( ($ip_relay > 0) && ($runningip_relay < 1) ) ||
		( ($AST_conf_3way > 0) && ($runningAST_conf_3way < 1) ) || 
		( ($email_inbound > 0) && ($runningemail_inbound < 1) )
	   )
		{

		if ($DB) {print "double check that processes are not running...\n";}

			sleep(1);

		#`PERL5LIB="$PATHhome/libs"; export PERL5LIB`; # issue #457
		$ENV{'PERL5LIB'} = "$PATHhome/libs";
		### you may have to use a different ps command if you're not using Slackware Linux
		#	@psoutput = `ps -f -C AST_update --no-headers`;
		#	@psoutput = `ps -f -C AST_updat* --no-headers`;
		#	@psoutput = `/bin/ps -f --no-headers -A`;
		#	@psoutput = `/bin/ps -o pid,args -A`; ### use this one for FreeBSD
		@psoutput2 = `/bin/ps -o "%p %a" --no-headers -A`;
		$i=0;
		foreach (@psoutput2)
			{
			chomp($psoutput2[$i]);
			if ($DBX) {print "$i|$psoutput2[$i]|     \n";}
			@psline = split(/\/usr\/bin\/perl /,$psoutput2[$i]);

			if ($psoutput2[$i] =~ /bin\/asterisk/) 
				{
				$runningASTERISK++;
				if ($DB) {print "asterisk RUNNING:              |$psoutput2[$i]|\n";}
				}
			if ($psline[1] =~ /$REGhome\/AST_update/) 
				{
				$runningAST_update++;
				if ($DB) {print "AST_update RUNNING:              |$psline[1]|\n";}
				}
			if ($psline[1] =~ /AST_manager_se/) 
				{
				$runningAST_send++;
				if ($DB) {print "AST_send RUNNING:                |$psline[1]|\n";}
				}
			if ($psline[1] =~ /AST_manager_li/) 
				{
				$runningAST_listen++;
				if ($DB) {print "AST_listen RUNNING:              |$psline[1]|\n";}
				}
			if ($psline[1] =~ /$REGhome\/AST_VDauto_dial\.pl/) 
				{
				$runningAST_VDauto_dial++;
				if ($DB) {print "AST_VDauto_dial RUNNING:         |$psline[1]|\n";}
				}
			if ($psline[1] =~ /$REGhome\/AST_VDremote_agents\.pl/) 
				{
				$runningAST_VDremote_agents++;
				if ($DB) {print "AST_VDremote_agents RUNNING:     |$psline[1]|\n";}
				}
			if ($psline[1] =~ /$REGhome\/AST_VDadapt\.pl/) 
				{
				$runningAST_VDadapt++;
				if ($DB) {print "AST_VDadapt RUNNING:             |$psline[1]|\n";}
				}
			if ($psline[1] =~ /$REGhome\/FastAGI_log\.pl/) 
				{
				$runningFastAGI_log++;
				if ($DB) {print "FastAGI_log RUNNING:             |$psline[1]|\n";}
				}
			if ($psline[1] =~ /$REGhome\/AST_VDauto_dial_FILL\.pl/) 
				{
				$runningAST_VDauto_dial_FILL++;
				if ($DB) {print "AST_VDauto_dial_FILL RUNNING:    |$psline[1]|\n";}
				}
			if ($psline[1] =~ /$REGhome\/VD_email_inbound\.pl/) 
				{
				$runningemail_inbound++;
				if ($DB) {print "VD_email_inbound RUNNING:|$psline[1]|\n";}
				}
			if ($psoutput2[$i] =~ / ip_relay /) 
				{
				$runningip_relay++;
				if ($DB) {print "ip_relay RUNNING:                |$psoutput2[$i]|\n";}
				}
			if ($psline[1] =~ /$REGhome\/AST_conf_update_3way\.pl/) 
				{
				$runningAST_conf_3way++;
				if ($DB) {print "AST_conf_3way RUNNING:           |$psline[1]|\n";}
				}
			$i++;
			}


		if ( ($AST_update > 0) && ($runningAST_update < 1) )
			{ 
			if ($DB) {print "starting AST_update...\n";}
			# add a '-L' to the command below to activate logging
			if (( $ast_ver_str{major} = 1 ) && ($ast_ver_str{minor} >= 12))
				{`/usr/bin/screen -d -m -S ASTupdate $PATHhome/AST_update_AMI2.pl`;}
			else
				{`/usr/bin/screen -d -m -S ASTupdate $PATHhome/AST_update.pl`;}
			}
		if ( ($AST_send_listen > 0) && ($runningAST_send < 1) )
			{ 
			if ($DB) {print "starting AST_manager_send...\n";}
			# add a '-L' to the command below to activate logging
			`/usr/bin/screen -d -m -S ASTsend $PATHhome/AST_manager_send.pl`;
			}
		if ( ($AST_send_listen > 0) && ($runningAST_listen < 1) )
			{ 
			if ($DB) {print "starting AST_manager_listen...\n";}
			# add a '-L' to the command below to activate logging
			if (( $ast_ver_str{major} = 1 ) && ($ast_ver_str{minor} >= 12))
				{`/usr/bin/screen -d -m -S ASTlisten $PATHhome/AST_manager_listen_AMI2.pl`;}
			else
				{
				if ($lstn_buffer > 0) 
					{`/usr/bin/screen -d -m -S ASTlisten $PATHhome/AST_manager_listenBUFFER.pl`;}
				else
					{`/usr/bin/screen -d -m -S ASTlisten $PATHhome/AST_manager_listen.pl`;}
				}
			}
		if ( ($AST_VDauto_dial > 0) && ($runningAST_VDauto_dial < 1) )
			{ 
			if ($DB) {print "starting AST_VDauto_dial...\n";}
			# add a '-L' to the command below to activate logging
			`/usr/bin/screen -d -m -S ASTVDauto $PATHhome/AST_VDauto_dial.pl $autodial_delay`;
			}
		if ( ($AST_VDremote_agents > 0) && ($runningAST_VDremote_agents < 1) )
			{ 
			if ($DB) {print "starting AST_VDremote_agents...\n";}
			# add a '-L' to the command below to activate logging
			`/usr/bin/screen -d -m -S ASTVDremote $PATHhome/AST_VDremote_agents.pl --debug`;
			}
		if ( ($AST_VDadapt > 0) && ($runningAST_VDadapt < 1) )
			{ 
			if ($DB) {print "starting AST_VDadapt...\n";}
			# add a '-L' to the command below to activate logging
			`/usr/bin/screen -d -m -S ASTVDadapt $PATHhome/AST_VDadapt.pl --debug`;
			}
		if ( ($FastAGI_log > 0) && ($runningFastAGI_log < 1) )
			{ 
			if ($DB) {print "starting FastAGI_log...\n";}
			# add a '-L' to the command below to activate logging
			`/usr/bin/screen -d -m -S ASTfastlog $PATHhome/FastAGI_log.pl --debug`;
			}
		if ( ($AST_VDauto_dial_FILL > 0) && ($runningAST_VDauto_dial_FILL < 1) )
			{ 
			if ($DB) {print "starting AST_VDauto_dial_FILL...\n";}
			# add a '-L' to the command below to activate logging
			`/usr/bin/screen -d -m -S ASTVDadFILL $PATHhome/AST_VDauto_dial_FILL.pl --debug $fill_staggered $adfill_delay`;
			}
		if ( ($email_inbound > 0) && ($runningemail_inbound < 1) )
			{ 
			if ($DB) {print "starting VD_email_inbound...\n";}
			# add a '-L' to the command below to activate logging
			`/usr/bin/screen -d -m -S ASTemail $PATHhome/VD_email_inbound.pl`;
			}
		if ( ($ip_relay > 0) && ($runningip_relay < 1) )
			{ 
			if ($DB) {print "starting ip_relay through relay_control...\n";}
			`$PATHhome/ip_relay/relay_control start  2>/dev/null 1>&2`;
			}
		if ( ($AST_conf_3way > 0) && ($runningAST_conf_3way < 1) )
			{ 
			if ($DB) {print "starting AST_conf_3way...\n";}
			# add a '-L' to the command below to activate logging
			`/usr/bin/screen -d -m -S ASTconf3way $PATHhome/AST_conf_update_3way.pl --debug $cu3way_delay`;
			}
		}
	}


### run the Timeclock auto-logout process ###
if ($timeclock_auto_logout > 0)
	{
	if ($DB) {print "running Timeclock auto-logout process...\n";}
	`/usr/bin/screen -d -m -S Timeclock $PATHhome/ADMIN_timeclock_auto_logout.pl 2>/dev/null 1>&2`;
	if ($teodDB) 
		{
		$event_string = "running Timeclock auto-logout process|/usr/bin/screen -d -m -S Timeclock $PATHhome/ADMIN_timeclock_auto_logout.pl 2>/dev/null 1>&2";
		&teod_logger;
		}
	}
################################################################################
#####  END keepalive of ViciDial-related scripts
################################################################################





################################################################################
#####  START clear out non-used vicidial_conferences sessions and reset daily
#####        tally tables at Timeclock end-of-day
################################################################################

$timeclock_end_of_day_NOW=0;
### determine if it is the timeclock end of day right now
$stmtA = "SELECT count(*) from system_settings where timeclock_end_of_day LIKE \"%$reset_test%\";";
if ($DB) {print "|$stmtA|\n";}
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthArows=$sthA->rows;
if ($sthArows > 0)
	{
	@aryA = $sthA->fetchrow_array;
	$timeclock_end_of_day_NOW =	$aryA[0];
	}
$sthA->finish();


if ($timeclock_end_of_day_NOW > 0)
	{
	if ($teodDB) {$event_string = "Starting timeclock end of day processes: $stmtA|$timeclock_end_of_day_NOW";   &teod_logger;}

	$stmtA = "SELECT agents_calls_reset,usacan_phone_dialcode_fix from system_settings;";
	if ($DB) {print "|$stmtA|\n";}
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$SSsel_ct=$sthA->rows;
	if ($SSsel_ct > 0)
		{
		@aryA = $sthA->fetchrow_array;
		$agents_calls_reset =			$aryA[0];
		$usacan_phone_dialcode_fix =	$aryA[1];
		}
	$sthA->finish();

	if ($DB) {print "Starting clear out non-used vicidial_conferences sessions process...\n";}

	$stmtA = "SELECT conf_exten,extension from vicidial_conferences where server_ip='$server_ip' and leave_3way='0';";
	if ($DB) {print "|$stmtA|\n";}
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$VCexten_ct=$sthA->rows;
	$rec_count=0;
	while ($VCexten_ct > $rec_count)
		{
		@aryA = $sthA->fetchrow_array;
		$PT_conf_extens[$rec_count] =	 $aryA[0];
		$PT_extensions[$rec_count] =	 $aryA[1];
			if ($DBX) {print "|$PT_conf_extens[$rec_count]|$PT_extensions[$rec_count]|\n";}
		$rec_count++;
		}
	$sthA->finish();
	$k=0;
	$conf_cleared=0;
	while ($k < $rec_count)
		{
		$live_session=0;
		$stmtA = "SELECT count(*) from vicidial_live_agents where conf_exten='$PT_conf_extens[$k]' and server_ip='$server_ip';";
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		if ($sthArows > 0)
			{
			@aryA = $sthA->fetchrow_array;
			$live_session =	"$aryA[0]";
			}
		$sthA->finish();

		if ($live_session < 1)
			{
			$stmtA = "UPDATE vicidial_conferences set extension='' where server_ip='$server_ip' and conf_exten='$PT_conf_extens[$k]';";
				if($DBX){print STDERR "\n|$stmtA|\n";}
			$affected_rows = $dbhA->do($stmtA); #  or die  "Couldn't execute query:|$stmtA|\n";
			$conf_cleared = ($conf_cleared + $affected_rows);
			}
		$k++;
		}
	if ($teodDB) {$event_string = "Empty vicidial_conferences entries cleared: $conf_cleared";   &teod_logger;}


	### Only run the following on one server in the cluster, the one set as the active voicemail server ###
	if ( ($active_voicemail_server =~ /$server_ip/) && ((length($active_voicemail_server)) eq (length($server_ip))) )
		{
		if ($DB) {print "Starting clear out system-wide daily reset tables...\n";}

		$stmtA = "UPDATE vicidial_xfer_stats SET xfer_count='0';";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$affected_rows = $dbhA->do($stmtA);
		if($DB){print STDERR "\n|$affected_rows vicidial_xfer_stats records reset|\n";}
		if ($teodDB) {$event_string = "vicidial_xfer_stats records reset: $affected_rows";   &teod_logger;}

		$stmtA = "optimize table vicidial_xfer_stats;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if ($DB) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();

		$stmtA = "UPDATE vicidial_campaign_stats SET dialable_leads='0', calls_today='0', answers_today='0', drops_today='0', drops_today_pct='0', drops_answers_today_pct='0', calls_hour='0', answers_hour='0', drops_hour='0', drops_hour_pct='0', calls_halfhour='0', answers_halfhour='0', drops_halfhour='0', drops_halfhour_pct='0', calls_fivemin='0', answers_fivemin='0', drops_fivemin='0', drops_fivemin_pct='0', calls_onemin='0', answers_onemin='0', drops_onemin='0', drops_onemin_pct='0', differential_onemin='0', agents_average_onemin='0', balance_trunk_fill='0', status_category_count_1='0', status_category_count_2='0', status_category_count_3='0', status_category_count_4='0',agent_calls_today='0',agent_pause_today='0',agent_wait_today='0',agent_custtalk_today='0',agent_acw_today='0';";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$affected_rows = $dbhA->do($stmtA);
		if($DB){print STDERR "\n|$affected_rows vicidial_campaign_stats records reset|\n";}
		if ($teodDB) {$event_string = "vicidial_campaign_stats records reset: $affected_rows";   &teod_logger;}

		$stmtA = "optimize table vicidial_campaign_stats;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if ($DB) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();

		$stmtA = "UPDATE vicidial_drop_rate_groups SET calls_today='0', answers_today='0', drops_today='0', drops_today_pct='0', drops_answers_today_pct='0';";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$affected_rows = $dbhA->do($stmtA);
		if($DB){print STDERR "\n|$affected_rows vicidial_drop_rate_groups records reset|\n";}
		if ($teodDB) {$event_string = "vicidial_drop_rate_groups records reset: $affected_rows";   &teod_logger;}

		$stmtA = "optimize table vicidial_drop_rate_groups;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if ($DB) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();

		$stmtA = "delete from vicidial_campaign_server_stats;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$affected_rows = $dbhA->do($stmtA);
		if($DB){print STDERR "\n|$affected_rows vicidial_campaign_server_stats records deleted|\n";}
		if ($teodDB) {$event_string = "vicidial_campaign_server_stats records reset: $affected_rows";   &teod_logger;}

		$stmtA = "optimize table vicidial_campaign_server_stats;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if ($DB) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();

		$stmtA = "delete from vicidial_campaign_stats_debug;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$affected_rows = $dbhA->do($stmtA);
		if($DB){print STDERR "\n|$affected_rows vicidial_campaign_stats_debug records deleted|\n";}
		if ($teodDB) {$event_string = "vicidial_campaign_stats_debug records reset: $affected_rows";   &teod_logger;}

		$stmtA = "optimize table vicidial_campaign_stats_debug;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if ($DB) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();

		$stmtA = "update vicidial_inbound_group_agents SET calls_today=0;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$affected_rows = $dbhA->do($stmtA);
		if($DB){print STDERR "\n|$affected_rows vicidial_inbound_group_agents call counts reset|\n";}
		if ($teodDB) {$event_string = "vicidial_inbound_group_agents records reset: $affected_rows";   &teod_logger;}

		$stmtA = "optimize table vicidial_inbound_group_agents;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if ($DB) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();

		$stmtA = "update vicidial_campaign_cid_areacodes SET call_count_today=0;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$affected_rows = $dbhA->do($stmtA);
		if($DB){print STDERR "\n|$affected_rows vicidial_campaign_cid_areacodes call counts reset|\n";}
		if ($teodDB) {$event_string = "vicidial_campaign_cid_areacodes records reset: $affected_rows";   &teod_logger;}

		$stmtA = "optimize table vicidial_campaign_cid_areacodes;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if ($DB) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();

		$stmtA = "update vicidial_did_ra_extensions SET call_count_today=0;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$affected_rows = $dbhA->do($stmtA);
		if($DB){print STDERR "\n|$affected_rows vicidial_did_ra_extensions call counts reset|\n";}
		if ($teodDB) {$event_string = "vicidial_did_ra_extensions records reset: $affected_rows";   &teod_logger;}

		$stmtA = "optimize table vicidial_did_ra_extensions;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if ($DB) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();

		$stmtA = "update vicidial_extension_groups SET call_count_today=0;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$affected_rows = $dbhA->do($stmtA);
		if($DB){print STDERR "\n|$affected_rows vicidial_extension_groups call counts reset|\n";}
		if ($teodDB) {$event_string = "vicidial_extension_groups records reset: $affected_rows";   &teod_logger;}

		$stmtA = "optimize table vicidial_extension_groups;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if ($DB) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();

		$stmtA = "optimize table vicidial_users;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if ($DB) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();

		$stmtA = "update vicidial_campaign_agents SET calls_today=0;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$affected_rows = $dbhA->do($stmtA);
		if($DB){print STDERR "\n|$affected_rows vicidial_campaign_agents call counts reset|\n";}
		if ($teodDB) {$event_string = "vicidial_campaign_agents records reset: $affected_rows";   &teod_logger;}

		$stmtA = "optimize table vicidial_campaign_agents;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if ($DB) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();

		$stmtA = "update vicidial_live_inbound_agents SET calls_today=0;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$affected_rows = $dbhA->do($stmtA);
		if($DB){print STDERR "\n|$affected_rows vicidial_live_inbound_agents call counts reset|\n";}
		if ($teodDB) {$event_string = "vicidial_live_inbound_agents records reset: $affected_rows";   &teod_logger;}

		if ($agents_calls_reset > 0)
			{
			$stmtA = "delete from vicidial_live_inbound_agents where last_call_finish < \"$TDSQLdate\";";
			if($DBX){print STDERR "\n|$stmtA|\n";}
			$affected_rows = $dbhA->do($stmtA);
			if($DB){print STDERR "\n|$affected_rows vicidial_live_inbound_agents old records deleted|\n";}
			if ($teodDB) {$event_string = "vicidial_live_inbound_agents old records deleted($TDSQLdate): $affected_rows";   &teod_logger;}

			$stmtA = "delete from vicidial_live_agents where last_state_change < \"$TDSQLdate\" and extension NOT LIKE \"R/%\";";
			if($DBX){print STDERR "\n|$stmtA|\n";}
			$affected_rows = $dbhA->do($stmtA);
			if($DB){print STDERR "\n|$affected_rows vicidial_live_agents old records deleted|\n";}
			if ($teodDB) {$event_string = "vicidial_live_agents old records deleted($TDSQLdate): $affected_rows";   &teod_logger;}

			$stmtA = "delete from vicidial_auto_calls where last_update_time < \"$TDSQLdate\";";
			if($DBX){print STDERR "\n|$stmtA|\n";}
			$affected_rows = $dbhA->do($stmtA);
			if($DB){print STDERR "\n|$affected_rows vicidial_auto_calls old records deleted|\n";}
			if ($teodDB) {$event_string = "vicidial_auto_calls old records deleted($TDSQLdate): $affected_rows";   &teod_logger;}
			}

		$stmtA = "optimize table vicidial_live_inbound_agents;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if ($DB) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();

		$stmtA = "optimize table vicidial_live_agents;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if ($DB) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();

		$stmtA = "optimize table vicidial_auto_calls;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if ($DB) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();

		$stmtA = "update vicidial_user_list_new_lead SET new_count=0;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$affected_rows = $dbhA->do($stmtA);
		if($DB){print STDERR "\n|$affected_rows vicidial_user_list_new_lead call counts reset|\n";}
		if ($teodDB) {$event_string = "vicidial_user_list_new_lead records reset: $affected_rows";   &teod_logger;}

		$stmtA = "optimize table vicidial_user_list_new_lead;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if ($DB) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();

		$stmtA = "optimize table vicidial_daily_max_stats;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if ($DB) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();

		$stmtA = "optimize table vicidial_daily_ra_stats;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if ($DB) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();

		$stmtA = "delete from vicidial_session_data where login_time < \"$TDSQLdate\";";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$affected_rows = $dbhA->do($stmtA);
		if($DB){print STDERR "\n|$affected_rows vicidial_session_data old records deleted|\n";}
		if ($teodDB) {$event_string = "vicidial_session_data old records deleted($TDSQLdate): $affected_rows";   &teod_logger;}

		$stmtA = "optimize table vicidial_session_data;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if ($DB) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();

		$stmtA = "delete from vicidial_monitor_calls where monitor_time < \"$TDSQLdate\";";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$affected_rows = $dbhA->do($stmtA);
		if($DB){print STDERR "\n|$affected_rows vicidial_monitor_calls old records deleted|\n";}
		if ($teodDB) {$event_string = "vicidial_monitor_calls old records deleted($TDSQLdate): $affected_rows";   &teod_logger;}

		$stmtA = "optimize table vicidial_monitor_calls;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if ($DB) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();

		# set past holidays to EXPIRED status
		$stmtA = "UPDATE vicidial_call_time_holidays SET holiday_status='EXPIRED' where holiday_date < \"$RMdate\" and holiday_status!='EXPIRED';";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$affected_rows = $dbhA->do($stmtA);
		if($DB){print STDERR "\n|$affected_rows Holidays set to expired|\n";}
		if ($teodDB) {$event_string = "Holidays set to expired($RMdate): $affected_rows";   &teod_logger;}

		# roll campaign hour stats
		if (!$Q) {print "\nProcessing vicidial_campaign_hour_counts table...\n";}
		$stmtA = "INSERT IGNORE INTO vicidial_campaign_hour_counts_archive SELECT * from vicidial_campaign_hour_counts where date_hour < '$today_start';";
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		
		$sthArows = $sthA->rows;
		if (!$Q) {print "$sthArows rows inserted into vicidial_campaign_hour_counts_archive table \n";}
		
		$rv = $sthA->err();
		if (!$rv) 
			{	
			$stmtA = "DELETE FROM vicidial_campaign_hour_counts WHERE date_hour < '$today_start';";
			$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
			$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
			$sthArows = $sthA->rows;
			if (!$Q) {print "$sthArows rows deleted from vicidial_campaign_hour_counts table \n";}

			$stmtA = "optimize table vicidial_campaign_hour_counts;";
			$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
			$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
			}

		# roll vicidial_carrier_hour_counts
		if (!$Q) {print "\nProcessing vicidial_carrier_hour_counts table...\n";}
		$stmtA = "INSERT IGNORE INTO vicidial_carrier_hour_counts_archive SELECT * from vicidial_carrier_hour_counts where date_hour < '$today_start';";
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		
		$sthArows = $sthA->rows;
		if (!$Q) {print "$sthArows rows inserted into vicidial_carrier_hour_counts_archive table \n";}
		
		$rv = $sthA->err();
		if (!$rv) 
			{	
			$stmtA = "DELETE FROM vicidial_carrier_hour_counts WHERE date_hour < '$yesterday_start';";
			$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
			$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
			$sthArows = $sthA->rows;
			if (!$Q) {print "$sthArows rows deleted from vicidial_carrier_hour_counts table \n";}

			$stmtA = "optimize table vicidial_carrier_hour_counts;";
			$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
			$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
			}


		##### BEGIN max stats end of day process #####
		# set OPEN max stats records to CLOSING for processing
		$stmtA = "UPDATE vicidial_daily_max_stats SET stats_flag='CLOSING' where stats_flag='OPEN';";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$affected_rows = $dbhA->do($stmtA);
		if($DB){print STDERR "\n|$affected_rows Daily Max Stats Closing Process Started|\n";}
		if ($teodDB) {$event_string = "Daily Max Stats Closing Process Started: $affected_rows";   &teod_logger;}

		# gather data from CLOSING max stats records
		$stmtA = "SELECT stats_date,stats_flag,stats_type,campaign_id,update_time,closed_time,max_channels,max_calls,max_inbound,max_outbound,max_agents,max_remote_agents,total_calls from vicidial_daily_max_stats where stats_flag='CLOSING';";
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArowsDMS=$sthA->rows;
		$i=0;
		while ($sthArowsDMS > $i)
			{
			@aryA = $sthA->fetchrow_array;
			$Astats_date[$i]	= 		$aryA[0];
			$Astats_flag[$i]	= 		$aryA[1];
			$Astats_type[$i]	= 		$aryA[2];
			$Acampaign_id[$i]	= 		$aryA[3];
			$Aupdate_time[$i]	= 		$aryA[4];
			$Aclosed_time[$i]	= 		$aryA[5];
			$Amax_channels[$i]	= 		$aryA[6];
			$Amax_calls[$i]	= 			$aryA[7];
			$Amax_inbound[$i]	= 		$aryA[8];
			$Amax_outbound[$i]	= 		$aryA[9];
			$Amax_agents[$i]	= 		$aryA[10];
			$Amax_remote_agents[$i]	= 	$aryA[11];
			$Atotal_calls[$i]	= 		$aryA[12];

			if($DBXXX){print STDERR "\nMAX STATS: |$i|$Astats_date[$i]|$Astats_flag[$i]|$Astats_type[$i]|$Acampaign_id[$i]|$Aupdate_time[$i]|$Aclosed_time[$i]|$Amax_channels[$i]|$Amax_calls[$i]|$Amax_inbound[$i]|$Amax_outbound[$i]|$Amax_agents[$i]|$Amax_remote_agents[$i]|$Atotal_calls[$i]|\n";}
			if ($teodDB) {$event_string = "MAX STATS: |$i|$Astats_date[$i]|$Astats_flag[$i]|$Astats_type[$i]|$Acampaign_id[$i]|$Aupdate_time[$i]|$Aclosed_time[$i]|$Amax_channels[$i]|$Amax_calls[$i]|$Amax_inbound[$i]|$Amax_outbound[$i]|$Amax_agents[$i]|$Amax_remote_agents[$i]|$Atotal_calls[$i]|";   &teod_logger;}

			$i++;
			}
		$sthA->finish();

		### loop through CLOSING max stats records and calculate end of day numbers, updating if necessary
		$i=0;
		while ($sthArowsDMS > $i)
			{
			$NEWtotal_calls=0;
			$inbound_count=0;
			$outbound_count=0;
			### calculate total calls for system, did inbound and vicidial outbound
			if ($Astats_type[$i] =~ /TOTAL/)
				{
				$stmtA = "SELECT count(*) from vicidial_did_log where call_date >= \"$RMSQLdate\" and call_date < \"$now_date\";";
				$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
				$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
				$sthArows=$sthA->rows;
				if ($sthArows > 0)
					{
					@aryA = $sthA->fetchrow_array;
					$inbound_count =	$aryA[0];
					}
				$sthA->finish();
				if ($teodDB) {$event_string = "MAX STATS TOTAL DID INBOUND: |$stmtA|$inbound_count|";   &teod_logger;}

				$stmtA = "SELECT count(*) from vicidial_log where call_date >= \"$RMSQLdate\" and call_date < \"$now_date\";";
				$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
				$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
				$sthArows=$sthA->rows;
				if ($sthArows > 0)
					{
					@aryA = $sthA->fetchrow_array;
					$outbound_count =	$aryA[0];
					}
				$sthA->finish();
				if ($teodDB) {$event_string = "MAX STATS TOTAL OUTBOUND: |$stmtA|$outbound_count|";   &teod_logger;}
				$NEWtotal_calls = ($inbound_count + $outbound_count);

				$stmtA = "UPDATE vicidial_daily_max_stats SET total_calls='$NEWtotal_calls',stats_flag='CLOSED' where stats_flag='CLOSING' and campaign_id='' and stats_type='TOTAL';";
				if($DBX){print STDERR "\n|$stmtA|\n";}
				$affected_rows = $dbhA->do($stmtA);
				if($DB){print STDERR "\n|$affected_rows Daily Max Stats Closed for TOTAL: $NEWtotal_calls|$Atotal_calls[$i]\n";}
				if ($teodDB) {$event_string = "Daily Max Stats Closed for TOTAL: |$stmtA|$affected_rows|$NEWtotal_calls|$Atotal_calls[$i]|";   &teod_logger;}
				}
			### calculate total calls for ingroups
			if ($Astats_type[$i] =~ /INGROUP/)
				{
				$stmtA = "SELECT count(*) from vicidial_closer_log where call_date >= \"$RMSQLdate\" and call_date < \"$now_date\" and campaign_id='$Acampaign_id[$i]';";
				$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
				$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
				$sthArows=$sthA->rows;
				if ($sthArows > 0)
					{
					@aryA = $sthA->fetchrow_array;
					$inbound_count =	$aryA[0];
					}
				$sthA->finish();
				$NEWtotal_calls = $inbound_count;

				$stmtB = "UPDATE vicidial_daily_max_stats SET total_calls='$NEWtotal_calls',stats_flag='CLOSED' where stats_flag='CLOSING' and campaign_id='$Acampaign_id[$i]' and stats_type='INGROUP';";
				if($DBX){print STDERR "\n|$stmtB|\n";}
				$affected_rows = $dbhA->do($stmtB);
				if($DB){print STDERR "\n|$affected_rows Daily Max Stats Closed for INGROUP $Acampaign_id[$i]: $NEWtotal_calls|$Atotal_calls[$i]|\n";}
				if ($teodDB) {$event_string = "MAX STATS IN-GROUP INBOUND: |$stmtA|$inbound_count|$Acampaign_id[$i]|$stmtB|$affected_rows|";   &teod_logger;}
				}
			### calculate total calls for campaigns
			if ($Astats_type[$i] =~ /CAMPAIGN/)
				{
				$stmtA = "SELECT count(*) from vicidial_log where call_date >= \"$RMSQLdate\" and call_date < \"$now_date\" and campaign_id='$Acampaign_id[$i]';";
				$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
				$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
				$sthArows=$sthA->rows;
				if ($sthArows > 0)
					{
					@aryA = $sthA->fetchrow_array;
					$outbound_count =	$aryA[0];
					}
				$sthA->finish();
				$NEWtotal_calls = $outbound_count;

				$stmtB = "UPDATE vicidial_daily_max_stats SET total_calls='$NEWtotal_calls',stats_flag='CLOSED' where stats_flag='CLOSING' and campaign_id='$Acampaign_id[$i]' and stats_type='CAMPAIGN';";
				if($DBX){print STDERR "\n|$stmtB|\n";}
				$affected_rows = $dbhA->do($stmtB);
				if($DB){print STDERR "\n|$affected_rows Daily Max Stats Closed for CAMPAIGN $Acampaign_id[$i]: $NEWtotal_calls|$Atotal_calls[$i]|\n";}
				if ($teodDB) {$event_string = "MAX STATS CAMPAIGN OUTBOUND: |$stmtA|$outbound_count|$Acampaign_id[$i]|$stmtB|$affected_rows|";   &teod_logger;}
				}

			if($DBXXX){print STDERR "\nMAX STATS: |$i|$Astats_date[$i]|$Astats_flag[$i]|$Astats_type[$i]|$Acampaign_id[$i]|$Aupdate_time[$i]|$Aclosed_time[$i]|$Amax_channels[$i]|$Amax_calls[$i]|$Amax_inbound[$i]|$Amax_outbound[$i]|$Amax_agents[$i]|$Amax_remote_agents[$i]|$Atotal_calls[$i]|     |$NEWtotal_calls = ($inbound_count + $outbound_count)|\n";}
			if ($teodDB) {$event_string = "MAX STATS: |$i|$Astats_date[$i]|$Astats_flag[$i]|$Astats_type[$i]|$Acampaign_id[$i]|$Aupdate_time[$i]|$Aclosed_time[$i]|$Amax_channels[$i]|$Amax_calls[$i]|$Amax_inbound[$i]|$Amax_outbound[$i]|$Amax_agents[$i]|$Amax_remote_agents[$i]|$Atotal_calls[$i]|     |$NEWtotal_calls = ($inbound_count + $outbound_count)|";   &teod_logger;}

			$i++;
			}

		$stmtA = "UPDATE vicidial_daily_max_stats SET stats_flag='CLOSED' where stats_flag='CLOSING';";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$affected_rows = $dbhA->do($stmtA);
		if($DB){print STDERR "\n|$affected_rows Daily Max Stats Closed Cleanup|\n";}
		if ($teodDB) {$event_string = "Daily Max Stats Closed Cleanup: |$stmtA|$affected_rows|";   &teod_logger;}
		##### END max stats end of day process #####



		##### BEGIN ra stats end of day process #####
		# set OPEN ra stats records to CLOSING for processing
		$stmtA = "UPDATE vicidial_daily_ra_stats SET stats_flag='CLOSING' where stats_flag='OPEN';";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$affected_rows = $dbhA->do($stmtA);
		if($DB){print STDERR "\n|$affected_rows Daily RA Stats Closing Process Started|\n";}
		if ($teodDB) {$event_string = "Daily RA Stats Closing Process Started: |$stmtA|$affected_rows|";   &teod_logger;}

		# gather data from CLOSING ra stats records
		$stmtA = "SELECT stats_date,stats_flag,user,update_time,closed_time,max_calls,total_calls from vicidial_daily_ra_stats where stats_flag='CLOSING';";
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArowsDMS=$sthA->rows;
		$i=0;
		while ($sthArowsDMS > $i)
			{
			@aryA = $sthA->fetchrow_array;
			$Astats_date[$i]	= 		$aryA[0];
			$Astats_flag[$i]	= 		$aryA[1];
			$Auser[$i]	= 				$aryA[2];
			$Aupdate_time[$i]	= 		$aryA[3];
			$Aclosed_time[$i]	= 		$aryA[4];
			$Amax_calls[$i]	= 			$aryA[5];
			$Atotal_calls[$i]	= 		$aryA[6];

			if($DBXXX){print STDERR "\nRA MAX STATS: |$i|$Astats_date[$i]|$Astats_flag[$i]|$Auser[$i]|$Aupdate_time[$i]|$Aclosed_time[$i]|$Amax_calls[$i]|$Atotal_calls[$i]|\n";}
			if ($teodDB) {$event_string = "RA MAX STATS: |$i|$Astats_date[$i]|$Astats_flag[$i]|$Auser[$i]|$Aupdate_time[$i]|$Aclosed_time[$i]|$Amax_calls[$i]|$Atotal_calls[$i]|";   &teod_logger;}
			$i++;
			}
		$sthA->finish();

		$stmtA = "UPDATE vicidial_daily_ra_stats SET stats_flag='CLOSED' where stats_flag='CLOSING';";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$affected_rows = $dbhA->do($stmtA);
		if($DB){print STDERR "\n|$affected_rows Daily RA Stats Closed Cleanup|\n";}
		if ($teodDB) {$event_string = "Daily RA Stats Closed Cleanup: |$stmtA|$affected_rows|";   &teod_logger;}
		##### END ra stats end of day process #####


		##### BEGIN vicidial_ajax_log end of day process removing records older than 7 days #####
		$stmtA = "DELETE from vicidial_ajax_log where db_time < \"$SDSQLdate\";";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$affected_rows = $dbhA->do($stmtA);
		if($DB){print STDERR "\n|$affected_rows vicidial_ajax_log records older than 7 days purged|\n";}
		if ($teodDB) {$event_string = "vicidial_ajax_log records older than 7 days purged: |$stmtA|$affected_rows|";   &teod_logger;}

		$stmtA = "optimize table vicidial_ajax_log;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if ($DB) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();
		##### END vicidial_ajax_log end of day process removing records older than 7 days #####


		##### BEGIN vicidial_vdad_log end of day process removing records older than 7 days #####
		$stmtA = "DELETE from vicidial_vdad_log where db_time < \"$SDSQLdate\";";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$affected_rows = $dbhA->do($stmtA);
		if($DB){print STDERR "\n|$affected_rows vicidial_vdad_log records older than 7 days purged|\n";}
		if ($teodDB) {$event_string = "vicidial_vdad_log records older than 7 days purged: |$stmtA|$affected_rows|";   &teod_logger;}

		$stmtA = "optimize table vicidial_vdad_log;";
		if($DBX){print STDERR "\n|$stmtA|\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		@aryA = $sthA->fetchrow_array;
		if ($DB) {print "|",$aryA[0],"|",$aryA[1],"|",$aryA[2],"|",$aryA[3],"|","\n";}
		$sthA->finish();
		##### END vicidial_vdad_log end of day process removing records older than 7 days #####


		##### BEGIN usacan_phone_dialcode_fix funciton #####
		if ($usacan_phone_dialcode_fix > 0)
			{
			$stmtA = "UPDATE vicidial_list SET phone_code='1' where phone_code!='1';";
			if($DBX){print STDERR "\n|$stmtA|\n";}
			$PCaffected_rows = $dbhA->do($stmtA);
			if($DB){print STDERR "\n|$PCaffected_rows vicidial_list.phone_code entries set to 1|\n";}
			if ($teodDB) {$event_string = "vicidial_list.phone_code entries set to 1: |$stmtA|$PCaffected_rows|";   &teod_logger;}

			$stmtB = "UPDATE vicidial_list SET phone_number = TRIM(LEADING '1' from phone_number) where char_length(phone_number) > 10 and phone_number LIKE \"1%\";";
			if($DBX){print STDERR "\n|$stmtB|\n";}
			$PNaffected_rows = $dbhA->do($stmtB);
			if($DB){print STDERR "\n|$PNaffected_rows vicidial_list phone_number leading 1 entries trimmed|\n";}
			if ($teodDB) {$event_string = "vicidial_list phone_number leading 1 entries trimmed: |$stmtB|$PNaffected_rows|";   &teod_logger;}

			if ( ($PCaffected_rows > 0) or ($PNaffected_rows > 0) )
				{
				if ($DB) {print "restarting Asterisk process...\n";}
				$stmtA="INSERT INTO vicidial_admin_log set event_date=NOW(), user='VDAD', ip_address='1.1.1.1', event_section='SERVERS', event_type='MODIFY', record_id='leads', event_code='USACAN PHONE DIALCODE FIX', event_sql='', event_notes='$PCaffected_rows vicidial_list.phone_code entries set to 1|$PNaffected_rows vicidial_list phone_number leading 1 entries trimmed|';";
				$Laffected_rows = $dbhA->do($stmtA);
				if ($DBX) {print "Admin log of USACAN phone code fix: |$Laffected_rows|$stmtA|\n";}
				}
			}
		##### END usacan_phone_dialcode_fix funciton #####


		$dbhC = DBI->connect("DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port", "$VARDB_custom_user", "$VARDB_custom_pass")
		 or die "Couldn't connect to database: " . DBI->errstr;

		##### find MEMORY tables for reset of empty space #####
		$stmtA = "SHOW TABLE STATUS WHERE Engine='MEMORY';";
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		$i=0;
		while ($sthArows > $i)
			{
			@aryA = $sthA->fetchrow_array;
			$table_name	= 	$aryA[0];

			$stmtC = "ALTER TABLE $table_name ENGINE=MEMORY;";
			if($DBX){print STDERR "\n|$stmtC|\n";}
			$Caffected_rows = $dbhC->do($stmtC);
			if($DB){print STDERR "\n|$table_name memory reset $Caffected_rows rows|\n";}
			$i++;
			}
		$sthA->finish();
		}
	}

################################################################################
#####  END   clear out non-used vicidial_conferences sessions and reset daily
#####        tally tables
################################################################################





################################################################################
#####  START Creation of auto-generated conf files
################################################################################

if ( ($active_voicemail_server =~ /$server_ip/) && ((length($active_voicemail_server)) eq (length($server_ip))) )
	{
	$THISserver_voicemail=1;
	if ($DB) {print "   voicemail server configuration: $SSallow_voicemail_greeting|$sounds_update\n";}

	if ( !-e ('/etc/asterisk/voicemail.conf'))
		{`echo -e \"; END OF FILE\n\" > /etc/asterisk/voicemail.conf`;}
	if ( !-e ('/etc/asterisk/BUILDvoicemail-vicidial.conf'))
		{`echo -e \"; END OF FILE\n\" > /etc/asterisk/BUILDvoicemail-vicidial.conf`;}
	$vmCMP =  compare("/etc/asterisk/BUILDvoicemail-vicidial.conf","/etc/asterisk/voicemail.conf");
	if ($vmCMP > 0)
		{
		if ($DB) {print "starting voicemail configuration check\n";}
		################################################################################
		#####  START Parsing of the voicemail.conf file
		################################################################################
		# default path to voicemail configuration file:
		$VMCconf = '/etc/asterisk/voicemail.conf';

		open(vmc, "$VMCconf") || die "can't open $VMCconf: $!\n";
		@vmc = <vmc>;
		close(vmc);
		$i=0;
		$vm_header_content='';
		$vm_zones_content='';
		$boxes=9999999;
		$zones=9999;
		$zonesend=9999;
		$otherboxes=9999999;
		foreach(@vmc)
			{
			$line = $vmc[$i];
			$line =~ s/\n|\r//gi;
			if ( ($zones > 0) && ($i > $zones) && ($line =~ /\[/) )
				{
				$zonesend = $i;
				if ($DBXXX > 0) {print "voicemail zones end:     $zonesend\n";}
				}
			if ($line =~ /\[zonemessages\]/)
				{
				$zones = $i;
				if ($DBXXX > 0) {print "voicemail zones begin:   $zones\n";}
				}
			if ($line =~ /\[default\]/)
				{$boxes = $i;}
			if ($line =~ /^; Other Voicemail Entries/)
				{$otherboxes = $i;}
			### BEGIN parse through voicemail zonemessages
			if ( ($i > $zones) && ($i < $zonesend) )
				{
				if ( ($line !~ /^;/) && (length($line) > 5) )
					{
					$templine = $line;
					$templine =~ s/\|.*//gi;
					$vm_zones_content .= "$templine\n";
					if ($DBXXX > 0) {print "voicemail zones content:   $line\n";}
					}
				}
			### END parse through voicemail zonemessages

			### BEGIN parse through voicemail boxes and update DB with any changed settings
			if ($i > $boxes)
				{
				if ( ($line !~ /^;/) && (length($line) > 5) )
					{
					# 102 => 102,102a Mailbox,test@vicidial.com,,|delete=yes
					chomp($line);
					@parse_line = split(/ => /,$line);
					$mailbox = $parse_line[0];
					$mboptions = $parse_line[1];
					@options_line = split(/,/,$parse_line[1]);
					$vmc_pass = $options_line[0];
					$vmc_email = $options_line[2];
					$vmc_delete_vm_after_email='N';
					$vmc_voicemail_timezone="$SSdefault_voicemail_timezone";
					$vmc_voicemail_options='';
					if ($mboptions =~ /delete=yes/)
						{$vmc_delete_vm_after_email='Y';}
					if ($mboptions =~ /tz=/)
						{
						@options_sgmt = split(/tz=/,$mboptions);
						@tz_sgmt = split(/\|/,$options_sgmt[1]);
						$vmc_voicemail_timezone = $tz_sgmt[0];
						@options_sgmt = split(/tz=$vmc_voicemail_timezone\|/,$mboptions);
						$vmc_voicemail_options = $options_sgmt[1];
						}
					$sthArows=0;

					if ($i < $otherboxes)
						{
						$stmtA = "SELECT voicemail_id,pass,email,delete_vm_after_email,voicemail_timezone,voicemail_options FROM phones where voicemail_id='$mailbox' and active='Y' order by extension limit 1;";
						#	print "$stmtA\n";
						$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
						$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
						$sthArows=$sthA->rows;
						if ($sthArows > 0)
							{
							@aryA = $sthA->fetchrow_array;
							$mb_voicemail =				$aryA[0];
							$mb_pass =					$aryA[1];
							$mb_email =					$aryA[2];
							$mb_delete_vm_after_email =	$aryA[3];
							$mb_voicemail_timezone =	$aryA[4];
							$mb_voicemail_options =		$aryA[5];

							if ( ( ($mb_pass !~ /$vmc_pass/) || (length($mb_pass) != length($vmc_pass)) ) || ( ($mb_email !~ /$vmc_email/) || (length($mb_email) != length($vmc_email)) ) || ( ($mb_delete_vm_after_email !~ /$vmc_delete_vm_after_email/) || (length($mb_delete_vm_after_email) != length($vmc_delete_vm_after_email)) ) || ( ($mb_voicemail_timezone !~ /$vmc_voicemail_timezone/) || (length($mb_voicemail_timezone) != length($vmc_voicemail_timezone)) ) || ( ($mb_voicemail_options !~ /$vmc_voicemail_options/) || (length($mb_voicemail_options) != length($vmc_voicemail_options)) ) )
								{
								$stmtA="UPDATE phones SET pass='$vmc_pass',email='$vmc_email',delete_vm_after_email='$vmc_delete_vm_after_email',voicemail_timezone='$vmc_voicemail_timezone',voicemail_options='$vmc_voicemail_options' where voicemail_id='$mailbox' and active='Y' order by extension limit 1;";
								$affected_rows = $dbhA->do($stmtA);

								$stmtA="UPDATE servers SET rebuild_conf_files='Y' where server_ip='$server_ip';";
								$affected_rows = $dbhA->do($stmtA);
								}
							}
						$sthA->finish();
						}
					else
						{
						$stmtA = "SELECT voicemail_id,pass,email,delete_vm_after_email,voicemail_timezone,voicemail_options FROM vicidial_voicemail WHERE voicemail_id='$mailbox' and active='Y' limit 1;";
						#	print "$stmtA\n";
						$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
						$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
						$sthArows=$sthA->rows;
						if ($sthArows > 0)
							{
							@aryA = $sthA->fetchrow_array;
							$mb_voicemail =				$aryA[0];
							$mb_pass =					$aryA[1];
							$mb_email =					$aryA[2];
							$mb_delete_vm_after_email =	$aryA[3];
							$mb_voicemail_timezone =	$aryA[4];
							$mb_voicemail_options =		$aryA[5];

							if ( ( ($mb_pass !~ /$vmc_pass/) || (length($mb_pass) != length($vmc_pass)) ) || ( ($mb_email !~ /$vmc_email/) || (length($mb_email) != length($vmc_email)) ) || ( ($mb_delete_vm_after_email !~ /$vmc_delete_vm_after_email/) || (length($mb_delete_vm_after_email) != length($vmc_delete_vm_after_email)) ) || ( ($mb_voicemail_timezone !~ /$vmc_voicemail_timezone/) || (length($mb_voicemail_timezone) != length($vmc_voicemail_timezone)) ) || ( ($mb_voicemail_options !~ /$vmc_voicemail_options/) || (length($mb_voicemail_options) != length($vmc_voicemail_options)) ) )
								{
								$stmtA="UPDATE vicidial_voicemail SET pass='$vmc_pass',email='$vmc_email',delete_vm_after_email='$vmc_delete_vm_after_email',voicemail_timezone='$vmc_voicemail_timezone',voicemail_options='$vmc_voicemail_options' where voicemail_id='$mailbox' and active='Y' limit 1;";
								$affected_rows = $dbhA->do($stmtA);

								$stmtA="UPDATE servers SET rebuild_conf_files='Y' where server_ip='$server_ip';";
								$affected_rows = $dbhA->do($stmtA);
								}
							}
						$sthA->finish();
						}
					if ($sthArows < 1) 
						{
						if ($DB) {print "Mailbox not found: $mailbox     it will be removed from voicemail.conf\n";}
						}
					}
				### END parse through voicemail boxes and update DB with any changed settings
				}
			else
				{
				$vm_header_content .= "$line\n";
				}
			$i++;
			}
		if (length($SSvoicemail_timezones) != length($vm_zones_content)) 
			{
			$stmtA="UPDATE system_settings SET voicemail_timezones='$vm_zones_content';";
			$affected_rows = $dbhA->do($stmtA);
			if ($DB) {print "voicemail zones updated\n";}
			}
		################################################################################
		#####  END Parsing of the voicemail.conf file
		################################################################################
		}
	if (($SSallow_voicemail_greeting > 0) && ($sounds_update =~ /Y/) )
		{
		$stmtA = "SELECT voicemail_id,voicemail_greeting,count(*) FROM phones where voicemail_greeting != '' and voicemail_greeting is not NULL and active='Y' group by voicemail_id order by voicemail_id limit 10000;";
		#	print "$stmtA\n";
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		$vmb_ct=0;
		while ($sthArows > $vmb_ct)
			{
			@aryA = $sthA->fetchrow_array;
			$aVG_voicemail_id[$vmb_ct] =			$aryA[0];
			$aVG_voicemail_greeting[$vmb_ct] =		$aryA[1];
			$vmb_ct++;
			}

		$vmb_ct=0;
		while ($sthArows > $vmb_ct)
			{
			$VG_voicemail_id =				$aVG_voicemail_id[$vmb_ct];
			$VG_voicemail_greeting =		$aVG_voicemail_greeting[$vmb_ct];
			
			$gsm='.gsm';
			$wav='.wav';
			$audio_file_copied=0;
			$vm_dir_created=0;
			$vm_greet_wav_exists=0;
			$vm_greet_gsm_exists=0;
			$vm_delete_greeting=0;
			if ( !-e ("/var/spool/asterisk/voicemail/default/$VG_voicemail_id"))
				{
				`mkdir /var/spool/asterisk/voicemail/default/$VG_voicemail_id`;
				if ($DB) {print "voicemail directory created: /var/spool/asterisk/voicemail/default/$VG_voicemail_id/\n";}
				$vm_dir_created++;
				}
			if ( -e ("/var/lib/asterisk/sounds/$VG_voicemail_greeting$wav"))
				{
				$vm_greet_wav_exists++;
				}
			if ( -e ("/var/lib/asterisk/sounds/$VG_voicemail_greeting$gsm"))
				{
				$vm_greet_gsm_exists++;
				}
			if ($VG_voicemail_greeting =~ /---DELETE---/)
				{
				$vm_delete_greeting++;
				}

			if ( ($vm_dir_created < 1) && ( ($vm_greet_wav_exists > 0) || ($vm_greet_gsm_exists > 0) || ($vm_delete_greeting > 0) ) )
				{
				`rm -f /var/spool/asterisk/voicemail/default/$VG_voicemail_id/unavail.wav`;
				`rm -f /var/spool/asterisk/voicemail/default/$VG_voicemail_id/unavail.WAV`;
				`rm -f /var/spool/asterisk/voicemail/default/$VG_voicemail_id/unavail.gsm`;
				if ($DB) {print "cleared old voicemail greetings: $VG_voicemail_id\n";}
				}

			if ($vm_greet_wav_exists > 0)
				{
				`cp /var/lib/asterisk/sounds/$VG_voicemail_greeting$wav /var/spool/asterisk/voicemail/default/$VG_voicemail_id/unavail$wav`;
				$audio_file_copied++;
				}
			if ($vm_greet_gsm_exists > 0)
				{
				`cp /var/lib/asterisk/sounds/$VG_voicemail_greeting$gsm /var/spool/asterisk/voicemail/default/$VG_voicemail_id/unavail$gsm`;
				$audio_file_copied++;
				}
			if ($vm_delete_greeting > 0)
				{
				$stmtA="UPDATE phones SET voicemail_greeting='' where voicemail_greeting='---DELETE---' and voicemail_id='$VG_voicemail_id';";
				$affected_rows = $dbhA->do($stmtA);
				if ($DB) {print "resetting vm greeting file to empty: $VG_voicemail_id|$VG_voicemail_greeting|$affected_rows|$stmtA\n";}
				}

			if ($audio_file_copied < 1)
				{if ($DB) {print "no voicemail greeting copied: $VG_voicemail_id|$VG_voicemail_greeting\n";}}
			if ($DBX>0) {print "Custom Voicemail Greeting: $VG_voicemail_id|$VG_voicemail_greeting|$audio_file_copied\n";}

			$vmb_ct++;
			}

		$stmtA = "SELECT voicemail_id,voicemail_greeting,count(*) FROM vicidial_voicemail where voicemail_greeting != '' and voicemail_greeting is not NULL and active='Y' group by voicemail_id order by voicemail_id limit 10000;";
		#	print "$stmtA\n";
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		$vmb_ct=0;
		while ($sthArows > $vmb_ct)
			{
			@aryA = $sthA->fetchrow_array;
			$aVG_voicemail_id[$vmb_ct] =			$aryA[0];
			$aVG_voicemail_greeting[$vmb_ct] =		$aryA[1];
			$vmb_ct++;
			}

		$vmb_ct=0;
		while ($sthArows > $vmb_ct)
			{
			$VG_voicemail_id =				$aVG_voicemail_id[$vmb_ct];
			$VG_voicemail_greeting =		$aVG_voicemail_greeting[$vmb_ct];

			$gsm='.gsm';
			$wav='.wav';
			$audio_file_copied=0;
			$vm_dir_created=0;
			$vm_greet_wav_exists=0;
			$vm_greet_gsm_exists=0;
			$vm_delete_greeting=0;
			if ( !-e ("/var/spool/asterisk/voicemail/default/$VG_voicemail_id"))
				{
				`mkdir /var/spool/asterisk/voicemail/default/$VG_voicemail_id`;
				if ($DB) {print "voicemail directory created: /var/spool/asterisk/voicemail/default/$VG_voicemail_id/\n";}
				$vm_dir_created++;
				}
			if ( -e ("/var/lib/asterisk/sounds/$VG_voicemail_greeting$wav"))
				{
				$vm_greet_wav_exists++;
				}
			if ( -e ("/var/lib/asterisk/sounds/$VG_voicemail_greeting$gsm"))
				{
				$vm_greet_gsm_exists++;
				}
			if ($VG_voicemail_greeting =~ /---DELETE---/)
				{
				$vm_delete_greeting++;
				}

			if ( ($vm_dir_created < 1) && ( ($vm_greet_wav_exists > 0) || ($vm_greet_gsm_exists > 0) || ($vm_delete_greeting > 0) ) )
				{
				`rm -f /var/spool/asterisk/voicemail/default/$VG_voicemail_id/unavail.wav`;
				`rm -f /var/spool/asterisk/voicemail/default/$VG_voicemail_id/unavail.WAV`;
				`rm -f /var/spool/asterisk/voicemail/default/$VG_voicemail_id/unavail.gsm`;
				if ($DB) {print "cleared old voicemail greetings: $VG_voicemail_id\n";}
				}

			if ($vm_greet_wav_exists > 0)
				{
				`cp /var/lib/asterisk/sounds/$VG_voicemail_greeting$wav /var/spool/asterisk/voicemail/default/$VG_voicemail_id/unavail$wav`;
				$audio_file_copied++;
				}
			if ($vm_greet_gsm_exists > 0)
				{
				`cp /var/lib/asterisk/sounds/$VG_voicemail_greeting$gsm /var/spool/asterisk/voicemail/default/$VG_voicemail_id/unavail$gsm`;
				$audio_file_copied++;
				}
			if ($vm_delete_greeting > 0)
				{
				$stmtA="UPDATE vicidial_voicemail SET voicemail_greeting='' where voicemail_greeting='---DELETE---' and voicemail_id='$VG_voicemail_id';";
				$affected_rows = $dbhA->do($stmtA);
				if ($DB) {print "resetting vm greeting file to empty: $VG_voicemail_id|$VG_voicemail_greeting|$affected_rows|$stmtA\n";}
				}

			if ($audio_file_copied < 1)
				{if ($DB) {print "no voicemail greeting copied: $VG_voicemail_id|$VG_voicemail_greeting\n";}}
			if ($DBX>0) {print "Custom Voicemail Greeting: $VG_voicemail_id|$VG_voicemail_greeting|$audio_file_copied\n";}

			$vmb_ct++;
			}
		}
	}
else
	{
	$stmtA = "SELECT server_id FROM servers,system_settings where servers.server_ip=system_settings.active_voicemail_server;";
	#	print "$stmtA\n";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	if ($sthArows > 0)
		{
		@aryA = $sthA->fetchrow_array;
		$voicemail_server_id	=	$aryA[0];
		}
	$sthA->finish();
	}

if ( ($active_asterisk_server =~ /Y/) && ($generate_vicidial_conf =~ /Y/) && ($rebuild_conf_files =~ /Y/) ) 
	{
	if ($DB) {print "generating new auto-gen conf files\n";}

	$hangup_exten_line = 'exten => h,1,AGI(agi://127.0.0.1:4577/call_log--HVcauses--PRI-----NODEBUG-----${HANGUPCAUSE}-----${DIALSTATUS}-----${DIALEDTIME}-----${ANSWEREDTIME})';
	%ast_ver_str = parse_asterisk_version($asterisk_version);
	if ($DBX) {print "Asterisk version: $ast_ver_str{major} $ast_ver_str{minor}\n";}

	if (( $ast_ver_str{major} = 1 ) && ($ast_ver_str{minor} < 6))
		{
		$hangup_exten_line = 'exten => h,1,DeadAGI(agi://127.0.0.1:4577/call_log--HVcauses--PRI-----NODEBUG-----${HANGUPCAUSE}-----${DIALSTATUS}-----${DIALEDTIME}-----${ANSWEREDTIME})';
		}
	if (( $ast_ver_str{major} = 1 ) && ($ast_ver_str{minor} >= 12))
		{
		$hangup_exten_line = 'exten => h,1,AGI(agi://127.0.0.1:4577/call_log--HVcauses--PRI-----NODEBUG-----${HANGUPCAUSE}-----${DIALSTATUS}-----${DIALEDTIME}-----${ANSWEREDTIME}-----${HANGUPCAUSE(${HANGUPCAUSE_KEYS()},tech)}))';
		}

	$stmtA="UPDATE servers SET rebuild_conf_files='N' where server_ip='$server_ip';";
	$affected_rows = $dbhA->do($stmtA);

	### format the new server_ip dialstring for example to use with extensions.conf
	$S='*';
	if( $VARserver_ip =~ m/(\S+)\.(\S+)\.(\S+)\.(\S+)/ )
		{
		$a = leading_zero($1);
		$b = leading_zero($2);
		$c = leading_zero($3);
		$d = leading_zero($4);
		$VARremDIALstr = "$a$S$b$S$c$S$d";
		}

	$ext  .= "TRUNKloop = IAX2/ASTloop:$self_conf_secret\@127.0.0.1:40569\n";
	$ext  .= "TRUNKblind = IAX2/ASTblind:$self_conf_secret\@127.0.0.1:41569\n";
	$ext  .= "TRUNKplay = IAX2/ASTplay:$self_conf_secret\@127.0.0.1:42569\n";

	$iax  .= "register => ASTloop:$self_conf_secret\@127.0.0.1:40569\n";
	$iax  .= "register => ASTblind:$self_conf_secret\@127.0.0.1:41569\n";
	$iax  .= "register => ASTplay:$self_conf_secret\@127.0.0.1:42569\n";

	$Lext  = "\n";
	$Lext .= "; Local Server: $server_ip\n";
	$Lext .= "exten => _$VARremDIALstr*.,1,Goto(default,\${EXTEN:16},1)\n";
	$Lext .= "exten => _$VARremDIALstr*.,2,Hangup()\n";
	$Lext .= "exten => _**$VARremDIALstr*.,1,Goto(default,\${EXTEN:18},1)\n";
	$Lext .= "exten => _**$VARremDIALstr*.,2,Hangup()\n";
	$Lext .= "\n";
	%ast_ver_str = parse_asterisk_version($asterisk_version);
	if (( $ast_ver_str{major} = 1 ) && ($ast_ver_str{minor} < 6))
		{
		$Lext .= "; Agent session audio playback meetme entry\n";
		$Lext .= "exten => _473782178600XXX,1,Answer\n";
		$Lext .= "exten => _473782178600XXX,n,Meetme(\${EXTEN:8},Fq)\n";
		$Lext .= "exten => _473782178600XXX,n,Hangup()\n";
		$Lext .= "; Agent session audio playback loop\n";
		$Lext .= "exten => _473782168600XXX,1,Dial(\${TRUNKplay}/47378217\${EXTEN:8},5,To)\n";
		$Lext .= "exten => _473782168600XXX,n,Hangup()\n";
		$Lext .= "; Agent session audio playback extension\n";
		$Lext .= "exten => 473782158521111,1,Answer\n";
		$Lext .= "exten => 473782158521111,n,ControlPlayback(\${CALLERID(name)}|99999|0|1|2|3|4)\n";
		$Lext .= "exten => 473782158521111,n,Hangup()\n";
		$Lext .= "; SendDTMF to playback channel to control it\n";
		$Lext .= "exten => _473782148521111.,1,Answer\n";
		$Lext .= "exten => _473782148521111.,n,SendDTMF(\${CALLERID(num)}|250|250|IAX2/ASTplay-\${EXTEN:15})\n";
		$Lext .= "exten => _473782148521111.,n,Hangup()\n";
		$Lext .= "; Silent wait channel for DTMFsend\n";
		$Lext .= "exten => 473782138521111,1,Answer\n";
		$Lext .= "exten => 473782138521111,n,Wait(5)\n";
		$Lext .= "exten => 473782138521111,n,Hangup()\n";
		$Lext .= "; Whisper to agent meetme entry\n";
		$Lext .= "exten => _473782188600XXX,1,Answer\n";
		$Lext .= "exten => _473782188600XXX,n,Wait(1)\n";
		$Lext .= "exten => _473782188600XXX,n,AGI(getAGENTchannel.agi)\n";
		$Lext .= "exten => _473782188600XXX,n,NoOp(\${agent_zap_channel})\n";
		$Lext .= "exten => _473782188600XXX,n,GotoIf(\$[ \"\${agent_zap_channel}\" = \"101\" ]?fin)\n";
		$Lext .= "exten => _473782188600XXX,n,ChanSpy(\${agent_zap_channel},qw)\n";
		$Lext .= "exten => _473782188600XXX,n(fin),Hangup()\n";
		}
	else
		{
		$Lext .= "; Agent session audio playback meetme entry\n";
		$Lext .= "exten => _473782178600XXX,1,Meetme(\${EXTEN:8},q)\n";
		$Lext .= "exten => _473782178600XXX,n,Hangup()\n";
		$Lext .= "; Agent session audio playback loop\n";
		$Lext .= "exten => _473782168600XXX,1,Dial(\${TRUNKplay}/47378217\${EXTEN:8},5,To)\n";
		$Lext .= "exten => _473782168600XXX,n,Hangup()\n";
		$Lext .= "; Agent session audio playback extension\n";
		$Lext .= "exten => 473782158521111,1,Answer\n";
		$Lext .= "exten => 473782158521111,n,ControlPlayback(\${CALLERID(name)},99999,0,1,2,3,4)\n";
		$Lext .= "exten => 473782158521111,n,Hangup()\n";
		$Lext .= "; SendDTMF to playback channel to control it\n";
		$Lext .= "exten => _473782148521111.,1,Answer\n";
		$Lext .= "exten => _473782148521111.,n,SendDTMF(\${CALLERID(num)},250,250,IAX2/ASTplay-\${EXTEN:15})\n";
		$Lext .= "exten => _473782148521111.,n,Hangup()\n";
		$Lext .= "; Silent wait channel for DTMFsend\n";
		$Lext .= "exten => 473782138521111,1,Answer\n";
		$Lext .= "exten => 473782138521111,n,Wait(5)\n";
		$Lext .= "exten => 473782138521111,n,Hangup()\n";
		$Lext .= "; Whisper to agent meetme entry\n";
		$Lext .= "exten => _473782188600XXX,1,Answer\n";
		$Lext .= "exten => _473782188600XXX,n,Wait(1)\n";
		$Lext .= "exten => _473782188600XXX,n,AGI(getAGENTchannel.agi)\n";
		$Lext .= "exten => _473782188600XXX,n,NoOp(\${agent_zap_channel})\n";
		$Lext .= "exten => _473782188600XXX,n,GotoIf(\$[ \"\${agent_zap_channel}\" = \"101\" ]?fin)\n";
		$Lext .= "exten => _473782188600XXX,n,ChanSpy(\${agent_zap_channel},qw)\n";
		$Lext .= "exten => _473782188600XXX,n(fin),Hangup()\n";
		}

	$Liax .= "\n";
	$Liax .= "[ASTloop]\n";
	$Liax .= "accountcode=ASTloop\n";
	$Liax .= "secret=$self_conf_secret\n";
	$Liax .= "type=friend\n";
	$Liax .= "requirecalltoken=no\n";
	$Liax .= "context=default\n";
	$Liax .= "auth=plaintext\n";
	$Liax .= "host=dynamic\n";
	$Liax .= "permit=0.0.0.0/0.0.0.0\n";
	$Liax .= "disallow=all\n";
	$Liax .= "allow=alaw\n";
	if ($conf_qualify =~ /Y/) 
		{$Liax .= "qualify=yes\n";}

	$Liax .= "\n";
	$Liax .= "[ASTblind]\n";
	$Liax .= "accountcode=ASTblind\n";
	$Liax .= "secret=$self_conf_secret\n";
	$Liax .= "type=friend\n";
	$Liax .= "requirecalltoken=no\n";
	$Liax .= "context=default\n";
	$Liax .= "auth=plaintext\n";
	$Liax .= "host=dynamic\n";
	$Liax .= "permit=0.0.0.0/0.0.0.0\n";
	$Liax .= "disallow=all\n";
	$Liax .= "allow=alaw\n";
	if ($conf_qualify =~ /Y/) 
		{$Liax .= "qualify=yes\n";}

	$Liax .= "\n";
	$Liax .= "[ASTplay]\n";
	$Liax .= "accountcode=ASTplay\n";
	$Liax .= "secret=$self_conf_secret\n";
	$Liax .= "type=friend\n";
	$Liax .= "requirecalltoken=no\n";
	$Liax .= "context=default\n";
	$Liax .= "auth=plaintext\n";
	$Liax .= "host=dynamic\n";
	$Liax .= "permit=0.0.0.0/0.0.0.0\n";
	$Liax .= "disallow=all\n";
	$Liax .= "allow=alaw\n";
	if ($conf_qualify =~ /Y/) 
		{$Liax .= "qualify=yes\n";}


	##### Get the server_id for this server's server_ip #####
	$stmtA = "SELECT server_id,vicidial_recording_limit FROM servers where server_ip='$server_ip';";
	#	print "$stmtA\n";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	if ($sthArows > 0)
		{
		@aryA = $sthA->fetchrow_array;
		$server_id	=					$aryA[0];
		$vicidial_recording_limit =		(60 * $aryA[1]);
		$i++;
		}
	$sthA->finish();


	##### BEGIN Generate the server_ips and server_ids of all VICIDIAL servers on the network for load balancing #####
	$stmtA = "SELECT server_ip,server_id,conf_secret FROM servers where server_ip!='$server_ip' and active_asterisk_server='Y' order by server_ip;";
	#	print "$stmtA\n";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	$active_server_ips='';
	$active_dialplan_numbers='';
	$i=0;
	while ($sthArows > $i)
		{
		@aryA = $sthA->fetchrow_array;
		$server_ip[$i] =	$aryA[0];
		$server_id[$i] =	$aryA[1];
		$conf_secret[$i] =	$aryA[2];
		if ($i > 0)
			{$active_server_ips .= ",";}
		$active_server_ips .= "'$aryA[0]'";

		if( $server_ip[$i] =~ m/(\S+)\.(\S+)\.(\S+)\.(\S+)/ )
			{
			$a = leading_zero($1);
			$b = leading_zero($2);
			$c = leading_zero($3);
			$d = leading_zero($4);
			$VARremDIALstr = "$a$S$b$S$c$S$d";
			}
		$ext  .= "TRUNK$server_id[$i] = IAX2/$server_id:$conf_secret[$i]\@$server_ip[$i]:4569\n";

		$iax  .= "register => $server_id:$conf_secret[$i]\@$server_ip[$i]:4569\n";

		$Lext .= "; Remote Server VDAD extens: $server_id[$i] $server_ip[$i]\n";
		$Lext .= "exten => _$VARremDIALstr*.,1,Dial(\${TRUNK$server_id[$i]}/\${EXTEN:16},55,oT)\n";
		$Lext .= "exten => _$VARremDIALstr*.,2,Hangup()\n";
		$Lext .= "; Remote Server native bridge extens: $server_id[$i] $server_ip[$i]\n";
		$Lext .= "exten => _**$VARremDIALstr*.,1,Dial(\${TRUNK$server_id[$i]}/\${EXTEN:18},55,o)\n";
		$Lext .= "exten => _**$VARremDIALstr*.,2,Hangup()\n";

		$Liax .= "\n";
		$Liax .= "[$server_id[$i]]\n";
		$Liax .= "accountcode=IAX$server_id[$i]\n";
		$Liax .= "secret=$self_conf_secret\n";
		$Liax .= "type=friend\n";
		$Liax .= "requirecalltoken=no\n";
		$Liax .= "context=default\n";
		$Liax .= "auth=plaintext\n";
		$Liax .= "host=dynamic\n";
		$Liax .= "permit=0.0.0.0/0.0.0.0\n";
		$Liax .= "disallow=all\n";
		$Liax .= "allow=alaw\n";
		if ($conf_qualify =~ /Y/) 
			{$Liax .= "qualify=yes\n";}

		$i++;
		}
	$sthA->finish();
	##### END Generate the server_ips and server_ids of all VICIDIAL servers on the network for load balancing #####



	##### BEGIN Create Voicemail extensions for this server_ip #####
	if ( ($THISserver_voicemail > 0) || (length($voicemail_server_id) < 1) )
		{
		$Vext .= "; Voicemail Extensions:\n";
		$Vext .= "exten => _85026666666666.,1,Wait(1)\n";
		$Vext .= "exten => _85026666666666.,n,Voicemail(\${EXTEN:14},u)\n";
		$Vext .= "exten => _85026666666666.,n,Hangup()\n";
		$Vext .= "exten => _85026666666667.,1,Wait(1)\n";
		$Vext .= "exten => _85026666666667.,n,Voicemail(\${EXTEN:14},su)\n";
		$Vext .= "exten => _85026666666667.,n,Hangup()\n";
		$Vext .= "exten => 8500,1,VoicemailMain\n";
		$Vext .= "exten => 8500,2,Goto(s,6)\n";
		$Vext .= "exten => 8500,3,Hangup()\n";
		if ($asterisk_version =~ /^1.2/)
			{$Vext .= "exten => 8501,1,VoicemailMain(s\${CALLERIDNUM})\n";}
		else
			{$Vext .= "exten => 8501,1,VoicemailMain(s\${CALLERID(num)})\n";}
		$Vext .= "exten => 8501,2,Hangup()\n";
		$Vext .= "\n";
		$Vext .= "; Prompt Extensions:\n";
		$Vext .= "exten => 8167,1,Answer\n";
		$Vext .= "exten => 8167,2,AGI(agi-record_prompts.agi,wav-----720000)\n";
		$Vext .= "exten => 8167,3,Hangup()\n";
		$Vext .= "exten => 8168,1,Answer\n";
		$Vext .= "exten => 8168,2,AGI(agi-record_prompts.agi,gsm-----720000)\n";
		$Vext .= "exten => 8168,3,Hangup()\n";
		}
	else
		{
		$Vext .= "; Voicemail Extensions go to main voicemail server:\n";
		$Vext .= "exten => _85026666666666.,1,Dial(\${TRUNK$voicemail_server_id}/\${EXTEN},99,oT)\n";
		$Vext .= "exten => _85026666666667.,1,Dial(\${TRUNK$voicemail_server_id}/\${EXTEN},99,oT)\n";
		$Vext .= "exten => 8500,1,Dial(\${TRUNK$voicemail_server_id}/\${EXTEN},99,oT)\n";
		$Vext .= "exten => 8500,2,Hangup()\n";
		$Vext .= "exten => 8501,1,Dial(\${TRUNK$voicemail_server_id}/\${EXTEN},99,oT)\n";
		$Vext .= "exten => 8501,2,Hangup()\n";
		$Vext .= "\n";
		$Vext .= "; Prompt Extensions go to main voicemail server:\n";
		$Vext .= "exten => 8167,1,Dial(\${TRUNK$voicemail_server_id}/\${EXTEN},99,oT)\n";
		$Vext .= "exten => 8167,2,Hangup()\n";
		$Vext .= "exten => 8168,1,Dial(\${TRUNK$voicemail_server_id}/\${EXTEN},99,oT)\n";
		$Vext .= "exten => 8168,2,Hangup()\n";
		}

	$Vext .= "\n";
	$Vext .= "; this is used for recording conference calls, the client app sends the filename\n";
	$Vext .= ";    value as a callerID recordings go to /var/spool/asterisk/monitor (WAV)\n";
	$Vext .= ";    Recording is limited to 1 hour, to make longer, just change the server\n";
	$Vext .= ";    setting ViciDial Recording Limit\n";
	$Vext .= ";     this is the WAV verison, default\n";
	$Vext .= "exten => 8309,1,Answer\n";
	if ($asterisk_version =~ /^1.2/)
		{$Vext .= "exten => 8309,2,Monitor(wav,\${CALLERIDNAME})\n";}
	else
		{$Vext .= "exten => 8309,2,Monitor(wav,\${CALLERID(name)})\n";}
	$Vext .= "exten => 8309,3,Wait($vicidial_recording_limit)\n";
	$Vext .= "exten => 8309,4,Hangup()\n";
	$Vext .= ";     this is the GSM verison\n";
	$Vext .= "exten => 8310,1,Answer\n";
	if ($asterisk_version =~ /^1.2/)
		{$Vext .= "exten => 8310,2,Monitor(gsm,\${CALLERIDNAME})\n";}
	else
		{$Vext .= "exten => 8310,2,Monitor(gsm,\${CALLERID(name)})\n";}
	$Vext .= "exten => 8310,3,Wait($vicidial_recording_limit)\n";
	$Vext .= "exten => 8310,4,Hangup()\n";

	$Vext .= "\n;     agent alert extension\n";
	$Vext .= "exten => 83047777777777,1,Answer\n";
	if ($asterisk_version =~ /^1.2/)
		{$Vext .= "exten => 83047777777777,2,Playback(\${CALLERIDNAME})\n";}
	else
		{$Vext .= "exten => 83047777777777,2,Playback(\${CALLERID(name)})\n";}
	$Vext .= "exten => 83047777777777,3,Hangup()\n";

	$Vext .= "; This is a loopback dial-around to allow for immediate answer of outbound calls\n";
	$Vext .= "exten => _8305888888888888.,1,Answer\n";
	$Vext .= "exten => _8305888888888888.,n,Wait(\${EXTEN:16:1})\n";
	$Vext .= "exten => _8305888888888888.,n,Dial(\${TRUNKloop}/\${EXTEN:17},,To)\n";
	$Vext .= "exten => _8305888888888888.,n,Hangup()\n";
	$Vext .= "; No-call silence extension\n";
	$Vext .= "exten => _8305888888888888X999,1,Answer\n";
	$Vext .= "exten => _8305888888888888X999,n,Wait($vicidial_recording_limit)\n";
	$Vext .= "exten => _8305888888888888X999,n,Hangup()\n";
	$Vext .= "; In-Group Ask-Post-Call Survey AGI\n";
	$Vext .= "exten => _8306888888888888X999,1,Answer\n";
	$Vext .= "exten => _8306888888888888X999,n,AGI(agi-ingroup_survey.agi)\n";
	$Vext .= "exten => _8306888888888888X999,n,Hangup()\n";
	##### END Create Voicemail extensions for this server_ip #####



	##### BEGIN Generate the IAX carriers for this server_ip #####
	$stmtA = "SELECT carrier_id,carrier_name,registration_string,template_id,account_entry,globals_string,dialplan_entry,carrier_description FROM vicidial_server_carriers where server_ip IN('$server_ip','0.0.0.0') and active='Y' and protocol='IAX2' order by carrier_id;";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	$i=0;
	while ($sthArows > $i)
		{
		@aryA = $sthA->fetchrow_array;
		$carrier_id[$i]	=			$aryA[0];
		$carrier_name[$i]	=		$aryA[1];
		$registration_string[$i] =	$aryA[2];
		$template_id[$i] =			$aryA[3];
		$account_entry[$i] =		$aryA[4];
		$globals_string[$i] =		$aryA[5];
		$dialplan_entry[$i] =		$aryA[6];
		$carrier_description[$i] =	$aryA[7];
		$i++;
		}
	$sthA->finish();

	$i=0;
	while ($sthArows > $i)
		{
		$template_contents[$i]='';
		if ( (length($template_id[$i]) > 1) && ($template_id[$i] !~ /--NONE--/) ) 
			{
			$stmtA = "SELECT template_contents FROM vicidial_conf_templates where template_id='$template_id[$i]';";
			$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
			$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
			$sthBrows=$sthA->rows;
			if ($sthBrows > 0)
				{
				@aryA = $sthA->fetchrow_array;
				$template_contents[$i]	=	"$aryA[0]";
				}
			$sthA->finish();
			}
		$ext  .= "$globals_string[$i]\n";

		$iax  .= "$registration_string[$i]\n";

		$Lext .= "; VICIDIAL Carrier: $carrier_id[$i] - $carrier_name[$i]\n";
		if (length($carrier_description[$i]) > 0) {$Lext .= "; $carrier_description[$i]\n";}
		$Lext .= "$dialplan_entry[$i]\n";

		$Liax .= "; VICIDIAL Carrier: $carrier_id[$i] - $carrier_name[$i]\n";
		if (length($carrier_description[$i]) > 0) {$Liax .= "; $carrier_description[$i]\n";}
		$Liax .= "$account_entry[$i]\n";
		$Liax .= "$template_contents[$i]\n";

		$i++;
		}
	##### END Generate the IAX carriers for this server_ip #####



	##### BEGIN Generate the SIP carriers for this server_ip #####
	$stmtA = "SELECT carrier_id,carrier_name,registration_string,template_id,account_entry,globals_string,dialplan_entry,carrier_description FROM vicidial_server_carriers where server_ip IN('$server_ip','0.0.0.0') and active='Y' and protocol='SIP' order by carrier_id;";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	$i=0;
	while ($sthArows > $i)
		{
		@aryA = $sthA->fetchrow_array;
		$carrier_id[$i]	=			$aryA[0];
		$carrier_name[$i]	=		$aryA[1];
		$registration_string[$i] =	$aryA[2];
		$template_id[$i] =			$aryA[3];
		$account_entry[$i] =		$aryA[4];
		$globals_string[$i] =		$aryA[5];
		$dialplan_entry[$i] =		$aryA[6];
		$carrier_description[$i] =	$aryA[7];
		$i++;
		}
	$sthA->finish();

	$i=0;
	while ($sthArows > $i)
		{
		$template_contents[$i]='';
		if ( (length($template_id[$i]) > 1) && ($template_id[$i] !~ /--NONE--/) ) 
			{
			$stmtA = "SELECT template_contents FROM vicidial_conf_templates where template_id='$template_id[$i]';";
			$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
			$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
			$sthBrows=$sthA->rows;
			if ($sthBrows > 0)
				{
				@aryA = $sthA->fetchrow_array;
				$template_contents[$i]	=	"$aryA[0]";
				}
			$sthA->finish();
			}
		$ext  .= "$globals_string[$i]\n";

		$sip  .= "$registration_string[$i]\n";

		$Lext .= "; VICIDIAL Carrier: $carrier_id[$i] - $carrier_name[$i]\n";
		if (length($carrier_description[$i]) > 0) {$Lext .= "; $carrier_description[$i]\n";}
		$Lext .= "$dialplan_entry[$i]\n";

		$Lsip .= "; VICIDIAL Carrier: $carrier_id[$i] - $carrier_name[$i]\n";
		if (length($carrier_description[$i]) > 0) {$Lsip .= "; $carrier_description[$i]\n";}
		$Lsip .= "$account_entry[$i]\n";
		$Lsip .= "$template_contents[$i]\n";

		$i++;
		}
	##### BEGIN Generate the SIP carriers for this server_ip #####


	$Pext .= "\n";
	$Pext .= "; Phones direct dial extensions:\n";


	##### BEGIN Generate the IAX phone entries #####
	$stmtA = "SELECT extension,dialplan_number,voicemail_id,pass,template_id,conf_override,email,template_id,conf_override,outbound_cid,fullname,phone_context,phone_ring_timeout,conf_secret,delete_vm_after_email,codecs_list,codecs_with_template,voicemail_timezone,voicemail_options,voicemail_instructions,unavail_dialplan_fwd_exten,unavail_dialplan_fwd_context,conf_qualify FROM phones where server_ip='$server_ip' and protocol='IAX2' and active='Y' order by extension;";
	#	print "$stmtA\n";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	$i=0;
	while ($sthArows > $i)
		{
		@aryA = $sthA->fetchrow_array;
		$extension[$i] =				$aryA[0];
		$dialplan[$i] =					$aryA[1];
		$voicemail[$i] =				$aryA[2];
		$pass[$i] =						$aryA[3];
		$template_id[$i] =				$aryA[4];
		$conf_override[$i] =			$aryA[5];
		$email[$i] =					$aryA[6];
		$template_id[$i] =				$aryA[7];
		$conf_override[$i] =			$aryA[8];
		$outbound_cid[$i] =				$aryA[9];
		$fullname[$i] =					$aryA[10];
		$phone_context[$i] =			$aryA[11];
		$phone_ring_timeout[$i] =		$aryA[12];
		$conf_secret[$i] =				$aryA[13];
		$delete_vm_after_email[$i] =	$aryA[14];
		$codecs_list[$i] =				$aryA[15];
		$codecs_with_template[$i] =		$aryA[16];
		$voicemail_timezone[$i] =		$aryA[17];
		$voicemail_options[$i] =		$aryA[18];
		$voicemail_instructions[$i] =	$aryA[19];
		$unavail_dialplan_fwd_exten[$i] =	$aryA[20];
		$unavail_dialplan_fwd_context[$i] =	$aryA[21];
		$conf_qualify[$i] =				$aryA[22];
		if ( (length($SSdefault_codecs) > 2) && (length($codecs_list[$i]) < 3) )
			{$codecs_list[$i] = $SSdefault_codecs;}
		$active_dialplan_numbers .= "'$aryA[1]',";

		$i++;
		}
	$sthA->finish();

	$i=0;
	while ($sthArows > $i)
		{
		$conf_entry_written=0;
		$template_contents[$i]='';
		$Pcodec='';
		if (length($codecs_list[$i]) > 2)
			{
			if ($codecs_list[$i] =~ /gsm/i)			{$Pcodec .= "allow=gsm\n";}
			if ($codecs_list[$i] =~ /alaw|a-law/i)	{$Pcodec .= "allow=alaw\n";}
			if ($codecs_list[$i] =~ /ulaw|u-law/i)	{$Pcodec .= "allow=ulaw\n";}
			if ($codecs_list[$i] =~ /g722|g\.722/i)	{$Pcodec .= "allow=g722\n";}
			if ($codecs_list[$i] =~ /g723|g\.723/i)	{$Pcodec .= "allow=g723.1\n";}
			if ($codecs_list[$i] =~ /g726|g\.726/i)	{$Pcodec .= "allow=g726\n";}
			if ($codecs_list[$i] =~ /g729|g\.729/i)	{$Pcodec .= "allow=g729\n";}
			if ($codecs_list[$i] =~ /ilbc/i)		{$Pcodec .= "allow=ilbc\n";}
			if ($codecs_list[$i] =~ /lpc10/i)		{$Pcodec .= "allow=lpc10\n";}
			if ($codecs_list[$i] =~ /speex/i)		{$Pcodec .= "allow=speex\n";}
			if ($codecs_list[$i] =~ /adpcm/i)		{$Pcodec .= "allow=adpcm\n";}
			if (length($Pcodec) > 2)
				{$Pcodec = "disallow=all\n$Pcodec";}
			}
		if ($DBXXX > 0) {print "IAX|$extension[$i]|$codecs_list[$i]|$Pcodec\n";}

		if ( (length($template_id[$i]) > 1) && ($template_id[$i] !~ /--NONE--/) ) 
			{
			$stmtA = "SELECT template_contents FROM vicidial_conf_templates where template_id='$template_id[$i]';";
			$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
			$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
			$sthBrows=$sthA->rows;
			if ($sthBrows > 0)
				{
				@aryA = $sthA->fetchrow_array;
				$template_contents[$i]	=	"$aryA[0]";

				$Piax .= "\n\[$extension[$i]\]\n";
				$Piax .= "username=$extension[$i]\n";
				$Piax .= "secret=$conf_secret[$i]\n";
				$Piax .= "accountcode=$extension[$i]\n";
				if ( (length($fullname[$i])>0) || (length($outbound_cid[$i])>0) ) 
					{
					$Piax .= "callerid=\"$fullname[$i]\" <$outbound_cid[$i]>\n";
					}
				$Piax .= "mailbox=$voicemail[$i]\n";
				if ($conf_qualify[$i] =~ /Y/) 
					{$Piax .= "qualify=yes\n";}
				if ($codecs_with_template[$i] > 0) 
					{$Piax .= "$Pcodec";}
				$Piax .= "$template_contents[$i]\n";
				
				$conf_entry_written++;
				}
			$sthA->finish();
			}
		if (length($conf_override[$i]) > 10)
			{
			if ($conf_entry_written < 1) 
				{$Piax .= "\n\[$extension[$i]\]\n";}
			$Piax .= "$conf_override[$i]\n";
			$conf_entry_written++;
			}
		if ($conf_entry_written < 1)
			{
			$Piax .= "\n\[$extension[$i]\]\n";
			$Piax .= "username=$extension[$i]\n";
			$Piax .= "secret=$conf_secret[$i]\n";
			$Piax .= "accountcode=$extension[$i]\n";
			if ( (length($fullname[$i])>0) || (length($outbound_cid[$i])>0) ) 
				{
				$Piax .= "callerid=\"$fullname[$i]\" <$outbound_cid[$i]>\n";
				}
			$Piax .= "mailbox=$voicemail[$i]\n";
			$Piax .= "requirecalltoken=no\n";
			$Piax .= "context=$phone_context[$i]\n";
			$Piax .= "$Pcodec";
			$Piax .= "type=friend\n";
			$Piax .= "auth=md5\n";
			$Piax .= "host=dynamic\n";
			if ($conf_qualify[$i] =~ /Y/) 
				{$Piax .= "qualify=yes\n";}
			}
		%ast_ver_str = parse_asterisk_version($asterisk_version);
		if (( $ast_ver_str{major} = 1 ) && ($ast_ver_str{minor} < 6))
			{
			$Pext .= "exten => $dialplan[$i],1,Dial(IAX2/$extension[$i]|$phone_ring_timeout[$i]|)\n";
			}
		else
			{
			$Pext .= "exten => $dialplan[$i],1,Dial(IAX2/$extension[$i],$phone_ring_timeout[$i],)\n";
			}
		if (length($unavail_dialplan_fwd_exten[$i]) > 0) 
			{
			if (length($unavail_dialplan_fwd_context[$i]) < 1) 
				{$unavail_dialplan_fwd_context[$i] = 'default';}
			$Pext .= "exten => $dialplan[$i],2,Goto($unavail_dialplan_fwd_context[$i],$unavail_dialplan_fwd_exten[$i],1)\n";
			}
		else
			{
			if ($voicemail_instructions[$i] =~ /Y/)
				{
				$Pext .= "exten => $dialplan[$i],2,Goto(default,85026666666666$voicemail[$i],1)\n";
				}
			else
				{
				$Pext .= "exten => $dialplan[$i],2,Goto(default,85026666666667$voicemail[$i],1)\n";
				}
			}
		if (!(( $ast_ver_str{major} = 1 ) && ($ast_ver_str{minor} < 6)))
			{
			$Pext .= "exten => $dialplan[$i],3,Hangup()\n";
			}

		if ($delete_vm_after_email[$i] =~ /Y/)
			{$vm  .= "$voicemail[$i] => $pass[$i],$extension[$i] Mailbox,$email[$i],,|delete=yes|tz=$voicemail_timezone[$i]|$voicemail_options[$i]\n";}
		else
			{$vm  .= "$voicemail[$i] => $pass[$i],$extension[$i] Mailbox,$email[$i],,|delete=no|tz=$voicemail_timezone[$i]|$voicemail_options[$i]\n";}

		$i++;
		}
	##### END Generate the IAX phone entries #####



	##### BEGIN Generate the SIP phone entries #####
	$stmtA = "SELECT extension,dialplan_number,voicemail_id,pass,template_id,conf_override,email,template_id,conf_override,outbound_cid,fullname,phone_context,phone_ring_timeout,conf_secret,delete_vm_after_email,codecs_list,codecs_with_template,voicemail_timezone,voicemail_options,voicemail_instructions,unavail_dialplan_fwd_exten,unavail_dialplan_fwd_context FROM phones where server_ip='$server_ip' and protocol='SIP' and active='Y' order by extension;";
	#	print "$stmtA\n";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	$i=0;
	while ($sthArows > $i)
		{
		@aryA = $sthA->fetchrow_array;
		$extension[$i] =				$aryA[0];
		$dialplan[$i] =					$aryA[1];
		$voicemail[$i] =				$aryA[2];
		$pass[$i] =						$aryA[3];
		$template_id[$i] =				$aryA[4];
		$conf_override[$i] =			$aryA[5];
		$email[$i] =					$aryA[6];
		$template_id[$i] =				$aryA[7];
		$conf_override[$i] =			$aryA[8];
		$outbound_cid[$i] =				$aryA[9];
		$fullname[$i] =					$aryA[10];
		$phone_context[$i] =			$aryA[11];
		$phone_ring_timeout[$i] =		$aryA[12];
		$conf_secret[$i] =				$aryA[13];
		$delete_vm_after_email[$i] =	$aryA[14];
		$codecs_list[$i] =				$aryA[15];
		$codecs_with_template[$i] =		$aryA[16];
		$voicemail_timezone[$i] =		$aryA[17];
		$voicemail_options[$i] =		$aryA[18];
		$voicemail_instructions[$i] =	$aryA[19];
		$unavail_dialplan_fwd_exten[$i] =	$aryA[20];
		$unavail_dialplan_fwd_context[$i] =	$aryA[21];
		if ( (length($SSdefault_codecs) > 2) && (length($codecs_list[$i]) < 3) )
			{$codecs_list[$i] = $SSdefault_codecs;}
		$active_dialplan_numbers .= "'$aryA[1]',";

		$i++;
		}
	$sthA->finish();

	$i=0;
	while ($sthArows > $i)
		{
		$conf_entry_written=0;
		$template_contents[$i]='';
		$Pcodec='';
		if (length($codecs_list[$i]) > 2)
			{
			if ($codecs_list[$i] =~ /gsm/i)			{$Pcodec .= "allow=gsm\n";}
			if ($codecs_list[$i] =~ /alaw|a-law/i)	{$Pcodec .= "allow=alaw\n";}
			if ($codecs_list[$i] =~ /ulaw|u-law/i)	{$Pcodec .= "allow=ulaw\n";}
			if ($codecs_list[$i] =~ /g722|g\.722/i)	{$Pcodec .= "allow=g722\n";}
			if ($codecs_list[$i] =~ /g723|g\.723/i)	{$Pcodec .= "allow=g723.1\n";}
			if ($codecs_list[$i] =~ /g726|g\.726/i)	{$Pcodec .= "allow=g726\n";}
			if ($codecs_list[$i] =~ /g729|g\.729/i)	{$Pcodec .= "allow=g729\n";}
			if ($codecs_list[$i] =~ /ilbc/i)		{$Pcodec .= "allow=ilbc\n";}
			if ($codecs_list[$i] =~ /lpc10/i)		{$Pcodec .= "allow=lpc10\n";}
			if ($codecs_list[$i] =~ /speex/i)		{$Pcodec .= "allow=speex\n";}
			if ($codecs_list[$i] =~ /adpcm/i)		{$Pcodec .= "allow=adpcm\n";}
			if (length($Pcodec) > 2)
				{$Pcodec = "disallow=all\n$Pcodec";}
			}
		if ($DBXXX > 0) {print "SIP|$extension[$i]|$codecs_list[$i]|$Pcodec\n";}

		if ( (length($template_id[$i]) > 1) && ($template_id[$i] !~ /--NONE--/) ) 
			{
			$stmtA = "SELECT template_contents FROM vicidial_conf_templates where template_id='$template_id[$i]';";
			$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
			$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
			$sthBrows=$sthA->rows;
			if ($sthBrows > 0)
				{
				@aryA = $sthA->fetchrow_array;
				$template_contents[$i]	=	"$aryA[0]";

				$Psip .= "\n\[$extension[$i]\]\n";
				$Psip .= "username=$extension[$i]\n";
				$Psip .= "secret=$conf_secret[$i]\n";
				$Psip .= "accountcode=$extension[$i]\n";
				if ( (length($fullname[$i])>0) || (length($outbound_cid[$i])>0) ) 
					{
					$Psip .= "callerid=\"$fullname[$i]\" <$outbound_cid[$i]>\n";
					}
				$Psip .= "mailbox=$voicemail[$i]\n";
				if ($codecs_with_template[$i] > 0) 
					{$Psip .= "$Pcodec";}
				$Psip .= "$template_contents[$i]\n";
				
				$conf_entry_written++;
				}
			$sthA->finish();
			}
		if (length($conf_override[$i]) > 10)
			{
			if ($conf_entry_written < 1) 
				{$Psip .= "\n\[$extension[$i]\]\n";}
			$Psip .= "$conf_override[$i]\n";
			$conf_entry_written++;
			}
		if ($conf_entry_written < 1)
			{
			$Psip .= "\n\[$extension[$i]\]\n";
			$Psip .= "username=$extension[$i]\n";
			$Psip .= "secret=$conf_secret[$i]\n";
			$Psip .= "accountcode=$extension[$i]\n";
			if ( (length($fullname[$i])>0) || (length($outbound_cid[$i])>0) ) 
				{
				$Psip .= "callerid=\"$fullname[$i]\" <$outbound_cid[$i]>\n";
				}
			$Psip .= "mailbox=$voicemail[$i]\n";
			$Psip .= "context=$phone_context[$i]\n";
			$Psip .= "$Pcodec";
			$Psip .= "type=friend\n";
			$Psip .= "host=dynamic\n";
			}
		%ast_ver_str = parse_asterisk_version($asterisk_version);
		if (( $ast_ver_str{major} = 1 ) && ($ast_ver_str{minor} < 6))
			{
			$Pext .= "exten => $dialplan[$i],1,Dial(SIP/$extension[$i]|$phone_ring_timeout[$i]|)\n";
			}
		else
			{
			$Pext .= "exten => $dialplan[$i],1,Dial(SIP/$extension[$i],$phone_ring_timeout[$i],)\n";
			}
		if (length($unavail_dialplan_fwd_exten[$i]) > 0) 
			{
			if (length($unavail_dialplan_fwd_context[$i]) < 1) 
				{$unavail_dialplan_fwd_context[$i] = 'default';}
			$Pext .= "exten => $dialplan[$i],2,Goto($unavail_dialplan_fwd_context[$i],$unavail_dialplan_fwd_exten[$i],1)\n";
			}
		else
			{
			if ($voicemail_instructions[$i] =~ /Y/)
				{
				$Pext .= "exten => $dialplan[$i],2,Goto(default,85026666666666$voicemail[$i],1)\n";
				}
			else
				{
				$Pext .= "exten => $dialplan[$i],2,Goto(default,85026666666667$voicemail[$i],1)\n";
				}
			}
		if (!(( $ast_ver_str{major} = 1 ) && ($ast_ver_str{minor} < 6)))
			{
			$Pext .= "exten => $dialplan[$i],3,Hangup()\n";
			}

		if ($delete_vm_after_email[$i] =~ /Y/)
			{$vm  .= "$voicemail[$i] => $pass[$i],$extension[$i] Mailbox,$email[$i],,|delete=yes|tz=$voicemail_timezone[$i]|$voicemail_options[$i]\n";}
		else
			{$vm  .= "$voicemail[$i] => $pass[$i],$extension[$i] Mailbox,$email[$i],,|delete=no|tz=$voicemail_timezone[$i]|$voicemail_options[$i]\n";}

		$i++;
		}
	##### END Generate the SIP phone entries #####



	if ( ($SSgenerate_cross_server_exten > 0) and (length($active_server_ips) > 7) )
		{
		##### BEGIN Generate the CROSS SERVER IAX and SIP phone entries #####
		$stmtA = "SELECT extension,dialplan_number,fullname,server_ip FROM phones where server_ip NOT IN('$server_ip') and server_ip IN($active_server_ips) and dialplan_number NOT IN($active_dialplan_numbers'') and protocol IN('SIP','IAX2') and active='Y' order by dialplan_number,server_ip;";
		#	print "$stmtA\n";
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		$i=0;
		while ($sthArows > $i)
			{
			@aryA = $sthA->fetchrow_array;
			$CXextension[$i] =				$aryA[0];
			$CXdialplan[$i] =				$aryA[1];
			$CXfullname[$i] =				$aryA[2];
			$CXserver_ip[$i] =				$aryA[3];

			$i++;
			}
		$sthA->finish();

		$i=0;
		while ($sthArows > $i)
			{
			$CXVARremDIALstr='';
			if( $CXserver_ip[$i] =~ m/(\S+)\.(\S+)\.(\S+)\.(\S+)/ )
				{
				$a = leading_zero($1);
				$b = leading_zero($2);
				$c = leading_zero($3);
				$d = leading_zero($4);
				$CXVARremDIALstr = "$a$S$b$S$c$S$d$S";
				}
			$Pext .= "; Remote Phone Entry $i: $CXextension[$i] $CXserver_ip[$i] $CXfullname[$i]\n";
			$Pext .= "exten => $CXdialplan[$i],1,Goto(default,$CXVARremDIALstr$CXdialplan[$i],1)\n";

			$i++;
			}
		##### END Generate the CROSS SERVER IAX and SIP phone entries #####
		}


	##### BEGIN Generate custom meetme entries if set #####
	$meetme_custom_ext='';
	if ( (length($meetme_enter_login_filename) > 0) || (length($meetme_enter_leave3way_filename) > 0) ) 
		{
		if (length($meetme_enter_login_filename) < 1) {$meetme_enter_login_filename='sip-silence';}
		if (length($meetme_enter_leave3way_filename) < 1) {$meetme_enter_leave3way_filename='sip-silence';}

		$meetme_custom_ext .= '[meetme-enter-login]';
		$meetme_custom_ext .= "\n; meetme entry for Vicidial agent logging in, Asterisk 1.8+ compatible only\n";
		$meetme_custom_ext .= "exten => _8600XXX,1,Meetme(\${EXTEN},FG($meetme_enter_login_filename))\n";
		$meetme_custom_ext .= "exten => _8600XXX,n,Hangup()\n";
		$meetme_custom_ext .= "\n";
		$meetme_custom_ext .= $hangup_exten_line;
		$meetme_custom_ext .= "\n\n";
		$meetme_custom_ext .= '[meetme-enter-leave3way]';
		$meetme_custom_ext .= "\n; meetme entry for Vicidial agent leaving 3way call, Asterisk 1.8+ compatible only\n";
		$meetme_custom_ext .= "exten => _8600XXX,1,Meetme(\${EXTEN},FG($meetme_enter_leave3way_filename))\n";
		$meetme_custom_ext .= "exten => _8600XXX,n,Hangup()\n";
		$meetme_custom_ext .= "\n";
		$meetme_custom_ext .= $hangup_exten_line;
		$meetme_custom_ext .= "\n\n";

		if ($DBX>0) {print "Custom Meetme login and leave3way entries generated: |$meetme_enter_login_filename|$meetme_enter_leave3way_filename|\n";}
		}
	##### END Generate custom meetme entries if set #####


	##### BEGIN Generate the Call Menu entries #####
	$stmtA = "SELECT menu_id,menu_name,menu_prompt,menu_timeout,menu_timeout_prompt,menu_invalid_prompt,menu_repeat,menu_time_check,call_time_id,track_in_vdac,custom_dialplan_entry,tracking_group,dtmf_log,dtmf_field,qualify_sql,alt_dtmf_log,question FROM vicidial_call_menu order by menu_id;";
	#	print "$stmtA\n";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	$i=0;
	while ($sthArows > $i)
		{
		@aryA = $sthA->fetchrow_array;
		$menu_id[$i] =				$aryA[0];
		$menu_name[$i] =			$aryA[1];
		$menu_prompt[$i] =			$aryA[2];
		$menu_timeout[$i] =			$aryA[3];
		$menu_timeout_prompt[$i] =	$aryA[4];
		$menu_invalid_prompt[$i] =	$aryA[5];
		$menu_repeat[$i] =			$aryA[6];
		$menu_time_check[$i] =		$aryA[7];
		$call_time_id[$i] =			$aryA[8];
		$track_in_vdac[$i] =		$aryA[9];
		$custom_dialplan_entry[$i]= $aryA[10];
		$tracking_group[$i] =		$aryA[11];
		$dtmf_log[$i] =				$aryA[12];
		$dtmf_field[$i] =			$aryA[13];
		$qualify_sql[$i] =			$aryA[14];
		$alt_dtmf_log[$i] =			$aryA[15];
		$question[$i] =				$aryA[16];

		if ($track_in_vdac[$i] > 0)
			{$track_in_vdac[$i] = 'YES';}
		else
			{$track_in_vdac[$i] = 'NO';}
		if ( (length($qualify_sql[$i]) > 5) && ($SScall_menu_qualify_enabled > 0) )
			{$qualify_sql_active[$i] = 'YES';}
		else
			{$qualify_sql_active[$i] = 'NO';}
		$i++;
		}
	$sthA->finish();

	$i=0;
	$call_menu_ext = '';
	$CM_agi_string='';
	while ($sthArows > $i)
		{
		$stmtA = "SELECT option_value,option_description,option_route,option_route_value,option_route_value_context FROM vicidial_call_menu_options where menu_id='$menu_id[$i]' order by option_value;";
		#	print "$stmtA\n";
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArowsJ=$sthA->rows;
		$j=0;
		$time_check_scheme = '';
		$time_check_route = '';
		$time_check_route_value = '';
		$time_check_route_context = '';
		$call_menu_timeout_ext = '';
		$call_menu_invalid_ext = '';
		$call_menu_options_ext = '';
		$cm_invalid_set=0;
		$cm_timeout_set=0;
		if ($DBX>0) {print "$sthArowsJ|$stmtA\n";}
		while ($sthArowsJ > $j)
			{
			@aryA = $sthA->fetchrow_array;
			$option_value[$j] =					$aryA[0];
			$option_description[$j] =			$aryA[1];
			$option_route[$j] =					$aryA[2];
			$option_route_value[$j] =			$aryA[3];
			$option_route_value_context[$j] =	$aryA[4];
			if ($option_value[$j] =~ /STAR/) {$option_value[$j] = '*';}
			if ($option_value[$j] =~ /HASH/) {$option_value[$j] = '#';}
			$j++;
			}

		$j=0;
		while ($sthArowsJ > $j)
			{
			$PRI=1;
			$call_menu_line='';
			if ( ($option_value[$j] =~ /TIMECHECK/) && ($menu_time_check[$i] > 0) && (length($call_time_id[$i])>0) )
				{
				$time_check_scheme =			$call_time_id[$i];
				$time_check_route =				$option_route[$j];
				$time_check_route_value =		$option_route_value[$j];
				$time_check_route_context =		$option_route_value_context[$j];

				if ($option_route[$j] =~ /INGROUP/)
					{
					@IGoption_route_value_context = split(/,/,$option_route_value_context[$j]);
					$IGhandle_method =			$IGoption_route_value_context[0];
					$IGsearch_method =			$IGoption_route_value_context[1];
					$IGlist_id =				$IGoption_route_value_context[2];
					$IGcampaign_id =			$IGoption_route_value_context[3];
					$IGphone_code =				$IGoption_route_value_context[4];
					$IGvid_enter_filename =		$IGoption_route_value_context[5];
					$IGvid_id_number_filename =	$IGoption_route_value_context[6];
					$IGvid_confirm_filename =	$IGoption_route_value_context[7];
					$IGvid_validate_digits =	$IGoption_route_value_context[8];

					$CM_agi_string = "agi-VDAD_ALL_inbound.agi,$IGhandle_method-----$IGsearch_method-----$option_route_value[$j]-----$menu_id[$i]--------------------$IGlist_id-----$IGphone_code-----$IGcampaign_id---------------$IGvid_enter_filename-----$IGvid_id_number_filename-----$IGvid_confirm_filename-----$IGvid_validate_digits";
					}
				}
			else
				{
				if (length($option_description[$j])>0)
					{
					$call_menu_line .= "; $option_description[$j]\n";
					}
				if ($option_value[$j] =~ /TIMEOUT/)
					{
					$option_value[$j] = 't';
					if ( (length($menu_timeout_prompt[$i])>0)  && ($menu_timeout_prompt[$i] !~ /NONE/) )
						{
						$menu_timeout_prompt_ext='';
						if ($menu_timeout_prompt[$i] =~ /\|/)
							{
							@menu_timeout_prompts_array = split(/\|/,$menu_timeout_prompt[$i]);
							$w=0;
							foreach(@menu_timeout_prompts_array)
								{
								if (length($menu_timeout_prompts_array[$w])>0)
									{
									$menu_timeout_prompt_ext .= "exten => t,$PRI,Playback($menu_timeout_prompts_array[$w])\n";
									$PRI++;
									}
								$w++;
								}
							}
						else
							{
							$menu_timeout_prompt_ext .= "exten => t,1,Playback($menu_timeout_prompt[$i])\n";
							$PRI++;
							}

						$call_menu_line .= "$menu_timeout_prompt_ext";
						$cm_timeout_set++;
						}
					}
				if ($option_value[$j] =~ /INVALID/)
					{
					$menu_invalid_prompt_ext='';
					if ( (length($menu_invalid_prompt[$i])>0) && ($menu_invalid_prompt[$i] !~ /NONE/) )
						{
						if ($menu_invalid_prompt[$i] =~ /\|/)
							{
							@menu_invalid_prompts_array = split(/\|/,$menu_invalid_prompt[$i]);
							$w=0;
							foreach(@menu_invalid_prompts_array)
								{
								if (length($menu_invalid_prompts_array[$w])>0)
									{
									$menu_invalid_prompt_ext .= "exten => i,$PRI,Playback($menu_invalid_prompts_array[$w])\n";
									$PRI++;
									}
								$w++;
								}
							}
						else
							{
							$menu_invalid_prompt_ext .= "exten => i,1,Playback($menu_invalid_prompt[$i])\n";
							$PRI++;
							}

						}
					if ( ($option_value[$j] =~ /INVALID_2ND/) && ($cm_invalid_set < 1) )
						{
						$menu_invalid_prompt_ext .= "exten => i,$PRI,Set(INVCOUNT=\$[\$\{INVCOUNT\} + 1]) \n";   $PRI++;
						$menu_invalid_prompt_ext .= "exten => i,$PRI,NoOp(\$\{INVCOUNT\}) \n";   $PRI++;
						$menu_invalid_prompt_ext .= "exten => i,$PRI,Gotoif(\$[0\$\{INVCOUNT\} < 2]?" . $menu_id[$i] . ",s,4) \n";   $PRI++;
					#	$menu_invalid_prompt_ext .= "exten => i,$PRI,Hangup()\n";   $PRI++;
						}
					if ( ($option_value[$j] =~ /INVALID_3RD/) && ($cm_invalid_set < 1) )
						{
						$menu_invalid_prompt_ext .= "exten => i,$PRI,Set(INVCOUNT=\$[\$\{INVCOUNT\} + 1]) \n";   $PRI++;
						$menu_invalid_prompt_ext .= "exten => i,$PRI,NoOp(\${INVCOUNT}) \n";   $PRI++;
						$menu_invalid_prompt_ext .= "exten => i,$PRI,Gotoif(\$[0\$\{INVCOUNT\} < 3]?" . $menu_id[$i] . ",s,4) \n";   $PRI++;
					#	$menu_invalid_prompt_ext .= "exten => i,$PRI,Hangup()\n";   $PRI++;
						}

					$call_menu_line .= "$menu_invalid_prompt_ext";
					$cm_invalid_set++;
					$option_value[$j] = 'i';
					}
				if ($option_route[$j] =~ /AGI/)
					{
					if ($dtmf_log[$i] > 0) 
						{$call_menu_line .= "exten => $option_value[$j],$PRI,AGI(cm.agi,$tracking_group[$i]-----$option_value[$j]-----$dtmf_field[$i]-----$alt_dtmf_log[$i]-----$question[$i])\n";   $PRI++;}
					$call_menu_line .= "exten => $option_value[$j],$PRI,AGI($option_route_value[$j])\n";   $PRI++;
					$call_menu_line .= "exten => $option_value[$j],$PRI,Hangup()\n";
					}
				if ($option_route[$j] =~ /CALLMENU/)
					{
					if ($dtmf_log[$i] > 0) 
						{$call_menu_line .= "exten => $option_value[$j],$PRI,AGI(cm.agi,$tracking_group[$i]-----$option_value[$j]-----$dtmf_field[$i]-----$alt_dtmf_log[$i]-----$question[$i])\n";   $PRI++;}
					$call_menu_line .= "exten => $option_value[$j],$PRI,Goto($option_route_value[$j],s,1)\n";   $PRI++;
					$call_menu_line .= "exten => $option_value[$j],$PRI,Hangup()\n";
					}
				if ($option_route[$j] =~ /DID/)
					{
					if ($dtmf_log[$i] > 0) 
						{$call_menu_line .= "exten => $option_value[$j],$PRI,AGI(cm.agi,$tracking_group[$i]-----$option_value[$j]-----$dtmf_field[$i]-----$alt_dtmf_log[$i]-----$question[$i])\n";   $PRI++;}
					$call_menu_line .= "exten => $option_value[$j],$PRI,Goto(trunkinbound,$option_route_value[$j],1)\n";   $PRI++;
					$call_menu_line .= "exten => $option_value[$j],$PRI,Hangup()\n";
					}
				if ($option_route[$j] =~ /INGROUP/)
					{
					@IGoption_route_value_context = split(/,/,$option_route_value_context[$j]);
					$IGhandle_method =			$IGoption_route_value_context[0];
					$IGsearch_method =			$IGoption_route_value_context[1];
					$IGlist_id =				$IGoption_route_value_context[2];
					$IGcampaign_id =			$IGoption_route_value_context[3];
					$IGphone_code =				$IGoption_route_value_context[4];
					$IGvid_enter_filename =		$IGoption_route_value_context[5];
					$IGvid_id_number_filename =	$IGoption_route_value_context[6];
					$IGvid_confirm_filename =	$IGoption_route_value_context[7];
					$IGvid_validate_digits =	$IGoption_route_value_context[8];

					if ($dtmf_log[$i] > 0) 
						{$call_menu_line .= "exten => $option_value[$j],$PRI,AGI(cm.agi,$tracking_group[$i]-----$option_value[$j]-----$dtmf_field[$i]-----$alt_dtmf_log[$i]-----$question[$i])\n";   $PRI++;}
					if ($option_route_value[$j] =~ /DYNAMIC_INGROUP_VAR/) 
						{
						$call_menu_line .= "exten => $option_value[$j],$PRI,AGI(agi-VDAD_ALL_inbound.agi,$IGhandle_method-----$IGsearch_method-----\$\{ingroupvar\}-----$menu_id[$i]--------------------$IGlist_id-----$IGphone_code-----$IGcampaign_id---------------$IGvid_enter_filename-----$IGvid_id_number_filename-----$IGvid_confirm_filename-----$IGvid_validate_digits)\n";   $PRI++;
						}
					else
						{
						$call_menu_line .= "exten => $option_value[$j],$PRI,AGI(agi-VDAD_ALL_inbound.agi,$IGhandle_method-----$IGsearch_method-----$option_route_value[$j]-----$menu_id[$i]--------------------$IGlist_id-----$IGphone_code-----$IGcampaign_id---------------$IGvid_enter_filename-----$IGvid_id_number_filename-----$IGvid_confirm_filename-----$IGvid_validate_digits)\n";   $PRI++;
						}
					$call_menu_line .= "exten => $option_value[$j],$PRI,Hangup()\n";
					}
				if ($option_route[$j] =~ /EXTENSION/)
					{
					if ($dtmf_log[$i] > 0) 
						{$call_menu_line .= "exten => $option_value[$j],$PRI,AGI(cm.agi,$tracking_group[$i]-----$option_value[$j]-----$dtmf_field[$i]-----$alt_dtmf_log[$i]-----$question[$i])\n";   $PRI++;}
					if (length($option_route_value_context[$j])>0) {$option_route_value_context[$j] = "$option_route_value_context[$j],";}
					$call_menu_line .= "exten => $option_value[$j],$PRI,Goto($option_route_value_context[$j]$option_route_value[$j],1)\n";   $PRI++;
					$call_menu_line .= "exten => $option_value[$j],$PRI,Hangup()\n";
					}
				if ($option_route[$j] =~ /VOICEMAIL|VMAIL_NO_INST/)
					{
					if ($dtmf_log[$i] > 0) 
						{$call_menu_line .= "exten => $option_value[$j],$PRI,AGI(cm.agi,$tracking_group[$i]-----$option_value[$j]-----$dtmf_field[$i]-----$alt_dtmf_log[$i]-----$question[$i])\n";   $PRI++;}
					if ($option_route[$j] =~ /VMAIL_NO_INST/)
						{
						$call_menu_line .= "exten => $option_value[$j],$PRI,Goto(default,85026666666667$option_route_value[$j],1)\n";   $PRI++;
						}
					else
						{
						$call_menu_line .= "exten => $option_value[$j],$PRI,Goto(default,85026666666666$option_route_value[$j],1)\n";   $PRI++;
						}
					$call_menu_line .= "exten => $option_value[$j],$PRI,Hangup()\n";
					}
				if ($option_route[$j] =~ /HANGUP/)
					{
					if ( (length($option_route_value[$j])>0) && ($option_route_value[$j] !~ /NONE/) )
						{
						$hangup_prompt_ext='';
						if ($option_route_value[$j] =~ /\|/)
							{
							@hangup_prompts_array = split(/\|/,$option_route_value[$j]);
							$w=0;
							foreach(@hangup_prompts_array)
								{
								if (length($hangup_prompts_array[$w])>0)
									{
									$hangup_prompt_ext .= "exten => $option_value[$j],$PRI,Playback($hangup_prompts_array[$w])\n";
									$PRI++;
									}
								$w++;
								}
							}
						else
							{
							$hangup_prompt_ext .= "exten => $option_value[$j],$PRI,Playback($option_route_value[$j])\n";
							$PRI++;
							}

						$call_menu_line .= "$hangup_prompt_ext";
						if ($dtmf_log[$i] > 0) 
							{$call_menu_line .= "exten => $option_value[$j],$PRI,AGI(cm.agi,$tracking_group[$i]-----$option_value[$j]-----$dtmf_field[$i]-----$alt_dtmf_log[$i]-----$question[$i])\n";   $PRI++;}
						$call_menu_line .= "exten => $option_value[$j],n,Hangup()\n";
						}
					else
						{
						if ($dtmf_log[$i] > 0) 
							{$call_menu_line .= "exten => $option_value[$j],$PRI,AGI(cm.agi,$tracking_group[$i]-----$option_value[$j]-----$dtmf_field[$i]-----$alt_dtmf_log[$i]-----$question[$i])\n";   $PRI++;}
						$call_menu_line .= "exten => $option_value[$j],$PRI,Hangup()\n";
						}
					}
				if ($option_route[$j] =~ /PHONE/)
					{
					$stmtA = "SELECT dialplan_number,server_ip FROM phones where login='$option_route_value[$j]';";
					#	print "$stmtA\n";
					$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
					$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
					$sthArowsP=$sthA->rows;
					if ($sthArowsP > 0)
						{
						@aryA = $sthA->fetchrow_array;
						$Pdialplan =	"$aryA[0]";
						$Pserver_ip =	"$aryA[1]";

						### format the remote server dialstring to get the call to the overflow agent meetme room
						$S='*';
						if( $Pserver_ip =~ m/(\S+)\.(\S+)\.(\S+)\.(\S+)/ )
							{
							$a = leading_zero($1); 
							$b = leading_zero($2); 
							$c = leading_zero($3); 
							$d = leading_zero($4);
							$DIALstring = "$a$S$b$S$c$S$d$S";
							}
						if ($dtmf_log[$i] > 0) 
							{$call_menu_line .= "exten => $option_value[$j],$PRI,AGI(cm.agi,$tracking_group[$i]-----$option_value[$j]-----$dtmf_field[$i]-----$alt_dtmf_log[$i]-----$question[$i])\n";   $PRI++;}
						$call_menu_line .= "exten => $option_value[$j],$PRI,Goto(default,$DIALstring$Pdialplan,1)\n";   $PRI++;
						$call_menu_line .= "exten => $option_value[$j],$PRI,Hangup()\n";
						}
					$sthA->finish();
					}

				if ($option_value[$j] =~ /t/)
					{
					$call_menu_timeout_ext = "$call_menu_line";
					}
				if ($option_value[$j] =~ /i/)
					{
					if ($cm_invalid_set > 1) 
						{$call_menu_invalid_ext .= "; COMMENTED OUT...\n";}
					else
						{$call_menu_invalid_ext = "$call_menu_line";}
					}
				if ($option_value[$j] !~ /i|t/)
					{
					$call_menu_options_ext .= "$call_menu_line";
					}
				}
			if ($DBX>0) {print "$i|$j|     $menu_id[$i]|$option_value[$j]\n";}
			$j++;
			}
		$sthA->finish();

		$menu_prompt_ext='';
		if ($menu_prompt[$i] =~ /\|/)
			{
			@menu_prompts_array = split(/\|/,$menu_prompt[$i]);
			$w=0;
			foreach(@menu_prompts_array)
				{
				if (length($menu_prompts_array[$w])>0)
					{
					if ($menu_prompts_array[$w] =~ /\.agi/)
						{
						$menu_prompt_ext .= "exten => s,n,AGI($menu_prompts_array[$w])\n";
						}
					else
						{
						if ($menu_prompts_array[$w] =~ /^NOINT/)
							{
							$menu_prompts_array[$w] =~ s/^NOINT//g;
							$menu_prompt_ext .= "exten => s,n,Playback($menu_prompts_array[$w])\n";
							}
						else
							{
							$menu_prompt_ext .= "exten => s,n,Background($menu_prompts_array[$w])\n";
							}
						}
					}
				$w++;
				}
			}
		else
			{
			if ($menu_prompt[$i] =~ /\.agi/)
				{
				$menu_prompt_ext .= "exten => s,n,AGI($menu_prompt[$i])\n";
				}
			else
				{
				if ($menu_prompt[$i] =~ /^NOINT/)
					{
					$menu_prompt[$i] =~ s/^NOINT//g;
					$menu_prompt_ext .= "exten => s,n,Playback($menu_prompt[$i])\n";
					}
				else
					{
					$menu_prompt_ext .= "exten => s,n,Background($menu_prompt[$i])\n";
					}
				}
			}


		if ($time_check_route =~ /AGI/)
			{
			$call_menu_options_ext .= "; time check after hours AGI special extension\n";
			$call_menu_options_ext .= "exten => 9999999999999999999988,1,AGI($time_check_route_value)\n";
			$call_menu_options_ext .= "exten => 9999999999999999999988,2,Hangup()\n";

			$time_check_route = 'EXTENSION';
			$time_check_route_value = '9999999999999999999988';
			$time_check_route_context = $menu_id[$i];
			}
		if ($time_check_route =~ /INGROUP/)
			{
			$call_menu_options_ext .= "; time check after hours INGROUP special extension\n";
			$call_menu_options_ext .= "exten => 9999999999999999999988,1,AGI($CM_agi_string)\n";
			$call_menu_options_ext .= "exten => 9999999999999999999988,2,Hangup()\n";

			$time_check_route = 'EXTENSION';
			$time_check_route_value = '9999999999999999999988';
			$time_check_route_context = $menu_id[$i];
			}
		$call_menu_ext .= "\n";
		$call_menu_ext .= "; $menu_name[$i]\n";
		$call_menu_ext .= "[$menu_id[$i]]\n";
		$call_menu_ext .= "exten => s,1,Answer\n";
		$call_menu_ext .= "exten => s,n,AGI(agi-VDAD_inbound_calltime_check.agi,$tracking_group[$i]-----$track_in_vdac[$i]-----$menu_id[$i]-----$time_check_scheme-----$time_check_route-----$time_check_route_value-----$time_check_route_context-----$qualify_sql_active[$i])\n";
		$call_menu_ext .= "exten => s,n,Set(INVCOUNT=0) \n";
		$call_menu_ext .= "$menu_prompt_ext";
		if ($menu_timeout[$i] > 0)
			{$call_menu_ext .= "exten => s,n,WaitExten($menu_timeout[$i])\n";}
		$k=0;
		while ($k < $menu_repeat[$i]) 
			{
			$call_menu_ext .= "$menu_prompt_ext";
			if ($menu_timeout[$i] > 0)
				{$call_menu_ext .= "exten => s,n,WaitExten($menu_timeout[$i])\n";}
			$k++;
			}
	#	$call_menu_ext .= "exten => s,n,Hangup()\n";
		$call_menu_ext .= "\n";
		$call_menu_ext .= "$call_menu_options_ext";
		$call_menu_ext .= "\n";

		if (length($call_menu_timeout_ext) < 1)
			{
			if ( (length($menu_timeout_prompt[$i])>0)  && ($menu_timeout_prompt[$i] !~ /NONE/) )
				{
				$call_menu_ext .= "exten => t,1,Playback($menu_timeout_prompt[$i])\n";
				$call_menu_ext .= "exten => t,n,Goto(s,4)\n";
				$call_menu_ext .= "exten => t,n,Hangup()\n";
				}
			else
				{
				$call_menu_ext .= "exten => t,1,Goto(s,4)\n";
				$call_menu_ext .= "exten => t,n,Hangup()\n";
				}
			}
		else
			{
			$call_menu_ext .= "$call_menu_timeout_ext";
			}
		if (length($call_menu_invalid_ext) < 1)
			{
			if ( (length($menu_invalid_prompt[$i])>0) && ($menu_invalid_prompt[$i] !~ /NONE/) )
				{
				$call_menu_ext .= "exten => i,1,Playback($menu_invalid_prompt[$i])\n";
				$call_menu_ext .= "exten => i,n,Goto(s,4)\n";
				$call_menu_ext .= "exten => i,n,Hangup()\n";
				}
			else
				{
				$call_menu_ext .= "exten => i,1,Goto(s,4)\n";
				$call_menu_ext .= "exten => i,n,Hangup()\n";
				}
			}
		else
			{
			$call_menu_ext .= "$call_menu_invalid_ext";
			}
		$call_menu_ext .= "; hangup\n";
		$call_menu_ext .= $hangup_exten_line;

		if (length($custom_dialplan_entry[$i]) > 4) 
			{
			$call_menu_ext .= "\n\n";
			$call_menu_ext .= "; custom dialplan entries\n";
			$call_menu_ext .= "$custom_dialplan_entry[$i]\n";
			}

		$call_menu_ext .= "\n\n";

		$i++;
		}
	##### END Generate the Call Menu entries #####



	##### BEGIN generate voicemail accounts for all distinct phones on dedicated voicemail server
	if ($THISserver_voicemail > 0)
		{
		$vm='';

		##### Get the distinct phone entries #####
		$stmtA = "SELECT distinct(voicemail_id) FROM phones where active='Y' order by voicemail_id;";
		#	print "$stmtA\n";
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		$i=0;
		while ($sthArows > $i)
			{
			@aryA = $sthA->fetchrow_array;
			$voicemail[$i] =	$aryA[0];
			$i++;
			}
		$sthA->finish();

		$i=0;
		while ($sthArows > $i)
			{
			##### Get the distinct phone entries #####
			$stmtA = "SELECT extension,pass,email,delete_vm_after_email,voicemail_timezone,voicemail_options FROM phones where active='Y' and voicemail_id='$voicemail[$i]';";
			#	print "$stmtA\n";
			$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
			$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
			$sthArowsX=$sthA->rows;
			if ($sthArowsX > 0)
				{
				@aryA = $sthA->fetchrow_array;
				$extension[$i] =				$aryA[0];
				$pass[$i] =						$aryA[1];
				$email[$i] =					$aryA[2];
				$delete_vm_after_email[$i] =	$aryA[3];
				$voicemail_timezone[$i] =		$aryA[4];
				$voicemail_options[$i] =		$aryA[5];

				if ($delete_vm_after_email[$i] =~ /Y/)
					{$vm  .= "$voicemail[$i] => $pass[$i],$extension[$i] Mailbox,$email[$i],,|delete=yes|tz=$voicemail_timezone[$i]|$voicemail_options[$i]\n";}
				else
					{$vm  .= "$voicemail[$i] => $pass[$i],$extension[$i] Mailbox,$email[$i],,|delete=no|tz=$voicemail_timezone[$i]|$voicemail_options[$i]\n";}
				}
			$sthA->finish();

			$i++;
			}

		##### Get the other voicemail box entries #####
		$stmtA = "SELECT voicemail_id,fullname,pass,email,delete_vm_after_email,voicemail_timezone,voicemail_options FROM vicidial_voicemail where active='Y';";
		#	print "$stmtA\n";
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows=$sthA->rows;
		if ($sthArows > 0)
			{
			$vm  .= "\n";
			$vm  .= "; Other Voicemail Entries:\n";
			}
		$i=0;
		while ($sthArows > $i)
			{
			@aryA = $sthA->fetchrow_array;
			$voicemail_id[$i] =				$aryA[0];
			$fullname[$i] =					$aryA[1];
			$pass[$i] =						$aryA[2];
			$email[$i] =					$aryA[3];
			$delete_vm_after_email[$i] =	$aryA[4];
			$voicemail_timezone[$i] =		$aryA[5];
			$voicemail_options[$i] =		$aryA[6];

			if ($delete_vm_after_email[$i] =~ /Y/)
				{$vm  .= "$voicemail_id[$i] => $pass[$i],$fullname[$i],$email[$i],,|delete=yes|tz=$voicemail_timezone[$i]|$voicemail_options[$i]\n";}
			else
				{$vm  .= "$voicemail_id[$i] => $pass[$i],$fullname[$i],$email[$i],,|delete=no|tz=$voicemail_timezone[$i]|$voicemail_options[$i]\n";}

			$i++;
			}
		$sthA->finish();
		}
	##### END generate voicemail accounts for all distinct phones on dedicated voicemail server



	##### BEGIN generate meetme entries for this server
	$mm = "; ViciDial Conferences:\n";

	### Find vicidial_conferences on this server
	$stmtA = "SELECT conf_exten FROM vicidial_conferences where server_ip='$server_ip';";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArowsVC=$sthA->rows;
	$j=0;
	while ($sthArowsVC > $j)
		{
		@aryA = $sthA->fetchrow_array;
		$vc_meetme[$j] =	$aryA[0];
		$j++;
		}
	$sthA->finish();

	$j=0;
	while ($sthArowsVC > $j)
		{
		$mm .= "conf => $vc_meetme[$j]\n";
		$j++;
		}

	$mm .= "\n";
	$mm .= "; Conferences:\n";

	### Find conferences on this server
	$stmtA = "SELECT conf_exten FROM conferences where server_ip='$server_ip';";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArowsC=$sthA->rows;
	$j=0;
	while ($sthArowsC > $j)
		{
		@aryA = $sthA->fetchrow_array;
		$meetme[$j] =	$aryA[0];
		$j++;
		}
	$sthA->finish();

	$j=0;
	while ($sthArowsC > $j)
		{
		$mm .= "conf => $meetme[$j]\n";
		$j++;
		}
	##### END generate meetme entries for this server



	##### BEGIN generate music on hold entries for this server
	$moh='';

	### Find music on hold contexts
	$stmtA = "SELECT moh_id,moh_name,random FROM vicidial_music_on_hold where remove='N' and active='Y' and moh_id NOT IN('astdb','sounds','agi-bin','keys');";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArowsM=$sthA->rows;
	$j=0;
	while ($sthArowsM > $j)
		{
		@aryA = $sthA->fetchrow_array;
		$moh_id[$j] =	$aryA[0];
		$moh_name[$j] =	$aryA[1];
		$random[$j] =	$aryA[2];
		$j++;
		}
	$sthA->finish();

	$j=0;
	while ($sthArowsM > $j)
		{
		$moh  .= "; $moh_name[$j]\n";
		$moh  .= "[$moh_id[$j]]\n";
		$moh  .= "mode=files\n";
		$moh  .= "directory=/var/lib/asterisk/$moh_id[$j]\n";
		if ($random[$j] =~ /Y/) 
			{$moh  .= "random=yes\n";}
		else 
			{$moh  .= "sort=alpha\n";}
		$moh  .= "\n";

		$j++;
		}

	##### END generate music on hold entries for this server

	##### BEGIN gather header lines for voicemail.conf file
	# default path to voicemail configuration file:
	$VMCconf = '/etc/asterisk/voicemail.conf';

	open(vmc, "$VMCconf") || die "can't open $VMCconf: $!\n";
	@vmc = <vmc>;
	close(vmc);
	$i=0;
	$vm_header_content='';
	$boxes=9999999;
	foreach(@vmc)
		{
		$line = $vmc[$i];
		$line =~ s/\n|\r//gi;
		if ($line =~ /\[default\]/)
			{$boxes = $i;}
		if ($i <= $boxes)
			{
			$vm_header_content .= "$line\n";
			}
		$i++;
		}
	##### END  gather header lines for voicemail.conf file

	if ($DB) {print "writing auto-gen conf files\n";}

	open(ext, ">/etc/asterisk/BUILDextensions-vicidial.conf") || die "can't open /etc/asterisk/BUILDextensions-vicidial.conf: $!\n";
	open(iax, ">/etc/asterisk/BUILDiax-vicidial.conf") || die "can't open /etc/asterisk/BUILDiax-vicidial.conf: $!\n";
	open(sip, ">/etc/asterisk/BUILDsip-vicidial.conf") || die "can't open /etc/asterisk/BUILDsip-vicidial.conf: $!\n";
	open(vm, ">/etc/asterisk/BUILDvoicemail-vicidial.conf") || die "can't open /etc/asterisk/BUILDvoicemail-vicidial.conf: $!\n";
	open(moh, ">/etc/asterisk/BUILDmusiconhold-vicidial.conf") || die "can't open /etc/asterisk/BUILDmusiconhold-vicidial.conf: $!\n";
	open(mm, ">/etc/asterisk/BUILDmeetme-vicidial.conf") || die "can't open /etc/asterisk/BUILDmeetme-vicidial.conf: $!\n";

	print ext "; WARNING- THIS FILE IS AUTO-GENERATED BY VICIDIAL, ANY EDITS YOU MAKE WILL BE LOST\n";
	print ext "$ext\n";
	print ext "$meetme_custom_ext\n";
	print ext "$call_menu_ext\n";
	print ext "\n";
	if (length($SScustom_dialplan_entry)>5)
		{
		print ext "[vicidial-auto-system-setting-custom]\n";
		print ext $hangup_exten_line;
		print ext "\n";
		print ext "; System Setting Custom Dialplan\n$SScustom_dialplan_entry\n\n";
		}
	if (length($SERVERcustom_dialplan_entry)>5)
		{
		print ext "[vicidial-auto-server-custom]\n";
		print ext $hangup_exten_line;
		print ext "\n";
		print ext "; Server Custom Dialplan\n$SERVERcustom_dialplan_entry\n\n";
		}
	print ext "[vicidial-auto-external]\n";
	print ext $hangup_exten_line;
	print ext "\n";
	print ext "$Lext\n";

	print ext "[vicidial-auto-internal]\n";
	print ext $hangup_exten_line;
	print ext "\n";
	print ext "$Vext\n";

	print ext "[vicidial-auto-phones]\n";
	print ext $hangup_exten_line;
	print ext "\n";
	print ext "$Pext\n";

	print ext "[vicidial-auto]\n";

	print ext $hangup_exten_line;
	print ext "\n";
	print ext "\n";
	print ext "include => vicidial-auto-internal\n";
	print ext "include => vicidial-auto-phones\n";
	print ext "include => vicidial-auto-external\n";
	if (length($SERVERcustom_dialplan_entry)>5)
		{print ext "include => vicidial-auto-server-custom\n";}
	if (length($SScustom_dialplan_entry)>5)
		{print ext "include => vicidial-auto-system-setting-custom\n";}
	print ext "\n";
	print ext "\n; END OF FILE    Last Forced System Reload: $SSreload_timestamp\n";

	print iax "; WARNING- THIS FILE IS AUTO-GENERATED BY VICIDIAL, ANY EDITS YOU MAKE WILL BE LOST\n";
	print iax "$iax\n";
	print iax "$Liax\n";
	print iax "$Piax\n";
	print iax "\n; END OF FILE    Last Forced System Reload: $SSreload_timestamp\n";

	print sip "; WARNING- THIS FILE IS AUTO-GENERATED BY VICIDIAL, ANY EDITS YOU MAKE WILL BE LOST\n";
	print sip "$sip\n";
	print sip "$Lsip\n";
	print sip "$Psip\n";
	print sip "\n; END OF FILE    Last Forced System Reload: $SSreload_timestamp\n";

#	print vm "; WARNING- THIS FILE IS AUTO-GENERATED BY VICIDIAL, ANY EDITS YOU MAKE WILL BE LOST\n";
	print vm "$vm_header_content\n";
	print vm "$vm\n";
	print vm "\n; END OF FILE    Last Forced System Reload: $SSreload_timestamp\n";

	print moh "; WARNING- THIS FILE IS AUTO-GENERATED BY VICIDIAL, ANY EDITS YOU MAKE WILL BE LOST\n";
	print moh "$moh\n";
	print moh "\n; END OF FILE    Last Forced System Reload: $SSreload_timestamp\n";

	print mm "; WARNING- THIS FILE IS AUTO-GENERATED BY VICIDIAL, ANY EDITS YOU MAKE WILL BE LOST\n";
	print mm "$mm\n";
	print mm "\n; END OF FILE    Last Forced System Reload: $SSreload_timestamp\n";

	close(ext);
	close(iax);
	close(sip);
	close(vm);
	close(moh);
	close(mm);

	### find cmp binary
	$cmpbin = '';
	if ( -e ('/bin/cmp')) {$cmpbin = '/bin/cmp';}
	else 
		{
		if ( -e ('/usr/bin/cmp')) {$cmpbin = '/usr/bin/cmp';}
		else 
			{
			if ( -e ('/usr/local/bin/cmp')) {$cmpbin = '/usr/local/bin/cmp';}
			else
				{
				print "Can't find cmp binary! Exiting...\n";
				exit;
				}
			}
		}

	if ( !-e ('/etc/asterisk/extensions-vicidial.conf'))
		{`echo -e \"; END OF FILE\n\" > /etc/asterisk/extensions-vicidial.conf`;}

	if ( !-e ('/etc/asterisk/iax-vicidial.conf'))
		{`echo -e \"; END OF FILE\n\" > /etc/asterisk/iax-vicidial.conf`;}

	if ( !-e ('/etc/asterisk/sip-vicidial.conf'))
		{`echo -e \"; END OF FILE\n\" > /etc/asterisk/sip-vicidial.conf`;}

	if ( !-e ('/etc/asterisk/voicemail.conf'))
		{`echo -e \"; END OF FILE\n\" > /etc/asterisk/voicemail.conf`;}

	if ( !-e ('/etc/asterisk/musiconhold-vicidial.conf'))
		{`echo -e \"; END OF FILE\n\" > /etc/asterisk/musiconhold-vicidial.conf`;}

	if ( !-e ('/etc/asterisk/meetme-vicidial.conf'))
		{`echo -e \"; END OF FILE\n\" > /etc/asterisk/meetme-vicidial.conf`;}

	use File::Compare;

	$extCMP = compare("/etc/asterisk/BUILDextensions-vicidial.conf","/etc/asterisk/extensions-vicidial.conf");
	$iaxCMP = compare("/etc/asterisk/BUILDiax-vicidial.conf","/etc/asterisk/iax-vicidial.conf");
	$sipCMP = compare("/etc/asterisk/BUILDsip-vicidial.conf","/etc/asterisk/sip-vicidial.conf");
	$vmCMP =  compare("/etc/asterisk/BUILDvoicemail-vicidial.conf","/etc/asterisk/voicemail.conf");
	$mohCMP = compare("/etc/asterisk/BUILDmusiconhold-vicidial.conf","/etc/asterisk/musiconhold-vicidial.conf");
	$mmCMP =  compare("/etc/asterisk/BUILDmeetme-vicidial.conf","/etc/asterisk/meetme-vicidial.conf");

	sleep(1);

	### reload Asterisk
	if ($DB) {print "reloading asterisk modules:\n";}
	if ($asterisk_version =~ /^1.2/)
		{
		if ($extCMP > 0)
			{
			`cp -f /etc/asterisk/BUILDextensions-vicidial.conf /etc/asterisk/extensions-vicidial.conf`;
			`screen -XS asterisk eval 'stuff "extensions reload\015"'`;
			if ($DB) {print "extensions reload\n";}
			sleep(1);
			}
		if ($sipCMP > 0)
			{
			`cp -f /etc/asterisk/BUILDsip-vicidial.conf /etc/asterisk/sip-vicidial.conf`;
			`screen -XS asterisk eval 'stuff "sip reload\015"'`;
			if ($DB) {print "sip reload\n";}
			sleep(1);
			}
		if ($iaxCMP > 0)
			{
			`cp -f /etc/asterisk/BUILDiax-vicidial.conf /etc/asterisk/iax-vicidial.conf`;
			`screen -XS asterisk eval 'stuff "iax2 reload\015"'`;
			if ($DB) {print "iax reload\n";}
			sleep(1);
			}
		if ($vmCMP > 0)
			{
			`cp -f /etc/asterisk/BUILDvoicemail-vicidial.conf /etc/asterisk/voicemail.conf`;
			`screen -XS asterisk eval 'stuff "reload app_voicemail.so\015"'`;
			if ($DB) {print "reload app_voicemail.so\n";}
			sleep(1);
			}
		if ($mohCMP > 0)
			{
			`cp -f /etc/asterisk/BUILDmusiconhold-vicidial.conf /etc/asterisk/musiconhold-vicidial.conf`;
			`screen -XS asterisk eval 'stuff "moh reload\015"'`;
			if ($DB) {print "moh reload\n";}
			sleep(1);
			}
		if ($mmCMP > 0)
			{
			`cp -f /etc/asterisk/BUILDmeetme-vicidial.conf /etc/asterisk/meetme-vicidial.conf`;
			`screen -XS asterisk eval 'stuff "reload app_meetme.so\015"'`;
			if ($DB) {print "reload app_meetme.so\n";}
			sleep(1);
			}
		}
	else
		{
		if ($extCMP > 0)
			{
			`cp -f /etc/asterisk/BUILDextensions-vicidial.conf /etc/asterisk/extensions-vicidial.conf`;
			`screen -XS asterisk eval 'stuff "dialplan reload\015"'`;
			if ($DB) {print "dialplan reload\n";}
			sleep(1);
			}
		if ($sipCMP > 0)
			{
			`cp -f /etc/asterisk/BUILDsip-vicidial.conf /etc/asterisk/sip-vicidial.conf`;
			`screen -XS asterisk eval 'stuff "sip reload\015"'`;
			if ($DB) {print "sip reload\n";}
			sleep(1);
			}
		if ($iaxCMP > 0)
			{
			`cp -f /etc/asterisk/BUILDiax-vicidial.conf /etc/asterisk/iax-vicidial.conf`;
			`screen -XS asterisk eval 'stuff "iax2 reload\015"'`;
			if ($DB) {print "iax2 reload\n";}
			sleep(1);
			}
		if ($vmCMP > 0)
			{
			`cp -f /etc/asterisk/BUILDvoicemail-vicidial.conf /etc/asterisk/voicemail.conf`;
			`screen -XS asterisk eval 'stuff "module reload app_voicemail.so\015"'`;
			if ($DB) {print "module reload app_voicemail.so\n";}
			sleep(1);
			}
		if ($mohCMP > 0)
			{
			`cp -f /etc/asterisk/BUILDmusiconhold-vicidial.conf /etc/asterisk/musiconhold-vicidial.conf`;
			`screen -XS asterisk eval 'stuff "moh reload\015"'`;
			if ($DB) {print "moh reload\n";}
			sleep(1);
			}
		if ($mmCMP > 0)
			{
			`cp -f /etc/asterisk/BUILDmeetme-vicidial.conf /etc/asterisk/meetme-vicidial.conf`;
			`screen -XS asterisk eval 'stuff "module reload app_meetme.so\015"'`;
			if ($DB) {print "module reload app_meetme.so\n";}
			sleep(1);
			}
		}

	`rm -f /etc/asterisk/BUILDextensions-vicidial.conf`;
	`rm -f /etc/asterisk/BUILDiax-vicidial.conf`;
	`rm -f /etc/asterisk/BUILDsip-vicidial.conf`;
#	`rm -f /etc/asterisk/BUILDvoicemail-vicidial.conf`;
	`rm -f /etc/asterisk/BUILDmusiconhold-vicidial.conf`;
	`rm -f /etc/asterisk/BUILDmeetme-vicidial.conf`;

	}
################################################################################
#####  END Creation of auto-generated conf files
################################################################################







################################################################################
#####  BEGIN Find system uptime and update server record with the data
################################################################################
$uptimebin = '';
$system_uptime='';
$recent_reboot=0;

# Grab the system uptime from the Kernel in seconds
$uptime_seconds=`cat /proc/uptime`;
$uptime_seconds=substr($uptime_seconds,0,index($uptime_seconds, ' '));

### find uptime binary
if ( -e ('/bin/uptime')) {$uptimebin = '/bin/uptime';}
else 
	{
	if ( -e ('/usr/bin/uptime')) {$uptimebin = '/usr/bin/uptime';}
	else 
		{
		if ( -e ('/usr/local/bin/uptime')) {$uptimebin = '/usr/local/bin/uptime';}
		else
			{
			print "Can't find uptime binary! Exiting...\n";
			}
		}
	}

if (length($uptimebin)>3) 
	{
	@sysuptime = `$uptimebin`;
	 # 18:26:14 up 153 days, 23:59,  4 users,  load average: 0.01, 0.01, 0.00
	 # 10:03am  up 123 days  0:10,  1 user,  load average: 0.11, 0.05, 0.01
	 # 10:03am  up   3:17,  2 users,  load average: 0.41, 0.28, 0.21

	if ($DBX) {print "Uptime debug 1: |$sysuptime[0]|\n";}
	$sysuptime[0] =~ s/ days, / days /gi;
	$sysuptime[0] =~ s/,.*//gi;
	$sysuptime[0] =~ s/  / /gi;
	$sysuptime[0] =~ s/  / /gi;
	$sysuptime[0] =~ s/\r|\n|\t//gi;
	@uptimedata = split(/ up /,$sysuptime[0]);
	$system_uptime = $uptimedata[1];

	# If server was just restarted, reset the temp-no-restart setting to N
	$asterisk_temp_no_restartSQL='';
	if ($system_uptime =~ /^0:00|^0:01|^0:02|^0:03|^0:04|^0:05/)
		{
		$asterisk_temp_no_restartSQL=",asterisk_temp_no_restart='N'";
		$recent_reboot++;
		}
	if ($DBX) {print "Uptime debug 2: |$sysuptime[0]|$system_uptime|$recent_reboot|  seconds: |$uptime_seconds|\n";}

	$stmtA = "UPDATE servers SET system_uptime='$system_uptime' $asterisk_temp_no_restartSQL where server_ip='$server_ip';";
	$affected_rows = $dbhA->do($stmtA) or die  "Couldn't execute query: |$stmtA|\n";
	if ($DBX) {print "Uptime debug 3: |$affected_rows|$stmtA|\n";}
	}
################################################################################
#####  END Find system uptime and update server record with the data
################################################################################





################################################################################
#####  BEGIN Gathering asterisk output and peers/registry
################################################################################
if ( ($active_asterisk_server =~ /Y/) && ($gather_asterisk_output =~ /Y/) && ($reset_test =~ /0$|5$/) ) 
	{
	if ($DB) {print "Gathering asterisk output and peers/registry\n";}
	`/usr/bin/screen -d -m -S GatherOutput $PATHhome/AST_output_update.pl 2>/dev/null 1>&2`;
	}
################################################################################
#####  BEGIN Gathering asterisk output and peers/registry
################################################################################





################################################################################
#####  BEGIN Confirm Asterisk is running, and if not restart it from the screen
################################################################################
if ($DBX > 0)
	{print "CONFIRM ASTERISK IS RUNNING: |$active_asterisk_server|$runningASTERISK|$auto_restart_asterisk|$asterisk_temp_no_restart|$recent_reboot|\n";}
if ($active_asterisk_server =~ /Y/)
	{
	if ( ($runningASTERISK < 1) && ($auto_restart_asterisk =~ /Y/) && ($asterisk_temp_no_restart =~ /N/) && ($recent_reboot < 1) )
		{
		$asteriskSCREEN=0;
		@screenoutput = `/usr/bin/screen -ls`;

		$i=0;
		foreach (@screenoutput)
			{
			chomp($screenoutput[$i]);
			if ($DBX) {print "$i|$screenoutput[$i]|     \n";}
			if ($screenoutput[$i] =~ /\.asterisk/) 
				{
				$asteriskSCREEN++;
				if ($DB) {print "asterisk screen session open:              |$screenoutput[$i]|\n";}
				}
			$i++;
			}
		
		if ($asteriskSCREEN > 0)
			{
			if ($DB) {print "restarting Asterisk process...\n";}
			$stmtA="INSERT INTO vicidial_admin_log set event_date=NOW(), user='VDAD', ip_address='1.1.1.1', event_section='SERVERS', event_type='RESET', record_id='$server_ip', event_code='AUTO RESTART ASTERISK', event_sql='', event_notes='$system_uptime system uptime';";
			$Iaffected_rows = $dbhA->do($stmtA);
			if ($DBX) {print "Restart asterisk debug 1: |$Iaffected_rows|$stmtA|\n";}

			`screen -XS asterisk eval 'stuff "/usr/sbin/asterisk -vvvvgcT\015"'`;
			}
		elsif ($uptime_seconds>300)
 			{
			# We only want to start Asterisk if the system has been up for at least 5 minutes
			# That way we don't run into the keepalive and the regular init script colliding with each other
			if ($DB) {print "starting Asterisk process...\n";}
			$stmtA="INSERT INTO vicidial_admin_log set event_date=NOW(), user='VDAD', ip_address='1.1.1.1', event_section='SERVERS', event_type='RESET', record_id='$server_ip', event_code='AUTO START ASTERISK', event_sql='', event_notes='$system_uptime system uptime';";
			$Iaffected_rows = $dbhA->do($stmtA);
			if ($DBX) {print "Restart asterisk debug 1: |$Iaffected_rows|$stmtA|\n";}

			`$PATHhome/start_asterisk_boot.pl`;
			}
		}
	}
################################################################################
#####  END Confirm Asterisk is running, and if not restart it from the screen
################################################################################





################################################################################
#####  START scheduled callbacks move old USERONLY triggered to ANYONE
################################################################################
# only run this on active voicemail servver
if ( ($active_voicemail_server =~ /$server_ip/) && ((length($active_voicemail_server)) eq (length($server_ip))) )
	{
	##### BEGIN gather campaign settings #####
	$CBcampaign_id=$MT;
	$CBcallback_useronly_move_minutes=$MT;
	$stmtA = "SELECT campaign_id,callback_useronly_move_minutes FROM vicidial_campaigns where active='Y' and callback_useronly_move_minutes > 0 order by campaign_id;";
	if ($DBX) {print "$stmtA\n";}
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	$i=0;
	while ($sthArows > $i)
		{
		@aryA = $sthA->fetchrow_array;
		$CBcampaign_id[$i] =					$aryA[0];
		$CBcallback_useronly_move_minutes[$i] =	$aryA[1];
		$i++;
		}
	$sthA->finish();

	if ($DB) {print "   old live scheduled callbacks move active campaigns: $i\n";}

	$i=0;
	while ($sthArows > $i)
		{
		$CBmoveCOUNT=0;
		$stmtA = "SELECT count(*) from vicidial_callbacks where campaign_id='$CBcampaign_id[$i]' and status='LIVE' and recipient='USERONLY' and callback_time < (NOW() - INTERVAL $CBcallback_useronly_move_minutes[$i] MINUTE);";
		if ($DBX) {print "$stmtA\n";}
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArowsX=$sthA->rows;
		if ($sthArowsX > 0)
			{
			@aryA = $sthA->fetchrow_array;
			$CBmoveCOUNT =			$aryA[0];
			}
		$sthA->finish();

		if ($CBmoveCOUNT > 0) 
			{
			$stmtA = "UPDATE vicidial_callbacks SET recipient='ANYONE',status='ACTIVE' where campaign_id='$CBcampaign_id[$i]' and status='LIVE' and recipient='USERONLY' and callback_time < (NOW() - INTERVAL $CBcallback_useronly_move_minutes[$i] MINUTE);";
			$affected_rows = $dbhA->do($stmtA) or die  "Couldn't execute query: |$stmtA|\n";
			if ($DBX) {print "Callback USERONLY old move query: |$affected_rows|$stmtA|\n";}

			if ($teodDB) 
				{
				$event_string = "Callback USERONLY old moved: $affected_rows|$CBmoveCOUNT|$CBcampaign_id[$i]|$CBcallback_useronly_move_minutes[$i]|";
				&teod_logger;
				}
			}
		$i++;
		}
	}
################################################################################
#####  END scheduled callbacks move old USERONLY triggered to ANYONE
################################################################################





################################################################################
#####  BEGIN  Audio Store sync
################################################################################
$upload_audio = 0;
$upload_flag = '';
$soundsec=0;

if ( ($active_voicemail_server =~ /$server_ip/) && ((length($active_voicemail_server)) eq (length($server_ip))) )
	{
	if (-e "/prompt_count.txt")
		{
		open(test, "/prompt_count.txt") || die "can't open /prompt_count.txt: $!\n";
		@test = <test>;
		close(test);
		chomp($test[0]);
		$test[0] = ($test[0] + 85100000);
		$last_file_gsm = "$test[0].gsm";
		$last_file_wav = "$test[0].wav";

		if (-e "$PATHsounds/$last_file_gsm")
			{
			$sounddate = (-M "$PATHsounds/$last_file_gsm");
			$soundsec =	($sounddate * 86400);
			}
		if (-e "$PATHsounds/$last_file_wav")
			{
			$sounddate = (-M "$PATHsounds/$last_file_wav");
			$soundsec =	($sounddate * 86400);
			}
		if ($DB) {print "age of last audio prompt file: |$sounddate|$soundsec|   ($PATHsounds/$last_file_gsm|$last_file_wav)\n";}
		if ( ($soundsec > 300) && ($soundsec <= 360) )
			{
			$upload_audio = 1;
			$upload_flag = '--upload';
			}
		}
	### start the chat timeout process
	if ($SSallow_chats > 0) 
		{
		if ($DB) {print "running chat timeout process...\n";}
		`/usr/bin/screen -d -m -S ChatTimeout $PATHhome/AST_chat_timeout_cron.pl 2>/dev/null 1>&2`;
		}
	}

if ( ($active_asterisk_server =~ /Y/) && ( ($sounds_update =~ /Y/) || ($upload_audio > 0) ) )
	{
	if ($sounds_central_control_active > 0)
		{
		$gather_stats_flag='';
		if ($THISserver_voicemail > 0) 
			{$gather_stats_flag='--gather-details';}
		if ($DB) {print "running audio store sync process...\n";}
		`/usr/bin/screen -d -m -S AudioStore $PATHhome/ADMIN_audio_store_sync.pl $upload_flag $gather_stats_flag 2>/dev/null 1>&2`;
		}
	}
################################################################################
#####  END  Audio Store sync
################################################################################






################################################################################
#####  BEGIN  process triggers
################################################################################
$stmtA = "SELECT trigger_id,user,trigger_lines,trigger_name FROM vicidial_process_triggers where server_ip='$server_ip' and trigger_run='1' and trigger_time < NOW() order by trigger_time limit 1;";
$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
$sthBrows=$sthA->rows;
if ($sthBrows > 0)
	{
	@aryA = $sthA->fetchrow_array;
	$trigger_id	=		$aryA[0];
	$user	=			$aryA[1];
	$trigger_lines	=	$aryA[2];
	$trigger_name =		$aryA[3];
	}
$sthA->finish();

if ($sthBrows > 0)
	{
	$stmtA="UPDATE vicidial_process_triggers SET trigger_run='0' where trigger_id='$trigger_id';";
	$affected_rows = $dbhA->do($stmtA);

	$trigger_results='';
	if ($DB) {print "running process trigger: $trigger_id\n";}
	@triggers = split(/\|/,$trigger_lines);
	$i=0;
	foreach(@triggers)
		{
		$trigger_results .= "$triggers[$i]\n";
		if ($trigger_name =~ /SCREEN/)
			{
			if ($DB) {print "starting trigger process in a screen...\n";}
			`/usr/bin/screen -d -m -S VT$reset_test $triggers[$i]`;
			$trigger_results = 'launched in a screen';
			}
		else
			{
			@output=@MT;
			@output = `$triggers[$i]`;
			$m=0;
			foreach(@output) 
				{
				$trigger_results .= "$output[$m]";
				$m++;
				}
			}
		$i++;
		}
	if ($DB) {print "DONE\n";}
	if ($DB) {print "$trigger_results\n";}

	$trigger_lines =~ s/;|\\|\"//gi;
	$trigger_results =~ s/;|\\|\"//gi;

	$stmtA="INSERT INTO vicidial_process_trigger_log SET trigger_id='$trigger_id',user='$user',trigger_time=NOW(),server_ip='$server_ip',trigger_lines='$trigger_lines',trigger_results='$trigger_results';";
	$Iaffected_rows = $dbhA->do($stmtA);
	if ($DB) {print "FINISHED:   $affected_rows|$Iaffected_rows";}
	}
################################################################################
#####  END  process triggers
################################################################################





################################################################################
#####  BEGIN  automated reports
################################################################################
if ($SSenable_auto_reports > 0)
	{
	$THISserver_voicemailSQL='';
	if ($THISserver_voicemail > 0) {$THISserver_voicemailSQL=",'active_voicemail_server'";}
	$stmtA = "SELECT report_id FROM vicidial_automated_reports where ( (report_server IN('$server_ip'$THISserver_voicemailSQL) ) and ( ( (active='Y') and (report_times LIKE \"%$reset_test%\") and ( (report_weekdays LIKE \"%$wday%\") or (report_monthdays LIKE \"%$mday%\") ) ) or (run_now_trigger='Y') ) ) order by report_id limit 1000;";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthBrows=$sthA->rows;
	if ($DB) {print "Checking for Automated Reports: |$sthBrows|$stmtA|\n";}
	$r=0;
	while ($sthBrows > $r)
		{
		@aryA = $sthA->fetchrow_array;
		$report_idARY[$r]	=	$aryA[0];
		$r++;
		}
	$sthA->finish();

	if ($sthBrows > 0)
		{
		$r=0;
		while ($sthBrows > $r)
			{
			$temp_report = $report_idARY[$r];
			$ar_command = "$PATHhome/AST_email_web_report.pl --quiet --remove-images --remove-links --log-to-adminlog --report-id=$temp_report ";

			if ($DB) {print "starting automated report process in a screen... |AR$temp_report|\n";}
			`/usr/bin/screen -d -m -S AR$temp_report $ar_command `;

			$stmtA="UPDATE vicidial_automated_reports SET run_now_trigger='N' where run_now_trigger='Y' and report_server IN('$server_ip'$THISserver_voicemailSQL) and report_id='$report_idARY[$r]';";
			$ARaffected_rows = $dbhA->do($stmtA);
			if ($DB) {print "FINISHED:   $ARaffected_rows|$stmtA|";}

			$r++;
			}
		if ($DB) {print "Automated Reports DONE: $r\n";}
		}
	}
################################################################################
#####  END  automated reports
################################################################################




################################################################################
#####  BEGIN  drop lists
################################################################################
if ($SSenable_drop_lists > 0)
	{
	$THISserver_voicemailSQL='';
	if ($THISserver_voicemail > 0) {$THISserver_voicemailSQL=",'active_voicemail_server'";}
	$stmtA = "SELECT dl_id FROM vicidial_drop_lists where ( (dl_server IN('$server_ip'$THISserver_voicemailSQL) ) and ( ( (active='Y') and (dl_times LIKE \"%$reset_test%\") and ( (dl_weekdays LIKE \"%$wday%\") or (dl_monthdays LIKE \"%$mday%\") ) ) or (run_now_trigger='Y') ) ) order by dl_id limit 1000;";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthBrows=$sthA->rows;
	if ($DB) {print "Checking for Drop Lists: |$sthBrows|$stmtA|\n";}
	$r=0;
	while ($sthBrows > $r)
		{
		@aryA = $sthA->fetchrow_array;
		$dl_idARY[$r]	=	$aryA[0];
		$r++;
		}
	$sthA->finish();

	if ($sthBrows > 0)
		{
		$r=0;
		while ($sthBrows > $r)
			{
			$temp_droplist = $dl_idARY[$r];
			$ar_command = "$PATHhome/AST_droplist_process.pl --quiet --log-to-adminlog --dl-id=$temp_droplist ";

			if ($DB) {print "starting drop list process in a screen... |AR$temp_droplist|\n";}
			`/usr/bin/screen -d -m -S AR$temp_droplist $ar_command `;

			$stmtA="UPDATE vicidial_drop_lists SET run_now_trigger='N' where run_now_trigger='Y' and dl_server IN('$server_ip'$THISserver_voicemailSQL) and dl_id='$dl_idARY[$r]';";
			$ARaffected_rows = $dbhA->do($stmtA);
			if ($DB) {print "FINISHED:   $ARaffected_rows|$stmtA|";}

			$r++;
			}
		if ($DB) {print "Drop Lists DONE: $r\n";}
		}
	}
################################################################################
#####  END  drop lists
################################################################################




################################################################################
#####  BEGIN  reset lists, and expired lists to inactive check
################################################################################
if ($AST_VDadapt > 0)
	{
	### reset lists if reset time matches
	$stmtA = "SELECT list_id FROM vicidial_lists where reset_time LIKE \"%$reset_test%\";";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthBrows=$sthA->rows;
	$i=0;
	while ($sthBrows > $i)
		{
		@aryA = $sthA->fetchrow_array;
		$list_id[$i] = "$aryA[0]";
		$i++;
		}
	$sthA->finish();

	if ($DBX) {print "RESET LIST:   $i|$reset_test";}

	$i=0;
	while ($sthBrows > $i)
		{
		$stmtA="UPDATE vicidial_list set called_since_last_reset='N' where list_id='$list_id[$i]';";
		$affected_rows = $dbhA->do($stmtA);

		$SQL_log = "$stmtA|";
		$SQL_log =~ s/;|\\|\'|\"//gi;

		if ($DB) {print "DONE\n";}
		if ($DB) {print "$trigger_results\n";}

		$stmtA="INSERT INTO vicidial_admin_log set event_date='$now_date', user='VDAD', ip_address='1.1.1.1', event_section='LISTS', event_type='RESET', record_id='$list_id[$i]', event_code='ADMIN RESET LIST', event_sql=\"$SQL_log\", event_notes='$affected_rows leads reset';";
		$Iaffected_rows = $dbhA->do($stmtA);
		if ($DB) {print "FINISHED:   $affected_rows|$Iaffected_rows|$stmtA";}

		$i++;
		}
	
	### set expired lists to inactive, only run at 12 minutes past the hour
	if ( ($SSexpired_lists_inactive > 0) && ($min =~ /12/) )
		{
		if ($DB) {print "STARTING EXPIRED LIST TO INACTIVE CHECK:   |$SSexpired_lists_inactive|$min";}

		$stmtA = "SELECT list_id FROM vicidial_lists where active='Y' and expiration_date < \"$today_date\";";
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthCrows=$sthA->rows;
		$i=0;
		while ($sthCrows > $i)
			{
			@aryA = $sthA->fetchrow_array;
			$expired_list_id[$i] = "$aryA[0]";
			$i++;
			}
		$sthA->finish();

		if ($DBX) {print "EXPIRED LIST CHECK:   $i|$sthCrows|$min";}

		$i=0;
		while ($sthCrows > $i)
			{
			$stmtA="UPDATE vicidial_lists set active='N' where list_id='$expired_list_id[$i]';";
			$affected_rows = $dbhA->do($stmtA);

			$SQL_log = "$stmtA|";
			$SQL_log =~ s/;|\\|\'|\"//gi;

			if ($DB) {print "DONE\n";}
			if ($DB) {print "$trigger_results\n";}

			$stmtA="INSERT INTO vicidial_admin_log set event_date='$now_date', user='VDAD', ip_address='1.1.1.1', event_section='LISTS', event_type='MODIFY', record_id='$expired_list_id[$i]', event_code='ADMIN EXPIRED LIST INACTIVE', event_sql=\"$SQL_log\", event_notes='$affected_rows list expired';";
			$Iaffected_rows = $dbhA->do($stmtA);
			if ($DB) {print "FINISHED:   $affected_rows|$Iaffected_rows|$stmtA";}

			$i++;
			}
		}
	}
################################################################################
#####  END  reset lists, and expired lists to inactive check
################################################################################







if ($DB) {print "DONE\n";}

exit;


sub teod_logger
	{
	if (!$teodLOGfile) {$teodLOGfile = "$PATHlogs/teod.$year-$mon-$mday";}

	### open the log file for writing ###
	open(Lout, ">>$teodLOGfile")
			|| die "Can't open $teodLOGfile: $!\n";
	print Lout "$now_date|$event_string|\n";
	close(Lout);
	$event_string='';
	}

sub leading_zero($) 
	{
    $_ = $_[0];
    s/^(\d)$/0$1/;
    s/^(\d\d)$/0$1/;
    return $_;
	} # End of the leading_zero() routine.

# subroutine to parse the asterisk version
# and return a hash with the various part
sub parse_asterisk_version
	{
	# grab the arguments
	my $ast_ver_str = $_[0];

	# get everything after the - and put it in $ast_ver_postfix
	my @hyphen_parts = split( /-/ , $ast_ver_str );

	my $ast_ver_postfix = $hyphen_parts[1];

	# now split everything before the - up by the .
	my @dot_parts = split( /\./ , $hyphen_parts[0] );

	my %ast_ver_hash;

	if ( $dot_parts[0] <= 1 )
		{
		%ast_ver_hash = (
				"major" => $dot_parts[0],
				"minor" => $dot_parts[1],
				"build" => $dot_parts[2],
				"revision" => $dot_parts[3],
				"postfix" => $ast_ver_postfix
			);
		}

	# digium dropped the 1 from asterisk 10 but we still need it
	if ( $dot_parts[0] > 1 )
		{
		%ast_ver_hash = (
				"major" => 1,
				"minor" => $dot_parts[0],
				"build" => $dot_parts[1],
				"revision" => $dot_parts[2],
				"postfix" => $ast_ver_postfix
			);
		}

	return ( %ast_ver_hash );
	}
