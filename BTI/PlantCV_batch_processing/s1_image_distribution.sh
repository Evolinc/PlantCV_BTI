#!/bin/bash

usage() {
      echo ""
      echo "Usage : sh $0 -l photolist -r raw_dir -p photo_dir -t date_list"
      echo ""

cat <<'EOF'

  -l </path/to/photo list file>

  -r </path/to/photos previously been stored>

  -p </path/to/photos will be stored> 

  -t </path/to/date list for certain batch>

  -h Show this usage information

EOF
    exit 0
}


while getopts ":l:r:p:t:h:" opt; do
  case $opt in
    l)
     photo_list=$OPTARG
      ;;
    r)
     raw_dir=$OPTARG
      ;;
    p)
     photo_dir=$OPTARG
      ;;
    t)
     date_list=$OPTARG 
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


for i in $(cat $photo_list | cut -d "_" -f1)
do
	#make folders for each image factory
	mkdir ${photo_dir}/$i
	cd ${photo_dir}/$i
	
	mkdir ${photo_dir}/$i/cameraA
	mkdir ${photo_dir}/$i/cameraB

	for camera in cameraA cameraB;
	do 
		#Move photos to A and B
		cd ${photo_dir}/${i}/$camera
		ln -s ${raw_dir}/${i}_image_factory/*raspi?_$camera* ./

		echo "Cleaning dark images of $camera under the $i......"
		#clean the dark photos from each camera
		for sample in 0000 0030 0100 0130 0200 0230 0300 0330 0400 0430 0500 0530 0600 0630 0700 0730 2200 2230 2300 2330;
		do
			sample_full=raspi?_camera?_????$sample??.jpg
			rm ${photo_dir}/${i}/${camera}/*${sample_full} 
		done


		echo "Assigning images from certain dates to $camera under the $i........"
		#Organize photos from differnet batches under each camera
		#Create two new folders for all images for analysis and sample images for parameter settings
		mkdir ${photo_dir}/${i}_${camera}
		mkdir ${photo_dir}/${i}_${camera}_sample

        cd ${photo_dir}/${i}/$camera 
		#Modify different batch names for images
		for date in $(cat $date_list)
		do
			#$date format eg: 20211003
			date_full=raspi?_camera?_$date??????.jpg
			test_full=raspi?_camera?_${date}1200??.jpg

			#assign all images to raspi and camera
			ln -s ${photo_dir}/${i}/${camera}/$date_full ${photo_dir}/${i}_${camera}
            #assign one sample image to raspi and camera
			ln -s ${photo_dir}/${i}/${camera}/$test_full ${photo_dir}/${i}_${camera}_sample
		done	
	done
done

