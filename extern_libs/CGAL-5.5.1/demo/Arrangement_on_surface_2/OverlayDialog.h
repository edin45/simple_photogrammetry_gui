// Copyright (c) 2012  Tel-Aviv University (Israel).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org).
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Arrangement_on_surface_2/demo/Arrangement_on_surface_2/OverlayDialog.h $
// $Id: OverlayDialog.h 86e4235 2020-10-04T14:18:34+01:00 Ahmed Essam
// SPDX-License-Identifier: GPL-3.0-or-later OR LicenseRef-Commercial
//
// Author(s)     : Alex Tsui <alextsui05@gmail.com>

#ifndef OVERLAY_DIALOG_H
#define OVERLAY_DIALOG_H

#include <QDialog>
#include <vector>
#include <CGAL/Object.h>

class ArrangementDemoWindow;
class QListWidgetItem;
namespace Ui { class OverlayDialog; }

namespace demo_types
{
enum class TraitsType : int;
}

class OverlayDialog : public QDialog
{
  Q_OBJECT

public:
  typedef enum OverlayDialogRole {
    ARRANGEMENT = 32
  } OverlayDialogRole;

  struct ArrangementInfo
  {
    int id;
    demo_types::TraitsType ttype;
    QString label;
  };
  OverlayDialog(QWidget* parent, const std::vector<ArrangementInfo>&);

  std::vector<int> selectedArrangements() const;

public Q_SLOTS:
  void on_pickPushButton_pressed( );
  void on_unpickPushButton_pressed( );

protected:
  void restrictSelection( QListWidgetItem* item );
  void unrestrictSelection( );

  std::vector<ArrangementInfo> arr_infos;

  Ui::OverlayDialog* ui;
};

#endif // OVERLAY_DIALOG_H
