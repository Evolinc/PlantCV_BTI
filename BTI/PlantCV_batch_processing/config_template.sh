#!/bin/bash

#specify each directory for each argument required
pipe_dir="directory/to/pipelines" 
# under the directory: multi.py, s2_multiple_batcg.sh, and json file should be stored

raw_dir="directory/to/raspi_images/been/collected"

#specify directory for all arguments

parameter_code_dir="directory/to/parameter_code"
master_input_dir="directory/to/input_images"
master_json_dir="directory/to/json_outputs"
master_output_dir="directory/to/image(png)_outputs"

#allocate all images to certian directory
bash $pipe_dir/s1_image_distribution_previous_stamp.sh -l $master_input_dir/photo_list -r $raw_dir -p $master_input_dir -t $master_input_dir/date_list

#perform batch processing for each selected images
bash $pipe_dir/s2_multiple_batch.sh -p $pipe_dir -c $parameter_code_dir -i $master_input_dir -j $master_json_dir -o $master_output_dir -s $master_input_dir/meta.csv
