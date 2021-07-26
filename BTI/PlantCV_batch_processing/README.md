PlantCV batch processing for Arabidopsis plants is designed to distribute and process batch images which are taken by raspi camera from above view, and then transformed in a certain output format for further analysis in R program.  
PlantCV batch processing requires the following:
1.	PlantCV environment 
2.	RGB images that are being analyzed (can be JPG, png, and other formats based on plantCV requirements)
3.	Meta-table that includes PlantCV parameters for images (See example file)
4.	Photo_list: txt file with name of folder that includes all jpg images
5.	Date_list: txt file with dates (month, day) of images needed to be processed based on image timeseries
The certain purpose of each step was described below:
s1_image_distribution.sh distributes images into specific folders to separate images based on camera and time stamp.
s2_multiple_batch.sh process batch images using PlantCV to assign parameters and directories images and save phenotypic data in a csv table and a json file. 
s3_Rig_process.sh splits time series information in csv files based on plant ID and month-day-hour-min and transform all timestamps into, total hours and total minutes. 
Config_template.sh runs all scripts above with needed inputs and directory information.
