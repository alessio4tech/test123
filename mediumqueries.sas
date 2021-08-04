/* Write log output from included programs */
options source2;

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

/* Define library for storing dataset with performance data */
libname bigdisk "&bigdiskloc." FILELOCKWAIT=30;

/* Capture record count of table used in the tests */
%let reccount=;
%get_table_size(&targlib..&dataset.,reccount);
%put &=reccount;

/*START QUERIES TO CAS */



/* Medium Page 1 Correlation of Selected Measures */
%let qclass='medium';
%let graph='Correlation Matrix';
%let qname='simpleregression';

/* Start timer */
%let starttime = %sysfunc(datetime());

proc cas;
	simple.regression
	inputs={{name="UnitDowntime"},{name="UnitAge"},{name="Revenue"},{name="Profit"},
		{name="ProductQuality"},{name="ProductMaterialCost"},{name="FacilityAge"},
		{name="Expenses"},{name="EmployeesUsed"}},
		order=1,
		table={caslib="&targlib.",computedOnDemand="false",name="&dataset."};
run;


/* Stop timer */
%let stoptime = %sysfunc(datetime());

/* Record time */
%recordperf();

/* Medium Page 1  Linear regression */
%let graph='Linear Regression';
%let qname='regression';

/* Start timer */
%let starttime = %sysfunc(datetime());

proc cas;
	regression.glm
	class={{vars={"FacilityCity","Product","ProductLine","Facility","FacilityRegion",
		"FacilityState","ProductBrand","Unit"}}},
	code={comment=true,indentSize=3,labelId=1351,noCompPgm=true,tabForm=false},
	display={keyIsPath=false},maxParameters=2047,
	model={depVars={{name="UnitYieldTarget"}},
		effects={{vars={"FacilityCity","Product","ProductLine","Facility","FacilityRegion",
			"FacilityState","ProductBrand","Unit","FacilityAge","ProductMaterialCost",
			"UnitAge","EmployeesUsed","UnitLifespan","UnitLifespanLimit","UnitReliability"}}},
			informative=false},
	output={casOut={caslib="CASUSER",name="_va_9_score",onDemand="false",replace=true,replication=0},
		cooksD="_COOKD_",copyVars={"UnitYieldTarget","FacilityCity","Product","ProductLine",
		"Facility","FacilityRegion","FacilityState","ProductBrand","Unit","FacilityAge",
		"ProductMaterialCost","UnitAge","EmployeesUsed","UnitLifespan","UnitLifespanLimit",
		"UnitReliability"},
	covRatio="_COVRATIO_", dffits="_DFFITS_", h="_LEVERAGE_",likeDist="_LIKEDIST_",
	pred="_PREDLIN_",press="_PRESS_",resid="_RESID_",role="_FITROLE_",rStudent="_RSTUDENT_",
	student="_STUDENT_"},parmEstLevDetails="RAW_AND_FORMATTED",ss3=true,
	table={caslib="&targlib.",computedOnDemand="false",name="&dataset.",onDemand="false"},
	vaOpts={endDelimiter="}",startDelimiter="{",useEffectDelimiters=true};
	
	table.columnInfo
	table={caslib="&targlib.",computedOnDemand="false",name="&dataset."};
	
	table.dropTable
	caslib="CASUSER",name="_va_9_score";
	
	table.tableInfo
	caslib="&targlib.",name="&dataset.";
run;

/* Stop timer */
%let stoptime = %sysfunc(datetime());

/* Record time */
%recordperf();

/* Page 3 Object Decision Tree */
%let graph='Decision Tree';
%let qname='decisiontree';

/* Start timer */
%let starttime = %sysfunc(datetime());

