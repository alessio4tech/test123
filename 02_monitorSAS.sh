#!/bin/bash
count=`ls -al $1_*.log | wc -l`
echo
echo Number of log files to parse: $count
echo

for i in $(seq 1 $count)
do {

   ended=0
   errors=0
   warns=0
   normal_warn=0
   runtime=

   if [ $i -lt 10 ]
   then
      userid=gatedemo00$i
   else
      userid=gatedemo0$i
   fi

   line=$userid

   ended=`cat ./$1_$userid.log | grep -i "The SAS System used" | wc -l`
   if [ $ended -gt 0 ]
   then  
      runtime=`tail -17 ./$1_$userid.log | grep "real time" | awk '{print $3 " " $4}'`
      line+=" | Finished | $runtime"   
   else 
      line+=" | NOT Finished"
   fi

   errors=`cat ./$1_$userid.log | grep -i "error" | wc -l`
   if [ $errors -gt 0 ]
   then
      line+=" | ERRORS"
   else
      line+=" | NO error"
   fi

   warns=`cat ./$1_$userid.log | grep -i "warning" | wc -l`
   normal_warn=`cat ./$1_$userid.log | grep -i "Unable to copy SASUSER registry to WORK registry" | wc -l`
   if [ $warns -gt $normal_warn ]
   then
      line+=" | WARNINGS"
   fi

   echo $line >> ./monitor.log

}
done

cat ./monitor.log
rm ./monitor.log
echo

