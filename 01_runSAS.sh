#!/bin/bash
curdir=$PWD

for i in $(seq 01 $2)
do {
if [ $i -lt 10 ]
then
    userid=gatedemo00$i
else
    userid=gatedemo0$i
fi
/opt/sas/spre/home/SASFoundation/bin/sas_u8 ./$1.sas -set conc $2 -set data $3 -set uid $userid  -set curdir $curdir -set rundate $4 -log ./$1_$userid.log -print ./$1_$userid.lst &
}
done
echo
echo Started $2 SAS sessions with program $1.sas on dataset $3...
echo
sleep 2
while [ "$count" != 0 ];
	do
		sleep 10;
		count=$(./02_monitorSAS.sh $1 |grep -c NOT)
		echo Running $count $1 sessions on dataset $3 for $SECONDS seconds
	done
echo Done

