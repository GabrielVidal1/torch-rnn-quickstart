#!/bin/bash

[ $# -eq 0 ] && echo 'Usage: ./run_docker.sh <data.txt> [train, sample]' && exit 1

file="$1"

if [ ! -f "$file" ]; then
echo "$file: file not found"
exit 2
fi

CONT_NAME=torch


[ "$(docker ps | grep $CONT_NAME)" ] && docker kill $CONT_NAME
[ "$(docker ps -a | grep $CONT_NAME)" ] && docker container rm $CONT_NAME


filename="$(basename $file)"


dir="${file%%.*}"
[ ! -d "$dir" ] && mkdir $dir
cp $file $dir/$filename

file=${filename%%.*}

[ ! -f $dir/$file.h5 ] && docker container run --name $CONT_NAME -i -t -v "$(pwd)/$dir:/data" crisbal/torch-rnn:base /bin/bash -c "
        python scripts/preprocess.py \
        --input_txt /data/$filename \
        --output_h5 /data/$file.h5 \
        --output_json /data/$file.json
        "

if [ ! -f $dir/training.conf -o ! -f $dir/sampling.conf ]; then
    echo 'conf created'
    echo "-checkpoint_every 100" > $dir/training.conf
    echo "-length 2000" > $dir/sampling.conf
    [ ! -d $dir/checkpoints ] && mkdir $dir/checkpoints
fi


if [ "$2" == "train" ]; then

    init="$(ls $dir/checkpoints/ | grep .t7 | tail -1)"
    vfile="$(basename $(ls $dir/checkpoints/ | grep .t7 | tail -1))"

    CONT_NAME=$CONT_NAME-train

    echo training from $init
    [ "$(docker ps | grep $CONT_NAME)" ] && docker kill $CONT_NAME
    [ "$(docker ps -a | grep $CONT_NAME)" ] && docker container rm $CONT_NAME
    docker container run --name $CONT_NAME -i -t -v "$(pwd)/$dir:/data" crisbal/torch-rnn:base /bin/bash -c "
    th train.lua \
    -gpu -1 \
    -input_h5 /data/${filename%%.*}.h5 \
    -input_json /data/${filename%%.*}.json \
    -checkpoint_name /data/checkpoints/cv \
    -reset_iterations 0 \
    $([ $vfile ] && echo "-init_from /data/checkpoints/$vfile" ) \
    $(cat $dir/training.conf)
    "
    exit 0
fi


if [ "$2" == "sample" ]; then

    init="$(ls $dir/checkpoints/ | grep .t7 | tail -1)"
    vfile="$(basename $(ls $dir/checkpoints/ | grep .t7 | tail -1))"

    CONT_NAME=$CONT_NAME-sample

    echo sampling from $init
    [ "$(docker ps | grep $CONT_NAME)" ] && docker kill $CONT_NAME
    [ "$(docker ps -a | grep $CONT_NAME)" ] && docker container rm $CONT_NAME
    docker container run --name $CONT_NAME -i -t -v "$(pwd)/$dir:/data" crisbal/torch-rnn:base /bin/bash -c "
    th sample.lua -checkpoint /data/checkpoints/$vfile \
    -gpu -1 \
    -verbose 1 \
    $(cat $dir/sampling.conf)
    "
    exit 0
fi
