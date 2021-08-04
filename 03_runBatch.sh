#!/bin/bash
curdir=$PWD
rundate=$(date -d now +%d/%m/%Y)

if [ -z "$1" ]
  then
    repeat=1
  else
    repeat=$1
fi

cat datasets.txt | while read d

do {
	echo Loading dataset $d
	/opt/sas/spre/home/SASFoundation/bin/sas_u8 ./loadData.sas -set data $d -set curdir $curdir


	for i in 1 5 10 15 20;
	do {
		for ((x=1;x<=$repeat;x++));
		do {
			./01_runSAS.sh simplequeries "$i" "$d" "$rundate";
		}
		done
   	}
	done

	for k in 1 2 4 6 8 ;
	do {
		for ((y=1;y<=$repeat;y++));
		do {
                	./01_runSAS.sh mediumqueries "$k" "$d" "$rundate";
		}
		done
   	}
	done

	for m in 1 2 3;
	do {
		for ((z=1;z<=$repeat;z++));
		do {
                	./01_runSAS.sh heavyqueries "$m" "$d" "$rundate";
		}
		done
   	}
	done

	/opt/sas/spre/home/SASFoundation/bin/sas_u8 ./dropData.sas -set data $d -set curdir $curdir
}
done
echo All done!!!
