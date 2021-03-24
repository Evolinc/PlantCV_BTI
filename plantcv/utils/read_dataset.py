import os
from plantcv.plantcv import fatal_error

def read_dataset(source_path):
    if not os.path.exists(source_path):
        raise IOError("Directory does not exist: {0}".format(source_path))


    img_path_list = []
    img_extensions = ['.png', '.jpg', '.jpeg', '.tif', '.tiff', '.gif']

    for root, dirs, files in os.walk(source_path):
        for file in files:
            # Check file type so that only images get selected
            name, ext = os.path.splitext(file)
            if ext.lower() in img_extensions:
                img_path_list.append(os.path.join(root,file))

    return img_path_list