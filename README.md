## Torch-rnn quickstart

built on the [torch-rnn](https://github.com/jcjohnson/torch-rnn) docker container.

## Requirements

* [Docker](https://www.docker.com/)

## How to use

```
./torch-rnn-quickstart.sh <data.txt> [train, sample]
```

* `data.txt` is the textyou want to feed the neural net for training

### Training

```
./torch-rnn-quickstart.sh <data.txt> train
```

training parameters can be changes from the file `training.conf` generated in the corresponding folder (same path and name than the `<data.txt>`)

By default, the checkpoint with the most iterations will be used to continue training from.

### Sampling

```
./torch-rnn-quickstart.sh <data.txt> sample
```

training parameters can be changes from the file `sampling.conf` generated in the corresponding folder (same path and name than the `<data.txt>`)

By default, the checkpoint with the most iterations will be used for sampling.