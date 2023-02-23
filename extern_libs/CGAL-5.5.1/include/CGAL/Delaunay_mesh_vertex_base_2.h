// Copyright (c) 2003-2006  INRIA Sophia-Antipolis (France).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org).
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Mesh_2/include/CGAL/Delaunay_mesh_vertex_base_2.h $
// $Id: Delaunay_mesh_vertex_base_2.h e3934f1 2021-05-12T15:20:27+02:00 Laurent Rineau
// SPDX-License-Identifier: GPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Jane Tournois

#ifndef CGAL_DELAUNAY_VERTEX_BASE_2_H
#define CGAL_DELAUNAY_VERTEX_BASE_2_H

#include <CGAL/license/Mesh_2.h>


#include <CGAL/Triangulation_vertex_base_2.h>

namespace CGAL {

template <class Gt,
          class Vb = Triangulation_vertex_base_2<Gt> >
class Delaunay_mesh_vertex_base_2 : public Vb
{
public:
  typedef typename Gt::FT          FT;
  typedef typename Vb::Point       Point;
  typedef typename Vb::Face_handle Face_handle;

  template < typename TDS2 >
  struct Rebind_TDS {
    typedef typename Vb::template Rebind_TDS<TDS2>::Other Vb2;
    typedef Delaunay_mesh_vertex_base_2<Gt,Vb2> Other;
  };

protected:
  FT sizing_info_;

public:
  Delaunay_mesh_vertex_base_2()
    : Vb()
    , sizing_info_(0.)
  {}

  Delaunay_mesh_vertex_base_2(Point p)
    : Vb(p)
    , sizing_info_(0.)
  {}

  Delaunay_mesh_vertex_base_2(Point p,
                              Face_handle f)
    : Vb(p, f)
    , sizing_info_(0.)
  {}

  void set_sizing_info(const FT& s)
  {
    sizing_info_ = s;
  }
  const FT& sizing_info() const { return sizing_info_; }
#ifdef CGAL_MESH_2_DEBUG_REFINEMENT_POINTS
  typedef Tag_true Has_timestamp;

  std::size_t time_stamp() const { return time_stamp_; }

  void set_time_stamp(const std::size_t& ts) { time_stamp_ = ts; }

  std::size_t time_stamp_;
#endif // CGAL_MESH_2_DEBUG_REFINEMENT_POINTS
};

} // namespace CGAL

#endif
