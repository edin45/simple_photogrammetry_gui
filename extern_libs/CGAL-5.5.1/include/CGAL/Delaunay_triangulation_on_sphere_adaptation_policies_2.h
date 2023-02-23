// Copyright (c) 2021 GeometryFactory
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org).
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Voronoi_diagram_2/include/CGAL/Delaunay_triangulation_on_sphere_adaptation_policies_2.h $
// $Id: Delaunay_triangulation_on_sphere_adaptation_policies_2.h d5a306b 2021-06-11T17:26:36+02:00 Mael Rouxel-Labbé
// SPDX-License-Identifier: GPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Menelaos Karavelas <mkaravel@iacm.forth.gr>
//                 Mael Rouxel-Labbé

#ifndef CGAL_DELAUNAY_TRIANGULATION_ON_SPHERE_ADAPTATION_POLICIES_2_H
#define CGAL_DELAUNAY_TRIANGULATION_ON_SPHERE_ADAPTATION_POLICIES_2_H 1

#include <CGAL/license/Voronoi_diagram_2.h>

#include <CGAL/Voronoi_diagram_2/basic.h>
#include <CGAL/Voronoi_diagram_2/Delaunay_triangulation_on_sphere_degeneracy_testers.h>
#include <CGAL/Voronoi_diagram_2/Policy_base.h>
#include <CGAL/Voronoi_diagram_2/Default_site_inserters.h>
#include <CGAL/Voronoi_diagram_2/Identity_rejectors.h>

#include <CGAL/Identity_policy_2.h>

namespace CGAL {

//=========================================================================
//=========================================================================

template<class DToS2>
struct Delaunay_triangulation_on_sphere_degeneracy_removal_policy_2
  : public CGAL_VORONOI_DIAGRAM_2_INS::Policy_base
  <DToS2,
   CGAL_VORONOI_DIAGRAM_2_INS::Delaunay_triangulation_on_sphere_edge_tester_2<DToS2>,
   CGAL_VORONOI_DIAGRAM_2_INS::Identity_face_rejector<DToS2>,
   CGAL_VORONOI_DIAGRAM_2_INS::Default_site_inserter<typename DToS2::Point,DToS2>,
   CGAL_VORONOI_DIAGRAM_2_INS::Default_site_remover<DToS2> >
{
  typedef typename DToS2::Point      Site_2;
};


//=========================================================================
//=========================================================================

template<class DToS2>
struct Delaunay_triangulation_on_sphere_caching_degeneracy_removal_policy_2
  : public CGAL_VORONOI_DIAGRAM_2_INS::Caching_policy_base
  <DToS2,
   CGAL_VORONOI_DIAGRAM_2_INS::Delaunay_triangulation_on_sphere_edge_tester_2<DToS2>,
   CGAL_VORONOI_DIAGRAM_2_INS::Identity_face_rejector<DToS2>,
   CGAL_VORONOI_DIAGRAM_2_INS::Default_site_inserter<typename DToS2::Point,DToS2>,
   CGAL_VORONOI_DIAGRAM_2_INS::Default_site_remover<DToS2> >
{
  typedef typename DToS2::Point      Site_2;
};

//=========================================================================
//=========================================================================

} // namespace CGAL

#endif // CGAL_DELAUNAY_TRIANGULATION_ON_SPHERE_ADAPTATION_POLICIES_2_H
