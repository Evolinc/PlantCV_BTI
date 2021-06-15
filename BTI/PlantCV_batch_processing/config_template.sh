#!/bin/bash

#directory related to argument
pipe_dir="/home/liangyu/1_Project/2_PlantCV/2_scripts"

echo"**********The following scripts are required under the pipeline directory !***************" under the pipe_dir directory: 
echo"1.multi_plant.py"
echo"2.multi_plant.json"
echo"3.s1_Image_distribution.sh"
echo"4.s2_multiple_batch.sh"
echo"5.s3_Rig_process.R"

raw_dir="/home/liangyu/0_data/3_Raspi"
parameter_code_dir="/home/liangyu/1_Project/2_PlantCV/5_Project/2_LncRNA_20201030/parameter_code"
master_input_dir="/home/liangyu/1_Project/2_PlantCV/5_Project/2_LncRNA_20201030"
master_json_dir="/home/liangyu/1_Project/2_PlantCV/5_Project/2_LncRNA_20201030/Results"
master_output_dir="/home/liangyu/1_Project/2_PlantCV/5_Project/2_LncRNA_20201030/Results"

# STEP 1 allocate all images to certian directory
bash $pipe_dir/s1_image_distribution_previous_stamp.sh -l $master_input_dir/photo_list -r $raw_dir -p $master_input_dir -t $master_input_dir/date_list

#STEP 2 perform batch processing for each selected images
bash $pipe_dir/s2_multiple_batch.sh -p $pipe_dir -c $parameter_code_dir -i $master_input_dir -j $master_json_dir -o $master_output_dir -s $master_input_dir/LncRNA_20201030_meta.csv

#STEP 3 perform time stamp transformation for each camera
ls $master_json_dir/*.clean.csv | grep -v "sample.list" > $master_json_dir/sample.list

for i in $(cat $master_json_dir/sample.list);do
	Rscript $pipe_dir/s3_Rig_process.R --input $master_json_dir/${i} --output $master_json_dir/${i}
done

