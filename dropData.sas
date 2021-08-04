/* Write log output from included programs */
options source2;

/* Load var setting script */
%let curdir=%sysget(curdir);
%let file=/setvars.sas;
%include "&curdir.&file.";

/*  Start a session named mySession using the existing CAS server connection */
/*  Assign SAS libs to CAS libs                                              */

options cashost="&cassrv." casport=5570 ;

cas mySession sessopts=(caslib=&targlib. timeout=1800 locale="en_US")
user="&usr." authinfo="&authinfo.";

caslib _all_ assign;


/* Define library for storing dataset with performance data */
libname bigdisk "&bigdiskloc." FILELOCKWAIT=30;

/*Drop previous version of performance data from CAS*/
proc casutil;
	droptable incaslib="&targlib." casdata="perfstats_mc";
run;

/*Map longer than 8 character CASlib to 8 char SAS lib*/
data _null_;
	t=substr("&targlib.",1,8);
	call symputX('tlib',t);
run;

%put &tlib.;

/*Load latest performance data to CAS*/
data &tlib..perfstats_mc (promote=yes);
	set bigdisk.perfstats_mc;
run;
quit;

/*Save latest performance CAS table in the caslib*/
proc casutil;
	save incaslib="&targlib." casdata="perfstats_mc" outcaslib="&targlib." casout="perfstats_mc" replace;
run;
quit;

/*Drop latest data from CAS*/
proc casutil;
	droptable casdata="&dataset.";
run;
quit;

/*****************************************************************************/
/*  Terminate the specified CAS session (mySession). No reconnect is possible*/
/*****************************************************************************/

cas mySession terminate;
