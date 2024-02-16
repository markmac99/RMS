#!/bin/bash

here="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
hn=$(hostname)
if [[ "$hn" == "testpi4" || "$hn" == "testpi5" ]] ; then
    RMSDIR=/home/pi/source/RMS
    source ~/.bashrc
    source ~/vRMS/bin/activate
    cd $RMSDIR
    pip install -r requirements.txt
    python setup.py install
    CFG=$RMSDIR/.config
elif [ "$hn" == "MARKSDT" ] ; then 
    RMSDIR=/mnt/e/dev/meteorhunting/RMS
    source ~/.bashrc
    conda activate $HOME/miniconda3/envs/RMS
    cd $RMSDIR
    pip install -r requirements.txt
    CFG=$here/frbintests/.config
else
    echo not supported
    exit 1
fi
mkdir -p $here/frbintests/results
rm $here/frbintests/results/FR*.mp4
python -m Utils.FRbinViewer $here/frbintests/ -x -f mp4 
# basic video production
ls -1 $here/frbintests/FR*.mp4 | while read i ; do
    mv -f $i $here/frbintests/results/$(basename $i)-noextras.mp4
done
# with a config file but no other options - should be the same as basic
python -m Utils.FRbinViewer $here/frbintests/ -x -f mp4 -c $CFG
ls -1 $here/frbintests/FR*.mp4 | while read i ; do
    mv -f $i $here/frbintests/results/$(basename $i)-withcfg.mp4
done
# add shower name to the video but not the still
python -m Utils.FRbinViewer $here/frbintests/ -x -f mp4 -w -c $CFG
ls -1 $here/frbintests/FR*.mp4 | while read i ; do
    mv -f $i $here/frbintests/results/$(basename $i)-shwronly.mp4
done
# add still  to the video but not the shower name
python -m Utils.FRbinViewer $here/frbintests/ -x -f mp4 -m -c $CFG
ls -1 $here/frbintests/FR*.mp4 | while read i ; do
    mv -f $i $here/frbintests/results/$(basename $i)-ffonly.mp4
done
# add timestamp to the video but not the shower name
python -m Utils.FRbinViewer $here/frbintests/ -x -f mp4 -t -c $CFG
ls -1 $here/frbintests/FR*.mp4 | while read i ; do
    mv -f $i $here/frbintests/results/$(basename $i)-tsonly.mp4
done
# add everything
python -m Utils.FRbinViewer $here/frbintests/ -x -f mp4 -w -c $CFG -m -t
ls -1 $here/frbintests/FR*.mp4 | while read i ; do
    mv -f $i $here/frbintests/results/$(basename $i)-shwr_all.mp4
done
# add everything but accidentally forget the config file - should fail to add showerid
python -m Utils.FRbinViewer $here/frbintests/ -x -f mp4 -w -m -t
ls -1 $here/frbintests/FR*.mp4 | while read i ; do
    mv -f $i $here/frbintests/results/$(basename $i)-shwr_ff_ts_nocfg.mp4
done
