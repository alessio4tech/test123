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


/* Heavy Page 1 Neural Network */
%let qclass='heavy';
%let graph='Neural Network';
%let qname='neuralnet';

/* Start timer */
%let starttime = %sysfunc(datetime());

proc cas;
	neuralNet.annTrain
	acts={"TANH"},arch="MLP",casOut={caslib="CASUSER",name="_va_6_network",onDemand="false",replace=true,replication=0},code={comment=true,indentSize=3,labelId=3987,noCompPgm=true,tabForm=false},encodeName=true,hiddens={10},inputs={{name="FacilityAge"},{name="ProductMaterialCost"},{name="UnitAge"},{name="EmployeesUsed"},{name="UnitLifespan"},{name="UnitLifespanLimit"},{name="UnitReliability"},{name="FacilityCity"},{name="Facility"},{name="FacilityRegion"},{name="FacilityState"}},nloOpts={algorithm="lbfgs",optmlOpt={maxIters=250,maxTime=270.0,regL1=0.0,regL2=0.1},printOpt={statusMsg=true}},nominals={{format="$.",name="ProductBrand"},{format="$.",name="FacilityCity"},{format="$.",name="Facility"},{format="$.",name="FacilityRegion"},{format="$.",name="FacilityState"}},seed=1234.0,std="MIDRANGE",table={caslib="&targlib.",computedOnDemand="false",name="&dataset.",onDemand="false"},target="ProductBrand";
	
	simple.distinct
	includeMissing=false,inputs={{format="$.",name="ProductBrand"},{format="$.",name="FacilityCity"},{format="$.",name="Facility"},{format="$.",name="FacilityRegion"},{format="$.",name="FacilityState"}},maxNVals=10000,resultLimit=10000,table={caslib="&targlib.",computedOnDemand="false",name="&dataset."};
	
	simple.groupBy
	inputs={{format="$.",name="ProductBrand"}},resultLimit=101,table={caslib="&targlib.",computedOnDemand="false",computedVars={{name="_va_d_filterCalculation"}},computedVarsProgram="'_va_d_filterCalculation'n=(NOT(MISSING('ProductBrand'n)) AND NOT(MISSING('FacilityAge'n)) AND NOT(MISSING('ProductMaterialCost'n)) AND NOT(MISSING('UnitAge'n)) AND NOT(MISSING('EmployeesUsed'n)) AND NOT(MISSING('UnitLifespan'n)) AND NOT(MISSING('UnitLifespanLimit'n)) AND NOT(MISSING('UnitReliability'n)) AND NOT(MISSING('FacilityCity'n)) AND NOT(MISSING('Facility'n)) AND NOT(MISSING('FacilityRegion'n)) AND NOT(MISSING('FacilityState'n)));;",name="&dataset.",where="NOT('_va_d_filterCalculation'n = 0)"};
	
	simple.groupBy
	inputs={{format="$.",name="ProductBrand"}},table={caslib="&targlib.",computedOnDemand="false",name="&dataset."};
	
	simple.summary
	casOut={caslib="CASUSER",name="_va_7_layerSummary0",onDemand="false",replace=true,replication=0},inputs={{name="_local_id_3987_1"},{name="_Weight0_"}},subSet={"MEAN"},table={caslib="CASUSER",computedOnDemand="false",computedVars={{name="_local_id_3987_1"}},computedVarsProgram="_local_id_3987_1=abs(_Weight0_);",groupBy={{name="_NodeID_"}},name="_va_6_network",where="('_LayerID_'n = 0.0)"};
	
	simple.summary
	casOut={caslib="CASUSER",name="_va_8_layerSummary1",onDemand="false",replace=true,replication=0},inputs={{name="_local_id_3987_1"},{name="_Weight0_"}},subSet={"MEAN"},table={caslib="CASUSER",computedOnDemand="false",computedVars={{name="_local_id_3987_1"}},computedVarsProgram="_local_id_3987_1=abs(_Weight0_);",groupBy={{name="_NodeID_"}},name="_va_6_network",where="('_LayerID_'n = 1.0)"};
	
	simple.summary
	casOut={caslib="CASUSER",name="_va_9_layerSummary2",onDemand="false",replace=true,replication=0},inputs={{name="_local_id_3987_1"},{name="_Weight0_"}},subSet={"MEAN"},table={caslib="CASUSER",computedOnDemand="false",computedVars={{name="_local_id_3987_1"}},computedVarsProgram="_local_id_3987_1=abs(_Weight0_);",groupBy={{name="_ConnTo_"}},name="_va_6_network",where="('_LayerID_'n = 1.0)"};
	
	table.fetch
	from=0,maxRows=1,sasTypes=false,table={caslib="CASUSER",computedOnDemand="false",name="_va_6_network",where="'_NodeID_'n IN (77.0)"},to=1;
	
	table.fetch
	from=0,maxRows=10,sasTypes=false,sortBy={{name="_Mean_",order="DESCENDING"}},table={caslib="CASUSER",computedOnDemand="false",name="_va_8_layerSummary1",vars={{name="_NodeID_"},{name="_Mean_"}},where="('_Column_'n = '_Weight0_') AND '_NodeID_'n IN (67.0,69.0,70.0,74.0,71.0,72.0,68.0,66.0,75.0,73.0)"},to=10;
	
	table.fetch
	from=0,maxRows=10,sasTypes=false,sortBy={{name="_Mean_",order="DESCENDING"}},table={caslib="CASUSER",computedOnDemand="false",name="_va_8_layerSummary1",vars={{name="_NodeID_"},{name="_Mean_"}},where="NOT(('_Column_'n = '_Weight0_'))"},to=10;
	
	table.fetch
	from=0,maxRows=10,sasTypes=false,table={caslib="CASUSER",computedOnDemand="false",name="_va_6_network",where="'_NodeID_'n IN (67.0,69.0,70.0,74.0,71.0,72.0,68.0,66.0,75.0,73.0) AND '_ConnTo_'n IN (77.0)"},to=10;
	
	table.fetch
	from=0,maxRows=2,sasTypes=false,sortBy={{name="_Mean_",order="DESCENDING"}},table={caslib="CASUSER",computedOnDemand="false",name="_va_9_layerSummary2",vars={{name="_ConnTo_"},{name="_Mean_"}},where="('_Column_'n = '_Weight0_') AND '_ConnTo_'n IN (77.0)"},to=2;
	
	table.fetch
	from=0,maxRows=2,sasTypes=false,sortBy={{name="_Mean_",order="DESCENDING"}},table={caslib="CASUSER",computedOnDemand="false",name="_va_9_layerSummary2",vars={{name="_ConnTo_"},{name="_Mean_"}},where="NOT(('_Column_'n = '_Weight0_'))"},to=2;
	
	table.fetch
	from=0,maxRows=50,sasTypes=false,sortBy={{name="_Mean_",order="DESCENDING"}},table={caslib="CASUSER",computedOnDemand="false",name="_va_7_layerSummary0",vars={{name="_NodeID_"},{name="_Mean_"}},where="('_Column_'n = '_Weight0_') AND '_NodeID_'n IN (33.0,13.0,56.0,7.0,59.0,31.0,49.0,1.0,50.0,14.0,34.0,52.0,0.0,51.0,64.0,55.0,10.0,38.0,57.0,53.0,22.0,65.0,39.0,37.0,26.0,9.0,60.0,36.0,62.0,32.0,19.0,54.0,24.0,29.0,12.0,48.0,16.0,41.0,27.0,44.0,15.0,30.0,20.0,42.0,11.0,35.0,25.0,43.0,58.0,63.0)"},to=50;
	
	table.fetch
	from=0,maxRows=50,sasTypes=false,sortBy={{name="_Mean_",order="DESCENDING"}},table={caslib="CASUSER",computedOnDemand="false",name="_va_7_layerSummary0",vars={{name="_NodeID_"},{name="_Mean_"}},where="NOT(('_Column_'n = '_Weight0_'))"},to=50;
	
	table.fetch
	from=0,maxRows=500,sasTypes=false,table={caslib="CASUSER",computedOnDemand="false",name="_va_6_network",where="'_NodeID_'n IN (33.0,13.0,56.0,7.0,59.0,31.0,49.0,1.0,50.0,14.0,34.0,52.0,0.0,51.0,64.0,55.0,10.0,38.0,57.0,53.0,22.0,65.0,39.0,37.0,26.0,9.0,60.0,36.0,62.0,32.0,19.0,54.0,24.0,29.0,12.0,48.0,16.0,41.0,27.0,44.0,15.0,30.0,20.0,42.0,11.0,35.0,25.0,43.0,58.0,63.0) AND '_ConnTo_'n IN (67.0,69.0,70.0,74.0,71.0,72.0,68.0,66.0,75.0,73.0)"},to=500;
	
	table.dropTable
	caslib="CASUSER",name="_va_6_network";
	
	table.tableInfo
	caslib="&targlib.",name="&dataset.";

