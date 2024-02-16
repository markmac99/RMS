#!/bin/bash
# bash script to test GenerateMP4s

myself=$(readlink -f $0)
here="$( cd "$(dirname "$myself")" >/dev/null 2>&1 ; pwd -P )"
RMSDIR=$1
if [ "$RMSDIR" == "" ] ; then echo missing RMSDIR ; exit ; fi
DATA=$2/genmp4tests
if [ "$DATA" == "/genmp4tests" ] ; then  echo missing DATADIR ; exit ; fi
cd $RMSDIR

hn=$(hostname)
if [[ "$hn" == "testpi4" || "$hn" == "testpi5" ]] ; then
    echo running on $hn
    source ~/.bashrc
    source ~/vRMS/bin/activate
    pip install -r requirements.txt
    python setup.py install
elif [ "$hn" == "MARKSDT" ] ; then 
    echo running on $hn
    source ~/.bashrc
    conda activate $HOME/miniconda3/envs/RMS
    cd $RMSDIR
    pip install -r requirements.txt
else
    echo running on docker or ubuntu
fi
mkdir -p $DATA/results
rm $DATA/results/FR*.mp4
python -m Utils.GenerateMP4s $DATA/ 
ls -1 $DATA/FF*.mp4 | while read i ; do
    mv -f $i $DATA/results/$(basename $i)-nofilter.mp4
done

rm $DATA/FF*.mp4
python -m Utils.GenerateMP4s $DATA/ -s URS
ls -1 $DATA/FF*.mp4 | while read i ; do
    mv -f $i $DATA/results/$(basename $i)-shwrfilter.mp4
done

python -m Utils.GenerateMP4s $DATA/ -m 0
ls -1 $DATA/FF*.mp4 | while read i ; do
    mv -f $i $DATA/results/$(basename $i)-magfilter.mp4
done

python -m Utils.GenerateMP4s $DATA/ -s URS -m 1
ls -1 $DATA/FF*.mp4 | while read i ; do
    mv -f $i $DATA/results/$(basename $i)-magandshowerfilter.mp4
done
