import pycolmap
import optparse
import os

parser = optparse.OptionParser()
parser.add_option("-p","--project_dir",action="store",help="Colmap Project Dir")
parser.add_option("-i","--image_dir",action="store",help="Image Directory")
parser.add_option("-d","--database_path",action="store",help="Database Path")
parser.add_option("-s","--sparse_dir",action="store",help="Sparse Path")
parser.add_option("-o","--dense_dir",action="store",help="Dense Path")

options, args = parser.parse_args()
image_dir = options.image_dir
project_dir = options.project_dir
database_path = options.database_path
sparse_dir = options.sparse_dir
dense_dir = options.dense_dir

# Define paths
# project_dir = "path/to/your/project_directory"
# image_dir = f"{project_dir}/images"
# database_path = f"{project_dir}/database.db"
# sparse_dir = f"{project_dir}/sparse"

image_reader_options = pycolmap.SiftExtractionOptions(
    max_image_size=1000,
    darkness_adaptivity=True
)


# Step 1: Extract features
pycolmap.extract_features(database_path, image_dir,sift_options=image_reader_options)

# Step 2: Match features using exhaustive matcher
pycolmap.match_exhaustive(database_path)


pycolmap.incremental_mapping(database_path, image_dir, sparse_dir)

pycolmap.undistort_images(dense_dir, os.path.join(sparse_dir, "0"), image_dir)
