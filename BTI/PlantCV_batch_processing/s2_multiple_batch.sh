#!/bin/bash
# Script to process bacth image data by plantcv

usage() {
      echo ""
      echo "Usage : sh $0 -p pipeline -c parameter_code -i master_input -j master_json -o master_output -s meta_table"
      echo ""

cat <<'EOF'

  -p </path/to/pipelines been stored> 

  -c </path/to/parameter code for each set of plants>

  -i </path/to/master directory for iuput images>

  -j </path/to/master directory for output json result>

  -o </path/to/master directory for output images>

  -s </path/to/meta table for batch process>

  -h Show this usage information

EOF
    exit 0
}

while getopts ":p:c:i:j:o:s:h:" opt; do
  case $opt in
    p)
     pipe_dir=$OPTARG
      ;;
    c)
     parameter_code_dir=$OPTARG
      ;;
    i)
     master_input_dir=$OPTARG
      ;;
    j)
     master_json_dir=$OPTARG 
      ;;  
    o)
     master_output_dir=$OPTARG 
      ;;
    s)
     meta_table=$OPTARG 
      ;;  
    h)
     usage
     exit 1
      ;;      
    \?)
     echo "Invalid option: -$OPTARG" >&2
     exit 1
      ;;
    :)
     echo "Option -$OPTARG requires an argument." >&2
     exit 1
      ;;
  esac
done

echo "BEGIN!"
echo `date`

START_TIME=$SECONDS

IFS=$'\n';
for LINE in $(cat $meta_table | grep -v 'indir');do

    START_TIME_1=$SECONDS
    echo "****************************************************************************************"
    echo "******************STEP 1 Loading parameters for image processing......******************"

    #READ DIRECTORIES
    indir=$(echo ${LINE} | awk '{ print $1}')
    outdir=$(echo ${LINE} | awk '{ print $2 }')
    json_output=$(echo ${LINE} | awk '{ print $3 }')
    
    #READ PARAMETER
    white_X=$(echo ${LINE} | awk '{ print $4 }')
    white_Y=$(echo ${LINE} | awk '{ print $5 }')
    deg=$(echo ${LINE} | awk '{ print $6 }')
    shift1_size=$(echo ${LINE} | awk '{ print $7 }')
    shift1_dir=$(echo ${LINE} | awk '{ print $8 }')
    shift2_size=$(echo ${LINE} | awk '{ print $9 }')
    shift2_dir=$(echo ${LINE} | awk '{ print $10 }')
    threshold=$(echo ${LINE} | awk '{ print $11 }')
    ROIx=$(echo ${LINE} | awk '{ print $12 }')
    ROIy=$(echo ${LINE} | awk '{ print $13 }')
    plantx=$(echo ${LINE} | awk '{ print $14 }')
    planty=$(echo ${LINE} | awk '{ print $15 }')
    radius=$(echo ${LINE} | awk '{ print $16 }')

    #ASSIGN PARAMETERS
    rotations="rotation_deg=$deg"
    shift1="img=img1, number=$shift1_size, side='$shift1_dir'"
    shift2="img=imgs, number=$shift2_size, side='$shift2_dir'"
    ROI="x=$ROIx, y=$ROIy,"


    # ASSIGN DIRECTORY
    image_input="$master_input_dir/${indir}"
    output_json="$master_json_dir/${indir}.json"
    output_csv="$master_json_dir/${indir}"
    image_output="$master_output_dir/${outdir}"
    workflow="$parameter_code_dir/${indir}.py"

    echo
    #ECHO ALL PARAMETERS FOR CHECK
    echo "white balance spot is: x=$white_X y=$white_Y"
    echo "rotation degree is: $rotations" 
    echo "threshold for masking is: $threshold"
    echo "shift (left) right is: $shift1"
    echo "shift (bottumn) top is: $shift2"
    echo "region of interests is: $ROI"
    echo "coordinate of the plant0 is: $plantx $planty"
    
    echo
    echo "***Input Image folder is: $image_input***"
    echo "***Image out json file is: $output_json***"
    echo "***Output image folder is: $image_output***"
    echo "***workflow is: $workflow***"

    echo "Parameters loaded"
    ELAPSED_TIME_1=$(($SECONDS - $START_TIME_1))
    echo "Elapsed time for STEP 1 is" $ELAPSED_TIME_1 "seconds"

    echo
    START_TIME_2=$SECONDS
    echo "***********************************************************************************************************************"
    echo "******************STEP 2 Generating python scripts and json configuration file for certain rigs......******************"
    #replace python scripts
    sed "s/xcoord1/$white_X/g" $pipe_dir/multi_plant.py |sed "s/ycoord1/$white_Y/g" | sed "s/cut_off/$threshold/g" | sed "s/rotation_deg=/$rotations/g" | sed "s/img=img1, number=shift1, side=dir1/$shift1/g" | sed "s/img=imgs, number=shift2, side=dir2/$shift2/g" | sed "s/x=xcoord2, y=ycoord2,/$ROI/g" | sed "s/xcoord3/$plantx/g" | sed "s/ycoord3/$planty/g" | sed "s/VALUE/$radius/g" > $parameter_code_dir/${indir}.py

    #repalce json scripts
    sed "s@INPUT@$image_input@g" $pipe_dir/multi_plant.json | sed "s@JSON@$output_json@g" | sed "s@WORKFLOW@$workflow@g" | sed "s@OUTDIR@$image_output@g" > $parameter_code_dir/${indir}.json
    echo
    echo "Configuration completed"
    ELAPSED_TIME_2=$(($SECONDS - $START_TIME_2))
    echo "Elapsed time for STEP 2 is" $ELAPSED_TIME_2 "seconds"

    echo
    START_TIME_3=$SECONDS
    echo "**********************************************************************************"
    echo "******************STEP 3 Excuting plantCV batch processing......******************"
    python $pipe_dir/plantcv-workflow.py --config $parameter_code_dir/${indir}.json
    echo
    echo "Batch processing completed"
    ELAPSED_TIME_3=$(($SECONDS - $START_TIME_3))
    echo "Elapsed time for STEP 3 is" $ELAPSED_TIME_3 "seconds"
    
    echo
    START_TIME_4=$SECONDS
    echo "*****************************************************************************************"
    echo "******************STEP 4 Transforming json format into csv format......******************"
    python $pipe_dir/plantcv-utils.py json2csv --json ${output_json} --csv ${output_csv}
    echo
    echo "json to csv transformation completed"
    ELAPSED_TIME_4=$(($SECONDS - $START_TIME_4))
    echo "Elapsed time for STEP 4 is" $ELAPSED_TIME_4 "seconds"

    echo
    START_TIME_5=$SECONDS
    echo "***************************************************************"
    echo "******************STEP 4 Clean csv file......******************"
    cat ${output_csv}-single-value-traits.csv | grep -v 'none' | cut -d ',' -f 30,16,17,18,19,20,21,22,23,24,25,26,27,28,29 > ${output_csv}.clean.csv

    ELAPSED_TIME_5=$(($SECONDS - $START_TIME_5))
    echo "Elapsed time for step 5 is" $ELAPSED_TIME_5 "seconds"
done

echo "Finished the PlantCV multi-plant pipeline!"
echo `date`

rm $master_json_dir/*multi-value-traits.csv
