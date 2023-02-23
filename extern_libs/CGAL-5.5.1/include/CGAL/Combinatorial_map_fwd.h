// Copyright (c) 2010-2011 CNRS and LIRIS' Establishments (France).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org)
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Combinatorial_map/include/CGAL/Combinatorial_map_fwd.h $
// $Id: Combinatorial_map_fwd.h 46f5325 2022-01-27T10:36:22+01:00 Guillaume Damiand
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
// Author(s)     : Guillaume Damiand <guillaume.damiand@liris.cnrs.fr>
//
#ifndef COMBINATORIAL_MAP_FWD_H
#define COMBINATORIAL_MAP_FWD_H 1

#include <CGAL/memory.h>
#include <CGAL/tags.h>

namespace CGAL {

struct Generic_map_min_items;

template<unsigned int d_, class Items_, class Alloc_, class Concurrent_tag=CGAL::Tag_false >
class Combinatorial_map_storage_1;

template < unsigned int d_, class Refs_,
           class Items_=Generic_map_min_items,
           class Alloc_=CGAL_ALLOCATOR(int),
           class Storage_= Combinatorial_map_storage_1<d_, Items_, Alloc_, CGAL::Tag_false> >
class Combinatorial_map_base;

template < unsigned int d_,
           class Items_=Generic_map_min_items,
           class Alloc_=CGAL_ALLOCATOR(int),
           class Storage_= Combinatorial_map_storage_1<d_, Items_, Alloc_, CGAL::Tag_false> >
class Combinatorial_map;

} // CGAL

#endif // COMBINATORIAL_MAP_FWD_H
