// Copyright (c) 2016 GeometryFactory (France)
//  All rights reserved.
//
// This file is part of CGAL (www.cgal.org)
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Installation/include/CGAL/mutex.h $
// $Id: mutex.h 6481cb2 2021-08-13T16:44:53+02:00 Sébastien Loriot
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial

#ifndef CGAL_MUTEX_H
#define CGAL_MUTEX_H

#include <CGAL/config.h>

#ifdef CGAL_HAS_THREADS
#include <mutex>
#define CGAL_MUTEX std::mutex
#define CGAL_SCOPED_LOCK(M) std::unique_lock<std::mutex> scoped_lock(M)
#endif
#endif // CGAL_MUTEX_H
