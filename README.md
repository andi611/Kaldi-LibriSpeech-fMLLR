# Kaldi-LibriSpeech
This repository contains Kaldi recipes on the LibriSpeech corpora to execute the fMLLR feature extraction process.
Once [Kaldi](http://kaldi-asr.org/doc/install.html) is installed, replace the files under `$KALDI_ROOT/egs/librispeech/s5/` with the files in the repository (especially [`run.sh`](run.sh) and [`cmd.sh`](cmd.sh)).

These code and procedures are also publised on the [fMLLR wiki page](https://en.wikipedia.org/wiki/FMLLR). Feel free to use or modify them, any bug report or improvement suggestion will be appreciated. If you have any questions, please contact r07942089@ntu.edu.tw.

## Prerequisite
### Setup Kaldi
- Install [Kaldi](http://kaldi-asr.org/doc/install.html)
- As suggested during the installation, do not forget to add the path of the Kaldi binaries into $HOME/.bashrc. For instance, make sure that .bashrc contains the following paths:
```.bashrc
export KALDI_ROOT=/home/mirco/kaldi
PATH=$PATH:$KALDI_ROOT/tools/openfst
PATH=$PATH:$KALDI_ROOT/src/featbin
PATH=$PATH:$KALDI_ROOT/src/gmmbin
PATH=$PATH:$KALDI_ROOT/src/bin
PATH=$PATH:$KALDI_ROOT/src/nnetbin
export PATH
```
- Remember to change the **KALDI_ROOT** variable using your path. As a first test to check the installation, open a bash shell, type `copy-feats` or `hmm-info` and make sure no errors appear.

### Setup Kaldiio
- This is for converting kaldi .ark files to our data format.
- Install [Kaldiio](https://github.com/nttcslab-sp/kaldiio)
- Use the following command to install:
```bash
pip3 install kaldiio
```

## Preprocessing LibriSpeech
Below are the basic steps to extract fMLLR features from the open source speech corpora Librispeech, note that the instructions below are for the subsets `train-clean-100`,`train-clean-360`, `dev-clean`, and `test-clean`, but they can be easily extended to support the other sets `dev-other`, `test-other`, and `train-other-500`.

1. If running on a single machine, change the following lines in `$KALDI_ROOT/egs/librispeech/s5/cmd.sh` and replace `queue.pl` to `run.pl`.
    - Change the lines to:
```
export train_cmd="run.pl --mem 2G"
export decode_cmd="run.pl --mem 4G"
export mkgraph_cmd="run.pl --mem 8G"
```

2. Change the `data` path in `run.sh` to your LibriSpeech data path, the directory `LibriSpeech/` should be under that path. For example:
```bash
data=/media/andi611/1TBSSD
```

3. Run the Kaldi recipe `run.sh` for LibriSpeech at least until Stage 13 (included), make sure that `flac` is installed if you are using a Linux machine:
```
./run.sh # Use the `run.sh` from this repo
sudo apt-get install flac
```
4. Copy `exp/tri4b/trans.*` files into `exp/tri4b/decode_tgsmall_train_clean_*/`
```
mkdir exp/tri4b/decode_tgsmall_train_clean_100 && cp exp/tri4b/trans.* exp/tri4b/decode_tgsmall_train_clean_100/
```
5. Compute the fmllr features by running the following script.
```bash
./compute_fmllr.sh
```

6. Compute alignments using:
```bash
# aligments on dev_clean and test_clean
steps/align_fmllr.sh --nj 10 data/dev_clean data/lang exp/tri4b exp/tri4b_ali_dev_clean
steps/align_fmllr.sh --nj 10 data/test_clean data/lang exp/tri4b exp/tri4b_ali_test_clean
steps/align_fmllr.sh --nj 30 data/train_clean_100 data/lang exp/tri4b exp/tri4b_ali_clean_100
steps/align_fmllr.sh --nj 30 data/train_clean_360 data/lang exp/tri4b exp/tri4b_ali_clean_360
```
7. Apply cmvn and dump the fmllr features to new .ark files:
```bash
./dump_fmllr_cmvn.sh
```
8. Use the python script to convert kaldi generated .ark featrues to .npy for your own dataloader, an example python script is provided:
```bash
python3 ark2libri.py
```