proc cas;
	decisionTree.dtreeTrain
	binOrder=true,casOut={caslib="CASUSER",name="_va_14_dtree",onDemand="false",replication=0},cfLev=0.25,code={columnWdth=32767,comment=true,indentSize=3,labelId=2436,noCompPgm=true,tabForm=false},crit="GAIN",encodeName=true,fuzzy=1,greedy=true,includeMissing=true,inputs={{name="ProductBrand"},{name="FacilityAge"},{name="ProductMaterialCost"},{name="UnitAge"},{name="EmployeesUsed"},{name="UnitLifespan"},{name="UnitLifespanLimit"},{name="UnitReliability"},{name="FacilityCity"},{name="Facility"},{name="FacilityRegion"},{name="FacilityState"}},leafSize=5,maxBranch=2,maxLevel=6,mergeBin=true,minUseInSearch=1,missing="USEINSEARCH",nBins=20,nominals={{format="$.",name="ProductBrand"},{format="$.",name="FacilityCity"},{format="$.",name="Facility"},{format="$.",name="FacilityRegion"},{format="$.",name="FacilityState"}},prune=true,splitOnce=false,stat=true,table={caslib="&targlib.",computedOnDemand="false",name="&dataset.",onDemand="false"},target="ProductBrand",targetOrder="ascending",varImp=true;
	
	simple.distinct
	includeMissing=true,inputs={{name="FacilityCity"},{name="Facility"},{name="FacilityRegion"},{name="FacilityState"}},maxNVals=10240,resultLimit=10240,table={caslib="&targlib.",computedOnDemand="false",name="&dataset."};
	
	simple.distinct
	includeMissing=true,inputs={{name="ProductBrand"}},maxNVals=100,resultLimit=100,table={caslib="&targlib.",computedOnDemand="false",name="&dataset."};
	
	simple.groupBy
	inputs={{format="$.",name="Facility"}},table={caslib="&targlib.",computedOnDemand="false",name="&dataset."};
	
	simple.groupBy
	inputs={{format="$.",name="FacilityCity"}},table={caslib="&targlib.",computedOnDemand="false",name="&dataset."};
	
	simple.groupBy
	inputs={{format="$.",name="FacilityRegion"}},table={caslib="&targlib.",computedOnDemand="false",name="&dataset."};
	
	simple.groupBy
	inputs={{format="$.",name="FacilityState"}},table={caslib="&targlib.",computedOnDemand="false",name="&dataset."};
	
	simple.summary
	table={caslib="CASUSER",computedOnDemand="false",name="_va_14_dtree",vars={{name="_NumTargetLevel_"},{name="_NumChild_"},{name="_PBranches_"}}};
	
	table.columnInfo
	table={caslib="CASUSER",computedOnDemand="false",name="_va_14_dtree"};
	
	table.fetch
	fetchVars={{name="_Target_"},{name="_NumTargetLevel_"},{name="_TargetVal0_"},{name="_TargetVal1_"},{name="_CI0_"},{name="_CI1_"},{name="_NodeID_"},{name="_TreeLevel_"},{name="_NodeName_"},{name="_Parent_"},{name="_ParentName_"},{name="_NodeType_"},{name="_Gain_"},{name="_NumObs_"},{name="_TargetValue_"},{name="_NumChild_"},{name="_ChildID0_"},{name="_ChildID1_"},{name="_PBranches_"},{name="_PBName0_"},{name="_PBName1_"},{name="_PBName2_"},{name="_PBName3_"},{name="_PBName4_"},{name="_PBName5_"},{name="_PBName6_"},{name="_PBName7_"},{name="_PBName8_"},{name="_PBName9_"},{name="_PBName10_"},{name="_MissingOnNode_"}},from=0,maxRows=5,sasTypes=false,sortBy={{formatted="RAW",name="_NodeID_",order="ASCENDING"}},table={caslib="CASUSER",computedOnDemand="false",name="_va_14_dtree"},to=5;
	
	table.recordCount
	table={caslib="CASUSER",computedOnDemand="false",name="_va_14_dtree"};
	
	table.dropTable
	caslib="CASUSER",name="_va_14_dtree";
	
	table.recordCount
	table={caslib="&targlib.",computedOnDemand="false",name="&dataset."};
	
	table.tableInfo
	caslib="&targlib.",name="&dataset.";
run;
quit;


/* Stop timer */
%let stoptime = %sysfunc(datetime());

/* Record time */
%recordperf();

/*Upload performance data to CAS */
proc casutil;
	droptable incaslib=&targlib. casdata="&perftable." quiet;
run;
quit;

data &targlib..&perftable. (promote=YES);
	set bigdisk.perfstats_mc;
run;

proc casutil;
	save incaslib=&targlib. outcaslib=&targlib. casdata="&perftable." casout="&perftable." replace;
run;
quit;

/*****************************************************************************/
/*  Terminate the specified CAS session (mySession). No reconnect is possible*/
/*****************************************************************************/

cas mySession terminate;
