// Copyright (c) 1997-2021
// Utrecht University (The Netherlands),
// ETH Zurich (Switzerland),
// INRIA Sophia-Antipolis (France),
// Max-Planck-Institute Saarbruecken (Germany),
// and Tel-Aviv University (Israel).
// GeometryFactory (France)
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org)
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Intersections_3/include/CGAL/Intersections_3/Plane_3_Sphere_3.h $
// $Id: Plane_3_Sphere_3.h c2d1adf 2021-06-23T17:34:48+02:00 Mael Rouxel-Labbé
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Sebastien Loriot
//

#ifndef CGAL_INTERSECTIONS_3_PLANE_3_SPHERE_3_H
#define CGAL_INTERSECTIONS_3_PLANE_3_SPHERE_3_H

#include <CGAL/Intersection_traits_3.h>
#include <CGAL/Intersections_3/internal/Plane_3_Sphere_3_do_intersect.h>
#include <CGAL/Intersections_3/internal/Plane_3_Sphere_3_intersection.h>

#include <CGAL/Plane_3.h>
#include <CGAL/Sphere_3.h>

namespace CGAL {

CGAL_DO_INTERSECT_FUNCTION(Plane_3, Sphere_3, 3)
CGAL_INTERSECTION_FUNCTION(Plane_3, Sphere_3, 3)

} // namespace CGAL

#endif // CGAL_INTERSECTIONS_3_PLANE_3_SPHERE_3_H
