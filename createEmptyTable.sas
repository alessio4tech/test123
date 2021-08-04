/* Load var setting script */
%let curdir=%sysget(curdir);
%let file=/setvars.sas;
%include "&curdir.&file.";

/* Define library for storing dataset with performance data */
libname bigdisk "&bigdiskloc." FILELOCKWAIT=30;

/*Create empty perf stats table*/
data bigdisk.perfstats_mc;
	length runplatform $50 nworkers 8 coresw 8 ghzw 8 memw 8 qclass $25
	graph $50 query $35 reccount 8 concses 8 runtime 8;
	format rundate ddmmyy10.;
run;
