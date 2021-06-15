#!/bin/bash

#directory related to argument
pipe_dir="/directory/to/pipelines"

echo"**********The following scripts are required under the pipeline directory !***************" under the pipe_dir directory: 
echo"1.multi_plant.py"
echo"2.multi_plant.json"
echo"3.s1_Image_distribution.sh"
echo"4.s2_multiple_batch.sh"
echo"5.s3_Rig_process.R"

parameter_code_dir="/directory/to/configuration file and python code"
raw_dir="/directory/to/images"

master_input_dir="/directory/to/images to be reorganized"
master_json_dir="/directory/to/save output images"
master_output_dir="/directory/to/save output json results"

# STEP 1 allocate all images to certian directory
bash $pipe_dir/s1_image_distribution_previous_stamp.sh -l $master_input_dir/photo_list -r $raw_dir -p $master_input_dir -t $master_input_dir/date_list

#STEP 2 perform batch processing for each selected images
bash $pipe_dir/s2_multiple_batch.sh -p $pipe_dir -c $parameter_code_dir -i $master_input_dir -j $master_json_dir -o $master_output_dir -s $master_input_dir/LncRNA_20201030_meta.csv

#STEP 3 perform time stamp transformation for each camera
ls $master_json_dir/*.clean.csv | grep -v "sample.list" > $master_json_dir/sample.list

for i in $(cat $master_json_dir/sample.list);do
	Rscript $pipe_dir/s3_Rig_process.R --input $master_json_dir/${i} --output $master_json_dir/${i}
done

