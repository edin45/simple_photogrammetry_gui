
from PIL import Image
import os, os.path
import optparse
import shutil

parser = optparse.OptionParser()
parser.add_option("-i","--image_folder",action="store",help="Imager folder")
parser.add_option("-r","--resolution_decrease",action="store",help="resolution decrease")
# parser.add_option("-o","--output_folder",action="store",help="Folder where Results are stored")
options, args = parser.parse_args()
image_folder = options.image_folder
resolution_decrease = options.resolution_decrease

# output_folder = options.output_folder

# image_list = [Image.open(item) for i in [glob.glob(f'{image_folder}/*.%s' % ext) for ext in ["jpg","tif","png","tiff", "jpeg"]] for item in i]
try:
    os.chdir(image_folder)
    os.mkdir("downres")
except:
  print("Folder exists") 

imgs = []
valid_images = [".jpg",".tif",".png",".tiff", ".jpeg", ".tga"]
for f in os.listdir(image_folder):
    ext = os.path.splitext(f)[1]
    if ext.lower() not in valid_images:
        continue
    imgs.append(f)

for image_filename in imgs:
    print(image_filename)
    image = Image.open(os.path.join(image_folder,image_filename))

    image_resized = image.resize((int(image.size[0]/float(resolution_decrease)), int(image.size[1]/float(resolution_decrease))))
    image_resized.save(os.path.join(os.path.join(image_folder,"downres"),image_filename))

cam_files = []
valid_cam_files = [".cam"]
for f in os.listdir(image_folder):
    ext = os.path.splitext(f)[1]
    if ext.lower() not in valid_cam_files:
        continue
    # cam_files.append(f)
    print(f)
    shutil.copy(os.path.join(image_folder,f), os.path.join(os.path.join(image_folder,"downres"),f))

# src_path = r"E:\demos\files\report\profit.txt"
# dst_path = r"E:\demos\files\account\profit.txt"

