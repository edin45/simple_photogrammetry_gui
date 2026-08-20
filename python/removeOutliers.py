import optparse
import open3d as o3d

parser = optparse.OptionParser()
parser.add_option("-i","--input_pointcloud",action="store",help="Input Pointcloud")
parser.add_option("-o","--output_folder",action="store",help="Folder where Results are stored")
options, args = parser.parse_args()
input_pointcloud = options.input_pointcloud
output_folder = options.output_folder


pcd = o3d.io.read_point_cloud(input_pointcloud)
	
cl, ind = pcd.remove_statistical_outlier(nb_neighbors=20, std_ratio=2.0)


o3d.io.write_point_cloud(output_folder + "\\outliers_removed.ply", cl, write_ascii=False)