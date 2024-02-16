#!/bin/bash
# bash script to test GenerateMP4s

myself=$(readlink -f $0)
here="$( cd "$(dirname "$myself")" >/dev/null 2>&1 ; pwd -P )"
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
    CFG=$here/genmp4tests/.config
else
    echo not supported
    exit 1
fi
mkdir -p $here/genmp4tests/results
rm $here/genmp4tests/results/FR*.mp4

python -m Utils.GenerateMP4s $here/genmp4tests/ 
ls -1 $here/genmp4tests/FR*.mp4 | while read i ; do
    mv -f $i $here/genmp4tests/results/$(basename $i)-nofilter.mp4
done

rm $here/genmp4tests/FF*.mp4
python -m Utils.GenerateMP4s $here/genmp4tests/ -s DSV
ls -1 $here/genmp4tests/FR*.mp4 | while read i ; do
    mv -f $i $here/genmp4tests/results/$(basename $i)-shwrfilter.mp4
done

python -m Utils.GenerateMP4s $here/genmp4tests/ -m -1
ls -1 $here/genmp4tests/FR*.mp4 | while read i ; do
    mv -f $i $here/genmp4tests/results/$(basename $i)-magfilter.mp4
done

python -m Utils.GenerateMP4s $here/genmp4tests/ -s DSV -m 0.5
ls -1 $here/genmp4tests/FR*.mp4 | while read i ; do
    mv -f $i $here/genmp4tests/results/$(basename $i)-magandshowerfilter.mp4
done
