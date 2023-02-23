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
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Intersections_3/include/CGAL/Intersections_3/Bbox_3_Ray_3.h $
// $Id: Bbox_3_Ray_3.h c2d1adf 2021-06-23T17:34:48+02:00 Mael Rouxel-Labbé
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Sebastien Loriot
//

#ifndef CGAL_INTERSECTIONS_3_BBOX_3_RAY_3_H
#define CGAL_INTERSECTIONS_3_BBOX_3_RAY_3_H

#include <CGAL/Intersection_traits_3.h>
#include <CGAL/Intersections_3/internal/Bbox_3_Ray_3_do_intersect.h>
#include <CGAL/Intersections_3/internal/Bbox_3_Ray_3_intersection.h>

#include <CGAL/Bbox_3.h>
#include <CGAL/Ray_3.h>

namespace CGAL {

template<typename K>
bool do_intersect(const CGAL::Bbox_3& box,
                  const Ray_3<K>& r)
{
  return K().do_intersect_3_object()(box, r);
}

template<typename K>
bool do_intersect(const Ray_3<K>& r,
                  const CGAL::Bbox_3& box)
{
  return K().do_intersect_3_object()(r, box);
}

template<typename K>
typename Intersection_traits<K, typename K::Ray_3, Bbox_3>::result_type
intersection(const CGAL::Bbox_3& box,
             const Ray_3<K>& r)
{
  return K().intersect_3_object()(box, r);
}

template<typename K>
typename Intersection_traits<K, typename K::Ray_3, Bbox_3>::result_type
intersection(const Ray_3<K>& r,
             const CGAL::Bbox_3& box)
{
  return K().intersect_3_object()(r, box);
}

} // namespace CGAL

#endif // CGAL_INTERSECTIONS_3_BBOX_3_RAY_3_H
