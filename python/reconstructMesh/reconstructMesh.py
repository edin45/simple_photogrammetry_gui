import optparse
import open3d as o3d
import numpy as np
import pymeshlab

parser = optparse.OptionParser()
parser.add_option("-i","--input_pointcloud",action="store",help="Input Pointcloud")
parser.add_option("-o","--output_folder",action="store",help="Folder where Results are stored")
parser.add_option("-d","--recon_depth",action="store",help="Reconstruction Depth")
options, args = parser.parse_args()
input_pointcloud_path = options.input_pointcloud
output_folder = options.output_folder
recon_depth = options.recon_depth







#pcd.normals = o3d.utility.Vector3dVector(np.zeros(
#    (1, 3)))  # invalidate existing normals

#pcd.estimate_normals()

#print("Meshing")
#radii = [0.005, 0.01, 0.02, 0.04]
#rec_mesh = o3d.geometry.TriangleMesh.create_from_point_cloud_ball_pivoting(inlier_cloud, /#o3d.utility.DoubleVector(radii))

input_pointcloud = o3d.io.read_point_cloud(input_pointcloud_path)

#input_pointcloud.normals = o3d.utility.Vector3dVector(np.zeros(
#    (1, 3)))  # invalidate existing normals

#input_pointcloud.estimate_normals()
#print("filtering...")
#cl, ind = input_pointcloud.remove_statistical_outlier(nb_neighbors=50, std_ratio=0.1)
#cl, ind = pcd.remove_radius_outlier(nb_points=16, radius=0.05)



#inlier_cloud = input_pointcloud.select_by_index(ind)

#scale = 0.1
#generate_sampling_voronoi
pcd = input_pointcloud.voxel_down_sample(voxel_size=0.005)
pcd.estimate_normals()
# o3d.geometry.estimate_normals(pcd,search_param=o3d.geometry.KDTreeSearchParamHybrid(radius=0.1,max_nn=30))
# print(f"saving...")
o3d.io.write_point_cloud(output_folder + f"/downsampled.ply", pcd, write_ascii=False)
print('recon')

#Alpha shapes
# mesh = o3d.geometry.TriangleMesh.create_from_point_cloud_alpha_shape(pcd, 0.01)
# mesh.compute_vertex_normals()

# #BPA:

# radii = [0.009]
# mesh = o3d.geometry.TriangleMesh.create_from_point_cloud_ball_pivoting(
#     pcd, o3d.utility.DoubleVector(radii))

# print('saving')
# o3d.io.write_triangle_mesh(output_folder + f"/bpa_recon.ply", mesh, write_ascii=False)

#while(scale < 2.0):

# print("meshing...")
# print('run Poisson surface reconstruction')
# with o3d.utility.VerbosityContextManager(
#         o3d.utility.VerbosityLevel.Debug) as cm:
#     mesh, densities = o3d.geometry.TriangleMesh.create_from_point_cloud_poisson(
#         input_pointcloud, depth=int(recon_depth), scale=0.9)

# with o3d.utility.VerbosityContextManager(
#         o3d.utility.VerbosityLevel.Debug) as cm:
#     triangle_clusters, cluster_n_triangles, cluster_area = (
#         mesh.cluster_connected_triangles())
# triangle_clusters = np.asarray(triangle_clusters)
# cluster_n_triangles = np.asarray(cluster_n_triangles)
# cluster_area = np.asarray(cluster_area)

# triangles_to_remove = cluster_n_triangles[triangle_clusters] < 100
# mesh.remove_triangles_by_mask(triangles_to_remove)

# print(f"saving...")
# o3d.io.write_triangle_mesh(output_folder + f"/meshed_poisson_cleanup.ply", mesh, write_ascii=False)


#    scale+=0.1





print("cleaning & reconstructing")

ms = pymeshlab.MeshSet()

print('reading...')
ms.load_new_mesh(output_folder + "/downsampled.ply")
# texturesize 
#ms.
# ms.generate_surface_reconstruction_ball_pivoting()

# ms.generate_marching_cubes_apss(filterscale=5)
# print('estimating_normals...')
# ms.compute_normal_for_point_clouds()
# print('remove outliers')
# ms.compute_selection_point_cloud_outliers()
# ms.meshing_remove_selected_vertices()
# print('reconstructing...')
# ms.generate_surface_reconstruction_screened_poisson(depth=int(recon_depth))
# print('remove_connected_componet_by_diameter...')
# ms.meshing_remove_connected_component_by_diameter()
# ms.meshing_remove_connected_component_by_face_number(mincomponentsize=100)
# print('compute_selection_by_edge_length...')
# # ms.meshing_remove_connected_component_by_diameter()
# ms.compute_selection_by_edge_length(threshold=0.1)
# print('meshing_remove_selected_faces...')
# ms.meshing_remove_selected_faces()
# print('dilate...')
# ms.apply_selection_dilatation()
# ms.apply_selection_dilatation()
# ms.apply_selection_dilatation()
# ms.apply_selection_dilatation()
# ms.apply_selection_dilatation()
# print('select_small_disconnected_components...')
# ms.compute_selection_by_small_disconnected_components_per_face()
# print('remove_selected_faces...')
# ms.meshing_remove_selected_faces()
# print('repair_non_manifold_edges...')
# ms.meshing_repair_non_manifold_edges()
# print('close_holes...')
# ms.meshing_close_holes()
# print('repair non manifold...')
# ms.meshing_repair_non_manifold_edges()
# print('saving...')
ms.save_current_mesh(output_folder + "/cleaned_up.ply")
