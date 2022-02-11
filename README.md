# Tesseract Trainer

A containerised version of the tools required to train/fine tune Tesseract
for a new font.

Based on: https://www.youtube.com/watch?v=TpD76k2HYms

## How to use

1. Clone this repo (`git clone https://github.com/artdevgame/tesseract-trainer.git`)
2. Copy your selected font into the `src/fonts` directory
3. Configure [docker-compose.yml](./docker-compose.yml) with your preferences ([see below](#Configuration))
4. Download and install Docker for your OS (https://www.docker.com/products/docker-desktop)
5. From the project root directory, run `docker-compose up`
6. After the process has finished, you will have a `final.traineddata` in the `src/output` directory. Use this in your Tesseract project

## Configuration

Change the following environment values in [docker-compose.yml](./docker-compose.yml):

| Property | Example | Description |
| --- | --- | --- |
| TESSTRAIN_FONT | Agency FB Condensed | The *name* of the font (not the filename) |
| TESSTRAIN_LANG | eng | The language of the training data |
| TESSTRAIN_MAX_PAGES | 10 | Training text size |
| TESSTRAIN_MAX_ITERATIONS | 400 | Number of iterations for the neural network, more will give a better result but may also lead to overfitting (bad) |
