// Copyright (c) 2008  INRIA Sophia-Antipolis (France), ETH Zurich (Switzerland).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org)
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Intersections_3/include/CGAL/Intersections_3/internal/Bbox_3_Plane_3_do_intersect.h $
// $Id: Bbox_3_Plane_3_do_intersect.h c2d1adf 2021-06-23T17:34:48+02:00 Mael Rouxel-Labbé
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Camille Wormser, Jane Tournois, Pierre Alliez

#ifndef CGAL_INTERNAL_INTERSECTIONS_3_BBOX_3_PLANE_3_DO_INTERSECT_H
#define CGAL_INTERNAL_INTERSECTIONS_3_BBOX_3_PLANE_3_DO_INTERSECT_H

#include <CGAL/Intersections_3/internal/Iso_cuboid_3_Plane_3_do_intersect.h>

#include <CGAL/Bbox_3.h>

namespace CGAL {
namespace Intersections {
namespace internal {

template <class K>
bool do_intersect(const typename K::Plane_3& plane,
                  const Bbox_3& bbox,
                  const K& k)
{
  return do_intersect_plane_box(plane, bbox, k);
}

template <class K>
bool do_intersect(const Bbox_3& bbox,
                  const typename K::Plane_3& plane,
                  const K& k)
{
  return do_intersect_plane_box(plane, bbox, k);
}

} // namespace internal
} // namespace Intersections
} // namespace CGAL

#endif // CGAL_INTERNAL_INTERSECTIONS_3_BBOX_3_PLANE_3_DO_INTERSECT_H
