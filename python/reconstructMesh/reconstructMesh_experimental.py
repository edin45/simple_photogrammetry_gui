
generate_surface_reconstruction_vcg
# import optparse
# import open3d as o3d
# import numpy as np
# import pyvista as pv

# parser = optparse.OptionParser()
# parser.add_option("-i","--input_pointcloud",action="store",help="Input Pointcloud")
# parser.add_option("-o","--output_folder",action="store",help="Folder where Results are stored")
# parser.add_option("-d","--recon_depth",action="store",help="Reconstruction Depth")
# options, args = parser.parse_args()
# input_pointcloud_path = options.input_pointcloud
# output_folder = options.output_folder
# recon_depth = options.recon_depth


# #pcd.normals = o3d.utility.Vector3dVector(np.zeros(
# #    (1, 3)))  # invalidate existing normals

# #pcd.estimate_normals()

# #print("Meshing")
# #radii = [0.005, 0.01, 0.02, 0.04]
# #rec_mesh = o3d.geometry.TriangleMesh.create_from_point_cloud_ball_pivoting(inlier_cloud, /#o3d.utility.DoubleVector(radii))

# print('reading...')
# input_pointcloud = pv.read(input_pointcloud_path)
# #o3d.io.read_point_cloud(input_pointcloud_path)

# # points is a 3D numpy array (n_points, 3) coordinates of a sphere
# cloud = pv.PolyData(input_pointcloud)

# print('meshing...')
# surf = cloud.reconstruct_surface()
# surf.save(output_folder + 'py_vista_test.ply')

# # volume = cloud.delaunay_3d(alpha=2.)
# # shell = volume.extract_geometry()
# # shell.save(output_folder + 'py_vista_test.ply')

# #input_pointcloud.normals = o3d.utility.Vector3dVector(np.zeros(
# #    (1, 3)))  # invalidate existing normals

# #input_pointcloud.estimate_normals()
# #print("filtering...")
# #cl, ind = input_pointcloud.remove_statistical_outlier(nb_neighbors=50, std_ratio=0.1)
# #cl, ind = pcd.remove_radius_outlier(nb_points=16, radius=0.05)



# #inlier_cloud = input_pointcloud.select_by_index(ind)

# #scale = 0.1

# #while(scale < 2.0):

# # print("meshing...")
# # print('run Poisson surface reconstruction')

# # with o3d.utility.VerbosityContextManager(
# #         o3d.utility.VerbosityLevel.Debug) as cm:
# #     mesh, densities = o3d.geometry.TriangleMesh.create_from_point_cloud_poisson(
# #         input_pointcloud, depth=int(recon_depth), scale=0.9)

# # with o3d.utility.VerbosityContextManager(
# #         o3d.utility.VerbosityLevel.Debug) as cm:
# #     triangle_clusters, cluster_n_triangles, cluster_area = (
# #         mesh.cluster_connected_triangles())
# # triangle_clusters = np.asarray(triangle_clusters)
# # cluster_n_triangles = np.asarray(cluster_n_triangles)
# # cluster_area = np.asarray(cluster_area)

# # triangles_to_remove = cluster_n_triangles[triangle_clusters] < 100
# # mesh.remove_triangles_by_mask(triangles_to_remove)

# # print(f"saving (scale: 0.9)...")
# # o3d.io.write_triangle_mesh(output_folder + f"/meshed_poisson_cleanup.ply", mesh, write_ascii=False)
# #    scale+=0.1

