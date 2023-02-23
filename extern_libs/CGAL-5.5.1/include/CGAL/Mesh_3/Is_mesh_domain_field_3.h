// Copyright (c) 2019 GeometryFactory Sarl  (France).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org).
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Mesh_3/include/CGAL/Mesh_3/Is_mesh_domain_field_3.h $
// $Id: Is_mesh_domain_field_3.h 393ae7d 2021-05-12T15:03:53+02:00 Maxime Gimeno
// SPDX-License-Identifier: GPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Laurent Rineau
//
//******************************************************************************
// File Description :
// Mesh_facet_criteria_3 class.
//******************************************************************************

#ifndef CGAL_MESH_3_IS_MESH_DOMAIN_FIELD_3_H
#define CGAL_MESH_3_IS_MESH_DOMAIN_FIELD_3_H

#include <CGAL/license/Mesh_3.h>

#include <boost/config.hpp>
#include <boost/callable_traits/is_invocable.hpp>

#include <CGAL/tags.h>

namespace CGAL {
  namespace Mesh_3 {
    template <typename Tr, typename Type>
    struct Is_mesh_domain_field_3 :
      public CGAL::Boolean_tag
      <
        boost::callable_traits::is_invocable_r<
          typename Tr::FT,
          Type,
          typename Tr::Bare_point,
          int,
          typename Tr::Vertex::Index
        >::value
      >
    {};
  } // end namespace Mesh_3
} // end namespace CGAL

#endif // CGAL_MESH_3_IS_MESH_DOMAIN_FIELD_3_H
