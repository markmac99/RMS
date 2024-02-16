#!/bin/bash

myself=$(readlink -f $0)
here="$( cd "$(dirname "$myself")" >/dev/null 2>&1 ; pwd -P )"

RMSDIR=$1
if [ "$RMSDIR" == "" ] ; then echo missing RMSDIR ; exit ; fi
DATA=$2/frbintests
if [ "$DATA" == "/frbintests" ] ; then  echo missing DATADIR ; exit ; fi
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
python -m Utils.FRbinViewer $DATA/ -x -f mp4 
# basic video production
ls -1 $DATA/FR*.mp4 | while read i ; do
    mv -f $i $DATA/results/$(basename $i)-noextras.mp4
done
# with a config file but no other options - should be the same as basic
python -m Utils.FRbinViewer $DATA/ -x -f mp4 -c $DATA/.config
ls -1 $DATA/FR*.mp4 | while read i ; do
    mv -f $i $DATA/results/$(basename $i)-withcfg.mp4
done
# add shower name to the video but not the still
python -m Utils.FRbinViewer $DATA/ -x -f mp4 -w -c $DATA/.config
ls -1 $DATA/FR*.mp4 | while read i ; do
    mv -f $i $DATA/results/$(basename $i)-shwronly.mp4
done
# add still  to the video but not the shower name
python -m Utils.FRbinViewer $DATA/ -x -f mp4 -m -c $DATA/.config
ls -1 $DATA/FR*.mp4 | while read i ; do
    mv -f $i $DATA/results/$(basename $i)-ffonly.mp4
done
# add timestamp to the video but not the shower name
python -m Utils.FRbinViewer $DATA/ -x -f mp4 -t -c $DATA/.config
ls -1 $DATA/FR*.mp4 | while read i ; do
    mv -f $i $DATA/results/$(basename $i)-tsonly.mp4
done
# add everything
python -m Utils.FRbinViewer $DATA/ -x -f mp4 -w -c $DATA/.config -m -t
ls -1 $DATA/FR*.mp4 | while read i ; do
    mv -f $i $DATA/results/$(basename $i)-shwr_all.mp4
done
# add everything but accidentally forget the config file - should fail to add showerid
python -m Utils.FRbinViewer $DATA/ -x -f mp4 -w -m -t
ls -1 $DATA/FR*.mp4 | while read i ; do
    mv -f $i $DATA/results/$(basename $i)-shwr_ff_ts_nocfg.mp4
done
