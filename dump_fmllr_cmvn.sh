#!/bin/bash

data=/media/andi611/1TBSSD/kaldi/egs/librispeech/s5 ## You'll want to change this path to something that will work on your system.

rm -rf $data/fmllr_cmvn/
mkdir $data/fmllr_cmvn/

for part in dev_clean test_clean train_clean_100 train_clean_360; do
  mkdir $data/fmllr_cmvn/$part/
  apply-cmvn --utt2spk=ark:$data/fmllr/$part/utt2spk  ark:$data/fmllr/$part/data/cmvn_speaker.ark scp:$data/fmllr/$part/feats.scp ark:- | add-deltas --delta-order=0 ark:- ark:$data/fmllr_cmvn/$part/fmllr_cmvn.ark
done

du -sh $data/fmllr_cmvn/*
echo "Done!"