run;


/* Stop timer */
%let stoptime = %sysfunc(datetime());

/* Record time */
%recordperf();

/* Heavy Page 1 Gradient Boosting */
%let graph='Gradient Boosting';
%let qname='gradboost';

/* Start timer */
%let starttime = %sysfunc(datetime());

proc cas;
	decisionTree.gbtreeTrain
	binOrder=true,
	casOut={caslib="CASUSER",name="_va_5_gbTree",onDemand="false",replace=true,replication=0},
	distribution="MULTINOMIAL",encodeName=true,greedy=true,includeMissing=true,
	inputs={{name="ProductBrand"},{name="FacilityAge"},{name="ProductMaterialCost"},{name="UnitAge"},
		{name="EmployeesUsed"},{name="UnitLifespan"},{name="UnitLifespanLimit"},{name="UnitReliability"},
		{name="FacilityCity"},{name="Facility"},{name="FacilityRegion"},{name="FacilityState"}},
	leafSize=5,learningRate=0.1,m=11,maxBranch=2,maxLevel=6,mergeBin=true,minUseInSearch=1,
	missing="USEINSEARCH",nBins=20,
	nominals={{format="$.",name="ProductBrand"},{format="$.",name="FacilityCity"},
		{format="$.",name="Facility"},{format="$.",name="FacilityRegion"},{format="$.",name="FacilityState"}},
	nTree=50,
	savestate={caslib="CASUSER",name="_va_model3753",replace=true},
	seed=1.0,subSampleRate=0.5,
	table={caslib="&targlib.",computedOnDemand="false",name="&dataset.",onDemand="false"},
	target="ProductBrand",varImp=true;
	
	decisionTree.gbtreeScore
	assess=false,copyVars={"ProductBrand"},includeMissing=true,
	modelTable={caslib="CASUSER",name="_va_5_gbTree"},
	table={caslib="&targlib.",computedOnDemand="false",name="&dataset."},target="ProductBrand";
	
	simple.distinct
	includeMissing=true,
	inputs={{name="FacilityCity"},{name="Facility"},{name="FacilityRegion"},{name="FacilityState"}},
	maxNVals=10240,resultLimit=10240,
	table={caslib="&targlib.",computedOnDemand="false",name="&dataset."};
	
	simple.distinct
	includeMissing=true,inputs={{name="ProductBrand"}},maxNVals=100,resultLimit=100,
	table={caslib="&targlib.",computedOnDemand="false",name="&dataset."};
	
	simple.groupBy
	inputs={{format="$.",name="Facility"}},
	table={caslib="&targlib.",computedOnDemand="false",name="&dataset."};
	
	simple.groupBy
	inputs={{format="$.",name="FacilityCity"}},
	table={caslib="&targlib.",computedOnDemand="false",name="&dataset."};
	
	simple.groupBy
	inputs={{format="$.",name="FacilityRegion"}},
	table={caslib="&targlib.",computedOnDemand="false",name="&dataset."};
	
	simple.groupBy
	inputs={{format="$.",name="FacilityState"}},
	table={caslib="&targlib.",computedOnDemand="false",name="&dataset."};
	
	simple.groupBy
	inputs={{format="$.",name="ProductBrand"}},
	table={caslib="&targlib.",computedOnDemand="false",name="&dataset."};
	
	table.dropTable
	caslib="CASUSER",name="_va_5_gbTree";
	
	table.recordCount
	table={caslib="CASUSER",computedOnDemand="false",name="_va_model3753"};
	
	table.dropTable
	caslib="CASUSER",name="_va_model3753";
		
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
