# Instructions

## 1. Preparation

### 1.1 Save files:
* Save all files in 1 folder on a SAS server (only used the SPRE server during dev)
* Adapt the .authinfo file with the details relevant to the environment
* if necessary chmod the .sh files to be executable by the user running them.

    #### *Remark:*
     *!!! .authinfo file is sensitive to location and permissions (should be 600 for the user running the final script).  Test this prior to launching the full script.*  


### 1.2 Adapt setup specific parameters in setvars.sas:
* %let runplatform="Viya3-4 Run A";  /*Give a name to your platform and possibly add an identifier for an individual run if you plan several per day. Run date is captured automatically.  This will serve to compare individual runs later in reporting. */
* %let cassrv=viya3-4-cas.ps-cp.sashq-d.openstack.sas.com;  /* CAS controller hostname */
* %let targlib=public;  /* CAS library that will host the scaled data sets and the final performance data set. */
* %let usr=sbxpet;  /*User used to connect to CAS.  Should be the one in the .authinfo file. */
* %let nworkers=0; /* number of CAS worker nodes in setup.  0 for SMP.*/
* %let coresw=16; /*number of cores per CAS worker node (or controller in SMP), obtained through eg. lscpu*/
* %let ghzw=2.7; /*speed of the CAS worker's cpu's, obtained through eg. lscpu*/
* %let memw=128; /*memory per CAS worker node, eg. vmstat -s*/

    #### *Remarks:*
     * If the targlib is a non-path CASlib, please adapt loadData.sas by removing the .sashdat part in the proc casutil near the end.
     * If the targlib is a CASLIB with a name longer than 8 characters, the scripts will error as the SAS code used won't auto-map a +8 character caslib to a libname.  Or you use another, or you add a line to all .sas scripts (underneath creating the CAS sessions):
       caslib <name set in setvars> cas caslib="<your CASLIB with more than 8 characters>";


### 1.3 Create empty performance data set:
* Before 1st time use: please create an empty dataset for collecting the test results: ./000_createperftable.sh


### 1.4 SAS_U8 location:
* If necessary change the location for your SAS executable (currently set to /opt/sas/spre/home/SASFoundation/bin/sas_u8) in following scripts: 000_createperftable.sh 00_scale.sh 01_runSAS.sh 03_runBatch.sh 


## 2. Scale data sets:
The original data set megacorp5_1m is the basis.  It contains 1.2M records and is approx 500MB in size once in-memory.  This will be multiplicated by outputting its rows several times.

New datasets will be created in the target CAS lib, saved and dropped from memory at the end.  These will be reloaded just before starting the load tests on the specific data set.

To scale the data set, you will use 00_scale.sh to multiply the original data set.  For this you need 3 numbers:

    1. minimum record multiplicator for the original data set
    2. maximum record multiplicator for the original data set
    3. increments the script needs to take to go from 1/ to 2/

Example: if you have 128GB for CAS, and you want to start with 1GB as the smallest data set, then you need to multiply the original dataset (500MB) by 2.  You want to scale to 10GB, which means multiplying the original data set with 20.  In between the boundaries you want increments of 5.  You would then use:

./00_scale.sh 2 20 5

That would create 4 datasets: 2.4M records (1GB, 2xorig), 8.4M records (3.5GB, 7xorig), 14.4M records(6GB, 12xorig), 20.4M records (8.5GB, 17xorig)

   #### *Remark:*
   *!!!Don't exagerate with these parameters.  Without careful use, this will blow up the runtime of the scripts.  Advise would be to scale from roughly 1% of total CAS memory to max 10%.**


## 3. Running the perf test script:
### 3.1 Planning:
CAS processes try to consume all possible cpu resources.  So please plan the running of this script when the system is not used.  This to get clean data and to avoid harming user experience.

### 3.2 03_runBatch.sh
This script is the only thing you'll run, it pilots all others.  Underneath an explanation of what it iterates over.  For usage instructions, see RUN below.

### 3.3 Iterating
##### Data:
This script will iterate over the datasets you created above.  It actually iterates over the names of the datasets that were saved to datasets.txt.  You could adapt this file prior to a test run eg.  The script will load each data at the start of an iteration, run the all the scripts and drop the data at the end.

##### Analyses:
The script will use 3 bundles of SAS scripts:
  * simplequeries.sas: representing simple CAS actions from bar charts, heat maps, ...  Each CAS action in there adds complexity by adding 1,2,3,... calculated values
  * mediumqueries.sas: representing medium type actions, easy to use exploratory actions: correlation matrices, decision trees, linear regressions.
  * heavyqueries.sas: complex algorithms, neural networks and gradient boosting algorithms.

##### Concurrency:
The script will perform different runs, increasing the concurrent CAS sessions:
  * simplequeries: 1,5,10,15,20
  * mediumqueries: 1,2,4,6,8
  * heavyqueries: 1,2,3

These parameters can be adapted in the 03_RunBatch.sh script if necessary.
Concurrent CAS sessions should not be read as concurrent users.  If we would assume 10% server load concurrency from a set of concurrent users, we could imagine the number of concurrent users generating the load represented by the concurrent CAS sessions.


### 3.4 Run:
Only command to execute:

nohup ./03_runBatch.sh &


Optionally you can indicate how many runs of the total script will be run as well by providing a parameter to the script.  By default, if you don't provide anything, it'll do only 1 run.  Multiple runs will provide more data to calculate average run times.  But caution: 2 runs will take twice as long as 1 run, 3 runs will take...
For the first time, please don't provide a parameter (so you can see how long it will take for 1 run).
Multiple (2) runs will look like: nohup ./03_runBatch.sh 2 &


### 3.5 Monitoring while running:
* Logs for individual SAS sessions can be found in the log files created, eg:  simplequeries_gatedemo001.log  This is the log for simplequeries script, for user 1.

* checking errors: grep ERROR *.log would give the errors in the logs for every run.  There will be errors on perf_stats table not found.  But that should be the only ones.  This error is caused by several CAS sessions dropping this CAS perf table and loading it again.  But that doesn't matter, the core perf data is on a SAS dataset on the SAS server.  The latest process that uploads it, does the trick.

* SAS Server status: you can follow which and how many concurrent queries are being run on which data for what time through:
tail -f nohup.out

* CAS status: you can follow activity on the CAS servers using top or nmon.  Running nmon and then hitting c,m,d,t will show you cpu, memory and disk usage as well as the top processes


### 3.6 Performance report:
* import the report JSON (baseline performance.json) in Environment Manager.  It's a performance report on top of the generated data.
* data will be added while running, so you can refresh the data source while running.  Mind that interacting with the report will generate (limited) load on CAS and as such have a (very small) impact on the results.# test123
# test123
