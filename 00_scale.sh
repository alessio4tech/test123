starttable=megacorp5_1m
rm datasets.txt

curdir=$PWD

for ((i=$1;i<=$2;i=i+$3))
	do
	{
	  targettable=megacorp5_$i; 
	  echo Creating $targettable;
	  /opt/sas/spre/home/SASFoundation/bin/sas_u8 ./scale.sas -set starttable $starttable -set targettable $targettable -set step $i -set curdir $curdir;
	  echo $targettable>>datasets.txt;
	}
	done
/opt/sas/spre/home/SASFoundation/bin/sas_u8 ./dropData.sas -set data megacorp5_1m -set curdir $curdir
echo Done
