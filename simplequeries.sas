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

/* Define library for storing SAS dataset with performance data.*/
libname bigdisk "&bigdiskloc." FILELOCKWAIT=30;

/* Capture record count of table used in the tests */
%let reccount=;
%get_table_size(&targlib..&dataset.,reccount);
%put &=reccount;

/*START QUERIES TO CAS */

/* Simple Page 1: Expenses by Unit Status grouped by Product Brand*/
%let qclass='simple';
%let graph='Bar Chart';
%let qname='simplesummary';

/* Start timer */
%let starttime = %sysfunc(datetime());

proc cas;
	simple.summary
		groupByLimit=25000,
		inputs={{name="Expenses"}},
		orderBy={"Expenses","UnitStatus","ProductBrand"},
		orderByAgg={"SUM"},
		orderByDesc={"Expenses"},
		subSet={"SUM"},
		table={caslib="&targlib.",computedOnDemand="false",groupBy={{format="$.",name="UnitStatus"},
			{format="$.",name="ProductBrand"}},name="&dataset."};
run;

/* Stop timer */
%let stoptime = %sysfunc(datetime());

/* Record time */
%recordperf();

/* Simple Page 1: Crosstab - Date by Year 1*/
%let graph='Crosstab Distinct';
%let qname='simpledistinct';

/* Start timer */
%let starttime = %sysfunc(datetime());

proc cas;
	simple.distinct
	groupByLimit=24000,
	includeMissing=true,
	inputs={{name="Unit"}},
	orderBy={"_va_d_DateByYear_YEAR","Product"},
	orderByAgg={},orderByDesc={},
	table={caslib="&targlib.",computedOnDemand="false",computedVars={{name="_va_d_DateByYear_YEAR"}},
		computedVarsProgram="'_va_d_DateByYear_YEAR'n=yyq(year('DateByYear'n),1);",
		groupBy={{format="BEST32.",name="_va_d_DateByYear_YEAR"},{format="$.",name="Product"}},
		name="&dataset."};
run;

/* Stop timer */
%let stoptime = %sysfunc(datetime());

/* Record time */
%recordperf();

/* Simple Page 2 Expenses by Prod Desc Group, Unit Status*/
%let graph='Heatmap Custom Group';
%let qname='simplesummary_customgroup';

/* Start timer */
%let starttime = %sysfunc(datetime());

proc cas;
	simple.summary
	groupByLimit=3000,
	inputs={{name="Expenses"}},
	orderBy={"UnitStatus","_va_c_Prod_Desc_Group"},orderByAgg
	={},orderByDesc={},subSet={"SUM"},
	table={caslib="&targlib.",computedOnDemand="false",computedVars={{name="_va_c_Prod_Desc_Group"}},
	computedVarsProgram="length '_va_c_Prod_Desc_Group'n $13;
		if (('ProductDescription'n IN ('100 Piece','1000 Piece','1500 Piece','2000 Piece','250 Piece','2500 Piece','500 Piece','750 Piece','Abyssinian','African','Air Force','American Quarter','American Shorthair','Andalusian','Ape','Appaloosa')))then do;
		'_va_c_Prod_Desc_Group'n= 'Value Group 1';
		end;
		else do;
		if (('ProductDescription'n IN ('Arabian','Army','Asian','Backgammon','Baseball','Basketball (F)','Basketball (M)','Beagles','Birman','Black','Cheeta','Classical','Dachshunds','Female','Football','German Shepherds')))then do;
		'_va_c_Prod_Desc_Group'n= 'Value Group 2';
		end;
		else do;
		if (('ProductDescription'n IN ('Blue','Blues','Bob','Boxers','Brown','Gibbon','Labrador Retrievers','R&B','Softball','Thoroughbred','Vollyball')))then do;
		'_va_c_Prod_Desc_Group'n= 'Value Group 3';
		end;
		else do;
		if (('ProductDescription'n IN ('Chess','Checkers','Custom','Maine Coon','Miniature Schnauzer','Nascar','Pink Unicorns','Playing Cards','Rock','Soccer (F)','Soccer (M)')))then do;
		'_va_c_Prod_Desc_Group'n= 'Value Group 4';
		end;
		else do;
		if (('ProductDescription'n IN ('Dos','Golden Retrievers','Golf (M)','Golf (W)','Gorilla','Green','Green Lantern','Hulk','Siamese','Slam','Spiderman','Spike','Superman','Tennessee Walking','Tennis (F)','Tennis (M)','Tiger','Tonkinese','Welsh Pony','White','Wonder Woman','Yellow','Yorkshire Terriers')))then do;
		'_va_c_Prod_Desc_Group'n= 'Value Group 5';
		end;
		else do;
		'_va_c_Prod_Desc_Group'n= 'Value Group 6';
		end;
		end;
		end;
		end;
		end;
		;",
		groupBy={{format="$.",name="UnitStatus"},{format="$.",name="_va_c_Prod_Desc_Group"}},
		name="&dataset."};
run;


/* Stop timer */
%let stoptime = %sysfunc(datetime());

/* Record time */
%recordperf();

/* Simple Page 2 Profit Calc, Unit (Distinct count) 1 by Prod Desc Group*/
%let graph='Bar Chart CustomGroup Calc Distinct';
%let qname='aggregatedistinct_cg_cm';

