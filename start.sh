cd /app/src

# data used for lstm model training
LSTM_REPO="langdata_lstm"
LSTM_REMOTE="https://github.com/tesseract-ocr/$LSTM_REPO.git"
LSTM_LOCAL="$LSTM_REPO/.git"
[ -d $LSTM_LOCAL ] || git clone $LSTM_REMOTE
echo "Fetching updates from the ${LSTM_REPO} repo (be patient, you'll see a message when done)"
(cd $LSTM_REPO; git pull $LSTM_REMOTE)
echo "Fetch complete"

# cleanup previous training data and output
rm -rf /app/src/train /app/src/output
mkdir -p /app/src/train /app/src/output

# generate new training data
tesstrain.sh \
 --fonts_dir /app/src/fonts \
 --fontlist "$TESSTRAIN_FONT" \
 --lang $TESSTRAIN_LANG \
 --linedata_only \
 --langdata_dir /app/src/langdata_lstm \
 --tessdata_dir $TESSDATA_PREFIX \
 --save_box_tiff \
 --maxpages $TESSTRAIN_MAX_PAGES \
 --output_dir /app/src/train

# extract the generated model
combine_tessdata -e $TESSDATA_PREFIX/$TESSTRAIN_LANG.traineddata /app/src/train/$TESSTRAIN_LANG.lstm

# test accuracy of model
lstmeval \
 --model /app/src/train/$TESSTRAIN_LANG.lstm \
 --traineddata $TESSDATA_PREFIX/$TESSTRAIN_LANG.traineddata \
 --eval_listfile /app/src/train/$TESSTRAIN_LANG.training_files.txt

# fine tune
OMP_THREAD_LIMIT=8 lstmtraining \
 --continue_from /app/src/train/$TESSTRAIN_LANG.lstm \
 --model_output /app/src/output/ \
 --traineddata $TESSDATA_PREFIX/$TESSTRAIN_LANG.traineddata \
 --train_listfile /app/src/train/$TESSTRAIN_LANG.training_files.txt \
 --max_iterations $TESSTRAIN_MAX_ITERATIONS

# combine fine tuned model with the original trained model
lstmtraining \
 --stop_training \
 --continue_from /app/src/output/_checkpoint \
 --traineddata $TESSDATA_PREFIX/$TESSTRAIN_LANG.traineddata \
 --model_output /app/src/output/final.traineddata

# test accuracy of new model
lstmeval \
 --model /app/src/output/_checkpoint \
 --traineddata $TESSDATA_PREFIX/$TESSTRAIN_LANG.traineddata \
 --eval_listfile /app/src/train/$TESSTRAIN_LANG.training_files.txt
