// Copyright (c) 2019
// GeometryFactory.  All rights reserved.
//
// This file is part of CGAL (www.cgal.org)
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Intersections_2/include/CGAL/Intersections_2/Circle_2_Segment_2.h $
// $Id: Circle_2_Segment_2.h 7e62c02 2021-04-12T14:02:37+02:00 Mael Rouxel-Labbé
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Maxime Gimeno

#ifndef CGAL_INTERSECTIONS_2_CIRCLE_2_SEGMENT_2_H
#define CGAL_INTERSECTIONS_2_CIRCLE_2_SEGMENT_2_H

#include <CGAL/Distance_2/Point_2_Segment_2.h>
#include <CGAL/Intersection_traits_2.h>

#include <CGAL/Circle_2.h>
#include <CGAL/Segment_2.h>

namespace CGAL {
namespace Intersections {
namespace internal {

template <class K>
bool
do_intersect(const typename K::Circle_2 & c,
             const typename K::Segment_2& s,
             const K&)
{
  return squared_distance(c.center(), s) <= c.squared_radius();
}

template <class K>
bool
do_intersect(const typename K::Segment_2& s,
             const typename K::Circle_2 & c,
             const K&)
{
  return squared_distance(c.center(), s) <= c.squared_radius();
}

} // namespace internal
} // namespace Intersections

CGAL_DO_INTERSECT_FUNCTION(Circle_2, Segment_2, 2)

} // namespace CGAL
#endif // CGAL_INTERSECTIONS_2_CIRCLE_2_SEGMENT_2_H