/* Start timer */
%let starttime = %sysfunc(datetime());

proc cas;
	aggregation.aggregate
	groupByLimit=7400,
	table={caslib="&targlib.",computedOnDemand="false",computedVars={{name="_va_c_Prod_Desc_Group"},
	{name="_va_d_Profit_Calc"}},
	computedVarsProgram="length '_va_c_Prod_Desc_Group'n $13;
		if (('ProductDescription'n IN ('100 Piece','1000 Piece','1500 Piece','2000 Piece','250 Piece','2500 Piece','500 Piece','750 Piece','Abyssinian','African','Air Force','American Quarter','American Shorthair','Andalusian','Ape','Appaloosa')))then do;
		'_va_c_Prod_Desc_Group'n= 'Value Group 1';
		end;
		else do;
		if (('ProductDescription'n IN ('Arabian','Army','Asian','Backgammon','Baseball','Basketball (F)','Basketball (M)','Beagles','Birman','Black','Cheeta','Classical','Dachshunds','Female','Football','German Shepherds')))then do;
		'_va_c_Prod_Desc_Group'n= 'Value Group 2';
		end;
		else do;
		if (('ProductDescription'n IN ('Blue','Blues','Bob','Boxers','Brown','Gibbon','Labrador Retrievers','R&B','Softball','Thoroughbred','Vollyball')))then do;
		'_va_c_Prod_Desc_Group'n= 'Value Group 3';
		end;
		else do;
		if (('ProductDescription'n IN ('Chess','Checkers','Custom','Maine Coon','Miniature Schnauzer','Nascar','Pink Unicorns','Playing Cards','Rock','Soccer (F)','Soccer (M)')))then do;
		'_va_c_Prod_Desc_Group'n= 'Value Group 4';
		end;
		else do;
		if (('ProductDescription'n IN ('Dos','Golden Retrievers','Golf (M)','Golf (W)','Gorilla','Green','Green Lantern','Hulk','Siamese','Slam','Spiderman','Spike','Superman','Tennessee Walking','Tennis (F)','Tennis (M)','Tiger','Tonkinese','Welsh Pony','White','Wonder Woman','Yellow','Yorkshire Terriers')))then do;
		'_va_c_Prod_Desc_Group'n= 'Value Group 5';
		end;
		else do;
		'_va_c_Prod_Desc_Group'n= 'Value Group 6';
		end;
		end;
		end;
		end;
		end;
		;
		'_va_d_Profit_Calc'n=('Revenue'n - 'Expenses'n);;",
	groupBy={{format="$.",name="_va_c_Prod_Desc_Group"}},
	name="&dataset.",onDemand="false"},
	varSpecs={{agg="SUMMARY",includeMissing=true,name="_va_d_Profit_Calc",summarySubset={"SUM"}}};
		
	simple.distinct
	groupByLimit=25000,
	includeMissing=true,
	inputs={{name="Unit"}},
	orderBy={"_va_c_Prod_Desc_Group"},
	orderByAgg={},orderByDesc={},
	table={caslib="&targlib.",computedOnDemand="false",computedVars={{name="_va_c_Prod_Desc_Group"}},
	computedVarsProgram="length '_va_c_Prod_Desc_Group'n $13;
		if (('ProductDescription'n IN ('100 Piece','1000 Piece','1500 Piece','2000 Piece','250 Piece','2500 Piece','500 Piece','750 Piece','Abyssinian','African','Air Force','American Quarter','American Shorthair','Andalusian','Ape','Appaloosa')))then do;
		'_va_c_Prod_Desc_Group'n= 'Value Group 1';
		end;
		else do;
		if (('ProductDescription'n IN ('Arabian','Army','Asian','Backgammon','Baseball','Basketball (F)','Basketball (M)','Beagles','Birman','Black','Cheeta','Classical','Dachshunds','Female','Football','German Shepherds')))then do;
		'_va_c_Prod_Desc_Group'n= 'Value Group 2';
		end;
		else do;
		if (('ProductDescription'n IN ('Blue','Blues','Bob','Boxers','Brown','Gibbon','Labrador Retrievers','R&B','Softball','Thoroughbred','Vollyball')))then do;
		'_va_c_Prod_Desc_Group'n= 'Value Group 3';
		end;
		else do;
		if (('ProductDescription'n IN ('Chess','Checkers','Custom','Maine Coon','Miniature Schnauzer','Nascar','Pink Unicorns','Playing Cards','Rock','Soccer (F)','Soccer (M)')))then do;
		'_va_c_Prod_Desc_Group'n= 'Value Group 4';
		end;
		else do;
		if (('ProductDescription'n IN ('Dos','Golden Retrievers','Golf (M)','Golf (W)','Gorilla','Green','Green Lantern','Hulk','Siamese','Slam','Spiderman','Spike','Superman','Tennessee Walking','Tennis (F)','Tennis (M)','Tiger','Tonkinese','Welsh Pony','White','Wonder Woman','Yellow','Yorkshire Terriers')))then do;
		'_va_c_Prod_Desc_Group'n= 'Value Group 5';
		end;
		else do;
		'_va_c_Prod_Desc_Group'n= 'Value Group 6';
		end;
		end;
		end;
		end;
		end;
		;",
		groupBy={{format="$.",name="_va_c_Prod_Desc_Group"}},name="&dataset."};
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


