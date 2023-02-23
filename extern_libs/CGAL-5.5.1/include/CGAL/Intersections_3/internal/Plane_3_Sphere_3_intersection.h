// Copyright (c) 2003  INRIA Sophia-Antipolis (France).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org)
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Intersections_3/include/CGAL/Intersections_3/internal/Plane_3_Sphere_3_intersection.h $
// $Id: Plane_3_Sphere_3_intersection.h c2d1adf 2021-06-23T17:34:48+02:00 Mael Rouxel-Labbé
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Pedro Machado Manhaes de Castro

#ifndef CGAL_INTERNAL_INTERSECTIONS_PLANE_3_SPHERE_3_INTERSECTION_H
#define CGAL_INTERNAL_INTERSECTIONS_PLANE_3_SPHERE_3_INTERSECTION_H

#include <CGAL/Intersection_traits_3.h>

#include <CGAL/number_utils.h>

namespace CGAL {
namespace Intersections {
namespace internal {

template <class K>
typename Intersection_traits<K, typename K::Plane_3, typename K::Sphere_3>::result_type
intersection(const typename K::Plane_3& p,
             const typename K::Sphere_3& s,
             const K&)
{
  typedef typename K::FT FT;
  typedef typename K::Point_3 Point_3;
  typedef typename K::Circle_3 Circle_3;

  const FT d2 = CGAL::square(p.a()*s.center().x() +
                             p.b()*s.center().y() +
                             p.c()*s.center().z() + p.d()) /
                (square(p.a()) + square(p.b()) + square(p.c()));

  const FT cmp = d2 - s.squared_radius();

  if(CGAL_NTS is_zero(cmp)) // tangent
  {
    return intersection_return<typename K::Intersect_3, typename K::Plane_3, typename K::Sphere_3>(
             p.projection(s.center()));
  }
  else if(CGAL_NTS is_negative(cmp)) // intersect
  {
    Point_3 center = p.projection(s.center());
    return intersection_return<typename K::Intersect_3, typename K::Plane_3, typename K::Sphere_3>(
             Circle_3{center, s.squared_radius() - d2, p});
  }

  // do not intersect
  return intersection_return<typename K::Intersect_3, typename K::Plane_3, typename K::Sphere_3>();
}

template <class K>
inline
typename Intersection_traits<K, typename K::Sphere_3, typename K::Plane_3>::result_type
intersection(const typename K::Sphere_3& s,
             const typename K::Plane_3& p,
             const K& k)
{
  return intersection(p, s, k);
}

} // namespace internal
} // namespace Intersections
} // namespace CGAL

#endif // CGAL_INTERNAL_INTERSECTIONS_PLANE_3_SPHERE_3_INTERSECTION_H
