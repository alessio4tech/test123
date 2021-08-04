/* Write log output from included programs */
options source2;

/* Load var setting script */
%let curdir=%sysget(curdir);
%let file=/setvars.sas;
%include "&curdir.&file.";

/*  Start a session named mySession using the existing CAS server connection */
/*  Assign SAS libs to CAS libs                                              */

options cashost="&cassrv." casport=5570 ;
options fullstimer;

cas mySession sessopts=(caslib=&targlib. timeout=1800 locale="en_US")
user="&usr." authinfo="&authinfo.";

caslib _all_ assign;

/*Capture script input*/
 %let data = %sysget(data);

/*Load data*/
proc casutil;
	load casdata="&data..sashdat" casout="&data.";
	promote casdata="&data.";
run;
quit;

 		
 	

cas mySession terminate;
