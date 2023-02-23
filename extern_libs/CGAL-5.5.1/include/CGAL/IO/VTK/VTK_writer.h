// Copyright (c) 2018
// GeometryFactory (France) All rights reserved.
//
// This file is part of CGAL (www.cgal.org)
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Stream_support/include/CGAL/IO/VTK/VTK_writer.h $
// $Id: VTK_writer.h 423ae6e 2020-01-24T17:48:02+01:00 Mael Rouxel-Labbé
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Stephane Tayeb

#ifndef CGAL_IO_VTK_WRITER_H
#define CGAL_IO_VTK_WRITER_H

#include <fstream>
#include <iostream>
#include <vector>

namespace CGAL {
namespace IO {
namespace internal {

template <class FT>
void write_vector(std::ostream& os,
                  const std::vector<FT>& vect)
{
  const char* buffer = reinterpret_cast<const char*>(&(vect[0]));
  std::size_t size = vect.size()*sizeof(FT);

  os.write(reinterpret_cast<const char *>(&size), sizeof(std::size_t)); // number of bytes encoded
  os.write(buffer, vect.size()*sizeof(FT)); // encoded data
}

} // namespace internal
} // namespace IO
} // namespace CGAL

#endif // CGAL_IO_VTK_WRITER_H
