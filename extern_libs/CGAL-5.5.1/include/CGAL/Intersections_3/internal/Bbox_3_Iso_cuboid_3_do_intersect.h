// Copyright (c) 2008  INRIA Sophia-Antipolis (France), ETH Zurich (Switzerland).
// Copyright (c) 2010, 2014 GeometryFactory Sarl (France).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org)
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Intersections_3/include/CGAL/Intersections_3/internal/Bbox_3_Iso_cuboid_3_do_intersect.h $
// $Id: Bbox_3_Iso_cuboid_3_do_intersect.h 9c6456f 2021-07-29T14:23:40+02:00 Mael Rouxel-Labbé
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Camille Wormser, Jane Tournois, Pierre Alliez

#ifndef CGAL_INTERNAL_INTERSECTIONS_3_BBOX_3_ISO_CUBOID_3_DO_INTERSECT_H
#define CGAL_INTERNAL_INTERSECTIONS_3_BBOX_3_ISO_CUBOID_3_DO_INTERSECT_H

#include <CGAL/Bbox_3.h>
#include <CGAL/enum.h>
#include <CGAL/number_utils.h>

namespace CGAL {
namespace Intersections {
namespace internal {

template <class K>
bool do_intersect(const CGAL::Bbox_3& bb,
                  const typename K::Iso_cuboid_3& ic,
                  const K& /* k */)
{
  // use CGAL::compare to access the Coercion_traits between K::FT and double
  if(compare(bb.xmax(), ic.xmin()) == SMALLER || compare(ic.xmax(), bb.xmin()) == SMALLER)
    return false;
  if(compare(bb.ymax(), ic.ymin()) == SMALLER || compare(ic.ymax(), bb.ymin()) == SMALLER)
    return false;
  if(compare(bb.zmax(), ic.zmin()) == SMALLER || compare(ic.zmax(), bb.zmin()) == SMALLER)
    return false;
  return true;
}

template <class K>
bool do_intersect(const typename K::Iso_cuboid_3& ic,
                  const CGAL::Bbox_3& bb,
                  const K& k)
{
  return do_intersect(bb, ic, k);
}

} // namespace internal
} // namespace Intersections
} // namespace CGAL

#endif // CGAL_INTERNAL_INTERSECTIONS_3_BBOX_3_ISO_CUBOID_3_DO_INTERSECT_H
