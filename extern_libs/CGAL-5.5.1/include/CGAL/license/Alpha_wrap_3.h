// Copyright (c) 2016  GeometryFactory SARL (France).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org)
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Installation/include/CGAL/license/Alpha_wrap_3.h $
// $Id: Alpha_wrap_3.h c8ad168 2022-03-18T21:31:41+01:00 Mael Rouxel-Labbé
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
// Author(s) : Andreas Fabri
//
// Warning: this file is generated, see include/CGAL/licence/README.md

#ifndef CGAL_LICENSE_ALPHA_WRAP_3_H
#define CGAL_LICENSE_ALPHA_WRAP_3_H

#include <CGAL/config.h>
#include <CGAL/license.h>

#ifdef CGAL_ALPHA_WRAP_3_COMMERCIAL_LICENSE

#  if CGAL_ALPHA_WRAP_3_COMMERCIAL_LICENSE < CGAL_RELEASE_DATE

#    if defined(CGAL_LICENSE_WARNING)

       CGAL_pragma_warning("Your commercial license for CGAL does not cover "
                           "this release of the 3D Alpha Wrapping package.")
#    endif

#    ifdef CGAL_LICENSE_ERROR
#      error "Your commercial license for CGAL does not cover this release \
              of the 3D Alpha Wrapping package. \
              You get this error, as you defined CGAL_LICENSE_ERROR."
#    endif // CGAL_LICENSE_ERROR

#  endif // CGAL_ALPHA_WRAP_3_COMMERCIAL_LICENSE < CGAL_RELEASE_DATE

#else // no CGAL_ALPHA_WRAP_3_COMMERCIAL_LICENSE

#  if defined(CGAL_LICENSE_WARNING)
     CGAL_pragma_warning("\nThe macro CGAL_ALPHA_WRAP_3_COMMERCIAL_LICENSE is not defined."
                          "\nYou use the CGAL 3D Alpha Wrapping package under "
                          "the terms of the GPLv3+.")
#  endif // CGAL_LICENSE_WARNING

#  ifdef CGAL_LICENSE_ERROR
#    error "The macro CGAL_ALPHA_WRAP_3_COMMERCIAL_LICENSE is not defined.\
            You use the CGAL 3D Alpha Wrapping package under the terms of \
            the GPLv3+. You get this error, as you defined CGAL_LICENSE_ERROR."
#  endif // CGAL_LICENSE_ERROR

#endif // no CGAL_ALPHA_WRAP_3_COMMERCIAL_LICENSE

#endif // CGAL_LICENSE_ALPHA_WRAP_3_H
