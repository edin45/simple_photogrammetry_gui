import os
import pymeshlab
import optparse

parser = optparse.OptionParser()
parser.add_option("-m","--mesh",action="store",help="To be textured mesh")
parser.add_option("-o","--output_folder",action="store",help="Folder where Results are stored")
parser.add_option("-t","--target_mesh_density",action="store",help="Target Density")
options, args = parser.parse_args()
output_folder = options.output_folder
mesh = options.mesh
target_mesh_density = float(options.target_mesh_density)

ms = pymeshlab.MeshSet()
print('reading...')
ms.load_new_mesh(mesh)
# ms.meshing_decimation_quadric_edge_collapse(targetfacenum=int(ms.current_mesh().face_number()/face_reduction_factor))
ms.meshing_decimation_clustering(
    threshold=pymeshlab.PercentageValue(target_mesh_density)
)
print('saving')
ms.save_current_mesh(os.path.join(output_folder,"model_surface_decimated.ply"))