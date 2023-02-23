// Copyright (c) 2006 Foundation for Research and Technology-Hellas (Greece).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org).
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Voronoi_diagram_2/include/CGAL/Voronoi_diagram_2/Handle_adaptor.h $
// $Id: Handle_adaptor.h aea0bdd 2021-09-13T09:33:35+02:00 Laurent Rineau
// SPDX-License-Identifier: GPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Menelaos Karavelas <mkaravel@iacm.forth.gr>

#ifndef CGAL_VORONOI_DIAGRAM_2_HANDLE_ADAPTOR_H
#define CGAL_VORONOI_DIAGRAM_2_HANDLE_ADAPTOR_H 1

#include <CGAL/license/Voronoi_diagram_2.h>


#include <CGAL/Voronoi_diagram_2/basic.h>

namespace CGAL {

namespace VoronoiDiagram_2 { namespace Internal {

template<class T>
class Handle_adaptor
{
 private:
  typedef Handle_adaptor<T>  Self;
 public:
  typedef T      value_type;
  typedef T*     pointer;
  typedef T&     reference;
  typedef const T*  const_pointer;
  typedef const T&  const_reference;
  typedef void iterator_category;
  typedef std::ptrdiff_t difference_type;

 public:
  Handle_adaptor() : t() {}
  Handle_adaptor(const T& t) : t(t) {}

  pointer    operator->() { return &t; }
  reference  operator*() { return t; }

  const_pointer    operator->() const { return &t; }
  const_reference  operator*() const { return t; }

  bool operator==(const Self& other) const {
    return t == other.t;
  }

  bool operator!=(const Self& other) const {
    return t != other.t;
  }

  bool operator<(const Self& other) const {
    return t < other.t;
  }

 private:
  T t;
};

} } //namespace VoronoiDiagram_2::Internal

} //namespace CGAL

#endif // CGAL_VORONOI_DIAGRAM_2_HANDLE_ADAPTOR_H
