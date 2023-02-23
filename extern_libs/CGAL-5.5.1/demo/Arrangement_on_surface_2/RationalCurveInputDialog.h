// Copyright (c) 2020 GeometryFactory Sarl (France).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org).
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Arrangement_on_surface_2/demo/Arrangement_on_surface_2/RationalCurveInputDialog.h $
// $Id: RationalCurveInputDialog.h cc99fd9 2021-02-19T16:02:12+01:00 Maxime Gimeno
// SPDX-License-Identifier: GPL-3.0-or-later OR LicenseRef-Commercial
//
// Author(s): Ahmed Essam <theartful.ae@gmail.com>

#ifndef ARRANGEMENT_DEMO_RATIONAL_CURVE_INPUT_DIALOG_H
#define ARRANGEMENT_DEMO_RATIONAL_CURVE_INPUT_DIALOG_H

#include <QDialog>

namespace Ui
{
class RationalCurveInputDialog;
}

class RationalCurveInputDialog : public QDialog
{
    Q_OBJECT

public:
    explicit RationalCurveInputDialog(QWidget *parent = nullptr);
    ~RationalCurveInputDialog();
    std::string getNumeratorText();
    std::string getDenominatorText();
    Ui::RationalCurveInputDialog* getUi(){return this->ui;}

private:
    Ui::RationalCurveInputDialog *ui;
};

#endif // ALGEBRAICCURVEINPUTDIALOG_H

