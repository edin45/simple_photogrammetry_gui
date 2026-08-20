import optparse
import open3d as o3d

parser = optparse.OptionParser()
parser.add_option("-i","--input_pointcloud",action="store",help="Input Pointcloud")
parser.add_option("-o","--output_folder",action="store",help="Folder where Results are stored")
options, args = parser.parse_args()
input_pointcloud = options.input_pointcloud
output_folder = options.output_folder


pcd = o3d.io.read_point_cloud(input_pointcloud)
	
cl, ind = pcd.remove_statistical_outlier(nb_neighbors=20, std_ratio=0.5)
#cl, ind = pcd.remove_radius_outlier(nb_points=16, radius=0.05)

print("filtering...")

inlier_cloud = pcd.select_by_index(ind)


#pcd.normals = o3d.utility.Vector3dVector(np.zeros(
#    (1, 3)))  # invalidate existing normals

#pcd.estimate_normals()

#print("Meshing")
#radii = [0.005, 0.01, 0.02, 0.04]
#rec_mesh = o3d.geometry.TriangleMesh.create_from_point_cloud_ball_pivoting(inlier_cloud, /#o3d.utility.DoubleVector(radii))

print("saving...")
o3d.io.write_point_cloud(output_folder + "/outliers_removed.ply", inlier_cloud, write_ascii=False)
