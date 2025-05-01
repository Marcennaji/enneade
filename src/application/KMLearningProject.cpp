// Copyright (c) 2023-2025 Orange. All rights reserved.
// This software is distributed under the BSD 3-Clause-clear License, the text of which is available
// at https://spdx.org/licenses/BSD-3-Clause-Clear.html or see the "LICENSE" file for more details.

#include "KMLearningProject.h"

#include "KWLearningProject.h"

#include "domain/learning/KMLearningProblem.h"
#include "domain/learning/KMPredictor.h"
#include "domain/learning/KMPredictorKNN.h"
#include "ui/views/KMLearningProblemView.h"
#include "ui/views/KMPredictorView.h"
#include "domain/evaluation/KMClassifierEvaluationTask.h"
#include "domain/evaluation/KMPredictorEvaluationTask.h"
#include "domain/clustering/KMRandomInitialisationTask.h"
#include "ui/views/KMPredictorKNNView.h"
#include "KMDRRegisterAllRules.h"

KMLearningProject::KMLearningProject()
{
}

KMLearningProject::~KMLearningProject()
{
}

KWLearningProblem* KMLearningProject::CreateLearningProblem()
{
	return new KMLearningProblem;
}

KWLearningProblemView* KMLearningProject::CreateLearningProblemView()
{
	return new KMLearningProblemView;
}

void KMLearningProject::OpenLearningEnvironnement()
{
	// code par defaut
	KWLearningProject::OpenLearningEnvironnement();

	UIObject::SetIconImage("enneade.gif");

	SetLearningApplicationName("Enneade");

	// enregistrements specifiques Enneade

	KMDRRegisterAllRules(); // regles de derivation
	KWPredictor::RegisterPredictor(new KMPredictor);
	KWPredictor::RegisterPredictor(new KMPredictorKNN);
	KWPredictorView::RegisterPredictorView(new KMPredictorView);
	KWPredictorView::RegisterPredictorView(new KMPredictorKNNView);
	PLParallelTask::RegisterTask(new KMClassifierEvaluationTask);
	PLParallelTask::RegisterTask(new KMPredictorEvaluationTask);
	PLParallelTask::RegisterTask(new KMRandomInitialisationTask);
}

