/* Write log output from included programs */
options source2 macrogen symbolgen mlogic mprint;

/* Load var setting script */
%let curdir=%sysget(curdir);
%let file=/setvars.sas;
%include "&curdir.&file.";

/*  Start a session named mySession using the existing CAS server connection */
/*  Assign SAS libs to CAS libs                                              */

options cashost="&cassrv." casport=5570 ;
/*options fullstimer;*/

cas mySession sessopts=(caslib=&targlib. timeout=1800 locale="en_US")
user="&usr." authinfo="&authinfo.";
caslib _all_ assign;

/* Define library holding the original data set.*/
libname bigdisk "&bigdiskloc." FILELOCKWAIT=30;

/*Capture input from Shell script*/
%let starttable = %sysget(starttable);
%let targettable=%sysget(targettable);
%let step=%sysget(step);

/*Loading original data set to CAS for in-memory replication.*/
data &targlib..&starttable. (promote=yes);
	set bigdisk.&starttable.;
run;

/*Multiplying rows to new dataset.*/
data &targlib..&targettable. (promote=yes);
	set &targlib..&starttable.;
	do i=1 to &step.;
		output;
	end;
run;

/*Saving data sets to CAS lib for loading prior to running the test on it.*/
proc casutil;
	save casdata="&targettable." outcaslib="&targlib." replace;
	droptable incaslib="&targlib." casdata="&targettable.";
	droptable incaslib="&targlib." casdata="&starttable.";
run;
quit;

cas mySession terminate;	
