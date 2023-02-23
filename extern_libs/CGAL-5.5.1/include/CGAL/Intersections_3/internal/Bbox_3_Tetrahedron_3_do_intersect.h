// Copyright (c) 2008  INRIA Sophia-Antipolis (France), ETH Zurich (Switzerland).
// Copyright (c) 2010, 2014  GeometryFactory Sarl (France).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org)
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Intersections_3/include/CGAL/Intersections_3/internal/Bbox_3_Tetrahedron_3_do_intersect.h $
// $Id: Bbox_3_Tetrahedron_3_do_intersect.h c2d1adf 2021-06-23T17:34:48+02:00 Mael Rouxel-Labbé
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Michael Hemmer

#ifndef CGAL_INTERNAL_INTERSECTIONS_3_BBOX_3_TETRAHEDRON_3_DO_INTERSECT_H
#define CGAL_INTERNAL_INTERSECTIONS_3_BBOX_3_TETRAHEDRON_3_DO_INTERSECT_H

#include <CGAL/Intersections_3/internal/Bbox_3_Triangle_3_do_intersect.h>

#include <CGAL/Bbox_3.h>
#include <CGAL/Uncertain.h>

namespace CGAL {
namespace Intersections {
namespace internal {

template <class K>
inline typename K::Boolean do_intersect(const CGAL::Bbox_3& aabb,
                                        const typename K::Tetrahedron_3& tet,
                                        const K& k)
{
  typename K::Construct_triangle_3 tr = k.construct_triangle_3_object();
  typename K::Boolean result = false;
  typename K::Boolean b = false;

  b = do_intersect(aabb, tr(tet[0], tet[1], tet[2]), k);
  if(certainly(b)) return b;
  if(is_indeterminate(b)) result = b;

  b = do_intersect(aabb, tr(tet[1], tet[2], tet[3]), k);
  if(certainly(b)) return b;
  if(is_indeterminate(b)) result = b;

  b = do_intersect(aabb, tr(tet[2], tet[3], tet[0]), k);
  if(certainly(b)) return b;
  if(is_indeterminate(b)) result = b;

  b = do_intersect(aabb, tr(tet[3], tet[0], tet[1]), k);
  if(certainly(b)) return b;
  if(is_indeterminate(b)) result = b;

  b = k.has_on_bounded_side_3_object()(
      tet, k.construct_point_3_object()(aabb.xmin(), aabb.ymin(), aabb.zmin()));
  if(certainly(b)) return b;
  if(is_indeterminate(b)) result = b;

  return result;
}

template <class K>
inline typename K::Boolean do_intersect(const typename K::Tetrahedron_3& tet,
                                        const CGAL::Bbox_3& bb,
                                        const K &k)
{
  return do_intersect(bb, tet, k);
}

} // namespace internal
} // namespace Intersections
} // namespace CGAL

#endif // CGAL_INTERNAL_INTERSECTIONS_3_BBOX_3_TETRAHEDRON_3_DO_INTERSECT_H
