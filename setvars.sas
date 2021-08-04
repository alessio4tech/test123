/* Set variables for environment */
/* ----------------------------- */
%let runplatform="Viya3-5 Army";  /*Give a name to your platform and possibly add
an identifier for an individual run if you plan several per day. Run date is captured
automatically.  This will serve to compare individual runs later in reporting. */

%let cassrv=node3.cluster.local;  /* CAS controller hostname */

%let targlib=public;  /* CAS library that will host the generated data sets while
running the tests and the final performance data set. */

%let perftable=perf_stats; /*CAS table to hold the performance stats.*/

%let usr=alessiot;  /*User used to connect to CAS.  Should be the one in the .authinfo file. */

%let nworkers=1; /* number of CAS worker nodes in setup.  0 for SMP.*/

%let coresw=8; /*number of cores per CAS worker node (or controller in SMP), obtained
through eg. lscpu*/

%let ghzw=2.0; /*speed of the CAS worker's cpu's, obtained through eg. lscpu*/

%let memw=32; /*memory per CAS worker node, eg. vmstat -s*/





/*---------------------------------------------------*/
/*Code defined for other scripts.  Don't change this.*/
/* Capture script input */
%let conc = %sysget(conc);
%let dataset=%sysget(data);
%let rundate=%sysget(rundate);
%let curdir=%sysget(curdir);
%let authfile=/.authinfo;
%let authinfo=&curdir.&authfile.;
%let bigdiskloc=&curdir.;

/*Define macro to set record count for dataset*/
%macro get_table_size(inset,macvar);
 data _null_;
  set &inset NOBS=size;
  call symput("&macvar",size);
 stop;
 run;
%mend;

/*Define result writing macro*/
%macro recordperf();
data work.tempperf;
		format rundate ddmmyy10.;
		
		runplatform=&runplatform.;
		rundate=%sysfunc(inputn(&rundate.,ddmmyy10.));
		nworkers=&nworkers.;
		coresw=&coresw.;
		ghzw=&ghzw.;
		memw=&memw.;
		qclass=&qclass.;
		graph=&graph.;
		query=&qname.;
		reccount=&reccount.;
		concses=&conc.;
		runtime = &stoptime.-&starttime.;
run;

proc append base=bigdisk.perfstats_mc data=work.tempperf;
run;
%mend;
/*---------------------------------------------------*/
