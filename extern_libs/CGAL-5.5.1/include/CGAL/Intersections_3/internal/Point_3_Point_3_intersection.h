// Copyright (c) 2003  INRIA Sophia-Antipolis (France).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org)
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Intersections_3/include/CGAL/Intersections_3/internal/Point_3_Point_3_intersection.h $
// $Id: Point_3_Point_3_intersection.h c2d1adf 2021-06-23T17:34:48+02:00 Mael Rouxel-Labbé
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Sébastien Loriot

#ifndef CGAL_INTERNAL_INTERSECTIONS_POINT_3_POINT_3_INTERSECTION_H
#define CGAL_INTERNAL_INTERSECTIONS_POINT_3_POINT_3_INTERSECTION_H

#include <CGAL/Intersection_traits_3.h>
#include <CGAL/Intersections_3/internal/Point_3_Point_3_do_intersect.h>

namespace CGAL {
namespace Intersections {
namespace internal {

template <class K>
typename CGAL::Intersection_traits<K, typename K::Point_3, typename K::Point_3>::result_type
intersection(const typename K::Point_3& pt1,
             const typename K::Point_3& pt2,
             const K& k)
{
  if(do_intersect(pt1, pt2, k))
    return intersection_return<typename K::Intersect_3, typename K::Point_3, typename K::Point_3>(pt1);

  return intersection_return<typename K::Intersect_3, typename K::Point_3, typename K::Point_3>();
}

} // namespace internal
} // namespace Intersections
} // namespace CGAL

#endif // CGAL_INTERNAL_INTERSECTIONS_POINT_3_POINT_3_INTERSECTION_H
